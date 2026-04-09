---
phase: 07-ai-analytics-pipeline
plan: "03"
subsystem: database-schema
tags: [migration, postgresql, rls, trigger, notifications, ai-workflow]
dependency_graph:
  requires: []
  provides:
    - work_sessions.status accepts ai_processing and pending_review
    - in_app_notifications table with RLS
    - grade_overrides INSERT triggers student notification
  affects:
    - work_sessions (status constraint extended)
    - grade_overrides (trigger added)
tech_stack:
  added: []
  patterns:
    - PostgreSQL AFTER INSERT trigger with SECURITY DEFINER
    - RLS policies for row-level user isolation
key_files:
  created:
    - db/migrations/007_work_sessions_ai_status.sql
    - db/migrations/007_in_app_notifications.sql
    - db/migrations/007_grade_override_notification_trigger.sql
  modified: []
decisions:
  - SECURITY DEFINER used on fn_notify_grade_override so trigger can INSERT into in_app_notifications regardless of caller's role
  - in_app_notifications uses auth.users FK (not profiles) to match RLS auth.uid() check
  - Trigger truncates question_text to 50 chars to keep notification body readable
metrics:
  duration_seconds: 182
  completed_date: "2026-04-09"
  tasks_completed: 2
  tasks_total: 2
  files_created: 3
  files_modified: 0
requirements: [7-11, 7-04]
---

# Phase 7 Plan 03: DB Schema — work_sessions AI Status + in_app_notifications + Grade Override Trigger Summary

**One-liner:** Extended work_sessions.status CHECK to 5 values (adds ai_processing, pending_review), created in_app_notifications table with RLS, and wired grade_overrides INSERT to auto-notify students via PostgreSQL AFTER INSERT trigger.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Extend work_sessions.status + create in_app_notifications | fa0598f | 007_work_sessions_ai_status.sql, 007_in_app_notifications.sql |
| 2 | Create grade_overrides INSERT trigger for student notification | f253ecd | 007_grade_override_notification_trigger.sql |

## What Was Built

### Task 1: work_sessions.status + in_app_notifications

**007_work_sessions_ai_status.sql:**
- Dropped existing `work_sessions_status_check` constraint
- Added new constraint accepting 5 values: `in_progress`, `submitted`, `ai_processing`, `pending_review`, `graded`
- Zero breaking changes — all existing rows remain valid

**007_in_app_notifications.sql:**
- `CREATE TABLE public.in_app_notifications` with columns: id (uuid PK), user_id (FK auth.users), type (text NOT NULL), title (text NOT NULL), body (text), payload (jsonb), read_at (timestamptz), created_at (timestamptz DEFAULT now())
- RLS enabled: SELECT policy (own rows), UPDATE policy (mark read own rows)
- Composite index on `(user_id, created_at DESC)` for fast per-user notification queries

### Task 2: Grade Override Notification Trigger

**007_grade_override_notification_trigger.sql:**
- `fn_notify_grade_override()` — SECURITY DEFINER function that:
  1. JOINs `submission_answers → work_sessions` to resolve `student_id`
  2. JOINs `assignment_questions → questions` for question text preview
  3. Truncates question text to 50 chars
  4. INSERTs into `in_app_notifications` with `type='grade_override'`, payload containing `submission_answer_id`, `old_score`, `new_score`, `overridden_by`
- `trg_grade_override_notify` — AFTER INSERT ON `grade_overrides`, FOR EACH ROW

## Verification Results

All checks passed against local Supabase (docker `supabase_db_AI_LMS_PRD`):

```
work_sessions_status_check: 5 values (in_progress, submitted, ai_processing, pending_review, graded) ✓
in_app_notifications: table exists, rowsecurity=true ✓
RLS policies: "Users can view own notifications", "Users can update own notifications (mark read)" ✓
trg_grade_override_notify trigger: exists ✓
fn_notify_grade_override function: exists ✓
```

## Deviations from Plan

None — plan executed exactly as written. The `INSERT` in the trigger migration used heredoc via `docker exec` directly due to dollar-quoting syntax requirements in shell, but the deployed SQL is identical to the plan specification.

## Known Stubs

None — this plan is pure DB schema with no Flutter code changes.

## Self-Check: PASSED

- db/migrations/007_work_sessions_ai_status.sql: FOUND
- db/migrations/007_in_app_notifications.sql: FOUND
- db/migrations/007_grade_override_notification_trigger.sql: FOUND
- Commit fa0598f: FOUND (Task 1)
- Commit f253ecd: FOUND (Task 2)
- DB verification: all 5 checks passed
