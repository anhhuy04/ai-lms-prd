# Session Notes (AI LMS Project)

> File dùng để lưu tóm tắt sau mỗi phiên làm việc, giúp agent mới nắm nhanh ngữ cảnh. Append entry mới, không overwrite. Chỉ dọn dẹp entry cũ khi đã có entry thay thế và quy trình log ổn định.

## Template entry (append dưới đây)
- Timestamp (ISO, ví dụ `2026-01-20T15:30Z`)
- Task/feature chính, files chạm
- Quyết định/kết luận quan trọng
- TODO còn lại / follow-up
- Links/paths tham chiếu (nếu có)

---

## Log
- *Chưa có entry. Thêm entry mới ở đây theo template trên.*

- 2026-01-20T15:30Z
  - Task/feature chính, files chạm: Migrate các dashboard screens sang Riverpod (`student_dashboard_screen.dart`, `student_home_content_screen.dart`, `teacher_dashboard_screen.dart`) dùng `authNotifierProvider` và `studentDashboardNotifier`; setup responsive với `ScreenUtilInit` trong `main.dart` (designSize 375x812, minTextAdapt, splitScreenMode); cập nhật `pubspec.yaml` (drift_dev tạm comment do xung đột retrofit_generator); giữ note html dependency do user thêm.
  - Quyết định/kết luận quan trọng: Drift (TODO 4.1-4.5) tạm hoãn vì conflict analyzer giữa `drift_dev` và `retrofit_generator`; Riverpod migration cho các dashboard chính đã xong, còn một số screens class/student chưa migrate; ScreenUtil đã bật ở app root.
  - TODO còn lại / follow-up: Migrate nốt các screens còn dùng Provider (`teacher_class_detail`, `create_class`, `edit_class`, `student_class_list`, `join_class`); xử lý cảnh báo `withOpacity` deprecated; chạy lại `flutter pub run build_runner build --delete-conflicting-outputs` (lệnh trước bị interrupt) và `flutter analyze` toàn dự án; tìm giải pháp version cho drift_dev vs retrofit_generator hoặc tạm defer Drift; cập nhật memory-bank sau khi hoàn tất.
  - Links/paths tham chiếu: `lib/presentation/views/dashboard/student_dashboard_screen.dart`, `lib/presentation/views/dashboard/home/student_home_content_screen.dart`, `lib/presentation/views/dashboard/teacher_dashboard_screen.dart`, `lib/main.dart`, `pubspec.yaml`, `.cursor/.cursorrules`.

- 2026-01-20T16:00Z
  - Task/feature chính, files chạm: Tổng hợp nhanh trạng thái các file plan để người mới nắm: `c:\\Users\\anhhuy\\.cursor\\plans\\library_integration_todo_plan_6df8b486.plan.md` (plan trung tâm 7 category, critical path AppLogger→Sentry→Freezed→Riverpod→Drift) và `.\cursor\plans\tong_ket_toan_bo_qua_trinh_thuc_hien_tu_dau_den_hien_tai.md` (tóm lược bối cảnh, rules, tiến độ). Category 1, 2 đã [✔]; Category 3 còn TODO 3.11 (các screens dùng Provider cũ), Category 4 (Drift) đang deferred do xung đột version; Category 5 (ScreenUtil) đã setup ở `main.dart`; Category 6 (build_runner workflow) và Category 7 (docs/memory-bank) chưa hoàn tất.
  - Quyết định/kết luận quan trọng: Giữ drift_dev commented vì conflict với `retrofit_generator` (analyzer version). Tiếp tục ưu tiên migrate nốt screens Provider cũ và chạy lại build_runner + analyze sau khi ổn định.
  - TODO còn lại / follow-up: (1) Migrate các screens còn lại dùng Provider (`teacher_class_detail`, `create_class`, `edit_class`, `student_class_list`, `join_class`). (2) Xử lý deprecated `withOpacity`. (3) Rerun `flutter pub run build_runner build --delete-conflicting-outputs` và `flutter analyze` toàn dự án. (4) Tìm combo version giải quyết drift_dev vs retrofit_generator hoặc tạm defer Drift (TODO 4.x). (5) Cập nhật memory-bank (techContext/systemPatterns/activeContext) sau khi hoàn tất các thay đổi lớn.
  - Links/paths tham chiếu: `c:\\Users\\anhhuy\\.cursor\\plans\\library_integration_todo_plan_6df8b486.plan.md`, `.cursor/plans/tong_ket_toan_bo_qua_trinh_thuc_hien_tu_dau_den_hien_tai.md`, `pubspec.yaml`, `lib/main.dart`.

