-- 034_backfill_question_stats_avg_score.sql
-- ============================================================================
-- BUG #2 — question_stats.avg_score đổi ngữ nghĩa normalized→raw nhưng KHÔNG
-- backfill (latent data corruption).
--
-- BỐI CẢNH
--   - Migration 007 (cũ) lưu  avg_score = final_score / points  (chuẩn hoá 0–1).
--   - Migration 032 (fn_update_question_stats) đổi sang  avg_score = final_score
--     (điểm THÔ) và toán incremental/regrade coi giá trị lưu là trung bình THÔ:
--         avg_score = (avg_score * total_attempts + NEW.final_score)
--                     / (total_attempts + 1)
--     (xem ..._032_fix_analytics_triggers.sql, dòng 217-272).
--   - Hậu quả: các rows question_stats hiện có vẫn ở dạng NORMALIZED
--     (0.75, 0.6667…) trong khi points = 1.00/2.00. Khi 1 câu cũ nhận
--     attempt/regrade mới → công thức trên TRỘN 2 hệ đơn vị → avg_score sai
--     vĩnh viễn.
--
-- KHẢO SÁT DỮ LIỆU HIỆN TRẠNG (SELECT read-only, 2026-05-30)
--   - question_stats: 26 rows. 24 rows avg_score <= 1 (normalized), 2 rows = 2.5.
--   - 20/26 rows MAP được tới submission_answers đã chấm (qua
--       question_stats.question_id = assignment_questions.question_id,
--       assignment_questions.id = submission_answers.assignment_question_id,
--       submission_answers.final_score IS NOT NULL).
--   - 6/26 rows KHÔNG map được: có trong bảng `questions` (bank) NHƯNG KHÔNG có
--     trong `assignment_questions` → trigger fn_update_question_stats hiện KHÔNG
--     BAO GIỜ fire cho chúng (không có submission_answer nào trỏ tới). Đây là
--     seed/orphan thuần, KHÔNG có nguồn chân lý để recompute và KHÔNG có harm
--     forward → migration NÀY ĐỂ NGUYÊN 6 rows đó (xem "HẠN CHẾ" bên dưới).
--
-- VÌ SAO RECOMPUTE (phương án A) CHỨ KHÔNG NHÂN NGƯỢC (phương án B)
--   - Nguồn chân lý là submission_answers.final_score (điểm thô per attempt) —
--     chính là giá trị mà trigger 032 dùng. Recompute = AVG(final_score) trực
--     tiếp, chính xác tuyệt đối, không phụ thuộc points đồng nhất hay không.
--   - Nhân ngược (avg_score * points) kém chính xác và 6 orphan cũng không có
--     points để nhân (không có assignment_questions).
--
-- VÌ SAO RECOMPUTE CẢ 3 CỘT (total_attempts, correct_count, avg_score)
--   - Khảo sát cho thấy CẢ 20 rows mappable đều có count SEED GIẢ, lệch hẳn so
--     với submission_answers thực (vd total_attempts=77 nhưng chỉ 36 answer đã
--     chấm; =100 nhưng chỉ 54). Theo định nghĩa của 032 cả 3 cột đều là aggregate
--     trên submission_answers (total_attempts = số answer đã chấm; correct_count
--     = số answer final_score >= points; avg_score = mean(final_score)).
--   - Nếu CHỈ sửa avg_score mà giữ total_attempts giả → công thức incremental
--     của trigger ((avg*count + NEW)/(count+1)) vẫn dùng count giả → avg_score
--     SAI LẠI ngay attempt đầu tiên. Tức là chỉ-avg_score không fix được bug.
--     Recompute cả 3 khôi phục invariant avg_score*total_attempts = SUM(final),
--     đúng nền tảng cho mọi cập nhật incremental về sau.
--   - Recompute giữ nguyên CÂU CHUYỆN TỈ LỆ (difficulty %): seed được nhồi gần
--     đúng tỉ lệ (vd 74/100≈74% → 39/54≈72%), nên dashboard không méo về độ khó.
--
-- ĐIỀU KIỆN "CORRECT": dùng đúng định nghĩa 032 = (final_score >= points), và
--   so PER-ROW với aq.points của TỪNG assignment_question (một câu bank có thể
--   được phân phối với points khác nhau ở nhiều assignment) — KHÔNG collapse
--   points về một giá trị.
--
-- IDEMPOTENT: UPDATE…FROM theo join tới submission_answers. Recompute luôn cho
--   CÙNG kết quả bất kể chạy bao nhiêu lần (không dựa vào điều kiện đơn vị như
--   "avg_score <= 1"), và join tự động CHỈ chạm 20 rows mappable, để yên 6 orphan.
--
-- HẠN CHẾ / RỦI RO CÒN LẠI
--   - 6 rows orphan (có trong `questions` nhưng không trong `assignment_questions`)
--     KHÔNG được sửa: không có submission_answers để recompute. Trong số đó 2 rows
--     đã ở dạng raw (avg_score=2.5) và 4 rows còn normalized. Vì trigger không
--     fire cho chúng, đơn vị của chúng hiện vô hại. RỦI RO TƯƠNG LAI: nếu sau này
--     các câu này được phân phối lại (tạo assignment_questions + submission_answers
--     mới) thì 4 rows normalized sẽ lại trộn đơn vị. Nếu/khi điều đó xảy ra, cần
--     recompute lại bằng chính query trong file này (sẽ tự bao phủ vì lúc đó chúng
--     trở thành mappable).
--   - total_attempts/correct_count seed sẽ bị thay bằng giá trị THẬT (thấp hơn).
--     Đây là hành vi CÓ CHỦ ĐÍCH: khôi phục đúng định nghĩa hệ thống.
--
-- ⚠️ CHẠY MỘT LẦN, SAU KHI 032 ĐÃ APPLY. (An toàn nếu chạy lại — idempotent.)
-- ============================================================================

BEGIN;

WITH recompute AS (
  SELECT
    aq.question_id,
    count(sa.final_score)                                      AS n_graded,
    count(*) FILTER (WHERE sa.final_score >= aq.points)        AS n_correct,
    avg(sa.final_score)                                        AS raw_avg,
    max(sa.graded_at)                                          AS last_graded
  FROM public.submission_answers sa
  JOIN public.assignment_questions aq
    ON aq.id = sa.assignment_question_id
  WHERE aq.question_id IS NOT NULL
    AND sa.final_score IS NOT NULL
  GROUP BY aq.question_id
)
UPDATE public.question_stats qs
SET
  total_attempts = r.n_graded,
  correct_count  = r.n_correct,
  avg_score      = round(r.raw_avg, 4),
  last_attempted = COALESCE(r.last_graded, qs.last_attempted)
FROM recompute r
WHERE qs.question_id = r.question_id;

COMMIT;
