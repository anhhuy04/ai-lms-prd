-- ============================================================
-- PHASE 5: Fill remaining critical tables
-- Tables: learning_objectives, question_objectives,
--         student_skill_mastery, submission_analytics,
--         ai_evaluations, grade_overrides
-- ============================================================
BEGIN;

-- ═══ 1. LEARNING_OBJECTIVES ═══
-- Mục tiêu học tập cho MMT và SQL Server
INSERT INTO public.learning_objectives (id, subject_code, code, description, difficulty, parent_id, metadata, created_at) VALUES
-- === MMT Root ===
('b0000001-0001-0000-0000-000000000001', 'MMT', 'MMT.ROOT', 'Kiến thức tổng quan Mạng máy tính', NULL, NULL, '{"level": "root"}', '2026-01-01T00:00:00+07:00'),
-- MMT Children
('b0000001-0001-0001-0000-000000000001', 'MMT', 'MMT.1', 'Hiểu mô hình OSI và các tầng mạng', 2, 'b0000001-0001-0000-0000-000000000001', '{"chapter": 1}', '2026-01-01T00:00:00+07:00'),
('b0000001-0001-0002-0000-000000000001', 'MMT', 'MMT.2', 'Hiểu và phân biệt giao thức TCP, UDP', 2, 'b0000001-0001-0000-0000-000000000001', '{"chapter": 1}', '2026-01-01T00:00:00+07:00'),
('b0000001-0001-0003-0000-000000000001', 'MMT', 'MMT.3', 'Tính toán địa chỉ IP và Subnet Mask', 3, 'b0000001-0001-0000-0000-000000000001', '{"chapter": 2}', '2026-01-01T00:00:00+07:00'),
('b0000001-0001-0004-0000-000000000001', 'MMT', 'MMT.4', 'Phân biệt các thiết bị mạng (Hub, Switch, Router)', 2, 'b0000001-0001-0000-0000-000000000001', '{"chapter": 3}', '2026-01-01T00:00:00+07:00'),
('b0000001-0001-0005-0000-000000000001', 'MMT', 'MMT.5', 'Hiểu các dịch vụ mạng (DHCP, DNS, SMTP)', 2, 'b0000001-0001-0000-0000-000000000001', '{"chapter": 4}', '2026-01-01T00:00:00+07:00'),
('b0000001-0001-0006-0000-000000000001', 'MMT', 'MMT.6', 'Cấu hình và quản lý VLAN', 3, 'b0000001-0001-0000-0000-000000000001', '{"chapter": 5}', '2026-01-01T00:00:00+07:00'),
-- === SQL Root ===
('b0000002-0001-0000-0000-000000000001', 'SQL', 'SQL.ROOT', 'Kiến thức tổng quan Hệ quản trị CSDL SQL Server', NULL, NULL, '{"level": "root"}', '2026-01-01T00:00:00+07:00'),
-- SQL Children
('b0000002-0001-0001-0000-000000000001', 'SQL', 'SQL.1', 'Sử dụng câu lệnh DDL (CREATE, ALTER, DROP)', 2, 'b0000002-0001-0000-0000-000000000001', '{"chapter": 1}', '2026-01-01T00:00:00+07:00'),
('b0000002-0001-0002-0000-000000000001', 'SQL', 'SQL.2', 'Áp dụng ràng buộc toàn vẹn dữ liệu (UNIQUE, CHECK, FK)', 2, 'b0000002-0001-0000-0000-000000000001', '{"chapter": 2}', '2026-01-01T00:00:00+07:00'),
('b0000002-0001-0003-0000-000000000001', 'SQL', 'SQL.3', 'Viết truy vấn JOIN và hàm Aggregate', 3, 'b0000002-0001-0000-0000-000000000001', '{"chapter": 3}', '2026-01-01T00:00:00+07:00'),
('b0000002-0001-0004-0000-000000000001', 'SQL', 'SQL.4', 'Sử dụng Stored Procedure và Trigger', 3, 'b0000002-0001-0000-0000-000000000001', '{"chapter": 4}', '2026-01-01T00:00:00+07:00'),
('b0000002-0001-0005-0000-000000000001', 'SQL', 'SQL.5', 'Hiểu INDEX, Transaction và ACID', 3, 'b0000002-0001-0000-0000-000000000001', '{"chapter": 5}', '2026-01-01T00:00:00+07:00')
ON CONFLICT DO NOTHING;

