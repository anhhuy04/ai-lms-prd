# Codebase Concerns

**Analysis Date:** 2026-04-14

---

## App Overview

**AI LMS PRD** is a Flutter/Dart LMS (Learning Management System) mobile app backed by Supabase. It supports three user roles:

### User Roles and Key Screens

**Student:**
- `lib/presentation/views/dashboard/student_dashboard_screen.dart` — home shell with BottomNav
- `lib/presentation/views/class/student/student_class_list_screen.dart` — enrolled classes with sort/filter/search
- `lib/presentation/views/class/student/student_class_detail_screen.dart` — class info, assignments, grades summary
- `lib/presentation/views/assignment/student/assignment_list_screen.dart` — assignments to complete
- `lib/presentation/views/assignment/student/student_assignment_detail_screen.dart` — assignment details
- `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart` — workspace (MCQ, essay, file upload, matching, fill-in-blank)
- `lib/presentation/views/assignment/student/student_submission_confirm_screen.dart` — confirm before submit
- `lib/presentation/views/assignment/student/student_submission_history_screen.dart` — past submissions with AI status badges
- `lib/presentation/views/assignment/student/student_submission_review_screen.dart` — review graded submission
- `lib/presentation/views/grading/student_analytics_screen.dart` — personal skill/score analytics
- `lib/presentation/views/recommendation/student/student_recommendations_tab.dart` — AI-driven learning recommendations
- `lib/presentation/views/class/student/qr_scan_screen.dart` — QR scan to join class
- `lib/presentation/views/class/student/join_class_screen.dart` — manual join by code

