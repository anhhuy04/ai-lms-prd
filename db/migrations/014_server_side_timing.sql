-- Migration 014: Server-Side Timing — "Chiếc đồng hồ Trọng tài"
--
-- Lỗ hổng bảo mật:
--   1. started_at = NULL (chưa bao giờ được set khi tạo session)
--   2. submitted_at = Flutter DateTime.now() → học sinh giả mạo đồng hồ máy
--   3. time_spent_seconds = 0 mãi mãi (UPDATE bị bỏ quên)
--   4. is_late = client-side comparison → có thể giả mạo
--
-- Fix: mọi timestamp đều từ PostgreSQL now(), không bao giờ tin client

-- ── Bước 1: started_at DEFAULT now() ─────────────────────────────────────
ALTER TABLE public.work_sessions
  ALTER COLUMN started_at SET DEFAULT now();

-- ── Bước 2: Backfill các session đang NULL (created_at là xấp xỉ tốt nhất) ─
UPDATE public.work_sessions
SET started_at = created_at
WHERE started_at IS NULL;

-- ── Bước 3: RPC finalize_work_session ────────────────────────────────────
-- Input : p_session_id, p_distribution_id, p_student_id, p_status
-- Output: { submitted_at, time_spent_seconds, is_late }
-- KHÔNG nhận bất kỳ tham số thời gian nào từ client
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
  v_uid              UUID := auth.uid();
  v_started_at       TIMESTAMPTZ;
  v_submitted_at     TIMESTAMPTZ;
  v_time_spent_secs  BIGINT;
  v_due_at           TIMESTAMPTZ;
  v_is_late          BOOLEAN := false;
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

  -- [Đồng hồ Trọng tài] Chốt thời điểm nộp bài tại PostgreSQL server
  v_submitted_at := now();

  -- Tính thời gian làm bài = submitted_at − started_at (đều là server timestamps)
  -- GREATEST(0) đề phòng precision nhỏ hoặc clock skew
  v_time_spent_secs := GREATEST(
    0,
    EXTRACT(EPOCH FROM (v_submitted_at - COALESCE(v_started_at, v_submitted_at)))::BIGINT
  );

  -- Kiểm tra nộp muộn hoàn toàn server-side
  SELECT due_at INTO v_due_at
  FROM public.assignment_distributions
  WHERE id = p_distribution_id;

  IF v_due_at IS NOT NULL THEN
    v_is_late := v_submitted_at > v_due_at;
  END IF;

  -- Atomic UPDATE với server timestamps — không nhận giờ từ client
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

GRANT EXECUTE ON FUNCTION public.finalize_work_session(UUID, UUID, UUID, TEXT) TO authenticated;
