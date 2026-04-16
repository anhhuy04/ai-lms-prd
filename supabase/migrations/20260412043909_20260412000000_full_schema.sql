-- pg_net extension managed by Supabase cloud (skip)


  create table "public"."ai_evaluations" (
    "id" uuid not null default gen_random_uuid(),
    "submission_answer_id" uuid,
    "model_name" text,
    "model_version" text,
    "ai_score" numeric(7,2),
    "ai_confidence" numeric(3,2),
    "feedback" text,
    "rationale" jsonb,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."ai_queue" (
    "id" uuid not null default gen_random_uuid(),
    "submission_answer_id" uuid,
    "request_type" text default 'score'::text,
    "status" text default 'pending'::text,
    "attempts" integer default 0,
    "payload" jsonb,
    "result" jsonb,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );



  create table "public"."ai_recommendations" (
    "id" uuid not null default gen_random_uuid(),
    "teacher_id" uuid,
    "class_id" uuid,
    "student_id" uuid,
    "type" text default 'individual'::text,
    "priority" integer default 3,
    "title" text not null,
    "description" text,
    "resources" jsonb,
    "dismissed" boolean default false,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."assignment_distributions" (
    "id" uuid not null default gen_random_uuid(),
    "assignment_id" uuid not null,
    "distribution_type" text not null,
    "class_id" uuid,
    "group_id" uuid,
    "student_ids" uuid[],
    "available_from" timestamp with time zone,
    "due_at" timestamp with time zone,
    "time_limit_minutes" integer,
    "allow_late" boolean default true,
    "late_policy" jsonb,
    "created_at" timestamp with time zone default now(),
    "status" text not null default 'active'::text,
    "settings" jsonb default '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true}'::jsonb
      );



  create table "public"."assignment_questions" (
    "id" uuid not null default gen_random_uuid(),
    "assignment_id" uuid not null,
    "question_id" uuid,
    "custom_content" jsonb,
    "points" numeric(7,2) not null default 1,
    "rubric" jsonb,
    "order_idx" integer not null
      );



  create table "public"."assignment_variants" (
    "id" uuid not null default gen_random_uuid(),
    "assignment_id" uuid not null,
    "variant_type" text not null default 'student'::text,
    "student_id" uuid,
    "group_id" uuid,
    "due_at_override" timestamp with time zone,
    "custom_questions" jsonb,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."assignments" (
    "id" uuid not null default gen_random_uuid(),
    "class_id" uuid,
    "teacher_id" uuid not null,
    "title" text not null,
    "description" text,
    "is_published" boolean default false,
    "published_at" timestamp with time zone,
    "total_points" numeric(8,2),
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "default_shuffle_questions" boolean default false,
    "default_shuffle_choices" boolean default false
      );



  create table "public"."autosave_answers" (
    "id" uuid not null default gen_random_uuid(),
    "session_id" uuid,
    "assignment_question_id" uuid,
    "answer_content" jsonb,
    "updated_at" timestamp with time zone default now()
      );



  create table "public"."class_members" (
    "class_id" uuid not null,
    "student_id" uuid not null,
    "role" text default 'student'::text,
    "joined_at" timestamp with time zone default now(),
    "status" text default 'pending'::text
      );



  create table "public"."class_teachers" (
    "id" uuid not null default gen_random_uuid(),
    "class_id" uuid,
    "teacher_id" uuid,
    "role" text default 'teacher'::text
      );



  create table "public"."classes" (
    "id" uuid not null default gen_random_uuid(),
    "school_id" uuid,
    "teacher_id" uuid not null,
    "name" text not null,
    "subject" text,
    "academic_year" text,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "class_settings" jsonb default '{"defaults": {"lock_class": false}, "enrollment": {"qr_code": {"is_active": false, "join_code": null, "expires_at": null, "require_approval": true}, "manual_join_limit": null}, "group_management": {"lock_groups": false, "allow_student_switch": false, "is_visible_to_students": true}, "student_permissions": {"auto_lock_on_submission": false, "can_edit_profile_in_class": true}}'::jsonb
      );



  create table "public"."file_links" (
    "id" uuid not null default gen_random_uuid(),
    "file_id" uuid,
    "target_type" text not null,
    "target_id" uuid not null,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."files" (
    "id" uuid not null default gen_random_uuid(),
    "storage_path" text not null,
    "url" text,
    "filename" text,
    "mime_type" text,
    "size_bytes" bigint,
    "uploaded_by" uuid,
    "metadata" jsonb,
    "created_at" timestamp with time zone default now(),
    "is_deleted" boolean default false
      );



  create table "public"."grade_overrides" (
    "id" uuid not null default gen_random_uuid(),
    "submission_answer_id" uuid not null,
    "overridden_by" uuid not null,
    "old_score" numeric(7,2),
    "new_score" numeric(7,2) not null,
    "reason" text,
    "created_at" timestamp with time zone not null default now()
      );



  create table "public"."group_members" (
    "group_id" uuid not null,
    "student_id" uuid not null,
    "joined_at" timestamp with time zone default now(),
    "role" text default 'member'::text,
    "enrolled_by" uuid
      );



  create table "public"."groups" (
    "id" uuid not null default gen_random_uuid(),
    "class_id" uuid,
    "name" text not null,
    "description" text,
    "created_at" timestamp with time zone default now(),
    "teacher_id" uuid
      );



  create table "public"."learning_objectives" (
    "id" uuid not null default gen_random_uuid(),
    "subject_code" text not null,
    "code" text not null,
    "description" text not null,
    "difficulty" integer,
    "parent_id" uuid,
    "metadata" jsonb,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."profiles" (
    "id" uuid not null,
    "full_name" text,
    "role" text default 'student'::text,
    "avatar_url" text,
    "bio" text,
    "metadata" jsonb,
    "updated_at" timestamp with time zone default now(),
    "phone" text,
    "gender" text
      );



  create table "public"."question_choices" (
    "id" integer not null,
    "question_id" uuid not null,
    "content" jsonb not null,
    "is_correct" boolean default false
      );


alter table "public"."question_choices" enable row level security;


  create table "public"."question_objectives" (
    "question_id" uuid not null,
    "objective_id" uuid not null
      );


alter table "public"."question_objectives" enable row level security;


  create table "public"."question_stats" (
    "question_id" uuid not null,
    "total_attempts" integer default 0,
    "correct_count" integer default 0,
    "avg_score" numeric(7,4) default 0,
    "last_attempted" timestamp with time zone
      );



  create table "public"."questions" (
    "id" uuid not null default gen_random_uuid(),
    "author_id" uuid not null,
    "type" text not null,
    "content" jsonb not null,
    "answer" jsonb,
    "default_points" numeric(7,2) default 1,
    "difficulty" integer,
    "tags" text[],
    "is_public" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


alter table "public"."questions" enable row level security;


  create table "public"."schools" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "domain" text,
    "metadata" jsonb,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."student_skill_mastery" (
    "student_id" uuid not null,
    "objective_id" uuid not null,
    "mastery_level" numeric(3,2) default 0.0,
    "attempts" integer default 0,
    "correct" integer default 0,
    "last_updated" timestamp with time zone default now()
      );



  create table "public"."submission_analytics" (
    "id" uuid not null default gen_random_uuid(),
    "submission_id" uuid,
    "metrics" jsonb,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."submission_answers" (
    "id" uuid not null default gen_random_uuid(),
    "session_id" uuid,
    "assignment_question_id" uuid not null,
    "answer" jsonb not null,
    "files" jsonb,
    "flagged" boolean default false,
    "ai_score" numeric(7,2),
    "ai_confidence" numeric(3,2),
    "final_score" numeric(7,2),
    "ai_feedback" jsonb,
    "teacher_feedback" jsonb,
    "graded_by" uuid,
    "graded_at" timestamp with time zone,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );



  create table "public"."submissions" (
    "id" uuid not null default gen_random_uuid(),
    "assignment_id" uuid,
    "student_id" uuid not null,
    "session_id" uuid,
    "variant_id" uuid,
    "started_at" timestamp with time zone,
    "submitted_at" timestamp with time zone,
    "is_late" boolean default false,
    "total_score" numeric(8,2),
    "ai_graded" boolean default false,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now(),
    "is_voided" boolean default false,
    "assignment_distribution_id" uuid
      );



  create table "public"."teacher_notes" (
    "id" uuid not null default gen_random_uuid(),
    "teacher_id" uuid,
    "student_id" uuid,
    "content" text not null,
    "is_private" boolean default true,
    "created_at" timestamp with time zone default now()
      );



  create table "public"."work_sessions" (
    "id" uuid not null default gen_random_uuid(),
    "assignment_distribution_id" uuid,
    "assignment_id" uuid,
    "student_id" uuid not null,
    "started_at" timestamp with time zone,
    "submitted_at" timestamp with time zone,
    "attempt" integer default 1,
    "status" text default 'in_progress'::text,
    "time_spent_seconds" bigint default 0,
    "created_at" timestamp with time zone default now(),
    "updated_at" timestamp with time zone default now()
      );


CREATE UNIQUE INDEX ai_evaluations_pkey ON public.ai_evaluations USING btree (id);

CREATE UNIQUE INDEX ai_queue_pkey ON public.ai_queue USING btree (id);

CREATE UNIQUE INDEX ai_recommendations_pkey ON public.ai_recommendations USING btree (id);

CREATE UNIQUE INDEX assignment_distributions_pkey ON public.assignment_distributions USING btree (id);

CREATE UNIQUE INDEX assignment_questions_assignment_id_order_idx_key ON public.assignment_questions USING btree (assignment_id, order_idx);

CREATE UNIQUE INDEX assignment_questions_pkey ON public.assignment_questions USING btree (id);

CREATE UNIQUE INDEX assignment_variants_pkey ON public.assignment_variants USING btree (id);

CREATE UNIQUE INDEX assignments_pkey ON public.assignments USING btree (id);

CREATE UNIQUE INDEX autosave_answers_pkey ON public.autosave_answers USING btree (id);

CREATE UNIQUE INDEX class_members_pkey ON public.class_members USING btree (class_id, student_id);

CREATE UNIQUE INDEX class_teachers_pkey ON public.class_teachers USING btree (id);

CREATE UNIQUE INDEX classes_pkey ON public.classes USING btree (id);

CREATE UNIQUE INDEX file_links_pkey ON public.file_links USING btree (id);

CREATE UNIQUE INDEX files_pkey ON public.files USING btree (id);

CREATE UNIQUE INDEX grade_overrides_pkey ON public.grade_overrides USING btree (id);

CREATE UNIQUE INDEX group_members_pkey ON public.group_members USING btree (group_id, student_id);

CREATE UNIQUE INDEX groups_pkey ON public.groups USING btree (id);

CREATE INDEX idx_ai_queue_status ON public.ai_queue USING btree (status);

CREATE INDEX idx_assignment_distributions_assignment ON public.assignment_distributions USING btree (assignment_id);

CREATE INDEX idx_assignment_distributions_available_from ON public.assignment_distributions USING btree (available_from);

CREATE INDEX idx_assignment_distributions_class ON public.assignment_distributions USING btree (class_id);

CREATE INDEX idx_assignment_distributions_due_at ON public.assignment_distributions USING btree (due_at);

CREATE INDEX idx_assignment_distributions_group ON public.assignment_distributions USING btree (group_id);

CREATE INDEX idx_assignment_distributions_student_ids ON public.assignment_distributions USING gin (student_ids);

CREATE INDEX idx_assignment_distributions_type ON public.assignment_distributions USING btree (distribution_type);

CREATE INDEX idx_assignment_questions_assignment ON public.assignment_questions USING btree (assignment_id);

CREATE INDEX idx_assignment_questions_order ON public.assignment_questions USING btree (assignment_id, order_idx);

CREATE INDEX idx_assignment_questions_question ON public.assignment_questions USING btree (question_id);

CREATE INDEX idx_assignment_variants_assignment ON public.assignment_variants USING btree (assignment_id);

CREATE INDEX idx_assignment_variants_group ON public.assignment_variants USING btree (group_id);

CREATE INDEX idx_assignment_variants_student ON public.assignment_variants USING btree (student_id);

CREATE INDEX idx_assignment_variants_type ON public.assignment_variants USING btree (variant_type);

CREATE INDEX idx_assignments_class ON public.assignments USING btree (class_id);

CREATE INDEX idx_assignments_class_teacher_published ON public.assignments USING btree (class_id, teacher_id, is_published);

CREATE INDEX idx_assignments_created_at ON public.assignments USING btree (created_at DESC);

CREATE INDEX idx_assignments_is_published ON public.assignments USING btree (is_published);

CREATE INDEX idx_assignments_teacher ON public.assignments USING btree (teacher_id);

CREATE INDEX idx_class_members_student ON public.class_members USING btree (student_id);

CREATE INDEX idx_class_members_student_id ON public.class_members USING btree (student_id);

CREATE INDEX idx_class_teachers_class_id ON public.class_teachers USING btree (class_id);

CREATE INDEX idx_class_teachers_teacher_id ON public.class_teachers USING btree (teacher_id);

CREATE INDEX idx_classes_join_code ON public.classes USING btree (((((class_settings -> 'enrollment'::text) -> 'qr_code'::text) ->> 'join_code'::text)));

CREATE INDEX idx_classes_school_id ON public.classes USING btree (school_id);

CREATE INDEX idx_classes_teacher ON public.classes USING btree (teacher_id);

CREATE INDEX idx_classes_teacher_id ON public.classes USING btree (teacher_id);

CREATE INDEX idx_group_members_student_id ON public.group_members USING btree (student_id);

CREATE INDEX idx_groups_class_id ON public.groups USING btree (class_id);

CREATE INDEX idx_learning_objectives_parent ON public.learning_objectives USING btree (parent_id);

CREATE INDEX idx_learning_objectives_subject_code ON public.learning_objectives USING btree (subject_code, code);

CREATE INDEX idx_question_choices_order ON public.question_choices USING btree (question_id, id);

CREATE INDEX idx_question_choices_question ON public.question_choices USING btree (question_id);

CREATE INDEX idx_question_objectives_objective ON public.question_objectives USING btree (objective_id);

CREATE INDEX idx_question_objectives_question ON public.question_objectives USING btree (question_id);

CREATE INDEX idx_questions_author ON public.questions USING btree (author_id);

CREATE INDEX idx_questions_author_type_public ON public.questions USING btree (author_id, type, is_public);

CREATE INDEX idx_questions_created_at ON public.questions USING btree (created_at DESC);

CREATE INDEX idx_questions_difficulty ON public.questions USING btree (difficulty);

CREATE INDEX idx_questions_is_public ON public.questions USING btree (is_public);

CREATE INDEX idx_questions_tags ON public.questions USING gin (tags);

CREATE INDEX idx_questions_type ON public.questions USING btree (type);

CREATE INDEX idx_student_skill ON public.student_skill_mastery USING btree (student_id);

CREATE INDEX idx_submissions_distribution ON public.submissions USING btree (assignment_distribution_id);

CREATE INDEX idx_submissions_student ON public.submissions USING btree (student_id);

CREATE INDEX idx_work_sessions_student ON public.work_sessions USING btree (student_id);

CREATE UNIQUE INDEX learning_objectives_pkey ON public.learning_objectives USING btree (id);

CREATE UNIQUE INDEX learning_objectives_subject_code_code_key ON public.learning_objectives USING btree (subject_code, code);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX question_choices_pkey ON public.question_choices USING btree (id, question_id);

CREATE UNIQUE INDEX question_objectives_pkey ON public.question_objectives USING btree (question_id, objective_id);

CREATE UNIQUE INDEX question_stats_pkey ON public.question_stats USING btree (question_id);

CREATE UNIQUE INDEX questions_pkey ON public.questions USING btree (id);

CREATE UNIQUE INDEX schools_domain_key ON public.schools USING btree (domain);

CREATE UNIQUE INDEX schools_pkey ON public.schools USING btree (id);

CREATE UNIQUE INDEX student_skill_mastery_pkey ON public.student_skill_mastery USING btree (student_id, objective_id);

CREATE UNIQUE INDEX submission_analytics_pkey ON public.submission_analytics USING btree (id);

CREATE UNIQUE INDEX submission_answers_pkey ON public.submission_answers USING btree (id);

CREATE UNIQUE INDEX submissions_pkey ON public.submissions USING btree (id);

CREATE UNIQUE INDEX teacher_notes_pkey ON public.teacher_notes USING btree (id);

CREATE UNIQUE INDEX work_sessions_pkey ON public.work_sessions USING btree (id);

alter table "public"."ai_evaluations" add constraint "ai_evaluations_pkey" PRIMARY KEY using index "ai_evaluations_pkey";

alter table "public"."ai_queue" add constraint "ai_queue_pkey" PRIMARY KEY using index "ai_queue_pkey";

alter table "public"."ai_recommendations" add constraint "ai_recommendations_pkey" PRIMARY KEY using index "ai_recommendations_pkey";

alter table "public"."assignment_distributions" add constraint "assignment_distributions_pkey" PRIMARY KEY using index "assignment_distributions_pkey";

alter table "public"."assignment_questions" add constraint "assignment_questions_pkey" PRIMARY KEY using index "assignment_questions_pkey";

alter table "public"."assignment_variants" add constraint "assignment_variants_pkey" PRIMARY KEY using index "assignment_variants_pkey";

alter table "public"."assignments" add constraint "assignments_pkey" PRIMARY KEY using index "assignments_pkey";

alter table "public"."autosave_answers" add constraint "autosave_answers_pkey" PRIMARY KEY using index "autosave_answers_pkey";

alter table "public"."class_members" add constraint "class_members_pkey" PRIMARY KEY using index "class_members_pkey";

alter table "public"."class_teachers" add constraint "class_teachers_pkey" PRIMARY KEY using index "class_teachers_pkey";

alter table "public"."classes" add constraint "classes_pkey" PRIMARY KEY using index "classes_pkey";

alter table "public"."file_links" add constraint "file_links_pkey" PRIMARY KEY using index "file_links_pkey";

alter table "public"."files" add constraint "files_pkey" PRIMARY KEY using index "files_pkey";

alter table "public"."grade_overrides" add constraint "grade_overrides_pkey" PRIMARY KEY using index "grade_overrides_pkey";

alter table "public"."group_members" add constraint "group_members_pkey" PRIMARY KEY using index "group_members_pkey";

alter table "public"."groups" add constraint "groups_pkey" PRIMARY KEY using index "groups_pkey";

alter table "public"."learning_objectives" add constraint "learning_objectives_pkey" PRIMARY KEY using index "learning_objectives_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."question_choices" add constraint "question_choices_pkey" PRIMARY KEY using index "question_choices_pkey";

alter table "public"."question_objectives" add constraint "question_objectives_pkey" PRIMARY KEY using index "question_objectives_pkey";

alter table "public"."question_stats" add constraint "question_stats_pkey" PRIMARY KEY using index "question_stats_pkey";

alter table "public"."questions" add constraint "questions_pkey" PRIMARY KEY using index "questions_pkey";

alter table "public"."schools" add constraint "schools_pkey" PRIMARY KEY using index "schools_pkey";

alter table "public"."student_skill_mastery" add constraint "student_skill_mastery_pkey" PRIMARY KEY using index "student_skill_mastery_pkey";

alter table "public"."submission_analytics" add constraint "submission_analytics_pkey" PRIMARY KEY using index "submission_analytics_pkey";

alter table "public"."submission_answers" add constraint "submission_answers_pkey" PRIMARY KEY using index "submission_answers_pkey";

alter table "public"."submissions" add constraint "submissions_pkey" PRIMARY KEY using index "submissions_pkey";

alter table "public"."teacher_notes" add constraint "teacher_notes_pkey" PRIMARY KEY using index "teacher_notes_pkey";

alter table "public"."work_sessions" add constraint "work_sessions_pkey" PRIMARY KEY using index "work_sessions_pkey";

alter table "public"."ai_evaluations" add constraint "ai_evaluations_submission_answer_id_fkey" FOREIGN KEY (submission_answer_id) REFERENCES public.submission_answers(id) ON DELETE CASCADE not valid;

alter table "public"."ai_evaluations" validate constraint "ai_evaluations_submission_answer_id_fkey";

alter table "public"."ai_queue" add constraint "ai_queue_request_type_check" CHECK ((request_type = ANY (ARRAY['score'::text, 'feedback'::text, 'analysis'::text]))) not valid;

alter table "public"."ai_queue" validate constraint "ai_queue_request_type_check";

alter table "public"."ai_queue" add constraint "ai_queue_submission_answer_id_fkey" FOREIGN KEY (submission_answer_id) REFERENCES public.submission_answers(id) not valid;

alter table "public"."ai_queue" validate constraint "ai_queue_submission_answer_id_fkey";

alter table "public"."ai_recommendations" add constraint "ai_recommendations_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.classes(id) not valid;

alter table "public"."ai_recommendations" validate constraint "ai_recommendations_class_id_fkey";

alter table "public"."ai_recommendations" add constraint "ai_recommendations_priority_check" CHECK (((priority >= 1) AND (priority <= 5))) not valid;

alter table "public"."ai_recommendations" validate constraint "ai_recommendations_priority_check";

alter table "public"."ai_recommendations" add constraint "ai_recommendations_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) not valid;

alter table "public"."ai_recommendations" validate constraint "ai_recommendations_student_id_fkey";

alter table "public"."ai_recommendations" add constraint "ai_recommendations_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES auth.users(id) not valid;

alter table "public"."ai_recommendations" validate constraint "ai_recommendations_teacher_id_fkey";

alter table "public"."ai_recommendations" add constraint "ai_recommendations_type_check" CHECK ((type = ANY (ARRAY['individual'::text, 'small_group'::text, 'class'::text]))) not valid;

alter table "public"."ai_recommendations" validate constraint "ai_recommendations_type_check";

alter table "public"."assignment_distributions" add constraint "assignment_distributions_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) ON DELETE CASCADE not valid;

alter table "public"."assignment_distributions" validate constraint "assignment_distributions_assignment_id_fkey";

alter table "public"."assignment_distributions" add constraint "assignment_distributions_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE not valid;

alter table "public"."assignment_distributions" validate constraint "assignment_distributions_class_id_fkey";

alter table "public"."assignment_distributions" add constraint "assignment_distributions_distribution_type_check" CHECK ((distribution_type = ANY (ARRAY['class'::text, 'group'::text, 'individual'::text]))) not valid;

alter table "public"."assignment_distributions" validate constraint "assignment_distributions_distribution_type_check";

alter table "public"."assignment_distributions" add constraint "assignment_distributions_group_id_fkey" FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE not valid;

alter table "public"."assignment_distributions" validate constraint "assignment_distributions_group_id_fkey";

alter table "public"."assignment_distributions" add constraint "assignment_distributions_status_check" CHECK ((status = ANY (ARRAY['draft'::text, 'scheduled'::text, 'active'::text, 'closed'::text, 'archived'::text]))) not valid;

alter table "public"."assignment_distributions" validate constraint "assignment_distributions_status_check";

alter table "public"."assignment_distributions" add constraint "assignment_distributions_time_limit_minutes_check" CHECK (((time_limit_minutes IS NULL) OR (time_limit_minutes > 0))) not valid;

alter table "public"."assignment_distributions" validate constraint "assignment_distributions_time_limit_minutes_check";

alter table "public"."assignment_distributions" add constraint "check_distribution_type_match" CHECK ((((distribution_type = 'class'::text) AND (class_id IS NOT NULL) AND (group_id IS NULL) AND (student_ids IS NULL)) OR ((distribution_type = 'group'::text) AND (class_id IS NOT NULL) AND (group_id IS NOT NULL) AND (student_ids IS NULL)) OR ((distribution_type = 'individual'::text) AND (class_id IS NOT NULL) AND (student_ids IS NOT NULL) AND (array_length(student_ids, 1) > 0) AND (group_id IS NULL)))) not valid;

alter table "public"."assignment_distributions" validate constraint "check_distribution_type_match";

alter table "public"."assignment_questions" add constraint "assignment_questions_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) ON DELETE CASCADE not valid;

alter table "public"."assignment_questions" validate constraint "assignment_questions_assignment_id_fkey";

alter table "public"."assignment_questions" add constraint "assignment_questions_assignment_id_order_idx_key" UNIQUE using index "assignment_questions_assignment_id_order_idx_key";

alter table "public"."assignment_questions" add constraint "assignment_questions_points_check" CHECK ((points > (0)::numeric)) not valid;

alter table "public"."assignment_questions" validate constraint "assignment_questions_points_check";

alter table "public"."assignment_questions" add constraint "assignment_questions_question_id_fkey" FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE SET NULL not valid;

alter table "public"."assignment_questions" validate constraint "assignment_questions_question_id_fkey";

alter table "public"."assignment_variants" add constraint "assignment_variants_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) ON DELETE CASCADE not valid;

alter table "public"."assignment_variants" validate constraint "assignment_variants_assignment_id_fkey";

alter table "public"."assignment_variants" add constraint "assignment_variants_group_id_fkey" FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE not valid;

alter table "public"."assignment_variants" validate constraint "assignment_variants_group_id_fkey";

alter table "public"."assignment_variants" add constraint "assignment_variants_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."assignment_variants" validate constraint "assignment_variants_student_id_fkey";

alter table "public"."assignment_variants" add constraint "assignment_variants_variant_type_check" CHECK ((variant_type = ANY (ARRAY['student'::text, 'group'::text, 'global'::text]))) not valid;

alter table "public"."assignment_variants" validate constraint "assignment_variants_variant_type_check";

alter table "public"."assignment_variants" add constraint "check_variant_type_match" CHECK ((((variant_type = 'student'::text) AND (student_id IS NOT NULL) AND (group_id IS NULL)) OR ((variant_type = 'group'::text) AND (group_id IS NOT NULL) AND (student_id IS NULL)) OR ((variant_type = 'global'::text) AND (student_id IS NULL) AND (group_id IS NULL)))) not valid;

alter table "public"."assignment_variants" validate constraint "check_variant_type_match";

alter table "public"."assignments" add constraint "assignments_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE not valid;

alter table "public"."assignments" validate constraint "assignments_class_id_fkey";

alter table "public"."assignments" add constraint "assignments_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES auth.users(id) not valid;

alter table "public"."assignments" validate constraint "assignments_teacher_id_fkey";

alter table "public"."assignments" add constraint "assignments_total_points_check" CHECK (((total_points IS NULL) OR (total_points >= (0)::numeric))) not valid;

alter table "public"."assignments" validate constraint "assignments_total_points_check";

alter table "public"."autosave_answers" add constraint "autosave_answers_assignment_question_id_fkey" FOREIGN KEY (assignment_question_id) REFERENCES public.assignment_questions(id) not valid;

alter table "public"."autosave_answers" validate constraint "autosave_answers_assignment_question_id_fkey";

alter table "public"."autosave_answers" add constraint "autosave_answers_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.work_sessions(id) ON DELETE CASCADE not valid;

alter table "public"."autosave_answers" validate constraint "autosave_answers_session_id_fkey";

alter table "public"."class_members" add constraint "class_members_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE not valid;

alter table "public"."class_members" validate constraint "class_members_class_id_fkey";

alter table "public"."class_members" add constraint "class_members_status_check" CHECK ((status = ANY (ARRAY['pending'::text, 'approved'::text, 'rejected'::text]))) not valid;

alter table "public"."class_members" validate constraint "class_members_status_check";

alter table "public"."class_members" add constraint "class_members_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."class_members" validate constraint "class_members_student_id_fkey";

alter table "public"."class_teachers" add constraint "class_teachers_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE not valid;

alter table "public"."class_teachers" validate constraint "class_teachers_class_id_fkey";

alter table "public"."class_teachers" add constraint "class_teachers_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."class_teachers" validate constraint "class_teachers_teacher_id_fkey";

alter table "public"."classes" add constraint "classes_school_id_fkey" FOREIGN KEY (school_id) REFERENCES public.schools(id) not valid;

alter table "public"."classes" validate constraint "classes_school_id_fkey";

alter table "public"."classes" add constraint "classes_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES auth.users(id) not valid;

alter table "public"."classes" validate constraint "classes_teacher_id_fkey";

alter table "public"."file_links" add constraint "file_links_file_id_fkey" FOREIGN KEY (file_id) REFERENCES public.files(id) ON DELETE CASCADE not valid;

alter table "public"."file_links" validate constraint "file_links_file_id_fkey";

alter table "public"."files" add constraint "files_uploaded_by_fkey" FOREIGN KEY (uploaded_by) REFERENCES auth.users(id) not valid;

alter table "public"."files" validate constraint "files_uploaded_by_fkey";

alter table "public"."grade_overrides" add constraint "grade_overrides_overridden_by_fkey" FOREIGN KEY (overridden_by) REFERENCES auth.users(id) not valid;

alter table "public"."grade_overrides" validate constraint "grade_overrides_overridden_by_fkey";

alter table "public"."grade_overrides" add constraint "grade_overrides_submission_answer_id_fkey" FOREIGN KEY (submission_answer_id) REFERENCES public.submission_answers(id) ON DELETE CASCADE not valid;

alter table "public"."grade_overrides" validate constraint "grade_overrides_submission_answer_id_fkey";

alter table "public"."group_members" add constraint "group_members_enrolled_by_fkey" FOREIGN KEY (enrolled_by) REFERENCES auth.users(id) not valid;

alter table "public"."group_members" validate constraint "group_members_enrolled_by_fkey";

alter table "public"."group_members" add constraint "group_members_group_id_fkey" FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE not valid;

alter table "public"."group_members" validate constraint "group_members_group_id_fkey";

alter table "public"."group_members" add constraint "group_members_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."group_members" validate constraint "group_members_student_id_fkey";

alter table "public"."groups" add constraint "groups_class_id_fkey" FOREIGN KEY (class_id) REFERENCES public.classes(id) ON DELETE CASCADE not valid;

alter table "public"."groups" validate constraint "groups_class_id_fkey";

alter table "public"."groups" add constraint "groups_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES auth.users(id) not valid;

alter table "public"."groups" validate constraint "groups_teacher_id_fkey";

alter table "public"."learning_objectives" add constraint "learning_objectives_difficulty_check" CHECK (((difficulty >= 1) AND (difficulty <= 5))) not valid;

alter table "public"."learning_objectives" validate constraint "learning_objectives_difficulty_check";

alter table "public"."learning_objectives" add constraint "learning_objectives_parent_id_fkey" FOREIGN KEY (parent_id) REFERENCES public.learning_objectives(id) ON DELETE SET NULL not valid;

alter table "public"."learning_objectives" validate constraint "learning_objectives_parent_id_fkey";

alter table "public"."learning_objectives" add constraint "learning_objectives_subject_code_code_key" UNIQUE using index "learning_objectives_subject_code_code_key";

alter table "public"."profiles" add constraint "profiles_gender_check" CHECK ((gender = ANY (ARRAY['male'::text, 'female'::text, 'other'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_gender_check";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_role_check" CHECK ((role = ANY (ARRAY['teacher'::text, 'student'::text, 'admin'::text]))) not valid;

alter table "public"."profiles" validate constraint "profiles_role_check";

alter table "public"."question_choices" add constraint "question_choices_id_check" CHECK ((id >= 0)) not valid;

alter table "public"."question_choices" validate constraint "question_choices_id_check";

alter table "public"."question_choices" add constraint "question_choices_question_id_fkey" FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE not valid;

alter table "public"."question_choices" validate constraint "question_choices_question_id_fkey";

alter table "public"."question_objectives" add constraint "question_objectives_objective_id_fkey" FOREIGN KEY (objective_id) REFERENCES public.learning_objectives(id) ON DELETE CASCADE not valid;

alter table "public"."question_objectives" validate constraint "question_objectives_objective_id_fkey";

alter table "public"."question_objectives" add constraint "question_objectives_question_id_fkey" FOREIGN KEY (question_id) REFERENCES public.questions(id) ON DELETE CASCADE not valid;

alter table "public"."question_objectives" validate constraint "question_objectives_question_id_fkey";

alter table "public"."question_stats" add constraint "question_stats_question_id_fkey" FOREIGN KEY (question_id) REFERENCES public.questions(id) not valid;

alter table "public"."question_stats" validate constraint "question_stats_question_id_fkey";

alter table "public"."questions" add constraint "questions_author_id_fkey" FOREIGN KEY (author_id) REFERENCES auth.users(id) not valid;

alter table "public"."questions" validate constraint "questions_author_id_fkey";

alter table "public"."questions" add constraint "questions_default_points_check" CHECK ((default_points > (0)::numeric)) not valid;

alter table "public"."questions" validate constraint "questions_default_points_check";

alter table "public"."questions" add constraint "questions_difficulty_check" CHECK (((difficulty >= 1) AND (difficulty <= 5))) not valid;

alter table "public"."questions" validate constraint "questions_difficulty_check";

alter table "public"."questions" add constraint "questions_type_check" CHECK ((type = ANY (ARRAY['multiple_choice'::text, 'short_answer'::text, 'essay'::text, 'true_false'::text, 'matching'::text, 'problem_solving'::text, 'file_upload'::text, 'fill_in_blank'::text]))) not valid;

alter table "public"."questions" validate constraint "questions_type_check";

alter table "public"."schools" add constraint "schools_domain_key" UNIQUE using index "schools_domain_key";

alter table "public"."student_skill_mastery" add constraint "student_skill_mastery_mastery_level_check" CHECK (((mastery_level >= (0)::numeric) AND (mastery_level <= (1)::numeric))) not valid;

alter table "public"."student_skill_mastery" validate constraint "student_skill_mastery_mastery_level_check";

alter table "public"."student_skill_mastery" add constraint "student_skill_mastery_objective_id_fkey" FOREIGN KEY (objective_id) REFERENCES public.learning_objectives(id) not valid;

alter table "public"."student_skill_mastery" validate constraint "student_skill_mastery_objective_id_fkey";

alter table "public"."student_skill_mastery" add constraint "student_skill_mastery_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) not valid;

alter table "public"."student_skill_mastery" validate constraint "student_skill_mastery_student_id_fkey";

alter table "public"."submission_analytics" add constraint "submission_analytics_submission_id_fkey" FOREIGN KEY (submission_id) REFERENCES public.submissions(id) not valid;

alter table "public"."submission_analytics" validate constraint "submission_analytics_submission_id_fkey";

alter table "public"."submission_answers" add constraint "submission_answers_assignment_question_id_fkey" FOREIGN KEY (assignment_question_id) REFERENCES public.assignment_questions(id) not valid;

alter table "public"."submission_answers" validate constraint "submission_answers_assignment_question_id_fkey";

alter table "public"."submission_answers" add constraint "submission_answers_graded_by_fkey" FOREIGN KEY (graded_by) REFERENCES auth.users(id) not valid;

alter table "public"."submission_answers" validate constraint "submission_answers_graded_by_fkey";

alter table "public"."submission_answers" add constraint "submission_answers_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.work_sessions(id) ON DELETE CASCADE not valid;

alter table "public"."submission_answers" validate constraint "submission_answers_session_id_fkey";

alter table "public"."submissions" add constraint "submissions_assignment_distribution_id_fkey" FOREIGN KEY (assignment_distribution_id) REFERENCES public.assignment_distributions(id) not valid;

alter table "public"."submissions" validate constraint "submissions_assignment_distribution_id_fkey";

alter table "public"."submissions" add constraint "submissions_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) ON DELETE CASCADE not valid;

alter table "public"."submissions" validate constraint "submissions_assignment_id_fkey";

alter table "public"."submissions" add constraint "submissions_session_id_fkey" FOREIGN KEY (session_id) REFERENCES public.work_sessions(id) not valid;

alter table "public"."submissions" validate constraint "submissions_session_id_fkey";

alter table "public"."submissions" add constraint "submissions_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.profiles(id) not valid;

alter table "public"."submissions" validate constraint "submissions_student_id_fkey";

alter table "public"."submissions" add constraint "submissions_variant_id_fkey" FOREIGN KEY (variant_id) REFERENCES public.assignment_variants(id) not valid;

alter table "public"."submissions" validate constraint "submissions_variant_id_fkey";

alter table "public"."teacher_notes" add constraint "teacher_notes_student_id_fkey" FOREIGN KEY (student_id) REFERENCES auth.users(id) not valid;

alter table "public"."teacher_notes" validate constraint "teacher_notes_student_id_fkey";

alter table "public"."teacher_notes" add constraint "teacher_notes_teacher_id_fkey" FOREIGN KEY (teacher_id) REFERENCES auth.users(id) not valid;

alter table "public"."teacher_notes" validate constraint "teacher_notes_teacher_id_fkey";

alter table "public"."work_sessions" add constraint "work_sessions_assignment_distribution_id_fkey" FOREIGN KEY (assignment_distribution_id) REFERENCES public.assignment_distributions(id) not valid;

alter table "public"."work_sessions" validate constraint "work_sessions_assignment_distribution_id_fkey";

alter table "public"."work_sessions" add constraint "work_sessions_assignment_id_fkey" FOREIGN KEY (assignment_id) REFERENCES public.assignments(id) not valid;

alter table "public"."work_sessions" validate constraint "work_sessions_assignment_id_fkey";

alter table "public"."work_sessions" add constraint "work_sessions_status_check" CHECK ((status = ANY (ARRAY['in_progress'::text, 'submitted'::text, 'graded'::text]))) not valid;

alter table "public"."work_sessions" validate constraint "work_sessions_status_check";

alter table "public"."work_sessions" add constraint "work_sessions_student_id_fkey" FOREIGN KEY (student_id) REFERENCES public.profiles(id) not valid;

alter table "public"."work_sessions" validate constraint "work_sessions_student_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_assignment_with_questions(p_teacher_id uuid, p_payload jsonb)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
declare
  v_assignment        jsonb;
  v_questions         jsonb;
  v_assignment_id     uuid;
  v_question          jsonb;
  v_question_id       uuid;
  v_total_points      numeric(8,2);
  v_expected_points   numeric(8,2);
  v_count_questions   integer;
  v_base_content      jsonb;
  v_custom_content    jsonb;
  v_idx               integer;
  v_obj_id_text       text;
  v_order_idx         integer;
begin
  if p_payload is null then
    raise exception 'PAYLOAD_REQUIRED';
  end if;

  v_assignment := coalesce(p_payload->'assignment', '{}'::jsonb);

  if coalesce(v_assignment->>'title', '') = '' then
    raise exception 'ASSIGNMENT_TITLE_REQUIRED';
  end if;

  -- Bước 1: tạo bản ghi assignments (template, is_published = false)
  insert into public.assignments (
    class_id,
    teacher_id,
    title,
    description,
    is_published,
    total_points
  )
  values (
    nullif(v_assignment->>'class_id', '')::uuid,
    p_teacher_id,
    v_assignment->>'title',
    nullif(v_assignment->>'description', ''),
    false,
    case
      when v_assignment ? 'total_points'
        then (v_assignment->>'total_points')::numeric
      else null
    end
  )
  returning id into v_assignment_id;

  -- Bước 2: lặp mảng questions
  v_questions := coalesce(p_payload->'questions', '[]'::jsonb);

  if jsonb_typeof(v_questions) <> 'array' then
    raise exception 'QUESTIONS_MUST_BE_ARRAY';
  end if;

  for v_question in
    select value from jsonb_array_elements(v_questions)
  loop
    -- 2.1 Xác định question_id
    if coalesce(v_question->>'id', '') <> '' then
      -- Reuse câu hỏi có sẵn trong bank
      v_question_id := (v_question->>'id')::uuid;
    else
      -- Câu hỏi mới: insert vào questions (+ objectives, choices nếu có)
      if coalesce(v_question->>'type', '') = '' then
        raise exception 'QUESTION_TYPE_REQUIRED';
      end if;

      insert into public.questions (
        author_id,
        type,
        content,
        answer,
        default_points,
        difficulty,
        tags
      )
      values (
        p_teacher_id,
        v_question->>'type',
        coalesce(v_question->'content', '{}'::jsonb),
        v_question->'answer',
        coalesce((v_question->>'default_points')::numeric, 1),
        case
          when v_question ? 'difficulty'
            then (v_question->>'difficulty')::int
          else null
        end,
        case
          when v_question ? 'tags'
               and jsonb_typeof(v_question->'tags') = 'array'
            then array(
              select jsonb_array_elements_text(v_question->'tags')
            )
          else null
        end
      )
      returning id into v_question_id;

      -- Objectives (mảng uuid text)
      if v_question ? 'objectives'
         and jsonb_typeof(v_question->'objectives') = 'array' then
        for v_obj_id_text in
          select jsonb_array_elements_text(v_question->'objectives')
        loop
          insert into public.question_objectives (question_id, objective_id)
          values (v_question_id, v_obj_id_text::uuid);
        end loop;
      end if;

      -- Choices cho multiple_choice
      if (v_question->>'type') = 'multiple_choice'
         and v_question ? 'choices'
         and jsonb_typeof(v_question->'choices') = 'array' then
        v_idx := 0;
        -- choices là array các object JSON: {text, image_url?, is_correct?}
        for v_custom_content in
          select value from jsonb_array_elements(v_question->'choices')
        loop
          insert into public.question_choices (
            id,
            question_id,
            content,
            is_correct
          )
          values (
            v_idx,
            v_question_id,
            coalesce(v_custom_content->'content', v_custom_content),
            coalesce(
              (v_custom_content->>'is_correct')::boolean,
              (v_custom_content->>'isCorrect')::boolean,
              false
            )
          );
          v_idx := v_idx + 1;
        end loop;
      end if;
    end if;

    -- 2.2 Tính custom_content (override so với content gốc)
    select q.content
    into v_base_content
    from public.questions q
    where q.id = v_question_id;

    v_custom_content := v_question->'custom_content';

    if v_custom_content is null
       or v_custom_content = v_base_content then
      v_custom_content := null;
    end if;

    -- 2.3 Insert vào assignment_questions (the Bridge)
    if not (v_question ? 'order_idx') then
      raise exception 'ORDER_IDX_REQUIRED_FOR_EACH_QUESTION';
    end if;

    v_order_idx := (v_question->>'order_idx')::int;

    insert into public.assignment_questions (
      assignment_id,
      question_id,
      custom_content,
      points,
      rubric,
      order_idx
    )
    values (
      v_assignment_id,
      v_question_id,
      v_custom_content,
      coalesce(
        (v_question->>'points')::numeric,
        (v_question->>'default_points')::numeric,
        1
      ),
      v_question->'rubric',
      v_order_idx
    );
  end loop;

  -- Bước 3: validate assignment_questions & total_points
  select
    count(*)::int,
    coalesce(sum(points), 0)::numeric(8,2)
  into v_count_questions, v_total_points
  from public.assignment_questions
  where assignment_id = v_assignment_id;

  if v_count_questions = 0 then
    raise exception 'ASSIGNMENT_MUST_HAVE_QUESTION';
  end if;

  if v_assignment ? 'total_points' then
    v_expected_points := (v_assignment->>'total_points')::numeric;
    if v_expected_points <> v_total_points then
      raise exception 'TOTAL_POINTS_MISMATCH: expected %, got %',
        v_expected_points, v_total_points;
    end if;
  end if;

  update public.assignments
  set total_points = v_total_points
  where id = v_assignment_id;

  return v_assignment_id;

exception
  when others then
    -- Re-raise với message rõ ràng để client map sang lỗi tiếng Việt
    raise exception 'CREATE_ASSIGNMENT_FAILED: %', sqlerrm
      using errcode = 'P0001';
end;
$function$
;

CREATE OR REPLACE FUNCTION public.create_class_student_variants(p_assignment_id uuid, p_class_id uuid, p_shuffle_questions boolean DEFAULT true, p_shuffle_choices boolean DEFAULT true)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_student RECORD;
    v_count INTEGER := 0;
BEGIN
    FOR v_student IN
        SELECT cm.student_id
        FROM class_members cm
        WHERE cm.class_id = p_class_id
        AND cm.status = 'approved'
    LOOP
        PERFORM create_student_variant(
            p_assignment_id,
            v_student.student_id,
            p_shuffle_questions,
            p_shuffle_choices
        );
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_group_variant(p_assignment_id uuid, p_group_id uuid, p_shuffle_questions boolean DEFAULT true, p_shuffle_choices boolean DEFAULT true)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_variant_id UUID;
    v_questions JSONB;
    v_shuffled_questions JSONB := '[]'::JSONB;
    v_seed BIGINT;
BEGIN
    v_seed := (
        (('x' || substr(md5(p_group_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
        ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
    );

    SELECT jsonb_agg(
        jsonb_build_object(
            'original_assignment_question_id', aq.id,
            'original_question_id', aq.question_id,
            'order_idx', aq.order_idx,
            'points', aq.points,
            'custom_content', aq.custom_content
        ) ORDER BY aq.order_idx
    ) INTO v_questions
    FROM assignment_questions aq
    WHERE aq.assignment_id = p_assignment_id;

    IF v_questions IS NULL THEN
        RAISE EXCEPTION 'No questions found';
    END IF;

    IF p_shuffle_questions AND jsonb_array_length(v_questions) > 1 THEN
        v_shuffled_questions := shuffle_with_seed(v_questions, v_seed);
    ELSE
        v_shuffled_questions := v_questions;
    END IF;

    IF p_shuffle_choices THEN
        v_shuffled_questions := (
            SELECT jsonb_agg(
                jsonb_set(
                    elem,
                    '{custom_content,choices}',
                    shuffle_with_seed(
                        COALESCE(elem->'custom_content'->'choices', '[]'::JSONB),
                        v_seed + (elem->>'order_idx')::BIGINT * 997
                    )
                )
            )
            FROM jsonb_array_elements(v_shuffled_questions) AS elem
        );
    END IF;

    INSERT INTO assignment_variants (
        id,
        assignment_id,
        variant_type,
        group_id,
        custom_questions,
        created_at
    ) VALUES (
        gen_random_uuid(),
        p_assignment_id,
        'group',
        p_group_id,
        jsonb_build_object(
            'questions', v_shuffled_questions,
            'seed', v_seed,
            'shuffle_questions', p_shuffle_questions,
            'shuffle_choices', p_shuffle_choices,
            'generated_at', NOW()::TEXT
        ),
        NOW()
    )
    RETURNING id INTO v_variant_id;

    RETURN v_variant_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_groups_variants(p_assignment_id uuid, p_group_ids uuid[], p_shuffle_questions boolean DEFAULT true, p_shuffle_choices boolean DEFAULT true)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_group_id UUID;
    v_count INTEGER := 0;
BEGIN
    FOREACH v_group_id IN ARRAY p_group_ids
    LOOP
        PERFORM create_group_variant(
            p_assignment_id,
            v_group_id,
            p_shuffle_questions,
            p_shuffle_choices
        );
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_student_variant(p_assignment_id uuid, p_student_id uuid, p_shuffle_questions boolean DEFAULT true, p_shuffle_choices boolean DEFAULT true)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_variant_id UUID;
    v_questions JSONB;
    v_shuffled_questions JSONB := '[]'::JSONB;
    v_seed BIGINT;
    v_question JSONB;
BEGIN
    v_seed := (
        (('x' || substr(md5(p_student_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
        ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
    );

    SELECT jsonb_agg(
        jsonb_build_object(
            'original_assignment_question_id', aq.id,
            'original_question_id', aq.question_id,
            'order_idx', aq.order_idx,
            'points', aq.points,
            'custom_content', aq.custom_content
        ) ORDER BY aq.order_idx
    ) INTO v_questions
    FROM assignment_questions aq
    WHERE aq.assignment_id = p_assignment_id;

    IF v_questions IS NULL OR jsonb_array_length(v_questions) = 0 THEN
        RAISE EXCEPTION 'No questions found for assignment %', p_assignment_id;
    END IF;

    IF p_shuffle_questions AND jsonb_array_length(v_questions) > 1 THEN
        v_shuffled_questions := shuffle_with_seed(v_questions, v_seed);
    ELSE
        v_shuffled_questions := v_questions;
    END IF;

    v_shuffled_questions := (
        SELECT jsonb_agg(
            CASE
                WHEN p_shuffle_choices THEN
                    jsonb_set(
                        elem,
                        '{custom_content,choices}',
                        shuffle_with_seed(
                            COALESCE(elem->'custom_content'->'choices', '[]'::JSONB),
                            v_seed + (elem->>'order_idx')::BIGINT * 997
                        )
                    )
                ELSE
                    elem
            END
        )
        FROM jsonb_array_elements(v_shuffled_questions) AS elem
    );

    INSERT INTO assignment_variants (
        id,
        assignment_id,
        variant_type,
        student_id,
        custom_questions,
        created_at
    ) VALUES (
        gen_random_uuid(),
        p_assignment_id,
        'student',
        p_student_id,
        jsonb_build_object(
            'questions', v_shuffled_questions,
            'seed', v_seed,
            'shuffle_questions', p_shuffle_questions,
            'shuffle_choices', p_shuffle_choices,
            'generated_at', NOW()::TEXT
        ),
        NOW()
    )
    RETURNING id INTO v_variant_id;

    RETURN v_variant_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.create_students_variants(p_assignment_id uuid, p_student_ids uuid[], p_shuffle_questions boolean DEFAULT true, p_shuffle_choices boolean DEFAULT true)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_student_id UUID;
    v_count INTEGER := 0;
BEGIN
    FOREACH v_student_id IN ARRAY p_student_ids
    LOOP
        PERFORM create_student_variant(
            p_assignment_id,
            v_student_id,
            p_shuffle_questions,
            p_shuffle_choices
        );
        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.ensure_student_variant(p_assignment_id uuid, p_student_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_variant_id UUID;
    v_settings JSONB;
    v_shuffle_questions BOOLEAN := false;
    v_shuffle_choices BOOLEAN := false;
    v_existing UUID;
BEGIN
    SELECT id INTO v_existing
    FROM assignment_variants
    WHERE assignment_id = p_assignment_id
    AND (
        (variant_type = 'student' AND student_id = p_student_id)
        OR (variant_type = 'group' AND group_id IN (
            SELECT group_id FROM group_members WHERE student_id = p_student_id
        ))
    )
    LIMIT 1;

    IF v_existing IS NOT NULL THEN
        RETURN v_existing;
    END IF;

    SELECT ad.settings INTO v_settings
    FROM assignment_distributions ad
    WHERE ad.assignment_id = p_assignment_id
    AND (
        (ad.distribution_type = 'individual' AND p_student_id = ANY(ad.student_ids))
        OR
        (ad.distribution_type = 'group' AND EXISTS (
            SELECT 1 FROM group_members gm
            WHERE gm.group_id = ad.group_id
            AND gm.student_id = p_student_id
        ))
        OR
        (ad.distribution_type = 'class' AND EXISTS (
            SELECT 1 FROM class_members cm
            WHERE cm.class_id = ad.class_id
            AND cm.student_id = p_student_id
            AND cm.status = 'approved'
        ))
    )
    ORDER BY
        CASE ad.distribution_type
            WHEN 'individual' THEN 1
            WHEN 'group' THEN 2
            WHEN 'class' THEN 3
        END
    LIMIT 1;

    IF v_settings IS NOT NULL THEN
        v_shuffle_questions := COALESCE((v_settings->>'shuffle_questions')::BOOLEAN, false);
        v_shuffle_choices := COALESCE((v_settings->>'shuffle_choices')::BOOLEAN, false);
    END IF;

    v_variant_id := create_student_variant(
        p_assignment_id,
        p_student_id,
        v_shuffle_questions,
        v_shuffle_choices
    );

    RETURN v_variant_id;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_recalculate_skill_mastery()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  -- Only proceed when final_score actually changed
  IF OLD.final_score IS NOT DISTINCT FROM NEW.final_score THEN
    RETURN NEW;
  END IF;

  -- Full recount: re-aggregate ALL submission_answers for each
  -- (student_id, objective_id) pair affected by this changed row.
  --
  -- Step 1: Identify affected student (via work_sessions) and
  --         affected objective_ids (via assignment_questions → question_objectives).
  -- Step 2: Re-aggregate from scratch and UPSERT.
  --
  -- D-07: aq2.question_id IS NOT NULL — skip custom (ad-hoc) questions.
  -- D-08: final_score IS NOT NULL — 0 counts as attempt (already handled by IS NOT NULL).

  INSERT INTO student_skill_mastery (student_id, objective_id, attempts, correct, mastery_level, last_updated)
  SELECT
    ws2.student_id,
    qo2.objective_id,
    COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL),
    COUNT(*) FILTER (WHERE sa2.final_score = aq2.points AND sa2.final_score IS NOT NULL),
    CASE
      WHEN COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL) = 0 THEN 0
      ELSE COUNT(*) FILTER (WHERE sa2.final_score = aq2.points AND sa2.final_score IS NOT NULL)::numeric
           / COUNT(*) FILTER (WHERE sa2.final_score IS NOT NULL)
    END,
    now()
  FROM submission_answers sa2
  JOIN assignment_questions aq2 ON aq2.id = sa2.assignment_question_id
  JOIN question_objectives qo2  ON qo2.question_id = aq2.question_id
  JOIN work_sessions ws2        ON ws2.id = sa2.session_id
  WHERE ws2.student_id = (
          SELECT ws3.student_id FROM work_sessions ws3 WHERE ws3.id = NEW.session_id
        )
    AND qo2.objective_id IN (
          SELECT qo4.objective_id
          FROM assignment_questions aq4
          JOIN question_objectives qo4 ON qo4.question_id = aq4.question_id
          WHERE aq4.id = NEW.assignment_question_id
        )
    AND aq2.question_id IS NOT NULL
    AND sa2.final_score IS NOT NULL
  GROUP BY ws2.student_id, qo2.objective_id
  ON CONFLICT (student_id, objective_id)
  DO UPDATE SET
    attempts      = EXCLUDED.attempts,
    correct       = EXCLUDED.correct,
    mastery_level = EXCLUDED.mastery_level,
    last_updated  = now();

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_update_question_stats()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
DECLARE
  v_question_id uuid;
  v_points      numeric;
BEGIN
  -- D-06: Skip essay rows where AI has not graded yet
  IF NEW.final_score IS NULL THEN
    RETURN NEW;
  END IF;

  -- Resolve base question_id from assignment_questions (D-07: skip custom ad-hoc questions)
  SELECT question_id, points
    INTO v_question_id, v_points
    FROM assignment_questions
   WHERE id = NEW.assignment_question_id
     AND question_id IS NOT NULL;

  IF v_question_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- UPSERT question_stats
  INSERT INTO question_stats (question_id, total_attempts, correct_count, avg_score, last_attempted)
  VALUES (
    v_question_id,
    1,
    CASE WHEN v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END,
    NEW.final_score,
    now()
  )
  ON CONFLICT (question_id)
  DO UPDATE SET
    total_attempts = question_stats.total_attempts + 1,
    correct_count  = question_stats.correct_count +
                     CASE WHEN v_points > 0 AND NEW.final_score >= v_points THEN 1 ELSE 0 END,
    avg_score      = (question_stats.avg_score * question_stats.total_attempts + NEW.final_score)
                     / (question_stats.total_attempts + 1),
    last_attempted = now();

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_update_skill_mastery()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  -- D-06: Skip essay/fill-blank rows where AI has not graded yet
  IF NEW.final_score IS NULL THEN
    RETURN NEW;
  END IF;

  -- UPSERT student_skill_mastery for each learning objective linked to this question
  -- D-07: AND aq.question_id IS NOT NULL skips custom (ad-hoc) questions
  INSERT INTO student_skill_mastery (student_id, objective_id, attempts, correct, mastery_level, last_updated)
  SELECT
    ws.student_id,
    qo.objective_id,
    1,
    CASE WHEN NEW.final_score = aq.points THEN 1 ELSE 0 END,
    CASE WHEN NEW.final_score = aq.points THEN 1.0 ELSE 0.0 END,
    now()
  FROM work_sessions ws
  JOIN assignment_questions aq ON aq.id = NEW.assignment_question_id
  JOIN question_objectives qo ON qo.question_id = aq.question_id
  WHERE ws.id = NEW.session_id
    AND aq.question_id IS NOT NULL
  ON CONFLICT (student_id, objective_id)
  DO UPDATE SET
    attempts      = student_skill_mastery.attempts + 1,
    correct       = student_skill_mastery.correct +
                    CASE WHEN NEW.final_score = (
                           SELECT points FROM assignment_questions WHERE id = NEW.assignment_question_id
                         )
                         THEN 1 ELSE 0
                    END,
    mastery_level = (
                      student_skill_mastery.correct +
                      CASE WHEN NEW.final_score = (
                             SELECT points FROM assignment_questions WHERE id = NEW.assignment_question_id
                           )
                           THEN 1 ELSE 0
                      END
                    )::numeric / (student_skill_mastery.attempts + 1),
    last_updated  = now();

  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_user_role_safe(user_id uuid DEFAULT auth.uid())
 RETURNS text
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  user_role TEXT;
BEGIN
  -- Tắt RLS trong function để bypass hoàn toàn
  PERFORM set_config('row_security', 'off', false);
  
  -- Query profiles mà không bị ảnh hưởng bởi RLS
  SELECT role INTO user_role
  FROM profiles
  WHERE id = user_id
  LIMIT 1;
  
  RETURN user_role;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
begin
  insert into public.profiles (id, full_name, role, phone, gender)
  values (
    new.id, 
    new.raw_user_meta_data->>'full_name', 
    coalesce(new.raw_user_meta_data->>'role', 'student'),
    new.raw_user_meta_data->>'phone',
    new.raw_user_meta_data->>'gender'
  )
  on conflict (id) do nothing;
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin(user_id uuid DEFAULT auth.uid())
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  RETURN public.get_user_role_safe(user_id) = 'admin';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_assignment_distributed_to_student(assignment_id_param uuid, student_id_param uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  result BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1
    FROM assignment_distributions ad
    JOIN assignments a ON a.id = ad.assignment_id
    WHERE ad.assignment_id = assignment_id_param
      AND a.is_published = true
      AND (
        (ad.distribution_type = 'class' 
          AND ad.class_id IS NOT NULL
          AND public.is_student_in_class(student_id_param, ad.class_id))
        OR
        (ad.distribution_type = 'group'
          AND ad.group_id IS NOT NULL
          AND public.is_student_in_group(student_id_param, ad.group_id))
        OR
        (ad.distribution_type = 'individual'
          AND student_id_param = ANY(ad.student_ids))
      )
      AND (ad.available_from IS NULL OR ad.available_from <= now())
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_student_in_class(student_id uuid, class_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    WHERE cm.student_id = is_student_in_class.student_id
      AND cm.class_id = is_student_in_class.class_id
      AND cm.status = 'approved'
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_student_in_class_any_status(student_id uuid, class_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    WHERE cm.student_id = is_student_in_class_any_status.student_id
      AND cm.class_id = is_student_in_class_any_status.class_id
      AND cm.status IN ('approved', 'pending')
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_student_in_group(student_id uuid, group_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM group_members gm
    WHERE gm.student_id = is_student_in_group.student_id
      AND gm.group_id = is_student_in_group.group_id
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_teacher(user_id uuid DEFAULT auth.uid())
 RETURNS boolean
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  RETURN public.get_user_role_safe(user_id) = 'teacher';
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_teacher_of_student_class(teacher_id uuid, student_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  -- Kiểm tra xem teacher có dạy class nào mà student là member không
  SELECT EXISTS (
    SELECT 1
    FROM class_members cm
    JOIN classes c ON c.id = cm.class_id
    WHERE cm.student_id = is_teacher_of_student_class.student_id
      AND c.teacher_id = is_teacher_of_student_class.teacher_id
      AND cm.status = 'approved'
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_teacher_owner_of_class(teacher_id uuid, class_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  result BOOLEAN;
BEGIN
  -- Bypass RLS bằng cách sử dụng SECURITY DEFINER
  SELECT EXISTS (
    SELECT 1
    FROM classes c
    WHERE c.id = is_teacher_owner_of_class.class_id
      AND c.teacher_id = is_teacher_owner_of_class.teacher_id
  ) INTO result;
  
  RETURN COALESCE(result, false);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.publish_assignment(p_assignment jsonb, p_questions jsonb DEFAULT '[]'::jsonb, p_distributions jsonb DEFAULT '[]'::jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
  v_uid uuid := auth.uid();
  v_is_admin boolean := false;
  v_teacher_id uuid;
  v_assignment_id uuid;
  v_assignment_row public.assignments%rowtype;
  v_class_id uuid;
BEGIN
  -- Auth
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT EXISTS(
    SELECT 1 FROM public.profiles
    WHERE id = v_uid AND role = 'admin'
  ) INTO v_is_admin;

  IF v_is_admin THEN
    v_teacher_id := COALESCE((p_assignment->>'teacher_id')::uuid, v_uid);
  ELSE
    IF NOT EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = v_uid AND role = 'teacher'
    ) THEN
      RAISE EXCEPTION 'Forbidden: only teachers can publish assignments';
    END IF;
    v_teacher_id := v_uid;
  END IF;

  v_class_id := (p_assignment->>'class_id')::uuid;
  IF v_class_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1
      FROM public.classes c
      WHERE c.id = v_class_id
        AND (v_is_admin OR c.teacher_id = v_teacher_id)
    ) THEN
      RAISE EXCEPTION 'Forbidden: class not owned by teacher';
    END IF;
  END IF;

  -- Upsert assignment (meta only, thời gian & allow_late được lưu ở assignment_distributions)
  v_assignment_id := (p_assignment->>'id')::uuid;
  IF v_assignment_id IS NOT NULL THEN
    IF NOT v_is_admin AND NOT EXISTS (
      SELECT 1 FROM public.assignments a
      WHERE a.id = v_assignment_id AND a.teacher_id = v_teacher_id
    ) THEN
      RAISE EXCEPTION 'Forbidden: assignment not owned by teacher';
    END IF;

    UPDATE public.assignments
    SET
      class_id = v_class_id,
      title = COALESCE(p_assignment->>'title', title),
      description = p_assignment->>'description',
      total_points = (p_assignment->>'total_points')::numeric,
      is_published = TRUE,
      published_at = now()
    WHERE id = v_assignment_id
    RETURNING * INTO v_assignment_row;
  ELSE
    INSERT INTO public.assignments (
      class_id,
      teacher_id,
      title,
      description,
      is_published,
      published_at,
      total_points
    ) VALUES (
      v_class_id,
      v_teacher_id,
      COALESCE(p_assignment->>'title', 'Bài tập mới'),
      p_assignment->>'description',
      TRUE,
      now(),
      (p_assignment->>'total_points')::numeric
    )
    RETURNING * INTO v_assignment_row;

    v_assignment_id := v_assignment_row.id;
  END IF;

  -- Replace assignment_questions
  DELETE FROM public.assignment_questions WHERE assignment_id = v_assignment_id;
  IF jsonb_typeof(p_questions) = 'array' AND jsonb_array_length(p_questions) > 0 THEN
    INSERT INTO public.assignment_questions (
      assignment_id,
      question_id,
      custom_content,
      points,
      rubric,
      order_idx
    )
    SELECT
      v_assignment_id,
      (q->>'question_id')::uuid,
      q->'custom_content',
      COALESCE((q->>'points')::numeric, 1),
      q->'rubric',
      (q->>'order_idx')::int
    FROM jsonb_array_elements(p_questions) AS q;
  END IF;

  -- Replace assignment_distributions (lưu thời gian, allow_late, late_policy)
  DELETE FROM public.assignment_distributions WHERE assignment_id = v_assignment_id;
  IF jsonb_typeof(p_distributions) = 'array' AND jsonb_array_length(p_distributions) > 0 THEN
    INSERT INTO public.assignment_distributions (
      assignment_id,
      distribution_type,
      class_id,
      group_id,
      student_ids,
      available_from,
      due_at,
      time_limit_minutes,
      allow_late,
      late_policy
    )
    SELECT
      v_assignment_id,
      (d->>'distribution_type')::text,
      (d->>'class_id')::uuid,
      (d->>'group_id')::uuid,
      CASE
        WHEN d ? 'student_ids' AND d->'student_ids' IS NOT NULL THEN
          ARRAY(
            SELECT jsonb_array_elements_text(d->'student_ids')::uuid
          )
        ELSE NULL
      END,
      (d->>'available_from')::timestamptz,
      (d->>'due_at')::timestamptz,
      (d->>'time_limit_minutes')::int,
      COALESCE((d->>'allow_late')::boolean, TRUE),
      d->'late_policy'
    FROM jsonb_array_elements(p_distributions) AS d;
  END IF;

  SELECT * INTO v_assignment_row FROM public.assignments WHERE id = v_assignment_id;
  RETURN to_jsonb(v_assignment_row);
END;
$function$
;

CREATE OR REPLACE FUNCTION public.shuffle_with_seed(p_array jsonb, p_seed bigint)
 RETURNS jsonb
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
DECLARE
    v_result JSONB;
    v_length INTEGER;
    v_i INTEGER;
    v_j INTEGER;
    v_temp JSONB;
BEGIN
    v_result := p_array;
    v_length := jsonb_array_length(v_result);

    IF v_length <= 1 THEN
        RETURN v_result;
    END IF;

    FOR v_i IN REVERSE v_length - 1 .. 1 LOOP
        v_j := floor(
            ((p_seed + v_i::BIGINT) * 1103515245 + 12345) % 2147483648
        ) % (v_i + 1);

        v_temp := v_result->v_i;
        v_result := jsonb_set(
            jsonb_set(v_result, ARRAY[v_i::TEXT], v_result->v_j),
            ARRAY[v_j::TEXT],
            v_temp
        );
    END LOOP;

    RETURN v_result;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;

grant delete on table "public"."ai_evaluations" to "anon";

grant insert on table "public"."ai_evaluations" to "anon";

grant references on table "public"."ai_evaluations" to "anon";

grant select on table "public"."ai_evaluations" to "anon";

grant trigger on table "public"."ai_evaluations" to "anon";

grant truncate on table "public"."ai_evaluations" to "anon";

grant update on table "public"."ai_evaluations" to "anon";

grant delete on table "public"."ai_evaluations" to "authenticated";

grant insert on table "public"."ai_evaluations" to "authenticated";

grant references on table "public"."ai_evaluations" to "authenticated";

grant select on table "public"."ai_evaluations" to "authenticated";

grant trigger on table "public"."ai_evaluations" to "authenticated";

grant truncate on table "public"."ai_evaluations" to "authenticated";

grant update on table "public"."ai_evaluations" to "authenticated";

grant delete on table "public"."ai_evaluations" to "service_role";

grant insert on table "public"."ai_evaluations" to "service_role";

grant references on table "public"."ai_evaluations" to "service_role";

grant select on table "public"."ai_evaluations" to "service_role";

grant trigger on table "public"."ai_evaluations" to "service_role";

grant truncate on table "public"."ai_evaluations" to "service_role";

grant update on table "public"."ai_evaluations" to "service_role";

grant delete on table "public"."ai_queue" to "anon";

grant insert on table "public"."ai_queue" to "anon";

grant references on table "public"."ai_queue" to "anon";

grant select on table "public"."ai_queue" to "anon";

grant trigger on table "public"."ai_queue" to "anon";

grant truncate on table "public"."ai_queue" to "anon";

grant update on table "public"."ai_queue" to "anon";

grant delete on table "public"."ai_queue" to "authenticated";

grant insert on table "public"."ai_queue" to "authenticated";

grant references on table "public"."ai_queue" to "authenticated";

grant select on table "public"."ai_queue" to "authenticated";

grant trigger on table "public"."ai_queue" to "authenticated";

grant truncate on table "public"."ai_queue" to "authenticated";

grant update on table "public"."ai_queue" to "authenticated";

grant delete on table "public"."ai_queue" to "service_role";

grant insert on table "public"."ai_queue" to "service_role";

grant references on table "public"."ai_queue" to "service_role";

grant select on table "public"."ai_queue" to "service_role";

grant trigger on table "public"."ai_queue" to "service_role";

grant truncate on table "public"."ai_queue" to "service_role";

grant update on table "public"."ai_queue" to "service_role";

grant delete on table "public"."ai_recommendations" to "anon";

grant insert on table "public"."ai_recommendations" to "anon";

grant references on table "public"."ai_recommendations" to "anon";

grant select on table "public"."ai_recommendations" to "anon";

grant trigger on table "public"."ai_recommendations" to "anon";

grant truncate on table "public"."ai_recommendations" to "anon";

grant update on table "public"."ai_recommendations" to "anon";

grant delete on table "public"."ai_recommendations" to "authenticated";

grant insert on table "public"."ai_recommendations" to "authenticated";

grant references on table "public"."ai_recommendations" to "authenticated";

grant select on table "public"."ai_recommendations" to "authenticated";

grant trigger on table "public"."ai_recommendations" to "authenticated";

grant truncate on table "public"."ai_recommendations" to "authenticated";

grant update on table "public"."ai_recommendations" to "authenticated";

grant delete on table "public"."ai_recommendations" to "service_role";

grant insert on table "public"."ai_recommendations" to "service_role";

grant references on table "public"."ai_recommendations" to "service_role";

grant select on table "public"."ai_recommendations" to "service_role";

grant trigger on table "public"."ai_recommendations" to "service_role";

grant truncate on table "public"."ai_recommendations" to "service_role";

grant update on table "public"."ai_recommendations" to "service_role";

grant delete on table "public"."assignment_distributions" to "anon";

grant insert on table "public"."assignment_distributions" to "anon";

grant references on table "public"."assignment_distributions" to "anon";

grant select on table "public"."assignment_distributions" to "anon";

grant trigger on table "public"."assignment_distributions" to "anon";

grant truncate on table "public"."assignment_distributions" to "anon";

grant update on table "public"."assignment_distributions" to "anon";

grant delete on table "public"."assignment_distributions" to "authenticated";

grant insert on table "public"."assignment_distributions" to "authenticated";

grant references on table "public"."assignment_distributions" to "authenticated";

grant select on table "public"."assignment_distributions" to "authenticated";

grant trigger on table "public"."assignment_distributions" to "authenticated";

grant truncate on table "public"."assignment_distributions" to "authenticated";

grant update on table "public"."assignment_distributions" to "authenticated";

grant delete on table "public"."assignment_distributions" to "service_role";

grant insert on table "public"."assignment_distributions" to "service_role";

grant references on table "public"."assignment_distributions" to "service_role";

grant select on table "public"."assignment_distributions" to "service_role";

grant trigger on table "public"."assignment_distributions" to "service_role";

grant truncate on table "public"."assignment_distributions" to "service_role";

grant update on table "public"."assignment_distributions" to "service_role";

grant delete on table "public"."assignment_questions" to "anon";

grant insert on table "public"."assignment_questions" to "anon";

grant references on table "public"."assignment_questions" to "anon";

grant select on table "public"."assignment_questions" to "anon";

grant trigger on table "public"."assignment_questions" to "anon";

grant truncate on table "public"."assignment_questions" to "anon";

grant update on table "public"."assignment_questions" to "anon";

grant delete on table "public"."assignment_questions" to "authenticated";

grant insert on table "public"."assignment_questions" to "authenticated";

grant references on table "public"."assignment_questions" to "authenticated";

grant select on table "public"."assignment_questions" to "authenticated";

grant trigger on table "public"."assignment_questions" to "authenticated";

grant truncate on table "public"."assignment_questions" to "authenticated";

grant update on table "public"."assignment_questions" to "authenticated";

grant delete on table "public"."assignment_questions" to "service_role";

grant insert on table "public"."assignment_questions" to "service_role";

grant references on table "public"."assignment_questions" to "service_role";

grant select on table "public"."assignment_questions" to "service_role";

grant trigger on table "public"."assignment_questions" to "service_role";

grant truncate on table "public"."assignment_questions" to "service_role";

grant update on table "public"."assignment_questions" to "service_role";

grant delete on table "public"."assignment_variants" to "anon";

grant insert on table "public"."assignment_variants" to "anon";

grant references on table "public"."assignment_variants" to "anon";

grant select on table "public"."assignment_variants" to "anon";

grant trigger on table "public"."assignment_variants" to "anon";

grant truncate on table "public"."assignment_variants" to "anon";

grant update on table "public"."assignment_variants" to "anon";

grant delete on table "public"."assignment_variants" to "authenticated";

grant insert on table "public"."assignment_variants" to "authenticated";

grant references on table "public"."assignment_variants" to "authenticated";

grant select on table "public"."assignment_variants" to "authenticated";

grant trigger on table "public"."assignment_variants" to "authenticated";

grant truncate on table "public"."assignment_variants" to "authenticated";

grant update on table "public"."assignment_variants" to "authenticated";

grant delete on table "public"."assignment_variants" to "service_role";

grant insert on table "public"."assignment_variants" to "service_role";

grant references on table "public"."assignment_variants" to "service_role";

grant select on table "public"."assignment_variants" to "service_role";

grant trigger on table "public"."assignment_variants" to "service_role";

grant truncate on table "public"."assignment_variants" to "service_role";

grant update on table "public"."assignment_variants" to "service_role";

grant delete on table "public"."assignments" to "anon";

grant insert on table "public"."assignments" to "anon";

grant references on table "public"."assignments" to "anon";

grant select on table "public"."assignments" to "anon";

grant trigger on table "public"."assignments" to "anon";

grant truncate on table "public"."assignments" to "anon";

grant update on table "public"."assignments" to "anon";

grant delete on table "public"."assignments" to "authenticated";

grant insert on table "public"."assignments" to "authenticated";

grant references on table "public"."assignments" to "authenticated";

grant select on table "public"."assignments" to "authenticated";

grant trigger on table "public"."assignments" to "authenticated";

grant truncate on table "public"."assignments" to "authenticated";

grant update on table "public"."assignments" to "authenticated";

grant delete on table "public"."assignments" to "service_role";

grant insert on table "public"."assignments" to "service_role";

grant references on table "public"."assignments" to "service_role";

grant select on table "public"."assignments" to "service_role";

grant trigger on table "public"."assignments" to "service_role";

grant truncate on table "public"."assignments" to "service_role";

grant update on table "public"."assignments" to "service_role";

grant delete on table "public"."autosave_answers" to "anon";

grant insert on table "public"."autosave_answers" to "anon";

grant references on table "public"."autosave_answers" to "anon";

grant select on table "public"."autosave_answers" to "anon";

grant trigger on table "public"."autosave_answers" to "anon";

grant truncate on table "public"."autosave_answers" to "anon";

grant update on table "public"."autosave_answers" to "anon";

grant delete on table "public"."autosave_answers" to "authenticated";

grant insert on table "public"."autosave_answers" to "authenticated";

grant references on table "public"."autosave_answers" to "authenticated";

grant select on table "public"."autosave_answers" to "authenticated";

grant trigger on table "public"."autosave_answers" to "authenticated";

grant truncate on table "public"."autosave_answers" to "authenticated";

grant update on table "public"."autosave_answers" to "authenticated";

grant delete on table "public"."autosave_answers" to "service_role";

grant insert on table "public"."autosave_answers" to "service_role";

grant references on table "public"."autosave_answers" to "service_role";

grant select on table "public"."autosave_answers" to "service_role";

grant trigger on table "public"."autosave_answers" to "service_role";

grant truncate on table "public"."autosave_answers" to "service_role";

grant update on table "public"."autosave_answers" to "service_role";

grant delete on table "public"."class_members" to "anon";

grant insert on table "public"."class_members" to "anon";

grant references on table "public"."class_members" to "anon";

grant select on table "public"."class_members" to "anon";

grant trigger on table "public"."class_members" to "anon";

grant truncate on table "public"."class_members" to "anon";

grant update on table "public"."class_members" to "anon";

grant delete on table "public"."class_members" to "authenticated";

grant insert on table "public"."class_members" to "authenticated";

grant references on table "public"."class_members" to "authenticated";

grant select on table "public"."class_members" to "authenticated";

grant trigger on table "public"."class_members" to "authenticated";

grant truncate on table "public"."class_members" to "authenticated";

grant update on table "public"."class_members" to "authenticated";

grant delete on table "public"."class_members" to "service_role";

grant insert on table "public"."class_members" to "service_role";

grant references on table "public"."class_members" to "service_role";

grant select on table "public"."class_members" to "service_role";

grant trigger on table "public"."class_members" to "service_role";

grant truncate on table "public"."class_members" to "service_role";

grant update on table "public"."class_members" to "service_role";

grant delete on table "public"."class_teachers" to "anon";

grant insert on table "public"."class_teachers" to "anon";

grant references on table "public"."class_teachers" to "anon";

grant select on table "public"."class_teachers" to "anon";

grant trigger on table "public"."class_teachers" to "anon";

grant truncate on table "public"."class_teachers" to "anon";

grant update on table "public"."class_teachers" to "anon";

grant delete on table "public"."class_teachers" to "authenticated";

grant insert on table "public"."class_teachers" to "authenticated";

grant references on table "public"."class_teachers" to "authenticated";

grant select on table "public"."class_teachers" to "authenticated";

grant trigger on table "public"."class_teachers" to "authenticated";

grant truncate on table "public"."class_teachers" to "authenticated";

grant update on table "public"."class_teachers" to "authenticated";

grant delete on table "public"."class_teachers" to "service_role";

grant insert on table "public"."class_teachers" to "service_role";

grant references on table "public"."class_teachers" to "service_role";

grant select on table "public"."class_teachers" to "service_role";

grant trigger on table "public"."class_teachers" to "service_role";

grant truncate on table "public"."class_teachers" to "service_role";

grant update on table "public"."class_teachers" to "service_role";

grant delete on table "public"."classes" to "anon";

grant insert on table "public"."classes" to "anon";

grant references on table "public"."classes" to "anon";

grant select on table "public"."classes" to "anon";

grant trigger on table "public"."classes" to "anon";

grant truncate on table "public"."classes" to "anon";

grant update on table "public"."classes" to "anon";

grant delete on table "public"."classes" to "authenticated";

grant insert on table "public"."classes" to "authenticated";

grant references on table "public"."classes" to "authenticated";

grant select on table "public"."classes" to "authenticated";

grant trigger on table "public"."classes" to "authenticated";

grant truncate on table "public"."classes" to "authenticated";

grant update on table "public"."classes" to "authenticated";

grant delete on table "public"."classes" to "service_role";

grant insert on table "public"."classes" to "service_role";

grant references on table "public"."classes" to "service_role";

grant select on table "public"."classes" to "service_role";

grant trigger on table "public"."classes" to "service_role";

grant truncate on table "public"."classes" to "service_role";

grant update on table "public"."classes" to "service_role";

grant delete on table "public"."file_links" to "anon";

grant insert on table "public"."file_links" to "anon";

grant references on table "public"."file_links" to "anon";

grant select on table "public"."file_links" to "anon";

grant trigger on table "public"."file_links" to "anon";

grant truncate on table "public"."file_links" to "anon";

grant update on table "public"."file_links" to "anon";

grant delete on table "public"."file_links" to "authenticated";

grant insert on table "public"."file_links" to "authenticated";

grant references on table "public"."file_links" to "authenticated";

grant select on table "public"."file_links" to "authenticated";

grant trigger on table "public"."file_links" to "authenticated";

grant truncate on table "public"."file_links" to "authenticated";

grant update on table "public"."file_links" to "authenticated";

grant delete on table "public"."file_links" to "service_role";

grant insert on table "public"."file_links" to "service_role";

grant references on table "public"."file_links" to "service_role";

grant select on table "public"."file_links" to "service_role";

grant trigger on table "public"."file_links" to "service_role";

grant truncate on table "public"."file_links" to "service_role";

grant update on table "public"."file_links" to "service_role";

grant delete on table "public"."files" to "anon";

grant insert on table "public"."files" to "anon";

grant references on table "public"."files" to "anon";

grant select on table "public"."files" to "anon";

grant trigger on table "public"."files" to "anon";

grant truncate on table "public"."files" to "anon";

grant update on table "public"."files" to "anon";

grant delete on table "public"."files" to "authenticated";

grant insert on table "public"."files" to "authenticated";

grant references on table "public"."files" to "authenticated";

grant select on table "public"."files" to "authenticated";

grant trigger on table "public"."files" to "authenticated";

grant truncate on table "public"."files" to "authenticated";

grant update on table "public"."files" to "authenticated";

grant delete on table "public"."files" to "service_role";

grant insert on table "public"."files" to "service_role";

grant references on table "public"."files" to "service_role";

grant select on table "public"."files" to "service_role";

grant trigger on table "public"."files" to "service_role";

grant truncate on table "public"."files" to "service_role";

grant update on table "public"."files" to "service_role";

grant delete on table "public"."grade_overrides" to "anon";

grant insert on table "public"."grade_overrides" to "anon";

grant references on table "public"."grade_overrides" to "anon";

grant select on table "public"."grade_overrides" to "anon";

grant trigger on table "public"."grade_overrides" to "anon";

grant truncate on table "public"."grade_overrides" to "anon";

grant update on table "public"."grade_overrides" to "anon";

grant delete on table "public"."grade_overrides" to "authenticated";

grant insert on table "public"."grade_overrides" to "authenticated";

grant references on table "public"."grade_overrides" to "authenticated";

grant select on table "public"."grade_overrides" to "authenticated";

grant trigger on table "public"."grade_overrides" to "authenticated";

grant truncate on table "public"."grade_overrides" to "authenticated";

grant update on table "public"."grade_overrides" to "authenticated";

grant delete on table "public"."grade_overrides" to "service_role";

grant insert on table "public"."grade_overrides" to "service_role";

grant references on table "public"."grade_overrides" to "service_role";

grant select on table "public"."grade_overrides" to "service_role";

grant trigger on table "public"."grade_overrides" to "service_role";

grant truncate on table "public"."grade_overrides" to "service_role";

grant update on table "public"."grade_overrides" to "service_role";

grant delete on table "public"."group_members" to "anon";

grant insert on table "public"."group_members" to "anon";

grant references on table "public"."group_members" to "anon";

grant select on table "public"."group_members" to "anon";

grant trigger on table "public"."group_members" to "anon";

grant truncate on table "public"."group_members" to "anon";

grant update on table "public"."group_members" to "anon";

grant delete on table "public"."group_members" to "authenticated";

grant insert on table "public"."group_members" to "authenticated";

grant references on table "public"."group_members" to "authenticated";

grant select on table "public"."group_members" to "authenticated";

grant trigger on table "public"."group_members" to "authenticated";

grant truncate on table "public"."group_members" to "authenticated";

grant update on table "public"."group_members" to "authenticated";

grant delete on table "public"."group_members" to "service_role";

grant insert on table "public"."group_members" to "service_role";

grant references on table "public"."group_members" to "service_role";

grant select on table "public"."group_members" to "service_role";

grant trigger on table "public"."group_members" to "service_role";

grant truncate on table "public"."group_members" to "service_role";

grant update on table "public"."group_members" to "service_role";

grant delete on table "public"."groups" to "anon";

grant insert on table "public"."groups" to "anon";

grant references on table "public"."groups" to "anon";

grant select on table "public"."groups" to "anon";

grant trigger on table "public"."groups" to "anon";

grant truncate on table "public"."groups" to "anon";

grant update on table "public"."groups" to "anon";

grant delete on table "public"."groups" to "authenticated";

grant insert on table "public"."groups" to "authenticated";

grant references on table "public"."groups" to "authenticated";

grant select on table "public"."groups" to "authenticated";

grant trigger on table "public"."groups" to "authenticated";

grant truncate on table "public"."groups" to "authenticated";

grant update on table "public"."groups" to "authenticated";

grant delete on table "public"."groups" to "service_role";

grant insert on table "public"."groups" to "service_role";

grant references on table "public"."groups" to "service_role";

grant select on table "public"."groups" to "service_role";

grant trigger on table "public"."groups" to "service_role";

grant truncate on table "public"."groups" to "service_role";

grant update on table "public"."groups" to "service_role";

grant delete on table "public"."learning_objectives" to "anon";

grant insert on table "public"."learning_objectives" to "anon";

grant references on table "public"."learning_objectives" to "anon";

grant select on table "public"."learning_objectives" to "anon";

grant trigger on table "public"."learning_objectives" to "anon";

grant truncate on table "public"."learning_objectives" to "anon";

grant update on table "public"."learning_objectives" to "anon";

grant delete on table "public"."learning_objectives" to "authenticated";

grant insert on table "public"."learning_objectives" to "authenticated";

grant references on table "public"."learning_objectives" to "authenticated";

grant select on table "public"."learning_objectives" to "authenticated";

grant trigger on table "public"."learning_objectives" to "authenticated";

grant truncate on table "public"."learning_objectives" to "authenticated";

grant update on table "public"."learning_objectives" to "authenticated";

grant delete on table "public"."learning_objectives" to "service_role";

grant insert on table "public"."learning_objectives" to "service_role";

grant references on table "public"."learning_objectives" to "service_role";

grant select on table "public"."learning_objectives" to "service_role";

grant trigger on table "public"."learning_objectives" to "service_role";

grant truncate on table "public"."learning_objectives" to "service_role";

grant update on table "public"."learning_objectives" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."question_choices" to "anon";

grant insert on table "public"."question_choices" to "anon";

grant references on table "public"."question_choices" to "anon";

grant select on table "public"."question_choices" to "anon";

grant trigger on table "public"."question_choices" to "anon";

grant truncate on table "public"."question_choices" to "anon";

grant update on table "public"."question_choices" to "anon";

grant delete on table "public"."question_choices" to "authenticated";

grant insert on table "public"."question_choices" to "authenticated";

grant references on table "public"."question_choices" to "authenticated";

grant select on table "public"."question_choices" to "authenticated";

grant trigger on table "public"."question_choices" to "authenticated";

grant truncate on table "public"."question_choices" to "authenticated";

grant update on table "public"."question_choices" to "authenticated";

grant delete on table "public"."question_choices" to "service_role";

grant insert on table "public"."question_choices" to "service_role";

grant references on table "public"."question_choices" to "service_role";

grant select on table "public"."question_choices" to "service_role";

grant trigger on table "public"."question_choices" to "service_role";

grant truncate on table "public"."question_choices" to "service_role";

grant update on table "public"."question_choices" to "service_role";

grant delete on table "public"."question_objectives" to "anon";

grant insert on table "public"."question_objectives" to "anon";

grant references on table "public"."question_objectives" to "anon";

grant select on table "public"."question_objectives" to "anon";

grant trigger on table "public"."question_objectives" to "anon";

grant truncate on table "public"."question_objectives" to "anon";

grant update on table "public"."question_objectives" to "anon";

grant delete on table "public"."question_objectives" to "authenticated";

grant insert on table "public"."question_objectives" to "authenticated";

grant references on table "public"."question_objectives" to "authenticated";

grant select on table "public"."question_objectives" to "authenticated";

grant trigger on table "public"."question_objectives" to "authenticated";

grant truncate on table "public"."question_objectives" to "authenticated";

grant update on table "public"."question_objectives" to "authenticated";

grant delete on table "public"."question_objectives" to "service_role";

grant insert on table "public"."question_objectives" to "service_role";

grant references on table "public"."question_objectives" to "service_role";

grant select on table "public"."question_objectives" to "service_role";

grant trigger on table "public"."question_objectives" to "service_role";

grant truncate on table "public"."question_objectives" to "service_role";

grant update on table "public"."question_objectives" to "service_role";

grant delete on table "public"."question_stats" to "anon";

grant insert on table "public"."question_stats" to "anon";

grant references on table "public"."question_stats" to "anon";

grant select on table "public"."question_stats" to "anon";

grant trigger on table "public"."question_stats" to "anon";

grant truncate on table "public"."question_stats" to "anon";

grant update on table "public"."question_stats" to "anon";

grant delete on table "public"."question_stats" to "authenticated";

grant insert on table "public"."question_stats" to "authenticated";

grant references on table "public"."question_stats" to "authenticated";

grant select on table "public"."question_stats" to "authenticated";

grant trigger on table "public"."question_stats" to "authenticated";

grant truncate on table "public"."question_stats" to "authenticated";

grant update on table "public"."question_stats" to "authenticated";

grant delete on table "public"."question_stats" to "service_role";

grant insert on table "public"."question_stats" to "service_role";

grant references on table "public"."question_stats" to "service_role";

grant select on table "public"."question_stats" to "service_role";

grant trigger on table "public"."question_stats" to "service_role";

grant truncate on table "public"."question_stats" to "service_role";

grant update on table "public"."question_stats" to "service_role";

grant delete on table "public"."questions" to "anon";

grant insert on table "public"."questions" to "anon";

grant references on table "public"."questions" to "anon";

grant select on table "public"."questions" to "anon";

grant trigger on table "public"."questions" to "anon";

grant truncate on table "public"."questions" to "anon";

grant update on table "public"."questions" to "anon";

grant delete on table "public"."questions" to "authenticated";

grant insert on table "public"."questions" to "authenticated";

grant references on table "public"."questions" to "authenticated";

grant select on table "public"."questions" to "authenticated";

grant trigger on table "public"."questions" to "authenticated";

grant truncate on table "public"."questions" to "authenticated";

grant update on table "public"."questions" to "authenticated";

grant delete on table "public"."questions" to "service_role";

grant insert on table "public"."questions" to "service_role";

grant references on table "public"."questions" to "service_role";

grant select on table "public"."questions" to "service_role";

grant trigger on table "public"."questions" to "service_role";

grant truncate on table "public"."questions" to "service_role";

grant update on table "public"."questions" to "service_role";

grant delete on table "public"."schools" to "anon";

grant insert on table "public"."schools" to "anon";

grant references on table "public"."schools" to "anon";

grant select on table "public"."schools" to "anon";

grant trigger on table "public"."schools" to "anon";

grant truncate on table "public"."schools" to "anon";

grant update on table "public"."schools" to "anon";

grant delete on table "public"."schools" to "authenticated";

grant insert on table "public"."schools" to "authenticated";

grant references on table "public"."schools" to "authenticated";

grant select on table "public"."schools" to "authenticated";

grant trigger on table "public"."schools" to "authenticated";

grant truncate on table "public"."schools" to "authenticated";

grant update on table "public"."schools" to "authenticated";

grant delete on table "public"."schools" to "service_role";

grant insert on table "public"."schools" to "service_role";

grant references on table "public"."schools" to "service_role";

grant select on table "public"."schools" to "service_role";

grant trigger on table "public"."schools" to "service_role";

grant truncate on table "public"."schools" to "service_role";

grant update on table "public"."schools" to "service_role";

grant delete on table "public"."student_skill_mastery" to "anon";

grant insert on table "public"."student_skill_mastery" to "anon";

grant references on table "public"."student_skill_mastery" to "anon";

grant select on table "public"."student_skill_mastery" to "anon";

grant trigger on table "public"."student_skill_mastery" to "anon";

grant truncate on table "public"."student_skill_mastery" to "anon";

grant update on table "public"."student_skill_mastery" to "anon";

grant delete on table "public"."student_skill_mastery" to "authenticated";

grant insert on table "public"."student_skill_mastery" to "authenticated";

grant references on table "public"."student_skill_mastery" to "authenticated";

grant select on table "public"."student_skill_mastery" to "authenticated";

grant trigger on table "public"."student_skill_mastery" to "authenticated";

grant truncate on table "public"."student_skill_mastery" to "authenticated";

grant update on table "public"."student_skill_mastery" to "authenticated";

grant delete on table "public"."student_skill_mastery" to "service_role";

grant insert on table "public"."student_skill_mastery" to "service_role";

grant references on table "public"."student_skill_mastery" to "service_role";

grant select on table "public"."student_skill_mastery" to "service_role";

grant trigger on table "public"."student_skill_mastery" to "service_role";

grant truncate on table "public"."student_skill_mastery" to "service_role";

grant update on table "public"."student_skill_mastery" to "service_role";

grant delete on table "public"."submission_analytics" to "anon";

grant insert on table "public"."submission_analytics" to "anon";

grant references on table "public"."submission_analytics" to "anon";

grant select on table "public"."submission_analytics" to "anon";

grant trigger on table "public"."submission_analytics" to "anon";

grant truncate on table "public"."submission_analytics" to "anon";

grant update on table "public"."submission_analytics" to "anon";

grant delete on table "public"."submission_analytics" to "authenticated";

grant insert on table "public"."submission_analytics" to "authenticated";

grant references on table "public"."submission_analytics" to "authenticated";

grant select on table "public"."submission_analytics" to "authenticated";

grant trigger on table "public"."submission_analytics" to "authenticated";

grant truncate on table "public"."submission_analytics" to "authenticated";

grant update on table "public"."submission_analytics" to "authenticated";

grant delete on table "public"."submission_analytics" to "service_role";

grant insert on table "public"."submission_analytics" to "service_role";

grant references on table "public"."submission_analytics" to "service_role";

grant select on table "public"."submission_analytics" to "service_role";

grant trigger on table "public"."submission_analytics" to "service_role";

grant truncate on table "public"."submission_analytics" to "service_role";

grant update on table "public"."submission_analytics" to "service_role";

grant delete on table "public"."submission_answers" to "anon";

grant insert on table "public"."submission_answers" to "anon";

grant references on table "public"."submission_answers" to "anon";

grant select on table "public"."submission_answers" to "anon";

grant trigger on table "public"."submission_answers" to "anon";

grant truncate on table "public"."submission_answers" to "anon";

grant update on table "public"."submission_answers" to "anon";

grant delete on table "public"."submission_answers" to "authenticated";

grant insert on table "public"."submission_answers" to "authenticated";

grant references on table "public"."submission_answers" to "authenticated";

grant select on table "public"."submission_answers" to "authenticated";

grant trigger on table "public"."submission_answers" to "authenticated";

grant truncate on table "public"."submission_answers" to "authenticated";

grant update on table "public"."submission_answers" to "authenticated";

grant delete on table "public"."submission_answers" to "service_role";

grant insert on table "public"."submission_answers" to "service_role";

grant references on table "public"."submission_answers" to "service_role";

grant select on table "public"."submission_answers" to "service_role";

grant trigger on table "public"."submission_answers" to "service_role";

grant truncate on table "public"."submission_answers" to "service_role";

grant update on table "public"."submission_answers" to "service_role";

grant delete on table "public"."submissions" to "anon";

grant insert on table "public"."submissions" to "anon";

grant references on table "public"."submissions" to "anon";

grant select on table "public"."submissions" to "anon";

grant trigger on table "public"."submissions" to "anon";

grant truncate on table "public"."submissions" to "anon";

grant update on table "public"."submissions" to "anon";

grant delete on table "public"."submissions" to "authenticated";

grant insert on table "public"."submissions" to "authenticated";

grant references on table "public"."submissions" to "authenticated";

grant select on table "public"."submissions" to "authenticated";

grant trigger on table "public"."submissions" to "authenticated";

grant truncate on table "public"."submissions" to "authenticated";

grant update on table "public"."submissions" to "authenticated";

grant delete on table "public"."submissions" to "service_role";

grant insert on table "public"."submissions" to "service_role";

grant references on table "public"."submissions" to "service_role";

grant select on table "public"."submissions" to "service_role";

grant trigger on table "public"."submissions" to "service_role";

grant truncate on table "public"."submissions" to "service_role";

grant update on table "public"."submissions" to "service_role";

grant delete on table "public"."teacher_notes" to "anon";

grant insert on table "public"."teacher_notes" to "anon";

grant references on table "public"."teacher_notes" to "anon";

grant select on table "public"."teacher_notes" to "anon";

grant trigger on table "public"."teacher_notes" to "anon";

grant truncate on table "public"."teacher_notes" to "anon";

grant update on table "public"."teacher_notes" to "anon";

grant delete on table "public"."teacher_notes" to "authenticated";

grant insert on table "public"."teacher_notes" to "authenticated";

grant references on table "public"."teacher_notes" to "authenticated";

grant select on table "public"."teacher_notes" to "authenticated";

grant trigger on table "public"."teacher_notes" to "authenticated";

grant truncate on table "public"."teacher_notes" to "authenticated";

grant update on table "public"."teacher_notes" to "authenticated";

grant delete on table "public"."teacher_notes" to "service_role";

grant insert on table "public"."teacher_notes" to "service_role";

grant references on table "public"."teacher_notes" to "service_role";

grant select on table "public"."teacher_notes" to "service_role";

grant trigger on table "public"."teacher_notes" to "service_role";

grant truncate on table "public"."teacher_notes" to "service_role";

grant update on table "public"."teacher_notes" to "service_role";

grant delete on table "public"."work_sessions" to "anon";

grant insert on table "public"."work_sessions" to "anon";

grant references on table "public"."work_sessions" to "anon";

grant select on table "public"."work_sessions" to "anon";

grant trigger on table "public"."work_sessions" to "anon";

grant truncate on table "public"."work_sessions" to "anon";

grant update on table "public"."work_sessions" to "anon";

grant delete on table "public"."work_sessions" to "authenticated";

grant insert on table "public"."work_sessions" to "authenticated";

grant references on table "public"."work_sessions" to "authenticated";

grant select on table "public"."work_sessions" to "authenticated";

grant trigger on table "public"."work_sessions" to "authenticated";

grant truncate on table "public"."work_sessions" to "authenticated";

grant update on table "public"."work_sessions" to "authenticated";

grant delete on table "public"."work_sessions" to "service_role";

grant insert on table "public"."work_sessions" to "service_role";

grant references on table "public"."work_sessions" to "service_role";

grant select on table "public"."work_sessions" to "service_role";

grant trigger on table "public"."work_sessions" to "service_role";

grant truncate on table "public"."work_sessions" to "service_role";

grant update on table "public"."work_sessions" to "service_role";


  create policy "Authenticated users can read AI evaluations"
  on "public"."ai_evaluations"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Teachers can manage AI evaluations"
  on "public"."ai_evaluations"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Teachers can manage AI queue"
  on "public"."ai_queue"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Teachers can read AI queue"
  on "public"."ai_queue"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Teachers can manage their ai_recommendations"
  on "public"."ai_recommendations"
  as permissive
  for all
  to authenticated
using ((auth.uid() = teacher_id));



  create policy "Admins can manage all assignment distributions"
  on "public"."assignment_distributions"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Students can view distributions for assigned assignments"
  on "public"."assignment_distributions"
  as permissive
  for select
  to public
using (public.is_assignment_distributed_to_student(assignment_id, auth.uid()));



  create policy "Teachers can manage distributions for own assignments"
  on "public"."assignment_distributions"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = assignment_distributions.assignment_id) AND (a.teacher_id = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = assignment_distributions.assignment_id) AND (a.teacher_id = auth.uid())))));



  create policy "Admins can manage all assignment questions"
  on "public"."assignment_questions"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Students can view questions in assigned assignments"
  on "public"."assignment_questions"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM (public.assignments a
     JOIN public.assignment_distributions ad ON ((ad.assignment_id = a.id)))
  WHERE ((a.id = assignment_questions.assignment_id) AND (a.is_published = true) AND (((ad.distribution_type = 'class'::text) AND (ad.class_id IS NOT NULL) AND public.is_student_in_class(auth.uid(), ad.class_id)) OR ((ad.distribution_type = 'group'::text) AND (ad.group_id IS NOT NULL) AND public.is_student_in_group(auth.uid(), ad.group_id)) OR ((ad.distribution_type = 'individual'::text) AND (auth.uid() = ANY (ad.student_ids)))) AND ((ad.available_from IS NULL) OR (ad.available_from <= now()))))));



  create policy "Teachers can manage questions in own assignments"
  on "public"."assignment_questions"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = assignment_questions.assignment_id) AND (a.teacher_id = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = assignment_questions.assignment_id) AND (a.teacher_id = auth.uid())))));



  create policy "Admins can manage all assignment variants"
  on "public"."assignment_variants"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Students can view own variants"
  on "public"."assignment_variants"
  as permissive
  for select
  to public
using ((((variant_type = 'student'::text) AND (student_id = auth.uid())) OR ((variant_type = 'group'::text) AND public.is_student_in_group(auth.uid(), group_id)) OR ((variant_type = 'global'::text) AND (EXISTS ( SELECT 1
   FROM (public.assignment_distributions ad
     JOIN public.assignments a ON ((a.id = ad.assignment_id)))
  WHERE ((ad.assignment_id = assignment_variants.assignment_id) AND (a.is_published = true) AND (((ad.distribution_type = 'class'::text) AND (ad.class_id IS NOT NULL) AND public.is_student_in_class(auth.uid(), ad.class_id)) OR ((ad.distribution_type = 'group'::text) AND (ad.group_id IS NOT NULL) AND public.is_student_in_group(auth.uid(), ad.group_id)) OR ((ad.distribution_type = 'individual'::text) AND (auth.uid() = ANY (ad.student_ids))))))))));



  create policy "Teachers can manage variants in own assignments"
  on "public"."assignment_variants"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = assignment_variants.assignment_id) AND (a.teacher_id = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = assignment_variants.assignment_id) AND (a.teacher_id = auth.uid())))));



  create policy "Admins can create assignments"
  on "public"."assignments"
  as permissive
  for insert
  to public
with check (public.is_admin(auth.uid()));



  create policy "Admins can delete all assignments"
  on "public"."assignments"
  as permissive
  for delete
  to public
using (public.is_admin(auth.uid()));



  create policy "Admins can update all assignments"
  on "public"."assignments"
  as permissive
  for update
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Admins can view all assignments"
  on "public"."assignments"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Students can view assigned assignments"
  on "public"."assignments"
  as permissive
  for select
  to public
using (public.is_assignment_distributed_to_student(id, auth.uid()));



  create policy "Teachers can create assignments"
  on "public"."assignments"
  as permissive
  for insert
  to public
with check (((teacher_id = auth.uid()) AND ((class_id IS NULL) OR public.is_teacher_owner_of_class(auth.uid(), class_id))));



  create policy "Teachers can delete own unpublished assignments"
  on "public"."assignments"
  as permissive
  for delete
  to public
using (((teacher_id = auth.uid()) AND (is_published = false)));



  create policy "Teachers can update own assignments"
  on "public"."assignments"
  as permissive
  for update
  to public
using ((teacher_id = auth.uid()))
with check ((teacher_id = auth.uid()));



  create policy "Teachers can view own assignments"
  on "public"."assignments"
  as permissive
  for select
  to public
using ((teacher_id = auth.uid()));



  create policy "Users can insert their own autosave_answers"
  on "public"."autosave_answers"
  as permissive
  for insert
  to public
with check ((EXISTS ( SELECT 1
   FROM public.work_sessions ws
  WHERE ((ws.id = autosave_answers.session_id) AND (ws.student_id = auth.uid())))));



  create policy "Users can update their own autosave_answers"
  on "public"."autosave_answers"
  as permissive
  for update
  to public
using ((EXISTS ( SELECT 1
   FROM public.work_sessions ws
  WHERE ((ws.id = autosave_answers.session_id) AND (ws.student_id = auth.uid())))));



  create policy "Users can view their own autosave_answers"
  on "public"."autosave_answers"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.work_sessions ws
  WHERE ((ws.id = autosave_answers.session_id) AND (ws.student_id = auth.uid())))));



  create policy "Admins can manage all class members"
  on "public"."class_members"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Admins can view all class members"
  on "public"."class_members"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Students can view own memberships"
  on "public"."class_members"
  as permissive
  for select
  to public
using ((student_id = auth.uid()));



  create policy "Teachers can manage members of own classes"
  on "public"."class_members"
  as permissive
  for all
  to public
using ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), class_id)))
with check ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), class_id)));



  create policy "Teachers can view members of own classes"
  on "public"."class_members"
  as permissive
  for select
  to public
using ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), class_id)));



  create policy "Admins can manage all class teachers"
  on "public"."class_teachers"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Main teacher can manage class teachers"
  on "public"."class_teachers"
  as permissive
  for all
  to public
using ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), class_id)))
with check ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), class_id)));



  create policy "Admins can manage all classes"
  on "public"."classes"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Admins can view all classes"
  on "public"."classes"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Students can view enrolled classes"
  on "public"."classes"
  as permissive
  for select
  to public
using (public.is_student_in_class_any_status(auth.uid(), id));



  create policy "Teachers can manage own classes"
  on "public"."classes"
  as permissive
  for all
  to public
using ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), id)))
with check ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), id)));



  create policy "Teachers can view own classes"
  on "public"."classes"
  as permissive
  for select
  to public
using ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), id)));



  create policy "Authenticated users can insert file_links"
  on "public"."file_links"
  as permissive
  for insert
  to authenticated
with check (true);



  create policy "Authenticated users can read file_links"
  on "public"."file_links"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Authenticated users can read files"
  on "public"."files"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Users can insert their own files"
  on "public"."files"
  as permissive
  for insert
  to authenticated
with check ((auth.uid() = uploaded_by));



  create policy "Authenticated users can read grade_overrides"
  on "public"."grade_overrides"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Teachers can manage grade_overrides"
  on "public"."grade_overrides"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Admins can manage all group members"
  on "public"."group_members"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Admins can view all group members"
  on "public"."group_members"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Students can view own group memberships"
  on "public"."group_members"
  as permissive
  for select
  to public
