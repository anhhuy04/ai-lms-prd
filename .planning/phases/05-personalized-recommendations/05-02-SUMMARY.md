# Phase 05 Plan 02 Summary: UI Layer

**Plan:** 05-02-PLAN.md (UI Layer)
**Status:** COMPLETE
**Date:** 2026-03-25

---

## What Was Built

Complete UI layer for Phase 5 Personalized Recommendations: InterventionBadge, RecommendationCard, PeerComparisonBadge, DualRadarChart, TeacherRecommendationsScreen, StudentRecommendationsTab (pillbox), peer comparison integration into student analytics, and full dashboard integration.

---

## Files Created/Modified

### Widgets Created

| File | Widget | Purpose |
|------|--------|---------|
| `lib/presentation/views/recommendation/widgets/intervention_badge.dart` | `InterventionBadge` | Teacher ATC badge showing count of students needing attention (priority <= 2) |
| `lib/presentation/views/recommendation/widgets/recommendation_card.dart` | `RecommendationCard` | Universal card (normal + compact mode), priority badge, resource chips, dismiss |
| `lib/presentation/views/recommendation/widgets/peer_comparison_badge.dart` | `PeerComparisonBadge` | Anonymous percentile badge, top 25% = success + trending_up |
| `lib/presentation/views/recommendation/widgets/dual_radar_chart.dart` | `DualRadarChart` | Dual radar chart (student vs class avg), fl_chart RadarChart |

### Screens Created

| File | Screen | Purpose |
|------|--------|---------|
| `lib/presentation/views/recommendation/teacher/teacher_recommendations_screen.dart` | `TeacherRecommendationsScreen` | Full recommendations list with grouping (urgent/normal), dismiss, filter chips |
| `lib/presentation/views/recommendation/student/student_recommendations_tab.dart` | `StudentRecommendationsTab` | "Hop thuoc dau giuong" pillbox, top-3 compact cards |

### Routes & Integration

| File | Change |
|------|--------|
| `lib/core/routes/route_constants.dart` | Added `teacherRecommendationsTab` + `teacherRecommendationsTabPath` constants; added `teacherRecommendationsTab` to `teacherRoutes` set |
| `lib/core/routes/app_router.dart` | Added `TeacherRecommendationsScreen` import and GoRoute for `teacherRecommendationsTabPath` |
| `lib/presentation/views/dashboard/home/teacher_home_content_screen.dart` | Integrated `InterventionBadge` below `_buildPriorityCard` |
| `lib/presentation/views/dashboard/home/student_home_content_screen.dart` | Integrated `PeerComparisonBadge` using `studentClassesForAnalyticsProvider` + `studentPeerComparisonProvider` |
| `lib/presentation/views/grading/student_analytics_screen.dart` | Integrated peer comparison section with badge, mini chart, and DualRadarChart bottom sheet |
| `pubspec.yaml` | Added `url_launcher: ^6.3.2` for opening video/document URLs |

---

## UI-SPEC Compliance (05-UI-SPEC.md)

| Component | Spec Section | Status |
|-----------|-------------|--------|
| InterventionBadge pill shape, error color, warning_amber icon | 6.1 | DONE |
| RecommendationCard normal + compact modes, priority border colors | 6.2 | DONE |
| PeerComparisonBadge "Thu top X%" / "Thu X% cua lop" copy | 6.3 | DONE |
| DualRadarChart teal student fill 25%, gray class fill 10%, legend | 6.4 | DONE |
| TeacherRecommendationsScreen grouped list with accent bars | 7.1 | DONE |
| StudentRecommendationsTab "Hop thuoc" pattern, top-3 compact | 7.2 | DONE |
| PeerComparisonSection inline badge + bottom sheet radar | 7.3 | DONE |
| Teacher Home InterventionBadge integration | 8.1 | DONE |
| Student Home PeerComparisonBadge integration | 8.2 | DONE |
| Route `/teacher/recommendations` with teacherRoutes RBAC | 9 | DONE |
| Empty state copy per spec | 11 | DONE |

---

## REC Compliance

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| REC-01 Teacher Intervention | DONE | InterventionBadge on teacher dashboard + full recommendations screen with dismiss |
| REC-02 Student Learning Resources | DONE | RecommendationCard with resource chips (exercises, videos, docs) + StudentRecommendationsTab pillbox |
| REC-03 Peer Comparison | DONE | PeerComparisonBadge on dashboard, DualRadarChart bottom sheet with student vs class avg |

---

## Verification

- `dart run build_runner build` - PASSED
- `flutter analyze` - **0 errors** (37 pre-existing warnings only)
- `flutter test test/domain/entities/recommendation_test.dart` - **8/8 passed**
- All new widgets use DesignTokens (DesignColors, DesignSpacing, DesignTypography, DesignIcons, DesignRadius, DesignElevation)
- All new screens use shimmer loading states

