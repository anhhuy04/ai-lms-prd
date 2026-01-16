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

## State Management Pattern: ChangeNotifier + Provider

### ViewModel Structure
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

### 2. Provider for State Management
- **Why:** Simple, lightweight, works well with MVVM
- **Pattern:** Each feature has own ViewModel as ChangeNotifier
- **Dependency Injection:** Use `ChangeNotifierProvider` with explicit constructor dependencies

### 3. Clean Architecture Layers
- **Why:** Separates concerns, enables testing, makes feature changes easier
- **Trade-off:** More boilerplate, but pays off as project scales
- **Enforcement:** Code review must ensure no layer jumps (no direct DataSource in Views)

### 4. Role-Based Navigation
- **Why:** Different users see different UI
- **Implementation:** After auth, route to dashboard based on `profile.role`
- **Files:** [lib/core/routes/app_routes.dart](lib/core/routes/app_routes.dart)

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
| `xl` | 20 dp | Large padding (2.5x) | Section spacing, large gaps |
| `xxl` | 24 dp | Extra large (3x) | Major section breaks |
| `xxxl` | 32 dp | Triple extra (4x) | Large section separators |
| `xxxxl` | 40 dp | Quad extra (5x) | Large component spacing |
| `xxxxxl` | 48 dp | Five extra (6x) | Very large gaps |
| `xxxxxxl` | 64 dp | Six extra (8x) | Maximum spacing |

**Formula:** `spacing = 4 * multiplier` (e.g., lg = 4 * 4 = 16dp)

**Rule:** MUST use predefined tokens from `DesignSpacing`. Do NOT hardcode spacing values.

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