- 2026-01-20T17:00Z
  - Task/feature chính, files chạm: Migrate Riverpod cho khối lớp học: `student_class_list_screen.dart` (ref.watch classNotifier, authNotifier, AsyncValue.when), `join_class_screen.dart` (Riverpod, trạng thái submitting), `create_class_screen.dart` (Riverpod, dùng authNotifier + classNotifier.createClass), `edit_class_screen.dart` (Riverpod, dùng classNotifier.updateClass), mở rộng `class_notifier.dart` (loadClassesByStudent, loadClassDetails, selectedClass, detailErrorMessage, requestJoinClass, đồng bộ selectedClass khi update/delete). Chạy `build_runner` thành công sau thay đổi notifier.
  - Quyết định/kết luận quan trọng: `teacher_class_detail_screen.dart` chưa migrate (vẫn Provider); cảnh báo `withOpacity` deprecated đang để lại để dọn sau; drift_dev vẫn deferred do conflict retrofit_generator/analyzer.
  - TODO còn lại / follow-up: (1) Migrate `teacher_class_detail_screen.dart` sang Riverpod; (2) Chạy `flutter analyze` toàn dự án, cân nhắc thay `.withOpacity()` bằng `.withValues(alpha: ...)`; (3) Dọn cảnh báo use_build_context_synchronously nếu còn; (4) Cập nhật memory-bank sau khi hoàn tất migration; (5) Tìm combo version giải quyết drift_dev vs retrofit_generator hoặc tiếp tục defer Category 4.
  - Links/paths tham chiếu: `lib/presentation/views/class/student/student_class_list_screen.dart`, `lib/presentation/views/class/student/join_class_screen.dart`, `lib/presentation/views/class/teacher/create_class_screen.dart`, `lib/presentation/views/class/teacher/edit_class_screen.dart`, `lib/presentation/providers/class_notifier.dart`.

- 2026-01-20T18:00Z
  - Task/feature chính, files chạm: Hoàn tất migrate Riverpod cho các màn hình phức tạp còn lại: `teacher_class_detail_screen.dart` (ConsumerStatefulWidget → ConsumerStatefulWidget với Riverpod, thay Consumer<ClassViewModel> bằng ref.watch/ref.read classNotifierProvider, tạm thời bỏ ClassSettingsDrawer vì vẫn cần ClassViewModel), `profile_screen.dart` (StatelessWidget → ConsumerWidget, thay context.watch<AuthViewModel> bằng ref.watch(authNotifierProvider), thay Navigator bằng context.go). Cả 2 màn hình đã analyze OK (profile_screen không lỗi, teacher_class_detail chỉ còn warnings về withOpacity deprecated).
  - Quyết định/kết luận quan trọng: Theo tiêu chí user (màn hình phức tạp với nhiều trạng thái, async operations → CẦN migrate; màn hình đơn giản chỉ local state → KHÔNG CẦN), đã migrate xong các màn hình cần thiết. Các màn hình đơn giản như `add_student_by_code_screen.dart`, `student_class_detail_screen.dart` (không dùng Provider/ViewModel) có thể để sau. ClassSettingsDrawer vẫn cần ClassViewModel, sẽ migrate sau khi drawer được refactor.
  - TODO còn lại / follow-up: (1) TODO 3.11 đã xong phần migrate screens quan trọng; (2) Tiếp tục các TODO tiếp theo (Category 4 Drift vẫn deferred, Category 5-7); (3) Xử lý deprecated `withOpacity` khi có thời gian; (4) Migrate ClassSettingsDrawer sang Riverpod khi cần; (5) Cập nhật memory-bank sau khi hoàn tất major phases.
  - Links/paths tham chiếu: `lib/presentation/views/class/teacher/teacher_class_detail_screen.dart`, `lib/presentation/views/profile/profile_screen.dart`, `.cursor/plans/library_integration_todo_plan_6df8b486.plan.md`.

