# Hướng dẫn Debug và Test chức năng Xóa Lớp Học

## Tổng quan

File này cung cấp hướng dẫn chi tiết để debug và test chức năng xóa lớp học khi gặp vấn đề.

## Các cải thiện đã thực hiện

### 1. ✅ Cải thiện Error Handling trong UI (`class_settings_drawer.dart`)
- Thêm try-catch để bắt tất cả exceptions
- Hiển thị error message chi tiết với nút "Chi tiết"
- Thêm logging chi tiết ở mỗi bước
- Hiển thị SnackBar với duration dài hơn (5 giây) để user có thời gian đọc

### 2. ✅ Cải thiện Error Handling trong ViewModel (`class_viewmodel.dart`)
- Kiểm tra duplicate delete requests
- Phân loại và translate error messages rõ ràng hơn:
  - Lỗi 401: Lỗi xác thực
  - Lỗi 403: Không có quyền
  - Lỗi foreign key: Dữ liệu liên quan
  - Lỗi not found: Lớp học không tồn tại
- Clear error khi thành công
- Logging chi tiết ở mỗi bước

### 3. ✅ Cải thiện Error Handling trong Repository (`school_class_repository_impl.dart`)
- Log chi tiết về từng loại lỗi
- Hướng dẫn debug cho từng loại lỗi
- Error translation tốt hơn

### 4. ✅ Cải thiện Error Handling trong DataSource (`supabase_datasource.dart`)
- Kiểm tra authentication trước khi delete
- Kiểm tra response từ Supabase
- Throw exception nếu không có dòng nào bị xóa
- Log chi tiết về PostgrestException với code, message, details, hint

## Cách Test

### Bước 1: Kiểm tra Console Logs

Khi thử xóa lớp học, bạn sẽ thấy các log sau trong console:

```
🟢 [UI] deleteClass: Bắt đầu xóa lớp học {classId}
🟢 [UI] deleteClass: Tên lớp: {className}
🟢 [UI] deleteClass: Teacher ID: {teacherId}
🟢 [VIEWMODEL] deleteClass: Bắt đầu xóa lớp học {classId}
🟢 [REPO] deleteClass: Bắt đầu xóa lớp học {classId}
🟢 [REPO] deleteClass: Gọi datasource.deleteClass()
🟢 [DATASOURCE] delete: Bắt đầu xóa classes với id={classId}
🟢 [DATASOURCE] delete: Table: classes
🟢 [DATASOURCE] delete: ID: {classId}
🟢 [DATASOURCE] delete: User ID: {userId}
🟢 [DATASOURCE] delete: Gửi DELETE request đến Supabase...
```

### Bước 2: Kiểm tra các lỗi phổ biến

#### Lỗi 1: "Bạn cần đăng nhập để thực hiện thao tác này"
**Nguyên nhân:** User chưa đăng nhập hoặc session đã hết hạn

**Giải pháp:**
- Kiểm tra `_client.auth.currentUser` có null không
- Yêu cầu user đăng nhập lại

#### Lỗi 2: "Bạn không có quyền xóa lớp học này"
**Nguyên nhân:** 
- User không phải là teacher của lớp
- RLS policies chặn DELETE operation

**Giải pháp:**
- Kiểm tra `classItem.teacherId` có khớp với `auth.currentUser.id` không
- Kiểm tra RLS policies trong Supabase:
  ```sql
  -- Kiểm tra RLS có được enable không
  SELECT tablename, rowsecurity 
  FROM pg_tables 
  WHERE schemaname = 'public' AND tablename = 'classes';
  
  -- Kiểm tra policies
  SELECT * FROM pg_policies WHERE tablename = 'classes';
  ```

#### Lỗi 3: "Không thể xóa dữ liệu. Có thể bạn không có quyền hoặc dữ liệu không tồn tại."
**Nguyên nhân:** 
- Response từ Supabase là empty list (không có dòng nào bị xóa)
- Có thể do RLS policies hoặc dữ liệu không tồn tại

**Giải pháp:**
- Kiểm tra xem lớp học có tồn tại trong database không:
  ```sql
  SELECT * FROM classes WHERE id = '{classId}';
  ```