-- ═══ 2. QUESTION_OBJECTIVES ═══
-- Link seed questions → learning objectives
-- MMT questions: Sử dụng deterministic UUID từ generate_full_seed.py
-- question_ids from uuid5(NAMESPACE_DNS, "seed.question.mmt.{i}") and "seed.question.sql.{i}"
-- Mapping: q0,q1 → MMT.1 | q2 → MMT.2 | q3,q4 → MMT.3 | q5 → MMT.4 | q6,q7 → MMT.5 | q8 → MMT.6 | q9 → MMT.5
INSERT INTO public.question_objectives (question_id, objective_id)
SELECT q.id, obj.id
FROM public.questions q
CROSS JOIN LATERAL (
    SELECT CASE
        -- MMT questions by content matching
        WHEN q.content->>'text' LIKE '%OSI%tầng%' THEN 'b0000001-0001-0001-0000-000000000001'
        WHEN q.content->>'text' LIKE '%tầng%định tuyến%' THEN 'b0000001-0001-0001-0000-000000000001'
        WHEN q.content->>'text' LIKE '%Transport%TCP%' THEN 'b0000001-0001-0002-0000-000000000001'
        WHEN q.content->>'text' LIKE '%IPv4%' THEN 'b0000001-0001-0003-0000-000000000001'
        WHEN q.content->>'text' LIKE '%Subnet%' THEN 'b0000001-0001-0003-0000-000000000001'
        WHEN q.content->>'text' LIKE '%Data Link%' OR q.content->>'text' LIKE '%Switch%' THEN 'b0000001-0001-0004-0000-000000000001'
        WHEN q.content->>'text' LIKE '%DHCP%' THEN 'b0000001-0001-0005-0000-000000000001'
        WHEN q.content->>'text' LIKE '%DNS%' THEN 'b0000001-0001-0005-0000-000000000001'
        WHEN q.content->>'text' LIKE '%SMTP%' OR q.content->>'text' LIKE '%email%' THEN 'b0000001-0001-0005-0000-000000000001'
        WHEN q.content->>'text' LIKE '%VLAN%' THEN 'b0000001-0001-0006-0000-000000000001'
        -- SQL questions by content matching
        WHEN q.content->>'text' LIKE '%CREATE TABLE%' OR q.content->>'text' LIKE '%tạo bảng%' THEN 'b0000002-0001-0001-0000-000000000001'
        WHEN q.content->>'text' LIKE '%DROP TABLE%' OR q.content->>'text' LIKE '%xóa bảng%' THEN 'b0000002-0001-0001-0000-000000000001'
        WHEN q.content->>'text' LIKE '%UNIQUE%' OR q.content->>'text' LIKE '%ràng buộc%' THEN 'b0000002-0001-0002-0000-000000000001'
        WHEN q.content->>'text' LIKE '%JOIN%' THEN 'b0000002-0001-0003-0000-000000000001'
        WHEN q.content->>'text' LIKE '%COUNT%' OR q.content->>'text' LIKE '%ORDER BY%' THEN 'b0000002-0001-0003-0000-000000000001'
        WHEN q.content->>'text' LIKE '%Stored Procedure%' THEN 'b0000002-0001-0004-0000-000000000001'
        WHEN q.content->>'text' LIKE '%Trigger%' THEN 'b0000002-0001-0004-0000-000000000001'
        WHEN q.content->>'text' LIKE '%INDEX%' THEN 'b0000002-0001-0005-0000-000000000001'
        WHEN q.content->>'text' LIKE '%Transaction%' OR q.content->>'text' LIKE '%ACID%' THEN 'b0000002-0001-0005-0000-000000000001'
        ELSE NULL
    END AS obj_id
) matched_obj
JOIN public.learning_objectives obj ON obj.id = matched_obj.obj_id::uuid
WHERE q.tags IS NOT NULL
  AND (q.tags && ARRAY['mạng', 'SQL']::text[])
