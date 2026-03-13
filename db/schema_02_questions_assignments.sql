-- ==============================================================================
-- AI LMS - SCHEMA PHASE 2: QUESTION BANK & ASSIGNMENTS
-- Cập nhật: 2026-03-12 (đồng bộ từ Supabase production)
-- ==============================================================================

-- ═══ 1. LEARNING_OBJECTIVES ═══
-- Mục tiêu học tập (chuẩn kiến thức) - dùng cho AI phân tích
CREATE TABLE IF NOT EXISTS public.learning_objectives (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_code  text NOT NULL,                               -- Mã môn học (vd: "MATH", "PHY")
  code          text NOT NULL,                               -- Mã chuẩn KT (vd: "M3.1.1")
  description   text NOT NULL,                               -- Mô tả mục tiêu
  difficulty    integer CHECK (difficulty >= 1 AND difficulty <= 5),  -- Độ khó 1-5
  parent_id     uuid REFERENCES public.learning_objectives(id),      -- Mục tiêu cha (cấu trúc cây)
  metadata      jsonb,                                       -- Metadata mở rộng
  created_at    timestamptz DEFAULT now()
);
-- JSONB: learning_objectives.metadata → Chưa có dữ liệu mẫu


-- ═══ 2. QUESTIONS ═══
-- Ngân hàng câu hỏi (Question Bank) - câu hỏi gốc, tái sử dụng được
CREATE TABLE IF NOT EXISTS public.questions (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id       uuid NOT NULL REFERENCES auth.users(id),   -- GV tạo câu hỏi
  type            text NOT NULL                               -- Loại câu hỏi
                  CHECK (type IN (
                    'multiple_choice',   -- Trắc nghiệm nhiều đáp án
                    'short_answer',      -- Trả lời ngắn
                    'essay',             -- Tự luận
                    'true_false',        -- Đúng/Sai
                    'matching',          -- Nối cặp
                    'problem_solving',   -- Giải bài toán
                    'file_upload',       -- Nộp file
                    'fill_in_blank'      -- Điền vào chỗ trống
                  )),
  content         jsonb NOT NULL,                             -- Nội dung câu hỏi (xem mẫu JSONB)
  answer          jsonb,                                      -- Đáp án đúng (xem mẫu JSONB)
  default_points  numeric DEFAULT 1 CHECK (default_points > 0), -- Điểm mặc định
  difficulty      integer CHECK (difficulty >= 1 AND difficulty <= 5), -- Độ khó 1-5
  tags            text[],                                     -- Tags phân loại (mảng text)
  is_public       boolean DEFAULT false,                      -- Câu hỏi công khai cho GV khác
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);
-- JSONB: questions.content
-- ⚠️ TỬ HUYỆT 1: CHỈ chứa đề bài, KHÔNG giải thích (tránh lộ đề thi)
-- Mẫu thực tế (multiple_choice):
-- {
--   "text": "Trong Flutter, kiểu dữ liệu nào được sử dụng để lưu trữ một chuỗi ký tự?",
--   "latex": null,                                               -- Mới
--   "assets": []                                                 -- Mới: Hình ảnh đính kèm
-- }
--
-- JSONB: questions.answer (Polymorphic)
-- ⚠️ TỬ HUYỆT 1: Tách bạch "Cái học sinh thấy" và "Cái AI/GV thấy"
-- Mẫu Trắc nghiệm:
-- {
--   "correct_choice_ids": [1],   -- Mảng ID đáp án đúng (INT)
--   "general_explanation": "String là kiểu dữ liệu chuỗi trong Dart" -- Mới: Giải thích
-- }
-- Mẫu Tự luận (Mới):
-- { "ai_grading_keywords": [{"id": "kw-001", "keyword": "biến", "weight": 0.5}], "sample_response": "Đáp án mẫu..." }


