-- ===========================
-- Migration: Create Question Bank & Assignment Tables
-- File: db/02_create_question_bank_tables.sql
-- Description: Tạo các bảng cho ngân hàng câu hỏi, bài tập và mục tiêu học tập
-- Date: 2026-01-29
-- 
-- Lưu ý: File này tạo đầy đủ các bảng cần thiết cho Chapter 1 bao gồm:
-- - Learning objectives với hỗ trợ AI (description và metadata chứa AI config)
-- - Question bank và choices
-- - Assignments, assignment_questions, variants và distributions
-- - Đầy đủ RLS policies và indexes để tối ưu performance
--
-- Dependencies: Các bảng sau phải tồn tại trước khi chạy migration này:
-- - auth.users (built-in Supabase)
-- - public.classes (từ migration trước)
-- - public.groups (từ migration trước)
-- - public.profiles (từ migration trước)
-- - public.class_members (từ migration trước)
-- - public.group_members (từ migration trước)
-- ===========================

-- ===========================
-- 1. Learning Objectives (Mục Tiêu Học Tập)
-- ===========================
create table if not exists public.learning_objectives (
  id uuid primary key default gen_random_uuid(),
  subject_code text not null, -- Mã môn học (ví dụ: 'MATH', 'PHYSICS')
  code text not null, -- Mã mục tiêu học tập (ví dụ: 'MATH.01.01')
  description text not null, -- Mô tả chi tiết mục tiêu học tập, có thể chứa prompt template cho AI
  difficulty int check (difficulty between 1 and 5), -- Độ khó từ 1 (dễ) đến 5 (rất khó)
  parent_id uuid references public.learning_objectives on delete set null, -- Mục tiêu cha (hierarchical structure)
  metadata jsonb, -- JSON chứa cấu hình AI và thông tin bổ sung: {ai_prompt_template, example_questions[], keywords[], question_types[], difficulty_range: {min, max}}
  created_at timestamptz default now(),
  unique (subject_code, code)
);

-- Index cho learning_objectives
-- Note: unique (subject_code, code) tự động tạo index, nhưng giữ lại index này để rõ ràng và có thể dùng cho queries khác
create index if not exists idx_learning_objectives_subject_code on public.learning_objectives(subject_code, code);
create index if not exists idx_learning_objectives_parent on public.learning_objectives(parent_id);

-- ===========================
-- 2. Question Bank (Ngân Hàng Câu Hỏi)
-- ===========================
create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users not null, -- ID giáo viên tạo câu hỏi
  type text check (type in ('multiple_choice','short_answer','essay','true_false','matching','problem_solving','file_upload','fill_in_blank')) not null, -- Loại câu hỏi
  content jsonb not null, -- JSON chứa nội dung câu hỏi: {text: string, images: string[], latex?: string}
  answer jsonb, -- JSON chứa đáp án chuẩn, format tùy theo type (ví dụ: MCQ có thể là {correct_choices: [0,2]} hoặc {text: "đáp án"})
  default_points numeric(7,2) default 1 check (default_points > 0), -- Điểm mặc định cho câu hỏi này
  difficulty int check (difficulty between 1 and 5), -- Độ khó từ 1 (dễ) đến 5 (rất khó)
  tags text[], -- Mảng các thẻ phân loại câu hỏi (ví dụ: ['toán', 'đại số', 'phương trình'])
  is_public boolean default false, -- true: công khai (mọi giáo viên có thể xem), false: riêng tư (chỉ author)
  created_at timestamptz default now(), -- Thời gian tạo câu hỏi
  updated_at timestamptz default now() -- Thời gian cập nhật lần cuối (tự động update qua trigger)
);

-- Indexes cho questions
create index if not exists idx_questions_author on public.questions(author_id);
create index if not exists idx_questions_type on public.questions(type);
create index if not exists idx_questions_is_public on public.questions(is_public);
create index if not exists idx_questions_difficulty on public.questions(difficulty); -- Cho filter theo độ khó
create index if not exists idx_questions_author_type_public on public.questions(author_id, type, is_public);
create index if not exists idx_questions_tags on public.questions using gin(tags); -- GIN index cho array search
create index if not exists idx_questions_created_at on public.questions(created_at desc); -- Cho sort theo ngày tạo

