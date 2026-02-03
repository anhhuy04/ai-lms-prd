# Hướng Dẫn Test Chức Năng Assignment Creation

## Test Script Đã Tạo

File `test/temp_test_save_assignment_draft.dart` đã được tạo nhưng không thể chạy trong unit test environment (cần platform channels). 

## Cách Test Thủ Công Từ UI

### Bước 1: Chuẩn Bị
1. Đảm bảo app đã được build và chạy
2. Đăng nhập với tài khoản giáo viên
3. Navigate đến màn hình tạo bài tập

### Bước 2: Test Create Assignment & Save Draft

1. **Tạo Assignment Mới:**
   - Mở màn hình tạo bài tập
   - Nhập tiêu đề: "Test Assignment - Draft"
   - Nhập mô tả: "This is a test assignment"
   - Chọn ngày hết hạn (tương lai)
   - Chọn thời gian làm bài: 45 phút

2. **Thêm Câu Hỏi:**
   - Click nút "Thêm câu hỏi" (FAB)
   - Chọn "Trắc nghiệm"
   - Nhập câu hỏi: "What is 2 + 2?"
   - Thêm 4 options với 1 đáp án đúng
   - Save câu hỏi
   - Thêm thêm 1-2 câu hỏi nữa (tự luận hoặc trắc nghiệm)

3. **Thiết Lập Điểm:**
   - Trong phần "THANG ĐIỂM", nhập điểm cho từng loại câu hỏi
   - Verify tổng điểm hiển thị đúng

4. **Save Draft:**
   - Mở drawer (click nút 3 chấm hoặc FAB)
   - Click nút "Lưu bản nháp"
   - Verify:
     - Loading indicator xuất hiện
     - SnackBar hiển thị "Đã lưu bản nháp thành công!"
     - Assignment ID được lưu (có thể check trong logs)

5. **Verify Database:**
   - Mở Supabase Dashboard
   - Check bảng `assignments`:
     - Tìm assignment với title "Test Assignment - Draft"
     - Verify `is_published = false`
     - Verify `teacher_id` đúng với user hiện tại
   - Check bảng `assignment_questions`:
     - Verify có đúng số lượng questions
     - Verify `order_idx` đúng thứ tự
     - Verify `custom_content` chứa đúng data

### Bước 3: Test Edit Draft & Save Again

1. **Edit Assignment:**
   - Thay đổi tiêu đề: "Test Assignment - Draft Updated"
   - Thêm/sửa/xóa câu hỏi
   - Thay đổi điểm

2. **Save Draft Lần 2:**
   - Click "Lưu bản nháp" lại
   - Verify:
     - Không tạo assignment mới (dùng assignment ID cũ)
     - Data được update đúng

3. **Verify Database:**
   - Check `assignments` table: title đã được update
   - Check `assignment_questions`: questions đã được replace đúng

### Bước 4: Test Publish Assignment

1. **Publish:**
   - Đảm bảo assignment đã có ít nhất 1 câu hỏi
   - Mở drawer
   - Click "Lưu & Xuất bản"
   - Verify:
     - Loading indicator xuất hiện
     - SnackBar hiển thị "Đã xuất bản bài tập thành công!"
     - Màn hình tự động quay lại (context.pop())

2. **Verify Database:**
   - Check `assignments` table:
     - `is_published = true`
     - `published_at` có giá trị (timestamp)
   - Check `assignment_questions`: vẫn còn đúng data

### Bước 5: Test Error Cases

1. **Validation Errors:**
   - Thử save với title rỗng → Verify error message
   - Thử save với không có câu hỏi → Verify error message
   - Thử publish với due date trong quá khứ → Verify error message

2. **Network Errors:**
   - Tắt internet
   - Thử save → Verify error message hiển thị

3. **Loading States:**
   - Khi đang save, verify:
     - Buttons bị disable
     - Loading indicator hiển thị
     - Không thể thực hiện action khác

### Bước 6: Test Data Persistence

1. **Restart App:**
   - Save draft một assignment
   - Close app
   - Mở lại app
   - Navigate đến assignment list
   - Verify assignment vẫn còn trong database

2. **Verify Assignment Details:**
   - Mở assignment detail screen
   - Verify tất cả data hiển thị đúng:
     - Title, description
     - Questions với đúng order
     - Points đúng

## Checklist Test

- [ ] Create new assignment và save draft thành công
- [ ] Edit assignment và save draft lại thành công
- [ ] Publish assignment thành công
- [ ] Data được lưu đúng trong database
- [ ] Questions được lưu đúng với order_idx
- [ ] Loading states hoạt động đúng
- [ ] Error messages hiển thị rõ ràng (tiếng Việt)
- [ ] Validation hoạt động đúng
- [ ] Data persist qua app restart
- [ ] RLS policies được enforce (teacher chỉ thấy assignments của mình)

## Notes

- Test script `temp_test_save_assignment_draft.dart` có thể được sử dụng để test programmatically nếu có môi trường test phù hợp
- Tất cả test data sẽ được cleanup tự động hoặc có thể xóa thủ công từ Supabase Dashboard