- Kiểm tra RLS policies có cho phép DELETE không

#### Lỗi 4: "Lỗi foreign key - Có dữ liệu liên quan"
**Nguyên nhân:** 
- Có foreign key constraints chưa được xử lý
- Mặc dù có ON DELETE CASCADE, nhưng có thể có vấn đề

**Giải pháp:**
- Kiểm tra foreign key constraints:
  ```sql
  SELECT 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
  FROM information_schema.table_constraints AS tc 
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
  JOIN information_schema.referential_constraints AS rc
    ON rc.constraint_name = tc.constraint_name
  WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND ccu.table_name = 'classes';
  ```

### Bước 3: Test với Supabase SQL Editor

Chạy trực tiếp SQL để test:

```sql
-- 1. Kiểm tra lớp học có tồn tại không
SELECT id, name, teacher_id FROM classes WHERE id = '{classId}';

-- 2. Kiểm tra user hiện tại
SELECT auth.uid() as current_user_id;

-- 3. Test DELETE trực tiếp (với service role key)
DELETE FROM classes WHERE id = '{classId}';
```

Nếu DELETE SQL thành công nhưng code không thành công → vấn đề là RLS/authentication.

### Bước 4: Kiểm tra RLS Policies

Nếu RLS được enable, bạn cần tạo policy cho DELETE:

```sql
-- Enable RLS
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Tạo policy cho phép teacher xóa lớp của mình
CREATE POLICY "Teachers can delete own classes"
ON classes
FOR DELETE
USING (auth.uid() = teacher_id);
```

### Bước 5: Kiểm tra Authentication

Đảm bảo user đã đăng nhập và JWT token hợp lệ:

```dart
final user = Supabase.instance.client.auth.currentUser;
print('User ID: ${user?.id}');
print('User Email: ${user?.email}');
print('Session: ${Supabase.instance.client.auth.currentSession}');
```

## Checklist Debug

Khi gặp vấn đề, kiểm tra theo thứ tự:

- [ ] User đã đăng nhập chưa? (`auth.currentUser != null`)
- [ ] User có phải là teacher của lớp không? (`classItem.teacherId == auth.currentUser.id`)
- [ ] Lớp học có tồn tại trong database không?
- [ ] RLS có được enable không? Nếu có, có policy cho DELETE không?
- [ ] Console logs có hiển thị lỗi gì không?
- [ ] Error message trong SnackBar là gì?
- [ ] Có thể DELETE bằng SQL Editor không?

## Các file đã được cải thiện

1. `lib/widgets/drawers/class_settings_drawer.dart`
   - Thêm try-catch và error handling tốt hơn
   - Hiển thị error dialog với chi tiết
   - Logging chi tiết

2. `lib/presentation/viewmodels/class_viewmodel.dart`
   - Phân loại và translate errors
   - Kiểm tra duplicate requests
   - Logging chi tiết

3. `lib/data/repositories/school_class_repository_impl.dart`
   - Log chi tiết về từng loại lỗi
   - Hướng dẫn debug

4. `lib/data/datasources/supabase_datasource.dart`
   - Kiểm tra authentication
   - Kiểm tra response
   - Log chi tiết về PostgrestException

## Kết quả mong đợi

Sau khi cải thiện, khi test xóa lớp học:

1. **Thành công:**
   - Console hiển thị các log ✅
   - Loading dialog hiển thị
   - SnackBar hiển thị "Đã xóa lớp học thành công"
   - Navigate về màn hình trước
   - Lớp học biến mất khỏi danh sách

2. **Thất bại:**
   - Console hiển thị các log 🔴 với chi tiết lỗi
   - SnackBar hiển thị error message rõ ràng
   - Có thể click "Chi tiết" để xem error message đầy đủ
   - Error message được translate sang tiếng Việt và dễ hiểu

## Ghi chú

- Tất cả logs đều có prefix để dễ filter: `[UI]`, `[VIEWMODEL]`, `[REPO]`, `[DATASOURCE]`
- Error messages được translate sang tiếng Việt
- Có thể dùng console logs để trace toàn bộ flow từ UI → ViewModel → Repository → DataSource