-- Trigger tự động update updated_at
create or replace function public.update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists update_questions_updated_at on public.questions;
create trigger update_questions_updated_at
  before update on public.questions
  for each row
  execute function public.update_updated_at_column();

-- ===========================
-- 3. Question Choices (Lựa Chọn Trắc Nghiệm)
-- ===========================
create table if not exists public.question_choices (
  id int not null check (id >= 0), -- Thứ tự lựa chọn trong câu hỏi (0, 1, 2, 3...)
  question_id uuid references public.questions on delete cascade not null, -- FK đến câu hỏi cha (chỉ dùng cho MCQ)
  content jsonb not null, -- JSON chứa nội dung lựa chọn: {text: string, image?: string}
  is_correct boolean default false, -- true nếu đây là đáp án đúng (có thể có nhiều đáp án đúng)
  primary key (id, question_id) -- Composite primary key: id là thứ tự trong question
);

-- Indexes cho question_choices
create index if not exists idx_question_choices_question on public.question_choices(question_id);
create index if not exists idx_question_choices_order on public.question_choices(question_id, id); -- id chính là order


-- ===========================
-- 4. Question Objectives (Liên Kết Câu Hỏi - Mục Tiêu)
-- ===========================
create table if not exists public.question_objectives (
  question_id uuid references public.questions on delete cascade not null, -- FK đến câu hỏi
  objective_id uuid references public.learning_objectives on delete cascade not null, -- FK đến mục tiêu học tập
  primary key (question_id, objective_id) -- Composite primary key: một câu hỏi có thể đánh giá nhiều mục tiêu
);

-- Indexes cho question_objectives
create index if not exists idx_question_objectives_question on public.question_objectives(question_id);
create index if not exists idx_question_objectives_objective on public.question_objectives(objective_id);

-- ===========================
-- 5. Assignments (Bài Tập)
-- ===========================
create table if not exists public.assignments (
  id uuid primary key default gen_random_uuid(),
  class_id uuid references public.classes on delete cascade, -- FK đến lớp học (có thể null nếu phân phối sau)
  teacher_id uuid references auth.users not null, -- FK đến giáo viên tạo bài tập
  title text not null, -- Tiêu đề bài tập
  description text, -- Mô tả chi tiết bài tập (hướng dẫn, yêu cầu)
  is_published boolean default false, -- true: đã xuất bản (học sinh có thể thấy), false: đang soạn thảo
  published_at timestamptz, -- Thời gian xuất bản (tự động set khi is_published = true)
  total_points numeric(8,2) check (total_points is null or total_points >= 0), -- Tổng điểm bài tập (tự động tính từ assignment_questions hoặc set thủ công)
  created_at timestamptz default now(), -- Thời gian tạo bài tập
  updated_at timestamptz default now() -- Thời gian cập nhật lần cuối (tự động update qua trigger)
);

-- Indexes cho assignments
create index if not exists idx_assignments_class on public.assignments(class_id);
create index if not exists idx_assignments_teacher on public.assignments(teacher_id);
create index if not exists idx_assignments_is_published on public.assignments(is_published);
create index if not exists idx_assignments_class_teacher_published on public.assignments(class_id, teacher_id, is_published);
create index if not exists idx_assignments_created_at on public.assignments(created_at desc); -- Cho sort theo ngày tạo

-- Trigger tự động update updated_at cho assignments
drop trigger if exists update_assignments_updated_at on public.assignments;
create trigger update_assignments_updated_at
  before update on public.assignments
  for each row
  execute function public.update_updated_at_column();

-- ===========================
-- 6. Assignment Questions (Câu Hỏi Trong Bài Tập)
-- ===========================
create table if not exists public.assignment_questions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade not null, -- FK đến bài tập
  question_id uuid references public.questions on delete set null, -- FK đến câu hỏi trong ngân hàng (NULL nếu tạo mới, không reuse)
  custom_content jsonb, -- JSON nội dung tùy chỉnh nếu giáo viên sửa câu hỏi từ ngân hàng (override content gốc)
  points numeric(7,2) not null default 1 check (points > 0), -- Điểm cho câu hỏi này trong bài tập (có thể khác default_points)
  rubric jsonb, -- JSON tiêu chí chấm điểm: {criteria: [{name, max_points, description}], total_points}
  order_idx int not null, -- Thứ tự câu hỏi trong bài tập (1, 2, 3, ...)
  unique (assignment_id, order_idx) -- Đảm bảo không có 2 câu hỏi cùng thứ tự trong 1 bài tập
);