using ((student_id = auth.uid()));



  create policy "Teachers can manage members of groups in own classes"
  on "public"."group_members"
  as permissive
  for all
  to public
using ((public.is_teacher(auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.groups g
  WHERE ((g.id = group_members.group_id) AND public.is_teacher_owner_of_class(auth.uid(), g.class_id))))))
with check ((public.is_teacher(auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.groups g
  WHERE ((g.id = group_members.group_id) AND public.is_teacher_owner_of_class(auth.uid(), g.class_id))))));



  create policy "Teachers can view members of groups in own classes"
  on "public"."group_members"
  as permissive
  for select
  to public
using ((public.is_teacher(auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.groups g
  WHERE ((g.id = group_members.group_id) AND public.is_teacher_owner_of_class(auth.uid(), g.class_id))))));



  create policy "Admins can manage all groups"
  on "public"."groups"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Admins can view all groups"
  on "public"."groups"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Students can view groups they belong to"
  on "public"."groups"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.group_members gm
  WHERE ((gm.group_id = groups.id) AND (gm.student_id = auth.uid())))));



  create policy "Teachers can manage groups of own classes"
  on "public"."groups"
  as permissive
  for all
  to public
using ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), class_id)))
with check ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), class_id)));



  create policy "Teachers can view groups of own classes"
  on "public"."groups"
  as permissive
  for select
  to public