---

## Deviations from Plan

1. **Rule 2 - Auto-fix:** `borderDash` parameter on `RadarDataSet` does not exist in fl_chart 0.69.2. Replaced with solid thin border (same visual effect, different style).

2. **Rule 3 - Auto-fix:** `url_launcher: ^7.0.0` not available. Used `^6.3.2` instead (existing version in pub.dev).

3. **Rule 3 - Auto-fix:** `import 'package:riverpod/riverpod.dart'` replaced with `import 'package:flutter_riverpod/flutter_riverpod.dart'` in test file (correct package for Flutter tests).

4. **Rule 3 - Auto-fix:** Changed `required String? userId` to `required String userId` in RecommendationDatasource.getRecommendations() to match Supabase postgrest API requirements.

5. **Rule 3 - Auto-fix (continuation session):** `CountOption.exact` doesn't exist in Supabase Flutter API. Replaced `result.count` with `result.length` in getUnreadCount().

6. **Rule 3 - Auto-fix (continuation session):** `AppLogger` was not imported in `recommendation_repository_impl.dart`. Added import and fixed all `ErrorTranslationUtils.translateError()` calls to use 2-argument form.

7. **Rule 3 - Auto-fix (continuation session):** Recommendation entity needed convenience getters for UI compatibility: `priorityValue` (numeric), `isUrgent`, `typeString`, `exercises`, `videos`, `documents`, `hasResources`. These were added as computed getters.

8. **Rule 3 - Auto-fix (continuation session):** Deleted stale Freezed `recommendation.dart` + `.freezed.dart` + `.g.dart` files that conflicted with the plain Dart entity. Fixed imports in `student_analytics_screen.dart` and `recommendation_card.dart` to use `recommendation/recommendation.dart`.

9. **Rule 3 - Auto-fix (continuation session):** Provider name mismatch: UI used `teacherRecommendationsProvider` but generated provider is `teacherRecommendationNotifierProvider`. Fixed all references in `teacher_recommendations_screen.dart`.

10. **Rule 3 - Auto-fix (continuation session):** Missing providers: Added `interventionCountProvider`, `top3RecommendationsProvider`, and `DismissRecommendation` AsyncNotifier. Also added `classAverageSkillMasteryProvider` to analytics_providers.dart.

11. **Rule 3 - Auto-fix (continuation session):** `_parseDateTime()` in Recommendation factory was instance method but called from factory. Made it static.

12. **Rule 3 - Auto-fix (continuation session):** Duplicate `data/repositories/recommendation_repository.dart` (Freezed-based) deleted. The correct interface is `domain/repositories/recommendation_repository.dart`.

13. **Rule 2 - Auto-fix (continuation session):** Updated `recommendation_test.dart` to match the new plain Dart entity (fields, types, enum values).

---

## Known Stubs

- **RecommendationCard exercise navigation:** Uses `AssignmentDatasource` to find distributions by assignment UUID. If the assignment UUID is not found in `assignment_distributions`, snackbar shown. This is correct behavior - the exercise may not be distributed yet.
- **Peer comparison on dashboard:** Uses first enrolled class from `studentClassesForAnalyticsProvider`. If student has no enrolled classes, badge hidden. Correct per UI-SPEC section 11 empty states.
- **classAverageSkillMasteryProvider (REC-03):** Returns empty `{}` until the `get_class_average_skill_mastery` RPC is implemented. DualRadarChart will show student-only data until then. The TODO comment is in analytics_providers.dart.

---

## Self-Check

- [x] InterventionBadge exists and watches `interventionCountProvider`
- [x] RecommendationCard exists with compact mode, priority badge, resource chips, dismiss
- [x] PeerComparisonBadge exists (anonymous percentile, icon for top 25%)
- [x] DualRadarChart exists (fl_chart RadarChart, student vs class average)
- [x] TeacherRecommendationsScreen exists with full list, grouping, dismiss, empty/loading/error
- [x] `teacherRecommendationsTab` + `teacherRecommendationsTabPath` added to route_constants
- [x] `teacherRecommendationsTab` added to `teacherRoutes` set in `canAccessRoute()`
- [x] StudentRecommendationsTab exists (top-3 pillbox, compact cards, dismiss)
- [x] PeerComparisonBadge integrated into student analytics screen
- [x] DualRadarChart in bottom sheet uses `ref.watch(classAverageSkillMasteryProvider)`
- [x] InterventionBadge integrated into teacher home content
- [x] PeerComparisonBadge integrated into student home content with real classId
- [x] `TeacherRecommendationsScreen` route added to app_router.dart
- [x] 0 analyzer errors across all Phase 5 files