-- ═══ 3. QUESTION_CHOICES ═══
-- Đáp án của câu hỏi trong ngân hàng (Weak Entity, gắn với questions)
-- LƯU Ý: id là INTEGER (không phải UUID) → tiết kiệm 12 bytes/dòng, index nhanh hơn
CREATE TABLE IF NOT EXISTS public.question_choices (
  id          integer NOT NULL CHECK (id >= 0),              -- ID đáp án (0, 1, 2, 3...)
  question_id uuid NOT NULL REFERENCES public.questions(id), -- Câu hỏi gốc
  content     jsonb NOT NULL,                                 -- Nội dung đáp án (xem mẫu JSONB)
  is_correct  boolean DEFAULT false,                          -- Đáp án đúng hay sai
  PRIMARY KEY (id, question_id)
);
-- JSONB: question_choices.content
-- ⚠️ TỬ HUYỆT 1: BẮT BUỘC là Object, có mồi cho AI (tránh crash map)
-- Mẫu hiện tại/tương lai đan xen:
-- Legacy (Cũ): "123"         ← text đáp án
-- Chuẩn mới (Object):
-- { "text": "Đáp án A", "image_url": "https://...", "distractor_rationale": "Lý do HS hay chọn sai..." }


-- ═══ 4. QUESTION_OBJECTIVES ═══
-- Liên kết N-N giữa câu hỏi và mục tiêu học tập
CREATE TABLE IF NOT EXISTS public.question_objectives (
  question_id   uuid NOT NULL REFERENCES public.questions(id),
  objective_id  uuid NOT NULL REFERENCES public.learning_objectives(id),
  PRIMARY KEY (question_id, objective_id)
);


-- ═══ 5. ASSIGNMENTS ═══
-- Template bài tập - chứa NỘI DUNG, tách biệt khỏi lịch phát hành
-- QUAN TRỌNG: KHÔNG có due_at, time_limit ở đây → nằm ở assignment_distributions
CREATE TABLE IF NOT EXISTS public.assignments (
  id                        uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id                  uuid REFERENCES public.classes(id),        -- Thuộc lớp nào (nullable = bài tập riêng)
  teacher_id                uuid NOT NULL REFERENCES auth.users(id),   -- GV tạo bài tập
  title                     text NOT NULL,                              -- Tiêu đề bài tập
  description               text,                                       -- Mô tả / ghi chú
  is_published              boolean DEFAULT false,                      -- Đã xuất bản chưa
  published_at              timestamptz,                                -- Thời điểm xuất bản
  total_points              numeric CHECK (total_points IS NULL OR total_points >= 0), -- Tổng điểm
  default_shuffle_questions boolean DEFAULT false,                      -- Mặc định: đảo thứ tự câu hỏi
  default_shuffle_choices   boolean DEFAULT false,                      -- Mặc định: đảo thứ tự đáp án
  created_at                timestamptz DEFAULT now(),
  updated_at                timestamptz DEFAULT now()
);


