# 🧪 Hướng Dẫn Test Chức Năng Xóa Lớp Học

## 📋 Tóm Tắt Cải Thiện

Các fix đã thực hiện cho chức năng xóa lớp học:

### ✅ Cải Thiện Chính:
1. **Sửa lỗi context handling** - Lưu context an toàn khi pop dialog
2. **Thêm kiểm tra mounted** - Đảm bảo context còn hợp lệ trước khi sử dụng
3. **Thêm delay sau navigation** - Cho phép navigation hoàn tất trước khi show snackbar
4. **Cải thiện error messages** - Thêm emoji và định dạng rõ ràng hơn
5. **Xử lý case hủy thao tác** - Log khi user hủy xóa

---

## 🚀 Các Bước Test

### Bước 1: Chuẩn Bị

1. Mở ứng dụng trên emulator/device
2. Đăng nhập với tài khoản teacher
3. Tạo một lớp học test (hoặc dùng lớp cũ)
4. Mở Flutter DevTools hoặc View → Debug Area trong VS Code để xem logs

### Bước 2: Test Xóa Thành Công

**Kịch bản:** Xóa một lớp học không có học sinh

#### Các bước:
1. Mở một lớp học đã tạo
2. Click menu ⋮ → Xóa lớp học
3. Click "Xóa" trong confirmation dialog
4. Quan sát loading indicator
5. Kiểm tra kết quả

#### Kết quả mong đợi:
```
Console logs:
🟢 [UI] deleteClass: Bắt đầu xóa lớp học {classId}
🟢 [VIEWMODEL] deleteClass: Bắt đầu xóa lớp học {classId}
🟢 [REPO] deleteClass: Bắt đầu xóa lớp học {classId}
🟢 [DATASOURCE] delete: Bắt đầu xóa classes với id={classId}
✅ [UI] deleteClass: Xóa thành công

UI:
- Loading indicator hiển thị 1-2 giây
- Tự động quay lại màn hình danh sách lớp
- SnackBar xanh: "✅ Đã xóa lớp học thành công"
- Lớp học biến mất khỏi danh sách
```

---

### Bước 3: Test Xóa Thất Bại (Không Có Quyền)

**Kịch bản:** Thử xóa lớp của giáo viên khác

#### Các bước:
1. Mở một lớp học của giáo viên khác
2. Click menu ⋮ → Xóa lớp học
3. Quan sát kết quả

#### Kết quả mong đợi:
```
Console logs:
🔴 [VIEWMODEL ERROR] deleteClass: Lỗi 403 - Không có quyền xóa
🔴 [UI] deleteClass: Xóa thất bại

UI:
- Loading indicator đóng
- SnackBar đỏ: "❌ Lỗi xác thực: ..."
- Có nút "Chi tiết" để xem error message đầy đủ
```

---

### Bước 4: Test Xóa Lớp Có Học Sinh

**Kịch bản:** Xóa lớp có nhiều học sinh (test cascade delete)

#### Các bước:
1. Tạo lớp học mới
2. Thêm 3-5 học sinh vào lớp
3. Click menu ⋮ → Xóa lớp học
4. Kiểm tra confirmation dialog hiển thị số lượng học sinh
5. Click "Xóa"

#### Kết quả mong đợi:
```
Confirmation Dialog:
- Tiêu đề: "Xác nhận xóa lớp học"
- Nội dung: "Bạn có chắc chắn muốn xóa lớp 'Tên Lớp'?"
- Hộp cảnh báo hiển thị:
  • 5 học sinh đã được duyệt
  • Tất cả nhóm học tập và bài tập liên quan
- "Hành động này không thể hoàn tác."

Sau khi xóa:
- Lớp học bị xóa
- Tất cả học sinh liên quan bị xóa khỏi class_members table
- SnackBar thành công hiển thị
```

---

### Bước 5: Test Hủy Thao Tác

**Kịch bản:** User thay đổi ý định

#### Các bước:
1. Mở confirmation dialog
2. Click "Hủy"

#### Kết quả mong đợi:
```
Console logs:
🟡 [UI] deleteClass: User đã hủy thao tác xóa

UI:
- Dialog đóng
- Drawer vẫn ở lại hoặc đóng (tùy thiết kế)
- Không có thay đổi gì
```

---

### Bước 6: Test Với Lỗi Network

**Kịch bản:** Connection bị mất trong quá trình xóa

#### Các bước:
1. Bật chế độ Flight Mode sau khi click "Xóa" (loading đang hiển thị)
2. Quan sát kết quả

#### Kết quả mong đợi:
```
Console logs:
🔴 [DATASOURCE ERROR] delete: PostgrestException
🔴 [UI] deleteClass: Xóa thất bại

UI:
- Loading indicator đóng
- SnackBar đỏ: "❌ Lỗi kết nối mạng: ..."
- Lớp học KHÔNG bị xóa (cần refresh để xác nhận)
```

---

## 🔍 Kiểm Tra Chi Tiết Logs

### Logs Thành Công:
```
✅ [DATASOURCE] delete: Đã xóa 1 dòng thành công
✅ [VIEWMODEL] deleteClass: Hoàn tất xóa lớp học {classId}
✅ [UI] deleteClass: Xóa thành công
```

