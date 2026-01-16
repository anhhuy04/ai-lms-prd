

-----
-- ===========================
-- Extensions
-- ===========================
create extension if not exists "pgcrypto";  -- gen_random_uuid()
create extension if not exists "pg_net";    -- nếu dùng Edge Functions
create extension if not exists "uuid-ossp";

-- ===========================
-- 0. Profiles (kết nối auth.users) + trigger
-- ===========================
create table if not exists public.profiles (
  id uuid primary key references auth.users not null,
  full_name text,
  role text check (role in ('teacher', 'student', 'admin')) default 'student',
  avatar_url text,
  bio text,
  metadata jsonb,
  updated_at timestamptz default now()
);

create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, new.raw_user_meta_data->>'full_name', coalesce(new.raw_user_meta_data->>'role', 'student'))
  on conflict (id) do nothing;
  return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- ===========================
-- 1. Organization: schools, classes, membership
-- ===========================
create table if not exists public.schools (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  domain text unique,
  metadata jsonb,
  created_at timestamptz default now()
);

create table if not exists public.classes (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references public.schools,
  teacher_id uuid references auth.users not null,
  name text not null,
  subject text,
  academic_year text,
  description text,
   -- settings chính của lớp
  class_settings jsonb not null default '{
    "enrollment": {
      "qr_code": {
        "join_code": null,
        "is_active": false,
        "require_approval": true,
        "expires_at": null
      },
      "manual_join_limit": null
    },
    "group_management": {
      "is_visible_to_students": true,
      "allow_student_switch": false,
      "lock_groups": false
    },
    "student_permissions": {
      "can_edit_profile_in_class": true,
      "auto_lock_on_submission": false
    },
    "defaults": {
      "lock_class": false
    }
  }',
  created_at timestamptz default now()
);

create table if not exists public.class_members (
  id uuid primary key default gen_random_uuid(),

  class_id uuid not null
    references public.classes(id) on delete cascade,

  student_id uuid not null
    references public.profiles(id) on delete cascade,

  status text not null
    check (status in ('pending', 'approved', 'rejected'))
    default 'pending',

  joined_at timestamptz,
  created_at timestamptz default now(),

  unique (class_id, student_id)
);


-- Additional teacher-class mapping (co-teachers, assistants)
create table if not exists public.class_teachers (
  id uuid primary key default gen_random_uuid(),
  class_id uuid references public.classes on delete cascade,
  teacher_id uuid references auth.users on delete cascade,
  role text default 'teacher'
);

-- ===========================
-- 2. Groups inside class (for differentiated assignments)
-- ===========================
create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  class_id uuid references public.classes on delete cascade,
  name text not null,
  description text,
  created_at timestamptz default now()
);

create table if not exists public.group_members (
  group_id uuid references public.groups on delete cascade,
  student_id uuid references auth.users on delete cascade,
  joined_at timestamptz default now(),
  primary key (group_id, student_id)
);

-- ===========================
-- 3. Learning objectives / skills
-- ===========================
create table if not exists public.learning_objectives (
  id uuid primary key default gen_random_uuid(),
  subject_code text not null,
  code text not null,
  description text not null,
  difficulty int check (difficulty between 1 and 5),
  parent_id uuid references public.learning_objectives,
  metadata jsonb,
  created_at timestamptz default now(),
  unique (subject_code, code)
);

