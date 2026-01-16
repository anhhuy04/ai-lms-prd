# Phân Tích Dự Án AI LMS - Từ Đầu Đến Cuối

## Giới Thiệu Dự Án

Dự án AI LMS (Learning Management System) là một hệ thống học tập thông minh trên nền tảng di động, nhằm số hóa toàn bộ quy trình giao bài - làm bài - chấm điểm. Dự án sử dụng Flutter cho frontend, Supabase cho backend, và tích hợp AI để hỗ trợ chấm điểm tự động và đề xuất cá nhân hóa.

**Mục tiêu chính:**
- Số hóa quy trình giao bài - làm bài - chấm điểm
- Ứng dụng AI để hỗ trợ chấm điểm, phản hồi và phân tích học tập
- Hỗ trợ 3 đối tượng: Giáo viên, Học sinh, Quản trị viên

**Luồng chính:**
Giáo viên tạo bài → giao bài → học sinh làm bài → nộp bài → AI chấm → giáo viên duyệt → phân tích & đề xuất

## Những Gì Đã Hoàn Thành ✅

### 1. Cơ Sở Hạ Tầng Kỹ Thuật
- **Kiến trúc Clean Architecture + MVVM**: Đã thiết lập đầy đủ với 3 tầng rõ ràng
  - Presentation (Views & ViewModels)
  - Domain (Entities & Repositories)
  - Data (DataSources & Implementations)
- **Tích hợp Supabase**: Hoàn thành authentication, PostgreSQL database, Storage
- **Authentication System**: Đăng ký, đăng nhập, đăng xuất với email/password
- **Role-Based Access Control**: 3 vai trò (student/teacher/admin) với navigation riêng

### 2. UI/UX Cơ Bản
- **Splash Screen**: Tự động điều hướng dựa trên trạng thái auth
- **Login/Register Screens**: Form validation với thông báo lỗi tiếng Việt
- **Dashboard Screens**: Skeleton cho 3 vai trò (student/teacher/admin)
- **App Theme**: Material Design với colors và typography

### 3. State Management & Error Handling
- **Provider Pattern**: Dependency injection với ChangeNotifier
- **AuthViewModel**: Quản lý trạng thái đăng nhập, logout, role check
- **Error Handling**: CustomException với thông báo tiếng Việt trong Repository layer
- **Profile Entity**: Model cho bảng profiles với serialization

### 4. Database Schema Cơ Bản
- **Bảng profiles**: Tự động tạo khi user đăng ký
- **Trigger on_auth_user_created**: Sync auth.users với profiles
- **BaseTableDataSource**: Generic class cho Supabase queries

## Phân Tích Các Chương Và Bước Tiếp Theo

### Chương 1: Tạo Và Giao Bài Tập (Create & Distribute Assignments)

**Mục tiêu:** Cho phép giáo viên xây dựng bài tập đa dạng với nhiều loại câu hỏi, rich text, và phân phối linh hoạt.

**Những gì đã có:** Chỉ có skeleton dashboard, chưa có functionality thực tế.

**Bước thực hiện từng bước:**

#### Bước 1.1: Xây Dựng Data Models (Tuần 1)
- Tạo entity `Assignment` trong `lib/domain/entities/`
  ```dart
  class Assignment {
    final String id;
    final String title;
    final String description;
    final String createdBy; // teacher ID
    final DateTime dueDate;
    final List<String> learningObjectives;
    final Map<String, dynamic> rubricConfig;
    final DateTime createdAt;
    final DateTime updatedAt;
  }
  ```
- Tạo entity `Question` với enum `QuestionType`
  ```dart
  enum QuestionType {
    multipleChoice,
    trueFalse,
    shortAnswer,
    essay,
    fileUpload
  }

  class Question {
    final String id;
    final String assignmentId;
    final QuestionType type;
    final String content; // rich text
    final List<String>? options; // cho MC
    final int points;
    final int order;
  }
  ```

#### Bước 1.2: Xây Dựng Repository Layer (Tuần 1-2)
- Tạo `lib/domain/repositories/assignment_repository.dart` (abstract interface)
- Tạo `lib/data/datasources/assignment_datasource.dart` với Supabase queries
- Tạo `lib/data/repositories/assignment_repository_impl.dart` với error translation

#### Bước 1.3: Xây Dựng ViewModel (Tuần 2)
- Tạo `lib/presentation/viewmodels/assignment_viewmodel.dart`
- State management cho create/edit assignment
- Validation logic cho form fields