### Logs Thất Bại (Lỗi 401 - Không đăng nhập):
```
⚠️ [DATASOURCE] delete: User chưa đăng nhập!
🔴 [VIEWMODEL ERROR] deleteClass: Lỗi 401 - Kiểm tra authentication và RLS policies
🔴 [UI] deleteClass: Xóa thất bại
```

### Logs Thất Bại (Lỗi 403 - Không có quyền):
```
⚠️ [DATASOURCE ERROR] delete: Lỗi permission - RLS policy chặn DELETE
🔴 [VIEWMODEL ERROR] deleteClass: Lỗi 403 - Không có quyền xóa
🔴 [UI] deleteClass: Xóa thất bại
```

### Logs Thất Bại (Foreign Key):
```
⚠️ [DATASOURCE ERROR] delete: Lỗi foreign key constraint
🔴 [VIEWMODEL ERROR] deleteClass: Lỗi foreign key - Có dữ liệu liên quan
🔴 [UI] deleteClass: Xóa thất bại
```

---

## 🛠️ Troubleshooting

### Vấn đề: Loading indicator không biến mất

**Nguyên nhân:** Context invalid hoặc Navigator.pop() không thành công

**Giải pháp:**
1. Kiểm tra logs: có "Context không còn valid" không?
2. Restart app
3. Kiểm tra xem có lỗi nào ở tầng ViewModel/Repository không

---

### Vấn đề: SnackBar không hiển thị

**Nguyên nhân:** Context bị pop quá nhanh

**Giải pháp:**
1. Code đã thêm delay `Future.delayed(const Duration(milliseconds: 300))`
2. Nếu vẫn không hiển thị, check logs để xem có error gì
3. Kiểm tra xem ScaffoldMessenger có hợp lệ không

---

### Vấn đề: Lớp học không bị xóa dù hiển thị thành công

**Nguyên nhân:** 
- Local state bị cập nhật nhưng database chưa xóa thực sự
- Hoặc RLS policies chặn DELETE

**Giải pháp:**
1. Check Supabase database xem lớp có còn không
2. Nếu lớp vẫn tồn tại → vấn đề là RLS policies
3. Nếu lớp đã xóa nhưng UI hiển thị sai → vấn đề là state management

---

### Vấn đề: Context Invalid Error

**Lỗi:** "setState called after dispose" hoặc "The widget is not mounted"

**Nguyên nhân:** Context bị pop ra khỏi widget tree

**Giải pháp:**
1. Code đã kiểm tra `context.mounted` trước khi sử dụng context
2. Nếu vẫn gặp lỗi:
   - Lưu context lại trước khi await
   - Kiểm tra xem có `Navigator.pop()` quá nhiều lần không

---

## ✅ Checklist Test Hoàn Chỉnh

- [ ] Test xóa thành công (lớp không có học sinh)
- [ ] Test xóa thành công (lớp có 5-10 học sinh)
- [ ] Test xóa thất bại (không có quyền)
- [ ] Test hủy thao tác
- [ ] Test với network error
- [ ] Test loading indicator hiển thị/ẩn đúng
- [ ] Test SnackBar hiển thị đúng
- [ ] Test logs console đầy đủ
- [ ] Test error dialog "Chi tiết" hoạt động
- [ ] Test navigation quay lại danh sách lớp
- [ ] Test lớp học xóa khỏi danh sách
- [ ] Test database: lớp học không còn trong database
- [ ] Test database: class_members bị xóa cascade
- [ ] Test database: groups bị xóa cascade

---

## 📱 Test Trên Device Thực

1. Build release APK: `flutter build apk --release`
2. Install trên device: `flutter install --release`
3. Mở app
4. Thực hiện tất cả test steps ở trên
5. Kiểm tra logs trong logcat: `adb logcat | grep -i deleteClass`

---

## 📊 Kết Quả Dự Kiến

| Test Case | Input | Kết Quả Mong Đợi | Status |
|-----------|-------|------------------|--------|
| Xóa thành công (no students) | Click Xóa | ✅ Thành công | ⬜ |
| Xóa thành công (with students) | Click Xóa + 5 students | ✅ Thành công, cascade delete | ⬜ |
| Xóa thất bại (no permission) | Click Xóa | ❌ Lỗi 403 | ⬜ |
| Hủy thao tác | Click Hủy | ⏸️ Dialog đóng, không xóa | ⬜ |
| Network error | Flight Mode | ❌ Lỗi kết nối | ⬜ |
| Loading indicator | During delete | ⏳ Visible then hidden | ⬜ |
| SnackBar messages | After delete | ✅ Correct message shown | ⬜ |
| Database state | After delete | ✅ Lớp xóa khỏi DB | ⬜ |

---

## 🎯 Kết Luận

Nếu tất cả test cases đều pass ✅, chức năng xóa lớp học hoạt động chính xác!

Nếu có bất kỳ test case nào fail ❌, vui lòng:
1. Kiểm tra logs console
2. Kiểm tra Supabase database
3. Kiểm tra RLS policies
4. Liên hệ để debug thêm

---

**Ngày tạo:** 16/01/2026  
**Phiên bản:** 1.0  
**Trạng thái:** ✅ Sẵn sàng test
