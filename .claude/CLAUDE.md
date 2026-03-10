# CLAUDE.md — AI LMS PRD Project Intelligence

> This file is the primary instruction set for AI assistants working on this project.
> Read this file at the start of every session before taking any action.

---

## 0. Memory & Context Bootstrap (BẮT BUỘC)

**Đọc ngay khi bắt đầu phiên làm việc:**

1. `memory-bank/activeContext.md` — focus hiện tại, thay đổi gần đây
2. `memory-bank/progress.md` — trạng thái project, vấn đề đã biết
3. `memory-bank/projectbrief.md` — mục tiêu, scope project
4. `memory-bank/systemPatterns.md` — architecture patterns, design system
5. `tasks/lessons.md` (nếu có) — các lỗi đã mắc phải

**Optional:**
- `.claude/skills/memory-bank` — dùng `/memory-bank` để load memory files
- `.claude/skills/cleanup` — dùng `/cleanup` sau khi hoàn thành task

---

## 1. Source of Truth Priority (THỨ TỰ ƯU TIÊN)

| Priority | Source | Notes |
|----------|--------|-------|
| 1 | `.agents/rules/**` | Highest - rules cụ thể cho project |
| 2 | `.agents/skills/**` | Skills cho từng domain |
| 3 | `memory-bank/**` | Context, progress, patterns |
| 4 | `.cursorrules` | Cursor IDE rules (nếu có) |
| 5 | `docs/**` | Có thể legacy |

---

## 2. Smart Workflow Routing (TỰ ĐỘNG)

**QUAN TRỌNG:** KHÔNG cần user nhập lệnh. Tự động nhận diện workflow dựa trên prompt.

### Pattern → Workflow Mapping

| Prompt Pattern | Workflow | Ví dụ |
|----------------|----------|-------|
| **Bug/Lỗi/Error** | `bug_fixing` | "fix lỗi", "bị crash", "error", "bug" |
| **Feature/Tính năng** | `feature_development` | "thêm feature", "tạo màn", "implement" |
| **Refactor/Tối ưu** | `refactoring` | "refactor", "tách file", "đổi tên" |
| **Database/Supabase** | `data_workflow` | "thêm bảng", "tạo table", "migration", "RLS" |
| **Review/Kiểm tra** | `code_review` | "review", "check code", "audit" |
| **Tech Vision/Plan** | `tech_vision` | "/ag/plan", "tầm nhìn công nghệ", "phân tích tech" |
| **Setup Plan/Screen** | `setup_plan` | "/ag/setupplan", "tạo đặc tả", "đồng bộ design" |

### Auto-Detection Rules

1. **Đọc prompt** của user
2. **Match** với pattern table trên
3. **Load** relevant skill + workflow
4. **Execute** workflow tự động
5. ** KHÔNG cần hỏi user** về việc chạy workflow nào

### Skill + MCP Auto-Loading

| Task Type | Load Skill | Auto-Use MCP |
|-----------|------------|--------------|
| State/Riverpod | `/skill:state` | Context7 (riverpod docs) |
| Routing/GoRouter | `/skill:routing` | Context7 (go_router docs) |
| Supabase/DB | `/skill:supabase` | **Supabase MCP** (schema, migrations) |
| UI/Widgets | `/skill:ui-widgets` | Context7 (flutter docs) |
| Errors | `/skill:error-handling` | — |
| Architecture | `/skill:architecture` | — |
| Networking | `/skill:networking` | Context7 (dio docs) |
| Testing | `/skill:testing` | — |
| CI/CD | `/skill:cicd` | GitHub MCP |

---

## 3. Autonomy Routing

### Path A — Bug Fixes → 100% Autonomy
- User báo lỗi, error log, hoặc test fail
- **Hành động:** Đọc logs, tìm root cause, fix, verify. KHÔNG cần hỏi.