#### Bước 1.4: Xây Dựng UI Screens (Tuần 2-3)
- `lib/presentation/views/assignment/assignment_list_screen.dart`: Danh sách bài tập
- `lib/presentation/views/assignment/assignment_builder_screen.dart`: Form tạo bài
- `lib/presentation/views/assignment/question_builder_screen.dart`: Thêm/sửa câu hỏi
- `lib/presentation/views/assignment/assignment_preview_screen.dart`: Xem trước

#### Bước 1.5: Tích Hợp Rich Text Editor (Tuần 3)
- Thêm dependency `flutter_quill` vào pubspec.yaml
- Sử dụng MCP Fetch để tìm examples của flutter_quill
- Implement editor cho question content và assignment description
- Support LaTeX rendering cho công thức toán

#### Bước 1.6: Phân Phối Bài Tập (Tuần 4)
- UI chọn class/group/student để giao bài
- Set deadline và notifications
- Confirm distribution

### Chương 2: Làm Bài & Nộp Bài (Student Workspace & Submission)

**Mục tiêu:** Cung cấp workspace cho học sinh với auto-save, upload file, theo dõi tiến độ.

**Dependencies:** Phải hoàn thành Chương 1 trước.

**Bước thực hiện từng bước:**

#### Bước 2.1: Data Models (Tuần 4)
- Entity `Submission`: id, assignment_id, student_id, responses (JSON), status, submitted_at
- Entity `SubmissionAnswer`: id, submission_id, question_id, answer (JSON), auto_saved_at

#### Bước 2.2: Repository Layer (Tuần 4)
- `SubmissionRepository` với auto-save logic
- `SubmissionDataSource` với Supabase operations

#### Bước 2.3: Student Workspace ViewModel (Tuần 5)
- Track auto-save state mỗi 2 giây
- Handle file uploads
- Progress tracking

#### Bước 2.4: Workspace UI (Tuần 5)
- `StudentWorkspaceScreen`: Hiển thị questions với input fields phù hợp type
- Auto-save indicator
- Progress bar
- File upload với image picker

#### Bước 2.5: Submission Flow (Tuần 6)
- `SubmissionConfirmationScreen`: Review answers trước submit
- Timestamp recording
- Success confirmation với navigation

### Chương 3: Chấm Điểm Bằng AI (AI-Powered Grading)

**Mục tiêu:** Tự động chấm điểm với AI, cho phép teacher override.

**Dependencies:** Cần external AI service (OpenAI hoặc custom API).

**Bước thực hiện từng bước:**

#### Bước 3.1: AI Service Integration (Tuần 6)
- Tạo `AIService` trong `lib/core/services/`
- API calls đến OpenAI hoặc custom AI
- Prompt engineering cho grading essays

#### Bước 3.2: Grading Data Models (Tuần 7)
- Entity `AIEvaluation`: grade, confidence_score, feedback, generated_at
- Entity `GradeOverride`: teacher corrections

#### Bước 3.3: Grading UI (Tuần 7-8)
- `GradingDashboardScreen`: List submissions cần chấm
- `SubmissionReviewScreen`: AI grade + teacher override
- Batch grading interface

#### Bước 3.4: Confidence Scoring & Feedback (Tuần 8)
- Display confidence levels
- Editable feedback từ AI
- Learning insights generation

### Chương 4: Phân Tích Học Tập (Learning Analytics)

**Mục tiêu:** Cung cấp insights về tiến độ học tập, điểm mạnh/yếu.

**Dependencies:** Cần data từ Chapters 1-3.

**Bước thực hiện từng bước:**

#### Bước 4.1: Analytics Data Models (Tuần 9)
- `StudentSkillMastery`: skill_id, mastery_level, updated_at
- `QuestionStats`: correct_count, total_attempts, avg_time
- `SubmissionAnalytics`: time_spent, error_patterns

#### Bước 4.2: Analytics Engine (Tuần 9-10)
- Algorithms detect error patterns
- Skill mastery calculations
- Trend analysis

#### Bước 4.3: Charts & Visualizations (Tuần 10)
- Thêm `fl_chart` dependency
- Skill mastery radar charts
- Performance trend lines
- Distribution histograms

