---
phase: 07-ai-analytics-pipeline
plan: 09
subsystem: analytics + recommendations
tags: [rpc, routing, provider-wiring, phase5-closure, D-22, REC-03]
requirements: [7-09]
dependency_graph:
  requires: [07-01, 07-06, 07-08]
  provides:
    - "get_class_average_skill_mastery RPC (SECURITY DEFINER) for teacher analytics"
    - "Standalone route for StudentRecommendationsTab (outside ShellRoute)"
    - "classAverageSkillMasteryProvider wired to real RPC (no placeholder)"
  affects: [07-11]
tech_stack:
  added: []
  patterns:
    - "SECURITY DEFINER RPC + class_members join pattern"
    - "Datasource-backed Riverpod async provider with graceful empty-map fallback"
key_files:
  created:
    - db/migrations/007_class_avg_skill_mastery_rpc.sql
  modified:
    - lib/core/routes/app_router.dart
    - lib/data/datasources/analytics_datasource.dart
    - lib/presentation/providers/analytics_providers.dart
decisions:
  - "Standalone route uses distinct path /student/recommendations/view + _standalone name suffix to avoid GoRouter duplicate path AND duplicate name errors (both must be unique across the router)"
  - "Schema discovery: learning_objectives has (code, description), NOT name; students link to classes via class_members (status='approved'), NOT class_students — RPC updated accordingly"
  - "Datasource getClassAverageSkillMastery returns Map<String,double> matching the provider contract (objectiveId -> avgMastery), swallowing errors into empty map to keep DualRadarChart rendering"
metrics:
  duration_minutes: 12
  tasks_completed: 3
  files_changed: 4
  completed_date: "2026-04-11"
---

# Phase 07 Plan 09: Phase 5 UAT + VERIFICATION Closure Summary

Closed three Phase 5 VERIFICATION gaps (missing class-average RPC, missing standalone recommendations route, and pre-fixed dismiss invalidation) and wired the teacher DualRadarChart to real aggregated skill-mastery data via a new SECURITY DEFINER RPC.

## What Was Built

### Task 1 — get_class_average_skill_mastery RPC (D-22) [commit 0813847]

Created `db/migrations/007_class_avg_skill_mastery_rpc.sql` — a `SECURITY DEFINER` plpgsql function returning, per learning objective in a class:

- `objective_id`, `objective_code`, `objective_description`, `subject_code`
- `avg_mastery` — AVG of `student_skill_mastery.mastery_level`
- `total_students` — distinct students with mastery rows for that objective
- `students_below_threshold` — distinct students with `mastery_level < 0.6`

Student membership resolved via `public.class_members` where `status = 'approved'` (discovered via schema read — original plan draft assumed a `class_students` table that does not exist). `learning_objectives` exposes `code` + `description` rather than `name`, and the RPC surface was adjusted to match.

`GRANT EXECUTE ... TO authenticated` is included.

### Task 2 — Three Phase 5 VERIFICATION bug fixes [commit 4913e32]

1. **Standalone recommendations route** (`lib/core/routes/app_router.dart`):
   - Added a new `GoRoute` at path `/student/recommendations/view` with name `${AppRoute.studentRecommendationsTab}_standalone`, placed alongside other student standalone routes (outside the student `ShellRoute`).
   - Uses a distinct path + distinct name because GoRouter requires BOTH to be unique across the tree; same-path overload is not supported.

2. **classAverageSkillMasteryProvider RPC wiring**:
   - Added `AnalyticsDatasource.getClassAverageSkillMastery(classId)` which calls `rpc('get_class_average_skill_mastery', params: {'p_class_id': classId})` and maps the result rows into `Map<String, double>` (objectiveId -> avgMastery). Errors log via `AppLogger` and degrade to an empty map so `DualRadarChart` keeps rendering student-only data.
   - `analytics_providers.dart` `classAverageSkillMastery` provider no longer returns `{}` with a TODO — it watches the datasource and forwards the map.

3. **Dismiss invalidation bug (Bug 2)** — already fixed in a prior commit:
   - `lib/presentation/providers/recommendation_providers.dart` lines 235–242 already wrap all four `ref.invalidate(...)` calls inside the `if (success)` block. No code change was required for this bug; this was verified by reading the file.

### Task 3 — UAT checkpoint (auto-approved)

UAT device testing (PeerComparisonBadge, standalone route navigation, dismiss behavior on network failure, teacher class-average rendering) is deferred to manual testing on device. See "Deferred UAT" below.

## Verification