using ((public.is_teacher(auth.uid()) AND public.is_teacher_owner_of_class(auth.uid(), class_id)));



  create policy "Anyone can view learning objectives"
  on "public"."learning_objectives"
  as permissive
  for select
  to public
using (true);



  create policy "Teachers and admins can manage learning objectives"
  on "public"."learning_objectives"
  as permissive
  for all
  to public
using ((public.is_teacher(auth.uid()) OR public.is_admin(auth.uid())))
with check ((public.is_teacher(auth.uid()) OR public.is_admin(auth.uid())));



  create policy "Admins can read all profiles"
  on "public"."profiles"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Admins can update all profiles"
  on "public"."profiles"
  as permissive
  for update
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Teachers can read student profiles in their classes"
  on "public"."profiles"
  as permissive
  for select
  to public
using ((public.is_teacher(auth.uid()) AND public.is_teacher_of_student_class(auth.uid(), id)));



  create policy "Users can read own profile"
  on "public"."profiles"
  as permissive
  for select
  to public
using ((auth.uid() = id));



  create policy "Users can update own profile"
  on "public"."profiles"
  as permissive
  for update
  to public
using ((auth.uid() = id))
with check ((auth.uid() = id));



  create policy "Admins can manage all question choices"
  on "public"."question_choices"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Admins can view all question choices"
  on "public"."question_choices"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Anyone can view choices of public questions"
  on "public"."question_choices"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.questions q
  WHERE ((q.id = question_choices.question_id) AND (q.is_public = true)))));



  create policy "Students can view choices in assigned assignments"
  on "public"."question_choices"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM (((public.questions q
     JOIN public.assignment_questions aq ON ((aq.question_id = q.id)))
     JOIN public.assignments a ON ((a.id = aq.assignment_id)))
     JOIN public.assignment_distributions ad ON ((ad.assignment_id = a.id)))
  WHERE ((q.id = question_choices.question_id) AND (a.is_published = true) AND (((ad.distribution_type = 'class'::text) AND (ad.class_id IS NOT NULL) AND public.is_student_in_class(auth.uid(), ad.class_id)) OR ((ad.distribution_type = 'group'::text) AND (ad.group_id IS NOT NULL) AND public.is_student_in_group(auth.uid(), ad.group_id)) OR ((ad.distribution_type = 'individual'::text) AND (auth.uid() = ANY (ad.student_ids)))) AND ((ad.available_from IS NULL) OR (ad.available_from <= now()))))));



  create policy "Teachers can manage choices of own questions"
  on "public"."question_choices"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.questions q
  WHERE ((q.id = question_choices.question_id) AND (q.author_id = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.questions q
  WHERE ((q.id = question_choices.question_id) AND (q.author_id = auth.uid())))));



  create policy "Teachers can view choices of own questions"
  on "public"."question_choices"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.questions q
  WHERE ((q.id = question_choices.question_id) AND (q.author_id = auth.uid())))));



  create policy "Admins can manage all question objectives"
  on "public"."question_objectives"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Anyone can view objectives of public questions"
  on "public"."question_objectives"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.questions q
  WHERE ((q.id = question_objectives.question_id) AND (q.is_public = true)))));



  create policy "Teachers can manage objectives of own questions"
  on "public"."question_objectives"
  as permissive
  for all
  to public
