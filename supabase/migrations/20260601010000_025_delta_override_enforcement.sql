-- 025_delta_override_enforcement.sql
-- Mục tiêu: Ép Data Contract "Delta Override" cho assignment_questions, xoá data bloat.
--
-- Bối cảnh (verify bằng DB thật 2026-05-30):
--   * 41 dòng bank GLOBAL  + custom_content NULL        → S1 (đúng).
--   * 112 dòng bank PRIVATE + custom_content full payload → rác (RLS chặn học sinh đọc bank
--     private nên full payload là snapshot BẮT BUỘC; cách chuẩn là cắt link → inline S3).
--   * 139 dòng inline (question_id NULL)                 → S3 (đúng).
--
-- Khế ước sau migration:
--   - question_id NULL                       → custom_content = full snapshot (S3 inline)
--   - question_id + bank GLOBAL, không sửa   → custom_content NULL (S1)
--   - question_id + bank GLOBAL, có sửa      → custom_content = diff {override_text?, choices?} (S2)
--   - question_id + bank PRIVATE             → KHÔNG tồn tại (luôn cắt link → S3)
--   Invariant: question_id NOT NULL  ⟹  custom_content KHÔNG chứa key 'type'.
--
-- Dry-run đã chứng minh: resolved-view (text + choices học sinh thấy) BẤT BIẾN 153/153 dòng.

BEGIN;

-- ============================================================
-- 1. HELPER: chuẩn hoá (question_id, custom_content) theo khế ước.
--    Trả jsonb {question_id, custom_content}. Dùng chung cho 2 RPC + backfill.
-- ============================================================
CREATE OR REPLACE FUNCTION public.fn_normalize_aq_content(
  p_question_id uuid,
  p_custom_content jsonb
) RETURNS jsonb
LANGUAGE plpgsql STABLE
SET search_path = public, pg_temp
AS $$
DECLARE
  v_is_global    boolean;
  v_bank_content jsonb;
  v_bank_text    text;
  v_custom       jsonb;
  v_ov_text      text;
  v_custom_ch    jsonb;
  v_bank_ch      jsonb;
BEGIN
  -- Inline (không link bank) → giữ nguyên full snapshot (S3)
  IF p_question_id IS NULL THEN
    RETURN jsonb_build_object('question_id', NULL, 'custom_content', p_custom_content);
  END IF;

  SELECT is_global, content INTO v_is_global, v_bank_content
  FROM public.questions WHERE id = p_question_id;

  -- Bank không tồn tại → coi như inline (giữ snapshot, cắt link an toàn)
  IF NOT FOUND THEN
    RETURN jsonb_build_object('question_id', NULL, 'custom_content', p_custom_content);
  END IF;

  -- PRIVATE: học sinh không đọc được bank (RLS) → snapshot, cắt link → S3 inline
  IF v_is_global IS NOT TRUE THEN
    RETURN jsonb_build_object('question_id', NULL, 'custom_content', p_custom_content);
  END IF;

  -- GLOBAL: chỉ giữ DIFF (whitelist override_text, choices)
  IF p_custom_content IS NULL THEN
    RETURN jsonb_build_object('question_id', p_question_id, 'custom_content', NULL);
  END IF;

  v_custom    := '{}'::jsonb;
  v_bank_text := COALESCE(v_bank_content->>'text', v_bank_content->>'override_text');

  -- override_text: chỉ giữ nếu KHÁC bank
  v_ov_text := p_custom_content->>'override_text';
  IF v_ov_text IS NOT NULL AND v_ov_text IS DISTINCT FROM v_bank_text THEN
    v_custom := v_custom || jsonb_build_object('override_text', v_ov_text);
  END IF;

  -- choices: SNAPSHOT trọn mảng nếu KHÁC bank (so text + is_correct theo thứ tự).
  -- Không bao giờ diff từng phần tử (tránh Array Annihilation khi merge JSONB).
  IF p_custom_content ? 'choices'
     AND jsonb_typeof(p_custom_content->'choices') = 'array' THEN
    v_custom_ch := (
      SELECT jsonb_agg(jsonb_build_object(
               't', c->>'text',
               'c', COALESCE((c->>'isCorrect')::bool, (c->>'is_correct')::bool, false))
             ORDER BY (c->>'id')::int)
      FROM jsonb_array_elements(p_custom_content->'choices') c
    );
    v_bank_ch := (
      SELECT jsonb_agg(jsonb_build_object('t', qc.content->>'text', 'c', qc.is_correct)
             ORDER BY qc.id)
      FROM public.question_choices qc WHERE qc.question_id = p_question_id
    );
    IF v_custom_ch IS DISTINCT FROM v_bank_ch THEN
      v_custom := v_custom || jsonb_build_object('choices', p_custom_content->'choices');
    END IF;
  END IF;

  IF v_custom = '{}'::jsonb THEN
    v_custom := NULL;
  END IF;

  RETURN jsonb_build_object('question_id', p_question_id, 'custom_content', v_custom);
