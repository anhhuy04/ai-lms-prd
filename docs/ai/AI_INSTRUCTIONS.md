# HƯỚNG DẪN MẶC ĐỊNH CHO AI

Đây là các quy tắc và hướng dẫn mặc định cho AI khi làm việc với dự án Flutter "AI LMS".

**Version:** 2.0  
**Last Updated:** 2026-01-30  
**Status:** Cập nhật với Riverpod migration, GoRouter v2.0, ErrorTranslationUtils, và cấu trúc mới nhất

---

## ĐỀ BÀI
Tôi đang phát triển một hệ thống học tập thông minh trên nền tảng di động.

Mục tiêu:
- Số hóa quy trình giao bài – làm bài – chấm điểm
- Ứng dụng AI để hỗ trợ chấm điểm, phản hồi và phân tích học tập

Đối tượng sử dụng:
1. Giáo viên
2. Học sinh

Luồng chính:
Giáo viên tạo bài → giao bài → học sinh làm bài → nộp bài → AI chấm → giáo viên duyệt → phân tích & đề xuất

Yêu cầu chức năng chi tiết:

[CHƯƠNG 1] Tạo và giao bài tập
- Builder hỗ trợ nhiều loại câu hỏi
- Rich text, hình ảnh, video, LaTeX
- Rubric chấm điểm
- Xem trước bài
- Phân phối linh hoạt theo lớp / nhóm / cá nhân

[CHƯƠNG 2] Làm bài & nộp bài
- Workspace cho học sinh
- Auto-save
- Upload file
- Theo dõi tiến độ
- Nộp bài có xác nhận

[CHƯƠNG 3] Chấm điểm bằng AI
- Chấm tự động câu hỏi khách quan
- Hỗ trợ chấm tự luận
- Feedback chi tiết
- Confidence score
- Giáo viên override

[CHƯƠNG 4] Phân tích học tập
- Theo dõi mastery theo mục tiêu
- Phát hiện lỗi lặp lại
- Dashboard cá nhân học sinh

[CHƯƠNG 5] Đề xuất cá nhân hóa
- Gợi ý can thiệp cho giáo viên
- Đề xuất học theo nhóm
- Gợi ý tài nguyên học tập

Hãy xử lý yêu cầu theo hướng kỹ thuật, có cấu trúc rõ ràng.

## CSDL

create extension if not exists "pgcrypto";
create extension if not exists "pg_net";
create extension if not exists "uuid-ossp";

-- Profiles table
create table if not exists public.profiles (
id uuid primary key references auth.users not null,
full_name text,
role text check (role in ('teacher', 'student', 'admin')) default 'student',
avatar_url text,
bio text,
metadata jsonb,
updated_at timestamptz default now()
);

create or replace function public.handle_new_user()
returns trigger as $$
begin
insert into public.profiles (id, full_name, role)
values (new.id, new.raw_user_meta_data->>'full_name', coalesce(new.raw_user_meta_data->>'role', 'student'))
on conflict (id) do nothing;
return new;
end;
$$ language plpgsql security definer;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.handle_new_user();

---

## 1. Cấu trúc thư mục bắt buộc

Mọi file được tạo hoặc chỉnh sửa PHẢI tuân thủ nghiêm ngặt cấu trúc thư mục theo Clean Architecture dưới đây:

