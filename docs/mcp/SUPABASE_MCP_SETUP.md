# Hướng dẫn cấu hình Supabase MCP Server trong Cursor

## Bước 1: Cài đặt Supabase MCP Server

### Yêu cầu:
- Python 3.12+ 
- pipx hoặc uv (khuyến nghị dùng pipx)

### Cài đặt:
```bash
# Nếu đã có pipx
pipx install supabase-mcp-server

# Hoặc nếu dùng uv
uv pip install supabase-mcp-server
```

## Bước 2: Lấy API Key từ thequery.dev

1. Truy cập: https://thequery.dev
2. Đăng ký/Đăng nhập để lấy API key miễn phí
3. Copy API key của bạn

## Bước 3: Lấy thông tin Supabase Project

Từ project của bạn (`vazhgunhcjdwlkbslroc`):

1. **Project Reference**: `vazhgunhcjdwlkbslroc` (đã có)
2. **Database Password**: 
   - Vào Supabase Dashboard → Project Settings → Database
   - Copy database password
3. **Region**: 
   - Vào Supabase Dashboard → Project Settings
   - Xem region (ví dụ: `us-east-1`, `ap-southeast-1`, etc.)
4. **Service Role Key** (tùy chọn):
   - Vào Project Settings → API → Project API keys
   - Copy `service_role` key

## Bước 4: Cấu hình trong Cursor

### Cách 1: Cấu hình trong Cursor Settings (Khuyến nghị)

1. Mở Cursor → Settings → Features → MCP Servers
2. Thêm server mới với cấu hình sau:

```json
{
  "mcpServers": {
    "supabase": {
      "command": "supabase-mcp-server",
      "env": {
        "QUERY_API_KEY": "your-api-key-from-thequery-dev",
        "SUPABASE_PROJECT_REF": "vazhgunhcjdwlkbslroc",
        "SUPABASE_DB_PASSWORD": "your-database-password",
        "SUPABASE_REGION": "your-region",
        "SUPABASE_SERVICE_ROLE_KEY": "your-service-role-key"
      }
    }
  }
}
```

**Lưu ý**: Nếu command `supabase-mcp-server` không hoạt động, tìm đường dẫn đầy đủ:
```bash
# Windows PowerShell
where.exe supabase-mcp-server
```

Và dùng đường dẫn đầy đủ trong cấu hình.

### Cách 2: Tạo Global Config File

Tạo file `.env` tại: `%APPDATA%\supabase-mcp\.env`

```powershell
# Tạo thư mục
New-Item -ItemType Directory -Force -Path "$env:APPDATA\supabase-mcp"

# Tạo file .env
notepad "$env:APPDATA\supabase-mcp\.env"
```

Nội dung file `.env`:
```
QUERY_API_KEY=your-api-key-from-thequery-dev
SUPABASE_PROJECT_REF=vazhgunhcjdwlkbslroc
SUPABASE_DB_PASSWORD=your-database-password
SUPABASE_REGION=your-region
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## Bước 5: Kiểm tra cấu hình

Sau khi cấu hình:
1. Restart Cursor
2. Vào Settings → Features → MCP Servers
3. Bạn sẽ thấy Supabase MCP server với dấu xanh và số lượng tools

## Sử dụng MCP Supabase để xem tables

Sau khi cấu hình xong, bạn có thể hỏi AI:
- "Dùng MCP Supabase để list tất cả các tables"
- "Xem schema của table profiles"
- "Chạy SQL query SELECT * FROM profiles LIMIT 10"

Các tools có sẵn:
- `get_tables`: List tất cả tables trong schema
- `get_table_schema`: Xem chi tiết cấu trúc table
- `execute_postgresql`: Chạy SQL queries
- `get_db_schemas`: Xem tất cả schemas
