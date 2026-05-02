-- ==============================================================================
-- MIGRATION: Phase 06 - Redo Assignment + Score Aggregation
-- Created: 2026-05-02
-- Purpose: Immutable multi-attempt redo, score aggregation RPCs, RLS guards
-- ==============================================================================

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 0: Dedupe work_sessions
--    5 pairs tìm thấy qua điều tra: row cũ hơn giữ attempt=1, row mới hơn → 2
-- ══════════════════════════════════════════════════════════════════════════════
UPDATE public.work_sessions
SET attempt = 2
WHERE id IN (
  '3a1a84bb-2a6d-4db5-8179-40557ba0dd68',
  'acddd34e-f762-4846-a327-088b039f3f79',
  '937d1f52-84bc-4f0f-a941-0dbb6ade6994',
  '6c746779-156c-462a-8b9e-dac9cef20684',
  'b60a4d7a-b0ae-42e2-9e4c-f54ccc77f759'
);

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 1: Thêm session_id vào assignment_variants
--    Cho phép idempotency per-session trong ensure_student_variant_for_session.
--    Nullable để không phá variant cũ (created trước migration này).
-- ══════════════════════════════════════════════════════════════════════════════
ALTER TABLE public.assignment_variants
  ADD COLUMN IF NOT EXISTS session_id UUID
    REFERENCES public.work_sessions(id) ON DELETE SET NULL;

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 2: UNIQUE constraint trên work_sessions
--    Ngăn 2 session cùng attempt cho cùng (distribution, student).
--    Phải chạy AFTER STEP 0 (dedupe) để không conflict.
-- ══════════════════════════════════════════════════════════════════════════════
ALTER TABLE public.work_sessions
  ADD CONSTRAINT uq_work_sessions_dist_student_attempt
  UNIQUE (assignment_distribution_id, student_id, attempt);

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 3: Backfill settings JSON cho mọi distribution cũ
--    Thêm allow_retake, max_attempts, score_aggregation_rule nếu chưa có.
-- ══════════════════════════════════════════════════════════════════════════════
UPDATE public.assignment_distributions
SET settings = settings || jsonb_build_object(
  'allow_retake',           false,
  'max_attempts',           1,
  'score_aggregation_rule', 'latest'
)
WHERE NOT (settings ? 'allow_retake');

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 4: Cập nhật DEFAULT của cột settings
--    Distribution mới sẽ có đủ tất cả keys ngay từ đầu.
-- ══════════════════════════════════════════════════════════════════════════════
ALTER TABLE public.assignment_distributions
  ALTER COLUMN settings SET DEFAULT
  '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true, "allow_retake": false, "max_attempts": 1, "score_aggregation_rule": "latest"}'::jsonb;

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 5: RPC ensure_student_variant_for_session
--    Tạo variant mới PER SESSION (không xóa variant cũ — immutable records).
--    Idempotent theo session_id. Seed từ session_id để deterministic per attempt.
-- ══════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.ensure_student_variant_for_session(
  p_session_id    UUID,
  p_assignment_id UUID,
  p_student_id    UUID,
  p_attempt       INTEGER
) RETURNS UUID
SECURITY DEFINER SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_variant_id     UUID;
  v_settings       JSONB;
  v_shuffle_q      BOOLEAN := false;
  v_shuffle_c      BOOLEAN := false;
  v_seed           BIGINT;
  v_aq_rows        JSONB;
  v_q_ids          JSONB;
  v_shuffled_q_ids JSONB;
  v_result         JSONB := '[]'::JSONB;
  v_aq_id          TEXT;
  v_display_order  INT;
  v_choices_raw    JSONB;
  v_choice_ids     JSONB;