#### Bước 4.4: Analytics Dashboards (Tuần 11)
- `StudentAnalyticsScreen`: Personal progress
- `TeacherAnalyticsScreen`: Class overview
- `AdminAnalyticsScreen`: School metrics

### Chương 5: Đề Xuất Cá Nhân Hóa (Personalized Recommendations)

**Mục tiêu:** Gợi ý can thiệp cho teacher và tài nguyên học tập cho student.

**Dependencies:** Cần analytics từ Chapter 4.

**Bước thực hiện từng bước:**

#### Bước 5.1: Recommendation Engine (Tuần 11)
- AI algorithms generate suggestions
- Teacher interventions based on low performance
- Student learning resources

#### Bước 5.2: Recommendation Data Models (Tuần 12)
- `AIRecommendation`: type, content, priority, created_at
- `TeacherNotes`: teacher feedback

#### Bước 5.3: Recommendation UI (Tuần 12)
- Priority-based recommendation cards
- Dismiss và action links
- Integration với dashboards

## Các Tính Năng Hỗ Trợ (Cross-Cutting)

### Database & Security
- Tạo tables cho assignments, questions, submissions, grades, analytics
- Setup Row-Level Security (RLS) policies
- Indexes cho performance

### Class & Group Management
- Entities: School, Class, Group, ClassMember
- UI quản lý classes và groups
- Assignment distribution theo class/group

### Notifications
- Push notifications cho assignments mới
- Grade ready alerts
- Due date reminders

### Testing & Quality Assurance
- Unit tests cho ViewModels và Repositories (target 70% coverage)
- Widget tests cho screens
- Integration tests cho critical flows
- Performance profiling

## Timeline Tổng Quan

- **Phase 1 (Weeks 1-4)**: Chapter 1 - Assignment Builder ✅ (đang bắt đầu)
- **Phase 2 (Weeks 5-6)**: Chapter 2 - Student Workspace
- **Phase 3 (Weeks 7-8)**: Chapter 3 - AI Grading
- **Phase 4 (Weeks 9-11)**: Chapter 4 - Analytics
- **Phase 5 (Weeks 12+)**: Chapter 5 - Recommendations

**Tổng thời gian ước tính:** 12-14 tuần cho MVP hoàn chỉnh

## Dependencies Và Rủi Ro

### Dependencies Chính
- **Supabase**: Backend, auth, database, storage
- **Flutter**: Cross-platform mobile framework
- **Provider**: State management
- **External AI**: OpenAI API hoặc custom service cho grading

### Rủi Ro Cần Lưu Ý
- **AI Service Integration**: Có thể phức tạp, cần testing kỹ
- **Rich Text Storage**: Chưa quyết định format (HTML/Markdown/JSON)
- **Performance**: Với nhiều students, cần optimize queries và caching
- **Offline Support**: Complex khi có file uploads

### Success Criteria
- ✅ 5 chapters hoàn thành và tested
- ✅ AI grading accuracy ≥ 85%
- ✅ Auto-save không mất dữ liệu
- ✅ Analytics có insights hữu ích
- ✅ Mobile-first responsive
- ✅ Load time < 5 giây

## Kết Luận Và Khuyến Nghị

Dự án đã có foundation vững chắc với authentication và architecture. Bước tiếp theo quan trọng nhất là hoàn thành Chapter 1 (Assignment Builder) vì nó là cơ sở cho tất cả chapters sau.

**Khuyến nghị ưu tiên:**
1. Tập trung Chapter 1 trước (đã bắt đầu)
2. Đảm bảo database schema đúng trước khi build UI
3. Test early và often, đặc biệt cho AI features
4. Update memory-bank thường xuyên để track progress

Bạn có muốn tôi bắt đầu implement từ bước nào cụ thể trong Chapter 1 không?





tôi đang làm giao diện cho trang giao bài tập nhưng chưa hình dung ra đc ở trong đó cần có những chức năng gì và phải thiết kế như nào cho tối ưu theo đề bài. bạn hãy nhập vài là 1 desginer đầy đủ kinh nghiệm và mô tả lại trang web và các chức năng của từng chi tiết để tối ưu

**

Checkpoint

Compare

Restore

API Request

Thinking:Người dùng đang hỏi về thiết kế giao diện cho trang giao bài tập (assignment distribution screen). Họ muốn tôi đóng vai designer có kinh nghiệm để mô tả trang web và các chức năng chi tiết để tối ưu theo đề bài. ‎

