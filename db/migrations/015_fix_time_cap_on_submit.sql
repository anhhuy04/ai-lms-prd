-- Migration 015: Cap submitted_at tại thời điểm hết giờ
--
-- Edge case: Học sinh tắt máy lúc gần hết giờ, bật lại sau khi đã quá hạn.
-- Nếu không cap, submitted_at = lúc mở lại máy → sai (có thể +vài tiếng).
-- Đúng: submitted_at = started_at + time_limit_minutes (thời điểm timer chạy hết).
-- Kết quả: time_spent_seconds được giới hạn đúng, is_late so sánh với deadline chính xác.

CREATE OR REPLACE FUNCTION public.finalize_work_session(
  p_session_id       UUID,
  p_distribution_id  UUID,
  p_student_id       UUID,
  p_status           TEXT
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_uid                UUID := auth.uid();
  v_started_at         TIMESTAMPTZ;
  v_submitted_at       TIMESTAMPTZ;
  v_time_spent_secs    BIGINT;
  v_due_at             TIMESTAMPTZ;
  v_time_limit_minutes INT;
  v_exam_expires_at    TIMESTAMPTZ;
  v_is_late            BOOLEAN := false;
BEGIN
  -- [SECURITY] Chỉ chính học sinh đó mới được finalize session của mình
  IF v_uid != p_student_id THEN
    RAISE EXCEPTION 'Permission denied: can only finalize own session';
  END IF;

  -- Xác minh session tồn tại và thuộc về student này
  SELECT started_at INTO v_started_at
  FROM public.work_sessions
  WHERE id              = p_session_id
    AND student_id      = p_student_id
    AND assignment_distribution_id = p_distribution_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Session not found or not owned by student';
  END IF;

  -- Lấy due_at và time_limit từ distribution
  SELECT due_at, time_limit_minutes
  INTO v_due_at, v_time_limit_minutes
  FROM public.assignment_distributions
  WHERE id = p_distribution_id;

  -- [Đồng hồ Trọng tài — với Time Cap]
  -- Nếu có time_limit VÀ đã quá giờ → submitted_at = thời điểm HẾT GIỜ
  -- Lý do: học sinh tắt máy sau khi hết giờ không được "nộp muộn" so với deadline.
  --        time_spent_seconds cũng được giới hạn đúng tại time_limit_minutes * 60.
  IF v_time_limit_minutes IS NOT NULL AND v_started_at IS NOT NULL THEN
    v_exam_expires_at := v_started_at + (v_time_limit_minutes || ' minutes')::INTERVAL;
    v_submitted_at := LEAST(now(), v_exam_expires_at);
  ELSE
    v_submitted_at := now();
  END IF;

  -- Tính thời gian làm bài = submitted_at − started_at
  v_time_spent_secs := GREATEST(
    0,
    EXTRACT(EPOCH FROM (v_submitted_at - COALESCE(v_started_at, v_submitted_at)))::BIGINT
  );

  -- Kiểm tra nộp muộn dựa trên submitted_at đã được cap
  IF v_due_at IS NOT NULL THEN
    v_is_late := v_submitted_at > v_due_at;
  END IF;

  -- Atomic UPDATE với server timestamps
  UPDATE public.work_sessions
  SET
    status             = p_status,
    submitted_at       = v_submitted_at,
    time_spent_seconds = v_time_spent_secs,
    updated_at         = now()
  WHERE id         = p_session_id
    AND student_id = p_student_id;

  RETURN jsonb_build_object(
    'submitted_at',       v_submitted_at,
    'time_spent_seconds', v_time_spent_secs,
    'is_late',            v_is_late
  );
END;
$$;
