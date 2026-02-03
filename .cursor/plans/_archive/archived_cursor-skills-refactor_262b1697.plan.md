---
name: cursor-skills-refactor
overview: Tổng hợp và nâng cấp bộ rules/kỹ thuật đã có trong AI_LMS_PRD thành hệ skill `.cursor/skills` full-stack (Flutter + Supabase + MCP) ở mức module/pattern, để agent có thể tự xây dựng và mở rộng dự án.
todos:
  - id: collect-existing-rules
    content: Rà soát và gom nhóm toàn bộ rules/patterns chính từ memory-bank, systemPatterns, QUICK_REFERENCE, activeContext, docs.
    status: pending
  - id: design-skill-groups
    content: Thiết kế danh sách nhóm skill trung bình (module-level) cho Flutter, Supabase, MCP, Design System, Routing, State Management.
    status: pending
    dependencies:
      - collect-existing-rules
  - id: define-skill-schema
    content: Đề xuất schema chuẩn cho một skill `.cursor/skills` (metadata, triggers, rules, examples, links) phù hợp cấu hình hiện tại.
    status: pending
    dependencies:
      - design-skill-groups
  - id: draft-core-skills
    content: Soạn nội dung chi tiết cho 3–5 core skills đầu tiên (architecture, state, routing, design system, supabase).
    status: pending
    dependencies:
      - define-skill-schema
  - id: refine-and-extend-skills
    content: Dựa trên phản hồi, tinh chỉnh rồi nhân rộng skill cho các module khác (drawer, dialog, search, optimistic updates, MCP, workflow).
    status: pending
    dependencies:
      - draft-core-skills
---

# Kế hoạch xây dựng bộ skill `.cursor/skills` cho dự án AI_LMS_PRD

### Mục tiêu

- **Tổng hợp** toàn bộ rules, patterns, kỹ thuật đã được đúc kết trong codebase và memory-bank.
- **Tái cấu trúc** chúng thành các nhóm kỹ năng rõ ràng (Flutter, Supabase, MCP, Design System, Routing, State Management, v.v.).
- **Chuẩn hóa** thành skill cho `.cursor/skills` để agent có thể tự áp dụng khi phát triển/tái cấu trúc dự án.

### 1. Gom nhóm "năng lực" lớn đã có trong dự án

- **Flutter Architecture & Patterns**
- Clean Architecture 3-layer (Presentation → Domain → Data) + MVVM.
- Quy tắc phụ thuộc một chiều, không nhảy layer, chỉ Repository gọi DataSource.
- Entity/Repository/UseCase (dù UseCase đang optional) + ViewModel/Notifier.
- **State Management & Navigation**
- Riverpod (AsyncNotifier, `ref.watch`/`ref.read`, pattern `.when`) là primary; Provider (ChangeNotifier) legacy.
- GoRouter v2.0: named routes, path helpers, Tứ Trụ (GoRouter + Riverpod + RBAC + ShellRoute), tránh `Navigator.push`/path hardcode.
- Reactive navigation patterns (splash fix: router + provider, không manual `context.go` từ widget).
- **Design System & Widgets**
- Design Tokens (`design_tokens.dart`): Colors, Spacing, Typography, Icons, Radius, Elevation, Components, Breakpoints, Animations, Accessibility.
- Responsive Spacing System (`context.spacing.*`), Drawer System, Dialog System, Search System (generic search + dialogs), widget directory structure.
- **Supabase & Data Layer**
- SupabaseService init với envied, RLS-first mindset, tất cả query nằm trong `data/datasources`.
- Repository patterns với `CustomException`, dịch lỗi sang tiếng Việt ở repository, không để UI xử lý.
- Class settings JSON mapping + optimistic update pattern (`updateClassSettingOptimistic`, concurrency guard).
- **MCP & Dev Workflow**
- Supabase MCP để kiểm schema/migration, Context7 MCP để tra cứu docs/patterns, Fetch MCP cho docs ngoài, GitHub & Filesystem MCP cho git/files.
- Code quality & lint rules (analysis_options, riverpod_lint, `.clinerules`), test strategy, deployment checklist.

