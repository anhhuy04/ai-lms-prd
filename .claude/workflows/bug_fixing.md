---
name: bug_fixing
description: Workflow cho debug và sửa lỗi. Áp dụng Scientific Method: Observe -> Hypothesize -> Experiment -> Fix.
trigger: /bug
---

# Workflow: Bug Fixing

## 1. Observe (Đọc lỗi)

### User báo lỗi
- Đọc exact error message từ user
- Hỏi user để lấy thêm context nếu cần

### Từ terminal/logs
```bash
# Đọc logs.txt nếu có
cat logs.txt

# Chạy flutter để reproduce
flutter analyze
```

### Classify Lỗi
| Type | Ví dụ | Check |
|------|--------|-------|
| **Compile Error** | `Undefined name 'x'` | Syntax, import |
| **Runtime Error** | `Null check operator` | Null safety |
| **Logic Error** | Sai data hiển thị | Business logic |
| **UI Error** | Overflow, render error | Layout, constraints |
| **Network Error** | API fail | Supabase, Dio |

---

## 2. Hypothesize (Phân tích)

### Đọc Context
- Đọc `memory-bank/activeContext.md` — đang làm gì
- Đọc `memory-bank/progress.md` — trạng thái project

### Tra cứu Rules
- **UI Error** → `/skill:ui-widgets`
- **State Error** → `/skill:state`
- **Network Error** → `/skill:supabase`, `/skill:networking`
- **Architecture** → `/skill:architecture`

### Analyze Root Cause
```bash
# Tìm file liên quan
grep -r "functionName" lib/

# Tìm provider
grep -r "Provider" lib/presentation/providers/

# Tìm route
grep -r "route" lib/core/routes/
```

### Form Hypothesis
- Xác định **root cause** (KHÔNG phải symptom)
- Ví dụ: "Null check error" → **Root**: "API trả về null khi không có data"

---

## 3. Experiment (Thử nghiệm)

### Minimal Fix
- **TỐI THIỂU** — chỉ sửa phần cần thiết
- **KHÔNG** rewrite nguyên class trừ khi bắt buộc

### Fix Pattern theo Type

#### Null Safety
```dart
// ❌ Before
final name = user.name!;

// ✅ After
final name = user.name ?? 'Unknown';
```

#### Route Ordering
```dart
// ❌ Wrong — param match trước
GoRoute(path: '/student/:id', ...),
GoRoute(path: '/student/search', ...),

// ✅ Correct
GoRoute(path: '/student/search', ...),
GoRoute(path: '/student/:id', ...),
```

#### State Concurrency
```dart
// ❌ Missing guard
Future<void> save() async {
  state = await api.save();
}

// ✅ With guard
bool _isSaving = false;
Future<void> save() async {
  if (_isSaving) return;
  _isSaving = true;
  try {
    state = await api.save();
  } finally {
    _isSaving = false;
  }
}
```

---

## 4. Verify (Kiểm tra)

### Static Analysis
```bash
flutter analyze
```

### Test
```bash
# Unit test
flutter test test/unit/

# Widget test
flutter test test/widget/

# Specific file
flutter test test/path/to/test.dart
```

### Rebuild nếu cần
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

---

## 5. Document (Ghi nhận)

### Update Memory Bank
```markdown
## YYYY-MM-DD
- Bug: [Mô tả lỗi]
- Root Cause: [Nguyên nhân gốc]
- Fix: [Cách fix]
- Files: [Danh sách files]
```

### Update Rules nếu cần
- Nếu bug là pattern mới → thêm vào `.claude/CLAUDE.md`

### Báo cáo User
- Mô tả lỗi
- Root cause
- Cách fix
- Cách verify
