# Codebase Structure

**Analysis Date:** 2026-04-14

## Directory Layout

```
AI_LMS_PRD/
├── lib/
│   ├── main.dart                        # App entry point, DI bootstrap
│   ├── core/                            # Cross-cutting: routes, services, utils, theme
│   │   ├── constants/                   # Design tokens, UI constants, responsive config
│   │   ├── env/                         # envied compile-time secrets (env.dart)
│   │   ├── routes/                      # GoRouter config, route names/paths, guards
│   │   ├── services/                    # Supabase, AI, storage, network, deep link
│   │   ├── theme/                       # AppTheme (MaterialTheme)
│   │   └── utils/                       # AppLogger, date, validation, navigation helpers
│   ├── domain/                          # Pure Dart: entities, repository interfaces, usecases
│   │   ├── entities/                    # Freezed models (+ analytics/, recommendation/)
│   │   ├── repositories/               # Abstract repository interfaces
│   │   └── usecases/                    # Use-case classes (assignment, question, delete class)
│   ├── data/                            # Implementations: datasources, repos, mock
│   │   ├── datasources/                 # Supabase query classes
│   │   ├── repositories/               # RepositoryImpl classes
│   │   ├── mock/                        # Mock data for dev/testing
│   │   └── scripts/                     # One-off data scripts
│   ├── presentation/                    # UI layer
│   │   ├── providers/                   # Riverpod @riverpod providers + notifiers
│   │   ├── viewmodels/                  # ViewModel helpers + mixins
│   │   ├── views/                       # Feature screens
│   │   │   ├── assignment/              # student/ and teacher/ sub-trees
│   │   │   ├── auth/                    # login, register
│   │   │   ├── class/                   # student/ and teacher/ sub-trees
│   │   │   ├── dashboard/               # Role dashboards + home content screens
│   │   │   ├── grading/                 # Scores, student analytics, teacher analytics
│   │   │   ├── network/                 # No-internet screen
│   │   │   ├── profile/                 # Profile screen
│   │   │   ├── recommendation/          # student/ teacher/ recommendation views
│   │   │   ├── settings/                # Settings, API key setup
│   │   │   └── splash/                  # Splash screen
│   │   ├── fetchers/                    # Pagination / list-fetcher helpers
│   │   ├── mappers/                     # ViewModel/UI mappers
│   │   ├── common/                      # Shared presentation widgets
│   │   └── utils/                       # Presentation-level utilities
│   ├── widgets/                         # Shared UI components (no feature coupling)
│   │   ├── assignment/                  # Assignment-related list item widgets
│   │   ├── async/                       # AsyncListPage helper
│   │   ├── buttons/                     # QuickActionButton
│   │   ├── cards/                       # BaseCard, StatisticsCard
│   │   ├── dialogs/                     # DeleteDialog, ErrorDialog, FlexibleDialog, etc.
│   │   ├── drawers/                     # ActionEndDrawer, DrawerActionTile, etc.
│   │   ├── forms/                       # LabeledTextField, DateTimePickerField, SelectField
│   │   ├── list/                        # ClassDetailAssignmentList
│   │   ├── list_item/                   # ClassItemWidget, AssignmentListItem
│   │   ├── loading/                     # ShimmerLoading, ProfileShimmerLoading
│   │   ├── navigation/                  # BackButtonHandler
│   │   ├── objective_selector/          # ObjectiveSelectorSheet
│   │   ├── refresh/                     # AppRefreshIndicator
│   │   ├── responsive/                  # ResponsiveCard, ResponsiveGrid, etc.
│   │   ├── rubric/                      # InteractiveRubricGrader, RubricBuilderComponent, etc.
│   │   ├── search/                      # QuickSearchDialog, SearchScreen, SmartSearch
│   │   └── text/                        # SmartHighlightText, SmartMarqueeText
│   └── splash/                          # Legacy splash assets (if any)
├── db/
│   └── migrations/                      # SQL migration files (numbered)
├── docs/                                # Reference docs, phase flow references
├── memory-bank/                         # AI memory context files
├── .planning/
│   ├── codebase/                        # Codebase analysis documents (this file)
│   └── phases/                          # GSD phase plans
└── pubspec.yaml                         # Dependencies
```

## Directory Purposes

