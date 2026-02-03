# Active Context

## Current Sprint Focus
**Goal:** Widget Organization & UI Refinement (2026-01-21) - Complete widget reorganization, responsive spacing system, and search system refactoring

## Project Phase
**Phase:** Widget System Refactoring Complete (2026-01-21) - Ready for continued feature development

## Session Note (2026-01-29)
- Tiếp tục ưu tiên **hoàn thiện module Class** theo các patterns đã chuẩn hoá (GoRouter v2.0 + Riverpod + DesignTokens + shimmer).
- **Module Câu hỏi/Assignments để sau** (chỉ bắt đầu sau khi chốt schema Supabase qua MCP).

## Session Note (2026-01-29 - Latest)
- ✅ **Student Class List Enhancements**: Thêm teacher name, student count, sorting, filtering, search screen
- ✅ **Student Leave Class Feature**: Implement chức năng rời lớp (xóa hoàn toàn record khỏi database)
- ✅ **QR Scan Screen Redesign**: Cải thiện giao diện theo phong cách app ngân hàng với overlay cutout, toggle flash, chọn ảnh từ thư viện
- ✅ **Search Improvements**: Highlight teacher name thay vì academic year, bỏ search theo academic year
- ✅ **Avatar Enhancement**: Hiển thị chữ đầu của tên thay vì họ
- ✅ **Teacher Class List**: Hiển thị số học sinh động từ database

## Recently Completed

### Student Class Features & QR Scan Enhancement (NEW - 2026-01-29)
✅ **Student Class List Enhancements**
  - Added teacher name display below class name in `ClassItemWidget`
  - Added dynamic student count from database (aggregated from `class_members` with status='approved')
  - Implemented sorting options (name A-Z/Z-A, date newest/oldest) using `ClassSortBottomSheet`
  - Implemented filtering by enrollment status (all/approved/pending) using `FilteringUtils`
  - Created dedicated search screen (`StudentClassSearchScreen`) using `SearchScreen` generic pattern
  - Added `StudentClassMemberStatus` enum for type-safe status representation
  - Created `StudentClassInteractionHandler` for centralized pending class interaction logic
  - Updated `getClassesByStudent` to enrich data with teacher_name and student_count via SQL joins

✅ **Student Leave Class Feature**
  - Implemented `leaveClass` method in repository, datasource, and notifier layers
  - **Decision**: Xóa hoàn toàn record khỏi `class_members` (không chỉ đổi status)
  - Added confirmation dialog with warning message
  - Auto-refresh class list after leaving
  - Navigate back to class list screen on success
  - Files: `school_class_repository.dart`, `school_class_datasource.dart`, `class_notifier.dart`, `student_class_detail_screen.dart`

## Session Note (2026-01-30 - Question Bank & RLS)
- ✅ Hoàn thiện schema Question Bank & Assignments (8 bảng mới + indexes + triggers) trong `db/02_create_question_bank_tables.sql`.
- ✅ Thiết lập đầy đủ RLS cho các bảng mới (learning_objectives, questions, question_choices, question_objectives, assignments, assignment_questions, assignment_variants, assignment_distributions) với pattern: admin full access, teacher owner, student được xem theo distributions.
- ✅ Tối ưu RLS: thay tất cả `auth.uid()` trong policies mới bằng `(select auth.uid())` theo khuyến nghị Supabase để tránh re-evaluate per-row.
- ✅ Bật và bổ sung RLS cho core tables: `profiles`, `classes`, `schools`, `groups`, `class_teachers`, `class_members`, `group_members` (owner-based cho teacher, self-only cho student, admin full access).
- ✅ Tạo RPC `publish_assignment` (security definer, explicit auth checks) để publish assignment trong 1 transaction (upsert assignments + replace assignment_questions + assignment_distributions), expose qua Repository/Usecase/Notifier.

