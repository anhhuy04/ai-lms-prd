# System Patterns & Architecture

## Overall Architecture: Clean Architecture + MVVM

### Dependency Flow (Strict Unidirectional)
```
Presentation Layer (UI)
  ↓ (depends on)
Domain Layer (Business Logic - Abstract)
  ↓ (depends on)
Data Layer (Implementation)
```

**Key Rule:** Each layer ONLY knows about the layer directly below it. No reverse dependencies.

### Layer Responsibilities

#### Presentation Layer (`lib/presentation/`)
**Responsibility:** Render UI, capture user input, trigger business logic

- **Views/Screens** (`views/`) - Stateless/stateful widgets representing pages
- **ViewModels** (`viewmodels/`) - ChangeNotifier classes managing state & logic
  - One ViewModel per screen (ideally)
  - Holds all business logic (not in View)
  - Notifies Views of state changes
  - Converts domain responses to UI-friendly format
  - Handles error display (toast, dialogs, error states)

**Pattern:** Each screen uses `ChangeNotifierProvider` from Provider package to inject ViewModel

```dart
// Example in main.dart
ChangeNotifierProvider(
  create: (_) => AuthViewModel(
    repository: context.read<AuthRepository>(),
  ),
  child: LoginScreen(),
)
```

#### Domain Layer (`lib/domain/`)
**Responsibility:** Define business rules & interfaces (no implementation details)

- **Entities** (`entities/`) - Domain models (e.g., Profile, Assignment)
  - Pure data classes with no Supabase/framework dependencies
  - Represent "what the system knows about"
  
- **Repositories** (`repositories/`) - Abstract interfaces for data operations
  - Define what operations should be available (e.g., `loginUser()`, `fetchAssignments()`)
  - No Supabase/implementation details here
  - Return domain entities or domain-level errors
  
- **Use Cases** (`usecases/`) - Optional layer for complex business logic
  - Encapsulate specific business operations
  - Can combine multiple repository calls
  - Example: `SubmitAssignmentUseCase` (validates + saves submission + triggers grading)

#### Data Layer (`lib/data/`)
**Responsibility:** Implement data access, convert between formats

- **Data Sources** (`datasources/`) - Direct Supabase/API calls
  - **RULE:** ALL Supabase interaction happens here, nowhere else
  - `SupabaseDataSource` - Raw database operations (queries, inserts, updates)
  - Never called directly by Views or ViewModels
  - Returns raw response objects
  
- **Repositories** (`repositories/`) - Implement domain repository interfaces
  - Convert DataSource responses to Domain Entities
  - Handle errors and translate them to domain-level errors
  - Implement error recovery logic
  - Example: `AuthRepositoryImpl` implements `AuthRepository` interface

## State Management Pattern: Riverpod (Primary) + Provider (Legacy)

### Current State: Migration Complete (2026-01-20)
- **Riverpod** (v2.5.1) - Primary state management solution (MIGRATED)
  - Used for providers and reactive state
  - Code generation via `riverpod_generator` (v2.3.0) with `@riverpod` annotation
  - Better for dependency injection and state management
  - **Migration Status:** Hầu hết screens quan trọng đã migrate (login, register, splash, dashboards, class screens)
  - **Notifiers:** `AuthNotifier`, `ClassNotifier`, `StudentDashboardNotifier`, `TeacherDashboardNotifier` (AsyncNotifier pattern)
  - **Screens:** Đã convert sang `ConsumerWidget`/`ConsumerStatefulWidget` với `ref.watch()`/`ref.read()`
  - **Dashboard Refresh Pattern (2026-01-21):**
    - Refresh methods in dashboard notifiers only refresh data providers (classes, assignments)
    - **CRITICAL:** Do NOT call `checkCurrentUser()` in refresh methods to avoid auth state reset
    - Do NOT set state to `loading` in refresh (use `showLoading: false`) to prevent router redirect
    - Pattern: `refresh()` → read auth state → refresh data providers → preserve auth state
- **Provider** (v6.0.0) - Legacy support (còn một số screens/ widgets đơn giản)
  - Chỉ còn dùng trong một số screens/ widgets cũ (sẽ migrate dần)
  - ViewModels cũ vẫn tồn tại để tương thích ngược (không dùng cho code mới)

