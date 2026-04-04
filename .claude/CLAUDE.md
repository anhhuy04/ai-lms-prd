# CLAUDE.md — AI LMS PRD

> Instruction set chính. Đọc đầu phiên làm việc.

---

## 0. Bootstrap (BẮT BUỘC)

Đọc trước khi làm bất kỳ task nào:
1. `memory-bank/activeContext.md`
2. `memory-bank/progress.md`
3. `memory-bank/projectbrief.md`
4. `memory-bank/systemPatterns.md`
5. `tasks/lessons.md` (nếu có)

---

## 1. Source Priority

| Priority | Source |
|----------|--------|
| 1 | `.agents/rules/**` |
| 2 | `.agents/skills/**` |
| 3 | `memory-bank/**` |
| 4 | `.cursorrules` |
| 5 | `docs/**` |

---

## 2. Workflow Auto-Detection

KHÔNG cần user nhập lệnh. Match pattern → load workflow:

| Prompt Pattern | Workflow |
|----------------|----------|
| fix, lỗi, error, bug, crash | `bug_fixing` |
| thêm, tạo, implement, feature | `feature_development` |
| refactor, tách, đổi tên | `refactoring` |
| database, table, migration, rls | `data_workflow` |
| review, check, audit | `code_review` |
| /ag/plan, tầm nhìn tech | `tech_vision` |
| /ag/setupplan, đặc tả, design sync | `setup_plan` |

### Skill Auto-Loading

| Task Type | Load Skill | Auto-Use MCP |
|-----------|------------|--------------|
| State/Riverpod | `/skill:state` | Context7 (riverpod) |
| Routing/GoRouter | `/skill:routing` | Context7 (go_router) |
| Supabase/DB | `/skill:supabase` | Supabase MCP |
| UI/Widgets | `/skill:ui-widgets` | Context7 (flutter) |
| Errors | `/skill:error-handling` | — |
| Architecture | `/skill:architecture` | — |
| Networking | `/skill:networking` | Context7 (dio) |
| Testing | `/skill:testing` | — |

---

## 3. Autonomy

- **Path A — Bug**: Fix ngay, không hỏi. Đọc logs → root cause → fix → verify.
- **Path B — Vague/Large**: Đọc files liên quan, hỏi user clarify.
- **Path C — Clear 3+ steps**: Viết plan vào `tasks/todo.md`, chờ approve.

---

## 4. Tech Stack (BẮT BUỘC)

| Category | Package | Notes |
|----------|---------|-------|
| State | `riverpod` + `@riverpod` | KHÔNG dùng Provider/ChangeNotifier |
| Routing | `go_router` v14+ | Declarative, type-safe |
| Models | `freezed` + `json_serializable` | Immutable |
| Local DB | `drift` | Relational |
| Secure storage | `flutter_secure_storage` | Tokens/sensitive |
| Networking | `dio` + `retrofit` | Interface-based |
| Env secrets | `envied` | Compile-time only |
| Responsive | `flutter_screenutil` | All sizing |
| Loading UI | `shimmer` | List/page loading |
| QR generate | `pretty_qr_code` | Via `QrHelper` |
| QR scan | `mobile_scanner` v6.0.2 | — |
| Error reporting | `sentry_flutter` | All critical flows |
| Logging | `logger` | Via `AppLogger`, KHÔNG `print()` |

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**KHÔNG tự thêm library ngoài stack — hỏi user trước.**

---

## 5. Architecture (Clean Architecture)