### Path B — Vague / Large Features → Clarification
- Request mơ hồ, thiếu constraints, hoặc architecture phức tạp
- **Hành động:** Dừng. Đọc files liên quan, hỏi user để clarify.

### Path C — Well-Defined → Plan & Check-in
- Request rõ ràng với 3+ steps
- **Hành động:** Viết plan vào `tasks/todo.md`, chờ user approve rồi mới code.

---

## 4. Tech Stack (BẮT BUỘC)

### Mandatory Libraries

| Category | Package | Notes |
|----------|---------|-------|
| State | `riverpod` + `@riverpod` generator | KHÔNG dùng Provider/ChangeNotifier |
| Routing | `go_router` v14+ | Declarative, type-safe |
| Models | `freezed` + `json_serializable` | Immutable |
| Local DB | `drift` | Relational |
| Secure storage | `flutter_secure_storage` | Tokens/sensitive |
| Networking | `dio` + `retrofit` | Interface-based API |
| Env secrets | `envied` | Compile-time only |
| Responsive UI | `flutter_screenutil` | All sizing |
| Loading UI | `shimmer` | List/page loading |
| QR generate | `pretty_qr_code` | Via `QrHelper` wrapper |
| QR scan | `mobile_scanner` v6.0.2 | `MobileScannerController` |
| Error reporting | `sentry_flutter` | All critical flows |
| Logging | `logger` | Via `AppLogger`, KHÔNG `print()` |

### Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Adding New Libraries
1. Thêm vào `pubspec.yaml` trước
2. Chạy `flutter pub get`
3. Dùng MCP (Fetch/Context7) để đọc docs
4. Rồi mới viết code
5. KHÔNG tự thêm library không có trong stack — hỏi user

---

## 5. Architecture (Clean Architecture)

```
domain/          ← entities, repository interfaces, use-cases
data/            ← models (Freezed), repositories impl, datasources
presentation/    ← views/, providers/ (Riverpod)
core/            ← constants, routes, utils, widgets
```

- Repository interfaces: `domain/repositories/`
- Implementations: `data/repositories/`

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Provider | `[feature]Provider` / `[feature]NotifierProvider` | `classListProvider` |
| Screen | `[Feature]Screen` | `TeacherClassDetailScreen` |
| Widget | `[Feature]Widget` | `ClassItemWidget` |
| Utility | `[Feature]Helper` / `[Feature]Utils` | `QrHelper`, `DateUtils` |
| Private builders | `_build[Name]()` | `_buildHeader()` |

### Widget Modularization
- `build()` max **50 lines** → split thành `_buildXxx()` private methods
- Reused 2+ lần → extract thành `StatelessWidget` riêng
- Classes max **300 lines** → refactor hoặc split
- Dùng `const` constructors khi có thể
- Widget location:
  - Shared/reusable: `lib/widgets/`
  - Feature-specific: `lib/presentation/views/[feature]/widgets/`

---

## 6. Routing (GoRouter + RBAC)

### Core Principles
- **Mặc định dùng `pushNamed()`/`push()`** - thêm vào stack, back button hoạt động
- **Chỉ dùng `goNamed()`/`go()`** khi KHÔNG cần quay lại ( VD: login → home, splash → main)
- **Luôn dùng `context.pop()`** cho back navigation (GoRouter extension)
- **KHÔNG dùng `Navigator.pop()`** với GoRouter - không tương thích
- Dùng `Navigator.pop()` CHỈ cho: dialog, bottom sheet, modal overlay
- **KHÔNG dùng `Navigator.push*()`** cho screen navigation
- KHÔNG hardcoded path strings — dùng `AppRoute` constants
- Dùng `NavigationHelper.goBack(context)` để an toàn

### Quy tắc chọn push vs go
| Tình huống | Method |
|------------|--------|
| Screen có nút back/quay lại | `pushNamed()` |
| Bottom nav tap | `goNamed()` (thay thế tab) |
| Login → Home | `goNamed()` |
| List → Detail (có back) | `pushNamed()` |
| Modal/dialog | `showDialog()`, `showModalBottomSheet()` |

