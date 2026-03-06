# SQL Flow Decisions - AI LMS

> **Last Updated:** 2026-03-06
> **Purpose:** Reference document for all database logic decisions

---

## Overview

This document captures database logic decisions for Flows 1-4 and 6-9.
**Flow 5 (AI Grading)** has been SEPARATED into its own phase for later implementation.

**Total Flows in this document:** 8
- [x] Flow 1: Class Management
- [x] Flow 2: Group Management
- [x] Flow 3: Assignments (MODIFIED)
- [x] Flow 4: Submissions (MODIFIED)
- [ ] Flow 5: AI Grading → **SEPARATED - See Phase XX**
- [x] Flow 6: Learning Objectives & Question Bank
- [x] Flow 7: Files & Attachments
- [x] Flow 8: Analytics & Recommendations
- [x] Flow 9: Teacher Notes

---

## Flow 1: Class Management

### 1.1 Table: `classes`

| Column | Type | Decision |
|--------|------|----------|
| `class_settings` | JSONB | Keep as-is. Use `require_approval` in `qr_code` branch to handle self-enroll flow |
| `manual_join_limit` | JSONB | This IS max_students - no separate column needed |

**Key Decision:** All class configuration stored in JSONB to avoid ALTER TABLE for future settings.

### 1.2 Table: `class_members`

| Column | Action | Rationale |
|--------|--------|-----------|
| `role` | REMOVE | Role lives in `profiles` table, not here |
| `enrolled_by` | **ADD** | uuid - stores who approved the enrollment |
| `join_method` | **ADD** | text - values: 'qr_code', 'manual_add', 'invite_link' |
| `nickname` | DO NOT ADD | Keep table thin - junction table for querying |

### 1.3 Table: `class_teachers`

| Column | Decision |
|--------|----------|
| `role` | Values: 'co_teacher' (full access), 'assistant' (grading only) |
| Multiple teachers | YES - one class can have multiple teachers |

### 1.4 Workflow: Create Class

```sql
-- Teacher creates class
INSERT INTO classes (teacher_id, name, ...)
VALUES ('teacher-uuid', 'Class Name', ...);

-- NO need to insert into class_teachers
-- Query for teacher's classes:
SELECT * FROM classes
WHERE teacher_id = 'my-id'
OR id IN (
  SELECT class_id FROM class_teachers
  WHERE teacher_id = 'my-id'
);
```

### 1.5 Workflow: Student Join Class

```sql
-- Read config
SELECT class_settings->'enrollment'->'qr_code'->'require_approval'
FROM classes WHERE id = 'class-id';

-- If require_approval = true
INSERT INTO class_members (class_id, student_id, status)
VALUES ('class-id', 'student-id', 'pending');

-- If require_approval = false
INSERT INTO class_members (class_id, student_id, status)
VALUES ('class-id', 'student-id', 'approved');
```

---

## Flow 2: Group Management

### 2.1 Table: `groups`

| Column | Action | Rationale |
|--------|--------|-----------|
| `teacher_id` | **REMOVE** | Group belongs to class, not teacher |
| `class_id` | **SET NOT NULL** | No cross-class groups allowed |

**Key Decision:** Groups are scoped to a single class. Cross-class groups would break assignment_distributions and permissions.

### 2.2 Table: `group_members`

| Column | Action | Rationale |
|--------|--------|-----------|
| `role` | **ADD** | text default 'member' - values: 'leader', 'member' |
| `enrolled_by` | **ADD** | uuid - stores who added student to group |
| `status` | DO NOT ADD | Top-down flow - direct insert, no approval |

### 2.3 Workflow

```sql
-- Create group
INSERT INTO groups (class_id, name)
VALUES ('class-id', 'Group Name');

-- Add students (no approval needed)
INSERT INTO group_members (group_id, student_id)
VALUES ('group-id', 'student-id');

-- Student can be in multiple groups in same class
-- PK is (group_id, student_id)
```

---

## Flow 3: Assignments (MODIFIED - 2026-03-06)

### 3.1 Table: `assignments` (Template)

> **MODIFIED:** Removed time/policy columns - now pure template only

| Column | Decision |
|--------|----------|
| `total_points` | Keep (denormalization for read performance) |
| Auto-update | Use Trigger/Transaction when adding/removing questions |
| ~~`due_at`~~ | **REMOVED** - moved to assignment_distributions |
| ~~`available_from`~~ | **REMOVED** - moved to assignment_distributions |
| ~~`time_limit_minutes`~~ | **REMOVED** - moved to assignment_distributions |
| ~~`allow_late`~~ | **REMOVED** - moved to assignment_distributions |