**Teacher:**
- `lib/presentation/views/dashboard/teacher_dashboard_screen.dart` — home shell with BottomNav
- `lib/presentation/views/class/teacher/teacher_class_list_screen.dart` — class list with paging
- `lib/presentation/views/class/teacher/teacher_class_detail_screen.dart` — class management
- `lib/presentation/views/class/teacher/create_class_screen.dart` / `edit_class_screen.dart` — class CRUD
- `lib/presentation/views/class/teacher/add_student_by_code_screen.dart` — enrollment via QR/code
- `lib/presentation/views/class/teacher/student_list_screen.dart` — manage class members
- `lib/presentation/views/class/teacher/teacher_assignment_detail_screen.dart` — per-class assignment view
- `lib/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart` — assignment management hub
- `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` — build assignments (MCQ, essay, file, matching, fill-blank, problem-solving); AI question generation
- `lib/presentation/views/assignment/teacher/teacher_distribute_assignment_screen.dart` — distribute to classes/groups
- `lib/presentation/views/assignment/teacher/teacher_submission_list_screen.dart` — submission list with AI status filters
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` — side-by-side grading UI
- `lib/presentation/views/assignment/teacher/teacher_grading_hub_screen.dart` — grading queue
- `lib/presentation/views/grading/teacher_analytics_screen.dart` / `teacher_student_analytics_screen.dart` — class/student analytics
- `lib/presentation/views/recommendation/teacher/teacher_recommendations_screen.dart` — at-risk student recommendations

**Admin:**
- `lib/presentation/views/dashboard/admin_dashboard_screen.dart` — placeholder shell only (see Concerns below)

### LMS Features Implemented
- Authentication: login / register / role-based redirect (`auth/`)
- Class lifecycle: create → configure (settings drawer, QR code enrollment, groups) → list → detail
- Assignment builder: 7 question types (MCQ, true/false, essay, short answer, fill-blank, matching, file-upload/problem-solving), AI-generated questions via Gemini/Groq/Ollama
- Assignment distribution: tree selector (class → group → individual), variant shuffling, late-policy configuration
- Student workspace: answer all question types, autosave, timer, submit confirmation
- Grading workflow (Phase 2 complete): AI auto-grading queue, teacher review, approve/override scores, feedback editor with debounce, grade override audit trail, publish grades
- AI analytics pipeline (Phase 7): skill mastery triggers, class avg analytics, in-app notifications, AI queue Realtime watcher
- Analytics: student skill radar chart, trend line chart, teacher class heatmap, top/bottom performers list
- Recommendations (Phase 5): AI-driven recommendations for students and intervention alerts for teachers
- Settings: API key setup (Gemini / Groq / Ollama), AI provider selection
- Profile: editable user profile screen
- Offline/network: `lib/presentation/views/network/no_internet_screen.dart`

---

## Tech Debt

**Massive screen files violating 300-line class rule:**
- Issue: Several screen files far exceed the 300-line class limit mandated in CLAUDE.md
- Files:
  - `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart` (3126 lines)
  - `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` (3075 lines)
  - `lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart` (2561 lines)
  - `lib/presentation/views/settings/api_key_setup_screen.dart` (2371 lines)
  - `lib/presentation/views/assignment/teacher/teacher_distribute_assignment_screen.dart` (1723 lines)
  - `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` (1616 lines)
  - `lib/data/datasources/assignment_datasource.dart` (1805 lines)
- Impact: High cognitive load, hard to test, prone to merge conflicts
- Fix approach: Extract sub-widgets into `widgets/` subdirectories; split datasource by operation group (query vs mutation)

**Hardcoded design values bypassing DesignTokens (~897 occurrences):**
- Issue: Raw `EdgeInsets.all(N)`, `fontSize: N`, `BorderRadius.circular(N)`, `Color(0xFF...)` instead of `DesignSpacing.*`, `DesignTypography.*`, `DesignRadius.*`, `DesignColors.*`
- Files: Spread across many screens and widget files throughout `lib/presentation/` and `lib/widgets/`
- Impact: Inconsistent UI, impossible to theme or rescale globally
- Fix approach: Grep-and-replace in batches per token category; prioritize high-traffic screens first

**Legacy `Navigator.push()` calls not using GoRouter:**
- Issue: Two screens still call `Navigator.push()` directly, bypassing GoRouter RBAC and route guards
- Files:
  - `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` line 1140
  - `lib/presentation/views/class/teacher/teacher_assignment_detail_screen.dart` line 299
- Impact: These navigation paths bypass route guards; RBAC and deep link handling are not enforced
- Fix approach: Replace with `context.pushNamed()` using the appropriate `AppRoute` constant

**`assignment_datasource.dart` — N+1 queries not fully mitigated:**
- Issue: Grading methods iterate per-question and may fan out API calls; `Future.wait()` optimization is present in provider layer but not fully applied in datasource
- Files: `lib/data/datasources/assignment_datasource.dart`
- Impact: Performance degrades with large question sets on slow networks
- Fix approach: Batch question fetch with `.in_()` filter; consider moving per-question grading loop into a single Supabase RPC call

---

## Known Bugs / Incomplete Features

**Matching question type — drag-drop UI not implemented:**
- Symptoms: Matching questions render a placeholder, no interactive UI for students
- Files: `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart` line 890
- Trigger: Opening any assignment containing a `matching` question type as a student
- Workaround: None — students cannot answer matching questions via UI

**Teacher class detail — student count hardcoded to 0:**
- Symptoms: `approvedCount = 0` and `ungradedCount: 0` are hardcoded; not loaded from DB
- Files:
  - `lib/presentation/views/class/teacher/teacher_class_detail_screen.dart` lines 320, 746
  - `lib/presentation/views/class/teacher/teacher_class_list_screen.dart` line 445
- Trigger: Teacher class list and detail screens always show 0 students/ungraded
- Workaround: None

**Teacher submission providers — `maxScore` and `assignmentTitle` not loaded:**
- Symptoms: Grading UI shows missing assignment title and null max score
- Files: `lib/presentation/providers/teacher_submission_providers.dart` lines 108, 146
- Trigger: Any teacher grading flow
- Workaround: None; fields render as empty/null

**Student class detail — navigation stubs for key grade/assignment actions:**
- Symptoms: Tapping "grade details", "submitted assignments", "upcoming assignments", "all assignments" on student class detail does nothing
- Files: `lib/presentation/views/class/student/student_class_detail_screen.dart` lines 245, 258, 271, 458
- Trigger: Student taps stat cards inside class detail
- Workaround: Students must navigate via assignment list screen directly

**Question bank not connected to assignment builder:**
- Symptoms: "Open question bank" and "Upload file" buttons are TODO stubs
- Files: `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` lines 2348, 2352
- Trigger: Teacher taps "From Question Bank" or "Upload" in assignment builder
- Workaround: Teacher must create all questions manually

**Teacher assignment hub — submission counts and class names are stubs:**
- Symptoms: Assignment cards show placeholder data instead of real class names and submission counts
- Files: `lib/presentation/views/assignment/teacher/teacher_assignment_hub_screen.dart` lines 531, 539, 552, 718
- Trigger: Teacher opens assignment hub

**Distribution manager — "Add Distribution" is unimplemented:**
- Symptoms: Tapping "Add distribution" shows nothing
- Files: `lib/presentation/views/assignment/teacher/widgets/distribution/assignment_distribution_manager.dart` line 46

**Retroactive AI trigger not wired:**
- Symptoms: `TODO 7-12b: implement retroactive AI trigger` — button exists but has no action
- Files: `lib/presentation/views/assignment/teacher/widgets/submission/submission_list_item.dart` line 154

**Class bottom sheet filter not connected to provider:**
- Symptoms: `TODO 7-12c: wire to filter provider` — filter UI is rendered but has no effect on the list
- Files: `lib/presentation/views/assignment/teacher/widgets/grading_hub/class_bottom_sheet.dart` lines 114, 137

---

## Security Considerations

**Sentry DSN is empty — errors silently lost in production:**
- Risk: `env.g.dart` shows `_envieddatasentryDsn` as empty list; `ErrorReportingService.initialize()` is called in `main.dart` but DSN is blank, so production errors are not captured
- Files: `lib/core/env/env.g.dart` lines 447–456, `lib/core/services/error_reporting_service.dart`, `lib/main.dart`
- Current mitigation: AppLogger writes to console during development only
- Recommendation: Set `SENTRY_DSN` in `.env.prod` before any release build

**Admin dashboard is a placeholder with no RBAC-enforced features:**
- Risk: Admin role routes to a screen with plain `Text('Trang Tổng quan Admin')` placeholders; if any admin-only Supabase RPCs are accidentally exposed before admin UI is built, they could be misused
- Files: `lib/presentation/views/dashboard/admin_dashboard_screen.dart`
- Current mitigation: RLS policies on Supabase limit admin DB access correctly
- Recommendation: Do not expose admin management APIs until proper admin UI is built

**AI API keys stored in Supabase profile metadata:**
- Risk: User-configured AI API keys (Gemini, Groq) are stored via `ProfileMetadataService` → Supabase. If RLS on `profiles` is misconfigured, keys could be read by other users
- Files: `lib/core/services/profile_metadata_service.dart`, `lib/core/services/api_key_service.dart` (1014 lines)
- Current mitigation: RLS on `profiles` restricts read to owner; `flutter_secure_storage` used for local caching
- Recommendation: Audit RLS on `profiles` table; consider server-side AI proxying to avoid storing user API keys at all

---

## Performance Bottlenecks

**Recipient tree selector loads data one page at a time:**
- Problem: Modal uses `ScrollController`-based pagination (10 items); each class expansion triggers a separate datasource call
- Files: `lib/presentation/views/assignment/teacher/widgets/recipient_tree_selector_modal.dart` (1323 lines)
- Cause: No bulk prefetch of class hierarchy
- Improvement path: Prefetch all classes in one call on modal open; lazy-load group members only on expand

**Dashboard providers do not refresh data on pull-to-refresh:**
- Problem: `refresh()` in both dashboard notifiers only checks auth state; assignment/score providers remain stale
- Files:
  - `lib/presentation/providers/student_dashboard_notifier.dart` line 40
  - `lib/presentation/providers/teacher_dashboard_notifier.dart` line 40
- Cause: `ref.invalidate()` calls for data providers are TODO
- Improvement path: Add targeted `ref.invalidate()` calls for assignment and score providers in refresh methods

---

## Fragile Areas

**JSONB column parsing in `assignment_datasource.dart`:**
- Files: `lib/data/datasources/assignment_datasource.dart`
- Why fragile: Multiple JSONB columns (`custom_content`, `answer`, `content`, `custom_questions`) use different schemas per question type; format changed from camelCase to snake_case and from `text`/`options` to `override_text`/`choices` — old data in DB may not match new parser
- Safe modification: Always add fallback parsing for old format keys before removing them; add explicit null guards for each field
- Test coverage: No unit tests for datasource parsing logic

**`workspace_provider.dart` — question state parsing with dynamic fallback logic:**
- Files: `lib/presentation/providers/workspace_provider.dart`
- Why fragile: Parses question choices using multiple fallback paths and generates IDs from index if absent; any change to question format in DB will silently corrupt display
- Safe modification: Add explicit field validation with typed models; avoid dynamic map access without null guards

**Route ordering in `app_router.dart`:**
- Files: `lib/core/routes/app_router.dart`
- Why fragile: GoRouter requires specific routes before parameterized routes; adding new routes in wrong order causes silent routing bugs (documented in CLAUDE.md Section 6)
- Safe modification: Always add new routes above parameterized siblings; verify routing after any route changes

---

## Scaling Limits

**AI grading is client-triggered — no server-side queue resilience:**
- Current capacity: AI grading calls go from the Flutter app through `AiService` (Dio) directly to Gemini/Groq APIs
- Limit: High submission volumes will saturate AI API rate limits; no retry mechanism for failed AI calls in datasource
- Scaling path: Complete the server-side AI worker using the existing `ai_queue` table; `teacher_ai_queue_provider.dart` already subscribes via Supabase Realtime — wire the Edge Function worker

**Class list uses offset-based paging — not cursor-based:**
- Current capacity: Works for small teacher accounts
- Limit: Large accounts with 100+ classes will slow down on later pages (offset scans full table)
- Scaling path: Switch to keyset pagination in `lib/data/datasources/school_class_datasource.dart`

---

## Dependencies at Risk

**`drift` and `retrofit` included but not actively used:**
- Risk: Both packages are in `pubspec.yaml` and noted in `docs/reports/dependency-review.md` as "kept for future use", but no active Drift DB or Retrofit client exists in the datasource layer
- Impact: Adds build_runner overhead, increases APK size, and creates confusion for new developers
- Migration plan: Either implement concrete usage or remove; keep the documented decision in `docs/reports/dependency-review.md`

---

## Missing Critical Features

**In-app notifications system — UI not wired despite DB migration existing:**
- Problem: Notification bell icon taps in student and teacher class list screens are TODO stubs; `db/migrations/007_in_app_notifications.sql` migration exists but no UI is connected
- Files:
  - `lib/presentation/views/class/student/student_class_list_screen.dart` line 138
  - `lib/presentation/views/class/teacher/teacher_class_list_screen.dart` lines 297, 352
  - `lib/presentation/views/class/student/widgets/drawers/student_class_settings_drawer.dart` lines 185–215 (4 notification toggles)
- Blocks: Students/teachers cannot receive in-app alerts for grading, submissions, or class events

**Settings screen — language, terms, privacy policy stubs:**
- Problem: "Notification settings", "Language", "Terms of Service", "Privacy Policy" are TODO stubs
- Files: `lib/presentation/views/settings/settings_screen.dart` lines 108, 124, 161, 177

**Dark mode toggle is a stub:**
- Problem: Dark mode toggle exists in student class settings drawer but does nothing
- Files: `lib/presentation/views/class/student/widgets/drawers/student_class_settings_drawer.dart` line 294

**Admin dashboard not implemented:**
- Problem: Admin role routes to placeholder Text widgets; no user management, content management, or school administration features exist
- Files: `lib/presentation/views/dashboard/admin_dashboard_screen.dart`

---

## Test Coverage Gaps

**No unit tests for datasource layer:**
- What's not tested: All files under `lib/data/datasources/` including `assignment_datasource.dart`, `submission_datasource.dart`, `analytics_datasource.dart`, `ai_datasource.dart`
- Risk: JSONB parsing bugs, API contract mismatches, and grading logic errors go undetected
- Priority: High

**No widget tests for critical grading UI:**
- What's not tested: `teacher_submission_detail_screen.dart`, `grading_action_buttons.dart`, `teacher_feedback_editor.dart`, `lib/widgets/rubric/interactive_rubric_grader.dart`
- Risk: Grade override, feedback debounce, and publish grade flows could regress silently
- Priority: High

**Existing test suite is minimal:**
- What exists: `test/password_toggle_test.dart`, `test/widget_test.dart`, `test/domain/entities/recommendation_test.dart`, `test/presentation/providers/recommendation_providers_test.dart`, `test/integration/submission_flow_test.dart`, `test/integration/grading_flow_test.dart`
- Risk: Core LMS flows (submit assignment, AI grading, publish grades) have minimal or no automated coverage
- Priority: High for submission and grading integration tests

---

*Concerns audit: 2026-04-14*
