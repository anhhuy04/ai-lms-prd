---
status: awaiting_human_verify
trigger: "3 bugs trong Phase 02 - Teacher Grading Workflow"
created: 2026-04-01T00:00:00Z
updated: 2026-04-01T00:00:00Z
---

## Current Focus

hypothesis: Three distinct bugs — silent catch hides class_members query issues, race condition in _loadAssignment overwrites prefilled config, updateDistribution needs verify
test: Fix bugs 1 and 3 (confirmed root causes), verify bug 2 code flow
expecting: Si so shows correct count, form prefills correctly in edit mode
next_action: Apply fixes to assignment_datasource.dart and distribute_assignment_notifier.dart

## Symptoms

expected:
  - Bug 1: TeacherAssignmentDetailScreen shows Si so = 1 for class "4"
  - Bug 2: "Luu cau hinh" PATCH succeeds
  - Bug 3: Edit mode form prefills due_at, available_from, time_limit_minutes, allow_late

actual:
  - Bug 1: Si so = 0
  - Bug 2: Not tested yet, code flow looks correct
  - Bug 3: Form fields empty in edit mode

errors:
  - Bug 1: catch (_) {} swallows errors silently
  - Bug 3: Race condition — _loadAssignment overwrites loadDistributionConfig values

reproduction:
  - Bug 1: Open TeacherAssignmentDetailScreen for class "4"
  - Bug 3: From Detail screen, tap "Cau hinh" to enter edit mode

started: Phase 02 implementation

## Eliminated

(none yet)

## Evidence

- timestamp: 2026-04-01T00:01:00Z
  checked: RLS policies on class_members (backup_truoc_khi_seed.sql)
  found: Teacher HAS SELECT policy via is_teacher_owner_of_class function. Policy exists.
  implication: RLS is not the blocker. Query should work for teacher who owns the class.

- timestamp: 2026-04-01T00:02:00Z
  checked: school_class_datasource.dart line 125-128 for class_members query pattern
  found: Existing code uses .eq('status', 'approved') filter. Bug 1 code at line 693 does NOT use this filter.
  implication: Missing status filter + silent catch = potential issue. Adding logging will reveal actual error.

- timestamp: 2026-04-01T00:03:00Z
  checked: _loadAssignment method (lines 57-93) vs loadDistributionConfig (lines 395-414)
  found: Both run as microtasks. _loadAssignment does async network call then overwrites dueDate, availableFrom, timeLimitMinutes, allowLate unconditionally.
  implication: Confirmed race condition. loadDistributionConfig sets values first, then _loadAssignment overwrites them with assignment-level values.

- timestamp: 2026-04-01T00:04:00Z
  checked: updateDistribution flow (lines 417-468) and datasource (lines 292-296)
  found: Code flow is correct — builds patch from state, calls repository.updateDistribution(id, patch) which calls _assignmentDistributions.update(id, patch). No obvious code bug.
  implication: Bug 2 likely works if RLS UPDATE policy exists. Need to verify RLS.

## Resolution

root_cause:
  - Bug 1: Silent catch (_) {} hides errors + missing status='approved' filter on class_members query
  - Bug 2: Code flow correct, needs runtime verification
  - Bug 3: Race condition — _loadAssignment overwrites loadDistributionConfig values

fix:
  - Bug 1: Replaced catch (_) {} with catch (e, st) { AppLogger.error(...) } + added .eq('status', 'approved') filter to match codebase pattern
  - Bug 2: No code change needed — RLS policy "Teachers can manage distributions for own assignments" covers UPDATE. Code flow verified correct.
  - Bug 3: Changed _loadAssignment to use ?? operator for dueDate, availableFrom, timeLimitMinutes. Removed allowLate override (distribution-level setting, not assignment-level).
verification: dart analyze passed, awaiting human verification on device
files_changed:
  - lib/data/datasources/assignment_datasource.dart
  - lib/presentation/providers/distribute_assignment_notifier.dart