**Key Decision:** Assignments is PURE TEMPLATE - contains only content, no scheduling/policy.

### 3.2 Table: `assignment_questions`

| Column | Purpose |
|--------|---------|
| `custom_content` | Override question content for this specific assignment |
| `rubric` | Override grading rubric for this assignment |

**Key Decision:** Allows teacher to modify question for specific class without affecting other classes.

### 3.3 Table: `assignment_distributions` (Deployment)

> **EXPANDED:** Now contains ALL time and policy information

| Column | Decision |
|--------|----------|
| `distribution_type` | Values: 'class', 'group', 'individual' |
| `due_at` | **NOW CONTAINS** - deadline for this distribution |
| `available_from` | **NOW CONTAINS** - when student can start |
| `time_limit_minutes` | **NOW CONTAINS** - time limit |
| `settings` JSONB | **NOW CONTAINS** - retake_policy, proctoring, etc. |

```
if is_published = false → Draft
if is_published = true AND available_from > NOW() → Scheduled
if NOW() between available_from and due_at → Active
if NOW() > due_at + late_policy → Closed
```

**Settings JSONB:**

```json
{
  "retake_policy": {
    "allow_retake": true,
    "max_attempts": 3,
    "score_calculation": "highest"
  },
  "proctoring": {
    "prevent_leave_app": true,
    "max_violations_allowed": 3,
    "grace_period_seconds": 10
  }
}
```

### 3.4 Table: `assignment_variants`

| Concept | Decision |
|---------|----------|
| `settings.shuffle` | Rule/Configuration only - does NOT create records |
| `assignment_variants` | Execution Result - created when student starts exam |

**Workflow:**

1. **No shuffle** → NO variant record created → use default structure
2. **Shuffle enabled** → Student starts exam → Backend shuffles → INSERT variant with `custom_questions` → "freezes" exam structure for that student

```sql
-- When student starts exam with shuffle
INSERT INTO assignment_variants (assignment_id, variant_type, student_id, custom_questions)
VALUES ('assignment-id', 'student', 'student-id', '[shuffled_question_ids]');
```

### 3.5 Workflow: Create Assignment

```sql
-- Step 1: Create template (PURE - no time/policy)
INSERT INTO assignments (class_id, teacher_id, title, ...)
VALUES ('class-id', 'teacher-id', 'Assignment Title', ...);

-- Step 2: Add questions
INSERT INTO assignment_questions (assignment_id, question_id, points, order_idx)
VALUES
  ('assignment-id', 'question-1', 10, 1),
  ('assignment-id', 'question-2', 10, 2);

-- Step 3: Create distribution (WITH time/policy)
INSERT INTO assignment_distributions (
  assignment_id, distribution_type, class_id,
  due_at, available_from, time_limit_minutes, settings
)
VALUES (
  'assignment-id', 'class', 'class-id',
  '2026-03-01 23:59:00', '2026-02-25 00:00:00', 90,
  '{"retake_policy": {"allow_retake": true, "max_attempts": 3}}'
);

-- Step 4: Publish
UPDATE assignments SET is_published = true WHERE id = 'assignment-id';
```

---

## Flow 4: Submissions (MODIFIED - 2026-03-06)

### 4.1 Table: `work_sessions`

> **MODIFIED:** Removed 'late' from status

| Column | Decision |
|--------|----------|
| Status | ~~'in_progress', 'submitted', 'graded', 'late'~~ → **'in_progress', 'submitted', 'graded'** |
| paused | DO NOT ADD - timer continues when student exits app |
| `attempt` | Counter for retake tracking |

**Rationale (Principle Engineer):**
1. **Mutually Exclusive States** - State machine must be linear: in_progress → submitted → graded
2. **Single Source of Truth** - `is_late` already exists in `submissions` table (computed column)
3. **Frontend render** - Read `submissions.is_late` to display "Nộp muộn" label

### 4.2 Table: `autosave_answers`

| Decision | Implementation |
|----------|-----------------|
| Timing | Debounce 1-2s for text, immediate for multiple choice |
| Cleanup | DELETE after submit in same transaction |

### 4.3 Table: `submission_answers`

| Column | Purpose |
|--------|---------|
| `flagged` | Student marks question for review or suspects error |
| `files` | `[{"file_id": "uuid", "url": "...", "name": "...", "size": 1234}]` |
| `assignment_question_id` | Always reference original question ID, NOT display position |

