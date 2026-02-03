# Kiểm tra MCP Tools có sẵn không

## Vấn đề: MCP sáng xanh nhưng không dùng được

Khi MCP server hiển thị **sáng xanh** (connected) nhưng không thể sử dụng tools, có thể do:

1. **MCP server đã kết nối nhưng tools chưa được expose**
2. **AI Agent không nhận diện được MCP tools**
3. **Có lỗi trong quá trình initialize tools**

## Cách kiểm tra MCP Tools có sẵn không

### Cách 1: Hỏi trực tiếp AI Agent

**Copy và paste lệnh này vào chat với AI:**

```
Hãy liệt kê tất cả MCP servers đã được load và các tools có sẵn từ mỗi server. Đặc biệt là các tools từ supabase-official MCP server.
```

**Nếu AI trả về danh sách tools** → MCP đã load thành công, có thể sử dụng.

**Nếu AI nói "không có MCP tools" hoặc "MCP chưa load"** → Cần debug thêm.

### Cách 2: Kiểm tra Developer Tools Console

1. **Mở Developer Tools:** `Ctrl + Shift + I`
2. **Vào tab Console**
3. **Filter:** `mcp` hoặc `tool`
4. **Tìm các log:**

   ✅ **Nếu thấy:**
   ```
   [MCP] Tools available: get_tables, get_table, get_table_columns, ...
   ```
   → Tools đã được expose thành công

   ❌ **Nếu thấy:**
   ```
   [MCP] Server started but no tools registered
   [MCP] Tools not available
   ```
   → Có vấn đề với việc expose tools

### Cách 3: Test trực tiếp MCP server

Chạy lệnh này trong terminal để test MCP server có expose tools không:

```powershell
$env:SUPABASE_ACCESS_TOKEN = "sbp_f7c9c9b5c4e14e13728d7975dcd39b8a3c900596"
$env:SUPABASE_PROJECT_REF = "vazhgunhcjdwlkbslroc"

# Chạy MCP server và xem output
npx -y @supabase/mcp-server-supabase@latest --project-ref vazhgunhcjdwlkbslroc
```

**Nếu thấy output về tools** → MCP server hoạt động tốt, vấn đề có thể ở Cursor.

**Nếu lỗi** → Cần fix cấu hình hoặc token.

## Giải pháp

### Giải pháp 1: Restart Cursor và đợi đủ lâu

1. **Đóng hoàn toàn Cursor** (tất cả cửa sổ)
2. **Kiểm tra Task Manager** để đảm bảo không còn process Cursor
3. **Mở lại Cursor**
4. **Đợi ít nhất 15-20 giây** để MCP servers load hoàn toàn
5. **Kiểm tra lại trong Settings** xem MCP có sáng xanh không
6. **Thử yêu cầu AI sử dụng MCP** lại

### Giải pháp 2: Kiểm tra và sửa cấu hình mcp.json

1. **Mở file:** `c:/Users/anhhuy/.cursor/mcp.json`
2. **Kiểm tra cấu hình supabase-official:**

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
        "SUPABASE_ACCESS_TOKEN": "sbp_f7c9c9b5c4e14e13728d7975dcd39b8a3c900596"
      }
    }
  }
}
```

3. **Đảm bảo:**
   - JSON syntax đúng (không có lỗi)
   - `--project-ref` có trong args
   - `SUPABASE_ACCESS_TOKEN` có giá trị hợp lệ
   - Không có dấu phẩy thừa ở cuối

4. **Lưu file và restart Cursor**

### Giải pháp 3: Thử cách gọi MCP tools khác

Thay vì nói "dùng MCP", thử các cách sau:

**Cách 1:**
```
Sử dụng tool get_tables từ supabase-official MCP server để list tất cả tables
```

**Cách 2:**
```
Gọi MCP tool get_tables với schema là public
```

**Cách 3:**
```
Hãy sử dụng Supabase MCP để lấy danh sách tables trong database
```

### Giải pháp 4: Kiểm tra Cursor version

Một số version Cursor có thể có bug với MCP. Kiểm tra:

1. **Vào Help → About** để xem version
2. **Update Cursor lên version mới nhất** nếu có thể
3. **Restart lại**

### Giải pháp 5: Sử dụng giải pháp thay thế

Nếu MCP vẫn không hoạt động, có thể:

1. **Sử dụng Supabase Dashboard** để xem tables
2. **Sử dụng Supabase CLI** để query database
3. **Sử dụng SQL Editor** trong Supabase Dashboard
4. **Sử dụng REST API** trực tiếp

## Checklist Debug

- [ ] Đã hỏi AI Agent về MCP tools có sẵn không
- [ ] Đã kiểm tra Developer Tools Console
- [ ] Đã test MCP server từ command line
- [ ] Đã restart Cursor và đợi đủ lâu
- [ ] Đã kiểm tra và sửa cấu hình mcp.json
- [ ] Đã thử các cách gọi MCP tools khác nhau
- [ ] Đã kiểm tra Cursor version

## Yêu cầu hỗ trợ

Nếu vẫn không giải quyết được:

1. **Copy log từ Developer Tools Console** (filter `mcp` hoặc `tool`)
2. **Copy output từ script debug** (`debug_mcp_supabase.ps1`)
3. **Gửi cho AI Agent** kèm mô tả:
   - MCP có sáng xanh không? ✅
   - AI Agent có nhận diện được MCP tools không? ❌
   - Có lỗi gì trong Console không?
4. **AI Agent sẽ phân tích** và đưa ra giải pháp cụ thể