END;
$$;

REVOKE ALL ON FUNCTION public.fn_normalize_aq_content(uuid, jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.fn_normalize_aq_content(uuid, jsonb) TO authenticated;

-- ============================================================
-- 2. create_assignment_with_questions: chặn nguồn sinh rác.
--    THAY ĐỔI CỐT LÕI: câu inline (không có 'id') KHÔNG còn insert vào
--    public.questions (trước đây tạo câu bank PRIVATE rồi link → nguồn của
--    112 dòng rác). Inline giờ lưu thẳng question_id NULL + full snapshot.
--    Câu bank-linked ('id' có) đi qua fn_normalize_aq_content.
-- ============================================================
CREATE OR REPLACE FUNCTION public.create_assignment_with_questions(
  p_teacher_id uuid,
  p_payload jsonb
) RETURNS uuid
LANGUAGE plpgsql
AS $function$
DECLARE
  v_assignment      jsonb;
  v_questions       jsonb;
  v_assignment_id   uuid;
  v_question        jsonb;
  v_question_id     uuid;
  v_norm            jsonb;
  v_custom_content  jsonb;
  v_total_points    numeric(8,2);
  v_expected_points numeric(8,2);
  v_count_questions integer;
  v_order_idx       integer;
BEGIN
  IF p_payload IS NULL THEN
    RAISE EXCEPTION 'PAYLOAD_REQUIRED';
  END IF;

  v_assignment := COALESCE(p_payload->'assignment', '{}'::jsonb);

  IF COALESCE(v_assignment->>'title', '') = '' THEN
    RAISE EXCEPTION 'ASSIGNMENT_TITLE_REQUIRED';
  END IF;

  INSERT INTO public.assignments (class_id, teacher_id, title, description, is_published, total_points)
  VALUES (
    nullif(v_assignment->>'class_id', '')::uuid,
    p_teacher_id,
    v_assignment->>'title',
    nullif(v_assignment->>'description', ''),
    false,
    CASE WHEN v_assignment ? 'total_points' THEN (v_assignment->>'total_points')::numeric ELSE NULL END
  )
  RETURNING id INTO v_assignment_id;

  v_questions := COALESCE(p_payload->'questions', '[]'::jsonb);
  IF jsonb_typeof(v_questions) <> 'array' THEN
    RAISE EXCEPTION 'QUESTIONS_MUST_BE_ARRAY';
  END IF;

  FOR v_question IN SELECT value FROM jsonb_array_elements(v_questions)
  LOOP
    -- Bank-linked nếu có 'id'; inline nếu không. KHÔNG tạo câu bank mới cho inline.
    v_question_id := nullif(v_question->>'id', '')::uuid;

    -- Chuẩn hoá theo khế ước (private→cắt link, global→diff, inline→giữ full)
    v_norm := public.fn_normalize_aq_content(v_question_id, v_question->'custom_content');
    v_question_id    := nullif(v_norm->>'question_id', '')::uuid;
    v_custom_content := CASE WHEN v_norm->'custom_content' = 'null'::jsonb
                             THEN NULL ELSE v_norm->'custom_content' END;

    IF NOT (v_question ? 'order_idx') THEN
      RAISE EXCEPTION 'ORDER_IDX_REQUIRED_FOR_EACH_QUESTION';
    END IF;
    v_order_idx := (v_question->>'order_idx')::int;

    INSERT INTO public.assignment_questions (assignment_id, question_id, custom_content, points, rubric, order_idx)
    VALUES (
      v_assignment_id,
      v_question_id,
      v_custom_content,
      COALESCE((v_question->>'points')::numeric, (v_question->>'default_points')::numeric, 1),
      v_question->'rubric',
      v_order_idx
    );
  END LOOP;

  SELECT count(*)::int, COALESCE(sum(points), 0)::numeric(8,2)
    INTO v_count_questions, v_total_points
    FROM public.assignment_questions WHERE assignment_id = v_assignment_id;

  IF v_count_questions = 0 THEN
    RAISE EXCEPTION 'ASSIGNMENT_MUST_HAVE_QUESTION';
  END IF;

  IF v_assignment ? 'total_points' THEN
    v_expected_points := (v_assignment->>'total_points')::numeric;
    IF v_expected_points <> v_total_points THEN
      RAISE EXCEPTION 'TOTAL_POINTS_MISMATCH: expected %, got %', v_expected_points, v_total_points;
    END IF;
  END IF;

  UPDATE public.assignments SET total_points = v_total_points WHERE id = v_assignment_id;

  RETURN v_assignment_id;

EXCEPTION
  WHEN others THEN
    RAISE EXCEPTION 'CREATE_ASSIGNMENT_FAILED: %', sqlerrm USING errcode = 'P0001';
END;
$function$;

-- ============================================================
-- 3. publish_assignment: thêm chuẩn hoá custom_content khi INSERT
--    assignment_questions. Giữ nguyên auth + guard v_has_sessions +
--    distributions (chỉ đổi nhánh INSERT questions).
-- ============================================================
CREATE OR REPLACE FUNCTION public.publish_assignment(
  p_assignment jsonb,
  p_questions jsonb DEFAULT '[]'::jsonb,
  p_distributions jsonb DEFAULT '[]'::jsonb
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_is_admin boolean := false;
  v_teacher_id uuid;
  v_assignment_id uuid;
  v_assignment_row public.assignments%rowtype;
  v_class_id uuid;
  v_has_sessions boolean := false;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = v_uid AND role = 'admin') INTO v_is_admin;

  IF v_is_admin THEN
    v_teacher_id := COALESCE((p_assignment->>'teacher_id')::uuid, v_uid);
  ELSE
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = v_uid AND role = 'teacher') THEN
      RAISE EXCEPTION 'Forbidden: only teachers can publish assignments';
    END IF;
    v_teacher_id := v_uid;
  END IF;

  v_class_id := (p_assignment->>'class_id')::uuid;
  IF v_class_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.classes c
      WHERE c.id = v_class_id AND (v_is_admin OR c.teacher_id = v_teacher_id)
    ) THEN
      RAISE EXCEPTION 'Forbidden: class not owned by teacher';
    END IF;
  END IF;

  v_assignment_id := (p_assignment->>'id')::uuid;
  IF v_assignment_id IS NOT NULL THEN
    IF NOT v_is_admin AND NOT EXISTS (
      SELECT 1 FROM public.assignments a WHERE a.id = v_assignment_id AND a.teacher_id = v_teacher_id
    ) THEN
      RAISE EXCEPTION 'Forbidden: assignment not owned by teacher';
    END IF;

    UPDATE public.assignments
    SET class_id = v_class_id,
        title = COALESCE(p_assignment->>'title', title),
        description = p_assignment->>'description',
        total_points = (p_assignment->>'total_points')::numeric,
        is_published = TRUE,
        published_at = now()
    WHERE id = v_assignment_id
    RETURNING * INTO v_assignment_row;
  ELSE
    INSERT INTO public.assignments (class_id, teacher_id, title, description, is_published, published_at, total_points)
    VALUES (
      v_class_id, v_teacher_id,
      COALESCE(p_assignment->>'title', 'Bài tập mới'),
      p_assignment->>'description', TRUE, now(),
      (p_assignment->>'total_points')::numeric
    )
    RETURNING * INTO v_assignment_row;
    v_assignment_id := v_assignment_row.id;
  END IF;

  SELECT EXISTS(SELECT 1 FROM public.work_sessions WHERE assignment_id = v_assignment_id LIMIT 1)
    INTO v_has_sessions;

  -- Replace assignment_questions (chỉ khi chưa có học sinh làm bài)
  IF NOT v_has_sessions THEN
    DELETE FROM public.assignment_questions WHERE assignment_id = v_assignment_id;
    IF jsonb_typeof(p_questions) = 'array' AND jsonb_array_length(p_questions) > 0 THEN
      INSERT INTO public.assignment_questions (assignment_id, question_id, custom_content, points, rubric, order_idx)
      SELECT
        v_assignment_id,
        nullif(norm->>'question_id', '')::uuid,
        CASE WHEN norm->'custom_content' = 'null'::jsonb THEN NULL ELSE norm->'custom_content' END,
        COALESCE((q->>'points')::numeric, 1),
        q->'rubric',
        (q->>'order_idx')::int
      FROM jsonb_array_elements(p_questions) AS q
      CROSS JOIN LATERAL public.fn_normalize_aq_content(
        (q->>'question_id')::uuid, q->'custom_content'
      ) AS norm;
    END IF;
  END IF;

  -- Replace assignment_distributions (giữ nguyên logic cũ)
  IF NOT v_has_sessions AND jsonb_typeof(p_distributions) = 'array' AND jsonb_array_length(p_distributions) > 0 THEN
    DELETE FROM public.assignment_distributions WHERE assignment_id = v_assignment_id;
    INSERT INTO public.assignment_distributions (
      assignment_id, distribution_type, class_id, group_id, student_ids,
      available_from, due_at, time_limit_minutes, allow_late, late_policy
    )
    SELECT
      v_assignment_id,
      (d->>'distribution_type')::text,
      (d->>'class_id')::uuid,
      (d->>'group_id')::uuid,
      CASE WHEN d ? 'student_ids' AND d->'student_ids' IS NOT NULL
        THEN ARRAY(SELECT jsonb_array_elements_text(d->'student_ids')::uuid) ELSE NULL END,
      (d->>'available_from')::timestamptz,
      (d->>'due_at')::timestamptz,
      (d->>'time_limit_minutes')::int,
      COALESCE((d->>'allow_late')::boolean, TRUE),
      d->'late_policy'
    FROM jsonb_array_elements(p_distributions) AS d;
  END IF;

  SELECT * INTO v_assignment_row FROM public.assignments WHERE id = v_assignment_id;
  RETURN to_jsonb(v_assignment_row);