-- Indexes cho assignment_questions
create index if not exists idx_assignment_questions_assignment on public.assignment_questions(assignment_id);
create index if not exists idx_assignment_questions_question on public.assignment_questions(question_id);
create index if not exists idx_assignment_questions_order on public.assignment_questions(assignment_id, order_idx);

-- ===========================
-- 7. Assignment Variants (Biến Thể Bài Tập - Phân Hóa)
-- ===========================
create table if not exists public.assignment_variants (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade not null, -- FK đến bài tập gốc
  variant_type text check (variant_type in ('student','group','global')) default 'student' not null, -- Loại variant: 'student' (cho 1 học sinh), 'group' (cho 1 nhóm), 'global' (cho tất cả)
  student_id uuid references auth.users on delete cascade, -- FK đến học sinh (required nếu variant_type = 'student')
  group_id uuid references public.groups on delete cascade, -- FK đến nhóm (required nếu variant_type = 'group')
  due_at_override timestamptz, -- Hạn nộp override cho variant này (null = dùng due_at từ assignment hoặc distribution)
  custom_questions jsonb, -- JSON array chứa danh sách assignment_question ids hoặc objects tùy chỉnh cho variant này
  created_at timestamptz default now(), -- Thời gian tạo variant
  -- Validation: variant_type phải match với student_id hoặc group_id
  constraint check_variant_type_match check (
    (variant_type = 'student' and student_id is not null and group_id is null)
    or (variant_type = 'group' and group_id is not null and student_id is null)
    or (variant_type = 'global' and student_id is null and group_id is null)
  )
);

-- Indexes cho assignment_variants
create index if not exists idx_assignment_variants_assignment on public.assignment_variants(assignment_id);
create index if not exists idx_assignment_variants_student on public.assignment_variants(student_id);
create index if not exists idx_assignment_variants_group on public.assignment_variants(group_id);
create index if not exists idx_assignment_variants_type on public.assignment_variants(variant_type);

-- ===========================
-- 8. Assignment Distributions (Phân Phối Bài Tập)
-- ===========================
create table if not exists public.assignment_distributions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade not null, -- FK đến bài tập
  distribution_type text check (distribution_type in ('class','group','individual')) not null, -- Loại phân phối: 'class' (cho cả lớp), 'group' (cho 1 nhóm), 'individual' (cho danh sách học sinh cụ thể)
  class_id uuid references public.classes on delete cascade, -- FK đến lớp học (required nếu distribution_type = 'class')
  group_id uuid references public.groups on delete cascade, -- FK đến nhóm (required nếu distribution_type = 'group')
  student_ids uuid[], -- Mảng UUID của học sinh (required nếu distribution_type = 'individual', phải có ít nhất 1 phần tử)
  available_from timestamptz, -- Thời gian bắt đầu cho phép làm bài cho đợt phát hành này (SSOT: không đọc từ assignments)
  due_at timestamptz, -- Hạn nộp bài cho distribution này (SSOT: chỉ lưu ở đây)
  time_limit_minutes int check (time_limit_minutes is null or time_limit_minutes > 0), -- Giới hạn thời gian làm bài (phút), null = không giới hạn
  allow_late boolean default true, -- Cho phép nộp muộn hay không cho distribution này
  late_policy jsonb, -- JSON policy cho nộp muộn: {penalty_percentage: number, max_penalty: number, grace_period_minutes: number}
  status text not null default 'active' check (status in ('draft','scheduled','active','closed','archived')), -- Trạng thái đợt phát hành: có thể đóng đợt cũ mà không ảnh hưởng đợt mới
  created_at timestamptz default now(), -- Thời gian tạo distribution
  -- Validation: distribution_type phải match với các fields tương ứng
  constraint check_distribution_type_match check (
    (distribution_type = 'class' and class_id is not null and group_id is null and student_ids is null)
    or (distribution_type = 'group' and group_id is not null and class_id is null and student_ids is null)
    or (distribution_type = 'individual' and student_ids is not null and array_length(student_ids, 1) > 0 and class_id is null and group_id is null)
  )
);