### 2. Thiết kế cấu trúc skill theo module (mức "medium granularity")

- **Skill nhóm Flutter Architecture**
- `flutter_clean_architecture`
- Mục tiêu: giữ boundary giữa Presentation/Domain/Data, naming conventions, flow dependency.
- Nội dung: tóm tắt systemPatterns.md (layer responsibilities, entities/repositories/datasources, error flow).
- `flutter_state_management_riverpod`
- Mục tiêu: mọi state mới dùng Riverpod; pattern AsyncNotifier + `.when` + refresh không reset auth.
- Nội dung: auth/dashboard notifier patterns, refresh rules (không gọi `checkCurrentUser`, không set loading trong refresh).
- `flutter_state_management_provider_legacy`
- Mục tiêu: chỉ đọc/duy trì code cũ, không dùng cho feature mới; cách wrap ViewModel bằng Provider.

- **Skill nhóm Routing & Navigation**
- `routing_gorouter_rbac_shellroute`
- Mục tiêu: dùng GoRouter + named routes + RBAC + ShellRoute; tránh manual Navigator.
- Nội dung: route_constants, app_router, route_guards, 3-step RBAC, ví dụ `context.goNamed` + path helpers.
- `routing_reactive_auth_flow`
- Mục tiêu: nắm pattern sửa splash: router xem provider, widget chỉ render state.
- Nội dung: before/after từ `ARCHITECTURE_FIX.md` + QUICK_REFERENCE.md; golden rule: không `context.go` trong init/build.

- **Skill nhóm Design System & UI Components**
- `design_system_tokens_and_enforcement`
- Mục tiêu: cấm hardcode màu/spacing/font/radius/shadow/sizing, bắt buộc dùng `Design*` tokens.
- Nội dung: bảng màu Moon/Teal, spacing scale, typography scale, rules DO/DON'T từ QUICK_REFERENCE.md.
- `design_system_responsive_and_accessibility`
- Mục tiêu: responsive spacing, breakpoints, kích thước tối thiểu, animation chuẩn.
- Nội dung: ResponsiveSpacing, DesignBreakpoints, accessibility minima.
- `widgets_drawer_system`
- Mục tiêu: dùng ActionEndDrawer, ClassSettingsDrawer, DrawerToggleTile,... đúng chuẩn.
- Nội dung: kiến trúc drawer, width 340, pattern dùng trong Scaffold.
- `widgets_dialog_system`
- Mục tiêu: dùng FlexibleDialog/SuccessDialog/WarningDialog/ErrorDialog thay vì showDialog ad-hoc.
- Nội dung: pattern 5 loại dialog, responsive width, cách xử lý result.
- `widgets_search_system`
- Mục tiêu: tái sử dụng `SearchScreen<T>` + search dialogs + SearchField.
- Nội dung: generic search config, highlight text, empty states.

- **Skill nhóm Supabase & Data Patterns**
- `supabase_integration_and_env`
- Mục tiêu: khởi tạo Supabase qua Env/envied, network check, timeout, không hardcode URL/keys.
- Nội dung: SupabaseService pattern, envied, connectivity check.
- `repository_and_error_handling`
- Mục tiêu: mọi lỗi được wrap bằng CustomException, dịch sang tiếng Việt trong repository.
- Nội dung: error flow 4 bước (DataSource → Repository → ViewModel → View), ví dụ loginUser.
- `class_settings_and_optimistic_updates`
- Mục tiêu: cập nhật JSON `classes.class_settings` bằng optimistic update, không phá AsyncNotifier.
- Nội dung: updateClassSettingOptimistic, `_isUpdating` guard, mapping enrollment/qr_code/group_management/student_permissions.

