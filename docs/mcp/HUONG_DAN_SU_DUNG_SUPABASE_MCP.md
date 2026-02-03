# Hướng dẫn sử dụng Supabase MCP để lấy thông tin Tables

## Tình trạng hiện tại

MCP server `supabase-official` đã được cấu hình trong file:
- **File cấu hình:** `c:/Users/anhhuy/.cursor/mcp.json`
- **Project Reference:** `vazhgunhcjdwlkbslroc`
- **Access Token:** Đã được cấu hình

## Bước 1: Đảm bảo MCP Server đã được kết nối

### Kiểm tra MCP Server

1. **Restart Cursor hoàn toàn:**
   - Đóng tất cả cửa sổ Cursor
   - Mở lại Cursor
   - Đợi vài giây để MCP servers load

2. **Kiểm tra MCP đã load:**
   - Mở Developer Tools: `Ctrl+Shift+I`
   - Vào tab **Console**
   - Tìm log: `[MCP] Starting server: supabase-official`
   - Nếu thấy log này, MCP đã được kết nối thành công

3. **Kiểm tra trong Cursor Settings:**
   - Vào `Settings` → `Features` → `MCP Servers`
   - Tìm `supabase-official`
   - Kiểm tra trạng thái (nên có dấu xanh ✓)
   - ✅ **Nếu đã sáng xanh, MCP đã sẵn sàng sử dụng!**

## Bước 2: Sử dụng MCP để lấy thông tin Tables

✅ **MCP đã kết nối thành công!** (sáng xanh trong Settings)

Bây giờ bạn có thể yêu cầu AI sử dụng các lệnh sau để lấy thông tin tables:

### Lệnh 1: List tất cả các tables

```
Dùng MCP supabase-official để list tất cả các tables trong database
```

Hoặc:

```
Sử dụng supabase-official MCP để get_tables
```

### Lệnh 2: Lấy thông tin chi tiết một table

```
Sử dụng supabase-official MCP để get_table với tên table là "profiles"
```

### Lệnh 3: Lấy danh sách columns của table

```
Sử dụng supabase-official MCP để get_table_columns của table "profiles"
```

### Lệnh 4: Lấy dữ liệu từ table

```
Sử dụng supabase-official MCP để get_table_rows từ table "profiles" với limit 10
```

## Các Tools có sẵn trong Supabase MCP

Theo cấu hình `autoApprove`, các tools sau đã được tự động approve:

### Database Operations
- `get_tables` - List tất cả tables trong schema
- `get_table` - Lấy thông tin một table cụ thể
- `get_table_columns` - Lấy danh sách columns của table
- `get_table_rows` - Lấy rows từ table (có thể filter, sort, limit)
- `get_table_row` - Lấy một row cụ thể
- `get_table_row_by_id` - Lấy row theo ID

### Schema & Migrations
- `list_extensions` - List PostgreSQL extensions đã cài đặt
- `list_migrations` - List migrations đã được apply
- `apply_migration` - Apply migration mới vào database

### Monitoring & Debugging
- `get_logs` - Lấy logs từ các services (api, postgres, auth, storage, etc.)
- `get_advisors` - Lấy security và performance advisors

### Project Management
- `get_project_url` - Lấy URL của project
- `get_publishable_keys` - Lấy API keys (anon, service_role)
- `generate_typescript_types` - Generate TypeScript types từ schema

### Edge Functions
- `list_edge_functions` - List tất cả Edge Functions
- `get_edge_function` - Lấy thông tin một Edge Function
- `deploy_edge_function` - Deploy Edge Function mới

### Branching (Development)
- `create_branch` - Tạo database branch mới
- `list_branches` - List tất cả branches
- `delete_branch` - Xóa branch
- `merge_branch` - Merge branch
- `reset_branch` - Reset branch
- `rebase_branch` - Rebase branch

## Ví dụ sử dụng chi tiết

### Ví dụ 1: Lấy danh sách tất cả tables

**Yêu cầu AI:**
```
Dùng MCP supabase-official để get_tables và hiển thị tất cả các tables trong schema public
```

**Kết quả mong đợi:**
- Danh sách tất cả tables
- Thông tin về số rows
- Kích thước trên disk
- Số columns

### Ví dụ 2: Kiểm tra schema của table

**Yêu cầu AI:**
```
Sử dụng supabase-official MCP để get_table_columns của table "profiles" và hiển thị chi tiết các columns bao gồm data type, nullable, và constraints
```

**Kết quả mong đợi:**
- Tên column
- Data type
- Nullable/Not null
- Default value
- Constraints (primary key, foreign key, etc.)

### Ví dụ 3: Xem dữ liệu mẫu

**Yêu cầu AI:**
```
Sử dụng supabase-official MCP để get_table_rows từ table "profiles" với limit 5
```

**Kết quả mong đợi:**
- 5 rows đầu tiên từ table profiles
- Tất cả columns và giá trị

## Troubleshooting

### MCP Server không kết nối được

1. **Kiểm tra cấu hình:**
   ```powershell
   # Xem file cấu hình
   notepad c:/Users/anhhuy/.cursor/mcp.json
   ```

2. **Kiểm tra environment variables:**
   - `SUPABASE_ACCESS_TOKEN` phải có giá trị hợp lệ
   - `SUPABASE_PROJECT_REF` phải là `vazhgunhcjdwlkbslroc`

3. **Kiểm tra network:**
   - Đảm bảo có kết nối internet
   - Kiểm tra Supabase project còn hoạt động: https://supabase.com/dashboard/project/vazhgunhcjdwlkbslroc

4. **Restart Cursor:**
   - Đóng hoàn toàn Cursor
   - Mở lại và đợi MCP servers load

### Lỗi "Tool not found"

- Đảm bảo bạn đã restart Cursor sau khi cấu hình MCP
- Kiểm tra trong Developer Tools Console xem có lỗi gì không
- Thử lại với lệnh đơn giản hơn

### Lỗi "Access denied" hoặc "Unauthorized"

- Kiểm tra `SUPABASE_ACCESS_TOKEN` còn hợp lệ
- Tạo token mới tại: https://supabase.com/dashboard/account/tokens
- Cập nhật token trong file `mcp.json`

## Lưu ý quan trọng

1. **Auto-approve:** Các tools trong danh sách `autoApprove` sẽ được tự động approve, không cần xác nhận thủ công

2. **Read-only vs Write:** 
   - `get_tables`, `get_table`, `get_table_rows` là read-only (an toàn)
   - `apply_migration`, `deploy_edge_function` là write operations (cần cẩn thận)

3. **Performance:**
   - Khi lấy `get_table_rows`, luôn sử dụng `limit` để tránh lấy quá nhiều dữ liệu
   - Với tables lớn, nên sử dụng filter hoặc pagination

4. **Security:**
   - Access token có quyền truy cập vào project của bạn
   - Không commit token vào Git
   - File `mcp.json` nằm ngoài workspace nên không bị commit

## Tài liệu tham khảo

- [Supabase MCP Documentation](https://supabase.com/mcp)
- [MCP Server GitHub](https://github.com/supabase/mcp-server-supabase)
- Project Dashboard: https://supabase.com/dashboard/project/vazhgunhcjdwlkbslroc
