-- 037 — Phase 3 hardening (sau review 4-agent):
--  (E) recompute_submission_total trở thành CHOKEPOINT bên trong maybe_mark_session_graded
--      → chạy mỗi lần đánh giá session (edge sau mỗi score/feedback, Dart sau approve/override),
--      kể cả retry/rescan. Đóng lỗ idempotency: nếu recompute lẻ trong writeScore lỗi/crash,
--      lần maybe_mark kế tiếp vẫn cập nhật lại total_score (recompute deterministic = SUM).
--  (is_voided) recompute bỏ qua submission đã void — đồng nhất với batch_regrade_assignment.
-- PURELY ADDITIVE: CREATE OR REPLACE (giữ nguyên GRANT). Không đổi schema cột.

CREATE OR REPLACE FUNCTION public.recompute_submission_total(p_session_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  UPDATE public.submissions s
  SET total_score = COALESCE((
        SELECT SUM(sa.final_score)
        FROM   public.submission_answers sa
        WHERE  sa.session_id   = p_session_id
          AND  sa.final_score IS NOT NULL
      ), 0),
      updated_at = now()
  WHERE s.session_id = p_session_id
    AND NOT COALESCE(s.is_voided, false);
END;
$function$;

CREATE OR REPLACE FUNCTION public.maybe_mark_session_graded(p_session_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  v_pending  int;
  v_ungraded int;
  v_total    int;
BEGIN
  -- (E fix) recompute TẠI ĐÂY, TRƯỚC early-return → chạy cả khi còn item pending,
  -- và mọi đường (edge/Dart/retry/rescan) đều đi qua maybe_mark nên total_score luôn được sửa.
  PERFORM public.recompute_submission_total(p_session_id);

  -- Còn item score/feedback nào pending/processing cho các câu của session?
  SELECT count(*) INTO v_pending
  FROM   public.ai_queue q
  JOIN   public.submission_answers sa ON sa.id = q.submission_answer_id
  WHERE  sa.session_id = p_session_id
    AND  q.status IN ('pending', 'processing');

  IF v_pending > 0 THEN
    RETURN; -- AI còn đang xử lý → chưa kết luận
  END IF;

  SELECT count(*) FILTER (WHERE final_score IS NULL), count(*)
  INTO   v_ungraded, v_total
  FROM   public.submission_answers
  WHERE  session_id = p_session_id;

  IF v_total = 0 THEN
    RETURN;
  END IF;

  IF v_ungraded = 0 THEN
    UPDATE public.work_sessions
    SET    status = 'graded', updated_at = now()
    WHERE  id = p_session_id AND status IN ('ai_processing', 'pending_review');
  ELSE
    UPDATE public.work_sessions
    SET    status = 'pending_review', updated_at = now()
    WHERE  id = p_session_id AND status = 'ai_processing';
  END IF;
END;
$function$;
