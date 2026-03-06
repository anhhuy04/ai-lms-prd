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

-- Enable RLS
alter table public.files enable row level security;
alter table public.file_links enable row level security;
alter table public.ai_queue enable row level security;
alter table public.ai_evaluations enable row level security;
alter table public.grade_overrides enable row level security;
alter table public.student_skill_mastery enable row level security;
alter table public.question_stats enable row level security;
alter table public.submission_analytics enable row level security;
alter table public.ai_recommendations enable row level security;
alter table public.teacher_notes enable row level security;

-- Disable RLS strictly for these tables to be generally accessible for authenticated users,
-- or create generic permissive policies for authenticated users.
-- For simplicity, since note_sql.txt doesn't specify RLS for these, let's create simple policies.
create policy "Authenticated users can read files" on public.files for select to authenticated using (true);
create policy "Users can insert their own files" on public.files for insert to authenticated with check (auth.uid() = uploaded_by);

create policy "Authenticated users can read file_links" on public.file_links for select to authenticated using (true);
create policy "Authenticated users can insert file_links" on public.file_links for insert to authenticated with check (true);

create policy "Teachers can read AI queue" on public.ai_queue for select to authenticated using (true);
create policy "Teachers can manage AI queue" on public.ai_queue for all to authenticated using (true);

create policy "Authenticated users can read AI evaluations" on public.ai_evaluations for select to authenticated using (true);
create policy "Teachers can manage AI evaluations" on public.ai_evaluations for all to authenticated using (true);

create policy "Authenticated users can read grade_overrides" on public.grade_overrides for select to authenticated using (true);
create policy "Teachers can manage grade_overrides" on public.grade_overrides for all to authenticated using (true);

create policy "Authenticated users can read student_skill_mastery" on public.student_skill_mastery for select to authenticated using (true);
create policy "System can manage student_skill_mastery" on public.student_skill_mastery for all to authenticated using (true);

create policy "Authenticated users can read question_stats" on public.question_stats for select to authenticated using (true);
create policy "System can manage question_stats" on public.question_stats for all to authenticated using (true);

create policy "Teachers can read submission_analytics" on public.submission_analytics for select to authenticated using (true);
create policy "System can manage submission_analytics" on public.submission_analytics for all to authenticated using (true);

create policy "Teachers can manage their ai_recommendations" on public.ai_recommendations for all to authenticated using (auth.uid() = teacher_id);

create policy "Teachers can manage their teacher_notes" on public.teacher_notes for all to authenticated using (auth.uid() = teacher_id);
