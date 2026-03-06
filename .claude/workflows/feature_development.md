---
name: feature_development
description: Workflow cho phát triển tính năng mới hoặc thay đổi lớn. Áp dụng quy trình Plan -> Execute -> Debug -> Check.
trigger: /feature
---

# Workflow: Phát triển Tính năng Mới

## 1. Read Core Context (BẮT BUỘC)

### Memory Bank
- Đọc `memory-bank/activeContext.md` — focus hiện tại
- Đọc `memory-bank/progress.md` — trạng thái project

### Rules & Skills
- Đọc `.claude/CLAUDE.md` — rules tổng quan
- Load skill liên quan:
  - UI → `/skill:ui-widgets`
  - State → `/skill:state`
  - Supabase → `/skill:supabase`
  - Routing → `/skill:routing`

---

## 2. Plan (Analyze & Design)

### ✅ Yêu cầu rõ ràng?
- **NO** → Dừng lại, hỏi user để clarify requirements

### ✅ Analyze Codebase
```bash
# Kiểm tra provider existing
grep -r "featureNameProvider" lib/

# Kiểm tra route existing
grep -r "feature" lib/core/routes/

# Kiểm tra model existing
grep -r "FeatureName" lib/domain/entities/
```

### 📝 Viết Implementation Plan
Tạo file `tasks/todo.md`:

```markdown
# [Feature Name] Implementation Plan

## Architecture
- [ ] Domain: Entity, Repository Interface
- [ ] Data: DTO, Repository Impl, DataSource
- [ ] Presentation: Provider, Screen, Widgets

## State Management
- [ ] AsyncNotifier với @riverpod
- [ ] Concurrency guard nếu cần
- [ ] Bundle loader nếu load nhiều data

## Routing
- [ ] Thêm route constants
- [ ] Thêm GoRoute (specific TRƯỚC parameterized)
- [ ] RBAC nếu cần

## UI
- [ ] Design Tokens (DesignColors, DesignSpacing...)
- [ ] Shimmer loading
- [ ] Responsive (flutter_screenutil)

## Data
- [ ] Schema check (Supabase MCP)
- [ ] RLS policies
- [ ] Freezed model + fromJson
```

### ✅ Chờ User Approve
- **KHÔNG** tiến hành code cho đến khi user approve plan

---

## 3. Execute (Implement)

### Theo plan đã approve, implement:
1. **Domain Layer**
   - Entity trong `lib/domain/entities/`
   - Repository interface trong `lib/domain/repositories/`

2. **Data Layer**
   - DTO với `@freezed` + `json_serializable`
   - Repository impl trong `lib/data/repositories/`
   - DataSource trong `lib/data/datasources/`

3. **Presentation Layer**
   - Provider với `@riverpod` annotation
   - Screen trong `lib/presentation/views/`
   - Widgets trong `lib/presentation/views/[feature]/widgets/`

4. **Core**
   - Route constants trong `lib/core/routes/route_constants.dart`
   - GoRoute trong `lib/core/routes/app_router.dart`

### Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 4. Debug (Static Analysis)

### BẮT BUỘC chạy:
```bash
flutter analyze
```

### Nếu có lỗi:
- Fix từng lỗi một
- Chạy lại `flutter analyze` sau mỗi fix
- **KHÔNG** chuyển sang Check nếu còn lỗi

### Common Fixes
| Lỗi | Cách fix |
|------|----------|
| Missing import | Thêm import |
| Undefined method | Chạy build_runner |
| Type error | Kiểm tra generic types |
| Null safety | Thêm null check |

---

## 5. Check (Verify & Document)

### ✅ Test
- Chạy unit/widget tests nếu có
- Test happy path + error cases

### ✅ Update Memory Bank
```markdown
## YYYY-MM-DD
- Feature: [Tên feature]
- Files: lib/...
- Status: ✅ Complete
```

### ✅ Final Verify
```bash
flutter analyze  # Final check
```

### ✅ Báo cáo User
- Tóm tắn feature đã implement
- Files đã tạo/sửa
- Cách test
