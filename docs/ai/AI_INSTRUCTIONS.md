# HƯỚNG DẪN MẶC ĐỊNH CHO AI

Đây là các quy tắc và hướng dẫn mặc định cho AI khi làm việc với dự án Flutter "AI LMS".

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
    ├── routes/                # Thư mục chứa các route và navigation config
    │   ├── app_routes.dart    # File định nghĩa tất cả các route: Sử dụng GoRouter hoặc named routes, ví dụ: '/login', '/dashboard', '/assignment/create'. Đảm bảo bảo mật route dựa trên role (teacher/student).
    │   └── guards/            # Thư mục con cho route guards
    │       └── auth_guard.dart # File guard: Kiểm tra auth state từ ViewModel để redirect nếu chưa login hoặc không có quyền.
    ├── core/                  # Thư mục chứa các phần cốt lõi, chung cho toàn app
    │   ├── constants/         # Thư mục chứa hằng số
    │   │   ├── api_constants.dart # File chứa các hằng: URL Supabase, anon key, role enums ('teacher', 'student', 'admin').
    │   │   └── ui_constants.dart  # File chứa các hằng UI: colors, sizes, strings chung như error messages.
    │   ├── utils/             # Thư mục chứa các hàm tiện ích
    │   │   ├── date_utils.dart    # File util: Hàm xử lý ngày tháng, format timestamp từ Supabase.
    │   │   ├── network_utils.dart # File util: Kiểm tra kết nối mạng, handle errors từ Supabase queries.
    │   │   ├── validators.dart    # File util: Hàm validate input như email, password, full_name.
    │   │   └── extensions.dart    # File extension: Mở rộng các class như String, DateTime cho tiện dùng.
    │   └── services/          # Thư mục chứa các service inject qua provider
    │       ├── supabase_service.dart # File service: Khởi tạo và quản lý Supabase client, auth, realtime subscriptions (ví dụ: listen changes trên tables như assignments).
    │       ├── notification_service.dart # File service: Xử lý push notifications (sử dụng Firebase nếu cần) cho thông báo bài tập mới.
    │       ├── storage_service.dart # File service: Upload/download files đến Supabase Storage (cho images, PDFs trong questions/files).
    │       └── ai_service.dart    # File service: Gọi API AI (nếu tích hợp external AI như OpenAI) cho grading, feedback, recommendations.
    ├── data/                  # Thư mục chứa data layer (liên quan đến Supabase)
    │   ├── datasources/       # Thư mục chứa nguồn dữ liệu cụ thể
    │   │   └── supabase_datasource.dart # File datasource: Các hàm trực tiếp query Supabase như select, insert, update cho tables (profiles, classes, assignments, etc.).
    │   └── repositories/      # Thư mục chứa implement repository
    │       ├── auth_repository_impl.dart # File repo: Implement auth functions như signUp, signIn, getUserRole từ Supabase Auth.
    │       ├── profile_repository_impl.dart # File repo: Xử lý profiles: getProfile, updateProfile, trigger handle_new_user.
    │       ├── school_class_repository_impl.dart # File repo: Xử lý schools, classes, class_members, class_teachers: createClass, joinClass, etc.
    │       ├── group_objective_repository_impl.dart # File repo: Xử lý groups, group_members, learning_objectives, question_objectives.
    │       ├── question_file_repository_impl.dart # File repo: Xử lý questions, question_choices, files, file_links: createQuestion, uploadFile.
    │       ├── assignment_distribution_repository_impl.dart # File repo: Xử lý assignments, assignment_questions, assignment_variants, assignment_distributions: createAssignment, publishAssignment.
    │       ├── workspace_submission_repository_impl.dart # File repo: Xử lý work_sessions, autosave_answers, submission_answers, submissions: startSession, submitAnswer, autoSave.
    │       ├── ai_grading_repository_impl.dart # File repo: Xử lý ai_queue, ai_evaluations, grade_overrides: queueAIGrading, overrideGrade.
    │       └── analytics_recommendation_repository_impl.dart # File repo: Xử lý student_skill_mastery, question_stats, submission_analytics, ai_recommendations, teacher_notes: getMastery, generateRecommendations.
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
    │   │   ├── auth/          # Thư mục con cho auth screens
    │   │   │   ├── login_screen.dart # View: Màn hình login với form, button sign in/up, liên kết Supabase Auth.
    │   │   │   └── register_screen.dart # View: Màn hình đăng ký, chọn role (teacher/student), trigger handle_new_user.
    │   │   ├── dashboard/     # Thư mục con cho dashboard
    │   │   │   ├── teacher_dashboard_screen.dart # View: Dashboard giáo viên: Danh sách classes, assignments, recommendations (Chương 5).
    │   │   │   └── student_dashboard_screen.dart # View: Dashboard học sinh: Danh sách assignments, skill map, performance trends (Chương 4).
    │   │   ├── assignment/    # Thư mục con cho assignment (Chương 1)
    │   │   │   ├── assignment_builder_screen.dart # View: Builder tạo assignment: Rich text editor, add questions, set rubrics, preview.
    │   │   │   ├── assignment_distribution_screen.dart # View: Phân phối assignment: Chọn class/group/student, set due date, notifications.
    │   │   │   └── assignment_list_screen.dart # View: Danh sách assignments cho teacher/student.
    │   │   ├── workspace/     # Thư mục con cho student workspace (Chương 2)
    │   │   │   ├── student_workspace_screen.dart # View: Không gian làm bài: Auto-save, progress bar, upload files, timer, flag questions.
    │   │   │   └── submission_confirmation_screen.dart # View: Xác nhận nộp bài, review trước submit.
    │   │   ├── grading/       # Thư mục con cho grading (Chương 3)
    │   │   │   ├── grading_dashboard_screen.dart # View: Dashboard chấm bài: List submissions, batch grading, side-by-side view, publish grades.
    │   │   │   └── feedback_editor_screen.dart # View: Chỉnh sửa feedback AI, override scores.
    │   │   ├── analytics/     # Thư mục con cho analytics (Chương 4)
    │   │   │   ├── student_analytics_screen.dart # View: Phân tích strength/weakness: Charts, skill mastery, comparisons.
    │   │   │   └── individual_profile_screen.dart # View: Hồ sơ cá nhân: History, engagement metrics, teacher notes.
    │   │   └── recommendations/ # Thư mục con cho recommendations (Chương 5)
    │   │       └── recommendations_screen.dart # View: List recommendations: Prioritized actions, resources, dismiss option.
    │   └── viewmodels/        # Thư mục chứa ViewModels (state management, sử dụng ChangeNotifier hoặc Riverpod)
    │       ├── mixins/
    │       │   ├── refreshable_view_model.dart
    │       │   ├── realtime_listener.dart
    │       │   ├── loading_state_mixin.dart
    │       │   └── pagination_mixin.dart
    │       ├── auth_viewmodel.dart # VM: Quản lý auth state: login, logout, role check, listen auth changes từ Supabase.
    │       ├── profile_viewmodel.dart # VM: Load/update profile, full_name, avatar.
    │       ├── assignment_viewmodel.dart # VM: Logic tạo/distribute assignment: Call usecases, handle form states, validations (Chương 1).
    │       ├── workspace_viewmodel.dart # VM: Quản lý work session: Auto-save, timer, submit, progress tracking (Chương 2).
    │       ├── grading_viewmodel.dart # VM: Load submissions, AI grading queue, override, batch publish (Chương 3).
    │       ├── analytics_viewmodel.dart # VM: Fetch mastery data, charts, predictions (Chương 4).
    │       ├── recommendations_viewmodel.dart # VM: Generate/load recommendations, prioritize, dismiss (Chương 5).
    │       └── ...            # Các VM khác như class_viewmodel cho quản lý classes/groups.
    └── widgets/               # Thư mục chứa các widget reusable
        ├── custom_button.dart # Widget: Button tùy chỉnh với loading state.
        ├── rich_text_editor.dart # Widget: Editor cho questions/answers, hỗ trợ LaTeX, images.
        ├── progress_indicator.dart # Widget: Bar hiển thị tiến độ assignment.
        ├── file_uploader.dart # Widget: Upload files đến Supabase Storage.
        ├── chart_widgets.dart # Widget: Các chart cho analytics (sử dụng fl_chart).
        ├── error_handler.dart # Widget: Hiển thị errors từ API calls.
        └── drawers/            # Thư mục chứa hệ thống drawer
            ├── action_end_drawer.dart        # Khung chung cho tất cả drawer bên phải
            ├── class_settings_drawer.dart    # Nội dung cụ thể cho cài đặt lớp học
            ├── drawer_section_header.dart    # Header cho các section trong drawer
            ├── drawer_action_tile.dart       # Tile hành động với icon, tiêu đề, phụ đề
            └── drawer_toggle_tile.dart      # Tile với switch để bật/tắt tính năng
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
- **ViewModels:** Nằm trong `presentation/viewmodels/` và kết thúc bằng `_viewmodel.dart` (ví dụ: `auth_viewmodel.dart`).