Dựa trên kinh nghiệm làm UX/UI Designer cho các hệ thống giáo dục, tôi sẽ mô tả chi tiết giao diện trang "Giao bài tập" (Assignment Distribution Screen) để tối ưu theo đề bài AI LMS. Đây là một trang quan trọng vì nó kết nối giữa việc tạo bài tập và phân phối đến học sinh.

## 🎯 Mục Tiêu Chính Của Trang

- __Phân phối linh hoạt__: Lớp, nhóm, hoặc cá nhân học sinh
- __Thiết lập deadline__: Thời hạn nộp bài với thông báo
- __Xác nhận phân phối__: Đảm bảo không có lỗi trước khi gửi
- __Tracking phân phối__: Theo dõi trạng thái giao bài

## 📱 Layout Tổng Quan (Mobile-First Design)

### Header Section (Sticky Header)

```javascript
┌─────────────────────────────────────┐
│ ← Back          GIAO BÀI TẬP        │
│                                     │
│ 📝 Toán 12 - Bài tập tuần 3         │
│ 👨‍🏫 Giáo viên: Nguyễn Văn A         │
└─────────────────────────────────────┘
```

__Chức năng:__

- __Back button__: Quay về Assignment Builder
- __Title__: Tên bài tập + thông tin giáo viên
- __Progress indicator__: Step 4/4 trong flow tạo bài

### Step Indicator

```javascript
○ ○ ○ ●
Tạo bài  Chi tiết  Xem trước  Giao bài
```

__UX tối ưu:__

- Visual progress để user biết đang ở bước nào
- Không thể skip steps, đảm bảo data integrity

## 🎯 Phần Chính: Phân Phối (Main Distribution Section)

### 1. Chọn Đối Tượng Nhận Bài (Recipients Selection)

```javascript
┌─────────────────────────────────────┐
│ 👥 CHỌN ĐỐI TƯỢNG NHẬN BÀI        │
│                                     │
│ 🔘 Toàn bộ lớp học                 │
│ 🔘 Nhóm học sinh cụ thể            │
│ 🔘 Học sinh cá nhân                │
│                                     │
└─────────────────────────────────────┘
```

__Chức năng chi tiết:__

- __Radio buttons__: 3 options phân phối
- __Smart defaults__: Mặc định chọn "Toàn bộ lớp học"
- __Validation__: Phải chọn ít nhất 1 option

### 2. Chi Tiết Phân Phối Theo Loại

#### Trường hợp 1: Toàn Bộ Lớp Học

```javascript
┌─────────────────────────────────────┐
│ 🏫 CHỌN LỚP HỌC                    │
│                                     │
│ [Dropdown] Lớp 12A Toán           ▼ │
│ Lớp 12B Toán  • 35 học sinh        │
│                                     │
│ 📊 Preview: 35 học sinh sẽ nhận    │
└─────────────────────────────────────┘
```

#### Trường hợp 2: Nhóm Học Sinh

```javascript
┌─────────────────────────────────────┐
│ 👨‍👩‍👧‍👦 CHỌN NHÓM                     │
│                                     │
│ 🔍 Tìm nhóm...                     │
│                                     │
│ 📚 Nhóm Toán Nâng Cao              │
│   • Nguyễn A, Trần B, Lê C        │
│                                     │
│ 🎯 Nhóm Ôn Thi Đại Học            │
│   • 15 học sinh                    │
│                                     │
│ ➕ Tạo nhóm mới                    │
└─────────────────────────────────────┘
```

#### Trường hợp 3: Học Sinh Cá Nhân

```javascript
┌─────────────────────────────────────┐
│ 👤 CHỌN HỌC SINH CÁ NHÂN           │
│                                     │
│ 🔍 Tìm học sinh...                 │
│                                     │
│ ☑️ Nguyễn Văn A (12A)              │
│ ☑️ Trần Thị B (12B)                │
│ ☑️ Lê Văn C (12A)                  │
│                                     │
│ ✅ Đã chọn: 3 học sinh             │
└─────────────────────────────────────┘
```

__UX tối ưu:__

- __Search functionality__: Tìm nhanh học sinh/nhóm
- __Multi-select__: Checkbox cho chọn nhiều
- __Counter__: Hiển thị số lượng đã chọn
- __Preview recipients__: Xem trước danh sách sẽ nhận

### 3. Thiết Lập Thời Hạn (Deadline Settings)

