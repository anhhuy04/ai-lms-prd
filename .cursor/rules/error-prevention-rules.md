# Error Prevention Rules

> File này chứa các quy tắc được rút ra từ các sai sót thực tế trong quá trình phát triển để tránh lặp lại lỗi.

## 1. GoRouter Route Ordering (CRITICAL)

### Vấn đề đã gặp:
Route có parameter `/student/class/:classId` match trước route cụ thể `/student/class/search`, gây ra lỗi "unknown route name".

### Quy tắc:
- ✅ **Route cụ thể PHẢI đứng TRƯỚC route có parameter**
- ✅ Khi thêm route mới, kiểm tra xem có route nào có parameter có thể match path của route mới không
- ✅ Sắp xếp routes trong `app_router.dart` theo thứ tự: specific routes → parameterized routes → catch-all routes

### Ví dụ đúng:
```dart
// ✅ ĐÚNG: Route cụ thể đứng trước
GoRoute(
  path: '/student/class/search',
  name: AppRoute.studentClassSearch,
  builder: (context, state) => const StudentClassSearchScreen(),
),
GoRoute(
  path: '/student/class/:classId',
  name: AppRoute.studentClassDetail,
  builder: (context, state) => StudentClassDetailScreen(...),
),
```

### Ví dụ sai:
```dart
// ❌ SAI: Route có parameter đứng trước
GoRoute(
  path: '/student/class/:classId',  // Sẽ match '/student/class/search' trước!
  name: AppRoute.studentClassDetail,
  builder: (context, state) => StudentClassDetailScreen(...),
),
GoRoute(
  path: '/student/class/search',
  name: AppRoute.studentClassSearch,
  builder: (context, state) => const StudentClassSearchScreen(),
),
```

### Checklist khi thêm route mới:
- [ ] Route cụ thể đã đứng trước route có parameter?
- [ ] Đã test navigation với path đầy đủ?
- [ ] Đã kiểm tra không có route nào khác match path này?

---

## 2. Provider Duplication Prevention

### Vấn đề đã gặp:
Tạo `studentSearchScreenQueryProvider` hai lần trong cùng file, gây lỗi "already defined".

### Quy tắc:
- ✅ **TRƯỚC KHI tạo provider mới, PHẢI grep để kiểm tra đã tồn tại chưa**
- ✅ Sử dụng `grep` tool với pattern tên provider trước khi định nghĩa
- ✅ Nếu provider đã tồn tại, reuse thay vì tạo mới

### Workflow:
```bash
# 1. Grep trước khi tạo
grep -r "studentSearchScreenQueryProvider" lib/

# 2. Nếu không có kết quả, mới tạo mới
# 3. Nếu đã có, reuse hoặc refactor
```

### Checklist:
- [ ] Đã grep tên provider trước khi định nghĩa?
- [ ] Đã kiểm tra file hiện tại có định nghĩa trùng không?
- [ ] Đã kiểm tra các file import có định nghĩa trùng không?

---

## 3. Null Safety & API Usage

### Vấn đề đã gặp:
- Dùng `barcodes.first` trực tiếp mà không kiểm tra null/empty
- `analyzeImage()` có thể trả về null hoặc empty list

### Quy tắc:
- ✅ **LUÔN kiểm tra null và empty trước khi access collection elements**
- ✅ Sử dụng null-aware operators (`?.`, `??`) khi cần
- ✅ Kiểm tra `isEmpty` trước khi dùng `.first` hoặc `.last`
- ✅ Đọc documentation của API để biết return type (nullable hay không)

### Pattern đúng:
```dart
// ✅ ĐÚNG: Kiểm tra đầy đủ
final capture = await _scannerController.analyzeImage(file.path);

if (capture == null || capture.barcodes.isEmpty) {
  // Handle error
  return;
}

// Tìm barcode hợp lệ đầu tiên
Barcode? firstValid;
for (final barcode in capture.barcodes) {
  final value = barcode.rawValue;
  if (value != null && value.isNotEmpty) {
    firstValid = barcode;
    break;
  }
}

if (firstValid == null) {
  // Handle no valid barcode
  return;
}

// Mới dùng firstValid
final rawValue = firstValid.rawValue!;
```

### Pattern sai:
```dart
// ❌ SAI: Không kiểm tra null/empty
final barcodes = await _scannerController.analyzeImage(file.path);
final rawValue = barcodes.first.rawValue!;  // Có thể crash!
```

### Checklist:
- [ ] Đã kiểm tra null trước khi access?
- [ ] Đã kiểm tra empty collection trước khi dùng `.first`?
- [ ] Đã đọc API documentation để biết return type?
- [ ] Đã handle tất cả edge cases?

---

## 4. Dependency Management

### Vấn đề đã gặp:
- Import `image_picker` trong code nhưng chưa thêm vào `pubspec.yaml`
- Gây lỗi "Target of URI doesn't exist"