BEGIN
  -- [RLS] Chỉ student đó hoặc call từ start_redo_session (cùng student context)
  IF auth.uid() IS DISTINCT FROM p_student_id THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Student can only create variant for themselves';
  END IF;

  -- [IDEMPOTENT] Trả về variant đã tạo cho session này (không tạo lại)
  SELECT id INTO v_variant_id
  FROM assignment_variants
  WHERE session_id = p_session_id
    AND variant_type = 'student'
  LIMIT 1;

  IF v_variant_id IS NOT NULL THEN
    RETURN v_variant_id;
  END IF;

  -- Đọc shuffle settings từ distribution của session này
  SELECT ad.settings INTO v_settings
  FROM work_sessions ws
  JOIN assignment_distributions ad ON ad.id = ws.assignment_distribution_id
  WHERE ws.id = p_session_id;

  -- Fallback về assignment defaults nếu không tìm được distribution settings
  IF v_settings IS NULL THEN
    SELECT jsonb_build_object(
      'shuffle_questions', a.default_shuffle_questions,
      'shuffle_choices',   a.default_shuffle_choices
    ) INTO v_settings
    FROM assignments a
    WHERE a.id = p_assignment_id;
  END IF;

  IF v_settings IS NOT NULL THEN
    v_shuffle_q := COALESCE((v_settings->>'shuffle_questions')::BOOLEAN, false);
    v_shuffle_c := COALESCE((v_settings->>'shuffle_choices')::BOOLEAN, false);
  END IF;

  -- Seed deterministic từ session_id: mỗi attempt có variant khác nhau
  v_seed := (
    ('x' || substr(md5(p_session_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000 * 1000000000 +
    ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
  );

  -- Lấy tất cả assignment_questions theo order_idx
  SELECT jsonb_agg(
    jsonb_build_object('aq_id', aq.id::TEXT, 'order_idx', aq.order_idx)
    ORDER BY aq.order_idx
  ) INTO v_aq_rows
  FROM assignment_questions aq
  WHERE aq.assignment_id = p_assignment_id;

  IF v_aq_rows IS NULL OR jsonb_array_length(v_aq_rows) = 0 THEN
    RAISE EXCEPTION 'no_questions_found'
      USING HINT = format('No questions found for assignment %s', p_assignment_id);
  END IF;

  -- Tách array aq_ids
  SELECT jsonb_agg(elem->>'aq_id')
  INTO v_q_ids
  FROM jsonb_array_elements(v_aq_rows) elem;

  -- Shuffle thứ tự câu hỏi nếu cần
  IF v_shuffle_q THEN
    v_shuffled_q_ids := shuffle_with_seed(v_q_ids, v_seed);
  ELSE
    v_shuffled_q_ids := v_q_ids;
  END IF;

  -- Build custom_questions: pointer + shuffled_choices cho từng câu
  FOR v_display_order IN 1..jsonb_array_length(v_shuffled_q_ids)
  LOOP
    v_aq_id := v_shuffled_q_ids->>(v_display_order - 1);

    -- Lấy choice IDs (inline custom_content hoặc từ question_choices bank)
    SELECT
      CASE
        WHEN aq.question_id IS NULL AND aq.custom_content ? 'choices' THEN
          (SELECT jsonb_agg((c->>'id')::INT)
           FROM jsonb_array_elements(aq.custom_content->'choices') c)
        WHEN aq.question_id IS NOT NULL THEN
          (SELECT jsonb_agg(qc.id ORDER BY qc.id)
           FROM question_choices qc
           WHERE qc.question_id = aq.question_id)
        ELSE '[]'::JSONB
      END
    INTO v_choices_raw
    FROM assignment_questions aq
    WHERE aq.id = v_aq_id::UUID;

    v_choice_ids := COALESCE(v_choices_raw, '[]'::JSONB);

    IF v_shuffle_c AND jsonb_array_length(v_choice_ids) > 1 THEN
      v_choice_ids := shuffle_with_seed(v_choice_ids, v_seed + v_display_order * 997);
    END IF;

    v_result := v_result || jsonb_build_array(
      jsonb_build_object(
        'assignment_question_id', v_aq_id,
        'display_order',          v_display_order,
        'shuffled_choices',       v_choice_ids
      )
    );
  END LOOP;

  -- Insert variant mới gắn với session_id (KHÔNG xóa variant cũ — immutable)
  INSERT INTO assignment_variants (
    assignment_id, variant_type, student_id, session_id, custom_questions, created_at
  ) VALUES (
    p_assignment_id, 'student', p_student_id, p_session_id, v_result, NOW()
  )
  RETURNING id INTO v_variant_id;

  RETURN v_variant_id;
END;
$$;

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 6: RPC start_redo_session (TRÁI TIM — atomic, SECURITY DEFINER)
--    Tạo work_session mới + variant mới cho redo attempt.
--    Validate đầy đủ: active, not past_due, allow_retake, max_attempts,
--    no in_progress session, first attempt exists.
-- ══════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.start_redo_session(
  p_distribution_id UUID,
  p_student_id      UUID
) RETURNS JSONB
SECURITY DEFINER SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_assignment_id  UUID;
  v_dist_status    TEXT;
  v_due_at         TIMESTAMPTZ;
  v_allow_late     BOOLEAN;
  v_settings       JSONB;
  v_allow_retake   BOOLEAN;
  v_max_attempts   INT;
  v_current_max    INT;
  v_unfinished     INT;
  v_new_attempt    INT;
  v_session_id     UUID;
  v_variant_id     UUID;
BEGIN
  -- [RLS] Chỉ student đó mới được start redo session cho chính mình
  IF auth.uid() IS DISTINCT FROM p_student_id THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Student can only start redo session for themselves';
  END IF;

  -- Lock distribution row để tránh race condition
  SELECT
    d.assignment_id,
    d.status,
    d.due_at,
    d.allow_late,
    d.settings
  INTO
    v_assignment_id, v_dist_status, v_due_at, v_allow_late, v_settings
  FROM public.assignment_distributions d
  WHERE d.id = p_distribution_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'distribution_not_found'
      USING HINT = 'Distribution does not exist';
  END IF;

  -- Validate: distribution phải active
  IF v_dist_status != 'active' THEN
    RAISE EXCEPTION 'distribution_closed'
      USING HINT = 'Distribution is not active';
  END IF;

  -- Validate: không quá hạn (trừ khi allow_late)
  IF v_due_at IS NOT NULL
     AND v_due_at < now()
     AND NOT COALESCE(v_allow_late, true)
  THEN
    RAISE EXCEPTION 'past_due'
      USING HINT = 'Assignment is past due date';
  END IF;

  -- Validate: GV phải bật allow_retake
  v_allow_retake := COALESCE((v_settings->>'allow_retake')::BOOLEAN, false);
  IF NOT v_allow_retake THEN
    RAISE EXCEPTION 'retake_not_allowed'
      USING HINT = 'Teacher has not enabled retakes for this assignment';
  END IF;

  -- Đếm attempt lớn nhất hiện tại của học sinh
  SELECT COALESCE(MAX(ws.attempt), 0)
  INTO v_current_max
  FROM public.work_sessions ws
  WHERE ws.assignment_distribution_id = p_distribution_id
    AND ws.student_id = p_student_id;

  -- Validate: phải có ít nhất 1 lần làm trước đó
  IF v_current_max = 0 THEN
    RAISE EXCEPTION 'no_prior_attempt'
      USING HINT = 'Student has not started this assignment yet';
  END IF;

  -- Validate: chưa đạt max_attempts (0 hoặc NULL = unlimited)
  v_max_attempts := COALESCE((v_settings->>'max_attempts')::INT, 0);
  IF v_max_attempts > 0 AND v_current_max >= v_max_attempts THEN
    RAISE EXCEPTION 'max_attempts_reached'
      USING HINT = 'Student has reached the maximum number of allowed attempts';
  END IF;

  -- Validate: không có session nào đang dở dang (in_progress / ai_processing / pending_review)
  SELECT COUNT(*)
  INTO v_unfinished
  FROM public.work_sessions ws
  WHERE ws.assignment_distribution_id = p_distribution_id
    AND ws.student_id = p_student_id
    AND ws.status NOT IN ('submitted', 'graded');

  IF v_unfinished > 0 THEN
    RAISE EXCEPTION 'session_in_progress'
      USING HINT = 'Student has an unfinished session — must complete it before redo';
  END IF;

  v_new_attempt := v_current_max + 1;

  -- Tạo work_session mới với attempt tăng thêm 1
  INSERT INTO public.work_sessions (
    assignment_distribution_id,
    assignment_id,
    student_id,
    attempt,
    status,
    started_at
  ) VALUES (
    p_distribution_id,
    v_assignment_id,
    p_student_id,
    v_new_attempt,
    'in_progress',
    now()
  )
  RETURNING id INTO v_session_id;

  -- Tạo variant mới cho session này (deterministic theo session_id)
  v_variant_id := public.ensure_student_variant_for_session(
    v_session_id,
    v_assignment_id,
    p_student_id,
    v_new_attempt
  );

  RETURN jsonb_build_object(
    'session_id',  v_session_id,
    'attempt',     v_new_attempt,
    'variant_id',  v_variant_id
  );

EXCEPTION
  -- Convert unique constraint violation thành lỗi rõ ràng hơn
  WHEN unique_violation THEN
    RAISE EXCEPTION 'concurrent_redo_attempt'
      USING HINT = 'Another redo session was started concurrently. Please refresh and try again.';
  WHEN OTHERS THEN
    RAISE;
END;
$$;

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 7: RPC get_aggregated_scores_for_distribution
--    Trả về 1 row per student với final_score theo rule: latest / max / average.
--    Teacher-only (kiểm tra teacher_id = auth.uid()).
-- ══════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE FUNCTION public.get_aggregated_scores_for_distribution(
  p_distribution_id UUID,
  p_rule            TEXT DEFAULT NULL
) RETURNS TABLE (
  student_id          UUID,
  final_score         NUMERIC,
  attempts_count      INTEGER,
  final_submission_id UUID,
  final_session_id    UUID
)
SECURITY DEFINER SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_rule       TEXT;
  v_teacher_id UUID;
BEGIN
  -- [RLS] Chỉ teacher của assignment này được gọi
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Authentication required';
  END IF;

  SELECT a.teacher_id INTO v_teacher_id
  FROM public.assignment_distributions ad
  JOIN public.assignments a ON a.id = ad.assignment_id
  WHERE ad.id = p_distribution_id;

  IF v_teacher_id IS DISTINCT FROM auth.uid() THEN
    RAISE EXCEPTION 'permission_denied'
      USING HINT = 'Only the teacher who owns this assignment can view aggregated scores';
  END IF;

  -- Dùng override rule nếu có, nếu không đọc từ distribution.settings
  IF p_rule IS NOT NULL THEN
    v_rule := p_rule;
  ELSE
    SELECT COALESCE(d.settings->>'score_aggregation_rule', 'latest')
    INTO v_rule
    FROM public.assignment_distributions d
    WHERE d.id = p_distribution_id;
  END IF;

  IF v_rule = 'average' THEN
    -- Trung bình tất cả attempts, không có final_submission_id / final_session_id
    RETURN QUERY
      SELECT
        ws.student_id,
        ROUND(AVG(s.total_score)::numeric, 2)  AS final_score,
        COUNT(*)::INTEGER                       AS attempts_count,
        NULL::UUID                              AS final_submission_id,
        NULL::UUID                              AS final_session_id
      FROM public.work_sessions ws
      JOIN public.submissions s ON s.session_id = ws.id
      WHERE ws.assignment_distribution_id = p_distribution_id
        AND COALESCE(s.is_voided, false) = false
        AND s.total_score IS NOT NULL
      GROUP BY ws.student_id;

  ELSIF v_rule = 'max' THEN
    -- Điểm cao nhất (tie-break: attempt gần nhất)
    RETURN QUERY
      WITH ranked AS (
        SELECT
          ws.student_id,
          ws.id         AS session_id,
          s.id          AS submission_id,
          s.total_score,
          COUNT(*) OVER (PARTITION BY ws.student_id)::INTEGER AS attempts_count,
          ROW_NUMBER() OVER (
            PARTITION BY ws.student_id
            ORDER BY s.total_score DESC NULLS LAST, ws.attempt DESC
          ) AS rn
        FROM public.work_sessions ws
        JOIN public.submissions s ON s.session_id = ws.id
        WHERE ws.assignment_distribution_id = p_distribution_id
          AND COALESCE(s.is_voided, false) = false
          AND s.total_score IS NOT NULL
      )
      SELECT
        student_id,
        total_score      AS final_score,
        attempts_count,
        submission_id    AS final_submission_id,
        session_id       AS final_session_id
      FROM ranked
      WHERE rn = 1;

  ELSE
    -- 'latest' (default): attempt số lớn nhất
    RETURN QUERY
      WITH ranked AS (
        SELECT
          ws.student_id,
          ws.id         AS session_id,
          s.id          AS submission_id,
          s.total_score,
          COUNT(*) OVER (PARTITION BY ws.student_id)::INTEGER AS attempts_count,
          ROW_NUMBER() OVER (
            PARTITION BY ws.student_id
            ORDER BY ws.attempt DESC
          ) AS rn
        FROM public.work_sessions ws
        JOIN public.submissions s ON s.session_id = ws.id
        WHERE ws.assignment_distribution_id = p_distribution_id
          AND COALESCE(s.is_voided, false) = false
          AND s.total_score IS NOT NULL
      )
      SELECT
        student_id,
        total_score      AS final_score,
        attempts_count,
        submission_id    AS final_submission_id,
        session_id       AS final_session_id
      FROM ranked
      WHERE rn = 1;
  END IF;
END;
$$;

-- ══════════════════════════════════════════════════════════════════════════════
-- STEP 8: View v_student_attempts_summary
--    Phục vụ Teacher UI: tóm tắt tất cả attempts của học sinh.
-- ══════════════════════════════════════════════════════════════════════════════
CREATE OR REPLACE VIEW public.v_student_attempts_summary AS
SELECT
  ws.id                          AS session_id,
  ws.assignment_distribution_id,
  ws.student_id,
  ws.attempt,
  ws.status                      AS session_status,
  ws.started_at,
  ws.submitted_at,
  s.id                           AS submission_id,
  s.total_score,
  s.is_late,
  s.is_voided
FROM public.work_sessions ws
LEFT JOIN public.submissions s ON s.session_id = ws.id
ORDER BY ws.student_id, ws.attempt;