### Riverpod Pattern (Preferred for New Features)
```dart
// Using @riverpod code generation
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() async {
    return const AuthState.initial();
  }
  
  Future<void> loginUser(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      final user = await repository.loginUser(email, password);
      return AuthState.success(user);
    });
  }
}
```

### Provider Pattern (Legacy - Existing Code)
```dart
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  
  // State
  AuthState _state = AuthState.initial;
  String _errorMessage = '';
  User? _currentUser;
  
  // Getters
  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  
  // Methods
  Future<void> loginUser(String email, String password) async {
    _state = AuthState.loading;
    notifyListeners();
    
    try {
      final user = await _repository.loginUser(email, password);
      _currentUser = user;
      _state = AuthState.success;
    } on CustomException catch (e) {
      _errorMessage = e.message; // Already Vietnamese
      _state = AuthState.error;
    }
    notifyListeners();
  }
}

enum AuthState { initial, loading, success, error }
```

### View Integration with ViewModel
```dart
class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.state == AuthState.loading) {
          return LoadingWidget();
        }
        if (viewModel.state == AuthState.error) {
          return ErrorWidget(message: viewModel.errorMessage);
        }
        return LoginForm(onSubmit: (email, pwd) {
          viewModel.loginUser(email, pwd);
        });
      },
    );
  }
}
```

## Error Handling Pattern

### Error Flow
1. **DataSource** - Catches Supabase/network errors → throws `CustomException`
2. **Repository** - Catches `CustomException` → translates message to Vietnamese → re-throws
3. **ViewModel** - Catches exception → stores error message → updates state to `error`
4. **View** - Reads error message → displays to user in Vietnamese

```dart
// Example in Repository
Future<User> loginUser(String email, String password) async {
  try {
    final response = await _dataSource.loginUser(email, password);
    return User.fromJson(response);
  } on CustomException catch (e) {
    // Translate error message to Vietnamese
    final message = _translateError(e);
    throw CustomException(message: message);
  }
}
```

## Key Technical Decisions

### 1. Supabase as Backend
- **Why:** Simplifies backend (auth, realtime DB, storage, edge functions)
- **Constraint:** ALL Supabase calls in `data/datasources/` only
- **Real-Time Support:** Leverage Supabase Realtime for live updates (submissions, grades)

### 2. Riverpod for State Management (Primary)
- **Why:** Modern, powerful, excellent for dependency injection and state management
- **Pattern:** Use `@riverpod` code generation for providers and notifiers
- **Dependency Injection:** Use Riverpod providers for all dependencies
- **Migration:** Gradually migrate from Provider to Riverpod for new features

### 2b. Provider for State Management (Legacy Support)
- **Why:** Existing codebase uses Provider for ViewModels
- **Pattern:** Each feature has own ViewModel as ChangeNotifier
- **Dependency Injection:** Use `ChangeNotifierProvider` with explicit constructor dependencies
- **Status:** Coexists with Riverpod, will be gradually migrated

### 2c. Async List & Background Parsing Pattern (2026-01-29)
- **Goal:** Avoid jank (16ms/frame) when loading large lists (e.g. 500+ items).
- **Data Layer Rule:** Heavy JSON parsing must run in background isolate using `compute` (or explicit Isolate) inside datasources; repositories expose `Future<List<Entity>>` to domain/UI.
- **UI Pattern:** Use generic `AsyncListPage<T>` (`lib/widgets/async/async_list_page.dart`) for new list screens:
  - Accepts `Future<List<T>>` + `itemBuilder`.
  - Uses shimmer skeletons (`ShimmerListTileLoading`) while loading.
  - Provides standardized empty/error states using DesignTokens.
- **Existing Screens:** Legacy lists (e.g. teacher/student class lists) may keep custom Riverpod + pagination logic; new heavy lists should prefer `AsyncListPage<T>` + background parsing.

### Student Class Management Patterns (NEW - 2026-01-29)
✅ **Student Class List Features**
  - **Sorting**: Use `ClassSortBottomSheet` reusable widget with `ClassSortOption` enum (name A-Z/Z-A, date newest/oldest)
  - **Filtering**: Use `FilteringUtils.filterStudentClasses()` with `StudentClassFilterOption` enum (all/approved/pending)
  - **Search**: Dedicated `StudentClassSearchScreen` using generic `SearchScreen<Class>` pattern
  - **Status Handling**: Use `StudentClassMemberStatus` enum for type-safe status representation
  - **Pending Class Interaction**: Use `StudentClassInteractionHandler.handleClassTap()` for centralized logic
  - **Data Enrichment**: `getClassesByStudent` enriches data with `teacher_name` and `student_count` via SQL joins