-- ===========================
-- 4. Question Bank
-- ===========================
create table if not exists public.questions (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users not null,
  type text check (type in ('multiple_choice','short_answer','essay','true_false','matching','problem_solving','file_upload','fill_in_blank')) not null,
  content jsonb not null,        -- rich text + images + latex
  answer jsonb,                  -- expected answer(s), canonical response
  default_points numeric(7,2) default 1,
  difficulty int check (difficulty between 1 and 5),
  tags text[],
  is_public boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.question_objectives (
  question_id uuid references public.questions on delete cascade,
  objective_id uuid references public.learning_objectives on delete cascade,
  primary key (question_id, objective_id)
);

-- choices for MCQ
create table if not exists public.question_choices (
  id uuid primary key default gen_random_uuid(),
  question_id uuid references public.questions on delete cascade,
  content jsonb not null,
  is_correct boolean default false,
  order_idx int
);

-- ===========================
-- 5. Attachments / file metadata (links to Supabase Storage)
-- ===========================
create table if not exists public.files (
  id uuid primary key default gen_random_uuid(),
  storage_path text not null, -- S3/Supabase key
  url text,
  filename text,
  mime_type text,
  size_bytes bigint,
  uploaded_by uuid references auth.users,
  metadata jsonb,
  created_at timestamptz default now()
);

-- link files to questions or answers
create table if not exists public.file_links (
  id uuid primary key default gen_random_uuid(),
  file_id uuid references public.files on delete cascade,
  target_type text not null, -- 'question','answer','assignment','profile'...
  target_id uuid not null,
  created_at timestamptz default now()
);

-- ===========================
-- 6. Assignments + assignment questions + variants + distribution
-- ===========================
create table if not exists public.assignments (
  id uuid primary key default gen_random_uuid(),
  class_id uuid references public.classes on delete cascade,
  teacher_id uuid references auth.users not null,
  title text not null,
  description text,
  is_published boolean default false,
  published_at timestamptz,
  due_at timestamptz,
  available_from timestamptz,
  time_limit_minutes int,
  allow_late boolean default true,
  total_points numeric(8,2),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.assignment_questions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade,
  question_id uuid references public.questions,
  custom_content jsonb,        -- nếu giáo viên sửa
  points numeric(7,2) not null default 1,
  rubric jsonb,                -- tiêu chí chấm
  order_idx int not null,
  unique (assignment_id, order_idx)
);

-- Differentiated assignment variants (per student or per group)
create table if not exists public.assignment_variants (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade,
  variant_type text check (variant_type in ('student','group','global')) default 'student',
  student_id uuid references auth.users,
  group_id uuid references public.groups,
  due_at_override timestamptz,
  custom_questions jsonb,      -- array of assignment_question ids or objects
  created_at timestamptz default now()
);

-- Distribution: where assignment is sent (class / group / individuals)
create table if not exists public.assignment_distributions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade,
  distribution_type text check (distribution_type in ('class','group','individual')) not null,
  class_id uuid references public.classes,
  group_id uuid references public.groups,
  student_ids uuid[], -- explicit list when distribution_type = 'individual'
  available_from timestamptz,
  due_at timestamptz,
  time_limit_minutes int,
  allow_late boolean default true,
  late_policy jsonb,
  created_at timestamptz default now()
);

