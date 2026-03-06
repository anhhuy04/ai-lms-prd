# Teacher Assignment Grading Screen

## 1. Context & Mục tiêu
- **Mục tiêu**: Màn hình chi tiết chấm điểm một bài nộp của học sinh.
- **Context**: Giáo viên xem nội dung học sinh đã nộp (file, text), nhập điểm và nhận xét (feedback).

## 2. Luồng Flow (User Flow)
- Từ `TeacherAssignmentSubmissionsScreen` -> Chọn một học sinh -> Mở `TeacherAssignmentGradingScreen`.
- Nhập điểm số, viết feedback -> Nhấn "Lưu" hoặc "Lưu & Xem bài tiếp theo".

## 3. UI/UX Design (Giao diện mẫu)
*(User sẽ cung cấp giao diện mẫu và cấu trúc UI chi tiết ở đây)*
- ...

## 4. Kỹ thuật & Công nghệ áp dụng
- **Data Layer**: API gọi mutate state cập nhật điểm và feedback.
- **State Management**: Riverpod (Cập nhật local state sau khi chấm xong để UI danh sách reflect ngay lập tức).
- **Architecture**: Xử lý error handling khi chấm lỗi, hiện thị bottom sheet/snackbar thông báo.
