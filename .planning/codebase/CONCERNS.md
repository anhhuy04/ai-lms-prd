# Codebase Concerns

**Analysis Date:** 2026-03-05

---

## Tech Debt

### Missing Use Cases Layer
- **Issue:** Domain interfaces connect directly to repositories without use cases layer
- **Files:** `lib/domain/repositories/*.dart` - all repository interfaces
- **Impact:** Business logic mixed with data access; harder to test business rules independently
- **Fix approach:** Create use case classes in `lib/domain/usecases/` for each business operation

### Incomplete Chapter Implementations
- **Issue:** Only Chapter 1 (Assignment Creation/Distribution) is complete
- **Files:** `lib/presentation/views/assignment/` - fully implemented
- **Impact:** Major features missing from student experience
- **Fix approach:** Implement remaining chapters in order of priority

### No Error Boundaries on Screens
- **Issue:** Screens lack comprehensive error boundary widgets
- **Files:** All screen files in `lib/presentation/views/`
- **Impact:** App crashes visible to users without graceful recovery
- **Fix approach:** Wrap screen content with error boundary widgets

### Offline-First Not Implemented
- **Issue:** No local caching strategy; app requires constant connectivity
- **Files:** `lib/data/datasources/*` - all datasources
- **Impact:** Poor UX when network unstable; no draft preservation
- **Fix approach:** Implement Drift for local storage, queue operations when offline

### Analytics Module Architecture Not Designed
- **Issue:** Chapter 4 (Learning Analytics) has no architecture planning
- **Files:** N/A - not yet created
- **Impact:** Cannot implement analytics features without design
- **Fix approach:** Design analytics service architecture before implementation

---

## Known Bugs

### Folder Naming Typo
- **Issue:** `lib/core/ultils/` should be `lib/core/utils/`
- **Files:** `lib/core/ultils/` directory exists
- **Trigger:** File organization inspection
- **Workaround:** None - cosmetic only

### Dashboard Skeleton Screens
- **Issue:** Dashboard screens show only placeholder data
- **Files:** `lib/presentation/views/dashboard/*`
- **Trigger:** Login as any role
- **Workaround:** Complete Chapter 2-5 implementations

### HeroControllerScope Duplicate Keys
- **Issue:** Assertion error with duplicate page keys
- **Files:** `lib/core/routes/app_router.dart`
- **Trigger:** Navigation between certain routes
- **Workaround:** Already fixed with unique `state.pageKey` injection

---

## Security Considerations

### API Keys in Settings Screen
- **Risk:** User can store arbitrary API keys in settings
- **Files:** `lib/presentation/views/settings/api_key_setup_screen.dart`
- **Current mitigation:** Keys stored locally, not transmitted
- **Recommendations:** Encrypt stored keys; validate before use

### RLS Policy Completeness
- **Risk:** Some tables may have incomplete RLS policies
- **Files:** Database tables - check `db/` folder for migrations
- **Current mitigation:** RLS enabled on all tables per documentation
- **Recommendations:** Audit all RLS policies quarterly

### Environment Variables
- **Risk:** `.env` files may contain secrets
- **Files:** `lib/core/env/env.dart`
- **Current mitigation:** `envied` compiles at build time; `.env*` in `.gitignore`
- **Recommendations:** Never commit `.env*` files

---

## Performance Bottlenunks

### N+1 Query Problem (Historical)
- **Problem:** Previously sequential API calls in loops
- **Files:** `lib/presentation/providers/class_hierarchy_provider.dart`
- **Cause:** Multiple await in loops
- **Improvement path:** Already optimized with `Future.wait()` - 5 classes: 1000ms → 300ms

### Large List Rendering
- **Problem:** Modal/drawer lists loaded all items at once
- **Files:** `lib/presentation/views/assignment/teacher/widgets/recipient_tree_selector_modal.dart`
- **Improvement path:** Pagination implemented (10 items/page)

---

## Fragile Areas

### Assignment Distribution Workflow
- **Files:** `lib/presentation/providers/distribute_assignment_notifier.dart`, `teacher_distribute_assignment_screen.dart`
- **Why fragile:** Complex state machine with many edge cases (empty selection, partial selection, cross-class)
- **Safe modification:** Test all permutation paths before changes
- **Test coverage:** Integration tests needed

