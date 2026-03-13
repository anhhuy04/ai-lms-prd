-- ==============================================================================
-- AI LMS - SCHEMA PHASE 3: SUBMISSIONS, AI GRADING & ANALYTICS
-- Cập nhật: 2026-03-12 (đồng bộ từ Supabase production)
-- ==============================================================================

-- ═══ 1. WORK_SESSIONS ═══
-- Phiên làm bài của học sinh (tracking từ lúc mở đề đến khi nộp)
-- Unique constraint: 1 HS chỉ có 1 session/attempt cho mỗi distribution
CREATE TABLE IF NOT EXISTS public.work_sessions (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_distribution_id uuid REFERENCES public.assignment_distributions(id), -- Đợt phát hành nào
  assignment_id             uuid REFERENCES public.assignments(id),               -- Bài tập nào
  student_id                uuid NOT NULL REFERENCES public.profiles(id),         -- Học sinh nào
  started_at                timestamptz,                                           -- Thời điểm bắt đầu làm
  submitted_at              timestamptz,                                           -- Thời điểm nộp bài
  attempt                   integer DEFAULT 1,                                     -- Lần thứ mấy
  status                    text DEFAULT 'in_progress'                             -- Trạng thái phiên
                            CHECK (status IN ('in_progress', 'submitted', 'graded')),
  time_spent_seconds        bigint DEFAULT 0,                                      -- Tổng thời gian làm bài (giây)
  created_at                timestamptz DEFAULT now(),
  updated_at                timestamptz DEFAULT now()
  -- UNIQUE(assignment_distribution_id, student_id, attempt) -- đảm bảo unique
);


-- ═══ 2. AUTOSAVE_ANSWERS ═══
-- Lưu tự động câu trả lời (draft) khi HS đang làm bài
-- UNIQUE(session_id, assignment_question_id) — chỉ 1 draft/câu/session
CREATE TABLE IF NOT EXISTS public.autosave_answers (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id              uuid REFERENCES public.work_sessions(id),               -- Phiên làm bài
  assignment_question_id  uuid REFERENCES public.assignment_questions(id),         -- Câu hỏi nào
  answer_content          jsonb,                                                   -- Nội dung draft (xem mẫu JSONB)
  updated_at              timestamptz DEFAULT now()
);
-- JSONB: autosave_answers.answer_content
-- Mẫu MỚI (Trắc nghiệm):
-- { "selected_choice_ids": [0, 2] }
-- Mẫu CŨ (Legacy):
-- { "selected_choices": [0] }
-- Mẫu (Tự luận):
-- { "text": "Bài làm tự luận..." }


-- ═══ 3. SUBMISSIONS ═══
-- Bài nộp chính thức (sau khi HS bấm "Nộp bài")
CREATE TABLE IF NOT EXISTS public.submissions (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id             uuid REFERENCES public.assignments(id),               -- Bài tập nào
  assignment_distribution_id uuid REFERENCES public.assignment_distributions(id), -- Đợt phát hành nào
  student_id                uuid NOT NULL REFERENCES public.profiles(id),         -- Học sinh nào
  session_id                uuid REFERENCES public.work_sessions(id),             -- Phiên làm bài
  variant_id                uuid REFERENCES public.assignment_variants(id),       -- Biến thể đề (nếu có shuffle)
  started_at                timestamptz,                                           -- Bắt đầu lúc nào
  submitted_at              timestamptz,                                           -- Nộp lúc nào
  is_late                   boolean DEFAULT false,                                 -- Nộp trễ? (tính từ due_at của distribution)
  total_score               numeric,                                               -- Tổng điểm (sau chấm)
  ai_graded                 boolean DEFAULT false,                                 -- AI đã chấm chưa
  is_voided                 boolean DEFAULT false,                                 -- Bài bị hủy (gian lận, v.v.)
  created_at                timestamptz DEFAULT now(),
  updated_at                timestamptz DEFAULT now()
);


