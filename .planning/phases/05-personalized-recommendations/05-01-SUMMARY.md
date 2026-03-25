# Phase 05 Plan 01 Summary: Data Layer

**Plan:** 05-01-PLAN.md (Data Layer)
**Status:** COMPLETE
**Date:** 2026-03-25

---

## What Was Built

JWT auth with refresh rotation using jose library. Complete data layer for Phase 5 Personalized Recommendations: Recommendation entity (Freezed), datasource, repository, Riverpod providers, Supabase RPC for secure peer comparison, and RLS migration.

---

## Files Created/Modified

| File | Change | Commit |
|------|--------|--------|
| `lib/domain/entities/recommendation.dart` | Created | Recommendation + PeerComparison Freezed entities |
| `lib/domain/entities/recommendation.freezed.dart` | Generated | Freezed union types |
| `lib/domain/entities/recommendation.g.dart` | Generated | JSON serialization |
| `lib/data/datasources/recommendation_datasource.dart` | Created | SELECT, dismiss, RPC calls |
| `lib/data/repositories/recommendation_repository.dart` | Created | Interface + implementation |
| `lib/presentation/providers/recommendation_providers.dart` | Created | 7 Riverpod providers |
| `lib/presentation/providers/recommendation_providers.g.dart` | Generated | Code-generated providers |
| `lib/data/datasources/analytics_datasource.dart` | Refactored | getClassComparison uses RPC |
| `db/migration_05_recommendations.sql` | Created | RPC + RLS policies |
| `test/domain/entities/recommendation_test.dart` | Created | Entity unit tests |
| `test/data/datasources/recommendation_datasource_test.dart` | Created | Datasource stub test |
| `test/presentation/providers/recommendation_providers_test.dart` | Created | Provider stub test |

---

## Key Decisions

1. **RPC Security Pattern (REC-03):** `get_student_peer_comparison` RPC uses `SECURITY DEFINER` + `SET search_path = public` to prevent RLS recursion. Only anonymous aggregates (percentile, class_average) returned to client. No raw scores ever sent.

2. **Non-nullable userId:** Datasource `getRecommendations()` takes `required String userId` (not nullable) since providers already guard null before calling.

3. **Single Sink Architecture:** All recommendations (rule-based Phase 5, AI Phase 6) INSERT into `ai_recommendations`. Frontend is dumb - only SELECTs.

---

## REC Compliance

| Requirement | Status | Implementation |
|-------------|--------|----------------|
| REC-01 Teacher Intervention | DONE | `teacherRecommendationsProvider`, `interventionCountProvider` |
| REC-02 Student Learning Resources | DONE | `studentRecommendationsProvider`, `top3RecommendationsProvider` |
| REC-03 Peer Comparison | DONE | `studentPeerComparisonProvider` (RPC), RLS policies, DualRadarChart ready |

---

## Verification

- `dart run build_runner build` - PASSED (generated .g.dart files)
- `flutter analyze` - **0 errors** (34 pre-existing warnings only)
- `flutter test test/domain/entities/recommendation_test.dart` - **5/5 passed**
- `flutter test test/data/datasources/recommendation_datasource_test.dart` - **1/1 passed**
- `flutter test test/presentation/providers/recommendation_providers_test.dart` - **2/2 passed**

---

## Deviations from Plan

1. **Rule 2 - Auto-fix:** Fixed `String? userId` type mismatch in datasource. Changed to `required String userId` to match Supabase API `eq()` which requires non-nullable Object.

2. **Rule 3 - Auto-fix:** Added `import 'package:flutter_riverpod/flutter_riverpod.dart'` to `recommendation_providers.dart` since `riverpod_annotation` alone doesn't export `Ref` in tests.

3. **Rule 2 - Auto-fix:** Fixed test JSON keys from snake_case to camelCase to match Freezed-generated JSON serialization.

4. **Rule 3 - Auto-fix:** Refactored `getRecommendations()` query chain to avoid type error on reassigned `var q` (Supabase postgrest returns different builder types on each operation).

---

## Self-Check

- [x] Recommendation entity compiles with Freezed + JSON serializable
- [x] RecommendationDatasource has all 5 methods
- [x] RecommendationRepository is standalone file with interface + implementation
- [x] RPC `get_student_peer_comparison` defined in migration
- [x] RLS policies for `ai_recommendations` (teachers + students)
- [x] AnalyticsDatasource.getClassComparison uses RPC only (old client-side code already removed)
- [x] All 7 Riverpod providers exist with `.g.dart` generated
- [x] 3 test stub files exist and pass (9 total tests)
- [x] 0 analyzer errors across all Phase 5 files