✅ **QR Scan Screen Redesign (Banking App Style)**
  - Redesigned overlay with cutout (khoét lỗ) in center using `QRScanOverlayPainter`
  - Implemented toggle flash functionality with `MobileScannerController`
  - Added image picker from gallery using `image_picker` package
  - Scan QR code from selected image file
  - Improved UI/UX: modern app bar, better scan frame corners, smooth animations
  - Added processing overlay during QR analysis
  - Files: `qr_scan_screen.dart`, `pubspec.yaml` (added `image_picker: ^1.0.7`)

✅ **Search & Display Improvements**
  - **Search**: Highlight teacher name instead of academic year in search results
  - **Search**: Removed academic year from search filter (only search by name, subject, teacher name)
  - **Avatar**: Changed to display first letter of given name (tên) instead of surname (họ)
  - **Teacher Class List**: Added dynamic student count display (fetched from database)
  - Files: `class_item_widget.dart`, `avatar_utils.dart`, `class_providers.dart`, `school_class_datasource.dart`

✅ **Code Organization & Reusability**
  - Created `ClassSortBottomSheet` reusable widget for sorting options
  - Created `FilteringUtils` for centralized filtering logic
  - Created `QuickSearchClassMapper` for consistent class-to-search-item mapping
  - Created `ClassScreenHeader` and `ClassPrimaryActionCard` reusable widgets
  - Extracted common patterns between teacher and student class lists

### Class Settings & Search Architecture Consolidation (2026-01-27)
✅ **Search System v2 Folder & Naming Refactor**
  - Restructured `lib/widgets/search/` into:
    - `screens/` (full-screen generic search with `SearchScreen<T>` + `SearchScreenConfig<T>`)
    - `dialogs/` (overlay quick search using `QuickSearchDialog` and support widgets)
    - `shared/` (shared UI like `SearchField`)
  - Removed legacy `v1/v2/smart_v2` naming in favor of function-based names (screens/dialogs/shared).
  - Updated all imports (TeacherClassSearchScreen, assignment list, class detail screens) to use new structure.

✅ **Drawer System & Class Settings Alignment with Supabase**
  - `ClassCreateClassSettingDrawer` and `ClassSettingsDrawer` now map 1-1 to `classes.class_settings` JSON:
    - `defaults.lock_class`
    - `enrollment.qr_code.{is_active, require_approval, join_code, expires_at, logo_enabled}`
    - `enrollment.manual_join_limit`
    - `group_management.{is_visible_to_students, lock_groups, allow_student_switch}`
    - `student_permissions.{auto_lock_on_submission, can_edit_profile_in_class}`
  - Added advanced settings section to teacher class drawer:
    - Group controls (visibility, lock changes, allow student switch)
    - Student permissions (profile edit, auto-lock on submission)
  - Created create-class advanced drawer (`ClassCreateClassSettingDrawer`) that configures the same JSON before class creation.

✅ **Optimistic Class Settings Updates & Concurrency Guard**
  - Introduced `ClassNotifier.updateClassSettingOptimistic` pattern:
    - Immediate local update of `_selectedClass` and list state.
    - Background sync to Supabase via `_syncClassSettingToBackend` (no loading state).
    - Rollback on failure with detailed logging.
  - Updated all drawer toggles (including `lock_class`) to use optimistic updates.
  - Added `_isUpdating` guard to `ClassNotifier.updateClass` to prevent concurrent AsyncNotifier state completion issues.
  - Switched QR/Enrollment screen (`AddStudentByCodeScreen`) to use `updateClassSettingOptimistic('enrollment', enrollment)` instead of `updateClassSetting` to avoid `Future already completed` errors.

✅ **Teacher Class List Auto-Refresh After Class Creation**
  - After successful `CreateClassScreen._createClass()`:
    - Call `ref.read(pagingControllerProvider(currentTeacherId)).refresh()` to reload paged class list.
    - Then navigate back to `TeacherClassListScreen` via `context.go(AppRoute.teacherClassListPath)`.
  - Ensures newly created class appears immediately in the teacher’s list.

### Widget Organization & Search System Refactoring (NEW - 2026-01-21)
✅ **Widget Directory Reorganization**
  - Created new subdirectories: `text/`, `loading/`, `list/`, `list_item/`, `navigation/`
  - Moved widgets to appropriate directories based on functionality
  - Updated `lib/widgets/README.md` with comprehensive documentation
  - Clear separation: shared widgets vs feature-specific widgets

