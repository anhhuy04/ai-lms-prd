# Hướng dẫn Debug MCP trong Cursor

Tài liệu này hướng dẫn chi tiết cách kiểm tra, debug và test MCP servers trong Cursor IDE.

## Mục lục

1. [Mở Developer Tools](#mở-developer-tools)
2. [Xem Log MCP](#xem-log-mcp)
3. [Kiểm tra MCP Servers trong UI](#kiểm-tra-mcp-servers-trong-ui)
4. [Test Runtime từng MCP](#test-runtime-từng-mcp)
5. [Troubleshooting](#troubleshooting)

---

## Mở Developer Tools

### Cách 1: Qua Menu (Khuyến nghị)

1. **Mở Cursor**
2. Click menu **Help** (hoặc **Trợ giúp**)
3. Chọn **Toggle Developer Tools** (hoặc **Bật Công cụ Nhà phát triển**)

**Phím tắt:**
- **Windows/Linux**: `Ctrl + Shift + I` hoặc `F12`
- **macOS**: `Cmd + Option + I`

### Cách 2: Qua Command Palette

1. Mở Command Palette:
   - **Windows/Linux**: `Ctrl + Shift + P`
   - **macOS**: `Cmd + Shift + P`
2. Gõ: `Developer: Toggle Developer Tools`
3. Enter

---

## Xem Log MCP

### Bước 1: Mở Developer Tools

Theo hướng dẫn ở trên.

### Bước 2: Chuyển sang tab Console

Trong cửa sổ Developer Tools, click tab **Console** (hoặc nhấn `Esc` để toggle).

### Bước 3: Filter Log MCP

1. Trong ô **Filter** (hoặc search box) của Console, gõ:
   ```
   mcp
   ```
2. Hoặc filter chi tiết hơn:
   ```
   mcp|MCP|server|tool
   ```

### Bước 4: Restart Cursor để xem log khởi động

1. **Đóng Developer Tools** (nếu đang mở)
2. **Đóng hoàn toàn Cursor** (File → Exit / Quit)
3. **Mở lại Cursor**
4. **Mở Developer Tools ngay** (`Ctrl + Shift + I`)
5. **Xem Console** → filter `mcp`

### Các log quan trọng cần tìm:

✅ **Log thành công:**
```
[MCP] Starting server: supabase-official
[MCP] Server registered: supabase-official
[MCP] Tools available: list_tables, execute_query, ...
```

❌ **Log lỗi:**
```
[MCP] Failed to start server: fetch-mcp
[MCP] Error: spawn npx ENOENT
[MCP] Timeout starting server: dart
[MCP] Server crashed: github
```

⚠️ **Log cảnh báo:**
```
[MCP] Server started but no tools registered: memory
[MCP] Missing environment variable: SUPABASE_ACCESS_TOKEN
```

### Bước 5: Copy Log để gửi cho AI Agent

1. **Chọn tất cả log** liên quan MCP (click vào log đầu tiên, scroll xuống log cuối, giữ `Shift` và click)
2. **Copy** (`Ctrl + C` / `Cmd + C`)
3. **Dán vào chat** với AI Agent để phân tích

---

## Kiểm tra MCP Servers trong UI

### Cách 1: Qua Command Palette (Nếu có)

1. Mở Command Palette (`Ctrl + Shift + P` / `Cmd + Shift + P`)
2. Gõ: `MCP` hoặc `Model Context Protocol`
3. Xem các lệnh có sẵn:
   - `MCP: Show Servers`
   - `MCP: Show Tools`
   - `MCP: Restart Server`
   - `MCP: View Logs`

**Lưu ý:** Không phải phiên bản Cursor nào cũng có UI này. Nếu không thấy, dùng cách 2.

### Cách 2: Qua Settings

1. Mở Settings:
   - **Windows/Linux**: `Ctrl + ,`
   - **macOS**: `Cmd + ,`
2. Trong ô search, gõ: `MCP` hoặc `Model Context Protocol`
3. Xem các settings liên quan:
   - `MCP Servers`
   - `MCP Configuration`
   - `MCP Logs`

### Cách 3: Kiểm tra trực tiếp trong Chat với AI

**Test nhanh:** Hỏi AI Agent trong Cursor chat:

```
Hãy liệt kê tất cả MCP servers đã được load và các tools có sẵn
```

Nếu AI Agent có thể liệt kê được → MCP đã load thành công.

---

## Test Runtime từng MCP

### Checklist Test MCP

Sau khi xác nhận MCP đã load (qua Developer Tools hoặc UI), test từng MCP bằng cách **yêu cầu AI Agent gọi tool**.

#### ✅ Test Supabase MCP

**Yêu cầu AI Agent:**
```
Sử dụng Supabase MCP để list các tables trong database
```

**Kết quả mong đợi:**
- AI Agent gọi tool `list_tables` hoặc `execute_query`
- Trả về danh sách tables (profiles, classes, assignments, ...)

**Nếu lỗi:**
- "MCP server not found" → Server chưa load
- "Authentication failed" → Token sai hoặc hết hạn
- "Connection timeout" → Network issue hoặc Supabase project offline

---

#### ✅ Test Fetch MCP

**Yêu cầu AI Agent:**
```
Sử dụng Fetch MCP để fetch nội dung từ https://pub.dev/packages/riverpod
```

**Kết quả mong đợi:**
- AI Agent gọi tool `fetch_markdown` hoặc `fetch_html`
- Trả về nội dung trang web

**Nếu lỗi:**
- "MCP server not found" → Server chưa load
- "Network error" → Không kết nối được internet
- "Timeout" → URL không tồn tại hoặc server chậm

---

#### ✅ Test Filesystem MCP

**Yêu cầu AI Agent:**
```
Sử dụng Filesystem MCP để đọc file pubspec.yaml
```

**Kết quả mong đợi:**
- AI Agent gọi tool `read_file`
- Trả về nội dung `pubspec.yaml`

**Nếu lỗi:**
- "MCP server not found" → Server chưa load
- "Permission denied" → Quyền truy cập file bị chặn
- "File not found" → Đường dẫn sai trong config

---

#### ✅ Test GitHub MCP

**Yêu cầu AI Agent:**
```
Sử dụng GitHub MCP để list các branches trong repository này
```

**Kết quả mong đợi:**
- AI Agent gọi tool `list_branches`
- Trả về danh sách branches (main, develop, feature/..., ...)

**Nếu lỗi:**
- "MCP server not found" → Server chưa load
- "Authentication failed" → GitHub token sai hoặc hết hạn
- "Repository not found" → Token không có quyền truy cập repo

---

#### ✅ Test Memory MCP

**Yêu cầu AI Agent:**
```
Sử dụng Memory MCP để lưu: "Dự án này sử dụng Flutter với Riverpod cho state management"
```

**Kết quả mong đợi:**
- AI Agent gọi tool `store_memory`
- Trả về confirmation "Memory stored"

**Nếu lỗi:**
- "MCP server not found" → Server chưa load
- "Storage error" → Quyền ghi file bị chặn

---

#### ✅ Test Context7 MCP

**Yêu cầu AI Agent:**
```
Sử dụng Context7 MCP để tìm các file liên quan đến authentication
```

**Kết quả mong đợi:**
- AI Agent gọi tool `search_codebase` hoặc tương tự
- Trả về danh sách files liên quan

**Nếu lỗi:**
- "MCP server not found" → Server chưa load
- "API key missing" → Cần set `CONTEXT7_API_KEY` trong env

---

#### ✅ Test Dart MCP

**Yêu cầu AI Agent:**
```
Sử dụng Dart MCP để format file lib/main.dart
```

**Kết quả mong đợi:**
- AI Agent gọi tool `format_code` hoặc `analyze_code`
- Trả về code đã format hoặc linter errors

**Nếu lỗi:**
- "MCP server not found" → Server chưa load
- "Command not found" → Dart SDK không có trong PATH
- "Invalid command" → Args sai (ví dụ: `--experimental-mcp-server` không tồn tại)

---

## Troubleshooting

### Vấn đề 1: Developer Tools không mở được

**Giải pháp:**
- Thử phím tắt khác: `F12`, `Ctrl + Shift + I`, `Cmd + Option + I`
- Kiểm tra Cursor version (cần version hỗ trợ Developer Tools)
- Restart Cursor

---

### Vấn đề 2: Không thấy log MCP trong Console

**Nguyên nhân có thể:**
- MCP chưa được load (check config file `mcp.json`)
- Log level quá cao (chỉ hiển thị errors)
- Filter sai

**Giải pháp:**
1. Kiểm tra file `c:\Users\<username>\.cursor\mcp.json` có đúng không
2. Restart Cursor
3. Thử filter khác: `server`, `tool`, `error`
4. Check tab **Network** trong Developer Tools (xem có request nào đến MCP không)

---

### Vấn đề 3: MCP load nhưng không có tools

**Nguyên nhân:**
- Server crash sau khi start
- Server không expose tools đúng cách
- Cursor không parse được tool registry

**Giải pháp:**
1. Xem log chi tiết trong Console (tìm error messages)
2. Test server trực tiếp bằng command line:
   ```bash
   npx -y @supabase/mcp-server-supabase@latest --project-ref YOUR_PROJECT_REF
   ```
3. Kiểm tra version MCP server có tương thích với Cursor không

---

### Vấn đề 4: AI Agent không thể gọi MCP tools

**Nguyên nhân:**
- MCP chưa load
- Tool name sai
- Permission bị chặn

**Giải pháp:**
1. Yêu cầu AI Agent: "Liệt kê tất cả MCP tools có sẵn"
2. Nếu không có → MCP chưa load → check Developer Tools logs
3. Nếu có nhưng gọi fail → check permission và error messages

---

## Checklist Debug MCP

Sử dụng checklist này để debug MCP một cách có hệ thống:

- [ ] **Bước 1: Kiểm tra Config**
  - [ ] File `mcp.json` tồn tại và đúng vị trí
  - [ ] JSON syntax đúng (không có lỗi)
  - [ ] Tất cả `command` và `args` đúng
  - [ ] Environment variables đã set (nếu cần)

- [ ] **Bước 2: Kiểm tra Prerequisites**
  - [ ] Node.js đã cài (`node --version`)
  - [ ] npx hoạt động (`npx --version`)
  - [ ] Dart SDK đã cài (nếu dùng Dart MCP)
  - [ ] Python đã cài (nếu dùng Python-based MCP)

- [ ] **Bước 3: Mở Developer Tools**
  - [ ] Developer Tools mở được
  - [ ] Console tab hiển thị được
  - [ ] Filter `mcp` hoạt động

- [ ] **Bước 4: Restart và Xem Log**
  - [ ] Đóng Cursor hoàn toàn
  - [ ] Mở lại Cursor
  - [ ] Mở Developer Tools ngay
  - [ ] Filter `mcp` trong Console
  - [ ] Copy log liên quan MCP

- [ ] **Bước 5: Test từng MCP**
  - [ ] Supabase MCP: list tables
  - [ ] Fetch MCP: fetch URL
  - [ ] Filesystem MCP: read file
  - [ ] GitHub MCP: list branches
  - [ ] Memory MCP: store memory
  - [ ] Context7 MCP: search codebase
  - [ ] Dart MCP: format code

- [ ] **Bước 6: Ghi nhận Kết quả**
  - [ ] MCP nào PASS
  - [ ] MCP nào FAIL
  - [ ] Error messages cụ thể
  - [ ] Gửi log cho AI Agent để phân tích

---

## Tài liệu tham khảo

- [MCP_GUIDE.md](../../ai/MCP_GUIDE.md) - Hướng dẫn sử dụng từng MCP server
- [CURSOR_SETUP.md](../../ai/CURSOR_SETUP.md) - Hướng dẫn setup Cursor và MCP
- [.clinerules](../../.clinerules) - Rules và quy tắc làm việc với MCP

---

## Hỗ trợ

Nếu gặp vấn đề không giải quyết được:

1. Copy log từ Developer Tools Console
2. Gửi cho AI Agent kèm mô tả vấn đề
3. AI Agent sẽ phân tích và đưa ra giải pháp cụ thể
