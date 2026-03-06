# Teacher Assignment Detail Screen

## 1. Context & Mục tiêu
- **Mục tiêu**: Màn hình tổng quan khi giáo viên click vào một bài tập đã giao từ màn hình chi tiết lớp học (`TeacherClassDetailScreen`).
- **Context**: Hiển thị thông tin chung của bài tập (mô tả, đính kèm, hạn nộp) và thống kê nhanh (số lượng đã nộp, chưa nộp, đã chấm).

## 2. Luồng Flow (User Flow)
- Từ `TeacherClassDetailScreen` -> Click môt bài tập -> Mở `TeacherAssignmentDetailScreen`.
- Từ màn hình này, có thể click xem danh sách bài làm của học sinh -> Mở `TeacherAssignmentSubmissionsScreen`.
- Có thể chỉnh sửa bài tập hoặc thay đổi hạn nộp (tuỳ thuộc vào quyền).

## 3. UI/UX Design (Tổng hợp từ 2 mẫu)

Giao diện sẽ là sự kết hợp của 2 màn hình quản lý bài tập, bao gồm các section chính sau đây (từ trên xuống dưới):

### 3.1. Header & Quick Stats (Từ mẫu "Theo dõi")
- **App Bar**: Tên bài tập (vd: "Kiểm tra Giải tích") kèm tên lớp ("12A1"). Nút Back và Menu (more_horiz).
- **Thống kê nhanh (4 Cards lưới 2x2)**:
  - **Sĩ số**: Tổng số học sinh (icon groups).
  - **Đã nộp**: Số HS đã nộp (icon check_circle màu xanh lá).
  - **Chưa nộp**: Số HS chưa hoặc trễ hạn (icon pending màu xám/đỏ).
  - **Điểm TB**: Điểm trung bình của các bài đã chấm (icon analytics màu xanh dương).

### 3.2. Action Buttons (Từ mẫu "Theo dõi")
- Hàng nút thao tác cuộn ngang (Scrollable Row):
  - **Xem đề bài** (icon visibility)
  - **Sửa đề** (icon edit_document)
  - **Cấu hình** (icon settings)

### 3.3. Cấu hình bài tập (Từ mẫu "Cấu hình")
- Một Card "Cấu hình bài tập" (có nút Chỉnh sửa):
  - **Hạn nộp bài**: Ngày giờ cụ thể + Countdown (vd: "Còn 2 ngày 14 giờ").
  - Divider ngang.
  - **Thời gian**: Thời lượng làm bài (vd: "45 phút").
  - **Thang điểm**: Ví dụ "10.0".

### 3.4. Highlights & Leaderboard (Từ mẫu "Cấu hình")
#### 3.4.1. Nộp bài sớm nhất (Top 3)
- Tiêu đề có icon cup vàng. Có link "Xem tất cả".
- Hiển thị danh sách ngang gồm Top 3 học sinh nộp sớm nhất:
  - Avatar có badge thứ hạng (1, 2, 3).
  - Tên học sinh.
  - Điểm số (nếu đã chấm).
- Nút "Thêm" (Nút tròn đứt nét) để xem thêm nếu cần.

#### 3.4.2. Cần chú ý (Warning Section)
- Block nền đỏ nhạt để cảnh báo các vấn đề cần xử lý ngay:
  - Học sinh chưa nộp bài nhưng sắp tới hạn (kèm nút "Nhắc nhở").
  - Học sinh có điểm thấp cần hỗ trợ (kèm nút "Chi tiết").

### 3.5. Trạng thái tải dữ liệu (Loading/Shimmer)
- **Khi mới vào màn hình**: Hiển thị `ShimmerClassDetailLoading` hoặc xây dựng một `ShimmerAssignmentDetailLoading` riêng biệt với cấu trúc tương đồng UI trang này (skeleton cho stat cards, action buttons, config card).
- **Smooth Transitions**: Các hiệu ứng fade-in mượt mà khi data load xong thay thế shimmer. Đảm bảo trải nghiệm shimmer mượt mà, không bị giật UI lúc state switch từ `loading` qua `data`.

## 4. Kỹ thuật & Công nghệ áp dụng
- **State Management**: Riverpod (Providers để fetch chi tiết assignment).
- **Routing**: GoRouter (truyền ID của assignment và class qua params/extra).
- **Architecture**: Sử dụng các Design Tokens từ hệ thống, duy trì Clean Architecture.