-- Indexes cho assignment_distributions
create index if not exists idx_assignment_distributions_assignment on public.assignment_distributions(assignment_id);
create index if not exists idx_assignment_distributions_class on public.assignment_distributions(class_id);
create index if not exists idx_assignment_distributions_group on public.assignment_distributions(group_id);
create index if not exists idx_assignment_distributions_type on public.assignment_distributions(distribution_type);
create index if not exists idx_assignment_distributions_status on public.assignment_distributions(status);
create index if not exists idx_assignment_distributions_available_from on public.assignment_distributions(available_from); -- Cho query assignments available
create index if not exists idx_assignment_distributions_due_at on public.assignment_distributions(due_at); -- Cho query assignments sắp đến hạn
create index if not exists idx_assignment_distributions_student_ids on public.assignment_distributions using gin(student_ids); -- GIN index cho array

-- ===========================
-- 9. Row-Level Security (RLS) Policies
-- ===========================

-- Enable RLS cho tất cả các bảng
alter table public.learning_objectives enable row level security;
alter table public.questions enable row level security;
alter table public.question_choices enable row level security;
alter table public.question_objectives enable row level security;
alter table public.assignments enable row level security;
alter table public.assignment_questions enable row level security;
alter table public.assignment_variants enable row level security;
alter table public.assignment_distributions enable row level security;

-- ===========================
-- 7.1. Learning Objectives Policies
-- ===========================

-- Mọi người có thể xem learning objectives (public data)
create policy "Anyone can view learning objectives"
  on public.learning_objectives for select
  using (true);

-- Chỉ admins và teachers có thể tạo/sửa/xóa
create policy "Teachers and admins can manage learning objectives"
  on public.learning_objectives for all
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role in ('teacher', 'admin')
    )
  );

-- ===========================
-- 7.2. Questions Policies
-- ===========================

-- Teachers có thể xem câu hỏi của mình
create policy "Teachers can view own questions"
  on public.questions for select
  using ((select auth.uid()) = author_id);

-- Teachers có thể tạo câu hỏi của mình
create policy "Teachers can insert own questions"
  on public.questions for insert
  with check ((select auth.uid()) = author_id);

-- Teachers có thể sửa câu hỏi của mình
create policy "Teachers can update own questions"
  on public.questions for update
  using ((select auth.uid()) = author_id)
  with check ((select auth.uid()) = author_id);

-- Teachers có thể xóa câu hỏi của mình
create policy "Teachers can delete own questions"
  on public.questions for delete
  using ((select auth.uid()) = author_id);

-- Mọi người có thể xem câu hỏi public
create policy "Anyone can view public questions"
  on public.questions for select
  using (is_public = true);

-- Students có thể xem câu hỏi trong assignments đã được phân phối cho họ
create policy "Students can view questions in assigned assignments"
  on public.questions for select
  using (
    exists (
      select 1 from public.assignment_questions aq
      join public.assignments a on a.id = aq.assignment_id
      join public.assignment_distributions ad on ad.assignment_id = a.id
      left join public.class_members cm on cm.class_id = ad.class_id
      left join public.group_members gm on gm.group_id = ad.group_id
      where aq.question_id = questions.id
        and a.is_published = true
        and (
          (ad.distribution_type = 'class' and cm.student_id = (select auth.uid()) and cm.status = 'approved')
          or (ad.distribution_type = 'group' and gm.student_id = (select auth.uid()))
          or (ad.distribution_type = 'individual' and (select auth.uid()) = any(ad.student_ids))
        )
        and ad.status in ('scheduled','active')
        and (ad.available_from is null or ad.available_from <= now())
    )
  );

-- Admins có full access
create policy "Admins have full access to questions"
  on public.questions for all
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role = 'admin'
    )
  );

-- ===========================
-- 7.3. Question Choices Policies
-- ===========================