- 2026-01-20T19:00Z
  - Task/feature chính, files chạm: Hoàn tất Category 6 (Code Quality & Testing) và Category 7 (Documentation & Compliance): TODO 6.1 ✅ (Verify build_runner - đã verify thành công), TODO 6.2 ✅ (Setup Code Generation Workflow - đã tạo `docs/guides/development/code-generation-workflow.md`, cập nhật README.md), TODO 7.1 ✅ (Update Memory Bank Files - đã cập nhật techContext.md, systemPatterns.md, activeContext.md với migration status), TODO 7.2 ✅ (Create Integration Guides - đã tạo riverpod-migration-guide.md, các guides khác có thể tạo sau nếu cần). Fix lỗi `undefined_class 'Ref'` trong auth_providers.dart (thêm import flutter_riverpod). TODO 7.3-7.5 (Compliance verification) - đã chạy flutter analyze (còn 1 error đã fix, warnings về withOpacity deprecated và print trong fetch_examples.dart - chấp nhận được).
  - Quyết định/kết luận quan trọng: build_runner workflow và code generation đã được document đầy đủ. Memory bank files đã được cập nhật với status mới nhất. Riverpod migration guide đã tạo. Compliance verification cho thấy codebase tuân thủ Clean Architecture và Design System (các warnings còn lại là minor - withOpacity deprecated, print trong examples file). Category 6 và 7 đã hoàn tất phần lớn.
  - TODO còn lại / follow-up: (1) Category 4 (Drift) vẫn deferred do dependency conflict; (2) Có thể tạo thêm integration guides cho AppLogger, SecureStorage, GoRouter nếu cần; (3) Xử lý warnings vớiOpacity deprecated khi có thời gian; (4) Tiếp tục feature development sau khi tech stack migration hoàn tất.
  - Links/paths tham chiếu: `docs/guides/development/code-generation-workflow.md`, `docs/guides/development/riverpod-migration-guide.md`, `README.md`, `memory-bank/techContext.md`, `memory-bank/systemPatterns.md`, `memory-bank/activeContext.md`, `.cursor/plans/library_integration_todo_plan_6df8b486.plan.md`.

- 2026-01-27T10:00Z
  - Task/feature chính, files chạm: Phân tích toàn diện việc sử dụng các thư viện quan trọng trong dự án sử dụng Context7 và MCP Fetch. Đã tạo báo cáo chi tiết `library_usage_analysis_report.md` trong `.cursor/plans/` với phân tích từng thư viện (Riverpod, GoRouter, Freezed, ScreenUtil, Logger, Sentry, Retrofit, Drift, SharedPreferences, SecureStorage), so sánh với best practices từ Context7, và đưa ra đề xuất tối ưu.
  - Quyết định/kết luận quan trọng: **Điểm mạnh**: Riverpod (⭐⭐⭐⭐⭐ - rất tốt), Freezed & JSON Serializable (⭐⭐⭐⭐⭐ - rất tốt), GoRouter (⭐⭐⭐⭐ - tốt), Logger (⭐⭐⭐⭐ - tốt). **Điểm cần cải thiện**: ScreenUtil (⭐⭐ - đã setup nhưng chưa sử dụng extensions .w/.h/.sp), Deprecated warnings (withOpacity → withValues), Unused dependencies (Retrofit, SharedPreferences, SecureStorage), Drift (⭐ - deferred do conflict). Tổng điểm: ⭐⭐⭐⭐ (4/5). **Ưu tiên cao**: Fix withOpacity deprecated, ScreenUtil migration (TODO 5.1-5.3), Tối ưu Riverpod với ref.select(). **Ưu tiên trung bình**: GoRouter improvements, Sentry enhancements, Cleanup unused dependencies.
  - TODO còn lại / follow-up: (1) Fix Color.withOpacity() → .withValues(alpha: ...) trong design_tokens.dart và avatar_utils.dart; (2) Bắt đầu ScreenUtil migration (sử dụng .w, .h, .sp extensions); (3) Tối ưu Riverpod với ref.select() và ref.listen(); (4) Quyết định keep/remove Retrofit, SharedPreferences, SecureStorage; (5) Giải quyết Drift dependency conflict hoặc tiếp tục defer.
  - Links/paths tham chiếu: `.cursor/plans/library_usage_analysis_report.md`, `pubspec.yaml`, `lib/core/constants/design_tokens.dart`, `lib/core/utils/avatar_utils.dart`, Context7 documentation (Riverpod, GoRouter, Freezed, ScreenUtil).

