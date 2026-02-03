---
name: playbook_add_new_feature_end_to_end
intent: Checklist triển khai feature từ A→Z theo Clean Architecture + GoRouter + Riverpod
tags: [playbook, workflow, flutter]
---

## Khi dùng

Khi bạn muốn thêm một feature/screen mới (vd: Assignment Builder, Workspace, Class feature).

## Checklist (A→Z)

### 1) Đọc context đúng (không đoán)

- `.clinerules` (sections liên quan)
- `.cursor/.cursorrules` (tech stack + conflict priority + Sentry)
- `memory-bank/systemPatterns.md` + `activeContext.md` (pattern mới nhất)
- Nếu DB: `docs/ai/README_SUPABASE.md` + Supabase MCP check schema

### 2) Routing

- Add route name/path/helper vào `lib/core/routes/route_constants.dart`
- Add GoRoute/ShellRoute child trong `lib/core/routes/app_router.dart`
- Update RBAC helper nếu route role-restricted
- UI navigation dùng `context.goNamed()` + `pathParameters`

### 3) Presentation

- Screen: `lib/presentation/views/.../*_screen.dart`
- State: ưu tiên Riverpod notifier trong `lib/presentation/providers/...`
- UI render theo `.when(loading/error/data)` nếu AsyncValue

### 4) Domain

- Entity (`freezed`) trong `lib/domain/entities/`
- Repository interface trong `lib/domain/repositories/`
- (Optional) UseCase trong `lib/domain/usecases/` nếu logic phức tạp

### 5) Data

- DataSource Supabase trong `lib/data/datasources/` (query raw)
- RepoImpl trong `lib/data/repositories/` (map → entity, translate error VN)

### 6) UX + Design system

- Không hardcode màu/spacing/font/etc (DesignTokens)
- Split build() nếu dài; reuse widgets trong `lib/widgets/`

### 7) Logging + errors

- Không dùng `print`; dùng `AppLogger`
- Errors user-facing: tiếng Việt (qua repository/exception)
- Critical flows: report Sentry theo `.cursor/.cursorrules`

### 8) Tests (tối thiểu)

- Unit test cho notifier/repo logic chính (nếu chạm logic quan trọng)
- Widget test flow chính nếu feasible

## Links

- `.clinerules`
- `memory-bank/systemPatterns.md`
- `analysis_options.yaml`