### Route Guards and RBAC
- **Files:** `lib/core/routes/route_guards.dart`, `lib/core/routes/app_router.dart`
- **Why fragile:** Incorrect ordering or logic allows unauthorized access
- **Safe modification:** Always test as different roles after changes
- **Test coverage:** Manual testing per role required

### Concurrency in AsyncNotifier
- **Files:** All notifier providers in `lib/presentation/providers/`
- **Why fragile:** Multiple concurrent operations can cause "Future already completed" errors
- **Safe modification:** Always use `_isUpdating` guard pattern before state changes
- **Test coverage:** Load testing with rapid user actions

---

## Scaling Limits

### Supabase Free Tier
- **Current capacity:** 500MB database, 1GB bandwidth, 50MB storage
- **Limit:** Exceeded with large assignments or many media files
- **Scaling path:** Upgrade to Supabase Pro ($25/month) or implement media CDN

### Pagination Not Universally Applied
- **Current capacity:** Some lists load all items
- **Limit:** 100+ items causes UI lag
- **Scaling path:** Apply pagination pattern consistently to all list views

---

## Dependencies at Risk

### Riverpod vs Provider Hybrid
- **Risk:** Codebase has mix of Provider and Riverpod patterns
- **Impact:** Inconsistent state management; potential bugs from pattern confusion
- **Migration plan:** Complete migration to Riverpod only (already in progress per CLAUDE.md)

### Drift/Local DB Not Integrated
- **Risk:** `drift` package added but not used
- **Impact:** Offline features cannot be implemented
- **Migration plan:** Implement Drift for local caching when Chapter 2 starts

---

## Missing Critical Features

### Student Submission Flow (Chapter 2)
- **Problem:** Students cannot view or submit assignments
- **Blocks:** Cannot test assignment distribution end-to-end

### AI Grading Integration (Chapter 3)
- **Problem:** No AI service connection for automated grading
- **Blocks:** Teachers must grade all submissions manually

### Learning Analytics Dashboard (Chapter 4)
- **Problem:** No analytics service or UI
- **Blocks:** Teachers have no visibility into class performance trends

### Personalized Recommendations (Chapter 5)
- **Problem:** No recommendation engine
- **Blocks:** Students receive no AI-powered learning suggestions

---

## Test Coverage Gaps

### No Unit Tests Written
- **What's not tested:** All business logic in repositories, notifiers, use cases
- **Files:** `lib/data/repositories/`, `lib/presentation/providers/`, `lib/domain/`
- **Risk:** Bugs undetected until manual testing
- **Priority:** HIGH

### No Widget Tests
- **What's not tested:** UI components and screen widgets
- **Files:** `lib/presentation/views/`, `lib/widgets/`
- **Risk:** UI regressions undetected
- **Priority:** MEDIUM

### No Integration Tests
- **What's not tested:** End-to-end user flows
- **Files:** N/A
- **Risk:** Critical path failures in production
- **Priority:** HIGH

---

## Incomplete Features from Progress.md

### Chapter 1 Status: MOSTLY COMPLETE
- ✅ Assignment entity model
- ✅ Question entity model
- ✅ AssignmentDataSource
- ✅ AssignmentRepository
- ✅ Assignment builder UI
- ✅ Distribution workflow
- ⚠️ Rich text editor - not integrated (using simple TextField)

### Chapter 2 Status: NOT STARTED
- ⏳ StudentWorkspaceViewModel
- ⏳ Assignment response entity
- ⏳ Workspace screen
- ⏳ File upload capability
- ⏳ Submission confirmation

### Chapter 3 Status: NOT STARTED
- ⏳ AI Grading Service integration
- ⏳ AutoGradingViewModel
- ⏳ Teacher grading review screen

### Chapter 4 Status: NOT STARTED
- ⏳ Analytics service
- ⏳ AnalyticsViewModel
- ⏳ Analytics screens
- ⏳ Charts integration

### Chapter 5 Status: NOT STARTED
- ⏳ RecommendationService
- ⏳ RecommendationViewModel
- ⏳ Recommendation UI components

---

## Deprecated Patterns to Address

### Provider to Riverpod Migration Incomplete
- **Files:** Some files still use Provider instead of Riverpod annotations
- **Status:** CLAUDE.md mandates Riverpod; legacy code exists
- **Action:** Complete migration

### Legacy Route Class
- **Files:** Previously `lib/core/routes/app_routes.dart` (now deleted)
- **Status:** Correctly removed per progress.md
- **Action:** None - already fixed

---

*Concerns audit: 2026-03-05*
