# Báo Cáo Kiểm Tra RLS và Database Constraints - Chức Năng Xóa Lớp Học

**Ngày kiểm tra:** $(date)  
**Công cụ:** Supabase MCP Server

---

## 📋 Tổng Quan

Đã kiểm tra toàn bộ RLS policies, foreign key constraints, và triggers trên bảng `classes` để xác định nguyên nhân không thể xóa lớp học.

---

## ✅ Kết Quả Kiểm Tra

### 1. Row Level Security (RLS)

**Trạng thái:** ❌ **RLS DISABLED**

```sql
SELECT schemaname, tablename, rowsecurity as rls_enabled
FROM pg_tables 
WHERE schemaname = 'public' AND tablename = 'classes';

-- Kết quả:
-- rls_enabled: false
```

**Kết luận:** 
- ✅ **RLS đang TẮT** → Không có RLS policies nào chặn DELETE operation
- ⚠️ **Cảnh báo bảo mật:** Security advisors khuyến nghị enable RLS cho bảng public

### 2. RLS Policies

**Số lượng policies:** 0

```sql
SELECT * FROM pg_policies 
WHERE schemaname = 'public' AND tablename = 'classes';

-- Kết quả: [] (rỗng)
```

**Kết luận:**
- ✅ **Không có policies nào** → Không có policy nào chặn DELETE

### 3. Foreign Key Constraints

**Tổng số constraints liên quan:** 4

| Child Table | Column | Parent Table | Delete Rule | Constraint Name |
|-------------|--------|--------------|-------------|-----------------|
| `class_members` | `class_id` | `classes` | **CASCADE** | `class_members_class_id_fkey` |
| `class_teachers` | `class_id` | `classes` | **CASCADE** | `class_teachers_class_id_fkey` |
| `groups` | `class_id` | `classes` | **CASCADE** | `groups_class_id_fkey` |
| `classes` | `school_id` | `schools` | **NO ACTION** | `classes_school_id_fkey` |

**Phân tích:**

✅ **CASCADE constraints (3):**
- `class_members.class_id` → `classes.id` (CASCADE)
- `class_teachers.class_id` → `classes.id` (CASCADE)  
- `groups.class_id` → `classes.id` (CASCADE)

→ Khi xóa lớp học, các bản ghi liên quan sẽ **tự động bị xóa** (không chặn DELETE)

⚠️ **NO ACTION constraint (1):**
- `classes.school_id` → `schools.id` (NO ACTION)

→ **KHÔNG chặn DELETE** vì:
- `school_id` là **nullable** (có thể NULL)
- Nếu `school_id` là NULL → không có ràng buộc
- Nếu `school_id` có giá trị → chỉ chặn nếu `schools.id` không tồn tại (nhưng đây là constraint từ classes → schools, không ảnh hưởng DELETE classes)

**Kết luận:**
- ✅ **Foreign keys KHÔNG chặn DELETE operation**

### 4. Triggers

**Số lượng triggers:** 0

```sql
SELECT * FROM information_schema.triggers
WHERE event_object_table = 'classes' AND event_object_schema = 'public';

-- Kết quả: [] (rỗng)
```

**Kết luận:**
- ✅ **Không có triggers nào** → Không có trigger nào chặn DELETE

---

## 🔍 Nguyên Nhân Có Thể

Vì **KHÔNG có RLS policies, foreign keys, hoặc triggers nào chặn DELETE**, vấn đề có thể nằm ở:

### 1. ⚠️ Authentication Issue (Khả năng cao)

**Triệu chứng:**
- User chưa đăng nhập
- JWT token hết hạn
- Session không hợp lệ

**Kiểm tra:**
```dart
final user = Supabase.instance.client.auth.currentUser;
print('User: ${user?.id}');
print('Session: ${Supabase.instance.client.auth.currentSession}');
```

**Giải pháp:**
- Đảm bảo user đã đăng nhập
- Refresh session nếu cần
- Kiểm tra JWT token có hợp lệ không