-- Inherit từ questions: Chỉ author của question mới có thể sửa choices
create policy "Question authors can manage choices"
  on public.question_choices for all
  using (
    exists (
      select 1 from public.questions
      where id = question_choices.question_id and author_id = (select auth.uid())
    )
  );

-- Mọi người có thể xem choices của câu hỏi public
create policy "Anyone can view choices of public questions"
  on public.question_choices for select
  using (
    exists (
      select 1 from public.questions
      where id = question_choices.question_id and is_public = true
    )
  );

-- Students có thể xem choices của câu hỏi trong assignments đã được phân phối
create policy "Students can view choices in assigned assignments"
  on public.question_choices for select
  using (
    exists (
      select 1 from public.questions q
      join public.assignment_questions aq on aq.question_id = q.id
      join public.assignments a on a.id = aq.assignment_id
      join public.assignment_distributions ad on ad.assignment_id = a.id
      left join public.class_members cm on cm.class_id = ad.class_id
      left join public.group_members gm on gm.group_id = ad.group_id
      where q.id = question_choices.question_id
        and a.is_published = true
        and (
          (ad.distribution_type = 'class' and cm.student_id = (select auth.uid()) and cm.status = 'approved')
          or (ad.distribution_type = 'group' and gm.student_id = (select auth.uid()))
          or (ad.distribution_type = 'individual' and (select auth.uid()) = any(ad.student_ids))
        )
        and ad.status in ('scheduled','active')
        and (ad.available_from is null or ad.available_from <= now())
    )
  );

-- Admins có full access
create policy "Admins have full access to question choices"
  on public.question_choices for all
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role = 'admin'
    )
  );

-- ===========================
-- 7.4. Question Objectives Policies
-- ===========================

-- Inherit từ questions: Chỉ author của question mới có thể quản lý objectives
create policy "Question authors can manage objectives"
  on public.question_objectives for all
  using (
    exists (
      select 1 from public.questions
      where id = question_objectives.question_id and author_id = (select auth.uid())
    )
  );

-- Mọi người có thể xem objectives của câu hỏi public
create policy "Anyone can view objectives of public questions"
  on public.question_objectives for select
  using (
    exists (
      select 1 from public.questions
      where id = question_objectives.question_id and is_public = true
    )
  );

-- Admins có full access
create policy "Admins have full access to question objectives"
  on public.question_objectives for all
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role = 'admin'
    )
  );

-- ===========================
-- 7.5. Assignments Policies
-- ===========================

-- Teachers có thể xem assignments của mình
create policy "Teachers can view own assignments"
  on public.assignments for select
  using ((select auth.uid()) = teacher_id);

-- Teachers có thể tạo assignments cho lớp của mình
create policy "Teachers can create assignments"
  on public.assignments for insert
  with check (
    (select auth.uid()) = teacher_id
    and (
      class_id is null
      or exists (
        select 1 from public.classes c
        where c.id = class_id and c.teacher_id = (select auth.uid())
      )
    )
  );

-- Teachers có thể sửa assignments của mình (chỉ khi chưa published hoặc đang edit)
create policy "Teachers can update own assignments"
  on public.assignments for update
  using ((select auth.uid()) = teacher_id)
  with check ((select auth.uid()) = teacher_id);

-- Teachers có thể xóa assignments của mình (chỉ khi chưa published)
create policy "Teachers can delete own unpublished assignments"
  on public.assignments for delete
  using (
    (select auth.uid()) = teacher_id
    and is_published = false
  );

-- Students có thể xem assignments đã được phân phối cho lớp/nhóm của mình
create policy "Students can view assigned assignments"
  on public.assignments for select
  using (
    exists (
      select 1 from public.assignment_distributions ad
      left join public.class_members cm on cm.class_id = ad.class_id
      left join public.group_members gm on gm.group_id = ad.group_id
      where ad.assignment_id = assignments.id
        and assignments.is_published = true
        and (
          (ad.distribution_type = 'class' and cm.student_id = (select auth.uid()) and cm.status = 'approved')
          or (ad.distribution_type = 'group' and gm.student_id = (select auth.uid()))
          or (ad.distribution_type = 'individual' and (select auth.uid()) = any(ad.student_ids))
        )
        and ad.status in ('scheduled','active')
        and (ad.available_from is null or ad.available_from <= now())
    )
  );

