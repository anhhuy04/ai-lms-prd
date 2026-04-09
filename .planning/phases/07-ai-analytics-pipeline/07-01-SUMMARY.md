---
phase: 07-ai-analytics-pipeline
plan: "01"
subsystem: database
tags: [postgresql, triggers, analytics, skill-mastery, plpgsql]
dependency_graph:
  requires: []
  provides: [skill-mastery-pipeline, grade-override-recalc]
  affects: [phase-4-analytics-screens, phase-5-recommendations, 07-02-question-stats, 07-06-uat]
tech_stack:
  added: []
  patterns: [postgresql-trigger, upsert-on-conflict, security-definer, column-level-trigger]
key_files:
  created:
    - db/migrations/007_skill_mastery_trigger.sql
    - db/migrations/007_grade_override_recalc_trigger.sql
  modified: []
decisions:
  - "SECURITY DEFINER on both trigger functions to bypass RLS for analytics writes"
  - "Column-level trigger AFTER UPDATE OF final_score avoids firing on irrelevant updates"
  - "Full recount (not incremental delta) for grade override — prevents drift on concurrent overrides"
  - "fn_update_skill_mastery uses subquery for points lookup in ON CONFLICT block for correctness"
metrics:
  duration: "282 seconds (~5 minutes)"
  completed_date: "2026-04-09"
  tasks_completed: 2
  tasks_total: 2
  files_created: 2
  files_modified: 0
---

# Phase 7 Plan 01: Skill Mastery DB Trigger Pipeline Summary

**One-liner:** PostgreSQL AFTER INSERT + AFTER UPDATE triggers on `submission_answers` that auto-populate `student_skill_mastery` via assignment_questions → question_objectives join chain, with full-recount semantics on grade override.

---

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | AFTER INSERT trigger for skill mastery | 222a734 | db/migrations/007_skill_mastery_trigger.sql |
| 2 | AFTER UPDATE trigger for grade override recalc | d39c682 | db/migrations/007_grade_override_recalc_trigger.sql |

---

## What Was Built

### Task 1 — fn_update_skill_mastery() + trg_sa_01_skill_mastery

**File:** `db/migrations/007_skill_mastery_trigger.sql`

Trigger fires AFTER INSERT on `submission_answers`. Join chain: `work_sessions` (student_id) → `assignment_questions` → `question_objectives` → `learning_objectives`.

Key guards applied:
- **D-06:** `IF NEW.final_score IS NULL THEN RETURN NEW` — skips essay/fill-blank rows awaiting AI grading
- **D-07:** `AND aq.question_id IS NOT NULL` — skips custom (ad-hoc) questions with no question bank link
- **D-08:** `final_score = 0` is NOT NULL, so unanswered questions count as failed attempts (survivorship bias prevention)

UPSERT logic on `(student_id, objective_id)` conflict: increments `attempts + 1`, increments `correct` if full marks, recalculates `mastery_level = correct / attempts`.

Trigger prefix `trg_sa_01_` ensures alphabetical ordering before the question_stats trigger (`trg_sa_02_...`).

### Task 2 — fn_recalculate_skill_mastery() + trg_sa_update_recalc_mastery

**File:** `db/migrations/007_grade_override_recalc_trigger.sql`

Trigger fires AFTER UPDATE OF final_score on `submission_answers` (column-level — avoids unnecessary executions when other columns change).

Key design decisions:
- **D-09:** Full recount semantics — re-aggregates ALL `submission_answers` for the affected `(student_id, objective_id)` pair using `COUNT(*) FILTER` aggregation. Not incremental delta.
- Guard: `IF OLD.final_score IS NOT DISTINCT FROM NEW.final_score THEN RETURN NEW` — no-op when score unchanged.
- Correctly scopes recount to: same student (via `work_sessions.student_id`) AND same objective(s) (via `assignment_questions` → `question_objectives`).

---

## Verification Results

```
-- Both functions with SECURITY DEFINER:
[{"proname":"fn_recalculate_skill_mastery","prosecdef":true},
 {"proname":"fn_update_skill_mastery","prosecdef":true}]

-- Both triggers on submission_answers:
[{"tgname":"trg_sa_01_skill_mastery","table_name":"submission_answers","event":"INSERT"},
 {"tgname":"trg_sa_update_recalc_mastery","table_name":"submission_answers","event":"UPDATE"}]
```

All 4 acceptance criteria verified:
- Trigger exists in pg_trigger (1 row each)
- Function exists in pg_proc (1 row each)
- SECURITY DEFINER confirmed (prosecdef=true)
- All guards present in SQL files

---

## Decisions Made

1. **SECURITY DEFINER on trigger functions** — Required because `student_skill_mastery` has RLS enabled. Trigger functions run as the function owner (postgres) not the inserting user, bypassing student/teacher RLS policies for analytics writes.

2. **Column-level trigger `AFTER UPDATE OF final_score`** — Prevents unnecessary recalculation when teacher updates `teacher_feedback` or flags an answer without changing the score. Only fires on actual score changes.

3. **Full recount for grade override** — Incremental delta (e.g., subtract OLD contribution, add NEW) would drift if multiple overrides happen concurrently or if the original INSERT trigger had edge cases. Full recount is idempotent and correct.

4. **Subquery for `aq.points` in ON CONFLICT block** — The `FROM` clause tables are not available in the `DO UPDATE SET` block, so `SELECT points FROM assignment_questions WHERE id = NEW.assignment_question_id` is used. This is a known PostgreSQL limitation.

---

## Deviations from Plan

None — plan executed exactly as written.

---

## Known Stubs

None — this plan is purely SQL/DB with no Flutter stubs.

---

## Self-Check: PASSED

- `db/migrations/007_skill_mastery_trigger.sql` — FOUND
- `db/migrations/007_grade_override_recalc_trigger.sql` — FOUND
- Commit 222a734 — FOUND (`feat(07-01): add AFTER INSERT trigger for skill mastery pipeline`)
- Commit d39c682 — FOUND (`feat(07-01): add AFTER UPDATE trigger for grade override mastery recalculation`)
- Supabase deployment verified via Management API — both triggers and functions confirmed in pg_trigger and pg_proc
