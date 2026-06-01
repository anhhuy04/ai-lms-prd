-- 035_normalize_aq_content_hotfix.sql
-- Rủi ro #5: datasource.updateAssignmentQuestionContent() trước đây merge patch
-- rồi .update({'custom_content': merged}) THẲNG lên bảng → bỏ qua
-- fn_normalize_aq_content → câu bank GLOBAL không sửa vẫn sinh override thừa
-- (lẽ ra S1 custom_content NULL, lại thành S2) và có race read-modify-write.
--
-- RPC này gói trọn: đọc custom_content + question_id hiện tại → merge patch
-- (COALESCE NULL → '{}' tránh annihilation JSONB) → chuẩn hoá qua
-- fn_normalize_aq_content (đúng chữ ký migration 025) → UPDATE cả question_id
-- lẫn custom_content theo đúng khế ước Delta Override.
--
-- Authz: chủ assignment hoặc admin (bắt chước pattern 026), tra owner qua
-- JOIN assignment_questions → assignments theo p_aq_id (authz theo aq, không
-- theo assignment_id vì caller chỉ truyền aq id).
--
-- Trả về: full row assignment_questions dạng jsonb (giữ shape Map<String,dynamic>
-- mà datasource/callers đang kỳ vọng).
--
-- Chữ ký: update_assignment_question_content(p_aq_id uuid, p_patch jsonb) -> jsonb

BEGIN;

CREATE OR REPLACE FUNCTION public.update_assignment_question_content(
  p_aq_id uuid,
  p_patch jsonb
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $function$
DECLARE
  v_uid         uuid := auth.uid();
  v_is_admin    boolean := false;
  v_owner       uuid;
  v_question_id uuid;
  v_current     jsonb;
  v_merged      jsonb;
  v_norm        jsonb;
  v_new_qid     uuid;
  v_new_custom  jsonb;
  v_result      jsonb;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_patch IS NULL OR jsonb_typeof(p_patch) <> 'object' THEN
    RAISE EXCEPTION 'PATCH_MUST_BE_OBJECT';
  END IF;

  -- Tra owner + state hiện tại theo aq id (authz theo chủ assignment)
  SELECT a.teacher_id, aq.question_id, aq.custom_content
    INTO v_owner, v_question_id, v_current
  FROM public.assignment_questions aq
  JOIN public.assignments a ON a.id = aq.assignment_id
  WHERE aq.id = p_aq_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assignment question not found';
  END IF;

  -- Authz: chủ assignment hoặc admin
  SELECT EXISTS(SELECT 1 FROM public.profiles WHERE id = v_uid AND role = 'admin')
    INTO v_is_admin;
  IF NOT v_is_admin AND v_owner <> v_uid THEN
    RAISE EXCEPTION 'Forbidden: assignment not owned by teacher';
  END IF;

  -- Merge patch vào custom_content hiện tại (Delta Override).
  -- COALESCE(NULL, '{}') tránh `NULL || jsonb = NULL` (annihilation) cho câu S1.
  v_merged := COALESCE(v_current, '{}'::jsonb) || p_patch;

  -- Chuẩn hoá theo khế ước (global→diff/NULL, private→cắt link, inline→giữ full)
  v_norm := public.fn_normalize_aq_content(v_question_id, v_merged);
  v_new_qid    := nullif(v_norm->>'question_id', '')::uuid;
  v_new_custom := CASE WHEN v_norm->'custom_content' = 'null'::jsonb
                       THEN NULL ELSE v_norm->'custom_content' END;

  -- Alias bảng làm composite row: to_jsonb(aq) (KHÔNG dùng aq.* — `.*` bị
  -- expand thành column list, to_jsonb(col1,col2,...) không có hàm khớp,
  -- lỗi chỉ phát ở runtime khi gọi lần đầu).
  UPDATE public.assignment_questions AS aq
  SET question_id    = v_new_qid,
      custom_content = v_new_custom
  WHERE aq.id = p_aq_id
  RETURNING to_jsonb(aq) INTO v_result;

  RETURN v_result;
END;
$function$;

REVOKE ALL ON FUNCTION public.update_assignment_question_content(uuid, jsonb) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.update_assignment_question_content(uuid, jsonb) TO authenticated;

COMMIT;