✅ **Student Leave Class Pattern**
  - **Decision**: Xóa hoàn toàn record khỏi `class_members` (không chỉ đổi status)
  - **Flow**: Repository → Datasource → Notifier → UI Handler
  - **UI Pattern**: Confirmation dialog → Loading → Success/Error SnackBar → Navigate back
  - **State Update**: Auto-refresh class list after leaving (remove from state)

✅ **QR Scan Screen Pattern (Banking App Style)**
  - **Overlay**: Custom painter với cutout (khoét lỗ) ở giữa màn hình
  - **Camera Control**: `MobileScannerController` để toggle flash và analyze image
  - **Image Picker**: `image_picker` package để chọn ảnh từ thư viện
  - **Scan from Image**: `analyzeImage(file.path)` để scan QR từ file
  - **UI Elements**: Modern app bar, scan frame corners, animated scan line, processing overlay

✅ **Search & Display Patterns**
  - **Highlight**: Highlight teacher name instead of academic year in search results
  - **Search Filter**: Only search by name, subject, teacher name (academic year excluded)
  - **Avatar**: Display first letter of given name (tên) instead of surname (họ) - Vietnamese culture
  - **Student Count**: Dynamic count from database aggregation (status='approved' only)

### 3. Clean Architecture Layers
- **Why:** Separates concerns, enables testing, makes feature changes easier
- **Trade-off:** More boilerplate, but pays off as project scales
- **Enforcement:** Code review must ensure no layer jumps (no direct DataSource in Views)

### 4. Router Architecture (Tứ Trụ: GoRouter + Riverpod + RBAC + ShellRoute) - v2.0 PRODUCTION READY

**Core Philosophy:**
- Router as **infrastructure layer** - NO UI logic, NO business logic
- Named routes + static path helpers (NOT hardcoded paths)
- RBAC guards automatic via redirect (3-step check: public → auth → role)
- ShellRoute preserves bottom nav during navigation

**Key Components:**
- `lib/core/routes/route_constants.dart` - ALL route names, paths, helpers (Single Source of Truth)
  - Route names: `static const String studentClassDetail = 'student-class-detail'`
  - Path constants: `static const String studentClassDetailPath = '/student/class/:classId'`
  - Path helpers: `static String studentClassDetailPath(String classId) => '/student/class/$classId'`
  - RBAC helpers: `canAccessRoute(role, routeName)`

- `lib/core/routes/app_router.dart` - GoRouter configuration (routes, ShellRoute, redirect)
  - ShellRoute for Student/Teacher/Admin (preserves bottom nav)
  - All routes have `name` property (enable `context.goNamed()`)
  - RBAC redirect in redirect callback (public → auth → role check)
  - Provider: `appRouterProvider` (Riverpod)

- `lib/core/routes/route_guards.dart` - Utility functions
  - `isAuthenticated(ref)`, `getCurrentUserRole(ref)`, `canAccessRoute(ref, routeName)`
  - `appRouterRedirect()` - 3-step RBAC guard

**RBAC Redirect Flow:**
```
Step 1: Public route? (splash, login, register, reset-password, verify-email) → Allow
Step 2: Authenticated? No → Redirect /login?redirect=... ; Yes → Step 3
Step 3: Role match? No → Redirect to role's dashboard ; Yes → Allow
```

**Navigation Pattern (MUST USE):**
```dart
// ✅ Use named routes
context.goNamed(
  AppRoute.teacherEditClass,
  pathParameters: {'classId': id},
  extra: objectIfNeeded,
);

// ✅ Use path constants
context.go(AppRoute.studentJoinClassPath);

// ❌ Never use
context.go('/teacher/class/$id/edit');
Navigator.push(context, MaterialPageRoute(...));
```

**File Updates (Completed 2026-01-21):**
- ✅ route_constants.dart - Refactored with all 20+ routes, path helpers, RBAC
- ✅ app_router.dart - ShellRoute + RBAC redirect integrated
- ✅ route_guards.dart - Clean utility functions
- ✅ 5 UI screens updated (splash, drawer, detail, profile, dashboards)

**Next: Apply same pattern to remaining 20+ screens**

