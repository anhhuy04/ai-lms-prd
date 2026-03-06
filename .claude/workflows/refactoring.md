---
name: refactoring
description: Workflow cho refactoring code: tách file, đổi tên, tối ưu, extract method.
trigger: /refactor
---

# Workflow: Refactoring

## 1. Analyze

### Xác định mục tiêu
- [ ] Tách file quá lớn (>300 lines)
- [ ] Đổi tên cho nhất quán
- [ ] Extract method/component
- [ ] Clean up unused code
- [ ] Optimize performance

### Check Dependencies
```bash
# Tìm usage của function/class
grep -r "MyClass" lib/

# Tìm import
grep -r "import.*my_file" lib/
```

### Đọc Rules
- `/skill:architecture` — Clean Architecture boundaries
- `/skill:state` — Riverpod patterns

---

## 2. Plan

### Xác định scope
- **Small** (< 50 lines change): Thực hiện luôn
- **Large** (> 50 lines): Viết plan, chờ approve

### Risk Assessment
- [ ] Breaking changes có thể có?
- [ ] Cần update tests?
- [ ] Cần update routes/providers?

---

## 3. Execute

### Safe Refactoring Steps

#### Tách Widget
```dart
// ❌ Before
Widget build(BuildContext context) {
  return Column(children: [
    // 100 lines...
  ]);
}

// ✅ After
Widget build(BuildContext context) {
  return Column(children: [
    _buildHeader(),
    _buildContent(),
    _buildFooter(),
  ]);
}

Widget _buildHeader() => ...
Widget _buildContent() => ...
Widget _buildFooter() => ...
```

#### Extract to File
1. Tạo file mới
2. Di chuyển code
3. Update imports
4. Chạy analyze

#### Rename
1. Rename trong file
2. Update tất cả references
3. Update route constants nếu cần

---

## 4. Verify

### Analyze
```bash
flutter analyze
```

### Test
```bash
flutter test
```

### Check Imports
```bash
# Verify không có unused imports
flutter analyze | grep unused
```

---

## 5. Document

### Update Memory Bank
```markdown
## YYYY-MM-DD
- Refactor: [Mô tả]
- Files: [Danh sách]
- Breaking: [Có/Không]
```