### Quy tắc:
- ✅ **TRƯỚC KHI import package mới, PHẢI thêm vào `pubspec.yaml` trước**
- ✅ Chạy `flutter pub get` sau khi thêm dependency
- ✅ Kiểm tra version compatibility với các package khác
- ✅ Nếu package đã có trong "Optional/Future Dependencies", di chuyển sang active dependencies

### Workflow:
```bash
# 1. Thêm vào pubspec.yaml
# 2. Chạy flutter pub get
flutter pub get

# 3. Sau đó mới import trong code
```

### Checklist:
- [ ] Đã thêm package vào `pubspec.yaml`?
- [ ] Đã chạy `flutter pub get`?
- [ ] Đã kiểm tra version compatibility?
- [ ] Đã cập nhật `techContext.md` với package mới?

---

## 5. Requirement Clarification

### Vấn đề đã gặp:
- Implement `leaveClass` với update status thành 'left'
- User sau đó yêu cầu xóa hoàn toàn
- Phải refactor lại code

### Quy tắc:
- ✅ **KHI implement feature mới, PHẢI hỏi rõ requirement về behavior**
- ✅ Đặc biệt với các operations quan trọng (delete, update status, etc.)
- ✅ Nếu có nhiều cách implement, đề xuất và hỏi user chọn
- ✅ Document decision trong code comments

### Questions to ask:
- "Xóa hoàn toàn hay chỉ đổi status?"
- "Có cần giữ lại lịch sử không?"
- "Có cần rollback không?"

### Checklist:
- [ ] Đã hỏi rõ requirement về behavior?
- [ ] Đã đề xuất các options nếu có nhiều cách?
- [ ] Đã document decision trong code?

---

## 6. Import Management

### Vấn đề đã gặp:
- Thiếu import các package cần thiết
- Import không đúng path

### Quy tắc:
- ✅ **Sau khi viết code, PHẢI chạy `read_lints` để kiểm tra missing imports**
- ✅ Sử dụng IDE auto-import khi có thể
- ✅ Kiểm tra import paths đúng với project structure

### Workflow:
```bash
# 1. Viết code
# 2. Chạy linter
read_lints paths: ['lib/presentation/views/class/student/qr_scan_screen.dart']

# 3. Fix missing imports
# 4. Chạy lại linter để verify
```

### Checklist:
- [ ] Đã chạy linter sau khi viết code?
- [ ] Đã fix tất cả missing imports?
- [ ] Đã kiểm tra import paths đúng?

---

## 7. Code Generation After Changes

### Vấn đề đã gặp:
- Thêm fields mới vào Freezed class nhưng chưa chạy build_runner
- Gây lỗi incompatible parameters

### Quy tắc:
- ✅ **SAU KHI thay đổi Freezed/JsonSerializable classes, PHẢI chạy build_runner**
- ✅ Chạy với flag `--delete-conflicting-outputs` để tránh conflicts
- ✅ Kiểm tra generated files đã được update chưa

### Command:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Checklist:
- [ ] Đã chạy build_runner sau khi thay đổi Freezed class?
- [ ] Đã kiểm tra generated files?
- [ ] Đã fix các lỗi nếu có?

---

## 8. Testing After Implementation

### Vấn đề đã gặp:
- Implement feature nhưng chưa test đầy đủ các edge cases
- Một số lỗi chỉ phát hiện khi user test

### Quy tắc:
- ✅ **SAU KHI implement, PHẢI test các scenarios:**
  - Happy path (normal flow)
  - Error cases (null, empty, invalid data)
  - Edge cases (boundary conditions)
- ✅ Test trên thiết bị thật nếu có thể
- ✅ Kiểm tra navigation flows

### Checklist:
- [ ] Đã test happy path?
- [ ] Đã test error cases?
- [ ] Đã test edge cases?
- [ ] Đã test navigation flows?

---

## Summary: Pre-Implementation Checklist

Trước khi implement bất kỳ feature nào, hãy:

1. ✅ **Requirement**: Hỏi rõ requirement về behavior
2. ✅ **Dependencies**: Thêm vào `pubspec.yaml` và chạy `flutter pub get`
3. ✅ **Existing Code**: Grep để kiểm tra không duplicate
4. ✅ **Route Order**: Kiểm tra route order trong `app_router.dart`
5. ✅ **Null Safety**: Plan null checks và error handling
6. ✅ **API Docs**: Đọc documentation của API/package mới
7. ✅ **Code Generation**: Chạy build_runner nếu thay đổi Freezed classes
8. ✅ **Linter**: Chạy linter và fix tất cả errors
9. ✅ **Testing**: Test các scenarios quan trọng
10. ✅ **Documentation**: Cập nhật memory bank nếu cần