> **Xem thêm:** Chi tiết về naming conventions trong `memory-bank/systemPatterns.md` (Code Organization Patterns section)

---

## 4. Quản lý Trạng thái (State Management)

- Sử dụng **`ChangeNotifier`** cho các ViewModel.
- ViewModel chịu trách nhiệm xử lý logic và gọi các `Usecase` hoặc `Repository`.
- View chỉ "lắng nghe" các thay đổi từ ViewModel để cập nhật giao diện. Sử dụng `ChangeNotifier.addListener` để lắng nghe và gọi `setState` khi cần thiết.
- Các trạng thái như `isLoading`, `errorMessage` phải được quản lý bên trong ViewModel.

> **Xem thêm:** Chi tiết về State Management Pattern và ViewModel structure trong `memory-bank/systemPatterns.md` (State Management Pattern section)

---

## 5. Điều hướng (Routing & Navigation)

- Mọi hoạt động điều hướng phải được định nghĩa và xử lý tập trung tại `routes/app_routes.dart`.
- Khi điều hướng đến một màn hình cần dữ liệu (ví dụ: `profile`), dữ liệu đó **BẮT BUỘC** phải được truyền qua tham số `arguments` của `Navigator.pushNamed()`.
- Hàm `generateRoute` chịu trách nhiệm lấy `arguments`, kiểm tra kiểu dữ liệu, và truyền vào hàm khởi tạo của màn hình tương ứng.
- Sử dụng các hằng số được định nghĩa trong lớp `AppRoutes` (ví dụ: `AppRoutes.home`) thay vì chuỗi thuần (hard-coded string) như `'/home'`.