-- ═══ 4. SUBMISSION_ANSWERS ═══
-- Câu trả lời chính thức cho từng câu hỏi (sau submit)
CREATE TABLE IF NOT EXISTS public.submission_answers (
  id                      uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id              uuid REFERENCES public.work_sessions(id),               -- Phiên làm bài
  assignment_question_id  uuid NOT NULL REFERENCES public.assignment_questions(id),-- Câu hỏi nào
  answer                  jsonb NOT NULL,                                          -- Câu trả lời (xem mẫu JSONB)
  files                   jsonb,                                                   -- Files đính kèm
  flagged                 boolean DEFAULT false,                                   -- GV đánh dấu cần review
  ai_score                numeric,                                                 -- Điểm AI chấm
  ai_confidence           numeric,                                                 -- Độ tin cậy AI (0.0 - 1.0)
  final_score             numeric,                                                 -- Điểm cuối cùng (GV override hoặc AI)
  ai_feedback             jsonb,                                                   -- Phản hồi từ AI
  teacher_feedback        jsonb,                                                   -- Phản hồi từ GV
  graded_by               uuid REFERENCES auth.users(id),                          -- Ai chấm (null = AI)
  graded_at               timestamptz,                                             -- Chấm lúc nào
  created_at              timestamptz DEFAULT now(),
  updated_at              timestamptz DEFAULT now()
);
-- JSONB: submission_answers.answer
-- ⚠️ TỬ HUYỆT 5: Cấu trúc câu trả lời của học sinh
-- Mẫu MỚI (Trắc nghiệm):
-- { "selected_choice_ids": [0] }
-- Mẫu CŨ (Legacy):
-- { "selected_choices": [0] }
--
-- Mẫu MỚI (Tự luận):
-- { "text": "Bài làm...", "attachments": ["url1"] }
-- Mẫu CŨ (Legacy):
-- { "text": "Bài làm..." }
--
-- JSONB: submission_answers.ai_feedback
-- Mẫu dự kiến:
-- {
--   "comment": "Bài làm tốt, tuy nhiên thiếu phần giải thích",
--   "strengths": ["Hiểu đề bài", "Trình bày rõ ràng"],
--   "weaknesses": ["Thiếu giải thích chi tiết"],
--   "suggestions": ["Nên thêm các bước giải thích trung gian"]
-- }
--
-- JSONB: submission_answers.teacher_feedback
-- Mẫu dự kiến:
-- {
--   "comment": "Cần cải thiện phần trình bày",
--   "rating": 3
-- }
--
-- JSONB: submission_answers.files
-- Mẫu dự kiến:
-- [
--   { "file_id": "uuid", "name": "bai_lam.pdf", "url": "https://..." }
-- ]


-- ═══ 5. FILES ═══
-- Quản lý file upload (link tới Supabase Storage)
CREATE TABLE IF NOT EXISTS public.files (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  storage_path  text NOT NULL,                               -- Path trong Supabase Storage bucket
  url           text,                                         -- Public URL (nếu có)
  filename      text,                                         -- Tên file gốc
  mime_type     text,                                         -- MIME type (vd: "application/pdf")
  size_bytes    bigint,                                       -- Kích thước file (bytes)
  uploaded_by   uuid REFERENCES auth.users(id),               -- Ai upload
  metadata      jsonb,                                        -- Metadata file
  is_deleted    boolean DEFAULT false,                        -- Soft delete
  created_at    timestamptz DEFAULT now()
);
-- JSONB: files.metadata → Chưa có dữ liệu mẫu


-- ═══ 6. FILE_LINKS ═══
-- Liên kết polymorphic: file ↔ bất kỳ entity nào (assignment, submission, ...)
CREATE TABLE IF NOT EXISTS public.file_links (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id     uuid REFERENCES public.files(id),              -- File nào
  target_type text NOT NULL,                                  -- Loại entity: 'assignment' | 'submission' | 'question' ...
  target_id   uuid NOT NULL,                                  -- ID của entity
  created_at  timestamptz DEFAULT now()
);


-- ═══ 7. AI_QUEUE ═══
-- Hàng đợi chấm bài AI (async processing)
CREATE TABLE IF NOT EXISTS public.ai_queue (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_answer_id  uuid REFERENCES public.submission_answers(id),  -- Câu trả lời cần chấm
  request_type          text DEFAULT 'score'                            -- Loại yêu cầu
                        CHECK (request_type IN ('score', 'feedback', 'analysis')),
  status                text DEFAULT 'pending',                         -- 'pending' | 'processing' | 'completed' | 'failed'
  attempts              integer DEFAULT 0,                              -- Số lần thử
  payload               jsonb,                                          -- Dữ liệu gửi lên AI
  result                jsonb,                                          -- Kết quả từ AI
  created_at            timestamptz DEFAULT now(),
  updated_at            timestamptz DEFAULT now()
);
-- JSONB: ai_queue.payload
-- Mẫu dự kiến:
-- {
--   "question_text": "...",
--   "answer_text": "...",
--   "rubric": {...},
--   "max_points": 5
-- }


-- ═══ 8. AI_EVALUATIONS ═══
-- Kết quả đánh giá AI (lưu trữ lịch sử, có thể nhiều lần/câu)
CREATE TABLE IF NOT EXISTS public.ai_evaluations (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_answer_id  uuid REFERENCES public.submission_answers(id),
  model_name            text,                                           -- Tên model AI (vd: "gpt-4", "gemini-pro")
  model_version         text,                                           -- Phiên bản model
  ai_score              numeric,                                        -- Điểm AI chấm
  ai_confidence         numeric,                                        -- Độ tin cậy (0.0 - 1.0)
  feedback              text,                                           -- Nhận xét text
  rationale             jsonb,                                          -- Giải thích chi tiết lý do chấm
  created_at            timestamptz DEFAULT now()
);
-- JSONB: ai_evaluations.rationale
-- ⚠️ TỬ HUYỆT 5: Kết quả chấm AI phải map đúng với Rubric Matrix
-- Mẫu ĐẦY ĐỦ:
-- {
--   "criteria_scores": [
--     { "criteria_id": "crit-1", "score": 3, "comment": "..." }
--   ],
--   "overall_comment": "Bài làm đạt yêu cầu..."
-- }
-- Mẫu CŨ (Legacy):
-- {
--   "criteria_scores": [
--     { "criteria": "Hiểu đề", "score": 3, "max": 5, "comment": "..." }
--   ],
--   "overall_comment": "Bài làm đạt yêu cầu..."
-- }