```
project_root/
├── android/                   # Thư mục cho phần Android của ứng dụng Flutter (tự động tạo)
├── ios/                       # Thư mục cho phần iOS của ứng dụng Flutter (tự động tạo)
├── web/                       # Thư mục cho phần web nếu hỗ trợ (tùy chọn)
├── test/                      # Thư mục chứa các file test (unit test, widget test)
│   └── ...                    # Các file test cụ thể, ví dụ: authentication_test.dart - Để test các chức năng liên quan đến xác thực người dùng
├── pubspec.yaml               # File cấu hình dự án: khai báo dependencies như flutter, supabase_flutter, provider (cho MVVM), intl (cho ngày tháng), etc.
├── analysis_options.yaml      # File cấu hình lint rules cho code chất lượng
├── README.md                  # Tài liệu hướng dẫn dự án
└── lib/                       # Thư mục chính chứa source code Flutter
    ├── main.dart              # File entry point: Khởi tạo ứng dụng, setup Supabase client, provider cho dependency injection, và chạy app với MaterialApp hoặc CupertinoApp. Bao gồm route initial dựa trên auth state.
    ├── app.dart               # File định nghĩa App widget: Quản lý theme, localization, và router (sử dụng GoRouter hoặc Navigator). Kết nối với ViewModel để kiểm tra trạng thái auth.
    ├── routes/                # Thư mục chứa các route và navigation config (GoRouter v2.0)
    │   ├── route_constants.dart # File định nghĩa TẤT CẢ route names, paths, helpers (Single Source of Truth).
    │   ├── app_router.dart    # File GoRouter configuration: ShellRoute, RBAC redirect, deep linking.
    │   └── route_guards.dart  # File guard utilities: Auth/role check functions cho RBAC.
    ├── core/                  # Thư mục chứa các phần cốt lõi, chung cho toàn app
    │   ├── constants/         # Thư mục chứa hằng số
    │   │   ├── api_constants.dart # File chứa các hằng: URL Supabase, anon key, role enums ('teacher', 'student', 'admin').
    │   │   └── ui_constants.dart  # File chứa các hằng UI: colors, sizes, strings chung như error messages.
    │   ├── utils/             # Thư mục chứa các hàm tiện ích
    │   │   ├── app_logger.dart    # File util: Centralized logging service với các cấp độ (debug, info, warning, error, fatal).
    │   │   ├── date_utils.dart    # File util: Hàm xử lý ngày tháng, format timestamp từ Supabase.
    │   │   ├── network_utils.dart # File util: Kiểm tra kết nối mạng, handle errors từ Supabase queries.
    │   │   ├── validators.dart    # File util: Hàm validate input như email, password, full_name.
    │   │   ├── error_translation_utils.dart # File util: Translate error messages sang tiếng Việt, tái sử dụng cho tất cả repositories. BẮT BUỘC sử dụng trong repositories.
    │   │   ├── optimistic_update_utils.dart # File util: Optimistic update pattern cho UI updates không blocking.
    │   │   ├── filtering_utils.dart # File util: Filtering logic cho lists và search.
    │   │   ├── sorting_utils.dart # File util: Sorting logic cho lists.
    │   │   ├── refresh_utils.dart # File util: Refresh patterns cho Riverpod providers.
    │   │   ├── responsive_utils.dart # File util: Responsive design helpers.
    │   │   ├── qr_helper.dart # File util: QR code generation và processing.
    │   │   ├── avatar_utils.dart # File util: Avatar generation và processing.
    │   │   ├── vietnamese_text_utils.dart # File util: Vietnamese text processing.
    │   │   └── extensions.dart    # File extension: Mở rộng các class như String, DateTime cho tiện dùng.
    │   └── services/          # Thư mục chứa các service inject qua provider
    │       ├── supabase_service.dart # File service: Khởi tạo và quản lý Supabase client, auth, realtime subscriptions (ví dụ: listen changes trên tables như assignments).
    │       ├── notification_service.dart # File service: Xử lý push notifications (sử dụng Firebase nếu cần) cho thông báo bài tập mới.
    │       ├── storage_service.dart # File service: Upload/download files đến Supabase Storage (cho images, PDFs trong questions/files).
    │       └── ai_service.dart    # File service: Gọi API AI (nếu tích hợp external AI như OpenAI) cho grading, feedback, recommendations.
    ├── data/                  # Thư mục chứa data layer (liên quan đến Supabase)
    │   ├── datasources/       # Thư mục chứa nguồn dữ liệu cụ thể
    │   │   ├── supabase_datasource.dart # File datasource: BaseTableDataSource - Generic CRUD operations cho Supabase tables.
    │   │   ├── school_class_datasource.dart # File datasource: Queries cho classes, class_members, groups, group_members.
    │   │   ├── question_bank_datasource.dart # File datasource: Queries cho questions, question_choices, question_objectives.
    │   │   ├── assignment_datasource.dart # File datasource: Queries cho assignments, assignment_questions, assignment_variants, assignment_distributions.
    │   │   └── learning_objective_datasource.dart # File datasource: Queries cho learning_objectives.
    │   └── repositories/      # Thư mục chứa implement repository
    │       ├── auth_repository_impl.dart # File repo: Implement auth functions như signUp, signIn, getUserRole từ Supabase Auth. BẮT BUỘC sử dụng ErrorTranslationUtils.
    │       ├── school_class_repository_impl.dart # File repo: Xử lý schools, classes, class_members, class_teachers: createClass, joinClass, etc. BẮT BUỘC sử dụng ErrorTranslationUtils.
    │       ├── question_repository_impl.dart # File repo: Xử lý questions, question_choices: createQuestion, getQuestionsByAuthor, etc. BẮT BUỘC sử dụng ErrorTranslationUtils.
    │       ├── learning_objective_repository_impl.dart # File repo: Xử lý learning_objectives, question_objectives. BẮT BUỘC sử dụng ErrorTranslationUtils.
    │       └── assignment_repository_impl.dart # File repo: Xử lý assignments, assignment_questions, assignment_variants, assignment_distributions: createAssignment, publishAssignment. BẮT BUỘC sử dụng ErrorTranslationUtils.
    ├── domain/                # Thư mục chứa domain layer (abstract, entities)
    │   ├── entities/          # Thư mục chứa các entity model (tương ứng tables SQL)
    │   │   ├── profile.dart   # Entity: Model cho profiles table: id, full_name, role, avatar_url, etc.
    │   │   ├── school.dart    # Entity: Model cho schools table.
    │   │   ├── class.dart     # Entity: Model cho classes, class_members, class_teachers.
    │   │   ├── group.dart     # Entity: Model cho groups, group_members.
    │   │   ├── learning_objective.dart # Entity: Model cho learning_objectives, question_objectives.
    │   │   ├── question.dart  # Entity: Model cho questions, question_choices.
    │   │   ├── file.dart      # Entity: Model cho files, file_links.
    │   │   ├── assignment.dart # Entity: Model cho assignments, assignment_questions, assignment_variants, assignment_distributions.
    │   │   ├── work_session.dart # Entity: Model cho work_sessions, autosave_answers.
    │   │   ├── submission.dart # Entity: Model cho submission_answers, submissions.
    │   │   ├── ai_evaluation.dart # Entity: Model cho ai_queue, ai_evaluations, grade_overrides.
    │   │   ├── student_skill.dart # Entity: Model cho student_skill_mastery, question_stats, submission_analytics.
    │   │   └── recommendation.dart # Entity: Model cho ai_recommendations, teacher_notes.
    │   ├── repositories/      # Thư mục chứa abstract repository
    │   │   ├── auth_repository.dart # Abstract: Interface cho auth functions.
    │   │   ├── profile_repository.dart # Abstract: Interface cho profile operations.
    │   │   └── ...            # Tương tự cho các repo khác (school_class_repository, etc.).
    │   └── usecases/          # Thư mục chứa usecases (business logic abstract)
    │       ├── create_assignment_usecase.dart # Usecase: Logic tạo assignment, gọi repo để lưu vào DB.
    │       ├── submit_answer_usecase.dart # Usecase: Logic nộp bài, auto-save, kiểm tra due date.
    │       ├── grade_submission_usecase.dart # Usecase: Logic chấm điểm AI, override.
    │       ├── get_recommendations_usecase.dart # Usecase: Logic lấy recommendations dựa trên analytics.
    │       └── ...            # Các usecase khác tương ứng chức năng (tạo class, join group, etc.).
    ├── presentation/          # Thư mục chứa presentation layer (MVVM: Views và ViewModels)
    │   ├── views/             # Thư mục chứa các screen/widget UI (Views)
    │   │   ├── splash/        # Thư mục con cho splash screen
    │   │   │   └── splash_screen.dart # View: Splash screen với auth check và routing.
    │   │   ├── auth/          # Thư mục con cho auth screens
    │   │   │   ├── login_screen.dart # View: Màn hình login với form, button sign in/up, liên kết Supabase Auth. Sử dụng AuthNotifier.
    │   │   │   └── register_screen.dart # View: Màn hình đăng ký, chọn role (teacher/student), trigger handle_new_user. Sử dụng AuthNotifier.
    │   │   ├── dashboard/     # Thư mục con cho dashboard
    │   │   │   ├── student_dashboard_screen.dart # View: Dashboard học sinh với ShellRoute, bottom nav. Sử dụng StudentDashboardNotifier.
    │   │   │   ├── teacher_dashboard_screen.dart # View: Dashboard giáo viên với ShellRoute, bottom nav. Sử dụng TeacherDashboardNotifier.
    │   │   │   ├── admin_dashboard_screen.dart # View: Dashboard admin.
    │   │   │   └── home/      # Thư mục con cho home content
    │   │   │       ├── student_home_content_screen.dart # View: Nội dung home của học sinh.
    │   │   │       └── teacher_home_content_screen.dart # View: Nội dung home của giáo viên.
    │   │   ├── class/        # Thư mục con cho class management
    │   │   │   ├── student/   # Thư mục con cho student class screens
    │   │   │   │   ├── student_class_list_screen.dart # View: Danh sách lớp học của học sinh. Sử dụng ClassNotifier.
    │   │   │   │   ├── student_class_detail_screen.dart # View: Chi tiết lớp học cho học sinh.
    │   │   │   │   ├── join_class_screen.dart # View: Tham gia lớp học bằng mã.
    │   │   │   │   ├── qr_scan_screen.dart # View: Quét QR code để tham gia lớp.
    │   │   │   │   └── widgets/ # Widgets cho student class screens
    │   │   │   │       ├── search/ # Search screens
    │   │   │   │       └── drawers/ # Drawer components
    │   │   │   └── teacher/   # Thư mục con cho teacher class screens
    │   │   │       ├── teacher_class_list_screen.dart # View: Danh sách lớp học của giáo viên. Sử dụng ClassNotifier.
    │   │   │       ├── teacher_class_detail_screen.dart # View: Chi tiết lớp học cho giáo viên.
    │   │   │       ├── create_class_screen.dart # View: Tạo lớp học mới.
    │   │   │       ├── edit_class_screen.dart # View: Chỉnh sửa lớp học.
    │   │   │       ├── student_list_screen.dart # View: Danh sách học sinh trong lớp.
    │   │   │       ├── add_student_by_code_screen.dart # View: Thêm học sinh bằng mã QR.
    │   │   │       └── widgets/ # Widgets cho teacher class screens
    │   │   │           ├── search/ # Search screens
    │   │   │           └── drawers/ # Drawer components (class_settings_drawer, etc.)
    │   │   ├── assignment/    # Thư mục con cho assignment (Chương 1)
    │   │   │   ├── assignment_list_screen.dart # View: Danh sách assignments cho teacher/student.
    │   │   │   └── teacher/   # Thư mục con cho teacher assignment screens
    │   │   │       └── teacher_assignment_hub_screen.dart # View: Hub quản lý assignments của giáo viên.
    │   │   ├── grading/       # Thư mục con cho grading (Chương 3)
    │   │   │   └── scores_screen.dart # View: Màn hình điểm số.
    │   │   ├── profile/       # Thư mục con cho profile
    │   │   │   └── profile_screen.dart # View: Màn hình profile.
    │   │   └── network/       # Thư mục con cho network
    │   │       └── no_internet_screen.dart # View: Màn hình không có internet.
    │   ├── providers/         # Thư mục chứa Riverpod Providers và Notifiers (PRIMARY - Ưu tiên cho code mới)
    │   │   ├── auth_providers.dart # Providers: AuthNotifier, currentUserProvider, auth state providers.
    │   │   ├── class_providers.dart # Providers: ClassNotifier, class list providers với pagination/search.
    │   │   ├── question_bank_providers.dart # Providers: QuestionBankNotifier cho question bank management.
    │   │   ├── assignment_providers.dart # Providers: AssignmentBuilderNotifier, assignment list providers.
    │   │   ├── learning_objective_providers.dart # Providers: Learning objective providers.
    │   │   ├── student_dashboard_notifier.dart # Notifier: Student dashboard state và refresh logic.
    │   │   ├── teacher_dashboard_notifier.dart # Notifier: Teacher dashboard state và refresh logic.
    │   │   └── ...            # Các providers khác cho các features.
    │   └── viewmodels/        # Thư mục chứa ViewModels (LEGACY - Chỉ cho code cũ, không dùng cho code mới)
    │       ├── mixins/
    │       │   ├── refreshable_view_model.dart
    │       │   ├── realtime_listener.dart
    │       │   ├── loading_state_mixin.dart
    │       │   └── pagination_mixin.dart
    │       ├── auth_viewmodel.dart # VM (LEGACY): Quản lý auth state. Sử dụng AuthNotifier thay thế.
    │       ├── class_viewmodel.dart # VM (LEGACY): Quản lý classes. Sử dụng ClassNotifier thay thế.
    │       └── ...            # Các VM khác (LEGACY) - sẽ migrate dần sang Riverpod Notifiers.
    └── widgets/               # Thư mục chứa các widget reusable (SHARED - dùng chung cho cả teacher và student)
        ├── buttons/           # Button widgets (quick_action_button, etc.)
        ├── cards/             # Card widgets (base_card, statistics_card, etc.)
        ├── async/             # Widgets cho async operations
        ├── dialogs/           # Dialog widgets
        ├── drawers/           # Thư mục chứa hệ thống drawer (shared primitives)
        │   ├── action_end_drawer.dart        # Khung chung cho tất cả drawer bên phải
        │   ├── drawer_section_header.dart    # Header cho các section trong drawer
        │   ├── drawer_action_tile.dart       # Tile hành động với icon, tiêu đề, phụ đề
        │   └── drawer_toggle_tile.dart      # Tile với switch để bật/tắt tính năng
        ├── list/              # List widgets
        │   └── class_detail_assignment_list.dart # Widget: Container list bài tập trong class detail.
        ├── list_item/         # List item widgets (tổ chức theo feature)
        │   ├── class/         # Class-related list items
        │   │   ├── class_item_widget.dart    # Widget: Class item trong list với search highlighting.
        │   │   └── class_status_badge.dart   # Widget: Badge hiển thị trạng thái lớp học.
        │   └── assignment/    # Assignment-related list items
        │       └── class_detail_assignment_list_item.dart # Widget: Assignment item trong class detail (hỗ trợ teacher/student view mode).
        ├── loading/           # Loading indicators
        ├── navigation/        # Navigation widgets
        ├── responsive/       # Responsive widgets
        ├── search/            # Search widgets và screens
        │   ├── screens/       # Full-screen search screens
        │   ├── dialogs/       # Dialog-based search
        │   └── shared/        # Shared search components (search_field.dart)
        └── text/              # Text widgets
```