✅ **Generic Search Screen Implementation**
  - Created `SearchScreen<T>` generic widget in `lib/widgets/search/search_screen.dart`
  - Created `SearchConfig<T>` for flexible configuration
  - Recreated `TeacherClassSearchScreen` using generic `SearchScreen<Class>`
  - Pattern: Reusable search screen for different data types (classes, assignments, students)

✅ **Class Item Widget Enhancement**
  - Added optional `searchQuery` and `highlightColor` parameters
  - Implemented `SmartHighlightText` for search result highlighting
  - Fixed highlighting to only highlight actual values, not labels ("Môn:", "Học kỳ:")
  - Used `Expanded` wrapper to prevent text overflow

✅ **Academic Year Input Refinement**
  - Updated `create_class_screen.dart` and `edit_class_screen.dart` with 3 input fields:
    - Start year (mandatory, 4 digits)
    - End year (mandatory, 4 digits, must be > start year)
    - Semester (optional, max 2 digits)
  - Format: `xxxx_xxxx_x` (with semester) or `xxxx_xxxx` (without semester)
  - Automatic focus shifting between fields
  - Robust validation with clear error messages

✅ **Responsive Spacing System Implementation**
  - Created `ResponsiveSpacing` class in `design_tokens.dart`
  - Created `ResponsiveSpacingExtension` on `BuildContext` for easy access
  - Automatic scaling based on device type:
    - Mobile: 1.0x (base)
    - Tablet: 1.1x-1.25x (depending on spacing size)
    - Desktop: 1.2x-1.5x (depending on spacing size)
  - Usage: `context.spacing.md`, `context.spacing.lg`, etc.
  - Replaced hardcoded spacing values in widgets

✅ **Router Fix**
  - Recreated `TeacherClassSearchScreen` after deletion
  - Fixed router imports and route definitions
  - All routes now working correctly

✅ Project structure established (Clean Architecture + MVVM)

### Dashboard Refresh System (NEW - 2026-01-21)
✅ **Student Dashboard Refresh Fix**
  - Fixed refresh logic to prevent auth state reset and redirect to login
  - Removed `checkCurrentUser()` call from `refresh()` method
  - Changed `showLoading: true` → `showLoading: false` to avoid router redirect
  - Refresh now only updates data providers (classes, assignments) without touching auth state
  - Removed duplicate `RefreshIndicator` from `student_dashboard_screen.dart` (kept only in `student_home_content_screen.dart`)
  - File: `lib/presentation/providers/student_dashboard_notifier.dart`

✅ **Teacher Dashboard Refresh Implementation**
  - Created `teacher_dashboard_notifier.dart` with `refresh()` method
  - Added `RefreshIndicator` to `teacher_home_content_screen.dart`
  - Converted `TeacherHomeContentScreen` from `StatelessWidget` to `ConsumerWidget`
  - Added `physics: AlwaysScrollableScrollPhysics` for proper pull-to-refresh behavior
  - Pattern: Same as student dashboard (refresh data only, no auth state reset)
  - Files:
    - `lib/presentation/providers/teacher_dashboard_notifier.dart` (new)
    - `lib/presentation/views/dashboard/home/teacher_home_content_screen.dart` (updated)

✅ **Code Optimization**
  - Removed unused imports from dashboard screens
  - Fixed duplicate RefreshIndicator issue (caused `refresh()` to be called twice)
  - Ensured consistent refresh pattern across both student and teacher dashboards

### Tech Stack Upgrade (NEW - 2026-01-17)
✅ **Environment Configuration (Priority 1.1)**
  - Implemented `envied` for compile-time environment variables
  - Created `lib/core/env/env.dart` with Envied configuration
  - Refactored `SupabaseService` to use environment variables
  - Added `.env.dev`, `.env.staging`, `.env.prod` support
  - Updated `.gitignore` to exclude environment files
  - Documentation: `docs/guides/development/environment-setup.md`