using ((EXISTS ( SELECT 1
   FROM public.questions q
  WHERE ((q.id = question_objectives.question_id) AND (q.author_id = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.questions q
  WHERE ((q.id = question_objectives.question_id) AND (q.author_id = auth.uid())))));



  create policy "Authenticated users can read question_stats"
  on "public"."question_stats"
  as permissive
  for select
  to authenticated
using (true);



  create policy "System can manage question_stats"
  on "public"."question_stats"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Admins can manage all questions"
  on "public"."questions"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Admins can view all questions"
  on "public"."questions"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Anyone can view public questions"
  on "public"."questions"
  as permissive
  for select
  to public
using ((is_public = true));



  create policy "Students can view questions in assigned assignments"
  on "public"."questions"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM ((public.assignment_questions aq
     JOIN public.assignments a ON ((a.id = aq.assignment_id)))
     JOIN public.assignment_distributions ad ON ((ad.assignment_id = a.id)))
  WHERE ((aq.question_id = questions.id) AND (a.is_published = true) AND (((ad.distribution_type = 'class'::text) AND (ad.class_id IS NOT NULL) AND public.is_student_in_class(auth.uid(), ad.class_id)) OR ((ad.distribution_type = 'group'::text) AND (ad.group_id IS NOT NULL) AND public.is_student_in_group(auth.uid(), ad.group_id)) OR ((ad.distribution_type = 'individual'::text) AND (auth.uid() = ANY (ad.student_ids)))) AND ((ad.available_from IS NULL) OR (ad.available_from <= now()))))));



  create policy "Teachers can manage own questions"
  on "public"."questions"
  as permissive
  for all
  to public