**Lưu ý:** Nếu bạn cần tạo thêm các thư mục và file mới không có trong cây trên thì hãy hỏi tôi xem có đồng ý cho bạn tạo thêm câu thư mục và file mới hay ko.

> **Xem thêm:** Chi tiết về Clean Architecture và MVVM patterns trong `memory-bank/systemPatterns.md` (Overall Architecture section)

---

## 2. Quy tắc kiến trúc (Clean Architecture)

### Nguyên tắc cốt lõi:
- **Tầng Presentation:** Sử dụng mô hình **MVVM (View - ViewModel)**.
- **Tầng Data:** Sử dụng **Repository Pattern** để tương tác với Supabase.
- **Luồng phụ thuộc:** **Presentation -> Domain -> Data**. Không bao giờ được vi phạm luồng này (ví dụ: View không được gọi trực tiếp Repository, ViewModel không được gọi trực tiếp DataSource).

> **Xem thêm:** Chi tiết về Clean Architecture, MVVM patterns, dependency flow, và component relationships trong `memory-bank/systemPatterns.md` (Overall Architecture section)

---

## 3. Quy tắc đặt tên

- **Screens/Views:** Kết thúc bằng `_screen.dart` (ví dụ: `login_screen.dart`).
- **Entities:** Nằm trong `domain/entities/` và có tên phản ánh bảng trong CSDL (ví dụ: `profile.dart`).
- **ViewModels (LEGACY):** Nằm trong `presentation/viewmodels/` và kết thúc bằng `_viewmodel.dart` (ví dụ: `auth_viewmodel.dart`). KHÔNG dùng cho code mới.
- **Notifiers (Riverpod):** Nằm trong `presentation/providers/` và kết thúc bằng `_notifier.dart` (ví dụ: `auth_notifier.dart`). Ưu tiên cho code mới.
- **Providers (Riverpod):** Nằm trong `presentation/providers/` và kết thúc bằng `_providers.dart` (ví dụ: `auth_providers.dart`).
- **DataSources:** Kết thúc bằng `_datasource.dart` (ví dụ: `school_class_datasource.dart`).
- **Repositories:** Kết thúc bằng `_repository_impl.dart` (ví dụ: `school_class_repository_impl.dart`).
- **Utils:** Kết thúc bằng `_utils.dart` (ví dụ: `error_translation_utils.dart`).