**`lib/core/constants/`:**
- Purpose: App-wide constants and the design system token definitions
- Key files: `lib/core/constants/design_tokens.dart` (colors, spacing, typography, radius, elevation, icons), `lib/core/constants/ui_constants.dart`, `lib/core/constants/responsive_config.dart`

**`lib/core/routes/`:**
- Purpose: Single source of truth for all route names, paths, and RBAC logic
- Key files: `lib/core/routes/route_constants.dart` (`AppRoute` class with all route name constants and path helpers), `lib/core/routes/app_router.dart` (`appRouterProvider` GoRouter config), `lib/core/routes/route_guards.dart` (redirect helpers)

**`lib/core/services/`:**
- Purpose: Singleton services for infrastructure concerns
- Key files: `lib/core/services/supabase_service.dart` (Supabase initialization), `lib/core/services/ai_service.dart` (Gemini AI calls), `lib/core/services/api_key_service.dart` (API key CRUD), `lib/core/services/secure_storage_service.dart`, `lib/core/services/deep_link_service.dart`, `lib/core/services/teacher_ai_queue_processor.dart`

**`lib/domain/entities/`:**
- Purpose: Immutable domain models shared across all layers
- Key files: `lib/domain/entities/assignment.dart`, `lib/domain/entities/submission.dart`, `lib/domain/entities/profile.dart`, `lib/domain/entities/class.dart`, `lib/domain/entities/learning_objective.dart`
- Pattern: Each entity has `entity.dart` + `entity.freezed.dart` + `entity.g.dart` siblings (generated)

**`lib/domain/repositories/`:**
- Purpose: Repository contracts (abstract interfaces)
- Key files: `lib/domain/repositories/assignment_repository.dart`, `lib/domain/repositories/school_class_repository.dart`, `lib/domain/repositories/submission_repository.dart`, `lib/domain/repositories/auth_repository.dart`, `lib/domain/repositories/ai_repository.dart`

**`lib/data/datasources/`:**
- Purpose: All Supabase interaction — direct table queries and RPCs
- Key files: `lib/data/datasources/assignment_datasource.dart`, `lib/data/datasources/submission_datasource.dart`, `lib/data/datasources/analytics_datasource.dart`, `lib/data/datasources/ai_datasource.dart`, `lib/data/datasources/school_class_datasource.dart`

**`lib/data/repositories/`:**
- Purpose: Concrete implementations of domain repository interfaces
- Key files: `lib/data/repositories/assignment_repository_impl.dart`, `lib/data/repositories/submission_repository_impl.dart`, `lib/data/repositories/school_class_repository_impl.dart`

**`lib/presentation/providers/`:**
- Purpose: All Riverpod state management — providers, notifiers, and `.g.dart` generated files
- Key files: `lib/presentation/providers/auth_providers.dart` (currentUserProvider), `lib/presentation/providers/assignment_providers.dart`, `lib/presentation/providers/workspace_provider.dart`, `lib/presentation/providers/teacher_submission_providers.dart`, `lib/presentation/providers/analytics_providers.dart`, `lib/presentation/providers/datasource_providers.dart`

**`lib/presentation/views/assignment/teacher/`:**
- Purpose: Teacher assignment workflow screens
- Key files: `teacher_create_assignment_screen.dart`, `teacher_submission_detail_screen.dart`, `teacher_grading_hub_screen.dart`, `teacher_submission_list_screen.dart`, `teacher_distribute_assignment_screen.dart`
- Sub-widgets: `widgets/submission/`, `widgets/drawer/`, `widgets/ass_hub/`, `widgets/grading_hub/`

**`lib/presentation/views/grading/`:**
- Purpose: Analytics and scoring screens for both roles
- Key files: `lib/presentation/views/grading/student_analytics_screen.dart`, `lib/presentation/views/grading/teacher_analytics_screen.dart`, `lib/presentation/views/grading/scores_screen.dart`

**`lib/widgets/rubric/`:**
- Purpose: Rubric building and grading UI components used across teacher flows
- Key files: `lib/widgets/rubric/interactive_rubric_grader.dart`, `lib/widgets/rubric/rubric_builder_component.dart`, `lib/widgets/rubric/rubric_template_picker_sheet.dart`

## Key File Locations

