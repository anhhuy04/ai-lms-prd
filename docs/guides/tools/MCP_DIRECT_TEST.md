# Test MCP Trực Tiếp Trong Cursor Chat

Vì không có UI "MCP: Show Servers" và không có log lỗi, cách tốt nhất là **test trực tiếp** bằng cách yêu cầu AI Agent gọi tools.

## 🧪 Test Từng MCP

Copy và paste từng câu lệnh sau vào **Cursor chat** (không phải terminal), xem AI Agent có thể gọi được tool không:

### 1. Test Supabase MCP

```
Sử dụng Supabase MCP để list các tables trong database
```

**Kết quả mong đợi:**
- ✅ AI Agent gọi tool và trả về danh sách tables (profiles, classes, assignments, ...)
- ❌ AI Agent báo "MCP server not found" hoặc "Tool not available"

---

### 2. Test Fetch MCP

```
Sử dụng Fetch MCP để fetch nội dung từ https://pub.dev/packages/riverpod
```

**Kết quả mong đợi:**
- ✅ AI Agent fetch được nội dung trang web
- ❌ AI Agent báo "MCP server not found"

---

### 3. Test Filesystem MCP

```
Sử dụng Filesystem MCP để đọc file pubspec.yaml
```

**Kết quả mong đợi:**
- ✅ AI Agent đọc được nội dung file
- ❌ AI Agent báo "MCP server not found" hoặc "Permission denied"

---

### 4. Test GitHub MCP

```
Sử dụng GitHub MCP để list các branches trong repository này
```

**Kết quả mong đợi:**
- ✅ AI Agent list được branches (main, develop, ...)
- ❌ AI Agent báo "MCP server not found" hoặc "Authentication failed"

---

### 5. Test Memory MCP

```
Sử dụng Memory MCP để lưu: "Test memory storage"
```

**Kết quả mong đợi:**
- ✅ AI Agent lưu được memory
- ❌ AI Agent báo "MCP server not found"

---

### 6. Test Context7 MCP

```
Sử dụng Context7 MCP để tìm các file liên quan đến authentication
```

**Kết quả mong đợi:**
- ✅ AI Agent tìm được files liên quan
- ❌ AI Agent báo "MCP server not found" hoặc "API key missing"

---

### 7. Test Dart MCP

```
Sử dụng Dart MCP để format file lib/main.dart
```

**Kết quả mong đợi:**
- ✅ AI Agent format được code
- ❌ AI Agent báo "MCP server not found" hoặc "Command not found"

---

## 📊 Ghi Nhận Kết Quả

Sau khi test từng MCP, điền vào bảng sau:

| MCP | Kết quả | Error Message (nếu có) |
|-----|---------|------------------------|
| Supabase | ✅ PASS / ❌ FAIL | |
| Fetch | ✅ PASS / ❌ FAIL | |
| Filesystem | ✅ PASS / ❌ FAIL | |
| GitHub | ✅ PASS / ❌ FAIL | |
| Memory | ✅ PASS / ❌ FAIL | |
| Context7 | ✅ PASS / ❌ FAIL | |
| Dart | ✅ PASS / ❌ FAIL | |

---

## 🔍 Phân Tích Kết Quả

### Nếu TẤT CẢ MCP đều FAIL với "MCP server not found"

**Nguyên nhân:** MCP servers chưa được load trong Cursor.

**Giải pháp:**
1. Kiểm tra file `c:\Users\anhhuy\.cursor\mcp.json` có đúng không
2. Restart Cursor hoàn toàn (đóng và mở lại)
3. Kiểm tra Cursor version có hỗ trợ MCP không (cần version mới)

---

### Nếu MỘT SỐ MCP PASS, MỘT SỐ FAIL

**Nguyên nhân:** MCP cụ thể có vấn đề (config sai, thiếu env, ...)

**Giải pháp:**
- Xem error message cụ thể
- Kiểm tra config của MCP đó trong `mcp.json`
- Gửi error message cho AI Agent để phân tích

---

### Nếu TẤT CẢ MCP đều PASS

**Kết luận:** MCP đã load thành công! Không có UI và không có log là bình thường (tùy Cursor version).

---

## 💡 Lưu Ý

- **Test trong Cursor chat**, không phải terminal
- **Copy-paste chính xác** câu lệnh test
- **Ghi nhận error message** nếu có
- **Gửi kết quả** cho AI Agent để phân tích tiếp