### 2. ⚠️ PostgREST API Issue

**Triệu chứng:**
- Request không đến được Supabase
- Response empty hoặc null
- Network error

**Kiểm tra:**
- Xem console logs trong app
- Kiểm tra network requests trong DevTools
- Xem Supabase API logs

### 3. ⚠️ Code Logic Issue

**Triệu chứng:**
- Error không được catch đúng cách
- Response được xử lý sai
- State không được update

**Kiểm tra:**
- Xem console logs với prefix `[UI]`, `[VIEWMODEL]`, `[REPO]`, `[DATASOURCE]`
- Kiểm tra error messages trong SnackBar
- Trace toàn bộ flow từ UI → ViewModel → Repository → DataSource

---

## 🛠️ Giải Pháp Đề Xuất

### Giải pháp 1: Kiểm tra Authentication (Ưu tiên cao)

Thêm validation trong code trước khi DELETE:

```dart
// Trong DataSource hoặc Repository
final user = _client.auth.currentUser;
if (user == null) {
  throw Exception('Bạn cần đăng nhập để thực hiện thao tác này');
}
```

### Giải pháp 2: Test với SQL trực tiếp

Chạy SQL trực tiếp trong Supabase SQL Editor để xác nhận DELETE hoạt động:

```sql
-- Lấy một class ID để test
SELECT id, name, teacher_id FROM classes LIMIT 1;

-- Test DELETE (thay {classId} bằng ID thực tế)
DELETE FROM classes WHERE id = '{classId}';
```

**Nếu SQL thành công nhưng code không thành công:**
→ Vấn đề là **authentication/authorization** hoặc **PostgREST API**

**Nếu SQL cũng thất bại:**
→ Vấn đề là **database constraints** (nhưng đã kiểm tra và không có)

### Giải pháp 3: Enable RLS với Policies đúng (Khuyến nghị cho Production)

Mặc dù RLS đang tắt, nhưng để bảo mật, nên enable RLS với policies:

```sql
-- Enable RLS
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;

-- Policy cho phép teacher xóa lớp của mình
CREATE POLICY "Teachers can delete own classes"
ON classes
FOR DELETE
USING (auth.uid() = teacher_id);

-- Policy cho phép đọc (nếu chưa có)
CREATE POLICY "Anyone can read classes"
ON classes
FOR SELECT
USING (true);
```

**Lưu ý:** Sau khi enable RLS, cần test lại để đảm bảo policies hoạt động đúng.

---

## 📊 Tóm Tắt

| Kiểm tra | Trạng thái | Kết luận |
|----------|-----------|----------|
| RLS Enabled | ❌ Disabled | ✅ Không chặn DELETE |
| RLS Policies | 0 policies | ✅ Không chặn DELETE |
| Foreign Keys | 4 constraints (3 CASCADE, 1 NO ACTION) | ✅ Không chặn DELETE |
| Triggers | 0 triggers | ✅ Không chặn DELETE |

**Kết luận chính:**
- ✅ **Database constraints KHÔNG chặn DELETE operation**
- ⚠️ **Vấn đề có thể là Authentication, PostgREST API, hoặc Code Logic**
- 🔍 **Cần kiểm tra console logs và error messages để xác định nguyên nhân cụ thể**

---

## 📝 Bước Tiếp Theo

1. ✅ Kiểm tra console logs khi thử xóa lớp học
2. ✅ Xem error message trong SnackBar (click "Chi tiết" nếu có)
3. ✅ Kiểm tra authentication state (`auth.currentUser`)
4. ✅ Test DELETE với SQL trực tiếp trong Supabase SQL Editor
5. ⚠️ Nếu cần, enable RLS với policies đúng cho production

---

## 🔗 Tài Liệu Tham Khảo

- [Supabase RLS Documentation](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Supabase Security Advisors](https://supabase.com/docs/guides/database/database-linter)
- [Class Delete Debugging Guide](./debugging-guide.md)