> **Xem thêm:** Chi tiết về naming conventions trong `memory-bank/systemPatterns.md` (Code Organization Patterns section)

---

## 4. Quản lý Trạng thái (State Management)

### Riverpod (Primary - Ưu tiên cho code mới)
- **Riverpod** (v2.5.1) là giải pháp state management chính, sử dụng code generation với `@riverpod` annotation.
- **Pattern:** Sử dụng `AsyncNotifier` cho async state, `Notifier` cho sync state.
- **UI Integration:**
  - Views sử dụng `ConsumerWidget` hoặc `ConsumerStatefulWidget`
  - Sử dụng `ref.watch()` cho reactive state (tự động rebuild khi state thay đổi)
  - Sử dụng `ref.read()` cho one-time access (trong callbacks, không rebuild)
- **Providers:** Được định nghĩa trong `lib/presentation/providers/` với pattern:
  ```dart
  @riverpod
  class ClassNotifier extends _$ClassNotifier {
    @override
    FutureOr<List<Class>> build() async {
      return <Class>[];
    }
    // Methods...
  }
  ```
- **Dashboard Refresh Pattern (QUAN TRỌNG):**
  - Refresh methods CHỈ refresh data providers, KHÔNG touch auth state
  - KHÔNG gọi `checkCurrentUser()` trong refresh để tránh reset auth state
  - KHÔNG set state về `loading` trong refresh để tránh router redirect