-- Admins có full access
create policy "Admins have full access to assignments"
  on public.assignments for all
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role = 'admin'
    )
  );

-- ===========================
-- 7.6. Assignment Questions Policies
-- ===========================

-- Teachers có thể quản lý questions trong assignments của mình
create policy "Teachers can manage questions in own assignments"
  on public.assignment_questions for all
  using (
    exists (
      select 1 from public.assignments
      where id = assignment_questions.assignment_id and teacher_id = (select auth.uid())
    )
  );

-- Students có thể xem questions trong assignments đã được phân phối cho họ
create policy "Students can view questions in assigned assignments"
  on public.assignment_questions for select
  using (
    exists (
      select 1 from public.assignments a
      join public.assignment_distributions ad on ad.assignment_id = a.id
      left join public.class_members cm on cm.class_id = ad.class_id
      left join public.group_members gm on gm.group_id = ad.group_id
      where a.id = assignment_questions.assignment_id
        and a.is_published = true
        and (
          (ad.distribution_type = 'class' and cm.student_id = (select auth.uid()) and cm.status = 'approved')
          or (ad.distribution_type = 'group' and gm.student_id = (select auth.uid()))
          or (ad.distribution_type = 'individual' and (select auth.uid()) = any(ad.student_ids))
        )
        and ad.status in ('scheduled','active')
        and (ad.available_from is null or ad.available_from <= now())
    )
  );

-- Admins có full access
create policy "Admins have full access to assignment questions"
  on public.assignment_questions for all
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role = 'admin'
    )
  );

-- ===========================
-- 7.7. Assignment Variants Policies
-- ===========================

-- Teachers có thể quản lý variants trong assignments của mình
create policy "Teachers can manage variants in own assignments"
  on public.assignment_variants for all
  using (
    exists (
      select 1 from public.assignments
      where id = assignment_variants.assignment_id and teacher_id = (select auth.uid())
    )
  );

-- Students có thể xem variants được assign cho mình
create policy "Students can view own variants"
  on public.assignment_variants for select
  using (
    (
      variant_type = 'student' and student_id = (select auth.uid())
    )
    or (
      variant_type = 'group' and exists (
        select 1 from public.group_members
        where group_id = assignment_variants.group_id and student_id = (select auth.uid())
      )
    )
    or (
      variant_type = 'global' and exists (
        select 1 from public.assignment_distributions ad
        join public.assignments a on a.id = ad.assignment_id
        left join public.class_members cm on cm.class_id = ad.class_id
        left join public.group_members gm on gm.group_id = ad.group_id
        where ad.assignment_id = assignment_variants.assignment_id
          and (
            (ad.distribution_type = 'class' and cm.student_id = (select auth.uid()) and cm.status = 'approved')
            or (ad.distribution_type = 'group' and gm.student_id = (select auth.uid()))
            or (ad.distribution_type = 'individual' and (select auth.uid()) = any(ad.student_ids))
          )
          and ad.status in ('scheduled','active')
      )
    )
  );

-- Admins có full access
create policy "Admins have full access to assignment variants"
  on public.assignment_variants for all
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role = 'admin'
    )
  );

-- ===========================
-- 7.8. Assignment Distributions Policies
-- ===========================

-- Teachers có thể quản lý distributions cho assignments của mình
create policy "Teachers can manage distributions for own assignments"
  on public.assignment_distributions for all
  using (
    exists (
      select 1 from public.assignments
      where id = assignment_distributions.assignment_id and teacher_id = (select auth.uid())
    )
  );

-- Students có thể xem distributions của assignments được assign cho mình
create policy "Students can view distributions for assigned assignments"
  on public.assignment_distributions for select
  using (
    exists (
      select 1 from public.assignments a
      where a.id = assignment_distributions.assignment_id
        and a.is_published = true
        and (
          -- Distribution cho lớp của student
          (
            distribution_type = 'class'
            and exists (
              select 1 from public.class_members cm
              where cm.class_id = assignment_distributions.class_id
                and cm.student_id = (select auth.uid())
                and cm.status = 'approved'
            )
          )
          -- Distribution cho nhóm của student
          or (
            distribution_type = 'group'
            and exists (
              select 1 from public.group_members gm
              where gm.group_id = assignment_distributions.group_id
                and gm.student_id = (select auth.uid())
            )
          )
          -- Distribution cá nhân cho student
          or (
            distribution_type = 'individual'
            and (select auth.uid()) = any(student_ids)
          )
        )
        and status in ('scheduled','active')
        and (available_from is null or available_from <= now())
    )
  );

