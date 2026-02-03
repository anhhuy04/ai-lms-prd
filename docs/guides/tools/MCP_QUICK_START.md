# Hướng dẫn Nhanh: Test MCP trong Cursor

## 🚀 3 Bước Đơn Giản

### Bước 1: Mở Developer Tools

**Phím tắt:** `Ctrl + Shift + I` (Windows/Linux) hoặc `Cmd + Option + I` (macOS)

Hoặc:
- Menu **Help** → **Toggle Developer Tools**

---

### Bước 2: Xem Log MCP

1. Trong Developer Tools, click tab **Console**
2. Trong ô **Filter**, gõ: `mcp`
3. **Đóng và mở lại Cursor** để xem log khởi động MCP
4. **Copy log** liên quan MCP (nếu có lỗi)

---

### Bước 3: Test MCP bằng AI Agent

Trong Cursor chat, yêu cầu AI Agent:

```
Sử dụng Supabase MCP để list các tables trong database
```

Hoặc test các MCP khác:

- **Fetch MCP:** "Sử dụng Fetch MCP để fetch https://pub.dev/packages/riverpod"
- **Filesystem MCP:** "Sử dụng Filesystem MCP để đọc file pubspec.yaml"
- **GitHub MCP:** "Sử dụng GitHub MCP để list các branches"
- **Dart MCP:** "Sử dụng Dart MCP để format file lib/main.dart"

---

## 📋 Checklist Nhanh

- [ ] Developer Tools mở được
- [ ] Filter `mcp` trong Console hoạt động
- [ ] Restart Cursor và xem log khởi động
- [ ] Test ít nhất 1 MCP bằng AI Agent
- [ ] Ghi nhận kết quả: PASS / FAIL

---

## 🔧 Nếu Gặp Lỗi

1. **Copy log từ Developer Tools Console**
2. **Gửi cho AI Agent** kèm mô tả vấn đề
3. AI Agent sẽ phân tích và đưa ra giải pháp

---

## 📚 Tài liệu Chi tiết

- [MCP_DEBUG_GUIDE.md](./MCP_DEBUG_GUIDE.md) - Hướng dẫn debug chi tiết
- [MCP_TEST_CHECKLIST.md](./MCP_TEST_CHECKLIST.md) - Checklist đầy đủ để copy-paste

---

## ⚡ Script Tự Động Test

Chạy script PowerShell để test nhanh từ command line:

```powershell
powershell -ExecutionPolicy Bypass -File tools\test_mcp_servers.ps1
```

**Lưu ý:** Script này chỉ test khả năng spawn MCP servers, không test trong Cursor runtime.