### Provider (Legacy - Chỉ cho code cũ)
- **Provider** (v6.0.0) chỉ còn dùng cho một số screens/widgets cũ chưa migrate.
- **ViewModels** (`ChangeNotifier`) cũ vẫn tồn tại để tương thích ngược, nhưng KHÔNG dùng cho code mới.

> **Xem thêm:** Chi tiết về State Management Pattern và Riverpod usage trong `memory-bank/systemPatterns.md` (State Management Pattern section) và `memory-bank/techContext.md` (State Management section)

---

## 5. Điều hướng (Routing & Navigation) - GoRouter v2.0

### Architecture: Tứ Trụ (Four Pillars)
1. **GoRouter** - Navigation framework (v14.0.0+)
2. **Riverpod** - State management (auth, role checks)
3. **RBAC** - 3-step redirect logic (public → auth → role)
4. **ShellRoute** - Preserve bottom nav during navigation

### Core Files
- **`lib/core/routes/route_constants.dart`** - Single Source of Truth cho TẤT CẢ routes:
  - Route names (static constants)
  - Route paths (static helpers như `AppRoute.teacherEditClassPath(classId)`)
  - RBAC helpers (`canAccessRoute()`, `getDashboardPathForRole()`)
- **`lib/core/routes/app_router.dart`** - GoRouter configuration:
  - ShellRoute cho Student/Teacher/Admin dashboards
  - RBAC redirect logic tích hợp
  - Deep linking support
