# Phân tích lỗi không xóa được lớp học

## Kết quả kiểm tra từ MCP Supabase

### 1. ✅ Database Schema
- **Foreign Keys**: Tất cả đều có `ON DELETE CASCADE`:
  - `class_members.class_id` → `classes.id` (CASCADE)
  - `class_teachers.class_id` → `classes.id` (CASCADE)
  - `groups.class_id` → `classes.id` (CASCADE)
- **RLS**: Không được enable (`rls_enabled: false`)
- **RLS Policies**: Không có policies nào trên bảng `classes`

### 2. ✅ Test SQL DELETE
- **Kết quả**: DELETE hoạt động bình thường khi chạy trực tiếp SQL
- **Kết luận**: Không có vấn đề về database constraints

### 3. ⚠️ API Logs
- **Quan sát**: Không thấy request DELETE nào trong logs API
- **Có thể**: 
  - Code không thực sự gọi delete
  - Hoặc có lỗi trước khi gọi API
  - Hoặc request bị chặn ở tầng authentication

### 4. ⚠️ Security Advisors
- **Cảnh báo**: Tất cả bảng public đều có RLS disabled
- **Lưu ý**: Mặc dù RLS disabled, nhưng có thể có policies được định nghĩa nhưng chưa enable

## Nguyên nhân có thể

### 1. **RLS Policies chưa được enable nhưng đã được định nghĩa**
- Có thể có policies được tạo nhưng RLS chưa enable
- Khi RLS disabled, policies không hoạt động, nhưng có thể có vấn đề khác

### 2. **Authentication/Authorization issue**
- User có thể không có quyền DELETE
- JWT token có thể thiếu claims cần thiết
- Service role key có thể cần thiết

### 3. **Error không được catch/handle đúng cách**
- Lỗi có thể xảy ra nhưng không được log
- Error message có thể không được hiển thị

### 4. **PostgREST API issue**
- Có thể có vấn đề với PostgREST configuration
- Có thể cần check API permissions

## Giải pháp đề xuất

### Giải pháp 1: Kiểm tra và enable RLS với policies đúng
```sql
-- Enable RLS
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Tạo policy cho phép teacher xóa lớp của mình
CREATE POLICY "Teachers can delete own classes"
ON classes
FOR DELETE
USING (auth.uid() = teacher_id);
```

### Giải pháp 2: Kiểm tra authentication trong code
- Đảm bảo user đã đăng nhập
- Kiểm tra JWT token có hợp lệ không
- Kiểm tra user có phải là teacher của lớp không

### Giải pháp 3: Cải thiện error handling
- Log chi tiết hơn trong repository
- Hiển thị error message cụ thể cho user
- Thêm try-catch ở nhiều tầng

### Giải pháp 4: Test với service role key
- Thử xóa với service role key để bypass RLS
- Nếu thành công → vấn đề là RLS/authentication
- Nếu vẫn lỗi → vấn đề là database constraints

## Code cần kiểm tra

1. **lib/data/datasources/supabase_datasource.dart** (line 311-328)
   - Method `delete()` có error handling đầy đủ
   - Cần kiểm tra xem có throw exception không

2. **lib/data/datasources/school_class_datasource.dart** (line 115-117)
   - Gọi `_classesDataSource.delete(classId)`
   - Cần kiểm tra xem có lỗi gì không

3. **lib/data/repositories/school_class_repository_impl.dart** (line 87-95)
   - Error translation có thể che giấu lỗi thực sự
   - Cần log chi tiết hơn

4. **lib/presentation/viewmodels/class_viewmodel.dart** (line 292-318)
   - Return `false` khi có lỗi
   - Error message có thể không đầy đủ

## Bước tiếp theo

1. ✅ Kiểm tra logs trong app khi thử xóa
2. ✅ Thêm logging chi tiết hơn trong delete flow
3. ✅ Test với một lớp học cụ thể
4. ✅ Kiểm tra authentication state khi xóa
5. ⚠️ Kiểm tra xem có RLS policies nào được định nghĩa không (ngay cả khi RLS disabled)
