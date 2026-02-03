# Phân tích phạm vi StudentClassSettingsDrawer

## Mục đích
Tài liệu này phân tích các section trong `StudentClassSettingsDrawer` để xác định phần nào thuộc về lớp học cụ thể và phần nào thuộc về cài đặt ứng dụng chung.

## Phân loại các section

### ✅ Class-Specific (Nên giữ trong drawer này)

#### 1. THÔNG TIN LỚP HỌC
- **Thông tin lớp học** (`onViewClassInfo`): Xem mô tả, mã lớp, năm học của lớp hiện tại
- **Ngày tham gia** (`onViewJoinHistory`): Lịch sử tham gia lớp cụ thể
- **Thông tin giáo viên** (`onViewTeacherInfo`): Thông tin giáo viên phụ trách lớp này
- **Rời lớp học** (`onLeaveClass`): Hành động rời khỏi lớp cụ thể

**Lý do**: Tất cả đều liên quan trực tiếp đến lớp học hiện tại mà học sinh đang xem.

#### 2. QUẢN LÝ BÀI TẬP
- **Bài đã nộp** (`onViewSubmittedAssignments`): Bài tập đã nộp trong lớp này
- **Bài chưa nộp** (`onViewPendingAssignments`): Bài tập chưa nộp trong lớp này
- **Bài đã chấm** (`onViewGradedAssignments`): Bài tập đã được chấm trong lớp này
- **Lịch nộp bài** (`onViewAssignmentSchedule`): Lịch nộp bài của lớp này

**Lý do**: Mặc dù có thể có bài tập từ nhiều lớp, nhưng trong context của drawer này, học sinh đang ở trong một lớp cụ thể nên các bài tập được filter theo lớp đó.

### ⚠️ Có thể Class-Specific hoặc App-Wide (Cần xem xét)

#### 3. HỖ TRỢ
- **Liên hệ giáo viên** (`onContactTeacher`): Có thể là class-specific (liên hệ giáo viên của lớp này) hoặc app-wide (liên hệ giáo viên bất kỳ)
- **Báo cáo vấn đề** (`onReportIssue`): Thường là app-wide nhưng có thể bao gồm context của lớp hiện tại
- **Trung tâm trợ giúp** (`onOpenHelpCenter`): App-wide
- **Gửi phản hồi** (`onSendFeedback`): App-wide

**Đề xuất**: 
- Giữ "Liên hệ giáo viên" trong drawer này vì trong context của lớp học, học sinh muốn liên hệ giáo viên của lớp đó
- Các mục khác nên chuyển sang Settings/Profile screen chung

### ❌ App-Wide (Nên chuyển sang Settings/Profile screen)

#### 4. CÀI ĐẶT HIỂN THỊ
- **Chế độ tối** (`onChangeTheme`): Cài đặt cho toàn bộ ứng dụng
- **Cỡ chữ** (`onChangeTextSize`): Cài đặt cho toàn bộ ứng dụng
- **Màu sắc** (`onChangeTheme`): Cài đặt cho toàn bộ ứng dụng
- **Ngôn ngữ** (`onChangeLanguage`): Cài đặt cho toàn bộ ứng dụng

**Lý do**: Các cài đặt này ảnh hưởng đến toàn bộ ứng dụng, không chỉ riêng lớp học hiện tại.

## Kế hoạch refactor (Tương lai)

### Bước 1: Tạo App Settings Screen
- Tạo màn hình `AppSettingsScreen` hoặc thêm section vào Profile screen
- Di chuyển các cài đặt app-wide từ drawer sang đây

### Bước 2: Tinh gọn StudentClassSettingsDrawer
- Giữ lại:
  - THÔNG TIN LỚP HỌC
  - QUẢN LÝ BÀI TẬP
  - Liên hệ giáo viên (trong HỖ TRỢ)
- Loại bỏ:
  - CÀI ĐẶT HIỂN THỊ (chuyển sang App Settings)
  - Một số mục trong HỖ TRỢ (chuyển sang App Settings hoặc Help Center)

### Bước 3: Thêm link đến App Settings
- Thêm một tile ở cuối drawer: "Cài đặt ứng dụng" → điều hướng đến App Settings Screen

## Lưu ý
- Việc refactor này sẽ được thực hiện trong tương lai khi có App Settings Screen
- Hiện tại, drawer vẫn giữ nguyên để không ảnh hưởng đến UX hiện tại
- Khi refactor, cần đảm bảo các callback được migrate đúng cách
