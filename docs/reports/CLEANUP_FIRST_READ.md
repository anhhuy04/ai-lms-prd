# CLEANUP_FIRST_READ

Mục tiêu: **đây là file cần đọc đầu tiên** mỗi khi bạn muốn “quét/clear code” để biết:
- Những gì đã làm xong
- Những gì còn lại / rủi ro tiềm ẩn
- Các bước an toàn để tiếp tục dọn dẹp mà không phá build

## 1) Trạng thái hiện tại (đã xác nhận)

- `flutter analyze`: **No issues found**

## 2) Những thay đổi đã hoàn thành (theo plan)

### 2.1 Provider → Riverpod migration (đã làm)
- `lib/core/utils/refresh_utils.dart`: migrate sang Riverpod (dùng provider auth hiện có)
- `lib/widgets/drawers/class_advanced_settings_drawer.dart`: migrate sang Riverpod
- Xóa legacy `ClassSettingsDrawer` bản Provider
- Chuẩn hóa dùng `ClassSettingsDrawer` Riverpod

### 2.2 Xóa code trùng/lỗi thời (đã làm)
- Xóa:
  - `lib/widgets/search_dialog.dart`
  - `lib/widgets/search/smart_search_dialog.dart`
- Giữ: `lib/widgets/search/smart_search_dialog_v2.dart` (đang dùng)

### 2.3 Tối ưu file lớn (đã làm một phần)
- `lib/widgets/drawers/class_settings_drawer.dart`: đã giảm size mạnh (tách handler ra file riêng)
- Tách handlers: `lib/widgets/drawers/class_settings_drawer_handlers.dart`

### 2.4 Dependency review (đã làm)
- Drift / Retrofit+Dio: **giữ** (sẵn sàng cho tương lai)
- Freezed: **đang dùng** trong entities
- Report: `docs/reports/dependency-review.md`

### 2.5 Documentation consolidation (đã làm)
- `ROUTER_V2_MIGRATION.md` → `docs/guides/development/router-v2-migration.md`
- `SETUP_COMPLETE.md` → `docs/reports/setup-complete.md`
- `CHANGELOG_TECH_STACK.md` → `docs/reports/changelog-tech-stack.md`
- `SETUP_ENV.md`: remove (trùng nội dung với guide trong docs)

## 3) Những “bẫy” dễ phát sinh khi app lớn (đã harden một phần)

- **Async + BuildContext**: đã fix các điểm chính bằng `context.mounted` / `mounted` đúng chỗ
- **API deprecated Flutter**: đã xử lý `PopScope.onPopInvoked` → `onPopInvokedWithResult`, `withOpacity` → `withValues(alpha: ...)`
- **Test noise / lint**: dọn các test để không spam `print` và không fail lint

## 4) Những việc còn lại (nếu muốn sạch hơn nữa)

### 4.1 Dọn thư mục/đường dẫn không cần (optional)
- `lib/routes/` nếu còn rỗng: có thể xóa
- Kiểm tra `lib/presentation/fetchers/class_list_fetcher.dart` có còn được dùng không

### 4.2 Giảm file > 300 lines theo `.clinerules` (optional)
- `class_settings_drawer.dart` hiện đã giảm nhưng có thể tách tiếp thành:
  - `sections/student_management_section.dart`
  - `sections/class_settings_section.dart`
  - `sections/danger_zone_section.dart`
  - (chỉ làm nếu bạn muốn enforce 300 lines tuyệt đối)

### 4.3 CI / Quality gate (recommended)
- Chạy định kỳ:
  - `flutter analyze`
  - `flutter test`
  - `dependency_validator`

## 5) Checklist nhanh trước khi “clear” thêm

- [ ] Chạy `flutter analyze` (phải sạch)
- [ ] Grep usage trước khi xóa file
- [ ] Nếu đụng UI async: đảm bảo `context.mounted` sau `await`
- [ ] Sau mỗi batch: chạy lại `flutter analyze`