- **Skill nhóm MCP & Dev Workflow**
- `mcp_supabase_schema_and_migrations`
- Mục tiêu: trước khi đổi model/repo, dùng MCP để xem schema/migrations.
- Nội dung: mcp_supabase-official tools chính, checklist khi tạo bảng mới.
- `mcp_context7_and_fetch_for_docs`
- Mục tiêu: dùng Context7/FETCH để tra cứu docs library thay vì đoán.
- Nội dung: patterns tra cứu theo lib + task.
- `dev_workflow_quality_and_testing`
- Mục tiêu: luôn chạy analyze/test, tuân theo lint và `.clinerules` về kích thước hàm/file, format.
- Nội dung: các lệnh chuẩn, commit conventions, test chiến lược.

### 3. Chuẩn hóa format skill `.cursor/skills` (sau khi bạn đồng ý)

- **Cấu trúc mỗi skill (JSON/YAML tuỳ config hiện tại của bạn):**
- **metadata:** tên, mô tả ngắn, tags (flutter, supabase, mcp, ui, routing, v.v.).
- **triggers:** các từ khóa hoặc file patterns (vd: `lib/core/routes/**`, `design_tokens.dart`, `class_notifier.dart`).
- **rules:** danh sách câu ngắn, actionable ("Do this / Don’t do this").
- **examples:** 1–2 snippet ngắn thành công/thất bại (trích từ docs hiện có, đã rút gọn).
- **links:** đường dẫn docs nội bộ (`memory-bank/systemPatterns.md`, `QUICK_REFERENCE.md`, v.v.).
- **Nguyên tắc:**
- Mỗi skill ~1–2 màn hình, tránh quá dài; nếu dài, tách thành skill con.
- Không copy nguyên văn 900+ lines design_tokens; chỉ trích xuất rule quan trọng.

### 4. Lộ trình áp dụng skill vào phát triển dự án

- **Giai đoạn 1 – Chuẩn hóa skill core**
- Ưu tiên tạo nhóm skill: `flutter_clean_architecture`, `flutter_state_management_riverpod`, `routing_gorouter_rbac_shellroute`, `design_system_tokens_and_enforcement`, `supabase_integration_and_env`, `repository_and_error_handling`.
- Dùng chúng để "gác cổng" khi thêm feature mới (assignment builder, workspace, v.v.).
- **Giai đoạn 2 – Skill cho module UI phức tạp**
- Thêm các skill: `widgets_drawer_system`, `widgets_dialog_system`, `widgets_search_system`, `design_system_responsive_and_accessibility`.
- Áp dụng khi refactor UI hiện có (dashboard, class detail, form screens).
- **Giai đoạn 3 – Skill về Supabase nâng cao & MCP**
- Bổ sung `class_settings_and_optimistic_updates`, `mcp_supabase_schema_and_migrations`, `mcp_context7_and_fetch_for_docs`, `dev_workflow_quality_and_testing`.
- Dùng khi mở rộng schema (assignments, submissions, ai_evaluations) và khi cần agent thao tác database qua MCP.

### 5. Cách rèn luyện & kiểm thử skill

- **Scenario-based practice:**
- Đặt giả lập task (vd: "tạo màn Assignment Builder", "thêm toggle mới vào ClassSettingsDrawer") và kiểm xem agent có tự áp dụng đúng skill không (xem code đề xuất có tuân thủ rules không).
- **Checklists:**
- Với mỗi skill chính, tạo checklist ngắn để review PR (vd: cho routing: dùng `goNamed?`, path helper? RBAC có update?).
- **Iterate:**
- Khi phát hiện pattern mới (vd: offline-first với Drift, AI grading flows), thêm skill mới cùng cấu trúc trên.

Nếu bạn đồng ý với plan này, bước tiếp theo sẽ là cùng bạn thiết kế format cụ thể cho một vài skill mẫu (1–2 file), rồi sau đó nhân rộng cho toàn bộ nhóm skill trên.