- **`lib/core/routes/route_guards.dart`** - Auth/role utility functions

### Navigation Patterns
- **UI Navigation:** Sử dụng `context.goNamed()` với route constants:
  ```dart
  context.goNamed(
    AppRoute.teacherEditClass,
    pathParameters: {'classId': classId},
  );
  ```
- **Logic Navigation:** Sử dụng `ref.read(routerProvider).goNamed(...)`
- **KHÔNG sử dụng:** `Navigator.push()`, hardcoded paths như `'/home'`

### RBAC (Role-Based Access Control)
- **Automatic Redirect Logic:**
  1. Public routes → Allow (splash, login, register, deep links)
  2. Not authenticated → Redirect to `/login`
  3. Role mismatch → Redirect to role's dashboard
- **Route Protection:** Tự động kiểm tra qua `route_guards.dart`

### ShellRoute Pattern
- **Student Shell:** `/student-dashboard` preserves bottom nav
- **Teacher Shell:** `/teacher-dashboard` preserves bottom nav
- **Admin Shell:** `/admin-dashboard` preserves bottom nav

> **Xem thêm:** Chi tiết về Router Architecture v2.0 trong `memory-bank/systemPatterns.md` (Router Architecture section) và `memory-bank/techContext.md` (Routing & Navigation section)

---

## 6. Xử lý Lỗi (Error Handling)

- Các lỗi cần hiển thị cho người dùng (ví dụ: "Sai mật khẩu") phải được quản lý qua `errorMessage` trong ViewModel và hiển thị bằng `ScaffoldMessenger.of(context).showSnackBar(...)` ở View.
- Các lỗi trong tầng `Data` hoặc `Domain` nên được bắt và ném lại (re-throw) dưới dạng các Exception đã được định nghĩa, thay vì trả về `null` một cách chung chung.
- **Error Translation:** Tất cả repositories PHẢI sử dụng `ErrorTranslationUtils.translateError()` để translate lỗi sang tiếng Việt. KHÔNG được tự implement `_translateError()` method riêng.
- **Logging:** Sử dụng `AppLogger` thống nhất cho tất cả logging. KHÔNG được tạo custom logging functions như `_agentLog()`.

> **Xem thêm:** Chi tiết về Error Handling Pattern và error flow trong `memory-bank/systemPatterns.md` (Error Handling Pattern section)

---

## 7. Tương tác với Supabase

- Mọi lệnh gọi trực tiếp đến Supabase (ví dụ: `SupabaseService.client.auth.signUp`) **CHỈ** được phép tồn tại trong tầng **Data** (cụ thể là các tệp `_datasource.dart`).
- ViewModel và tầng Presentation không bao giờ được phép biết đến sự tồn tại của `SupabaseService` hay `Supabase.instance.client`.

> **Xem thêm:** Chi tiết về Supabase integration và constraints trong `memory-bank/systemPatterns.md` (Key Technical Decisions section) và `memory-bank/techContext.md` (Supabase Database Schema section)

---

## 8. Ngôn ngữ và cảnh báo

- Các comment ghi chú viết bằng tiếng việt, do app hiện tại cho người việt nên các chức năng và các thông báo đều viết bằng tiếng việt có dấu.
- các tên hàm và tên biến viết bằng tiếng anh hãy ghi chú dịch lại chức năng và ý nghĩa của nó bằng tiếng việt.

> **Xem thêm:** Chi tiết về Vietnamese Language Handling trong `memory-bank/activeContext.md` (Important Notes & Learnings section)

---

## 9. Quy tắc sửa file

- Khi làm việc với dự án Flutter sửa 1 file nào đó thì sửa những chỗ cần sửa, những chỗ không cần sửa thì giữa nguyên, nếu muốn xóa để tối ưu thì phải hỏi ý kiến xem có được xóa hay ko. tránh tình trạng sửa cả file nhưng các chỗ ko cần sửa thì xóa mất.
- Khi tôi yêu cầu "Tạo chức năng X", hãy tự động liệt kê đúng đường dẫn file theo cấu trúc này trước khi viết mã.

---

## 10. UI/UX Rules & Widget Composition Pattern

### 10.1. UI/UX General Rules
- Use `SmartHighlightText` for all search results (Supports Vietnamese diacritics removal).
- Ensure all screens use `AutomaticKeepAliveClientMixin` where state preservation is needed.
- Keyboard MUST be dismissed on scroll: `keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag`.
- Use `AppRefreshIndicator` widget (from `lib/widgets/refresh/app_refresh_indicator.dart`) for consistent pull-to-refresh styling across the app.

