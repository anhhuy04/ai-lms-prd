-- 031_normalize_legacy_text_key.sql
-- Dọn data legacy: 3 câu inline (question_id NULL) dùng key cũ 'text' thay vì
-- 'override_text' trong custom_content. Read path có fallback (`override_text ??
-- text`) nên vẫn render đúng, nhưng chuẩn hoá để nhất quán schema + tránh phụ
-- thuộc fallback về sau.
--
-- An toàn tuyệt đối: 3 câu đều 0 submission, 0 work_session. Chỉ rename key,
-- giữ nguyên value + mọi key khác (type, choices). Idempotent (lần 2 match 0 dòng).

BEGIN;

DO $$
DECLARE v_count int;
BEGIN
  WITH upd AS (
    UPDATE public.assignment_questions
    SET custom_content =
        (custom_content - 'text')
        || jsonb_build_object('override_text', custom_content->>'text')
    WHERE question_id IS NULL
      AND custom_content IS NOT NULL
      AND NOT (custom_content ? 'override_text')
      AND (custom_content ? 'text')
    RETURNING 1
  )
  SELECT count(*) INTO v_count FROM upd;
  RAISE NOTICE '[031] normalized % legacy text→override_text rows', v_count;
END $$;

COMMIT;