### Source Files
- `lib/core/routes/route_constants.dart` — ALL route names, paths, RBAC
- `lib/core/routes/app_router.dart` — GoRouter config, ShellRoute, RBAC redirect
- `lib/core/routes/route_guards.dart` — redirect callback, auth/role checks

### ⚠️ CRITICAL: Route Ordering
Specific routes PHẢI đứng TRƯỚC parameterized routes:
```dart
// ✅ CORRECT
GoRoute(path: '/student/class/search', ...),
GoRoute(path: '/student/class/:classId', ...),

// ❌ WRONG — param sẽ match 'search' trước!
GoRoute(path: '/student/class/:classId', ...),
GoRoute(path: '/student/class/search', ...),
```

### RBAC Redirect Logic (3-Step)
1. **Public route?** (splash, login, register...) → allow
2. **Authenticated?** → No → redirect `/login?redirect={path}`
3. **Role match?** → No → redirect to role's dashboard

### Path Parameters — Golden Rule
- Resource ID → path parameter (deep linking)
- Optional filter → query parameter (`?mode=edit`)
- Complex object → `extra` (mobile-only, dùng ít)
- **KHÔNG dùng `extra` cho IDs**

---

## 7. State Management (Riverpod + AsyncNotifier)

### Core Rules
- LUÔN LUÔN dùng `@riverpod` generator annotation
- `ref.watch()` trong UI (reactive rebuild)
- `ref.read()` trong callbacks/events (one-time read)
- Tránh unnecessary rebuilds

### AsyncNotifier Pattern
```dart
@riverpod
class ClassListNotifier extends _$ClassListNotifier {
  @override
  FutureOr<List<ClassEntity>> build() async {
    return ref.watch(classRepositoryProvider).getClasses();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(classRepositoryProvider).getClasses()
    );
  }
}
```

### ⚠️ CRITICAL: Concurrency Guards
Ngăn "Future already completed" / double-state errors:
```dart
bool _isUpdating = false;

Future<void> toggleSetting(bool value) async {
  if (_isUpdating) return;
  _isUpdating = true;
  try {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(repoProvider).update(value));
  } finally {
    _isUpdating = false;
  }
}
```

### Parallel Fetching (Bundle Loader)
```dart
Future<void> loadClassBundle(String classId) async {
  state = const AsyncLoading();
  final results = await Future.wait([
    ref.read(classRepoProvider).getClass(classId),
    ref.read(memberRepoProvider).getMembers(classId),
    ref.read(assignmentRepoProvider).getAssignments(classId),
  ]);
  state = AsyncData(ClassBundle(
    classDetail: results[0],
    members: results[1],
    assignments: results[2],
  ));
}
```

### Dashboard Refresh — No Auth Reset
```dart
// ✅ ĐÚNG: refresh chỉ data
Future<void> refresh() async {
  await loadClassBundle(classId);
}

// ❌ SAI: gây redirect về login
ref.invalidate(authProvider);
```

---

## 8. Data Layer & Supabase

### Schema First
1. Đọc SQL schema trong `docs/note sql.txt` và `db/`
2. Dùng Supabase MCP để inspect schema thực tế
3. KHÔNG assume column names
4. Notes về schema → viết vào `memory-bank/README_SUPABASE.md`

### RLS (Row Level Security) — BẮT BUỘC
- TẤT CẢ public tables phải có RLS enabled
- Dùng `(select auth.uid())` thay vì `auth.uid()` trực tiếp

```sql
-- ✅ CORRECT
CREATE POLICY "teachers_read_own_classes" ON classes
  FOR SELECT USING (teacher_id = (select auth.uid()));
```

### Data Access Pattern
```
UI → Provider(Riverpod) → Repository(interface) → DataSource → Supabase/Drift
```