ON CONFLICT DO NOTHING;

-- ═══ 3. STUDENT_SKILL_MASTERY ═══
-- Tính toán mastery level từ submission_answers thực tế
-- Chỉ cho SV có nộp bài  AND  câu hỏi có link objectives
INSERT INTO public.student_skill_mastery (student_id, objective_id, mastery_level, attempts, correct, last_updated)
SELECT
    ws.student_id,
    qo.objective_id,
    ROUND(
        CASE WHEN COUNT(*) > 0
            THEN COUNT(*) FILTER (WHERE sa.final_score > 0)::numeric / COUNT(*)::numeric
            ELSE 0
        END, 2
    ) AS mastery_level,
    COUNT(*)::int AS attempts,
    COUNT(*) FILTER (WHERE sa.final_score > 0)::int AS correct,
    MAX(sa.created_at) AS last_updated
FROM public.submission_answers sa
JOIN public.work_sessions ws ON ws.id = sa.session_id
JOIN public.assignment_questions aq ON aq.id = sa.assignment_question_id
JOIN public.question_objectives qo ON qo.question_id = aq.question_id
GROUP BY ws.student_id, qo.objective_id
ON CONFLICT (student_id, objective_id) DO UPDATE SET
    mastery_level = EXCLUDED.mastery_level,
    attempts = EXCLUDED.attempts,
    correct = EXCLUDED.correct,
    last_updated = EXCLUDED.last_updated;

-- ═══ 4. SUBMISSION_ANALYTICS ═══
-- Generate metrics cho mỗi submission
INSERT INTO public.submission_analytics (id, submission_id, metrics, created_at)
SELECT
    gen_random_uuid(),
    s.id,
    jsonb_build_object(
        'total_questions', (SELECT COUNT(*) FROM public.submission_answers sa2 WHERE sa2.session_id = s.session_id),
        'correct_count', (SELECT COUNT(*) FROM public.submission_answers sa2 WHERE sa2.session_id = s.session_id AND sa2.final_score > 0),
        'avg_time_per_question_seconds', 
            CASE WHEN ws.time_spent_seconds > 0 
                THEN ROUND(ws.time_spent_seconds::numeric / GREATEST((SELECT COUNT(*) FROM public.submission_answers sa2 WHERE sa2.session_id = s.session_id), 1), 0)
                ELSE 0 
            END,
        'total_time_seconds', ws.time_spent_seconds,
        'score_percentage', 
            CASE WHEN a.total_points > 0 
                THEN ROUND((s.total_score / a.total_points * 100)::numeric, 1)
                ELSE 0 
            END,
        'submission_rank', 'pending',
        'difficulty_breakdown', jsonb_build_object(
            'easy', (SELECT COUNT(*) FROM public.submission_answers sa3 
                     JOIN public.assignment_questions aq3 ON aq3.id = sa3.assignment_question_id
                     JOIN public.questions q3 ON q3.id = aq3.question_id
                     WHERE sa3.session_id = s.session_id AND q3.difficulty <= 2),
            'medium', (SELECT COUNT(*) FROM public.submission_answers sa3 
                       JOIN public.assignment_questions aq3 ON aq3.id = sa3.assignment_question_id
                       JOIN public.questions q3 ON q3.id = aq3.question_id
                       WHERE sa3.session_id = s.session_id AND q3.difficulty = 3),
            'hard', (SELECT COUNT(*) FROM public.submission_answers sa3 
                     JOIN public.assignment_questions aq3 ON aq3.id = sa3.assignment_question_id
                     JOIN public.questions q3 ON q3.id = aq3.question_id
                     WHERE sa3.session_id = s.session_id AND q3.difficulty >= 4)
        )
    ),
    s.submitted_at