-- Admins có full access
create policy "Admins have full access to assignment distributions"
  on public.assignment_distributions for all
  using (
    exists (
      select 1 from public.profiles
      where id = (select auth.uid()) and role = 'admin'
    )
  );

-- ===========================
-- 7.9. RPC Functions (Server-side transactions)
-- ===========================
-- RPC: Publish assignment trong 1 transaction để giảm round-trip:
-- - Upsert assignments (set is_published=true, published_at=now())
-- - Replace assignment_questions
-- - Replace assignment_distributions
--
-- Security:
-- - SECURITY DEFINER để chạy như owner và không bị RLS chặn
-- - Tự kiểm tra auth.uid() và quyền teacher/admin bên trong function
create or replace function public.publish_assignment(
  p_assignment jsonb,
  p_questions jsonb default '[]'::jsonb,
  p_distributions jsonb default '[]'::jsonb
) returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_is_admin boolean := false;
  v_teacher_id uuid;
  v_assignment_id uuid;
  v_assignment_row public.assignments%rowtype;
  v_class_id uuid;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  select exists(
    select 1 from public.profiles
    where id = v_uid and role = 'admin'
  ) into v_is_admin;

  if v_is_admin then
    v_teacher_id := coalesce((p_assignment->>'teacher_id')::uuid, v_uid);
  else
    if not exists(
      select 1 from public.profiles
      where id = v_uid and role = 'teacher'
    ) then
      raise exception 'Forbidden: only teachers can publish assignments';
    end if;
    v_teacher_id := v_uid;
  end if;

  v_class_id := (p_assignment->>'class_id')::uuid;
  if v_class_id is not null then
    if not exists(
      select 1
      from public.classes c
      where c.id = v_class_id
        and (v_is_admin or c.teacher_id = v_teacher_id)
    ) then
      raise exception 'Forbidden: class not owned by teacher';
    end if;
  end if;

  -- Upsert assignment
  v_assignment_id := (p_assignment->>'id')::uuid;
  if v_assignment_id is not null then
    if not v_is_admin and not exists(
      select 1 from public.assignments a
      where a.id = v_assignment_id and a.teacher_id = v_teacher_id
    ) then
      raise exception 'Forbidden: assignment not owned by teacher';
    end if;

    update public.assignments
    set
      class_id = v_class_id,
      title = coalesce(p_assignment->>'title', title),
      description = p_assignment->>'description',
      total_points = (p_assignment->>'total_points')::numeric,
      is_published = true,
      published_at = now()
    where id = v_assignment_id
    returning * into v_assignment_row;
  else
    insert into public.assignments (
      class_id,
      teacher_id,
      title,
      description,
      is_published,
      published_at,
      total_points
    ) values (
      v_class_id,
      v_teacher_id,
      coalesce(p_assignment->>'title', 'Bài tập mới'),
      p_assignment->>'description',
      true,
      now(),
      (p_assignment->>'total_points')::numeric
    )
    returning * into v_assignment_row;

    v_assignment_id := v_assignment_row.id;
  end if;

  -- Replace assignment_questions
  delete from public.assignment_questions where assignment_id = v_assignment_id;
  if jsonb_typeof(p_questions) = 'array' and jsonb_array_length(p_questions) > 0 then
    insert into public.assignment_questions (
      assignment_id,
      question_id,
      custom_content,
      points,
      rubric,
      order_idx
    )
    select
      v_assignment_id,
      (q->>'question_id')::uuid,
      q->'custom_content',
      coalesce((q->>'points')::numeric, 1),
      q->'rubric',
      (q->>'order_idx')::int
    from jsonb_array_elements(p_questions) as q;
  end if;

  -- Replace assignment_distributions
  delete from public.assignment_distributions where assignment_id = v_assignment_id;
  if jsonb_typeof(p_distributions) = 'array' and jsonb_array_length(p_distributions) > 0 then
    insert into public.assignment_distributions (
      assignment_id,
      distribution_type,
      class_id,
      group_id,
      student_ids,
      available_from,
      due_at,
      time_limit_minutes,
      allow_late,
      late_policy,
      status
    )
    select
      v_assignment_id,
      (d->>'distribution_type')::text,
      (d->>'class_id')::uuid,
      (d->>'group_id')::uuid,
      case
        when d ? 'student_ids' and d->'student_ids' is not null then
          array(
            select jsonb_array_elements_text(d->'student_ids')::uuid
          )
        else null
      end,
      (d->>'available_from')::timestamptz,
      (d->>'due_at')::timestamptz,
      (d->>'time_limit_minutes')::int,
      coalesce((d->>'allow_late')::boolean, true),
      d->'late_policy',
      coalesce((d->>'status')::text, 'active')
    from jsonb_array_elements(p_distributions) as d;
  end if;

  select * into v_assignment_row from public.assignments where id = v_assignment_id;
  return to_jsonb(v_assignment_row);