```javascript
┌─────────────────────────────────────┐
│ ⏰ THIẾT LẬP THỜI HẠN              │
│                                     │
│ 📅 Ngày hết hạn                     │
│ [Date Picker] 25/12/2024          ▼ │
│                                     │
│ 🕐 Giờ hết hạn                      │
│ [Date Picker] 25/12/2024          ▼ │
│ [Time Picker] 23:59               ▼ │


│ │ 🕐 Thời gian làm bài                  │
│ [Time Picker] 23:59               ▼ │
│                                     │
│ Thang điểm:                       +  │
  tự luận ...
  trắc nhiệm ...
└─────────────────────────────────────┘
```

__Chức năng tối ưu:__

- __Smart defaults__: Ngày mai, 23:59
- __Notification options__: Nhắc nhở học sinh
- __Notes field__: Hướng dẫn đặc biệt
- __Validation__: Không cho phép deadline quá khứ

### 4. Tùy Chọn Nâng Cao (Advanced Options)

```javascript
┌─────────────────────────────────────┐
│ ⚙️ TÙY CHỌN NÂNG CAO               │
│                                     │
│ 🔄 Cho phép nộp lại                │
│ [Toggle] ON                        │
│                                     │
│ 📊 Theo dõi tiến độ                 │
│ [Toggle] ON                        │
│                                     │
│ 🔒 Mật khẩu truy cập               │
│ [Text Field] (tùy chọn)            │
│                                     │
└─────────────────────────────────────┘
```

__Chức năng:__

- __Resubmission__: Cho phép nộp lại sau khi chấm
- __Progress tracking__: Theo dõi tỷ lệ hoàn thành
- __Access code__: Bảo mật thêm (optional)

## 📋 Phần Xem Trước & Xác Nhận (Preview & Confirmation)

### Recipients Preview

```javascript
┌─────────────────────────────────────┐
│ 👀 XEM TRƯỚC NGƯỜI NHẬN           │
│                                     │
│ 📧 Email sẽ gửi đến:               │
│ • nguyen.a@email.com              │
│ • tran.b@email.com                │
│ • le.c@email.com                  │
│ [+ 32 người khác]                 │
│                                     │
│ 📱 Push notification: ON          │
└─────────────────────────────────────┘
```

### Bài Tập Summary

```javascript
┌─────────────────────────────────────┐
│ 📝 TÓM TẮT BÀI TẬP                │
│                                     │
│ 🎯 Mục tiêu: Ôn tập đạo hàm        │
│ ⏱️ Thời gian: 45 phút              │
│ 📊 Số câu hỏi: 10                  │
│ 🎖️ Tổng điểm: 100                 │
│                                     │
│ 📅 Hết hạn: 25/12/2024 23:59      │
│ 🔔 Nhắc nhở: 1 giờ trước           │
└─────────────────────────────────────┘
```

## 🎛️ Action Buttons (Bottom Sticky)

```javascript
┌─────────────────────────────────────┐
│          [LƯU NHÁP]    [GIAO BÀI]   │
└─────────────────────────────────────┘
```

__UX tối ưu:__

- __Primary action__: "GIAO BÀI" nổi bật (màu xanh)
- __Secondary action__: "LƯU NHÁP" (màu xám)
- __Sticky bottom__: Luôn hiển thị khi scroll

## 🔄 User Flow Tối Ưu

### Flow Chính:

1. __Vào trang__ → Hiển thị options phân phối
2. __Chọn loại__ → Toàn lớp/Nhóm/Cá nhân
3. __Chọn recipients__ → Search & select
4. __Set deadline__ → Date/time picker
5. __Xem preview__ → Confirm recipients & summary
6. __Giao bài__ → Success confirmation + notification

### Edge Cases Handled:

- __Empty selection__: Error message "Vui lòng chọn ít nhất 1 học sinh"
- __Past deadline__: Warning "Thời hạn không thể ở quá khứ"
- __No internet__: Offline queue với sync later
- __Large class__: Pagination cho preview danh sách

## 🎨 Design System Consistency

### Colors:

- __Primary__: Xanh dương (#1976D2) cho actions chính
- __Success__: Xanh lá (#4CAF50) cho confirmations
- __Warning__: Cam (#FF9800) cho deadlines
- __Error__: Đỏ (#F44336) cho validations

### Typography:

- __Headers__: 18pt Bold
- __Body__: 14pt Regular
- __Captions__: 12pt Light
- __Font__: Roboto (Material Design)

### Spacing:

- __Sections__: 24pt margin
- __Elements__: 16pt padding
- __Items__: 8pt between list items

## 📱 Mobile Optimizations

### Touch Targets:

- Minimum 44pt height cho buttons
- 48pt cho form fields
- Comfortable spacing cho thumbs

### Keyboard Handling:

- Auto-scroll khi keyboard hiện
- Smart field focusing
- Input type hints (email, datetime)

### Performance:

- Lazy loading cho large recipient lists
- Cached search results
- Minimal re-renders

## 🔍 Accessibility Features

### Screen Reader Support:

- ARIA labels cho tất cả interactive elements
- Semantic HTML structure
- Alt text cho icons

### Keyboard Navigation:

- Tab order logical
- Enter để submit forms
- Escape để cancel

### Color Contrast:

- WCAG AA compliance
- Dark mode support
- High contrast mode

## 📊 Success Metrics

### UX Metrics:

- __Task completion__: >90% users complete distribution without errors
- __Time to complete__: <2 minutes average
- __Error rate__: <5% validation errors
- __Mobile satisfaction__: >4.5/5 rating

### Business Metrics:

- __Distribution success__: 99% assignments delivered successfully
- __Notification open rate__: >70% push notifications opened
- __On-time submission rate__: Increase by tracking deadlines

Bạn có muốn tôi đi sâu vào một phần cụ thể nào không? Ví dụ: wireframes chi tiết, component specifications, hoặc interaction flows?

thiết kế giao diện tạo câu hỏi

**

Checkpoint

Compare

Restore

API Request

Thinking:Người dùng muốn thiết kế giao diện tạo câu hỏi. Đây là phần quan trọng trong Chapter 1 của AI LMS - Question Builder. Tôi cần mô tả chi tiết giao diện cho việc tạo các loại câu hỏi khác nhau (multiple choice, true/false, short answer, essay, file upload) với UX tối ưu cho giáo viên. ‎

Dựa trên kinh nghiệm thiết kế UX/UI cho các hệ thống giáo dục, tôi sẽ mô tả chi tiết giao diện "Tạo câu hỏi" (Question Builder) để tối ưu cho việc tạo các loại câu hỏi đa dạng trong AI LMS.

## 🎯 Mục Tiêu Chính Của Trang

- __Đa dạng loại câu hỏi__: Multiple choice, True/False, Short answer, Essay, File upload
- __Rich content__: Hỗ trợ text, hình ảnh, video, LaTeX
- __Rubric chấm điểm__: Criteria-based scoring
- __Preview real-time__: Xem trước cách hiển thị cho học sinh
- __Intuitive workflow__: Dễ dàng cho giáo viên không chuyên kỹ thuật

## 📱 Layout Tổng Quan (Split-Screen Design)

### Header với Context

```javascript
┌─────────────────────────────────────┐
│ ← Back     CÂU HỎI 3/10   ➕ Thêm   │
│                                     │
│ 📝 Bài tập: Ôn tập đạo hàm         │
│ 🎯 Mục tiêu: Áp dụng công thức      │
└─────────────────────────────────────┘
```

__UX tối ưu:__

- __Progress indicator__: Hiển thị câu hỏi hiện tại / tổng số
- __Context awareness__: Nhắc lại bài tập và mục tiêu học tập
- __Quick actions__: Thêm câu hỏi mới, xóa, reorder

## 🎨 Phần Chính: Question Builder (Split Layout)

### Bên Trái: Form Tạo Câu Hỏi (70% width)

#### 1. Loại Câu Hỏi Selector

```javascript
┌─────────────────────────────────────┐
│ 🔘 LOẠI CÂU HỎI                     │
│                                     │
│ 🟢 Trắc nghiệm (Multiple Choice)    │
│ 🔵 Đúng/Sai (True/False)           │
│ 🟠 Tự luận ngắn (Short Answer)     │
│ 🔴 Tự luận (Essay)                 │
│ 🟣 Upload file (File Upload)       │
└─────────────────────────────────────┘
```

__UX tối ưu:__

- __Visual icons__: Màu sắc khác nhau cho từng loại
- __Smart defaults__: Multiple choice được chọn đầu tiên
- __Dynamic form__: Form thay đổi theo loại câu hỏi

#### 2. Nội Dung Câu Hỏi (Rich Text Editor)

```javascript
┌─────────────────────────────────────┐
│ ✏️ NỘI DUNG CÂU HỎI                 │
│                                     │
│ [Rich Text Editor]                  │
│ Tính đạo hàm của hàm số:            │
│                                     │
│ f(x) = x² + 2x + 1                  │
│                                     │
│ [B] [I] [U] [Image] [LaTeX] [Link]  │
│                                     │
│ 📎 Đính kèm: calculus_formula.png   │
└─────────────────────────────────────┘
```

__Chức năng:__

- __Formatting toolbar__: Bold, italic, underline
- __Media insertion__: Hình ảnh, video embed
- __LaTeX support__: Công thức toán học
- __File attachments__: Tài liệu tham khảo

#### 3. Cấu Hình Theo Loại Câu Hỏi

##### Multiple Choice Configuration

```javascript
┌─────────────────────────────────────┐
│ 📋 TÙY CHỌN TRẢ LỜI                 │
│                                     │
│ ☑️ Cho phép chọn nhiều đáp án       │
│ ☑️ Randomize thứ tự đáp án         │
│                                     │
│ 🔢 Số đáp án: 4                    │
│                                     │
│ 1. [Text Field] x + 1              │
│    ☑️ Đáp án đúng                   │
│                                     │
│ 2. [Text Field] x - 1              │
│    ☐ Đáp án sai                    │
│                                     │
│ 3. [Text Field] 2x + 1             │
│    ☐ Đáp án sai                    │
│                                     │
│ ➕ Thêm đáp án                      │
└─────────────────────────────────────┘
```

##### Essay Configuration

```javascript
┌─────────────────────────────────────┐
│ 📝 CẤU HÌNH TỰ LUẬN                │
│                                     │
│ 📏 Độ dài mong đợi                  │
│ [Slider] 200-500 từ                │
│                                     │
│ 🎯 Yêu cầu cụ thể                   │
│ [Text Area] Phải giải thích từng... │
│                                     │
│ 📎 File mẫu đính kèm                │
│ [File Upload] essay_sample.pdf      │
└─────────────────────────────────────┘
```

#### 4. Rubric Builder (Scoring Criteria)

```javascript
┌─────────────────────────────────────┐
│ 🎖️ TIÊU CHÍ CHẤM ĐIỂM               │
│                                     │
│ 📊 Loại rubric: Holistic           │
│   • Holistic (tổng thể)            │
│   • Analytic (chi tiết)            │
│                                     │
│ 🏆 Mức độ (4 levels)                │
│                                     │
│ ⭐ Xuất sắc (90-100%)               │
│ [Text] Trả lời đầy đủ, chính xác... │
│                                     │
│ ✅ Tốt (75-89%)                     │
│ [Text] Trả lời đúng nhưng thiếu... │
│                                     │
│ ⚠️ Trung bình (60-74%)              │
│ [Text] Trả lời có sai sót...       │
│                                     │
│ ❌ Yếu (0-59%)                      │
│ [Text] Trả lời sai hoặc trống...   │
└─────────────────────────────────────┘
```

__UX tối ưu:__

- __Templates__: Rubric mẫu cho từng loại câu hỏi
- __Drag & drop__: Reorder criteria
- __Auto-calculation__: Tự động tính điểm theo %

### Bên Phải: Preview & Tools (30% width)

#### 1. Live Preview

```javascript
┌─────────────────────────────────────┐
│ 👁️ XEM TRƯỚC (HỌC SINH THẤY)     │
│                                     │
│ Tính đạo hàm của hàm số:            │
│ f(x) = x² + 2x + 1                  │
│                                     │
│ ⃝ x + 1                             │
│ ⃝ x - 1                             │
│ ⃝ 2x + 1                            │
│ ⃝ 2x - 1                            │
│                                     │
│ [Nộp bài]                           │
└─────────────────────────────────────┘
```

__Chức năng:__

- __Real-time sync__: Thay đổi form → preview cập nhật ngay
- __Device preview__: Xem trên mobile/desktop
- __Student perspective__: Chính xác như học sinh thấy

#### 2. Question Library

```javascript
┌─────────────────────────────────────┐
│ 📚 THƯ VIỆN CÂU HỎI                 │
│                                     │
│ 🔍 Tìm câu hỏi...                  │
│                                     │
│ ⭐ Câu hỏi được dùng nhiều          │
│   • Đạo hàm bậc nhất               │
│   • Tích phân cơ bản               │
│                                     │
│ 📁 Thư mục của tôi                  │
│   • Ôn tập kỳ 1                    │
│   • Bài tập nâng cao               │
└─────────────────────────────────────┘
```

__UX tối ưu:__

- __Search & filter__: Tìm theo chủ đề, độ khó
- __Templates__: Câu hỏi mẫu sẵn có
- __Reuse__: Copy từ bài tập cũ
- __Save to library__: Lưu câu hỏi để tái sử dụng

#### 3. AI Assist Tools

```javascript
┌─────────────────────────────────────┐
│ 🤖 TRỢ LÝ AI                        │
│                                     │
│ ✨ Tạo câu hỏi tự động              │
│ [Input] Đạo hàm hàm số bậc 2       │
│                                     │
│ 🎯 Phân tích độ khó                 │
│ Độ khó: Trung bình (6/10)          │
│                                     │
│ 📊 Đề xuất đáp án sai              │
│ • Common mistakes của học sinh     │
└─────────────────────────────────────┘
```

## 🎛️ Action Panel (Bottom Sticky)

### Primary Actions

```javascript
┌─────────────────────────────────────┐
│ [LƯU NHÁP]  [XEM TRƯỚC]  [HOÀN THÀNH]
└─────────────────────────────────────┘
```

### Secondary Actions (Dropdown)

```javascript
⋮
├── Sao chép câu hỏi
├── Di chuyển lên/xuống
├── Xóa câu hỏi
├── Xuất ra file
└── Import từ file
```

## 🔄 User Flow Tối Ưu

### Flow Tạo Câu Hỏi:

1. __Chọn loại__ → Form động thay đổi
2. __Nhập nội dung__ → Rich text editor
3. __Cấu hình__ → Settings theo loại
4. __Setup rubric__ → Tiêu chí chấm điểm
5. __Preview__ → Xem như học sinh thấy
6. __Lưu__ → Chuyển sang câu hỏi tiếp theo

### Smart Features:

- __Auto-save__: Mỗi 30 giây
- __Validation__: Required fields, logic checks
- __Undo/Redo__: Text editing
- __Keyboard shortcuts__: Ctrl+S save, Ctrl+Z undo

## 🎨 Design System

### Visual Hierarchy:

- __Question number__: 24pt Bold
- __Form labels__: 16pt Medium
- __Input fields__: 14pt Regular
- __Help text__: 12pt Light

### Color Coding:

- __Multiple Choice__: Xanh dương
- __True/False__: Xanh lá
- __Short Answer__: Cam
- __Essay__: Tím
- __File Upload__: Xanh dương đậm

### Spacing:

- __Form sections__: 32pt margin
- __Form fields__: 24pt margin
- __List items__: 16pt margin

## 📱 Mobile Responsive Design

### Tablet Layout:

- __Split view__: Form 60% - Preview 40%
- __Collapsible panels__: Có thể ẩn preview để tập trung

### Mobile Layout:

- __Tab navigation__: Form | Preview | Tools
- __Bottom sheet__: Rubric builder
- __Swipe gestures__: Chuyển câu hỏi

## 🔍 Accessibility & Usability

### Keyboard Navigation:

- __Tab order__: Logical flow
- __Enter__: Next field
- __Shift+Enter__: Previous field
- __Ctrl+Enter__: Save & next

### Screen Reader:

- __Field labels__: Descriptive
- __Form validation__: Error announcements
- __Progress feedback__: "Đã lưu thành công"

### Error Prevention:

- __Required fields__: Visual indicators
- __Input validation__: Real-time feedback
- __Confirmation dialogs__: Delete actions

## 📊 Success Metrics

### Usability:

- __Task completion__: >95% teachers complete question creation
- __Time per question__: <5 minutes average
- __Error rate__: <3% validation errors
- __Satisfaction__: >4.8/5 rating

### Quality:

- __Question variety__: Average 3+ question types per assignment
- __Rich content usage__: 70%+ questions use images/formulas
- __Rubric completion__: 80%+ questions have detailed rubrics

Bạn có muốn tôi focus vào một khía cạnh cụ thể không? Ví dụ:

- Wireframes chi tiết cho một loại câu hỏi
- Component specifications
- AI assist features workflow
- Mobile adaptations