-- ===========================
-- 7. Student workspace / submissions / autosave
-- ===========================
-- Tracking an active work session (lam_bai)
create table if not exists public.work_sessions (
  id uuid primary key default gen_random_uuid(),
  assignment_distribution_id uuid references public.assignment_distributions,
  assignment_id uuid references public.assignments,
  student_id uuid references auth.users not null,
  started_at timestamptz,
  submitted_at timestamptz,
  attempt int default 1,
  status text default 'in_progress', -- in_progress / submitted / graded / late
  time_spent_seconds bigint default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Autosave drafts per question
create table if not exists public.autosave_answers (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references public.work_sessions on delete cascade,
  assignment_question_id uuid,
  answer_content jsonb,
  updated_at timestamptz default now()
);

-- Final submitted answers per question
create table if not exists public.submission_answers (
  id uuid primary key default gen_random_uuid(),
  session_id uuid references public.work_sessions on delete cascade,
  assignment_question_id uuid references public.assignment_questions not null,
  answer jsonb not null,
  files jsonb,                 -- [{file_id, url, name, size}]
  flagged boolean default false,
  ai_score numeric(7,2),
  ai_confidence numeric(3,2),
  final_score numeric(7,2),
  ai_feedback jsonb,
  teacher_feedback jsonb,
  graded_by uuid references auth.users,
  graded_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Quick submissions table for reporting aggregated results
create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade,
  student_id uuid references auth.users not null,
  session_id uuid references public.work_sessions,
  variant_id uuid references public.assignment_variants,
  started_at timestamptz,
  submitted_at timestamptz,
  is_late boolean generated always as (
    case
      when submitted_at is null then false
      when (select coalesce(a.due_at, ad.due_at) from public.assignments a left join public.assignment_distributions ad on ad.assignment_id = a.id where a.id = assignment_id limit 1) is null then false
      else submitted_at > coalesce((select ad.due_at from public.assignment_distributions ad where ad.assignment_id = assignment_id limit 1),(select a.due_at from public.assignments a where a.id = assignment_id limit 1))
    end
  ) stored,
  total_score numeric(8,2),
  ai_graded boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- ===========================
-- 8. AI grading / queue / evaluations
-- ===========================
create table if not exists public.ai_queue (
  id uuid primary key default gen_random_uuid(),
  submission_answer_id uuid references public.submission_answers,
  request_type text check (request_type in ('score','feedback','analysis')) default 'score',
  status text default 'pending', -- pending / running / done / failed
  attempts int default 0,
  payload jsonb, -- extra params
  result jsonb,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists public.ai_evaluations (
  id uuid primary key default gen_random_uuid(),
  submission_answer_id uuid references public.submission_answers on delete cascade,
  model_name text,
  model_version text,
  ai_score numeric(7,2),
  ai_confidence numeric(3,2),
  feedback text,
  rationale jsonb,
  created_at timestamptz default now()
);

-- Teacher overrides and audit trail
create table if not exists public.grade_overrides (
  id uuid primary key default gen_random_uuid(),
  submission_answer_id uuid references public.submission_answers on delete cascade,
  overridden_by uuid references auth.users,
  old_score numeric(7,2),
  new_score numeric(7,2),
  reason text,
  created_at timestamptz default now()
);

-- ===========================
-- 9. Skill mastery, analytics and stats
-- ===========================
create table if not exists public.student_skill_mastery (
  student_id uuid references auth.users,
  objective_id uuid references public.learning_objectives,
  mastery_level numeric(3,2) default 0.0 check (mastery_level between 0 and 1),
  attempts int default 0,
  correct int default 0,
  last_updated timestamptz default now(),
  primary key (student_id, objective_id)
);

create table if not exists public.question_stats (
  question_id uuid primary key references public.questions,
  total_attempts int default 0,
  correct_count int default 0,
  avg_score numeric(7,4) default 0,
  last_attempted timestamptz
);

create table if not exists public.submission_analytics (
  id uuid primary key default gen_random_uuid(),
  submission_id uuid references public.submissions,
  metrics jsonb,
  created_at timestamptz default now()
);

-- ===========================
-- 10. AI Recommendations & teacher notes
-- ===========================
create table if not exists public.ai_recommendations (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid references auth.users,
  class_id uuid references public.classes,
  student_id uuid references auth.users,   -- null = group/class
  type text check (type in ('individual','small_group','class')) default 'individual',
  priority int check (priority between 1 and 5) default 3,
  title text not null,
  description text,
  resources jsonb,
  dismissed boolean default false,
  created_at timestamptz default now()
);

create table if not exists public.teacher_notes (
  id uuid primary key default gen_random_uuid(),
  teacher_id uuid references auth.users,
  student_id uuid references auth.users,
  content text not null,
  is_private boolean default true,
  created_at timestamptz default now()
);

-- ===========================
-- 11. Indexes / Performance Hints
-- ===========================
create index if not exists idx_classes_teacher on public.classes(teacher_id);
create index if not exists idx_class_members_student on public.class_members(student_id);
create index if not exists idx_questions_author on public.questions(author_id);
create index if not exists idx_assignments_class on public.assignments(class_id);
create index if not exists idx_assignment_questions_assignment on public.assignment_questions(assignment_id);
create index if not exists idx_submissions_student on public.submissions(student_id);
create index if not exists idx_work_sessions_student on public.work_sessions(student_id);
create index if not exists idx_ai_queue_status on public.ai_queue(status);
create index if not exists idx_student_skill on public.student_skill_mastery(student_id);
