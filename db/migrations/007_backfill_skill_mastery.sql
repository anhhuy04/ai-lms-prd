-- ==============================================================================
-- AI LMS - Migration 007: Backfill student_skill_mastery từ dữ liệu cũ
-- Purpose: Tính lại toàn bộ mastery từ submission_answers đã có sẵn
--          (trigger chỉ chạy với INSERT mới — dữ liệu cũ chưa được tính)
-- Run:     Chạy 1 lần. Idempotent — có thể chạy lại mà không bị lỗi.
-- Scope:   Mặc định ALL students. Uncomment WHERE clause để filter 1 HS.
-- ==============================================================================

WITH mastery_calc AS (
  SELECT
    ws.student_id,
    qo.objective_id,
    COUNT(*) FILTER (WHERE sa.final_score IS NOT NULL)       AS attempts,
    COUNT(*) FILTER (WHERE sa.final_score = aq.points)       AS correct
  FROM submission_answers sa
  JOIN work_sessions          ws  ON ws.id  = sa.session_id
  JOIN assignment_questions   aq  ON aq.id  = sa.assignment_question_id
  JOIN question_objectives    qo  ON qo.question_id = aq.question_id
  WHERE sa.final_score IS NOT NULL   -- D-06: bỏ qua essay chưa chấm
    AND aq.question_id IS NOT NULL   -- D-07: bỏ qua custom questions
    -- Uncomment dòng dưới để chỉ backfill cho 1 học sinh cụ thể:
    -- AND ws.student_id = '<student-uuid-hs1>'
  GROUP BY ws.student_id, qo.objective_id
)
INSERT INTO student_skill_mastery
  (student_id, objective_id, attempts, correct, mastery_level, last_updated)
SELECT
  student_id,
  objective_id,
  attempts,
  correct,
  CASE WHEN attempts > 0
       THEN correct::numeric / attempts
       ELSE 0.0
  END AS mastery_level,
  now() AS last_updated
FROM mastery_calc
WHERE attempts > 0   -- bỏ qua row không có attempt hợp lệ
ON CONFLICT (student_id, objective_id)
DO UPDATE SET
  attempts      = EXCLUDED.attempts,
  correct       = EXCLUDED.correct,
  mastery_level = EXCLUDED.mastery_level,
  last_updated  = EXCLUDED.last_updated;

-- Kiểm tra kết quả sau khi chạy:
-- SELECT student_id, COUNT(*) as objectives, AVG(mastery_level) as avg_mastery
-- FROM student_skill_mastery
-- GROUP BY student_id
-- ORDER BY avg_mastery DESC;