FROM public.submissions s
JOIN public.work_sessions ws ON ws.id = s.session_id
JOIN public.assignments a ON a.id = s.assignment_id
WHERE s.session_id IS NOT NULL
ON CONFLICT DO NOTHING;

-- ═══ 5. AI_EVALUATIONS ═══
-- Lịch sử AI chấm cho mỗi submission_answer đã có ai_score
INSERT INTO public.ai_evaluations (id, submission_answer_id, model_name, model_version, ai_score, ai_confidence, feedback, rationale, created_at)
SELECT
    gen_random_uuid(),
    sa.id,
    'gemini-2.0-flash',
    'v2.0',
    sa.ai_score,
    sa.ai_confidence,
    CASE 
        WHEN sa.final_score > 0 THEN 'Đáp án chính xác.'
        ELSE 'Đáp án chưa chính xác. Xem lại lý thuyết liên quan.'
    END,
    jsonb_build_object(
        'criteria_scores', jsonb_build_array(
            jsonb_build_object(
                'criteria_id', 'auto-check',
                'score', sa.ai_score,
                'comment', CASE 
                    WHEN sa.final_score > 0 THEN 'Sinh viên chọn đúng đáp án.'
                    ELSE 'Sinh viên chọn sai đáp án. Cần ôn lại kiến thức.'
                END
            )
        ),
        'overall_comment', CASE 
            WHEN sa.final_score > 0 THEN 'Câu trả lời đạt yêu cầu.'
            ELSE 'Câu trả lời chưa đạt. Nên xem lại bài giảng.'
        END
    ),
    sa.created_at + interval '5 seconds'
FROM public.submission_answers sa
WHERE sa.ai_score IS NOT NULL
ON CONFLICT DO NOTHING;

-- ═══ 6. GRADE_OVERRIDES ═══
-- GV chỉnh điểm cho 1 số bài (audit trail)
-- Chọn 10 submission_answers ngẫu nhiên có final_score = 0 (sai) và GV cho thêm điểm
INSERT INTO public.grade_overrides (id, submission_answer_id, overridden_by, old_score, new_score, reason, created_at)
SELECT
    gen_random_uuid(),
    sa.id,
    (SELECT c.teacher_id FROM public.classes c 
     JOIN public.assignments a2 ON a2.class_id = c.id
     JOIN public.assignment_questions aq2 ON aq2.assignment_id = a2.id
     WHERE aq2.id = sa.assignment_question_id LIMIT 1),
    sa.final_score,
    (sa.final_score + 0.5),
    CASE (random() * 3)::int
        WHEN 0 THEN 'Sinh viên có giải thích thêm hợp lý khi gặp trực tiếp'
        WHEN 1 THEN 'Cho điểm cộng do tham gia tích cực trên lớp'
        WHEN 2 THEN 'Câu hỏi có 2 đáp án có thể chấp nhận được'
        ELSE 'Chỉnh điểm sau khi review lại rubric'
    END,
    sa.created_at + interval '3 days'
FROM public.submission_answers sa
WHERE sa.final_score = 0
ORDER BY random()
LIMIT 10;

-- Cập nhật final_score cho các bài đã override
UPDATE public.submission_answers sa
SET final_score = go.new_score, updated_at = go.created_at
FROM public.grade_overrides go
WHERE go.submission_answer_id = sa.id;

COMMIT;

-- ═══ VERIFY ═══
SELECT relname AS table_name, n_live_tup AS row_count
FROM pg_stat_user_tables
WHERE schemaname='public'
ORDER BY relname;