-- ═══ 6. ASSIGNMENT_QUESTIONS ═══
-- Câu hỏi trong bài tập (có thể link tới question bank HOẶC custom inline)
-- Nếu question_id = NULL → câu hỏi inline (custom_content chứa toàn bộ)
-- Nếu question_id != NULL → link tới ngân hàng, custom_content chứa override
CREATE TABLE IF NOT EXISTS public.assignment_questions (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id    uuid NOT NULL REFERENCES public.assignments(id),   -- Thuộc bài tập nào
  question_id      uuid REFERENCES public.questions(id),              -- Link ngân hàng (NULL = inline)
  custom_content   jsonb,                                              -- Nội dung tùy chỉnh (xem mẫu JSONB chi tiết)
  points           numeric NOT NULL DEFAULT 1 CHECK (points > 0),     -- Điểm cho câu hỏi này
  rubric           jsonb,                                              -- Rubric chấm điểm (cho essay/problem_solving)
  order_idx        integer NOT NULL                                    -- Thứ tự hiển thị (1, 2, 3...)
);
-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║  JSONB: assignment_questions.custom_content                      ║
-- ║  ĐÂY LÀ JSONB QUAN TRỌNG NHẤT CỦA DỰ ÁN                       ║
-- ╚═══════════════════════════════════════════════════════════════════╝
--
-- === FORMAT MỚI (Delta Override) ===
-- ⚠️ TỬ HUYỆT 2: Nguồn chân lý duy nhất - KHÔNG copy từ questions. Chỉ lưu những gì KHÁC gốc.
-- Chỉ override_text:
-- { "override_text": "Nội dung câu đã sửa cho lớp 10A" }
-- Override cả đáp án:
-- { "override_text": "Đã sửa", "choices": [{"id": 0, "text": "Đáp án A", "isCorrect": true}] }
-- Essay với keywords:
-- { "override_text": "Viết về...", "expected_answer": "Mẫu", "ai_grading_keywords": [...] }
--
-- === FORMAT ĐẦY ĐỦ (V1 Legacy/Standalone) ===
-- Dành cho dữ liệu cũ hoặc inline (question_id = NULL)
-- {
--   "tags": ["toán", "lớp 3"],                -- Tags phân loại
--   "type": "multiple_choice",                -- Loại: "multiple_choice" (snake_case, KHÔNG dùng camelCase)
--   "hints": [],                              -- Gợi ý cho học sinh
--   "choices": [                              -- ĐÁP ÁN (KHÔNG dùng "options")
--     {"id": 0, "text": "Đáp án A", "isCorrect": true},   -- id: INT (0,1,2...), isCorrect: BOOLEAN (camelCase)
--     {"id": 1, "text": "Đáp án B", "isCorrect": false},
--     {"id": 2, "text": "Đáp án C", "isCorrect": false}
--   ],
--   "difficulty": 4,                          -- Độ khó 1-5
--   "explanation": "Giải thích đáp án",       -- Giải thích (hiển thị sau khi chấm)
--   "override_text": "Nội dung câu hỏi",     -- Text câu hỏi (KHÔNG dùng "text")
--   "learningObjectives": []                  -- Mục tiêu học tập liên quan
-- }
--
-- === FORMAT ĐẦY ĐỦ: Math / Essay (V1 Legacy) ===
-- Math: { "tags": ["toán"], "type": "math", "difficulty": 4, "override_text": "1+1=?", "hints": [], "explanation": "", "learningObjectives": [] }
-- Essay: { "tags": ["văn"], "type": "essay", "difficulty": 3, "override_text": "Viết về...", "hints": [], "explanation": "", "learningObjectives": [] }
--
-- ╔══════════════════════════════════════════════════════════════╗
-- ║  QUY TẮC ĐỌC DỮ LIỆU (Backward Compatibility)            ║
-- ║  1. Đọc "override_text" trước, fallback "text"             ║
-- ║  2. Đọc "choices" trước, fallback "options"                ║
-- ║  3. Choice ID luôn là INT (0,1,2,3...) - KHÔNG phải String ║
-- ║  4. Dùng "isCorrect" (camelCase), fallback "is_correct"    ║
-- ╚══════════════════════════════════════════════════════════════╝
--
-- ╔═══════════════════════════════════════════════════════════════════╗
-- ║  JSONB: assignment_questions.rubric (MA TRẬN CHẤM ĐIỂM)        ║
-- ║  ⚠️ Bắt buộc dùng Ma trận cho AI chấm                         ║
-- ╚═══════════════════════════════════════════════════════════════════╝
-- {
--   "criteria": [
--     {
--       "id": "crit-1", "name": "Hiểu định nghĩa", "max_points": 5,
--       "levels": [
--         {"points": 5, "description": "Làm đúng hoàn toàn"},
--         {"points": 0, "description": "Làm sai"}
--       ]
--     }
--   ]
-- }