```
domain/    ← entities, repository interfaces, use-cases
data/      ← models (Freezed), repositories impl, datasources
presentation/ ← views/, providers/ (Riverpod)
core/      ← constants, routes, utils, widgets
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Provider | `[feature]Provider` / `[feature]NotifierProvider` | `classListProvider` |
| Screen | `[Feature]Screen` | `TeacherClassDetailScreen` |
| Widget | `[Feature]Widget` | `ClassItemWidget` |
| Utility | `[Feature]Helper/Utils` | `QrHelper`, `DateUtils` |
| Private builders | `_build[Name]()` | `_buildHeader()` |

**Widget rules:** `build()` max 50 lines → split `_buildXxx()`. Class max 300 lines. Dùng `const` constructors.

**Widget location:** Shared → `lib/widgets/`. Feature-specific → `lib/presentation/views/[feature]/widgets/`.

---

## 6. Routing (GoRouter)

> Code examples: `/skill:routing`

**Core rules:**
- Default: `pushNamed()` (thêm stack, back hoạt động)
- Chỉ `goNamed()` khi KHÔNG cần quay lại (login→home, bottom nav)
- `context.pop()` cho back. KHÔNG `Navigator.pop()` với screens.
- `Navigator.pop()` CHỈ cho: dialog, bottom sheet, modal.
- KHÔNG hardcoded path — dùng `AppRoute` constants.

| Tình huống | Method |
|------------|--------|
| Screen có nút back | `pushNamed()` |
| Bottom nav tap | `goNamed()` |
| Login → Home | `goNamed()` |
| List → Detail | `pushNamed()` |
| Modal/dialog | `showDialog()` |

**⚠️ CRITICAL Route Ordering:** Specific routes TRƯỚC parameterized:
```
✅ /student/class/search  →  /student/class/:classId
❌ /student/class/:classId  →  /student/class/search  (BUG!)
```

**Source files:**
- `lib/core/routes/route_constants.dart` — route names, paths, RBAC
- `lib/core/routes/app_router.dart` — GoRouter config
- `lib/core/routes/route_guards.dart` — redirect callbacks

---

## 7. State Management (Riverpod)

> Code examples: `/skill:state`

**Core rules:**
- LUÔN dùng `@riverpod` generator. KHÔNG `StateNotifierProvider`.
- `ref.watch()` trong UI, `ref.read()` trong callbacks.
- Dùng `AsyncValue.guard()` thay try/catch thủ công.
- **KHÔNG `ref.invalidate(authProvider)`** để refresh dashboard → router redirect về login.
- Guard concurrency: `bool _isUpdating = false` cho mọi mutating action.

---

## 8. Data Layer & Supabase

> Code examples: `/skill:supabase`

**Schema First:** Đọc `docs/note sql.txt` → Dùng Supabase MCP inspect schema thực tế → KHÔNG assume column names.

**RLS BẮT BUỘC:** Mọi public table phải có RLS. Dùng `(select auth.uid())` thay `auth.uid()`.

**Data flow:** `UI → Provider → Repository(interface) → DataSource → Supabase/Drift`

### New Table Checklist
1. Schema trong `db/`
2. Sync vào `docs/note sql.txt`
3. Apply via Supabase MCP
4. Enable RLS + policies (admin/teacher/student)
5. Update `memory-bank/README_SUPABASE.md`
6. Freezed model → DataSource → Repository
7. `dart run build_runner build -d`

---

## 9. UI & Design System

> Loading states code, responsive examples: `/skill:ui-widgets`

**Đọc trước khi code UI:**
1. `memory-bank/DESIGN_SYSTEM_GUIDE.md`
2. `lib/core/constants/design_tokens.dart`

### Design Tokens (BẮT BUỘC)

| Token | Dùng | KHÔNG dùng |
|-------|------|-----------|
| Colors | `DesignColors.*` | `Color(0xFF...)`, `Colors.blue` |
| Spacing | `DesignSpacing.xs/sm/md/lg/xl` | `EdgeInsets.all(16)` raw |
| Typography | `DesignTypography.*` | `TextStyle(fontSize:14)` raw |
| Icons size | `DesignIcons.*` | hardcoded `24.0` |
| Border radius | `DesignRadius.*` | `BorderRadius.circular(8)` raw |
| Shadows | `DesignElevation.level*` | `BoxShadow(...)` raw |

**Loading states:** `ShimmerListTileLoading` / `ShimmerLoading` / `ShimmerDashboardLoading` / `CircularProgressIndicator`.

**Responsive:** `.w` `.h` `.sp` `.r` (screenutil). `DesignBreakpoints.*` cho device checks.

---

## 10. Code Quality

### Pre-Implementation Checklist
1. Clarify behavior (đặc biệt delete/update)
2. Dependencies: `pubspec.yaml` + `flutter pub get` TRƯỚC import
3. Grep provider/function name trước khi tạo (tránh duplicate)
4. Route order: specific trước parameterized
5. Null safety cho ALL API return values
6. API docs: đọc lib docs cho return types
7. `build_runner` nếu Freezed/JsonSerializable thay đổi
8. `flutter analyze` + fix ALL errors
9. Test: happy path, error cases, edge cases

### Common Bugs

| Bug | Fix |
|-----|-----|
| Route ordering | Specific trước parameterized |
| Provider duplication | Grep trước khi define |
| Null safety | Guard collections, check first |
| Missing deps | pubspec → pub get → THEN import |

**Code style:** Functions max 50 lines. Classes max 300 lines. No hardcoded values → `core/constants/`. Fix ALL `flutter analyze`. KHÔNG `print()` → `AppLogger`.

---

## 11. MCP Servers

| MCP | Auto-Trigger |
|-----|-------------|
| **Supabase** | Database, RLS, migrations, edge functions |
| **Context7** | Docs package Flutter/Dart, library API |
| **Fetch** | URL cụ thể, Context7 không hỗ trợ |
| **GitHub** | Commit, PR, issues |
| **Dart** | Analyze, format sau khi viết code |
| **DuckDuckGo/Brave/Tavily** | Web search |

### MCP Tool Mapping

| Task | Tools |
|------|-------|
| Thêm bảng mới | Supabase: get_tables → apply_migration |
| Kiểm tra schema | Supabase: get_table_columns |
| Docs library | Context7: search_docs |
| Code quality | Dart: analyze + format |
| Git commit/PR | GitHub: commit, create_pull_request |

**Never Assume:** Database → Supabase MCP. Library API → Context7/Fetch.

---

## 12. Memory Bank

### Session Start (BẮT BUỘC)
Đọc: `projectbrief.md`, `productContext.md`, `activeContext.md`, `systemPatterns.md`, `techContext.md`, `progress.md`

### Session End / After Significant Change
Update: `activeContext.md` → `progress.md` → `systemPatterns.md` → `techContext.md`

---

## 13. Engineering Standards

| Principle | Rule |
|-----------|------|
| Simplicity First | Minimal code impact |
| Root Cause Only | Fix actual cause, không hack |
| Minimal Impact | Touch only what's necessary |
| No Over-engineering | Không thêm ngoài yêu cầu |

---

## 14. Skills

| Skill | Trigger |
|-------|---------|
| `/skill:state` | riverpod, provider, notifier, async |
| `/skill:routing` | route, go router, navigation |
| `/skill:supabase` | supabase, database, rls |
| `/skill:ui-widgets` | ui, widget, design, layout |
| `/skill:error-handling` | error, exception, sentry |
| `/skill:dart-language` | dart, records, sealed class |
| `/skill:architecture` | clean architecture, domain, data |
| `/skill:networking` | api, dio, retrofit |
| `/skill:dependency-injection` | di, provider setup |
| `/skill:testing` | test, mock, unit test |

---

## 15. Verification (NON-NEGOTIABLE)

```bash
flutter analyze          # No errors
flutter test             # All pass
flutter build apk --debug  # Build OK
```

---

## 16. Workflows

| Workflow | File | Trigger |
|----------|------|---------|
| `bug_fixing` | `.claude/workflows/bug_fixing.md` | fix, lỗi, error, bug |
| `feature_development` | `.claude/workflows/feature_development.md` | thêm, tạo, implement |
| `refactoring` | `.claude/workflows/refactoring.md` | refactor, tách, optimize |
| `data_workflow` | `.claude/workflows/data_workflow.md` | database, migration, rls |
| `code_review` | `.claude/workflows/code_review.md` | review, audit |
| `tech_vision` | `.claude/plugins/plan-workflow/workflows/tech_vision.md` | /ag/plan |
| `setup_plan` | `.claude/plugins/plan-workflow/workflows/setup_plan.md` | /ag/setupplan |

---

## 17. Cleanup

Sau task hoàn thành: `/cleanup` — xóa temp artifacts, giữ source code và memory-bank.