### New Table Checklist
1. Viết schema trong `db/`
2. Sync schema vào `docs/note sql.txt`
3. Apply table via Supabase MCP
4. Enable RLS immediately
5. Viết policies cho 3 roles (admin/teacher/student)
6. Update `memory-bank/README_SUPABASE.md`
7. Create Freezed model
8. Create DataSource + Repository
9. Run `dart run build_runner build -d`

---

## 9. UI & Design System

### MANDATORY: Read Design Docs First
1. `memory-bank/DESIGN_SYSTEM_GUIDE.md`
2. `memory-bank/systemPatterns.md` (Design System section)
3. `lib/core/constants/design_tokens.dart`

### Design Tokens — LUÔN DÙNG

| Token | Source | ❌ Never |
|-------|--------|----------|
| Colors | `DesignColors.*` | `Color(0xFF...)`, `Colors.blue` |
| Spacing | `DesignSpacing.xs/sm/md/lg/xl` | `EdgeInsets.all(16)` raw |
| Typography | `DesignTypography.*` | `TextStyle(fontSize: 14)` raw |
| Icons size | `DesignIcons.*` | hardcoded `24.0` |
| Border radius | `DesignRadius.*` | `BorderRadius.circular(8)` raw |
| Shadows | `DesignElevation.level*` | `BoxShadow(...)` raw |

### Loading States (BẮT BUỘC UX)
```dart
// ✅ List có avatar + text
ShimmerListTileLoading()

// ✅ Class list / card list
ShimmerLoading()

// ✅ Dashboard / trang tổng hợp
ShimmerDashboardLoading()

// ✅ Submit button / thao tác ngắn
CircularProgressIndicator(strokeWidth: 2)
```

### Responsive
- All sizing: `flutter_screenutil` (`.w`, `.h`, `.sp`, `.r`)
- Device type checks: `DesignBreakpoints.*`

---

## 10. Code Quality & Error Prevention

### Pre-Implementation Checklist
1. **Requirement** — clarify behavior (đặc biệt delete/update)
2. **Dependencies** — add to `pubspec.yaml` + `flutter pub get` TRƯỚC import
3. **Duplicate check** — grep provider/function name trước khi tạo
4. **Route order** — specific routes trước parameterized
5. **Null safety** — plan null checks cho ALL API return values
6. **API docs** — đọc lib docs cho return types
7. **Code gen** — run build_runner nếu Freezed/JsonSerializable thay đổi
8. **Lint** — `flutter analyze` + fix all errors
9. **Testing** — cover happy path, error cases, edge cases

### Common Bugs to Avoid

| Bug | Fix |
|-----|-----|
| Route ordering | Specific trước parameterized |
| Provider duplication | Luôn grep trước khi define |
| Null safety | Guard collections, check first |
| Missing dependencies | pubspec → pub get → THEN import |

### Code Style
- Functions: max **50 lines** → split
- Classes: max **300 lines** → refactor
- `const` constructors: always
- No hardcoded values → dùng `core/constants/`
- Fix ALL `flutter analyze` warnings
- Format: `dart format`
- KHÔNG `print()` → `AppLogger`

---

## 11. MCP Servers (TỰ ĐỘNG SỬ DỤNG)

### MCP Servers Available

| MCP | Package | Purpose | Auto-Trigger |
|-----|---------|---------|--------------|
| **Supabase** | `@supabase/mcp-server-supabase` | Database, RLS, migrations, edge functions | Database/Supabase tasks |
| **Context7** | `@upstash/context7-mcp` | Latest docs từ pub.dev, official sites | Library docs lookup |
| **Fetch** | `@kazuph/mcp-fetch` | Web content fetching | Web URLs |
| **GitHub** | `@modelcontextprotocol/server-github` | Git operations, PRs, issues | Git tasks |
| **Filesystem** | `@modelcontextprotocol/server-filesystem` | File operations | File access |
| **Dart** | `dart mcp-server` | Dart analyzer, formatter | Code quality |
| **DuckDuckGo** | `@thefallmarc/mcp-duckduckgo` | Web search | General web search |
| **Brave Search** | `@modelcontextprotocol/server-brave-search` | Web search | General web search |
| **Tavily** | `@taubyte/mcp-tavily` | Web search & AI answers | Search for answers |
| **Puppeteer** | `@modelcontextprotocol/server-puppeteer` | Web browsing | Scrape dynamic content |