### 5. Auto-Save Pattern (for Workspace)
- **Why:** Prevent student work loss; improve confidence
- **Implementation:** 
  - Debounce text input changes (wait 2 seconds after user stops typing)
  - Call `UpdateAssignmentResponse` use case
  - Show subtle "Saving..." indicator
  - Store local draft in SharedPreferences as backup

## Component Relationship Map

```
AuthViewModel
  └─ depends on → AuthRepository (domain interface)
                    └─ implemented by → AuthRepositoryImpl
                                          └─ depends on → SupabaseDataSource
                                          
StudentDashboardViewModel
  └─ depends on → AssignmentRepository (domain interface)
  └─ depends on → AnalyticsRepository (domain interface)
  
TeacherDashboardViewModel
  └─ depends on → GradingRepository (domain interface)
  └─ depends on → AnalyticsRepository (domain interface)
```

## Code Organization Patterns

### Naming Conventions
- **Screens:** `*_screen.dart` (e.g., `login_screen.dart`)
- **ViewModels:** `*_viewmodel.dart` (e.g., `auth_viewmodel.dart`)
- **Entities:** Lowercase entity name (e.g., `profile.dart`)
- **Repositories (interface):** `*_repository.dart`
- **Repositories (impl):** `*_repository_impl.dart`
- **DataSources:** `*_datasource.dart`

### Documentation Language
- **Function/class names:** English
- **Comments & docstrings:** English for technical; Vietnamese for business logic
- **Error messages:** Vietnamese (for user-facing errors)
- **UI labels:** Vietnamese

---

## Search System Patterns

### Overview
The search system provides advanced search functionality across the application with multiple search dialog variants and reusable search field components.

### Smart Search Dialog V2
**Location:** `lib/widgets/search/smart_search_dialog_v2.dart`

**Purpose:** Advanced search functionality for class details with validation and auto-capitalization

**Key Features:**
- **Conditional Rendering**: Sections only appear when search query is not empty
- **Validation**: Phone (10-11 digits), Email (proper format), Name (auto-capitalization)
- **Section Organization**: Results grouped by Assignments, Students, Classes
- **Keyword Highlighting**: Search terms highlighted in results
- **Empty State**: Shows "No results" message when appropriate

**Usage Example:**
```dart
showDialog(
  context: context,
  builder: (context) => SmartSearchDialogV2(
    initialQuery: '',
    assignments: assignmentList,
    students: studentList,
    classes: classList,
    onItemSelected: (item) {
      // Handle selected item
      Navigator.pop(context);
    },
  ),
);
```

### Smart Search Dialog (Original)
**Location:** `lib/widgets/search/smart_search_dialog.dart`

**Purpose:** Basic search functionality with recent searches and results

**Key Features:**
- **Recent Searches**: Shows previous search queries
- **Results Section**: Displays search results
- **Empty State**: Handles no results scenario

### Search Field Widget
**Location:** `lib/widgets/search_field.dart`

**Purpose:** Reusable search input field with icon and validation

**Key Features:**
- **Standardized Design**: Uses DesignTokens for consistent styling
- **Validation**: Built-in validation support
- **Reusable**: Can be used across multiple screens

## Design System Specifications

### Single Source of Truth
**Location:** `lib/core/constants/design_tokens.dart`

**Deprecated:** `lib/core/constants/ui_constants.dart` (kept for backward compatibility, all new code must use design_tokens.dart)

### Color Palette (Moon + Teal Theme)

#### Primary Palette
| Name | Color | Use Case |
|------|-------|----------|
| `moonLight` | #F5F7FA | Primary background (scaffold) |
| `moonMedium` | #E9EEF3 | Secondary background |
| `moonDark` | #DEE4EC | Tertiary background (disabled states) |
| `tealPrimary` | #0EA5A4 | Brand primary (buttons, links, accents) |
| `tealDark` | #0B7E7C | Darker variant (hover states, secondary) |
| `tealLight` | #14B8A6 | Lighter variant (accents) |
| `textPrimary` | #04202A | Text on light backgrounds |
| `textSecondary` | #546E7A | Secondary text (hints, captions) |

#### Semantic Colors
| Name | Color | Use Case |
|------|-------|----------|
| `success` | #4CAF50 | Success states, badges |
| `warning` | #FFA726 | Warnings, alerts |
| `error` | #EF5350 | Error messages, invalid states |
| `info` | #29B6F6 | Info notifications |

