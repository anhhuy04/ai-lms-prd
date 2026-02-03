# Checklist Test MCP - Copy và Điền Kết quả

## 📋 Hướng dẫn sử dụng

1. Copy checklist này vào một file text hoặc note
2. Điền kết quả khi test từng bước
3. Gửi cho AI Agent để phân tích nếu có lỗi

---

## ✅ BƯỚC 1: Mở Developer Tools

- [ ] Mở Developer Tools (`Ctrl + Shift + I` hoặc `F12`)
- [ ] Chuyển sang tab **Console**
- [ ] Filter: `mcp`
- [ ] **Ghi chú:** Developer Tools có mở được không? Filter có hoạt động không?

---

## ✅ BƯỚC 2: Restart Cursor và Xem Log Khởi động

- [ ] Đóng Cursor hoàn toàn
- [ ] Mở lại Cursor
- [ ] Mở Developer Tools ngay (`Ctrl + Shift + I`)
- [ ] Filter `mcp` trong Console
- [ ] **Copy log MCP ở đây (paste vào đây):**
```
[Paste log MCP từ Console vào đây]
```

---

## ✅ BƯỚC 3: Kiểm tra MCP Servers trong UI

### Cách 1: Command Palette
- [ ] Mở Command Palette (`Ctrl + Shift + P`)
- [ ] Gõ `MCP`
- [ ] **Có thấy lệnh nào liên quan MCP không?** (Ghi chú: Có/Không, nếu có thì list ra)

### Cách 2: Settings
- [ ] Mở Settings (`Ctrl + ,`)
- [ ] Search `MCP`
- [ ] **Có thấy settings nào liên quan MCP không?** (Ghi chú: Có/Không, nếu có thì list ra)

### Cách 3: Hỏi AI Agent
- [ ] Hỏi AI: "Liệt kê tất cả MCP servers đã được load"
- [ ] **AI Agent trả về gì?** (Paste response vào đây)

---

## ✅ BƯỚC 4: Test Runtime từng MCP

### 1. Supabase MCP
- [ ] Yêu cầu AI: "Sử dụng Supabase MCP để list các tables"
- [ ] **Kết quả:** ✅ PASS / ❌ FAIL
- [ ] **Nếu FAIL, error message:** (Ghi chú vào đây)

### 2. Fetch MCP
- [ ] Yêu cầu AI: "Sử dụng Fetch MCP để fetch https://pub.dev/packages/riverpod"
- [ ] **Kết quả:** ✅ PASS / ❌ FAIL
- [ ] **Nếu FAIL, error message:** (Ghi chú vào đây)

### 3. Filesystem MCP
- [ ] Yêu cầu AI: "Sử dụng Filesystem MCP để đọc file pubspec.yaml"
- [ ] **Kết quả:** ✅ PASS / ❌ FAIL
- [ ] **Nếu FAIL, error message:** (Ghi chú vào đây)

### 4. GitHub MCP
- [ ] Yêu cầu AI: "Sử dụng GitHub MCP để list các branches"
- [ ] **Kết quả:** ✅ PASS / ❌ FAIL
- [ ] **Nếu FAIL, error message:** (Ghi chú vào đây)

### 5. Memory MCP
- [ ] Yêu cầu AI: "Sử dụng Memory MCP để lưu: 'Test memory'"
- [ ] **Kết quả:** ✅ PASS / ❌ FAIL
- [ ] **Nếu FAIL, error message:** (Ghi chú vào đây)

### 6. Context7 MCP
- [ ] Yêu cầu AI: "Sử dụng Context7 MCP để tìm files liên quan authentication"
- [ ] **Kết quả:** ✅ PASS / ❌ FAIL
- [ ] **Nếu FAIL, error message:** (Ghi chú vào đây)

### 7. Dart MCP
- [ ] Yêu cầu AI: "Sử dụng Dart MCP để format file lib/main.dart"
- [ ] **Kết quả:** ✅ PASS / ❌ FAIL
- [ ] **Nếu FAIL, error message:** (Ghi chú vào đây)

---

## 📊 TỔNG KẾT

### MCP nào PASS?
- [ ] Supabase
- [ ] Fetch
- [ ] Filesystem
- [ ] GitHub
- [ ] Memory
- [ ] Context7
- [ ] Dart

### MCP nào FAIL?
- [ ] Supabase
- [ ] Fetch
- [ ] Filesystem
- [ ] GitHub
- [ ] Memory
- [ ] Context7
- [ ] Dart

### Error Messages tổng hợp:
```
[Paste tất cả error messages vào đây]
```

---

## 🔧 Thông tin Hệ thống

- **Cursor Version:** (Help → About → Copy version)
- **OS:** Windows / macOS / Linux
- **Node Version:** `node --version` = ?
- **Dart Version:** `dart --version` = ?

---

## 📝 Ghi chú thêm

```
[Ghi chú bất kỳ điều gì bạn thấy bất thường hoặc cần lưu ý]
```

---

**Sau khi điền xong, gửi checklist này cho AI Agent để phân tích và đưa ra giải pháp cụ thể.**