-- ═══ 7. ASSIGNMENT_VARIANTS ═══
-- Biến thể bài tập (đề riêng cho từng HS/nhóm) - dùng cho shuffle
CREATE TABLE IF NOT EXISTS public.assignment_variants (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id     uuid NOT NULL REFERENCES public.assignments(id),
  variant_type      text NOT NULL DEFAULT 'student'                  -- 'student' | 'group' | 'global'
                    CHECK (variant_type IN ('student', 'group', 'global')),
  student_id        uuid REFERENCES auth.users(id),                  -- HS nhận biến thể (nếu type=student)
  group_id          uuid REFERENCES public.groups(id),               -- Nhóm nhận (nếu type=group)
  due_at_override   timestamptz,                                     -- Override deadline riêng
  custom_questions  jsonb,                                            -- Thứ tự câu hỏi đã shuffle
  created_at        timestamptz DEFAULT now()
);
-- JSONB: assignment_variants.custom_questions
-- ⚠️ TỬ HUYỆT 3: Cấu trúc cây để Frontend vẽ UI không tính (Snapshot Format)
-- Mẫu MỚI (Snapshot chuẩn):
-- [
--   {
--     "assignment_question_id": "uuid-cau-3",
--     "display_order": 1,
--     "shuffled_choices": [13, 17, 15, 19]  -- Mảng INT đã đảo
--   }
-- ]
-- Mẫu CŨ (Legacy):
-- {
--   "question_order": ["uuid-q3", "uuid-q1", "uuid-q2"],  -- Thứ tự câu hỏi đã xáo trộn
--   "choice_orders": {                                     -- Thứ tự đáp án đã xáo trộn theo từng câu
--     "uuid-q1": [2, 0, 3, 1],
--     "uuid-q2": [1, 0, 2]
--   }
-- }


-- ═══ 8. ASSIGNMENT_DISTRIBUTIONS ═══
-- Đợt phát hành bài tập = NGUỒN SỰ THẬT DUY NHẤT cho deadline, time_limit
-- Mỗi distribution = 1 lần "phát đề" đến lớp/nhóm/cá nhân
CREATE TABLE IF NOT EXISTS public.assignment_distributions (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  assignment_id       uuid NOT NULL REFERENCES public.assignments(id),   -- Bài tập nào
  distribution_type   text NOT NULL                                       -- Kiểu phát hành
                      CHECK (distribution_type IN ('class', 'group', 'individual')),
  class_id            uuid REFERENCES public.classes(id),                -- Lớp nhận (nếu type=class)
  group_id            uuid REFERENCES public.groups(id),                 -- Nhóm nhận (nếu type=group)
  student_ids         uuid[],                                             -- Danh sách HS (nếu type=individual)
  available_from      timestamptz,                                        -- Bắt đầu làm bài từ
  due_at              timestamptz,                                        -- Hạn nộp bài
  time_limit_minutes  integer CHECK (time_limit_minutes IS NULL OR time_limit_minutes > 0), -- Giới hạn thời gian (phút)
  allow_late          boolean DEFAULT true,                               -- Cho phép nộp trễ
  late_policy         jsonb,                                              -- Chính sách trừ điểm trễ (xem mẫu JSONB)
  status              text NOT NULL DEFAULT 'active'                      -- Trạng thái đợt phát hành
                      CHECK (status IN ('draft', 'scheduled', 'active', 'closed', 'archived')),
  settings            jsonb                                               -- Cấu hình shuffle/hiển thị (xem mẫu JSONB)
                      DEFAULT '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}',
  created_at          timestamptz DEFAULT now()
);
-- JSONB: assignment_distributions.late_policy
-- ⚠️ TỬ HUYỆT 4: Cấu hình nộp muộn phức tạp
-- Mẫu MỚI ĐẦY ĐỦ:
-- { "policy_type": "daily_deduction", "deduction_value": 10, "unit": "percent", "max_days_allowed": 3, "lowest_possible_score": 0 }
-- Mẫu CŨ (Legacy):
-- { "penalty_per_day_percent": 10 }
--
-- JSONB: assignment_distributions.settings
-- ⚠️ TỬ HUYỆT 4: Xem lại đáp án sau khi nộp
-- Mẫu ĐẦY ĐỦ (Mới nhất):
-- {
--   "shuffle_questions": false,
--   "shuffle_choices": false,
--   "show_score_immediately": true,
--   "student_review_mode": "full_review",  -- Mới: none | score_only | full_review
--   "ai_feedback_enabled": true            -- Mới: Bật/tắt AI chấm
-- }
-- Mẫu CŨ (Legacy):
-- { "shuffle_questions": false, "shuffle_choices": false, "show_score_immediately": true }