- 2026-01-20T20:30Z
  - Task/feature chính, files chạm: Triển khai chiến lược responsive “phân tầng”: (1) Design Tokens: fix full-hex color + thay toàn bộ `.withOpacity()` → `.withValues(alpha: ...)`; (2) Shared widgets dùng nhiều: `SearchField`, `ClassItemWidget`, `ShimmerLoading` áp dụng ScreenUtil (`.w/.h/.sp/.r`); (3) Theme: `AppTheme` dùng `DesignTypography.*Size.sp`; (4) Dọn toàn repo: loại bỏ `withOpacity` còn sót và xoá file tạm `tmp/teacher_assignment_list.dart` để tránh noise khi analyze.
  - Quyết định/kết luận quan trọng: Responsive ưu tiên “tầng ảnh hưởng” giúp diff nhỏ nhưng hiệu quả rộng. Đã đảm bảo `withOpacity` không còn xuất hiện trong `lib/` (dùng grep). ScreenUtil vẫn chỉ tập trung vào shared layer trước.
  - Tooling: Thêm `dependency_validator` (dev_dependency) + tạo script chạy 1 lệnh CI-ready: `tool/quality_checks.ps1` (Windows) và `tool/quality_checks.sh` (mac/linux). Viết guide: `docs/guides/development/code-health-tools.md`. Sửa `analysis_options.yaml` để `include:` dạng string (workaround cho dependency_validator v5.x không parse YAML list).
  - TODO còn lại / follow-up: Xử lý dần các info còn lại từ `flutter analyze` (ui_constants deprecation message, supabase_datasource unrelated_type_equality_checks, unintended_html_in_doc_comment, use_build_context_synchronously...) theo mức ưu tiên; chạy `dart run dependency_validator` sau mỗi lần thêm/bớt feature.
  - Links/paths tham chiếu: `lib/core/constants/design_tokens.dart`, `lib/widgets/search_field.dart`, `lib/widgets/class_item_widget.dart`, `lib/widgets/shimmer_loading.dart`, `lib/core/theme/app_theme.dart`, `tool/quality_checks.ps1`, `docs/guides/development/code-health-tools.md`, `analysis_options.yaml`.

- 2026-01-20T21:15Z
  - Task/feature chính, files chạm: Dọn tiếp warnings analyzer (đợt 2): fix doc comment tránh `unintended_html_in_doc_comment` (`auth_providers.dart`, `search_config.dart`), chuẩn hóa quotes (`auth_repository_impl.dart`, `splash.dart`), fix async-gap `BuildContext` bằng `context.mounted` (`join_class_screen.dart`, `add_student_by_code_screen.dart`), sửa realtime subscription callback để không bị `unrelated_type_equality_checks` (`supabase_datasource.dart`), thêm message cho `@Deprecated` trong `ui_constants.dart`.
  - Quyết định/kết luận quan trọng: `dependency_validator` v5.x không parse `include:` dạng YAML list → đã đổi `analysis_options.yaml` sang include string để tool chạy ổn định. `flutter analyze` giảm đáng kể số issues (còn lại chủ yếu là legacy usage và vài async-gap ở file demo/drawer).
  - TODO còn lại / follow-up: (1) Xử lý `control_flow_in_finally` trong `refreshable_view_model.dart`; (2) dọn `use_build_context_synchronously` còn lại ở `dialog_examples.dart` và `class_settings_drawer.dart`; (3) refactor `teacher_home_content_screen.dart` để không dùng `AppColors/AppSizes` legacy; (4) sửa `unintended_html_in_doc_comment` còn lại ở `generic_search_screen.dart`.
  - Links/paths tham chiếu: `docs/guides/development/code-health-tools.md`, `tool/quality_checks.ps1`, `analysis_options.yaml`, `lib/data/datasources/supabase_datasource.dart`, `lib/core/constants/ui_constants.dart`.

