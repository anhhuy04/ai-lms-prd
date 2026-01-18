# Active Context

## Current Sprint Focus
**Goal:** Complete Authentication & Foundational Setup, then move into Chapter 1 (Assignment Builder)

## Project Phase
**Phase:** Early Development (Chapters 1-2 prioritized)

## Recently Completed
✅ Project structure established (Clean Architecture + MVVM)

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
- **Decision:** After login, check profile.role and route to appropriate dashboard
- **Why:** Different users need different UIs; simplifies conditional rendering
- **Implementation:** In AppRoutes, route determination happens immediately post-auth

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
- Review new dependency additions (ask: Is it really needed?)
- Keep pubspec.yaml lean (avoid bloat)
- Monitor breaking changes in major updates
- **Current Dependencies:**
  - ✅ Environment: `envied` (implemented)
  - ✅ Secure Storage: `flutter_secure_storage` (added)
  - ✅ QR Code: `pretty_qr_code` (added)
  - ✅ Routing: `go_router` (added, ready for migration)
  - ✅ Networking: `dio` + `retrofit` (added)
  - ✅ Local DB: `drift` (added)
  - ✅ Code Gen: `freezed`, `json_serializable`, `riverpod_generator` (added)
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
