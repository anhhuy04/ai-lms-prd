-- ══════════════════════════════════════════════════════════════════════════════
-- Migration 22: Khoá redo sau hạn (bất kể allow_late)
--
-- Vấn đề trước đây:
--   start_redo_session chỉ chặn redo khi `past_due AND NOT allow_late`. Khi
--   GV bật allow_late, học sinh đã có ≥1 attempt vẫn redo được sau hạn —
--   trái với business rule mới.
--
-- Business rule (được clarify):
--   • allow_late = false + past_due → khoá tất cả (đã có UI ClosedBanner).
--   • allow_late = true  + past_due:
--       - HS chưa có session → vẫn cho start lần đầu (giữ nguyên).
--       - HS đã có ≥1 session → KHÔNG cho redo (mới).
--
-- Cách fix:
--   Bỏ điều kiện `AND NOT allow_late` trong nhánh past_due của
--   start_redo_session. allow_late chỉ phục vụ "lần đầu", không bắc cầu
--   sang redo. Nhánh start session lần đầu (không đi qua RPC này) vẫn
--   không đụng — UI client tự cho phép theo allow_late.
--
-- An toàn:
--   • Idempotent (CREATE OR REPLACE).
--   • Không thay đổi signature, không break call site.
--   • Không động đến bảng/RLS.
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

  -- ══════════════════════════════════════════════════════════════════════
  -- [CHANGED v22] Past-due luôn block redo (bất kể allow_late)
  --
  -- allow_late chỉ áp cho LẦN ĐẦU làm bài. RPC này chỉ chạy khi đã có ≥1
  -- attempt (xem v_current_max check bên dưới), nên ở đây cứ thấy quá hạn
  -- là chặn — không quan tâm allow_late.
  -- ══════════════════════════════════════════════════════════════════════
  IF v_due_at IS NOT NULL AND v_due_at < now() THEN
    RAISE EXCEPTION 'past_due'
      USING HINT = 'Cannot redo after due date';
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

  -- Validate: không có session nào đang dở dang
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

  -- Tạo variant immutable gắn session_id (mỗi attempt 1 variant riêng)
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
  WHEN unique_violation THEN
    RAISE EXCEPTION 'concurrent_redo_attempt'
      USING HINT = 'Another redo session was started concurrently. Please refresh and try again.';
  WHEN OTHERS THEN
    RAISE;
END;
$$;