### MCP Auto-Usage Rules

**QUAN TRỌNG:** KHÔNG cần user yêu cầu. Tự động sử dụng khi cần.

#### 1. Supabase MCP → Tự động khi:
- Thêm/sửa bảng database
- Kiểm tra schema
- Viết RLS policies
- Query data
- Deploy edge functions
- Xem logs

```sql
-- Tự động gọi khi cần kiểm tra schema
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

-- Kiểm tra columns
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'target_table';
```

#### 2. Context7 MCP → Tự động khi:
- Cần docs về package Flutter/Dart
- Library knowledge có thể outdated (>2025)
- Tìm ví dụ code

```
# Tự động gọi khi cần docs
Context7: Get documentation for package:flutter_riverpod
```

#### Web Search MCPs (DuckDuckGo, Brave, Tavily) → Tự động khi:
- Cần tìm kiếm thông tin từ web
- Cần giải đáp câu hỏi
- Cần cập nhật kiến thức

```
# Tự động search khi cần
DuckDuckGo: search "flutter riverpod best practices 2025"
Brave-Search: search_query="supabase rls best practices"
Tavily: search query="..."
```

#### 3. Fetch MCP → Tự động khi:
- User cung cấp URL cụ thể
- Context7 không hỗ trợ
- Cần content từ website

```
# Tự động fetch khi có URL
Fetch: https://riverpod.dev/docs/...
```

#### 4. GitHub MCP → Tự động khi:
- User yêu cầu commit
- Tạo PR
- Kiểm tra issues

#### 5. Dart MCP → Tự động khi:
- Sau khi viết code
- Kiểm tra analyze
- Format code

```bash
# Tự động gọi sau code
dart_analyze_files: ["lib/path/to/file.dart"]
dart_format: ["lib/path/to/file.dart"]
```

### MCP Tool Mapping

| Task | MCP Tools to Use |
|------|------------------|
| **Thêm bảng mới** | Supabase: get_tables → apply_migration |
| **Kiểm tra schema** | Supabase: get_table_columns |
| **Viết RLS** | Supabase: get_tables, apply_migration |
| **Docs library** | Context7: search_docs |
| **Web content** | Fetch: fetch |
| **Code quality** | Dart: dart_analyze, dart_format |
| **Git commit** | GitHub: commit, create_pull_request |
| **File operations** | Filesystem: read_file, write_file |

### Never Assume - Always Verify

- **Database**: Dùng Supabase MCP để kiểm tra schema thực tế
- **Library API**: Dùng Context7/Fetch để lấy docs mới nhất
- **Code errors**: Dùng Dart MCP để analyze

---

## 12. Memory Bank Maintenance

### Session Start (MANDATORY)
Đọc tất cả trước khi làm bất kỳ task nào:
- `memory-bank/projectbrief.md`
- `memory-bank/productContext.md`
- `memory-bank/activeContext.md`
- `memory-bank/systemPatterns.md`
- `memory-bank/techContext.md`
- `memory-bank/progress.md`

### Session End / After Significant Change
Update các files:
- `activeContext.md` → "Recently Completed" + "Current Sprint Focus"
- `progress.md` → "What works" + current status
- `systemPatterns.md` → add new patterns
- `techContext.md` → update nếu dependencies thay đổi

### Update Triggers
1. New project pattern discovered
2. Significant code changes completed
3. User requests "update memory bank"
4. Context cần clarification cho next session

---

## 13. Engineering Standards