### 4.4 Table: `submissions`

> **MODIFIED:** is_late logic now only reads from assignment_distributions

| Decision | Rationale |
|----------|------------|
| Created on submit | NOT when starting exam |
| Required | CQRS pattern - enables fast dashboard queries |
| `is_late` | Generated column: `submitted_at > assignment_distributions.due_at` |

### 4.5 Submit Transaction (5 Steps)

```sql
BEGIN;

-- Step 1: Update work session
UPDATE work_sessions
SET status = 'submitted',
    submitted_at = NOW(),
    time_spent_seconds = EXTRACT(EPOCH FROM (NOW() - started_at))
WHERE id = 'session-id';

-- Step 2: Move answers to submission_answers
INSERT INTO submission_answers (session_id, assignment_question_id, answer)
SELECT session_id, assignment_question_id, answer_content
FROM autosave_answers
WHERE session_id = 'session-id';

-- Step 3: Cleanup autosave
DELETE FROM autosave_answers WHERE session_id = 'session-id';

-- Step 4: Create submission summary
INSERT INTO submissions (assignment_id, student_id, session_id, total_score, is_late)
SELECT assignment_id, student_id, id,
       (SELECT SUM(points) FROM submission_answers WHERE session_id = 'session-id'),
       submitted_at > (SELECT due_at FROM assignment_distributions WHERE id = assignment_distribution_id)
FROM work_sessions WHERE id = 'session-id';

-- Step 5: Queue for AI grading (essay questions)
INSERT INTO ai_queue (submission_answer_id, request_type)
SELECT id, 'score'
FROM submission_answers
WHERE session_id = 'session-id'
AND question_type IN ('essay', 'short_answer');

COMMIT;
```

### 4.6 Multi-Stage Scoring

| Stage | Action |
|-------|--------|
| 1. Submit | Auto-grade multiple choice immediately → `final_score`, temp `total_score` |
| 2. Queue | Push essay questions to `ai_queue` |
| 3. Async | AI Worker updates `ai_score`, `final_score` in `submission_answers` |
| 4. Reconcile | Trigger recalculates `submissions.total_score` = SUM(final_score), sets `ai_graded = true` |

### 4.7 Grade Override

Use PostgreSQL Trigger on `grade_overrides`:

```sql
CREATE OR REPLACE FUNCTION handle_grade_override()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE submission_answers
  SET final_score = NEW.new_score,
      updated_at = NOW()
  WHERE id = NEW.submission_answer_id;

  UPDATE submissions
  SET total_score = total_score + (NEW.new_score - NEW.old_score),
      updated_at = NOW()
  WHERE id = (SELECT submission_id FROM submission_answers WHERE id = NEW.submission_answer_id);

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_grade_override
AFTER INSERT ON grade_overrides
FOR EACH ROW EXECUTE PROCEDURE handle_grade_override();
```

---

## Flow 6: Learning Objectives & Question Bank

### 6.1 Table: `learning_objectives`

| Column | Decision |
|--------|----------|
| `subject_code` | Subject identifier (MATH, PHY, ENG...) |
| `code` | Detailed skill code (MATH_ALG_01) |
| UNIQUE | (subject_code, code) - no duplicates |
| `parent_id` | Adjacency List - unlimited tree depth |

**Key Decision:** Hierarchical skill tree using Adjacency List pattern.

### 6.2 Table: `questions`

| Column | Purpose |
|--------|---------|
| `author_id` | Teacher who created the question |
| `is_public` | Flag for community sharing |
| `tags` | `['tag1', 'tag2', ...]` for search |
| `content` | `{"text": "...", "late": "...", "image_urls": ["..."]}` |
| `answer` | `{"keywords": [...], "sample_essay": "..."}` for AI grading |

### 6.3 Table: `question_choices`

| Column | Decision |
|--------|----------|
| `id` | UUID (NOT integer) - for offline-first sync |
| `is_correct` | Allows multiple correct answers |
| Reordering | NOT needed - Frontend handles display order |

### 6.4 Table: `question_objectives`

| Decision | Rationale |
|----------|-----------|
| Many-to-Many | One question can map to multiple objectives |
| NO proficiency_level | Use `difficulty` from questions table |

### 6.5 Workflow: Question Management

| Action | Decision |
|--------|----------|
| **Create** | INSERT questions → choices → objectives |
| **Edit** | Check if in any assignment_questions. If YES → Clone to new version. If NO → UPDATE allowed |
| **Delete** | Soft Delete (`is_deleted = true`). NEVER hard delete if used in assignments |

