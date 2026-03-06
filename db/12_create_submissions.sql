-- ===========================
-- Student workspace / submissions / autosave
-- ===========================

-- Tracking an active work session
create table if not exists public.work_sessions (
  id uuid primary key default gen_random_uuid(),
  assignment_distribution_id uuid references public.assignment_distributions,
  assignment_id uuid references public.assignments,
  student_id uuid references public.profiles(id) not null,
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
  assignment_question_id uuid references public.assignment_questions,
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
  student_id uuid references public.profiles(id) not null,
  session_id uuid references public.work_sessions,
  variant_id uuid references public.assignment_variants,
  started_at timestamptz,
  submitted_at timestamptz,
  is_late boolean default false,
  total_score numeric(8,2),
  ai_graded boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS
alter table public.work_sessions enable row level security;
alter table public.autosave_answers enable row level security;
alter table public.submission_answers enable row level security;
alter table public.submissions enable row level security;

-- Policies for work_sessions
create policy "Users can view their own work_sessions" on public.work_sessions 
for select using (auth.uid() = student_id);

create policy "Teachers can view work_sessions for their assignments" on public.work_sessions 
for select using (
  exists (
    select 1 from public.assignments a 
    where a.id = assignment_id and a.teacher_id = auth.uid()
  )
);

create policy "Users can insert their own work_sessions" on public.work_sessions 
for insert with check (auth.uid() = student_id);

create policy "Users can update their own work_sessions" on public.work_sessions 
for update using (auth.uid() = student_id);

-- Policies for autosave_answers
create policy "Users can view their own autosave_answers" on public.autosave_answers 
for select using (
  exists (
    select 1 from public.work_sessions ws 
    where ws.id = session_id and ws.student_id = auth.uid()
  )
);

create policy "Users can insert their own autosave_answers" on public.autosave_answers 
for insert with check (
  exists (
    select 1 from public.work_sessions ws 
    where ws.id = session_id and ws.student_id = auth.uid()
  )
);

create policy "Users can update their own autosave_answers" on public.autosave_answers 
for update using (
  exists (
    select 1 from public.work_sessions ws 
    where ws.id = session_id and ws.student_id = auth.uid()
  )
);

-- Policies for submission_answers
create policy "Users can view their own submission_answers" on public.submission_answers 
for select using (
  exists (
    select 1 from public.work_sessions ws 
    where ws.id = session_id and ws.student_id = auth.uid()
  )
);

create policy "Teachers can view submission_answers for their assignments" on public.submission_answers 
for select using (
  exists (
    select 1 from public.work_sessions ws
    join public.assignments a on a.id = ws.assignment_id
    where ws.id = session_id and a.teacher_id = auth.uid()
  )
);

create policy "Users can insert their own submission_answers" on public.submission_answers 
for insert with check (
  exists (
    select 1 from public.work_sessions ws 
    where ws.id = session_id and ws.student_id = auth.uid()
  )
);

create policy "Teachers can update submission_answers" on public.submission_answers 
for update using (
  exists (
    select 1 from public.work_sessions ws
    join public.assignments a on a.id = ws.assignment_id
    where ws.id = session_id and a.teacher_id = auth.uid()
  )
);

-- Policies for submissions
create policy "Users can view their own submissions" on public.submissions 
for select using (auth.uid() = student_id);

create policy "Teachers can view submissions for their assignments" on public.submissions 
for select using (
  exists (
    select 1 from public.assignments a 
    where a.id = assignment_id and a.teacher_id = auth.uid()
  )
);

create policy "Users can insert their own submissions" on public.submissions 
for insert with check (auth.uid() = student_id);

create policy "Teachers can update submissions" on public.submissions 
for update using (
  exists (
    select 1 from public.assignments a 
    where a.id = assignment_id and a.teacher_id = auth.uid()
  )
);

-- Add to Realtime Publication if needed (optional for submissions, but good for realtime UI)
alter publication supabase_realtime add table public.submissions;
alter publication supabase_realtime add table public.work_sessions;