-- ═══ 9. GRADE_OVERRIDES ═══
-- Audit trail: GV chỉnh sửa điểm (ghi lại lịch sử thay đổi)
CREATE TABLE IF NOT EXISTS public.grade_overrides (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_answer_id  uuid NOT NULL REFERENCES public.submission_answers(id),
  overridden_by         uuid NOT NULL REFERENCES auth.users(id),      -- GV nào chỉnh
  old_score             numeric,                                       -- Điểm cũ
  new_score             numeric NOT NULL,                              -- Điểm mới
  reason                text,                                          -- Lý do chỉnh
  created_at            timestamptz NOT NULL DEFAULT now()
);


-- ═══ 10. STUDENT_SKILL_MASTERY ═══
-- Trình độ kỹ năng của HS theo từng mục tiêu học tập (AI tính toán)
CREATE TABLE IF NOT EXISTS public.student_skill_mastery (
  student_id    uuid NOT NULL REFERENCES auth.users(id),
  objective_id  uuid NOT NULL REFERENCES public.learning_objectives(id),
  mastery_level numeric DEFAULT 0.0                                  -- Mức thành thạo (0.0 - 1.0)
                CHECK (mastery_level >= 0 AND mastery_level <= 1),
  attempts      integer DEFAULT 0,                                    -- Tổng số lần thử
  correct       integer DEFAULT 0,                                    -- Số lần đúng
  last_updated  timestamptz DEFAULT now(),
  PRIMARY KEY (student_id, objective_id)
);


-- ═══ 11. QUESTION_STATS ═══
-- Thống kê câu hỏi (tỷ lệ đúng/sai, điểm trung bình)
CREATE TABLE IF NOT EXISTS public.question_stats (
  question_id     uuid PRIMARY KEY REFERENCES public.questions(id),
  total_attempts  integer DEFAULT 0,                                  -- Tổng lượt làm
  correct_count   integer DEFAULT 0,                                  -- Số lần đúng
  avg_score       numeric DEFAULT 0,                                  -- Điểm trung bình
  last_attempted  timestamptz                                         -- Lần cuối có HS làm
);


-- ═══ 12. SUBMISSION_ANALYTICS ═══
-- Phân tích bài nộp (dữ liệu cho AI recommendations)
CREATE TABLE IF NOT EXISTS public.submission_analytics (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id uuid REFERENCES public.submissions(id),
  metrics       jsonb,                                                -- Metrics phân tích
  created_at    timestamptz DEFAULT now()
);
-- JSONB: submission_analytics.metrics
-- Mẫu dự kiến:
-- {
--   "time_per_question": { "q1": 45, "q2": 120 },  -- Thời gian/câu (giây)
--   "accuracy_by_tag": { "toán": 0.8, "hình học": 0.6 },
--   "difficulty_vs_score": [
--     { "difficulty": 3, "score": 1.0 },
--     { "difficulty": 5, "score": 0.5 }
--   ]
-- }


-- ═══ 13. AI_RECOMMENDATIONS ═══
-- Đề xuất từ AI cho GV (gợi ý ôn tập, bài tập phụ, cá nhân hóa)
CREATE TABLE IF NOT EXISTS public.ai_recommendations (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id  uuid REFERENCES auth.users(id),                -- GV nhận đề xuất
  class_id    uuid REFERENCES public.classes(id),            -- Lớp nào
  student_id  uuid REFERENCES auth.users(id),                -- HS nào (null = đề xuất chung)
  type        text DEFAULT 'individual'                       -- 'individual' | 'small_group' | 'class'
              CHECK (type IN ('individual', 'small_group', 'class')),
  priority    integer DEFAULT 3                               -- Mức ưu tiên 1-5
              CHECK (priority >= 1 AND priority <= 5),
  title       text NOT NULL,                                  -- Tiêu đề đề xuất
  description text,                                           -- Mô tả chi tiết
  resources   jsonb,                                          -- Tài liệu gợi ý
  dismissed   boolean DEFAULT false,                          -- GV đã bỏ qua
  created_at  timestamptz DEFAULT now()
);
-- JSONB: ai_recommendations.resources
-- Mẫu dự kiến:
-- {
--   "exercises": ["uuid-assignment-1", "uuid-assignment-2"],
--   "videos": ["https://youtube.com/..."],
--   "documents": ["https://docs.google.com/..."]
-- }


-- ═══ 14. TEACHER_NOTES ═══
-- Ghi chú của GV về HS (riêng tư hoặc chia sẻ)
CREATE TABLE IF NOT EXISTS public.teacher_notes (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  teacher_id  uuid REFERENCES auth.users(id),                -- GV nào ghi
  student_id  uuid REFERENCES auth.users(id),                -- Về HS nào
  content     text NOT NULL,                                  -- Nội dung ghi chú
  is_private  boolean DEFAULT true,                           -- Riêng tư hay chia sẻ
  created_at  timestamptz DEFAULT now()
);