**Rule:** MUST import from `DesignColors` in design_tokens.dart. Do NOT use hardcoded color values.

### Spacing Scale (Base Unit: 4dp)

| Token | Value | Semantic Name | Common Use |
|-------|-------|---------------|------------|
| `xs` | 4 dp | Minimal padding | Icon spacing inside buttons |
| `sm` | 8 dp | Small padding | List item margin, form field margin |
| `md` | 12 dp | Medium padding (1.5x) | Card margin bottom, section dividers |
| `lg` | 16 dp | **STANDARD** (2x) | Card padding, screen padding, button padding |
| `xl` | 18 dp | Extra large (2.25x) | Section spacing, large gaps |
| `xxl` | 22 dp | Double extra (2.75x) | Major section breaks |
| `xxxl` | 28 dp | Triple extra (3.5x) | Large section separators |
| `xxxxl` | 36 dp | Quad extra (4.5x) | Large component spacing |
| `xxxxxl` | 44 dp | Five extra (5.5x) | Very large gaps |
| `xxxxxxl` | 56 dp | Six extra (7x) | Maximum spacing |

**Formula:** `spacing = 4 * multiplier` (e.g., lg = 4 * 4 = 16dp)

**Rule:** MUST use predefined tokens from `DesignSpacing`. Do NOT hardcode spacing values.

**Responsive Spacing (Updated 2026-01-21):**
- Use `context.spacing.md`, `context.spacing.lg`, etc. for responsive spacing
- Automatically scales based on device type (mobile/tablet/desktop)
- See "Responsive Spacing System" section in Widget Component Patterns for details

### Typography Scale

#### Font Sizes
| Level | Large | Medium | Small | Font Weight | Line Height | Use Case |
|-------|-------|--------|-------|-------------|-------------|----------|
| **Display** | 32dp | 28dp | 24dp | Bold | 1.25 | Page hero titles |
| **Headline** | 24dp | 20dp | 18dp | Semi-Bold | 1.4 | Section titles, page headers |
| **Title** | 20dp | 16dp | 14dp | Bold | 1.4 | Card titles, dialog headers |
| **Body** | 16dp | 14dp | 12dp | Regular | 1.5 | Main content text |
| **Label** | 14dp | 12dp | 11dp | Medium | 1.4 | Button text, badges |
| **Caption** | 12dp | - | - | Regular | 1.4 | Helper text, timestamps |

**Current Standards (DO NOT CHANGE):**
- Title Large: 20dp, bold ✅
- Body Medium: 14dp, regular ✅

**Rule:** Use predefined `TextStyle` objects from `DesignTypography` class (e.g., `DesignTypography.titleLarge`).

### Icon Sizing Scale

| Token | Size | Common Use |
|-------|------|------------|
| `xsSize` | 16 dp | Decorative icons, badges |
| `smSize` | 20 dp | Form field icons, small actions |
| `mdSize` | **24 dp** | **STANDARD** - button icons, toolbar icons |
| `lgSize` | 32 dp | Empty state icons |
| `xlSize` | 48 dp | Avatar images |
| `xxlSize` | 64 dp | Hero icons, profile avatars |

**Rule:** Use `DesignIcons.<size>` constants. Do NOT use arbitrary icon sizes.

### Border Radius Scale

| Token | Value | Use Case |
|-------|-------|----------|
| `none` | 0 dp | No rounding |
| `xs` | 4 dp | Subtle rounding |
| `sm` | 8 dp | **STANDARD** - buttons, input fields |
| `md` | 12 dp | **STANDARD** - cards, modals |
| `lg` | 16 dp | Larger containers |
| `full` | 50+ dp | Pill-shaped badges, circular avatars |

**Rule:** Use `DesignRadius.<token>`. Do NOT use arbitrary radius values.

### Elevation & Shadow System

| Level | Blur | Offset | Use Case |
|-------|------|--------|----------|
| **0** | None | None | Flat surfaces (no depth) |
| **1** | 3 dp | 0, 1 | Subtle elevation (button hover) |
| **2** | 6 dp | 0, 3 | Standard cards, list items |
| **3** | 16 dp | 0, 6 | Dialog containers, popovers |
| **4** | 24 dp | 0, 12 | Modal dialogs, FABs |
| **5** | 24 dp | 0, 16 | Drawer, app-level floating elements |