**Entry Points:**
- `lib/main.dart`: App bootstrap, DI setup, `runApp`

**Configuration:**
- `lib/core/routes/route_constants.dart`: All route names and path helpers
- `lib/core/routes/app_router.dart`: GoRouter full config
- `lib/core/constants/design_tokens.dart`: Design system tokens (ALWAYS use these)
- `lib/core/env/env.dart`: Compile-time env secrets via envied

**Core Logic:**
- `lib/presentation/providers/auth_providers.dart`: Auth state (`currentUserProvider`)
- `lib/presentation/providers/datasource_providers.dart`: DataSource provider definitions
- `lib/core/services/ai_service.dart`: AI/Gemini integration entry point
- `lib/core/services/teacher_ai_queue_processor.dart`: AI grading queue orchestration

**Testing:**
- No test directory detected — tests not yet present

## Naming Conventions

**Files:**
- Screens: `[feature]_screen.dart` (e.g., `teacher_submission_detail_screen.dart`)
- Providers: `[feature]_providers.dart` or `[feature]_notifier.dart`
- DataSources: `[feature]_datasource.dart`
- Repositories: `[feature]_repository.dart` (interface) / `[feature]_repository_impl.dart` (impl)
- Entities: `[entity_name].dart` (snake_case noun)
- Widgets: `[feature]_widget.dart` or descriptive noun (e.g., `class_item_widget.dart`)
- Generated files: `*.g.dart` (json_serializable/riverpod), `*.freezed.dart` (freezed)

**Directories:**
- Feature views split by role: `views/[feature]/teacher/` and `views/[feature]/student/`
- Local widgets co-located: `views/[feature]/[role]/widgets/`

## Where to Add New Code

**New Feature Screen:**
- Screen file: `lib/presentation/views/[feature]/[role]/[role]_[feature]_screen.dart`
- Local widgets: `lib/presentation/views/[feature]/[role]/widgets/[widget_name].dart`
- Route name + path: add constants to `lib/core/routes/route_constants.dart`
- Route builder: add `GoRoute` entry in `lib/core/routes/app_router.dart`
- RBAC: add route name to appropriate role set in `AppRoute.canAccessRoute()`

**New Provider / Notifier:**
- File: `lib/presentation/providers/[feature]_providers.dart` or `[feature]_notifier.dart`
- Run: `flutter pub run build_runner build --delete-conflicting-outputs` after adding `@riverpod`

**New Entity:**
- File: `lib/domain/entities/[entity].dart`
- Add `@freezed` class with `fromJson`
- Run build_runner to generate `.freezed.dart` and `.g.dart`

**New DataSource:**
- File: `lib/data/datasources/[feature]_datasource.dart`
- Constructor receives `SupabaseClient`
- Add provider in `lib/presentation/providers/datasource_providers.dart`

**New Repository:**
- Interface: `lib/domain/repositories/[feature]_repository.dart`
- Implementation: `lib/data/repositories/[feature]_repository_impl.dart`
- Inject in `lib/main.dart` via `ProviderScope.overrides`

**Shared Reusable Widget:**
- Location: `lib/widgets/[category]/[widget_name].dart`

**Feature-Specific Widget:**
- Location: `lib/presentation/views/[feature]/[role]/widgets/[widget_name].dart`

**Utility Function:**
- Location: `lib/core/utils/[name]_utils.dart`

## Special Directories

**`lib/data/mock/`:**
- Purpose: Static mock data for development/offline testing
- Generated: No
- Committed: Yes

**`lib/data/scripts/`:**
- Purpose: One-off migration/data scripts
- Generated: No
- Committed: Yes

**`db/migrations/`:**
- Purpose: Numbered SQL migration files applied to Supabase
- Generated: No
- Committed: Yes
- Key: File names prefixed with number (e.g., `007_grade_override_recalc_trigger.sql`)

**`*.g.dart` / `*.freezed.dart` files:**
- Purpose: Code-generated by `build_runner` from `@riverpod`, `@freezed`, `@JsonSerializable`
- Generated: Yes (do not edit manually)
- Committed: Yes (required for CI builds without build_runner)

**`.planning/`:**
- Purpose: GSD planning phases and codebase analysis documents
- Generated: No
- Committed: Yes

---

*Structure analysis: 2026-04-14*