end;
$$;

grant execute on function public.publish_assignment(jsonb, jsonb, jsonb) to authenticated;
comment on function public.publish_assignment(jsonb, jsonb, jsonb)
  is 'RPC: publish assignment in 1 transaction (upsert assignment + replace assignment_questions + replace assignment_distributions). SECURITY DEFINER with explicit auth checks.';

-- ===========================
-- 8. Comments & Documentation
-- ===========================

comment on table public.learning_objectives is 'Mục tiêu học tập theo môn học, có thể có cấu trúc phân cấp. Hỗ trợ AI tạo câu hỏi thông qua description và metadata';
comment on table public.questions is 'Ngân hàng câu hỏi, có thể public hoặc private';
comment on table public.question_choices is 'Lựa chọn cho câu hỏi trắc nghiệm (multiple choice)';
comment on table public.question_objectives is 'Liên kết nhiều-nhiều giữa câu hỏi và mục tiêu học tập';
comment on table public.assignments is 'Template bài tập chứa nội dung và câu hỏi, tách biệt hoàn toàn khỏi lịch phát hành & deadline';
comment on table public.assignment_questions is 'Câu hỏi trong bài tập, có thể reuse từ ngân hàng hoặc tạo mới';
comment on table public.assignment_variants is 'Biến thể bài tập để phân hóa theo học sinh/nhóm (differentiated assignments)';
comment on table public.assignment_distributions is 'Đợt phát hành bài tập đến lớp/nhóm/học sinh cụ thể, là nguồn sự thật duy nhất cho deadline, time_limit, late_policy và status';

comment on column public.questions.content is 'JSON chứa nội dung câu hỏi: {text, images[], latex}';
comment on column public.questions.answer is 'JSON chứa đáp án chuẩn, format tùy theo type';
comment on column public.question_choices.content is 'JSON chứa nội dung lựa chọn: {text, image?}';
comment on column public.assignment_questions.custom_content is 'Nội dung tùy chỉnh nếu giáo viên sửa câu hỏi từ ngân hàng';
comment on column public.assignment_questions.question_id is 'NULL nếu tạo mới, có giá trị nếu reuse từ ngân hàng';
comment on column public.learning_objectives.description is 'Mô tả chi tiết mục tiêu học tập. Có thể chứa prompt template cho AI với placeholders như {difficulty}, {subject}. Ví dụ: "Tạo câu hỏi về {subject} với độ khó {difficulty}"';
comment on column public.learning_objectives.metadata is 'JSON chứa cấu hình AI và thông tin bổ sung: {ai_prompt_template: string, example_questions: [], keywords: [], question_types: [], difficulty_range: {min, max}}';
comment on column public.assignment_variants.custom_questions is 'JSON array chứa danh sách assignment_question ids hoặc objects tùy chỉnh cho variant này';
comment on column public.assignment_distributions.late_policy is 'JSON policy cho nộp muộn: {penalty_percentage, max_penalty, grace_period_minutes}';
comment on column public.assignment_distributions.student_ids is 'Array UUID của học sinh khi distribution_type = individual';

-- ===========================
-- End of Migration
-- ===========================