**Rule:** Use `DesignElevation.level<N>` shadow constants. Do NOT create custom shadows.

### Component Sizing Reference Table

#### Target Sizes (Optimized, Post-Reduction)

| Component | Height | Width | Padding | Radius | Notes |
|-----------|--------|-------|---------|--------|-------|
| **Button (Medium)** | 44 dp | auto | 16 dp H, 12 dp V | 8 dp | STANDARD button size |
| **Button (Small)** | 36 dp | auto | 12 dp H, 8 dp V | 8 dp | Compact buttons |
| **Button (Large)** | 52 dp | auto | 20 dp H, 16 dp V | 8 dp | CTA buttons |
| **Input Field** | 48 dp | full | 16 dp | 8 dp | **REDUCED** from 56 dp |
| **Card** | min 100 dp | full-padding | 16 dp | 12 dp | **REDUCED** from 120 dp, min height |
| **AppBar** | 56 dp | full | 16 dp | 0 dp | **REDUCED** from 80 dp (Material standard) |
| **Bottom Nav** | 56 dp | full | 8 dp | 0 dp (top 12 dp) | Material standard |
| **FAB** | 56 dp | 56 dp | N/A | full | Standard Material FAB |
| **Avatar (Medium)** | 44 dp | 44 dp | N/A | full | **STANDARD** |
| **Avatar (Large)** | 64 dp | 64 dp | N/A | full | Profile/hero avatar |
| **Badge** | 24 dp | auto | 8 dp H, 4 dp V | full | Pill-shaped status badge |
| **List Item** | 48 dp | full | 16 dp | 0 dp | Minimum touch target (per Material) |
| **Chip/Tag** | 32 dp | auto | 12 dp | full | Filter/category tag |
| **Dialog** | auto | 280-560 dp | 16 dp | 16 dp | Modal dialog sizing |

## Widget Component Patterns

### Widget Organization Structure (Updated 2026-01-21)

**Directory Structure:**
```
lib/widgets/
├── dialogs/          # Dialog widgets (error, success, warning, etc.)
├── drawers/          # Shared drawer primitives (action tiles, toggle tiles, etc.)
├── list/             # List container widgets
├── list_item/        # Individual list item widgets
├── loading/          # Loading states (shimmer, skeletons, etc.)
├── navigation/       # Navigation handlers và utilities
├── responsive/       # Responsive layout widgets
├── search/           # Search-related widgets (screens, dialogs, fields)
└── text/             # Text utilities (highlight, marquee, etc.)
```

**Quy tắc phân loại:**
- `lib/widgets/`: **shared/reusable UI** (không chứa logic nghiệp vụ theo feature)
- `lib/presentation/views/**/widgets/`: widget **gắn với 1 feature/screen** (đặc biệt là drawers theo role)

**Key Widgets:**
- `ClassItemWidget` (`list_item/`): Hiển thị item lớp học, hỗ trợ search highlighting
- `SearchScreen<T>` (`search/`): Generic search screen có thể tái sử dụng cho nhiều loại dữ liệu
- `SmartHighlightText` (`text/`): Highlight text với từ khóa tìm kiếm (hỗ trợ tiếng Việt không dấu)
- `ResponsiveSpacing` (`core/constants/design_tokens.dart`): Responsive spacing system

**Documentation:** Xem `lib/widgets/README.md` để biết chi tiết về từng widget và cách sử dụng.

### Responsive Spacing System (2026-01-21)

**Purpose:** Dynamic spacing adjustment based on device type (mobile/tablet/desktop)

**Location:** `lib/core/constants/design_tokens.dart`

**Usage:**
```dart
// Using extension (recommended)
final spacing = context.spacing;
padding: EdgeInsets.all(spacing.md),
SizedBox(height: spacing.lg),

// Or using static method
final spacing = DesignSpacing.responsive(context);
padding: EdgeInsets.all(spacing.md),
```

**Scaling Rules:**
- **Mobile:** 1.0x (base values)
- **Tablet:**
  - Small spacing (xs, sm): 1.1x
  - Medium spacing (md, lg): 1.15x
  - Large spacing (xl, xxl+): 1.25x
- **Desktop:**
  - Small spacing (xs, sm): 1.2x
  - Medium spacing (md, lg): 1.3x
  - Large spacing (xl, xxl+): 1.5x