✅ **Tech Stack Libraries Added**
  - **QR Code**: `pretty_qr_code: ^3.5.0` with `QrHelper` utility class
  - **Routing**: `go_router: ^14.0.0` (ready for migration)
  - **Networking**: `dio: ^5.4.0` + `retrofit: ^4.0.0`
  - **Local DB**: `drift: ^2.30.0` + `flutter_secure_storage: ^9.0.0`
  - **Code Gen**: `freezed`, `json_serializable`, `riverpod_generator`
  - **UI**: `flutter_screenutil: ^5.9.0` for responsive design
  - **Error Reporting**: `sentry_flutter: ^9.10.0` + `logger: ^2.0.0`
  - **Testing**: `mocktail: ^1.0.0` + `riverpod_lint: ^2.3.0`

✅ **Code Quality Enhancements**
  - Updated `analysis_options.yaml` with `riverpod_lint`
  - Enabled `avoid_print: true` (must use AppLogger)
  - Added Riverpod best practices rules
  - Updated `.cursor/.cursorrules` with new tech stack standards

✅ **Documentation Created**
  - `docs/guides/development/environment-setup.md`
  - `docs/guides/development/qr-code-usage.md`
  - `SETUP_ENV.md` - Quick setup guide
  - `SETUP_COMPLETE.md` - Complete setup summary
  - `CHANGELOG_TECH_STACK.md` - Detailed changelog

### Comprehensive Documentation Updates (NEW - 2026-01-13)
✅ **Drawer System Documentation** - Complete reference in DESIGN_SYSTEM_GUIDE.md
  - Architecture overview with 5 core components
  - File structure and usage patterns
  - Integration examples with Scaffold
  - Design rules and best practices
  - References to all drawer-related widgets

✅ **Search System Documentation** - Enhanced in systemPatterns.md
  - Overview of search system architecture
  - Smart Search Dialog V2 with advanced features
  - Smart Search Dialog (original) with basic features
  - Search Field widget documentation
  - Usage examples and integration patterns

### Dialog System Implementation (NEW - 2026-01-14)
✅ **Flexible Dialog System** - Complete modular dialog system
  - **FlexibleDialog**: Core widget with 5 types (success, warning, error, info, confirm)
  - **SuccessDialog**: Specialized success dialogs with multiple variants
  - **WarningDialog**: Confirmation and warning dialogs with destructive actions
  - **ErrorDialog**: Error handling dialogs with retry options
  - **DialogExamples**: 10+ real-world usage examples
  - **README.md**: Comprehensive documentation with integration guide

✅ **Responsive Design Implementation**
  - Mobile: 90% width, max 340px
  - Tablet: 70% width, max 480px
  - Desktop: 50% width, max 560px
  - Automatic calculation based on MediaQuery and DesignBreakpoints

✅ **Design System Compliance**
  - All dialogs use DesignTokens (colors, spacing, typography, icons)
  - Consistent animation (fade + scale transitions)
  - Dark mode support (automatic theme adaptation)
  - Accessibility standards (proper touch targets, contrast ratios)

✅ **Reusable Component Library**
  - Standardized dialog patterns across app
  - Easy integration with existing screens
  - Replaceable for all current dialog implementations
✅ Supabase service initialization & configuration
✅ Authentication system (sign-in, sign-up, sign-out)
✅ AuthViewModel with full state management
✅ AuthRepositoryImpl with proper error handling & Vietnamese messages
✅ Profile entity model
✅ BaseTableDataSource for generic Supabase queries
✅ Role-based routing (student/teacher/admin dashboards)
✅ Splash screen with auto-navigation
✅ Login & Register screens (basic UI)
✅ Dashboard screens for all three roles (basic skeletons)
✅ App theme configuration (Material Design)

### Drawer System Implementation (NEW - 2026-01-11)
✅ **Drawer System Architecture** - Complete modular drawer system
  - **ActionEndDrawer**: Universal drawer container (340px width)
  - **ClassSettingsDrawer**: Class-specific settings content
  - **DrawerSectionHeader**: Section headers with icons
  - **DrawerActionTile**: Action items with icons, titles, subtitles
  - **DrawerToggleTile**: Toggle switches for settings