### 10.2. Widget Composition Pattern (Assignment List)
**MANDATORY:** Khi tạo các màn hình list tương tự nhau (>70% code giống), PHẢI sử dụng Composition Pattern thay vì copy-paste code.

**Location:** `lib/presentation/views/assignment/teacher/widgets/assignment_list/`

**Core Components:**
- `AssignmentCard`: Reusable card widget để hiển thị một assignment
  - Nhận config từ bên ngoài (badge, action, metadata)
  - Không hardcode logic, chỉ render UI
- `AssignmentListView`: List view wrapper với pull-to-refresh
  - Compose AssignmentCard và EmptyState
  - Xử lý refresh logic
- `AssignmentEmptyState`: Empty state widget
  - Factory methods: `.draft()`, `.published()`
- `AssignmentErrorState`: Error state widget với retry
- `AssignmentCardConfig`: Config classes (Badge, Action, Metadata)
- `AssignmentDateFormatter`: Utility class format dates

**Design Principles:**
1. **Composition over Configuration**: Tách thành widget nhỏ, compose lại
2. **Single Responsibility**: Mỗi widget chỉ làm 1 việc
3. **Open/Closed**: Dễ mở rộng, không cần sửa code cũ
4. **Dependency Inversion**: Widget nhận config từ bên ngoài

**Usage Pattern:**
```dart
// Screen chỉ compose, không có logic UI phức tạp
AssignmentListView(
  assignments: filteredAssignments,
  badgeConfig: AssignmentBadgeConfig.draft,
  actionBuilder: (assignment) => AssignmentActionConfig(
    label: 'Chỉnh sửa',
    icon: Icons.edit_outlined,
    onPressed: () => navigateToEdit(assignment),
  ),
  metadataConfig: AssignmentMetadataConfig.draft,
  emptyState: AssignmentEmptyState.draft(),
  onRefresh: () => refresh(),
)
```

**Khi nào áp dụng:**
- ✅ Có 2+ màn hình list tương tự nhau (>70% code giống)
- ✅ Cần tái sử dụng UI components
- ✅ Muốn dễ maintain và mở rộng

**Khi nào KHÔNG áp dụng:**
- ❌ Chỉ có 1 màn hình duy nhất
- ❌ Các màn hình khác nhau hoàn toàn
- ❌ Over-engineering cho use case đơn giản

**Best Practices:**
- ✅ Sử dụng preset configs: `AssignmentBadgeConfig.draft`, `AssignmentMetadataConfig.published`
- ✅ Tách utility functions: `AssignmentDateFormatter`
- ✅ Factory methods cho empty states: `AssignmentEmptyState.draft()`
- ✅ Test từng widget nhỏ riêng biệt
- ❌ Không hardcode config trong widget
- ❌ Không copy-paste code, dùng lại widgets
- ❌ Không tạo config class quá phức tạp

**Xem chi tiết:** `docs/architecture/assignment_list_widgets_composition_pattern.md`

---

## 11. MCP Usage Patterns và Best Practices

### 11.1. Supabase MCP Server
**Khi nào sử dụng:**
- Kiểm tra schema database trước khi tạo model hoặc repository
- Query dữ liệu để hiển thị trực tiếp cho người dùng
- Apply migrations khi cần thay đổi schema
- Xem logs để debug issues
- Quản lý Edge Functions

**Best Practices:**
- Luôn sử dụng `list_tables` hoặc `execute_sql` để kiểm tra schema trước khi giả định cấu trúc bảng
- Sử dụng `get_advisors` để kiểm tra security và performance issues sau khi thay đổi schema
- Khi query dữ liệu, luôn kiểm tra RLS policies để đảm bảo quyền truy cập

**Ví dụ:**
```
Trước khi tạo ProfileRepository:
1. Sử dụng Supabase MCP để list_tables và kiểm tra cấu trúc bảng profiles
2. Kiểm tra các cột thực tế: id, full_name, role, avatar_url, etc.
3. Sau đó mới tạo entity và repository phù hợp
```

### 11.2. Fetch MCP Server
**Khi nào sử dụng:**
- Tìm documentation của thư viện mới được thêm vào pubspec.yaml
- Tìm examples và best practices từ web
- Fetch API documentation khi tích hợp service mới

**Best Practices:**
- Sử dụng khi người dùng thêm thư viện mới và cần hiểu cách sử dụng
- Fetch documentation trước khi implement để đảm bảo sử dụng đúng cách
- Lưu các patterns quan trọng vào memory bank hoặc documentation

**Ví dụ:**
```
Khi thêm flutter_riverpod vào pubspec.yaml:
1. Sử dụng Fetch MCP để fetch documentation từ pub.dev
2. Tìm examples về Provider và StateNotifier
3. Implement theo best practices từ documentation
```

### 10.3. Context7 MCP Server
**Khi nào sử dụng:**
- Tìm kiếm patterns trong codebase
- Tìm các file liên quan đến một feature cụ thể
- Hiểu context của một phần code