**Implementation:**
- `ResponsiveSpacing` class: Calculates spacing based on device type
- `ResponsiveSpacingExtension` on `BuildContext`: Provides `context.spacing.*` access
- Automatic device detection via `MediaQuery` and `DesignBreakpoints`

**Benefits:**
- No hardcoded spacing values
- Automatic adaptation to different screen sizes
- Consistent spacing across all devices
- Easy to maintain and update

### DrawerToggleTile - Customizable Switch Sizing (2026-01-14)

**Purpose:** Drawer toggle component with customizable switch dimensions using Transform.scale

**File:** `lib/widgets/drawers/drawer_toggle_tile.dart`

**Constructor Parameters:**
```dart
DrawerToggleTile({
  required String title,           // Required: Tile title text
  String? subtitle,                // Optional: Subtitle text
  required bool value,             // Required: Current toggle value
  required ValueChanged<bool> onChanged, // Required: Callback on toggle
  IconData? icon,                  // Optional: Left icon
  double? iconSize,                // Optional: Icon size (uses defaultIconSize if null)
  TextStyle? titleStyle,           // Optional: Title text style
  TextStyle? subtitleStyle,        // Optional: Subtitle text style
  double? switchScale,             // NEW: Switch size scale (default: 1.0)
})
```

**Default Values:**
```dart
static double defaultIconSize = DesignIcons.mdSize;      // 22 dp
static double defaultSwitchScale = 1.0;                  // 100% original size
```

**Usage Examples:**
```dart
// Standard size (no parameter needed)
DrawerToggleTile(
  icon: Icons.lock,
  title: 'Khóa lớp học',
  subtitle: 'Chặn học sinh mới',
  value: false,
  onChanged: (val) { /* handle change */ },
)

// Smaller switch (80% size)
DrawerToggleTile(
  icon: Icons.lock,
  title: 'Khóa lớp học',
  value: false,
  onChanged: (val) { /* handle change */ },
  switchScale: 0.8,  // 20% smaller
)

// Larger switch (120% size)
DrawerToggleTile(
  icon: Icons.lock,
  title: 'Khóa lớp học',
  value: false,
  onChanged: (val) { /* handle change */ },
  switchScale: 1.2,  // 20% larger
)
```

**Implementation Details:**
- **Size Control:** Uses `Transform.scale(scale: switchScale ?? defaultSwitchScale)`
- **Fallback:** If `switchScale` is null, uses `defaultSwitchScale = 1.0`
- **No Breaking Changes:** Existing code works without modification
- **Flexibility:** Any scale value can be used (0.5 → 2.0 range recommended)

**Affected Components:**
- ClassSettingsDrawer (contains DrawerToggleTile instances)
- ClassAdvancedSettingsDrawer (contains DrawerToggleTile instances)

**Compilation Status:** ✅ No errors

---

### Responsive Breakpoints (Mobile-First)

| Breakpoint | Width Range | Device Type | Use Case |
|------------|-------------|-------------|----------|
| **Mobile Small** | 320-374 dp | iPhone SE | Minimal layout |
| **Mobile Medium** | 375-413 dp | iPhone 12 | Standard mobile (design target) |
| **Mobile Large** | 414+ dp | iPhone 12 Pro Max | Large phone optimization |
| **Tablet Small** | 600-767 dp | iPad mini | Two-column layouts |
| **Tablet Medium** | 768-1023 dp | iPad | Tablet-optimized UI |
| **Desktop** | 1200+ dp | Large screens | Full-feature layouts |

**Helper Methods:** Use `DesignBreakpoints.isMobile()`, `isTablet()`, `isDesktop()` to determine layout.

### Animation Durations

| Type | Duration | Curve | Use Case |
|------|----------|-------|----------|
| **Fast** | 150 ms | easeOut | Button press, quick feedback |
| **Normal** | 300 ms | easeInOut | **STANDARD** - fade, slide transitions |
| **Slow** | 500 ms | easeInOut | Drawer open, modal appear |
| **Very Slow** | 800 ms | easeIn | Scroll animations, hero transitions |

**Rule:** Use `DesignAnimations.duration*` constants.

### Accessibility Minima

