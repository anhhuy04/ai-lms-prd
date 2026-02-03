# UI Design System v2 – TODO Plan

> Lộ trình còn lại để hoàn thành migrate sang Design System v2 + sunset `design_tokens.dart`.

## Phase 1 – Dọn sạch `design_tokens.dart` khỏi `lib/presentation/**`

- [ ] Rà lại toàn bộ `lib/presentation/**` để chắc chắn chỉ còn các file sau import `core/constants/design_tokens.dart`:
  - [ ] `class/teacher/add_student_by_code_screen.dart`
  - [ ] `class/teacher/student_list_screen.dart`
  - [ ] `class/teacher/widgets/drawers/class_settings_drawer.dart`
  - [ ] `class/teacher/edit_class_screen.dart`
  - [ ] `class/teacher/create_class_screen.dart`
  - [ ] `class/student/qr_scan_screen.dart`
  - [ ] `class/student/join_class_screen.dart`
  - [ ] `class/student/student_class_detail_screen.dart`
  - [ ] `class/teacher/widgets/drawers/class_create_class_setting_drawer.dart`
  - [ ] `class/teacher/teacher_class_detail_screen.dart`
  - [ ] `class/student/widgets/drawers/student_class_settings_drawer.dart`
  - [ ] `class/teacher/widgets/drawers/class_settings_drawer_handlers.dart`
- [ ] Với từng file trên:
  - [ ] Thay `DesignColors/DesignTypography/DesignSpacing/DesignRadius/...` bằng `Theme.of(context).colorScheme/textTheme` + spacing/radius rõ ràng.
  - [ ] Ưu tiên dùng `TextTheme` (headline/title/body/caption) thay vì fontSize số magic.
  - [ ] Giữ nguyên logic điều hướng, Riverpod, Supabase (UI-only change).
  - [ ] Chạy linter cho file đó sau khi sửa.
- [ ] Chạy 1 lần grep cuối cùng để xác nhận **không còn** `core/constants/design_tokens.dart` trong `lib/presentation/**`.

## Phase 2 – Bổ sung semantic text/spacing để xoá số magic còn lại

- [ ] Quét nhanh lại các màn đã migrate (dashboard, home, assignment, auth, class screens) để liệt kê:
  - [ ] Các kiểu text lặp lại: page title, section title, caption phụ, số liệu lớn (stat), badge nhỏ, text on-primary.
  - [ ] Các khoảng cách lặp lại: sectionSpacing, itemSpacing, chip/badge padding, card padding.
- [ ] Cập nhật `AppTextStyles` trong `lib/core/design_system/semantics/app_text_styles.dart`:
  - [ ] Thêm 3–5 semantic role **ít nhưng chất lượng** (ví dụ: `sectionTitle`, `statValueLarge`, `badgeLabelSmall`, `captionOnPrimary`).
  - [ ] Mỗi role map về `TextTheme` Material tương ứng (không bịa thêm hệ text mới).
- [ ] (Nếu cần) Cập nhật `AppSpacing` trong `app_spacing.dart` cho các pattern spacing rõ rệt.
- [ ] Vòng refactor 2:
  - [ ] Thay các `fontSize: 12/14/16/24/...` lặp lại bằng semantic mới hoặc `textTheme` phù hợp.
  - [ ] Thay các `EdgeInsets.symmetric/all` số magic lặp nhiều bằng `context.appTheme.spacing.*` khi đã có.

## Phase 3 – DS Components cho pattern chung

- [ ] Xác định pattern UI lặp lại nhiều:
  - [ ] Section header (title + actionText bên phải).
  - [ ] Stat card nhỏ (icon + title + value lớn).
  - [ ] Class tile / assignment tile (card có title + subtitle + badge trạng thái).
- [ ] Thiết kế component trong `lib/core/design_system/components/` (hoặc `widgets/ds/` nếu phù hợp):
  - [ ] `AppSectionHeader` – dùng `AppTextStyles` + `AppSpacing` + `ColorScheme`.
  - [ ] `AppStatChip` / `AppStatCard` – hiển thị số liệu tóm tắt.
  - [ ] `AppStatusBadge` – badge trạng thái (success/warning/info/overdue).
- [ ] Refactor các màn dashboard/home/assignment/class để dùng DS components thay vì layout thủ công.

## Phase 4 – Verification + Sunset `design_tokens.dart`

- [ ] Chạy `flutter analyze` toàn project, đảm bảo không có lỗi mới từ UI refactor.
- [ ] Chạy nhanh các flow chính:
  - [ ] Login/Register.
  - [ ] Teacher dashboard + class list + create class.
  - [ ] Student dashboard + home + class detail.
  - [ ] Assignment list.
- [ ] Kiểm tra lại:
  - [ ] Không còn import `core/constants/design_tokens.dart` trong `lib/presentation/**`.
  - [ ] Các chỗ còn dùng `Design*` (nếu có) chỉ nằm ở core/legacy (nếu thật sự cần).
- [ ] Nếu thoả điều kiện sunset:
  - [ ] Đánh dấu `design_tokens.dart` là **DEPRECATED** hoàn toàn trong docs.
  - [ ] (Tuỳ quyết định) hoặc giữ file như một shim cho core, hoặc xoá nếu không còn import ở bất cứ đâu.

## Phase 5 – Enforcement (sau khi code ổn định)

- [ ] Thêm ghi chú vào `.clinerules` / `.cursor/skills/40_ui_design_system_tokens.md` về:
  - [ ] Cấm dùng `Color(0xFF...)`, `TextStyle(...)`, `EdgeInsets(...)`, `BorderRadius.circular(...)`, `BoxShadow(...)` trực tiếp trong `lib/presentation/**` (trừ escape hatch có TODO).
  - [ ] UI mới phải đi qua `Theme.of(context)` + DS components / `context.appTheme`.
- [ ] (Tuỳ chọn) Chuẩn bị 1 grep-script/PowerShell đơn giản để check trước commit:
  - [ ] Tìm `core/constants/design_tokens.dart`.
  - [ ] Tìm pattern hardcode màu/spacing phổ biến.
- [ ] Cập nhật playbook `.cursor/skills/playbook_refactor_or_migration.md` để ghi rõ checklist khi migrate UI theo Design System v2.