✅ **TeacherClassDetailScreen Integration**
  - Added endDrawer with ClassSettingsDrawer
  - Implemented "more_vert" button to open drawer
  - Fixed color issues (Theme.of(context).cardColor → DesignColors.white)

✅ **Design System Compliance**
  - All drawer components use DesignTokens
  - Consistent spacing, typography, colors
  - Responsive design with SingleChildScrollView

✅ **Reusable Component Library**
  - Drawer system can be extended for other screens
  - Standardized drawer width (340px)
  - Consistent UI patterns across app

### Performance & Async List Pattern (NEW - 2026-01-29)
✅ **Logging & File I/O Safety**
  - All debug file logging now guarded by `kDebugMode && Platform.isWindows` to avoid crashes on Android/iOS.
  - Switched to async `writeAsString` with `.catchError` to prevent blocking the main thread and frame drops.
✅ **Shimmer Loading Standardization**
  - Introduced three shimmer patterns:
    - `ShimmerLoading` for card-style lists (e.g. classes).
    - `ShimmerListTileLoading` for compact list tiles (avatar + 2 lines).
    - `ShimmerDashboardLoading` for dashboard layouts.
  - Updated `StudentClassListScreen` to use `ShimmerListTileLoading` for initial and loading states to keep transitions smooth.
✅ **Async ListPage & Background Parsing**
  - Created `AsyncListPage<T>` (`lib/widgets/async/async_list_page.dart`) to standardize async list loading:
    - Accepts `Future<List<T>>` + `itemBuilder`.
    - Uses shimmer list tiles while loading.
    - Provides DesignTokens-based empty/error states.
  - Pattern: Data layer parses large JSON payloads in a background isolate (via `compute`), UI only consumes `Future<List<T>>` for smooth 60fps transitions.

## Currently In Progress
🔄 **Assignment Creation Feature** - Starting Chapter 1
   - Assignment entity model
   - Question types enum
   - AssignmentRepository (domain interface)
   - AssignmentDataSource (Supabase queries)
   - AssignmentRepositoryImpl
   - AssignmentViewModel (for creation flow)
   - Assignment builder UI screens

## Immediate Next Steps (1-2 weeks)
1. **Create Assignment Data Models**
   - Assignment entity (id, title, description, created_by, due_date, rubric, etc.)
   - Question entity (type, content, options, points)
   - Complete domain structure

2. **Build Assignment DataSource**
   - Create assignment in Supabase
   - Fetch assignments by teacher
   - Update assignment
   - Delete assignment
   - Add questions to assignment

3. **Implement AssignmentRepository**
   - Wrap DataSource calls
   - Error translation to Vietnamese
   - Return domain entities

4. **Create AssignmentViewModel**
   - State: creatingAssignment, loadingAssignments, etc.
   - Methods: createAssignment(), saveQuestion(), publishAssignment()
   - Validation logic

5. **Build Assignment Builder Screens**
   - Assignment details screen (title, description, due date, learning objectives)
   - Question builder screen (add questions, set point values)
   - Rich text editor integration (for question content)
   - Preview assignment screen
   - Publish confirmation

## Critical Technical Decisions Made

### 1. State Management
- **Decision:** Provider + ChangeNotifier (MVVM pattern)
- **Why:** Simple, lightweight, works seamlessly with Flutter, excellent for MVVM
- **Impact:** All ViewModels follow ChangeNotifier pattern with explicit provider setup

### 2. Error Handling
- **Decision:** Translate all errors to Vietnamese in Repository layer
- **Why:** Users see errors in their language; ViewModels handle generic error state
- **Rationale:** Separates business logic (translation) from UI layer
- **Implementation:** Custom `CustomException` class with message field

### 3. Supabase Access
- **Decision:** ALL Supabase calls confined to `data/datasources/` layer only
- **Why:** Enforces clean architecture; makes testing easier; centralizes data logic
- **Enforcement:** Code reviews must catch direct Supabase imports in other layers