- **Touch Target Size:** Minimum 48×48 dp (per Material Design)
- **Button Height:** Always ≥ 36 dp (can be 44 dp standard)
- **Icon Size:** Always ≥ 20 dp for clickable icons
- **Text Size:** Body text minimum 12 dp
- **Contrast Ratio:** AA level (4.5:1) minimum for text
- **Focus Indicator:** 2 dp border in teal when keyboard-focused

### Design System Enforcement Rules

1. **NO hardcoded colors** - Use `DesignColors.*`
2. **NO hardcoded spacing** - Use `DesignSpacing.*`
3. **NO custom font sizes** - Use `DesignTypography.*` TextStyle objects
4. **NO custom icon sizes** - Use `DesignIcons.*` constants
5. **NO custom border radius** - Use `DesignRadius.*`
6. **NO custom shadows** - Use `DesignElevation.level*`
7. **NO arbitrary component dimensions** - Reference `DesignComponents.*`

## Testing Strategy (Future)
- **Unit Tests:** ViewModels, Repositories, Use Cases
- **Widget Tests:** Individual screens, widgets
- **Integration Tests:** Full feature flows (auth → dashboard → create assignment)
- **Mocking:** Mock repositories in ViewModel tests; mock DataSource in Repository tests

## Performance Considerations
- **Lazy Loading:** Load assignments/submissions in paginated chunks
- **Caching:** Cache profiles, class info in SharedPreferences
- **Image Optimization:** Compress images before upload to Supabase Storage
- **Realtime Limits:** Don't subscribe to large tables; use polling for less critical updates
- **Bundle Size:** Monitor APK size; lazy-load feature screens

## Security Patterns
- **Row-Level Security (RLS):** Use Supabase RLS policies to prevent unauthorized data access
- **Token Management:** Store JWT tokens securely using flutter_secure_storage
- **Input Validation:** Validate all user input before sending to backend
- **API Rate Limiting:** Prevent spam; implement debouncing for frequent operations

### Supabase RLS Conventions (Updated 2026-01-30)
- **auth.uid() pattern:** Trong mọi policy mới, LUÔN dùng `(select auth.uid())` thay vì `auth.uid()` trực tiếp (theo Supabase advisor) để tránh re-evaluate per-row.
- **Core tables RLS:** Tất cả bảng `public` liên quan lớp & permission (**profiles, classes, schools, groups, class_teachers, class_members, group_members**) phải bật RLS và có policy:
  - Admin: `role = 'admin'` → full access (`for all using... with check...`).
  - Teacher: quyền owner dựa trên FK (`teacher_id`, hoặc join qua `classes`/`groups`).
  - Student: chỉ xem/ghi các record có `student_id = (select auth.uid())`.
- **Question Bank & Assignment tables:** RLS cho các bảng mới (`learning_objectives`, `questions`, `question_choices`, `question_objectives`, `assignments`, `assignment_questions`, `assignment_variants`, `assignment_distributions`) follow pattern:
  - Admin full access.
  - Teacher chỉ thao tác trên resource mình sở hữu (`author_id`, `teacher_id`, join ngược qua `assignments`).
  - Student chỉ xem nội dung được phân phối qua `assignment_distributions` + membership (`class_members`, `group_members`).
- **RPC with security definer:** Các transaction phức tạp (vd: publish assignment) phải được gói qua RPC `security definer` với:
  - Check `auth.uid()` + role + ownership ngay đầu function.
  - Dùng transaction để cập nhật nhiều bảng atomically (assignments + assignment_questions + assignment_distributions).

---

# XEM THÊM

Để tìm hiểu thêm về các chủ đề liên quan, tham khảo:

- **Code Quality Rules:** `.clinerules` (Code Quality section)
- **Flutter Architecture Rules:** `.clinerules` (Flutter Architecture section) và `AI_INSTRUCTIONS.md` (Section 2)
- **Directory Structure:** `AI_INSTRUCTIONS.md` (Section 1)
- **MCP Usage Patterns:** `AI_INSTRUCTIONS.md` (Section 10) và `.clinerules` (Database & MCP section)
- **Technology Stack & Setup:** `memory-bank/techContext.md`
- **Current Work Focus:** `memory-bank/activeContext.md` (Current Sprint Focus section)
- **Code Conventions & Preferences:** `memory-bank/activeContext.md` (Active Preferences & Standards section)
- **HTML → Dart Conversion:** `.clinerules` (HTML → Dart Conversion section)
- **Flutter Refactoring Rules:** `.clinerules` (Flutter Refactoring section)