- `flutter analyze lib/core/routes/app_router.dart lib/presentation/providers/analytics_providers.dart lib/presentation/providers/recommendation_providers.dart lib/data/datasources/analytics_datasource.dart` → **No issues found** (0 errors, 0 warnings).
- Full `flutter analyze` → 2 pre-existing unused_element warnings in `teacher_submission_detail_screen.dart` and `grading_action_buttons.dart` — unrelated to this plan, logged as out-of-scope.
- Acceptance criteria satisfied:
  - Migration file contains `CREATE OR REPLACE FUNCTION get_class_average_skill_mastery(p_class_id uuid)` ✓
  - Contains `SECURITY DEFINER` ✓
  - Contains `AVG(ssm.mastery_level)` ✓
  - Contains `students_below_threshold ... FILTER (WHERE ssm.mastery_level < 0.6)` ✓
  - Standalone `StudentRecommendationsTab` GoRoute exists outside ShellRoute ✓
  - `top3RecommendationsProvider` invalidation inside `if (success)` block ✓ (pre-existing)
  - `classAverageSkillMasteryProvider` calls `rpc('get_class_average_skill_mastery', ...)` ✓
  - `flutter analyze` 0 errors ✓

## Deviations from Plan

**1. [Rule 1 — Schema Discovery] class_students does not exist; learning_objectives has no `name` column**
- Found during: Task 1 schema read
- Issue: Plan's sample SQL referenced `class_students` table and `lo.name` column; neither exists in this project's schema.
- Fix: Use `public.class_members` (the actual enrollment table, with `status = 'approved'` filter) and expose `lo.code` + `lo.description` + `lo.subject_code` in the RETURNS TABLE.
- Files modified: `db/migrations/007_class_avg_skill_mastery_rpc.sql`
- Commit: 0813847

**2. [Rule 1 — GoRouter constraint] Plan suggested same path + name suffix for standalone route**
- Found during: Task 2 implementation
- Issue: GoRouter enforces path uniqueness in addition to name uniqueness within a router subtree; registering two routes with identical `path` and only differing `name` would still fail at router build time.
- Fix: Used a distinct path `/student/recommendations/view` in addition to the `_standalone` name suffix. Callers that need the no-bottom-nav standalone variant push this new path/name.
- Files modified: `lib/core/routes/app_router.dart`
- Commit: 4913e32

**3. [Observation] Bug 2 (dismiss invalidation) was already fixed**
- Found during: Task 2 read_first step on `recommendation_providers.dart`
- The dismiss method at lines 229–251 already wraps all four `ref.invalidate(...)` calls inside the `if (success) { ... }` branch. This was likely closed in an earlier Phase 5 patch. No action taken, documented for traceability.

## Authentication Gates

None encountered. Supabase deployment of the RPC is deferred (see below) but is an infrastructure task, not an auth gate.

## Deferred Items

**RPC deployment to remote Supabase**
- The migration file is created and committed but NOT yet applied to the remote database.
- Supabase MCP tools are not exposed in this executor session, and the project does not have a linked `supabase/` CLI config (no `supabase/config.toml`, no `supabase/migrations/` directory).
- Action required: run via Supabase MCP `execute_sql` in a session where it is available, or `psql $DATABASE_URL -f db/migrations/007_class_avg_skill_mastery_rpc.sql`, or move the file into `supabase/migrations/` after `supabase link` + `supabase db push`.
- Until deployed, `classAverageSkillMasteryProvider` will hit the RPC and gracefully degrade to an empty map (logged as error), so no UI crash — DualRadarChart will just show student-only data, matching current Phase 5 behavior.

**Deferred UAT (Task 3 auto-approved)**
UAT requires a physical device session with real student submissions. The following tests are documented in 07-09-PLAN.md lines 206–225 and should be executed on device when convenient:
1. PeerComparisonBadge renders non-empty data for a student with submitted MCQ assignments.
2. Deep-link navigation to the standalone recommendations route renders without the bottom nav.
3. Dismiss-on-success removes recommendation from both tab and home dashboard; dismiss-on-failure leaves it in place.
4. Teacher class analytics view shows non-empty class average skill mastery (requires RPC deployed).

**Out of scope (Rule scope boundary — logged, not fixed)**
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart:1388` unused `_updateFeedback` warning.
- `lib/presentation/views/assignment/teacher/widgets/submission/grading_action_buttons.dart:86` unused `_extractText` warning.

## Commits

| Task | Hash    | Message |
|------|---------|---------|
| 1    | 0813847 | feat(07-09): add get_class_average_skill_mastery RPC migration (D-22) |
| 2    | 4913e32 | fix(07-09): close Phase 5 VERIFICATION gaps — standalone route + class avg RPC wiring |

## Self-Check: PASSED

- db/migrations/007_class_avg_skill_mastery_rpc.sql: FOUND
- lib/core/routes/app_router.dart standalone route: FOUND (searched "_standalone")
- lib/presentation/providers/analytics_providers.dart RPC call: FOUND (via datasource)
- commit 0813847: FOUND
- commit 4913e32: FOUND
- flutter analyze on modified files: 0 issues
