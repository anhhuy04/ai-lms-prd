# Sửa lỗi: MCP sáng xanh nhưng không thể dùng được

## Vấn đề

MCP server `supabase-official` hiển thị trạng thái **sáng xanh** (connected) trong Cursor Settings, nhưng khi yêu cầu AI sử dụng MCP tools thì không hoạt động.

## Nguyên nhân có thể

1. **MCP server start nhưng crash ngay sau đó**
2. **Tools không được expose đúng cách**
3. **Lỗi trong quá trình initialize**
4. **MCP server chưa hoàn tất quá trình load**
5. **Lỗi authentication hoặc permission**

## Các bước debug

### Bước 1: Chạy script debug

Chạy script debug để kiểm tra cấu hình:

```powershell
powershell -ExecutionPolicy Bypass -File tools\debug_mcp_supabase.ps1
```

Script này sẽ kiểm tra:
- Node.js và npx có hoạt động không
- MCP server có thể chạy được không
- Cấu hình `mcp.json` có đúng không
- Kết nối đến Supabase có thành công không

### Bước 2: Kiểm tra Developer Tools Console

1. **Mở Developer Tools:**
   - Nhấn `Ctrl + Shift + I` (Windows/Linux)
   - Hoặc `Cmd + Option + I` (macOS)

2. **Vào tab Console**

3. **Filter logs:**
   - Gõ `mcp` hoặc `supabase` vào ô filter
   - Hoặc filter chi tiết: `mcp|MCP|server|tool|error`

4. **Tìm các log quan trọng:**

   ✅ **Log thành công:**
   ```
   [MCP] Starting server: supabase-official
   [MCP] Server registered: supabase-official
   [MCP] Tools available: get_tables, get_table, ...
   ```

   ❌ **Log lỗi cần chú ý:**
   ```
   [MCP] Failed to start server: supabase-official
   [MCP] Server crashed: supabase-official
   [MCP] Error: spawn npx ENOENT
   [MCP] Timeout starting server: supabase-official
   [MCP] Authentication failed
   [MCP] Missing environment variable: SUPABASE_ACCESS_TOKEN
   ```

   ⚠️ **Log cảnh báo:**
   ```
   [MCP] Server started but no tools registered
   [MCP] Tools not available
   ```

5. **Copy log và gửi cho AI Agent** để phân tích

### Bước 3: Test MCP server trực tiếp từ command line

Test xem MCP server có thể chạy được không:

```powershell
# Set environment variables
$env:SUPABASE_ACCESS_TOKEN = "sbp_f7c9c9b5c4e14e13728d7975dcd39b8a3c900596"
$env:SUPABASE_PROJECT_REF = "vazhgunhcjdwlkbslroc"

# Test chạy MCP server
npx -y @supabase/mcp-server-supabase@latest --project-ref vazhgunhcjdwlkbslroc
```

**Nếu lỗi:**
- Kiểm tra token còn hợp lệ không
- Kiểm tra project reference có đúng không
- Kiểm tra kết nối internet

### Bước 4: Kiểm tra cấu hình mcp.json

Kiểm tra file cấu hình tại: `c:/Users/anhhuy/.cursor/mcp.json`

**Đảm bảo:**
- JSON syntax đúng (không có lỗi)
- `command` và `args` đúng
- `SUPABASE_ACCESS_TOKEN` có giá trị hợp lệ
- `--project-ref` trong args đúng với project của bạn

**Ví dụ cấu hình đúng:**
```json
{
  "mcpServers": {
    "supabase-official": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--project-ref",
        "vazhgunhcjdwlkbslroc"
      ],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "sbp_..."
      }
    }
  }
}
```

### Bước 5: Restart Cursor hoàn toàn

1. **Đóng tất cả cửa sổ Cursor**
2. **Kiểm tra Task Manager** (Windows) hoặc Activity Monitor (macOS) để đảm bảo không còn process Cursor nào chạy
3. **Mở lại Cursor**
4. **Đợi 10-15 giây** để MCP servers load
5. **Kiểm tra lại trong Settings** xem MCP có sáng xanh không
6. **Thử yêu cầu AI sử dụng MCP** lại

