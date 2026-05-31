-- 030_delta_override_hardening.sql
-- Hardening sau vòng review 5-agent (các phát hiện THẬT, không phải false alarm):
--
-- FIX 1 (publish_assignment): nhánh INSERT dùng `(q->>'question_id')::uuid` KHÔNG
--   có nullif → nếu client gửi question_id = "" (empty string) sẽ crash
--   `invalid input syntax for type uuid`. create/replace RPC đã dùng nullif;
--   publish bị sót → thêm cho nhất quán + chống crash.
--
-- FIX 2 (fn_normalize_aq_content): ORDER BY (c->>'id')::int khi so choices sẽ
--   crash nếu id không phải số (vd 'choice-0'). Dữ liệu hiện tại toàn int nên
--   chưa nổ, nhưng harden: cast an toàn (regex guard) để không bao giờ crash RPC.
--
-- Cả 2 là CREATE OR REPLACE (idempotent). Không đụng dữ liệu.

BEGIN;

-- ============================================================
-- FIX 2: fn_normalize_aq_content — ordering choices an toàn
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
  IF p_question_id IS NULL THEN
    RETURN jsonb_build_object('question_id', NULL, 'custom_content', p_custom_content);
  END IF;

  SELECT is_global, content INTO v_is_global, v_bank_content
  FROM public.questions WHERE id = p_question_id;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('question_id', NULL, 'custom_content', p_custom_content);
  END IF;

  IF v_is_global IS NOT TRUE THEN
    RETURN jsonb_build_object('question_id', NULL, 'custom_content', p_custom_content);
  END IF;

  IF p_custom_content IS NULL THEN
    RETURN jsonb_build_object('question_id', p_question_id, 'custom_content', NULL);
  END IF;

  v_custom    := '{}'::jsonb;
  v_bank_text := COALESCE(v_bank_content->>'text', v_bank_content->>'override_text');

  v_ov_text := p_custom_content->>'override_text';
  IF v_ov_text IS NOT NULL AND v_ov_text IS DISTINCT FROM v_bank_text THEN
    v_custom := v_custom || jsonb_build_object('override_text', v_ov_text);
  END IF;

  IF p_custom_content ? 'choices'
     AND jsonb_typeof(p_custom_content->'choices') = 'array' THEN
    -- HARDEN: cast id an toàn (regex guard) để không crash nếu id non-numeric.
    v_custom_ch := (
      SELECT jsonb_agg(jsonb_build_object(
               't', c->>'text',
               'c', COALESCE((c->>'isCorrect')::bool, (c->>'is_correct')::bool, false))
             ORDER BY
               CASE WHEN (c->>'id') ~ '^[0-9]+$' THEN (c->>'id')::int ELSE NULL END NULLS LAST,
               (c->>'id'))
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
-- FIX 1: publish_assignment — thêm nullif cho question_id
-- (chỉ đổi 1 dòng trong nhánh INSERT; giữ nguyên toàn bộ phần còn lại)
-- ============================================================
CREATE OR REPLACE FUNCTION public.publish_assignment(
  p_assignment jsonb,
  p_questions jsonb DEFAULT '[]'::jsonb,
  p_distributions jsonb DEFAULT '[]'::jsonb
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
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

  v_class_id := nullif(p_assignment->>'class_id','')::uuid;
  IF v_class_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1 FROM public.classes c
      WHERE c.id = v_class_id AND (v_is_admin OR c.teacher_id = v_teacher_id)
    ) THEN
      RAISE EXCEPTION 'Forbidden: class not owned by teacher';
    END IF;
  END IF;

  v_assignment_id := nullif(p_assignment->>'id','')::uuid;
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
        nullif(q->>'question_id', '')::uuid, q->'custom_content'   -- FIX: nullif
      ) AS norm;
    END IF;
  END IF;

  IF NOT v_has_sessions AND jsonb_typeof(p_distributions) = 'array' AND jsonb_array_length(p_distributions) > 0 THEN
    DELETE FROM public.assignment_distributions WHERE assignment_id = v_assignment_id;
    INSERT INTO public.assignment_distributions (
      assignment_id, distribution_type, class_id, group_id, student_ids,
      available_from, due_at, time_limit_minutes, allow_late, late_policy
    )
    SELECT
      v_assignment_id,
      (d->>'distribution_type')::text,
      nullif(d->>'class_id','')::uuid,
      nullif(d->>'group_id','')::uuid,
      CASE WHEN d ? 'student_ids' AND d->'student_ids' IS NOT NULL
        THEN ARRAY(SELECT jsonb_array_elements_text(d->'student_ids')::uuid) ELSE NULL END,
      nullif(d->>'available_from','')::timestamptz,
      nullif(d->>'due_at','')::timestamptz,
      nullif(d->>'time_limit_minutes','')::int,
      COALESCE((d->>'allow_late')::boolean, TRUE),
      d->'late_policy'
    FROM jsonb_array_elements(p_distributions) AS d;
  END IF;

  SELECT * INTO v_assignment_row FROM public.assignments WHERE id = v_assignment_id;
  RETURN to_jsonb(v_assignment_row);
END;
$function$;

COMMIT;
