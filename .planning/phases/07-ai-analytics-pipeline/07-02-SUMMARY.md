---
phase: 07-ai-analytics-pipeline
plan: 02
subsystem: database
tags: [postgresql, trigger, question_stats, analytics]
dependency_graph:
  requires: []
  provides: [question_stats auto-population on submission_answers INSERT]
  affects: [analytics dashboards, recommendation algorithms]
tech_stack:
  added: []
  patterns: [AFTER INSERT trigger, SECURITY DEFINER, UPSERT ON CONFLICT]
key_files:
  created:
    - db/migrations/007_question_stats_trigger.sql
  modified: []
decisions:
  - "trg_sa_02_ prefix ensures alphabetical ordering after trg_sa_01_ (skill mastery trigger)"
  - "SECURITY DEFINER used so trigger runs with definer rights regardless of row-level session user"
  - "Running average formula: (avg * n + new_val) / (n + 1) avoids re-reading all history"
  - "D-07 guard: question_id IS NULL check skips custom/inline questions from stats"
metrics:
  duration: "2m 23s"
  completed: "2026-04-09"
  tasks_completed: 1
  files_created: 1
  files_modified: 0
---

# Phase 07 Plan 02: question_stats AFTER INSERT Trigger Summary

**One-liner:** PostgreSQL AFTER INSERT trigger on `submission_answers` that UPSERT-updates `question_stats` (total_attempts, correct_count, running avg_score) for MCQ questions, skipping ungraded essays and custom/inline questions.

## What Was Built

A single SQL migration file deployed to the local Supabase instance that:

1. Creates `fn_update_question_stats()` trigger function (SECURITY DEFINER, plpgsql) with:
   - Guard: `IF NEW.final_score IS NULL THEN RETURN NEW` — skips essays awaiting AI grading
   - Lookup `question_id` + `points` from `assignment_questions` via `assignment_question_id`
   - Guard: `IF v_question_id IS NULL THEN RETURN NEW` — D-07 compliant, skips custom/inline questions
   - Correctness check: `v_is_correct := (NEW.final_score = v_points)`
   - UPSERT into `question_stats` with running average formula

2. Creates trigger `trg_sa_02_question_stats` — AFTER INSERT on `submission_answers` FOR EACH ROW

## Verification Results

Both verified against live local Supabase:
- `SELECT tgname FROM pg_trigger WHERE tgname = 'trg_sa_02_question_stats'` → 1 row
- `SELECT proname FROM pg_proc WHERE proname = 'fn_update_question_stats'` → 1 row

## Decisions Made

| Decision | Rationale |
|----------|-----------|
| `trg_sa_02_` name prefix | Alphabetical ordering ensures skill mastery trigger (`trg_sa_01_`) fires first |
| SECURITY DEFINER | Trigger runs with function owner rights, not session user (safe for analytics writes) |
| Running avg formula | `(old_avg * old_n + new_val) / (old_n + 1)` — O(1) space, no history scan needed |
| D-07 guard for NULL question_id | Custom/inline questions have no entry in `question_stats` (no `question_id` to key on) |
| `NULLIF(v_points, 0)` | Prevents division by zero if points column is ever set to 0 |

## Deviations from Plan

None — plan executed exactly as written. The `DROP TRIGGER IF EXISTS` was added before `CREATE TRIGGER` as a defensive measure for idempotent re-runs (minor enhancement, no behavior change).

## Out-of-Scope Discoveries

The Supabase advisory reported RLS disabled on 28 tables across the entire database. This is a pre-existing condition unrelated to this migration. Logged to deferred items — do not fix in this plan.

## Self-Check: PASSED

- [x] `db/migrations/007_question_stats_trigger.sql` exists and contains all required elements
- [x] Commit `a3b2e77` exists in git log
- [x] Trigger `trg_sa_02_question_stats` verified in pg_trigger
- [x] Function `fn_update_question_stats` verified in pg_proc
- [x] File contains `IF NEW.final_score IS NULL THEN RETURN NEW`
- [x] File contains `IF v_question_id IS NULL THEN RETURN NEW`
- [x] File contains `ON CONFLICT (question_id) DO UPDATE SET`
- [x] File contains `CREATE TRIGGER trg_sa_02_question_stats AFTER INSERT ON submission_answers`
- [x] File contains `SECURITY DEFINER`