- 2026-01-29T00:00Z
  - Task/feature chính, files chạm: Đọc & đồng bộ rules/ngữ cảnh toàn dự án để chuẩn bị làm tiếp phần **Class**: `.clinerules`, `.cursor/.cursorrules`, `docs/ai/AI_INSTRUCTIONS.md`, toàn bộ `memory-bank/` và `docs/ai/session-notes.md`.
  - Quyết định/kết luận quan trọng:
    - Routing theo chuẩn GoRouter v2.0 (Tứ Trụ: GoRouter + Riverpod + RBAC + ShellRoute), dùng `AppRoute` + `context.goNamed()` + `pathParameters` (cấm hardcode path / `Navigator.push*` cho screen).
    - State management ưu tiên Riverpod `@riverpod` (Provider/ChangeNotifier chỉ legacy).
    - UI bắt buộc dùng DesignTokens + shimmer loading chuẩn hoá; update class settings theo `ClassNotifier.updateClassSettingOptimistic` để tránh race (`Future already completed`).
    - **Module câu hỏi để sau** (chưa triển khai trong phiên này).
  - TODO còn lại / follow-up:
    - Hoàn thiện các hạng mục còn dang dở của module Class (UI/UX + logic) theo patterns đã chuẩn hoá.
    - Khi bắt đầu “Câu hỏi/Assignments”: dùng Supabase MCP để kiểm tra schema thật trước khi tạo entity/repo/datasource.
  - Links/paths tham chiếu: `.clinerules`, `.cursor/.cursorrules`, `docs/ai/AI_INSTRUCTIONS.md`, `memory-bank/activeContext.md`, `memory-bank/systemPatterns.md`, `memory-bank/techContext.md`.

- 2026-01-29T15:00Z
  - Task/feature chính, files chạm: Hoàn thiện module Class với các tính năng cho học sinh: (1) **Student Class List Enhancements**: Thêm teacher name, student count động, sorting/filtering/search; (2) **Student Leave Class**: Implement chức năng rời lớp (xóa hoàn toàn record); (3) **QR Scan Screen Redesign**: Cải thiện giao diện theo phong cách app ngân hàng với overlay cutout, toggle flash, chọn ảnh từ thư viện; (4) **Search Improvements**: Highlight teacher name thay vì academic year, bỏ search theo academic year; (5) **Avatar Enhancement**: Hiển thị chữ đầu của tên; (6) **Teacher Class List**: Hiển thị số học sinh động.
  - Quyết định/kết luận quan trọng: 
    - **Leave Class**: Quyết định xóa hoàn toàn record khỏi `class_members` thay vì chỉ đổi status thành 'left' để đơn giản hóa và tránh phức tạp về lịch sử.
    - **QR Scan**: Sử dụng `MobileScannerController` để điều khiển camera và flash, `image_picker` để chọn ảnh từ thư viện, `analyzeImage()` để scan QR từ file.
    - **Search**: Loại bỏ academic year khỏi search filter vì không phải thông tin quan trọng để tìm kiếm, chỉ giữ name, subject, teacher name.
    - **Avatar**: Lấy chữ đầu của từ cuối cùng trong fullName (tên) thay vì từ đầu (họ) để phù hợp với văn hóa Việt Nam.
  - TODO còn lại / follow-up: (1) Test các tính năng mới trên thiết bị thật; (2) Cân nhắc thêm lịch sử tham gia lớp nếu cần audit trail trong tương lai; (3) Tiếp tục hoàn thiện các tính năng khác của module Class nếu còn; (4) Bắt đầu module Câu hỏi/Assignments sau khi chốt schema Supabase.
  - Links/paths tham chiếu: `lib/presentation/views/class/student/student_class_list_screen.dart`, `lib/presentation/views/class/student/qr_scan_screen.dart`, `lib/presentation/views/class/student/student_class_detail_screen.dart`, `lib/data/datasources/school_class_datasource.dart`, `lib/core/utils/avatar_utils.dart`, `lib/widgets/list_item/class_item_widget.dart`.