### Bước 6: Kiểm tra Access Token

1. **Kiểm tra token còn hợp lệ:**
   - Truy cập: https://supabase.com/dashboard/account/tokens
   - Kiểm tra token `sbp_f7c9c9b5c4e14e13728d7975dcd39b8a3c900596` còn active không

2. **Nếu token hết hạn hoặc không hợp lệ:**
   - Tạo token mới tại: https://supabase.com/dashboard/account/tokens
   - Copy token mới
   - Cập nhật trong file `mcp.json`
   - Restart Cursor

### Bước 7: Kiểm tra Project Reference

1. **Kiểm tra project reference đúng:**
   - Truy cập: https://supabase.com/dashboard/project/vazhgunhcjdwlkbslroc
   - Xác nhận project còn hoạt động
   - Kiểm tra project reference trong URL

2. **Nếu project reference sai:**
   - Tìm project reference đúng trong Supabase Dashboard
   - Cập nhật trong file `mcp.json` (trong args `--project-ref`)
   - Restart Cursor

## Giải pháp thay thế

### Giải pháp 1: Sử dụng Supabase REST API trực tiếp

Nếu MCP không hoạt động, có thể sử dụng Supabase REST API để lấy thông tin tables:

```powershell
# Lấy danh sách tables qua REST API
$supabaseUrl = "https://vazhgunhcjdwlkbslroc.supabase.co"
$anonKey = "your-anon-key"

# Query information_schema để lấy tables
$query = "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'"
$response = Invoke-RestMethod -Uri "$supabaseUrl/rest/v1/rpc/get_tables" -Method GET -Headers @{"apikey"=$anonKey}
```

### Giải pháp 2: Sử dụng Supabase CLI

Cài đặt Supabase CLI và sử dụng:

```bash
# Cài đặt Supabase CLI
npm install -g supabase

# Login
supabase login

# List tables
supabase db list tables --project-ref vazhgunhcjdwlkbslroc
```

### Giải pháp 3: Sử dụng SQL Editor trong Supabase Dashboard

1. Truy cập: https://supabase.com/dashboard/project/vazhgunhcjdwlkbslroc
2. Vào **SQL Editor**
3. Chạy query:

```sql
SELECT 
    table_schema,
    table_name,
    (SELECT COUNT(*) FROM information_schema.columns WHERE table_name = t.table_name) as column_count
FROM information_schema.tables t
WHERE table_schema = 'public'
ORDER BY table_name;
```

## Checklist Debug

Sử dụng checklist này để debug một cách có hệ thống:

- [ ] **Bước 1:** Chạy script `debug_mcp_supabase.ps1`
- [ ] **Bước 2:** Mở Developer Tools và kiểm tra logs
- [ ] **Bước 3:** Test MCP server từ command line
- [ ] **Bước 4:** Kiểm tra cấu hình `mcp.json`
- [ ] **Bước 5:** Restart Cursor hoàn toàn
- [ ] **Bước 6:** Kiểm tra Access Token còn hợp lệ
- [ ] **Bước 7:** Kiểm tra Project Reference đúng
- [ ] **Bước 8:** Thử giải pháp thay thế nếu cần

## Yêu cầu hỗ trợ

Nếu vẫn không giải quyết được:

1. **Copy toàn bộ log từ Developer Tools Console** (filter `mcp`)
2. **Chạy script debug** và copy output
3. **Gửi cho AI Agent** kèm mô tả chi tiết vấn đề
4. **AI Agent sẽ phân tích** và đưa ra giải pháp cụ thể

## Tài liệu tham khảo

- [MCP_DEBUG_GUIDE.md](../guides/tools/MCP_DEBUG_GUIDE.md) - Hướng dẫn debug MCP chi tiết
- [HUONG_DAN_SU_DUNG_SUPABASE_MCP.md](./HUONG_DAN_SU_DUNG_SUPABASE_MCP.md) - Hướng dẫn sử dụng Supabase MCP
- [Supabase MCP Documentation](https://supabase.com/mcp)
