---
phase: 05-personalized-recommendations
plan: '05'
subsystem: ui
tags: [riverpod, go_router, recommendations, dashboard]

# Dependency graph
requires:
  - phase: 05-personalized-recommendations
    provides: '05-01/02/03: recommendation data layer (entities, repositories, datasources), recommendation_providers.dart with top3RecommendationsProvider'
provides:
  - '05-05: Student home dashboard REC-02 entry-point (route constants, GoRouter, dashboard section, dismiss invalidation)'
affects: [05-personalized-recommendations]

# Tech tracking
tech-stack:
  added: []
  patterns: ['GoRouter ShellRoute for bottom nav preservation', 'Riverpod provider invalidation for cache invalidation']

key-files:
  created: []
  modified:
    - lib/core/routes/route_constants.dart
    - lib/core/routes/app_router.dart
    - lib/presentation/views/dashboard/home/student_home_content_screen.dart
    - lib/presentation/providers/recommendation_providers.dart
    - lib/presentation/views/recommendation/student/student_recommendations_tab.dart

key-decisions:
  - "Full recommendations tab uses studentRecommendationNotifierProvider (limit 20) while home dashboard uses top3RecommendationsProvider (limit 3) for separation of concerns"
  - "DismissRecommendation.dismiss() invalidates top3RecommendationsProvider so home dashboard updates when a recommendation is dismissed from the full tab"
  - "Full tab uses studentRecommendationNotifierProvider for full list; _dismiss still invalidates top3RecommendationsProvider for home dashboard sync"

patterns-established:
  - "Provider invalidation chain: dismissRecommendationProvider invalidates studentRecommendationNotifierProvider + top3RecommendationsProvider + interventionCountProvider"

requirements-completed: [REC-02]

# Metrics
duration: 14min
completed: 2026-03-25
---

# Phase 05 Plan 05: Student "Hoc tap" Recommendations Entry-Point (REC-02)

**Close UAT gap: Student home dashboard has no UI entry-point to the 'Hoc tap' recommendations section. Added route constants, GoRouter route, recommendations section to home, dismiss-to-top3 invalidation, and full tab shows all recommendations.**

## Performance

- **Duration:** 14 min
- **Started:** 2026-03-25T16:21:43Z
- **Completed:** 2026-03-25T16:35:41Z
- **Tasks:** 5 (4 automated + 1 human-verify with UAT feedback fix)
- **Files modified:** 5

## Accomplishments

- Added `studentRecommendationsTab` + `studentRecommendationsTabPath` route constants with RBAC entry in `canAccessRoute()`
- Added GoRouter route inside Student ShellRoute (preserves bottom navigation)
- Added `_buildRecommendationsSection()` to student home dashboard showing up to 3 compact recommendation cards with "Xem tat ca" link
- Fixed `_buildSectionHeader` `onAction` callback (was previously empty `() {}`)
- Fixed `DismissRecommendation.dismiss()` to invalidate `top3RecommendationsProvider` so home dashboard updates
- Fixed `StudentRecommendationsTab._dismiss` to invalidate `top3RecommendationsProvider` + show snackbar
- **UAT fix:** Changed full tab to use `studentRecommendationNotifierProvider()` (limit 20) instead of `top3RecommendationsProvider` (limit 3) per user feedback

## Task Commits

Each task was committed atomically:

1. **Task 1: Route constants** - `18ac236` (feat)
2. **Task 2: GoRouter route** - `8379479` (feat)
3. **Task 3: Home dashboard section** - `29add2d` (feat)
4. **Task 4: Dismiss invalidation fix** - `a8c35d3` (fix)
5. **Task 5 UAT fix: Full tab provider** - `c79bf9a` (fix)

**Plan metadata:** docs(phase-05): complete plan 05-05 (pending final commit)

## Files Created/Modified

- `lib/core/routes/route_constants.dart` - Added `studentRecommendationsTab`, `studentRecommendationsTabPath`, added to `studentRoutes` in `canAccessRoute()`
- `lib/core/routes/app_router.dart` - Added `StudentRecommendationsTab` import and route inside Student ShellRoute
- `lib/presentation/views/dashboard/home/student_home_content_screen.dart` - Added `_buildRecommendationsSection()`, wired into ListView, fixed `_buildSectionHeader` `onAction`
- `lib/presentation/providers/recommendation_providers.dart` - `DismissRecommendation.dismiss()` now calls `ref.invalidate(top3RecommendationsProvider)`
- `lib/presentation/views/recommendation/student/student_recommendations_tab.dart` - Uses `studentRecommendationNotifierProvider()`, dismiss shows snackbar, `_dismiss` invalidates `top3RecommendationsProvider`

## Decisions Made

- Full recommendations tab shows up to 20 recommendations (`studentRecommendationNotifierProvider`) while home dashboard shows top 3 (`top3RecommendationsProvider`) - separate data sources for appropriate scoping
- Dismiss on the full tab invalidates both `studentRecommendationNotifierProvider` AND `top3RecommendationsProvider` to keep home dashboard in sync
- Route placed inside Student ShellRoute so bottom navigation bar remains visible during tab navigation

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing Critical] Removed unused imports**
- **Found during:** Task 3 and Task 4 verification
- **Issue:** `student_recommendations_tab.dart` had unused `go_router` import; `student_home_content_screen.dart` had unused `student_recommendations_tab.dart` import
- **Fix:** Removed both unused imports; all 5 files now pass `flutter analyze` with 0 errors
- **Files modified:** `student_recommendations_tab.dart`, `student_home_content_screen.dart`
- **Verification:** `flutter analyze` on all 5 files returns 0 errors
- **Committed in:** `a8c35d3` (Task 4 commit, amended)

---

**Total deviations:** 1 auto-fixed (unused imports, Rule 2)
**Impact on plan:** Minor cleanup - necessary for code quality but no behavior change.

### UAT Feedback Fix

**2. [UAT - User Feedback] Full tab shows all recommendations (limit 20), not top 3**
- **Found during:** Task 5 human verification
- **Issue:** Full tab was watching `top3RecommendationsProvider` (limit: 3) instead of `studentRecommendationNotifierProvider` (limit: 20)
- **Fix:** Changed full tab to watch `studentRecommendationNotifierProvider()`, kept `_dismiss` invalidating `top3RecommendationsProvider` for home dashboard sync
- **Files modified:** `student_recommendations_tab.dart` (3 lines)
- **Verification:** `flutter analyze` 0 errors, `build_runner` regenerated
- **Committed in:** `c79bf9a` (fix commit after checkpoint)

---

**Total UAT fixes:** 1
**Impact on plan:** User feedback resolved - full tab now correctly shows all recommendations.

## Issues Encountered

- None - all automated tasks completed cleanly with correct file targeting

## Next Phase Readiness

- Phase 05 REC-02 entry-point is complete and UAT-approved
- Ready for Phase 03 Rubric System or continuation of Phase 05

---
*Phase: 05-personalized-recommendations*
*Plan: 05*
*Completed: 2026-03-25*