using ((author_id = auth.uid()))
with check ((author_id = auth.uid()));



  create policy "Teachers can view own questions"
  on "public"."questions"
  as permissive
  for select
  to public
using ((author_id = auth.uid()));



  create policy "Admins can manage all schools"
  on "public"."schools"
  as permissive
  for all
  to public
using (public.is_admin(auth.uid()))
with check (public.is_admin(auth.uid()));



  create policy "Admins can view all schools"
  on "public"."schools"
  as permissive
  for select
  to public
using (public.is_admin(auth.uid()));



  create policy "Users can view schools they are related to"
  on "public"."schools"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.classes c
  WHERE ((c.school_id = schools.id) AND ((c.teacher_id = auth.uid()) OR public.is_student_in_class_any_status(auth.uid(), c.id))))));



  create policy "Authenticated users can read student_skill_mastery"
  on "public"."student_skill_mastery"
  as permissive
  for select
  to authenticated
using (true);



  create policy "System can manage student_skill_mastery"
  on "public"."student_skill_mastery"
  as permissive
  for all
  to authenticated
using (true);



  create policy "System can manage submission_analytics"
  on "public"."submission_analytics"
  as permissive
  for all
  to authenticated
using (true);



  create policy "Teachers can read submission_analytics"
  on "public"."submission_analytics"
  as permissive
  for select
  to authenticated