| Principle | Rule |
|-----------|------|
| Simplicity First | Minimal code impact |
| Root Cause Only | Fix actual cause, không hack |
| Minimal Impact | Touch only what's necessary |
| Demand Elegance | "Would a Staff Engineer approve this?" |
| No Over-engineering | Don't add beyond what's asked |

---

## 14. Skills (TỰ ĐỘNG LOAD)

### Skill Auto-Loading

| Skill | File | Trigger |
|-------|------|---------|
| State | `.claude/skills/state/SKILL.md` | riverpod, provider, notifier, async |
| Routing | `.claude/skills/routing/SKILL.md` | route, go router, navigation |
| Supabase | `.claude/skills/supabase/SKILL.md` | supabase, database, rls |
| UI Widgets | `.claude/skills/ui-widgets/SKILL.md` | ui, widget, design, layout |
| Error Handling | `.claude/skills/error-handling/SKILL.md` | error, exception, sentry |
| Dart Language | `.claude/skills/dart-language/SKILL.md` | dart, records, sealed class |
| Architecture | `.claude/skills/architecture/SKILL.md` | clean architecture, domain, data |
| Networking | `.claude/skills/networking/SKILL.md` | api, dio, retrofit |
| Dependency Injection | `.claude/skills/dependency-injection/SKILL.md` | di, provider setup |
| Testing | `.claude/skills/testing/SKILL.md` | test, mock, unit test |
| CI/CD | `.claude/skills/cicd/SKILL.md` | ci, cd, github actions |

> **Note:** Skills được tự động load khi task match với trigger keywords. KHÔNG cần user gọi lệnh.

---

## 15. Verification (NON-NEGOTIABLE)

Never mark task complete without empirical proof:

```bash
flutter analyze          # static analysis & type checking
flutter test             # unit + widget tests
flutter build apk --debug  # build smoke test
```

### Checklist
- [ ] No analyzer warnings or errors
- [ ] All relevant tests pass
- [ ] Diff reviewed — no unintended changes
- [ ] No new lint violations

---

## 16. Workflows (TỰ ĐỘNG CHẠY)

### Workflows Available

| Workflow | File | Trigger Patterns |
|----------|------|------------------|
| `bug_fixing` | `.claude/workflows/bug_fixing.md` | fix, lỗi, error, bug, crash, null |
| `feature_development` | `.claude/workflows/feature_development.md` | thêm, tạo, implement, feature, màn hình |
| `refactoring` | `.claude/workflows/refactoring.md` | refactor, tách, đổi tên, optimize |
| `data_workflow` | `.claude/workflows/data_workflow.md` | database, table, migration, supabase, rls |
| `code_review` | `.claude/workflows/code_review.md` | review, check, audit |
| `tech_vision` | `.claude/plugins/plan-workflow/workflows/tech_vision.md` | /ag/plan, tầm nhìn, tech vision, công nghệ |
| `setup_plan` | `.claude/plugins/plan-workflow/workflows/setup_plan.md` | /ag/setupplan, đặc tả, màn hình, design sync |

### How It Works

1. **User sends prompt** → Claude reads prompt
2. **Match pattern** → Find matching workflow from table above
3. **Load workflow** → Read relevant `.claude/workflows/*.md`
4. **Execute steps** → Follow workflow automatically
5. **Done** → Report results to user

### Example Auto-Detection

```
User: "fix lỗi crash khi login"
→ Detect: "fix" + "lỗi" → bug_fixing workflow
→ Load: .claude/workflows/bug_fixing.md
→ Execute: Observe → Hypothesize → Experiment → Verify → Document

User: "thêm màn hình profile"
→ Detect: "thêm" + "màn" → feature_development workflow
→ Load: .claude/workflows/feature_development.md
→ Execute: Read Context → Plan → Execute → Debug → Check
```

---

## 17. Cleanup

After task completes successfully, use `/cleanup` to remove temporary files.

- **Rule:** Never leave temp artifacts
- **Use:** `/cleanup` after verification passes
- **Keeps:** memory-bank/, .claude/, lib/, test/, README.md