**Best Practices:**
- Sử dụng để tìm hiểu cách các features tương tự được implement
- Tìm các patterns đã được sử dụng trong dự án để đảm bảo consistency

### 10.4. GitHub MCP Server
**Khi nào sử dụng:**
- Khi người dùng yêu cầu tạo commit hoặc quản lý Git
- Xem branches và PRs khi cần
- Chỉ sử dụng khi được yêu cầu rõ ràng

**Best Practices:**
- Không tự động tạo commits trừ khi được yêu cầu
- Luôn tạo commit message rõ ràng và mô tả đầy đủ
- Kiểm tra code quality trước khi commit

### 10.5. Filesystem MCP Server
**Khi nào sử dụng:**
- Đọc nhiều files cùng lúc để hiểu context
- Tìm kiếm patterns trong codebase
- Navigate codebase khi cần truy cập nhiều files

**Best Practices:**
- Sử dụng khi cần đọc nhiều files liên quan để hiểu đầy đủ context
- Kết hợp với codebase_search để tìm các patterns

### 10.6. Memory Bank Files (NOT MCP Tool)
**Lưu ý quan trọng:**
- Memory Bank là các **FILE THỰC TẾ** trong folder `memory-bank/`, KHÔNG phải MCP tool
- Sử dụng `read_file` tool để đọc các file trong `memory-bank/`
- Sử dụng `write` hoặc `search_replace` tool để cập nhật các file

**Khi nào cập nhật Memory Bank files:**
- Sau khi hoàn thành code changes quan trọng
- Khi phát hiện patterns mới
- Khi có thay đổi về kiến trúc hoặc quyết định kỹ thuật
- Khi user yêu cầu "update memory bank"

**Best Practices:**
- Đọc TẤT CẢ files trong `memory-bank/` trước khi bắt đầu task
- Cập nhật `activeContext.md` và `progress.md` sau mỗi thay đổi quan trọng
- Sử dụng file tools (`read_file`, `write`, `search_replace`) - KHÔNG sử dụng MCP Memory tool

### 10.7. General MCP Best Practices
- **Luôn kiểm tra trước khi giả định**: Sử dụng MCP để kiểm tra thực tế thay vì giả định
- **Sử dụng đúng tool cho đúng mục đích**: Mỗi MCP server có mục đích riêng, sử dụng đúng tool
- **Kết hợp các MCP servers**: Có thể sử dụng nhiều MCP servers cùng lúc để có context đầy đủ
- **Document findings**: Khi tìm thấy patterns hoặc best practices quan trọng, lưu vào memory bank hoặc documentation

> **Xem thêm:** Chi tiết về MCP Setup và configuration trong `memory-bank/techContext.md` (MCP Setup section) và `.clinerules` (Database & MCP section). Lưu ý: Memory Bank là các file trong folder `memory-bank/`, không phải MCP tool - xem section "Memory Bank File Operations" trong `.clinerules` để biết cách đọc/ghi files.

---

# XEM THÊM

Để tìm hiểu thêm về các chủ đề cụ thể, tham khảo:

- **Clean Architecture & MVVM Patterns:** `memory-bank/systemPatterns.md` (Overall Architecture section)
- **State Management (Riverpod):** `memory-bank/systemPatterns.md` (State Management Pattern section) và `memory-bank/techContext.md` (State Management section)
- **Routing & Navigation (GoRouter v2.0):** `memory-bank/systemPatterns.md` (Router Architecture section) và `memory-bank/techContext.md` (Routing & Navigation section)
- **Error Handling:** `memory-bank/systemPatterns.md` (Error Handling Pattern section) - Sử dụng `ErrorTranslationUtils` cho tất cả repositories
- **Design System:** `memory-bank/systemPatterns.md` (Design System Specifications section) và `memory-bank/DESIGN_SYSTEM_GUIDE.md`
- **Code Conventions:** `.clinerules` (Code Quality section) và `memory-bank/activeContext.md` (Active Preferences & Standards section)
- **MCP Setup & Configuration:** `memory-bank/techContext.md` (MCP Setup section)
- **Technology Stack:** `memory-bank/techContext.md` - Chi tiết về tất cả dependencies và tools
- **Current Work Focus:** `memory-bank/activeContext.md` (Current Sprint Focus section)
- **Progress Tracking:** `memory-bank/progress.md` - Lịch sử các thay đổi và optimizations
- **Git Workflow:** `.clinerules` (Git Workflow section)
- **HTML → Dart Conversion:** `.clinerules` (HTML → Dart Conversion section)
- **Flutter Refactoring Rules:** `.clinerules` (Flutter Refactoring section)

---

**Last Updated:** 2026-01-30  
**Version:** 2.0 (Updated với Riverpod migration, GoRouter v2.0, ErrorTranslationUtils, và cấu trúc mới nhất)