### 4. Role-Based Navigation
- **Decision (UPDATED 2026-01-21):** Sử dụng **GoRouter** với `appRouterProvider` để điều hướng dựa trên `profile.role`.
- **Why:** Different users cần UI khác nhau; GoRouter + Riverpod cho phép guard rõ ràng, deep-link tốt hơn và dễ test.
- **Implementation:** Logic định tuyến nằm trong `lib/core/routes/app_router.dart` (GoRouter) thay vì `AppRoutes` legacy.

### 5. Rich Text Support
- **Decision:** Use simple text fields initially; plan Flutter_Quill or Markdown package later
- **Why:** MVP first; rich text adds complexity (rendering, storage, server-side parsing)
- **Timeline:** Add in Chapter 1.5 if time permits; prioritize question creation flow

### 6. Auto-Save Pattern
- **Decision:** Will use debounce (wait 2 seconds after user stops typing) + SharedPreferences backup
- **Why:** Prevent data loss; show user confidence in saves
- **Implementation:** Debounce in ViewModel; save to SharedPreferences locally; sync to Supabase every 2 seconds

### 7. Image/File Uploads
- **Decision:** Use Supabase Storage (bucket per user for organization)
- **Why:** Integrated with auth; simple API; cost-effective
- **Scope:** First implement in Chapter 2 (student workspace); later for assignment media

## Known Issues & Blockers

### Design System Consolidation ✅ (Completed 2026-01-09)
- ✅ Created `lib/core/constants/design_tokens.dart` with comprehensive design token system
- ✅ Consolidated Moon/Teal color palette (removed conflicting blue colors)
- ✅ Defined spacing scale (4dp base, xs-xxxxxxl tokens)
- ✅ Defined typography scale (8 levels with predefined TextStyles)
- ✅ Defined icon sizing (16-64 dp scale)
- ✅ Defined border radius scale (0-50+ dp)
- ✅ Defined elevation/shadow system (5 levels)
- ✅ Documented component sizing standards (buttons, inputs, cards, AppBar, etc.)
- ✅ Defined responsive breakpoints (mobile-first, 320-1200dp+)
- ✅ Defined animation durations & curves
- ✅ Documented accessibility minima (48x48 touch targets, contrast ratios)
- ✅ Updated `ui_constants.dart` to use design_tokens as source (deprecated, backward compatible)
- ✅ Updated systemPatterns.md with full design system section
- **Next:** Migrate widget implementations to use new design tokens (component refactoring)

### Minor Issues
- ⚠️ Folder naming typo: `lib/core/ultils/` should be `lib/core/utils/` (TODO: Refactor later)
- ⚠️ Dashboard screens are skeleton-only (no real data flowing)
- ⚠️ **DESIGN SYSTEM:** Old hardcoded sizes still exist in widgets
  - ClassItemWidget uses 120dp (should be 100dp target)
  - StudentDashboardScreen AppBar uses 80dp (should be 56dp target)
  - TextFormFields use 56dp (should be 48dp target)
  - **Fix Timing:** Next sprint (component refactoring phase)

### Architectural Debt (Future)
- Use cases layer not yet implemented (currently domain interfaces → repos directly)
- No comprehensive error boundaries on screens
- No offline-first capability (will need later)
- Analytics module architecture not designed yet

## Important Notes & Learnings

### Pattern Enforcement
- Strictly enforce Clean Architecture boundaries (no shortcuts)
- ViewModels are NOT supposed to handle error translation; that's Repository job
- Views should not have business logic (even simple validation)
- Always ask: "Which layer should this responsibility belong to?"

### Vietnamese Language Handling
- All error messages to users: Vietnamese
- All function names & class names: English
- All code comments: English (technical) or Vietnamese (business logic)
- String constants for UI labels should be in a `strings.dart` file (to be created for i18n later)

### Supabase Quirks
- RLS policies must be set up before any data operations (security)
- Real-time subscriptions drain battery; use judiciously
- Storage paths are flat (create semantic naming convention)
- Auth tokens expire; auto-refresh requires flutter_secure_storage

