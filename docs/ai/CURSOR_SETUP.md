# Hướng dẫn Thiết lập Cursor và MCP cho dự án Flutter

Tài liệu này hướng dẫn cách thiết lập môi trường Cursor tối ưu với các MCP servers cho dự án Flutter "AI LMS".

## Mục lục

1. [Yêu cầu hệ thống](#yêu-cầu-hệ-thống)
2. [Cài đặt Cursor](#cài-đặt-cursor)
3. [Cấu hình MCP Servers](#cấu-hình-mcp-servers)
4. [Cấu hình GitHub MCP](#cấu-hình-github-mcp)
5. [Cấu hình Filesystem MCP](#cấu-hình-filesystem-mcp)
6. [Cấu hình Memory MCP](#cấu-hình-memory-mcp)
7. [Cấu hình Cursor Settings](#cấu-hình-cursor-settings)
8. [Kiểm tra cấu hình](#kiểm-tra-cấu-hình)
9. [Troubleshooting](#troubleshooting)

## Yêu cầu hệ thống

- **OS**: Windows 10/11, macOS, hoặc Linux
- **Node.js**: Version 18+ (để chạy MCP servers qua npx)
- **Git**: Đã cài đặt và cấu hình
- **Flutter SDK**: Đã cài đặt và trong PATH

## Cài đặt Cursor

1. Tải Cursor từ [cursor.sh](https://cursor.sh)
2. Cài đặt theo hướng dẫn
3. Mở Cursor và đăng nhập vào tài khoản của bạn

## Cấu hình MCP Servers

File cấu hình MCP nằm tại: `c:\Users\<username>\.cursor\mcp.json` (Windows) hoặc `~/.cursor/mcp.json` (macOS/Linux)

### Cấu trúc file mcp.json

```json
{
  "mcpServers": {
    "supabase-official": { ... },
    "github.com/upstash/context7-mcp": { ... },
    "github.com/zcaceres/fetch-mcp": { ... },
    "github": { ... },
    "filesystem": { ... },
    "memory": { ... }
  }
}
```

### Các MCP Servers đã được cấu hình

1. **Supabase Official MCP** - Quản lý database và backend
2. **Context7 MCP** - Quản lý context và tìm kiếm codebase
3. **Fetch MCP** - Fetch documentation và web content
4. **GitHub MCP** - Quản lý Git operations
5. **Filesystem MCP** - Đọc/ghi files và navigate codebase
6. **Memory MCP** - Lưu trữ context giữa các sessions

## Cấu hình GitHub MCP

### Bước 1: Tạo GitHub Personal Access Token

1. Truy cập GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Đặt tên token (ví dụ: "Cursor MCP")
4. Chọn các quyền (scopes):
   - `repo` - Full control of private repositories
   - `workflow` - Update GitHub Action workflows (nếu cần)
5. Click "Generate token"
6. **Lưu token ngay lập tức** (sẽ không hiển thị lại)

### Bước 2: Cập nhật mcp.json

Thêm token vào file `mcp.json`:

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github@latest"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_your_token_here"
      }
    }
  }
}
```

**Lưu ý bảo mật**: Không commit token vào Git. Token được lưu trong file local.

## Cấu hình Filesystem MCP

Filesystem MCP đã được cấu hình với đường dẫn dự án:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem@latest",
        "D:\\code\\Flutter_Android\\AI_LMS_PRD"
      ]
    }
  }
}
```

**Lưu ý**: Thay đổi đường dẫn nếu dự án của bạn ở vị trí khác.

## Cấu hình Memory MCP

Memory MCP không cần cấu hình thêm, sẽ tự động tạo storage:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-memory@latest"
      ]
    }
  }
}
```

## Cấu hình Cursor Settings

### File .vscode/settings.json

File `.vscode/settings.json` đã được tạo với các cấu hình tối ưu cho Flutter/Dart:

- Format on save
- Dart analysis rules
- File exclusions cho build folders
- Editor settings cho Dart, YAML, JSON, Markdown

### Cursor AI Settings

Có thể cấu hình trong Cursor Settings UI:

1. Mở Settings (Ctrl+, hoặc Cmd+,)
2. Tìm "Cursor" trong search
3. Cấu hình:
   - Model preferences
   - Context window size
   - Auto-save preferences

## Kiểm tra cấu hình

### 1. Kiểm tra MCP Servers

1. Mở Cursor
2. Mở Command Palette (Ctrl+Shift+P hoặc Cmd+Shift+P)
3. Tìm "MCP" hoặc kiểm tra trong Cursor Settings
4. Xác nhận tất cả MCP servers đã được load thành công

### 2. Kiểm tra Supabase MCP

Trong Cursor chat, thử:
```
Sử dụng Supabase MCP để list các tables trong database
```

### 3. Kiểm tra GitHub MCP

Trong Cursor chat, thử:
```
Sử dụng GitHub MCP để xem các branches hiện tại
```

**Lưu ý**: Cần có GitHub token hợp lệ.

### 4. Kiểm tra Filesystem MCP

Trong Cursor chat, thử:
```
Sử dụng Filesystem MCP để đọc file pubspec.yaml
```

## Troubleshooting

### MCP Server không khởi động

**Vấn đề**: MCP server không load hoặc báo lỗi

**Giải pháp**:
1. Kiểm tra Node.js đã cài đặt: `node --version`
2. Kiểm tra npx hoạt động: `npx --version`
3. Kiểm tra file `mcp.json` có syntax đúng JSON
4. Restart Cursor
5. Kiểm tra logs trong Cursor Developer Tools (Help → Toggle Developer Tools)

### GitHub MCP không hoạt động

**Vấn đề**: GitHub MCP báo lỗi authentication

**Giải pháp**:
1. Kiểm tra token trong `mcp.json` có đúng format
2. Kiểm tra token chưa hết hạn
3. Kiểm tra token có đủ quyền (scopes)
4. Tạo token mới nếu cần

### Filesystem MCP không truy cập được files

**Vấn đề**: Filesystem MCP không đọc được files

**Giải pháp**:
1. Kiểm tra đường dẫn trong `mcp.json` có đúng
2. Kiểm tra quyền truy cập thư mục
3. Sử dụng đường dẫn tuyệt đối (absolute path)

### Supabase MCP không kết nối được

**Vấn đề**: Supabase MCP không query được database

**Giải pháp**:
1. Kiểm tra `SUPABASE_ACCESS_TOKEN` trong `mcp.json`
2. Kiểm tra `project-ref` có đúng
3. Kiểm tra kết nối internet
4. Kiểm tra Supabase project còn hoạt động

### Memory MCP không lưu được data

**Vấn đề**: Memory MCP không lưu được context

**Giải pháp**:
1. Kiểm tra quyền ghi vào thư mục storage
2. Restart Cursor
3. Kiểm tra logs trong Developer Tools

## Best Practices

1. **Bảo mật**: Không commit tokens vào Git
2. **Backup**: Backup file `mcp.json` trước khi thay đổi
3. **Updates**: Cập nhật MCP servers định kỳ bằng cách chạy lại với `@latest`
4. **Documentation**: Đọc `MCP_GUIDE.md` để hiểu cách sử dụng từng MCP server
5. **Testing**: Test từng MCP server sau khi cấu hình

## Tài liệu liên quan

- [docs/mcp/MCP_GUIDE.md](docs/mcp/MCP_GUIDE.md) - Hướng dẫn chi tiết sử dụng từng MCP server
- [docs/ai/AI_INSTRUCTIONS.md](docs/ai/AI_INSTRUCTIONS.md) - Hướng dẫn cho AI agent
- [.clinerules](.clinerules) - Rules và quy tắc làm việc
- [memory-bank/techContext.md](memory-bank/techContext.md) - Technical context

## Hỗ trợ

Nếu gặp vấn đề không giải quyết được:

1. Kiểm tra lại các bước trong tài liệu này
2. Xem logs trong Cursor Developer Tools
3. Tham khảo documentation chính thức của từng MCP server
4. Tạo issue trong repository dự án