> **Xem thêm:** Chi tiết về Role-Based Navigation trong `memory-bank/systemPatterns.md` (Key Technical Decisions section)

---

## 6. Xử lý Lỗi (Error Handling)

- Các lỗi cần hiển thị cho người dùng (ví dụ: "Sai mật khẩu") phải được quản lý qua `errorMessage` trong ViewModel và hiển thị bằng `ScaffoldMessenger.of(context).showSnackBar(...)` ở View.
- Các lỗi trong tầng `Data` hoặc `Domain` nên được bắt và ném lại (re-throw) dưới dạng các Exception đã được định nghĩa, thay vì trả về `null` một cách chung chung.

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

## 10. MCP Usage Patterns và Best Practices

### 10.1. Supabase MCP Server
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

### 10.2. Fetch MCP Server
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
- **State Management:** `memory-bank/systemPatterns.md` (State Management Pattern section)
- **Error Handling:** `memory-bank/systemPatterns.md` (Error Handling Pattern section)
- **Design System:** `memory-bank/systemPatterns.md` (Design System Specifications section)
- **Code Conventions:** `.clinerules` (Code Quality section) và `memory-bank/activeContext.md` (Active Preferences & Standards section)
- **MCP Setup & Configuration:** `memory-bank/techContext.md` (MCP Setup section)
- **Technology Stack:** `memory-bank/techContext.md`
- **Current Work Focus:** `memory-bank/activeContext.md` (Current Sprint Focus section)
- **Git Workflow:** `.clinerules` (Git Workflow section)
- **HTML → Dart Conversion:** `.clinerules` (HTML → Dart Conversion section)
- **Flutter Refactoring Rules:** `.clinerules` (Flutter Refactoring section)