### Code Organization
- Prefer many small, focused files over large monolithic ones
- Each screen gets its own ViewModel (not shared)
- Reusable UI components go in `widgets/` folder
- Constants go in `core/constants/` (organize by feature if large)

## Active Preferences & Standards

> **Lưu ý:** Các quy tắc code quality nghiêm ngặt (functions ≤ 50 dòng, classes ≤ 300 dòng, dart format, flutter analyze) được định nghĩa trong `.clinerules` (Code Quality section). Phần này mô tả preferences và standards hiện tại của team.

### Code Style
- Use `const` constructors wherever possible (performance)
- Prefer null-safety (`?` and `!` operator usage)
- Use meaningful variable names (no `x`, `y`, `temp`)
- Single responsibility principle for all classes

### File Organization
- One entity per file
- Keep files < 300 lines (split if larger) - *Xem quy tắc nghiêm ngặt trong `.clinerules`*
- Related functionality groups in subdirectories
- Clear import organization (dart, package, relative imports)

### Comments & Documentation
- Docstrings on all public methods (what it does, params, returns)
- Inline comments only for non-obvious logic
- Avoid over-commenting (code should be self-documenting)
- Vietnamese comments acceptable for business logic clarification

### Testing (Future Focus)
- Unit test all ViewModels
- Unit test all Repositories
- Widget test all screens
- Integration test critical user flows
- Target: 70%+ code coverage

## Collaboration Notes
- Always check .clinerules and memory-bank files before starting work
- Update activeContext.md after each significant change
- Document learnings and patterns as they emerge
- Keep progress.md updated with completed items

## Dependencies Considerations
- ✅ **Tech Stack Upgrade Complete** - All core libraries from Tech Stack Upgrade Plan added
- ✅ **Dependency Review Complete (2026-01-21)** - Reviewed unused dependencies
  - **Drift**: KEEP - Planned for offline-first features
  - **Retrofit/Dio**: KEEP - Planned for external API integration
  - **Freezed**: ACTIVELY USED - Domain entities use `@freezed` annotation
- Review new dependency additions (ask: Is it really needed?)
- Keep pubspec.yaml lean (avoid bloat)
- Monitor breaking changes in major updates
- **Current Dependencies:**
  - ✅ Environment: `envied` (implemented)
  - ✅ Secure Storage: `flutter_secure_storage` (added)
  - ✅ QR Code: `pretty_qr_code` (added)
  - ✅ Routing: `go_router` (added, ready for migration)
  - ✅ Networking: `dio` + `retrofit` (added, ready for external APIs)
  - ✅ Local DB: `drift` (added, ready for offline-first)
  - ✅ Code Gen: `freezed`, `json_serializable`, `riverpod_generator` (added, freezed actively used)
  - ✅ Error Reporting: `sentry_flutter` + `logger` (added)
- **Future Dependencies:**
  - Plan for: `intl` (i18n), `image_picker`, `charts_flutter`

## Performance Targets
- App startup: < 3 seconds (cold start)
- Screen transitions: < 300ms
- API responses: < 2 seconds average
- APK size: < 100 MB

## Next Memory Bank Update Triggers
- After completing Chapter 1 (Assignment Builder)
- When major architectural decisions are made
- When new patterns emerge (document them!)
- Weekly sprint reviews

---

# XEM THÊM

Để tìm hiểu thêm về các chủ đề liên quan, tham khảo:

- **Code Quality Rules:** `.clinerules` (Code Quality section)
- **System Architecture:** `memory-bank/systemPatterns.md` (Overall Architecture section)
- **Technology Stack:** `memory-bank/techContext.md`
- **Directory Structure:** `AI_INSTRUCTIONS.md` (Section 1)
- **MCP Usage Patterns:** `AI_INSTRUCTIONS.md` (Section 10) và `.clinerules` (Database & MCP section)
- **Design System:** `memory-bank/systemPatterns.md` (Design System Specifications section)
- **Git Workflow:** `.clinerules` (Git Workflow section)
- **Flutter Refactoring Rules:** `.clinerules` (Flutter Refactoring section)