using (true);



  create policy "Teachers can update submission_answers"
  on "public"."submission_answers"
  as permissive
  for update
  to public
using ((EXISTS ( SELECT 1
   FROM (public.work_sessions ws
     JOIN public.assignments a ON ((a.id = ws.assignment_id)))
  WHERE ((ws.id = submission_answers.session_id) AND (a.teacher_id = auth.uid())))));



  create policy "Teachers can view submission_answers for their assignments"
  on "public"."submission_answers"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM (public.work_sessions ws
     JOIN public.assignments a ON ((a.id = ws.assignment_id)))
  WHERE ((ws.id = submission_answers.session_id) AND (a.teacher_id = auth.uid())))));



  create policy "Users can insert their own submission_answers"
  on "public"."submission_answers"
  as permissive
  for insert
  to public
with check ((EXISTS ( SELECT 1
   FROM public.work_sessions ws
  WHERE ((ws.id = submission_answers.session_id) AND (ws.student_id = auth.uid())))));



  create policy "Users can view their own submission_answers"
  on "public"."submission_answers"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.work_sessions ws
  WHERE ((ws.id = submission_answers.session_id) AND (ws.student_id = auth.uid())))));



  create policy "Teachers can update submissions"
  on "public"."submissions"
  as permissive
  for update
  to public
using ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = submissions.assignment_id) AND (a.teacher_id = auth.uid())))));



  create policy "Teachers can view submissions for their assignments"
  on "public"."submissions"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = submissions.assignment_id) AND (a.teacher_id = auth.uid())))));



  create policy "Users can insert their own submissions"
  on "public"."submissions"
  as permissive
  for insert
  to public
with check ((auth.uid() = student_id));



  create policy "Users can view their own submissions"
  on "public"."submissions"
  as permissive
  for select
  to public
using ((auth.uid() = student_id));



  create policy "Teachers can manage their teacher_notes"
  on "public"."teacher_notes"
  as permissive
  for all
  to authenticated
using ((auth.uid() = teacher_id));



  create policy "Teachers can view work_sessions for their assignments"
  on "public"."work_sessions"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.assignments a
  WHERE ((a.id = work_sessions.assignment_id) AND (a.teacher_id = auth.uid())))));



  create policy "Users can insert their own work_sessions"
  on "public"."work_sessions"
  as permissive
  for insert
  to public
with check ((auth.uid() = student_id));



  create policy "Users can update their own work_sessions"
  on "public"."work_sessions"
  as permissive
  for update
  to public
using ((auth.uid() = student_id));



  create policy "Users can view their own work_sessions"
  on "public"."work_sessions"
  as permissive
  for select
  to public
using ((auth.uid() = student_id));


CREATE TRIGGER update_assignments_updated_at BEFORE UPDATE ON public.assignments FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_questions_updated_at BEFORE UPDATE ON public.questions FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER trg_sa_01_skill_mastery AFTER INSERT ON public.submission_answers FOR EACH ROW EXECUTE FUNCTION public.fn_update_skill_mastery();

CREATE TRIGGER trg_sa_02_question_stats AFTER INSERT ON public.submission_answers FOR EACH ROW EXECUTE FUNCTION public.fn_update_question_stats();

CREATE TRIGGER trg_sa_update_recalc_mastery AFTER UPDATE OF final_score ON public.submission_answers FOR EACH ROW EXECUTE FUNCTION public.fn_recalculate_skill_mastery();

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