END;
$function$;

-- ============================================================
-- 4. BACKFILL: dọn các dòng bank-linked + full payload hiện có.
--    Dùng fn_normalize_aq_content → resolved-view BẤT BIẾN (đã chứng minh
--    153/153 identical). private→question_id NULL; global→diff/NULL.
--    KHÔNG đụng submission_answers (FK qua assignment_questions.id, không
--    phụ thuộc question_id). Trigger stats/mastery guard NULL an toàn.
-- ============================================================
DO $backfill$
DECLARE
  v_before int;
  v_after  int;
  v_priv_cut int;
BEGIN
  SELECT count(*) INTO v_before
  FROM public.assignment_questions
  WHERE question_id IS NOT NULL AND (custom_content ? 'type');

  RAISE NOTICE '[025 backfill] garbage rows before = %', v_before;

  WITH norm AS (
    SELECT aq.id,
           public.fn_normalize_aq_content(aq.question_id, aq.custom_content) AS n
    FROM public.assignment_questions aq
    WHERE aq.question_id IS NOT NULL AND (aq.custom_content ? 'type')
  )
  UPDATE public.assignment_questions aq
  SET question_id    = nullif(norm.n->>'question_id', '')::uuid,
      custom_content = CASE WHEN norm.n->'custom_content' = 'null'::jsonb
                           THEN NULL ELSE norm.n->'custom_content' END
  FROM norm
  WHERE aq.id = norm.id;

  GET DIAGNOSTICS v_priv_cut = ROW_COUNT;

  SELECT count(*) INTO v_after
  FROM public.assignment_questions
  WHERE question_id IS NOT NULL AND (custom_content ? 'type');

  RAISE NOTICE '[025 backfill] rows updated = %, garbage rows after = %', v_priv_cut, v_after;

  IF v_after <> 0 THEN
    RAISE EXCEPTION '[025 backfill] FAILED: still % garbage rows after backfill', v_after;
  END IF;
END;
$backfill$;

-- ============================================================
-- 5. CONSTRAINT: khoá khế ước vĩnh viễn.
--    question_id NOT NULL ⟹ custom_content KHÔNG chứa 'type' (chỉ diff).
--    Backfill đã làm sạch 100% → VALIDATE ngay.
-- ============================================================
ALTER TABLE public.assignment_questions
  ADD CONSTRAINT aq_bank_linked_must_be_delta
  CHECK (question_id IS NULL OR custom_content IS NULL OR NOT (custom_content ? 'type'))
  NOT VALID;

ALTER TABLE public.assignment_questions
  VALIDATE CONSTRAINT aq_bank_linked_must_be_delta;

COMMIT;
