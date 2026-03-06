# Teacher Assignment Submissions Screen

## 1. Context & Mục tiêu
- **Mục tiêu**: Màn hình danh sách bài làm của học sinh cho một bài tập cụ thể.
- **Context**: Giúp giáo viên theo dõi tiến độ nộp bài của cả lớp, phân loại theo trạng thái (Đã nộp, Chưa nộp, Đã chấm).

## 2. Luồng Flow (User Flow)
- Từ `TeacherAssignmentDetailScreen` -> Click xem bài nộp -> Mở `TeacherAssignmentSubmissionsScreen`.
- Tại đây hiển thị danh sách học sinh kèm trạng thái nộp bài.
- Click vào một học sinh -> Mở `TeacherAssignmentGradingScreen` để chấm điểm.

## 3. UI/UX Design (Giao diện mẫu)
*(User sẽ cung cấp giao diện mẫu và cấu trúc UI chi tiết ở đây)*
- ...

## 4. Kỹ thuật & Công nghệ áp dụng
- **State Management**: Riverpod (`classMembers` kết hợp với `submissions` để map dữ liệu học sinh).
- **Widgets**: Sử dụng list hiển thị kèm ShimmerLoading khi tải data.
- **Architecture**: Tuân thủ Design Tokens của hệ thống.
