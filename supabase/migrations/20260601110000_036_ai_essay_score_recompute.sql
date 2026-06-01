-- 036 — AI chấm điểm tự luận (Phase 3): recompute tổng điểm + backfill hàng đợi
-- Phụ trợ cho edge function process-ai-queue handleScore.
-- Phạm vi: PURELY ADDITIVE — chỉ thêm 1 function mới + backfill các dòng score deferred.
-- KHÔNG đụng schema cột, KHÔNG đổi trigger/RPC đang chạy ổn định.

-- ─────────────────────────────────────────────────────────────────────────────
-- recompute_submission_total: đặt submissions.total_score = SUM(final_score) của session
-- ─────────────────────────────────────────────────────────────────────────────
-- Vá lỗ hổng pre-existing: trước đây total_score chỉ = điểm trắc nghiệm lúc nộp,
-- không bao giờ cộng điểm tự luận sau khi chấm → sổ điểm thiếu điểm essay.
-- Gọi từ: edge auto-publish + approveAiScore + overrideScore + per-answer grade.
-- Dùng SQL fn dùng chung (KHÔNG trigger) để tránh fire trên luồng MCQ/batch_regrade đã test.
-- SUM chỉ tính các câu đã có final_score (câu chờ duyệt = NULL bị loại tới khi được chấm).
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
  WHERE s.session_id = p_session_id;
END;
$function$;

GRANT EXECUTE ON FUNCTION public.recompute_submission_total(uuid) TO authenticated, service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- maybe_mark_session_graded: phép AND — nguồn chân lý DUY NHẤT cho cú chuyển status.
-- Dùng chung bởi edge function (sau khi AI chấm) VÀ Dart (sau khi GV duyệt/sửa điểm).
--   graded        ⇔ không còn ai_queue score/feedback pending/processing VÀ mọi câu có final_score
--   pending_review ⇔ queue đã cạn nhưng còn câu tự luận chờ GV duyệt (final_score NULL)
-- Chỉ NÂNG cấp trạng thái (ai_processing→pending_review→graded), không hạ cấp.
-- Logic tương đương bản TS cũ nhưng tập trung 1 nơi để không lệch giữa 2 đường gọi.
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
  -- Còn item score/feedback nào pending/processing cho các câu của session?
  -- (analysis có submission_answer_id NULL nên không lọt vào — best-effort, không chặn graded)
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

GRANT EXECUTE ON FUNCTION public.maybe_mark_session_graded(uuid) TO authenticated, service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- Backfill: mở lại các item score đang deferred (STUB cũ) để webhook/scan nhặt lại.
-- Hiện tại 0 dòng score → no-op an toàn; giữ để idempotent khi tái chạy.
-- ─────────────────────────────────────────────────────────────────────────────
UPDATE public.ai_queue
SET    status = 'pending', updated_at = now()
WHERE  request_type = 'score' AND status = 'deferred';
