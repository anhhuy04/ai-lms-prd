# Tóm tắt Sửa Lỗi MCP "Connection closed"

## ✅ Đã Thực Hiện

### 1. Kiểm tra Rules Files
- ✅ **Đã kiểm tra `.clinerules`**: KHÔNG có quy tắc nào chặn MCP
- ✅ **Đã kiểm tra `.cursorrules`**: Không tồn tại trong workspace
- ✅ **Đã kiểm tra các file docs**: Chỉ chứa hướng dẫn, không có quy tắc chặn
- ✅ **Kết luận**: Rules files KHÔNG chặn MCP, thực ra KHUYẾN KHÍCH sử dụng MCP

### 2. Kiểm tra Prerequisites
- ✅ **Node.js**: Đã cài đặt (v20.18.0) tại `C:\Program Files\nodejs\node.exe`
- ✅ **npx**: Đã có trong PATH
- ⚠️ **Python**: Có trong PATH nhưng có thể là Windows Store stub
- ❌ **File mcp.json**: Chưa tồn tại tại `%APPDATA%\Cursor\mcp.json`

### 3. Đã Tạo File mcp.json
- ✅ Đã copy file mẫu từ `tools/mcp.json.sample` sang `%APPDATA%\Cursor\mcp.json`
- ⚠️ **CẦN CHỈNH SỬA**: File mẫu chứa placeholder values, cần điền thông tin thực tế

## 🔧 Các Bước Tiếp Theo

### Bước 1: Chỉnh sửa File mcp.json

Mở file để chỉnh sửa:
```powershell
notepad "$env:APPDATA\Cursor\mcp.json"
```

Hoặc dùng VS Code:
```powershell
code "$env:APPDATA\Cursor\mcp.json"
```

### Bước 2: Điền Thông Tin Thực Tế

Thay thế các placeholder sau:

#### Supabase MCP (Official - NPM)
```json
"SUPABASE_ACCESS_TOKEN": "YOUR_ACCESS_TOKEN_HERE",
"SUPABASE_PROJECT_REF": "YOUR_PROJECT_REF_HERE"
```

**Cách lấy:**
- Access Token: https://supabase.com/dashboard/account/tokens
- Project Ref: Tìm trong URL Supabase dashboard: `https://supabase.com/dashboard/project/<project-ref>`

#### Supabase MCP (Python - nếu dùng)
```json
"QUERY_API_KEY": "YOUR_QUERY_API_KEY_FROM_THEQUERY_DEV",
"SUPABASE_PROJECT_REF": "YOUR_PROJECT_REF",
"SUPABASE_DB_PASSWORD": "YOUR_DB_PASSWORD",
"SUPABASE_REGION": "us-east-1"
```

**Cách lấy:**
- QUERY_API_KEY: https://thequery.dev (đăng ký miễn phí)
- DB Password: Supabase Dashboard → Project Settings → Database
- Region: Supabase Dashboard → Project Settings → General

#### Context7 MCP (nếu cần)
```json
"CONTEXT7_API_KEY": "YOUR_CONTEXT7_API_KEY"
```

#### GitHub MCP (nếu cần)
```json
"GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_YOUR_TOKEN_HERE"
```

**Cách tạo:**
- GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
- Chọn scopes: `repo`, `workflow`

### Bước 3: Kiểm tra Đường dẫn Filesystem

Đảm bảo đường dẫn trong `filesystem` server đúng:
```json
"filesystem": {
  "args": [
    "-y",
    "@modelcontextprotocol/server-filesystem@latest",
    "D:\\code\\Flutter_Android\\AI_LMS_PRD"  // ← Kiểm tra đường dẫn này
  ]
}
```

### Bước 4: Restart Cursor

1. **Đóng hoàn toàn Cursor** (File → Exit)
2. **Mở lại Cursor**
3. **Mở Developer Tools** (`Ctrl + Shift + I`)
4. **Xem Console** với filter `mcp`
5. **Kiểm tra log** xem có lỗi không

### Bước 5: Test MCP Servers

Test từng MCP server bằng cách yêu cầu AI Agent:

1. **Supabase MCP:**
   ```
   Sử dụng Supabase MCP để list các tables trong database
   ```

2. **Fetch MCP:**
   ```
   Sử dụng Fetch MCP để fetch https://pub.dev/packages/riverpod
   ```

3. **Filesystem MCP:**
   ```
   Sử dụng Filesystem MCP để đọc file pubspec.yaml
   ```

4. **Memory MCP:**
   ```
   Sử dụng Memory MCP để lưu: "Test memory"
   ```

## 🐛 Troubleshooting

### Nếu vẫn gặp lỗi "Connection closed"

1. **Kiểm tra JSON Syntax:**
   ```powershell
   Get-Content "$env:APPDATA\Cursor\mcp.json" | ConvertFrom-Json
   ```
   Nếu có lỗi → Sửa JSON syntax

2. **Kiểm tra Commands:**
   ```powershell
   # Test npx
   npx --version
   
   # Test Node.js
   node --version
   ```

3. **Kiểm tra Log trong Developer Tools:**
   - Mở Developer Tools (`Ctrl + Shift + I`)
   - Tab Console
   - Filter: `mcp` hoặc `connection` hoặc `32000`
   - Copy log và gửi cho AI Agent phân tích

4. **Kiểm tra Environment Variables:**
   ```powershell
   # Kiểm tra từng biến
   $env:SUPABASE_ACCESS_TOKEN
   $env:SUPABASE_PROJECT_REF
   ```

### Nếu MCP không load

1. **Kiểm tra Cursor Version:**
   - Cần Cursor version mới hỗ trợ MCP
   - Update Cursor nếu cần

2. **Kiểm tra File mcp.json Location:**
   - Windows: `%APPDATA%\Cursor\mcp.json`
   - Đảm bảo file tồn tại và có quyền đọc

3. **Kiểm tra Network:**
   - MCP servers cần kết nối internet
   - Kiểm tra firewall không chặn

## 📝 Checklist Hoàn chỉnh

- [ ] File mcp.json đã được tạo tại đúng vị trí
- [ ] Đã điền SUPABASE_ACCESS_TOKEN
- [ ] Đã điền SUPABASE_PROJECT_REF
- [ ] Đã kiểm tra đường dẫn filesystem đúng
- [ ] Đã restart Cursor
- [ ] Đã mở Developer Tools và xem log
- [ ] Đã test ít nhất 1 MCP server
- [ ] Không có lỗi trong Console

## 📚 Tài liệu Tham khảo

- [MCP_CONNECTION_CLOSED_FIX.md](./MCP_CONNECTION_CLOSED_FIX.md) - Hướng dẫn chi tiết
- [MCP_DEBUG_GUIDE.md](./MCP_DEBUG_GUIDE.md) - Hướng dẫn debug
- [MCP_GUIDE.md](../../ai/MCP_GUIDE.md) - Hướng dẫn sử dụng từng MCP server
- [CURSOR_SETUP.md](../../ai/CURSOR_SETUP.md) - Hướng dẫn setup Cursor và MCP

## 🎯 Kết luận

**Rules Files:** ✅ KHÔNG chặn MCP
**Prerequisites:** ✅ Node.js và npx đã sẵn sàng
**File mcp.json:** ✅ Đã tạo, cần điền thông tin thực tế
**Next Steps:** ⚠️ Chỉnh sửa file mcp.json và restart Cursor