---

## Flow 7: Files & Attachments

### 7.1 Table: `files`

| Column | Decision |
|--------|----------|
| `storage_path` | Physical location in Storage (REQUIRED) |
| `url` | ONLY for public files (avatars, shared images) |
| `uploaded_by` | auth.users - for RLS security |

**Key Decision:** Private files use Presigned URLs (15 min expiry), NOT static URLs.

### 7.2 Table: `file_links`

| Column | Values |
|--------|--------|
| `target_type` | 'question', 'assignment', 'submission', 'profile', 'group', 'message' |
| Polymorphic | One file can link to multiple targets |

### 7.3 Workflow: Upload

```
1. Client → Backend: Request Presigned Upload URL
2. Client → Supabase Storage: Upload directly
3. Client → Backend: Send storage_path
4. Backend → INSERT files + file_links
```

### 7.4 Workflow: Delete

```
1. Soft delete (is_deleted = true) in files table
2. Cronjob (2 AM): Delete from Storage
3. Storage success → Hard delete from files table
```

### 7.5 Trigger for file_links

```sql
CREATE OR REPLACE FUNCTION handle_target_delete()
RETURNS TRIGGER AS $$
BEGIN
  DELETE FROM file_links
  WHERE target_type = TG_TABLE_NAME
  AND target_id = OLD.id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;
```

### 7.6 Storage Buckets

| Bucket | Contents | Access |
|--------|----------|--------|
| `public-assets` | Avatars, shared question images | No auth required |
| `private-vault` | Submissions, unpublished exams | Auth required |

### 7.7 Naming Convention

```
{target_type}/{target_id}/{uuid}.{extension}
Example: submissions/uuid-bai-nop/uuid-random.pdf
```

**Key Decision:** Original filename stored in `filename` column for UI display. Never use user-provided filename in storage path.

---

## Flow 8: Analytics & Recommendations

### 8.1 Table: `student_skill_mastery`

| Column | Decision |
|--------|----------|
| `mastery_level` | Probability (0-1) calculated using BKT/IRT algorithms |
| `attempts` | Total attempts - no need for separate column |
| Update timing | ASYNC via ai_queue with request_type = 'analysis' |

**Key Decision:** NOT simple correct/attempts ratio. AI calculates probability based on question difficulty.

### 8.2 Table: `question_stats`

| Columns | Decision |
|---------|----------|
| `total_attempts`, `correct_count`, `avg_score` | Keep as-is |
| Dynamic difficulty | Calculate on-the-fly via View |
| Discrimination index | Calculate via weekly cronjob |

### 8.3 Table: `submission_analytics`

**metrics JSONB structure:**

```json
{
  "time_per_question": [10, 45, 30, ...],
  "hesitation_index": 3,
  "proctoring_logs": [{"event": "leave_app", "timestamp": "..."}],
  "on_time": true
}
```

### 8.4 Table: `ai_recommendations`

| Column | Values |
|--------|--------|
| `type` | 'individual', 'small_group', 'class' |
| `priority` | 1 = highest (urgent), 5 = lowest |
| `resources` | `[{"type": "assignment_template", "id": "..."}, {"type": "video_url", "url": "..."}]` |

### 8.5 Workflow: Analytics

| Stage | Action |
|-------|--------|
| Submit | Push to ai_queue (request_type = 'analysis') |
| Worker | Calculate skill mastery, update question_stats |
| Cronjob (2 AM) | AI synthesizes data → generates recommendations |
| Teacher | Review → Accept or Dismiss (with reason) |

**Key Decision:** NOT real-time. Use batch processing to avoid spam.

---

## Flow 9: Teacher Notes

### 9.1 Table: `teacher_notes`

| Column | Action | Purpose |
|--------|--------|---------|
| `class_id` | **ADD** | REQUIRED - distinguishes context for multi-class students |
| `is_private` | Keep | true = only creator reads, false = shared with class teachers |
| `metadata` | **ADD** | JSONB for extensions (parent meetings, etc.) |

**metadata JSONB example:**

```json
{
  "type": "parent_meeting",
  "meeting_date": "2023-10-20",
  "parent_name": "Mr. John"
}
```

### 9.2 Workflow

| Action | Decision |
|--------|----------|
| Create note | NO notification to students (FERPA compliance) |
| Timeline | Use `created_at` for ordering |
| Student leaves class | KEEP notes (data belongs to school) |
| Teacher leaves school | KEEP notes (for new teacher to see history) |

### 9.3 AI Integration

**Key Decision:** Teacher notes provide "Soft Context" for AI recommendations.

Example: Teacher writes "Nam often forgets glasses" → AI recommends "Print assignments with larger font for Nam"

### 9.4 Security (RLS)

```sql
-- Read policy for teacher_notes:
-- 1. Notes I created (teacher_id = my_id) → always readable
-- 2. Notes from others in my class + is_private = false → readable
-- 3. Notes from others + is_private = true → NOT readable

CREATE POLICY "teacher_notes_read_policy" ON teacher_notes
FOR SELECT USING (
  teacher_id = auth.uid()
  OR (
    class_id IN (SELECT class_id FROM class_teachers WHERE teacher_id = auth.uid())
    AND is_private = false
  )
);
```

---

## Database Schema Changes Required

### Add to `class_members`:

```sql
ALTER TABLE class_members
ADD COLUMN IF NOT EXISTS enrolled_by uuid REFERENCES auth.users,
ADD COLUMN IF NOT EXISTS join_method text DEFAULT 'manual_add';
```

### Add to `group_members`:

```sql
ALTER TABLE group_members
ADD COLUMN IF NOT EXISTS role text DEFAULT 'member',
ADD COLUMN IF NOT EXISTS enrolled_by uuid REFERENCES auth.users;
```

### Modify `groups`:

```sql
ALTER TABLE groups DROP COLUMN IF EXISTS teacher_id;
ALTER TABLE groups ALTER COLUMN class_id SET NOT NULL;
```

### Modify `assignments` (Flow 3 - MODIFIED):

```sql
-- REMOVE time/policy columns - they now belong to assignment_distributions
ALTER TABLE assignments
DROP COLUMN IF EXISTS due_at,
DROP COLUMN IF EXISTS available_from,
DROP COLUMN IF EXISTS time_limit_minutes,
DROP COLUMN IF EXISTS allow_late;
```

### Modify `work_sessions` (Flow 4 - MODIFIED):

```sql
-- REMOVE 'late' from status CHECK constraint
ALTER TABLE work_sessions
DROP CONSTRAINT IF EXISTS work_sessions_status_check;

ALTER TABLE work_sessions
ADD CONSTRAINT work_sessions_status_check
CHECK (status IN ('in_progress', 'submitted', 'graded'));
```

### Modify `submissions` (Flow 4 - MODIFIED):

```sql
-- Update is_late to only read from assignment_distributions
ALTER TABLE submissions
DROP COLUMN IF EXISTS is_late;

ALTER TABLE submissions
ADD COLUMN is_late boolean GENERATED ALWAYS AS (
  submitted_at > (
    SELECT due_at FROM assignment_distributions
    WHERE id = submission_answers.assignment_distribution_id
  )
) STORED;
```

### Add to `questions`:

```sql
ALTER TABLE questions ADD COLUMN IF NOT EXISTS is_deleted boolean DEFAULT false;
```

### Add to `teacher_notes`:

```sql
ALTER TABLE teacher_notes
ADD COLUMN IF NOT EXISTS class_id uuid REFERENCES classes(id),
ADD COLUMN IF NOT EXISTS metadata jsonb;
```

### Fix `question_choices`:

```sql
-- Change id from integer to uuid
ALTER TABLE question_choices
ALTER COLUMN id TYPE uuid USING gen_random_uuid();
```

---

## Critical Rules for Backend Developers

1. **Always use Transactions** for multi-step operations
2. **Soft Delete** - never hard delete questions that have been used in assignments
3. **Audit Trail** - preserve historical data
4. **Computed State** - avoid hard-coded status columns with cronjobs
5. **JSONB Settings** - use for extensible configuration
6. **RLS (Row Level Security)** - enforce security at database level, not just application
7. **RLHF** - capture teacher overrides to improve AI
8. **Data Ownership** - data belongs to school, not individuals
9. **Async Processing** - use queues for AI and analytics to avoid blocking user flows
10. **Template vs Deployment** - Assignments is template, Distributions is deployment

---

## AI System Prompt Framework (CO-STAR)

For AI recommendations generation:

- **C**ontext: Learning trajectory data, skill mastery, question stats
- **O**bjective: Generate actionable recommendations for teachers
- **S**tyle: Educational data scientist persona
- **T**one: Professional, actionable
- **A**udience: Teachers
- **R**esponse Format: JSON array matching ai_recommendations schema

---

**Document Complete - Flows 1-4, 6-9 (8 flows)**

**Flow 5 (AI Grading) - SEPARATED into own phase**
