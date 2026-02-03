# MCP TMP Reports Archive (2025-01-20)

> File này là bản **gộp** từ các báo cáo/thử nghiệm trong `tmp/` để sau khi dọn project có thể **xóa tmp** mà không mất kiến thức quan trọng.
>
> Nguồn gốc: `tmp/*.md` (Context7, Fetch MCP, Supabase MCP) trong giai đoạn setup/khắc phục MCP.

---

## 1) Debug MCP Supabase (tools “sáng xanh nhưng không dùng được”)

### Nội dung gộp từ `tmp/MCP_DEBUG_SUMMARY.md`

```text
# Tóm tắt Debug MCP Supabase

## Kết quả Debug

### ✅ Những gì hoạt động tốt:

1. **Node.js và npx:** ✅ Hoạt động tốt
   - Node.js: v20.18.0
   - npx: 10.9.0

2. **MCP Server có thể chạy:** ✅ 
   - Package `@supabase/mcp-server-supabase@latest` có thể được tải và chạy
   - Server chạy trong stdio mode (bình thường cho MCP)

3. **Cấu hình mcp.json:** ✅ Tồn tại và đúng vị trí
   - File: `C:\Users\anhhuy\AppData\Roaming\Cursor\mcp.json`
   - Cấu hình `supabase-official` có đầy đủ
   - Access Token đã được cấu hình
   - Project Ref đã được cấu hình trong args

### ⚠️ Vấn đề hiện tại:

**MCP sáng xanh trong Settings nhưng không thể sử dụng tools**

Điều này có nghĩa là:
- MCP server đã được Cursor nhận diện và kết nối thành công
- Nhưng tools có thể chưa được expose cho AI Agent
- Hoặc có vấn đề trong quá trình initialize tools

## Các bước tiếp theo để fix
... (xem lại full content trong git history nếu cần) ...
```

---

## 2) Test cuối cùng: Context7 + Fetch MCP

### Nội dung gộp từ `tmp/MCP_FINAL_TEST_REPORT.md`

```text
# Báo Cáo Test Cuối Cùng - Context7 và Fetch MCP

## Ngày: 2025-01-20

## ✅ KẾT QUẢ TEST

### 1. Context7 MCP ✅ HOẠT ĐỘNG

**Package**: `@upstash/context7-mcp@latest`

**Test Result**:
Context7 Documentation MCP Server v2.1.0 running on stdio

... (xem lại full content trong git history nếu cần) ...
```

---

## 3) Báo cáo chi tiết offerings/tools của Context7 + Fetch

### Nội dung gộp từ `tmp/MCP_TOOLS_DETAILED_REPORT.md`

```text
# Báo Cáo Chi Tiết Tools Của Context7 và Fetch MCP

## Ngày: 2025-01-20

## 📊 TỔNG QUAN TỪ LOG CURSOR
... (xem lại full content trong git history nếu cần) ...
```

---

## 4) Danh sách MCP servers và tools (theo mcp.json thời điểm đó)

### Nội dung gộp từ `tmp/MCP_SERVERS_AND_TOOLS.md`

```text
# Danh sách MCP Servers và Tools
... (xem lại full content trong git history nếu cần) ...
```

---

## 5) Fix Fetch MCP “No server info found”

### Nội dung gộp từ `tmp/MCP_FETCH_FIX.md`

```text
# Sửa Lỗi Fetch MCP - "No server info found"
... (xem lại full content trong git history nếu cần) ...
```

---

## 6) Báo cáo sửa lỗi MCP Fetch và Context7 (tổng hợp)

### Nội dung gộp từ `tmp/MCP_FIX_REPORT.md`

```text
# Báo Cáo Sửa Lỗi MCP Fetch và Context7
... (xem lại full content trong git history nếu cần) ...
```

---

## 7) Kiểm tra tools Context7 & Fetch (bản ngắn)

### Nội dung gộp từ `tmp/MCP_TOOLS_CHECK.md`

```text
# Kiểm Tra Tools Của Context7 và Fetch MCP
... (xem lại full content trong git history nếu cần) ...
```

---

## 8) Prompt yêu cầu AI dùng Supabase MCP để lấy tables

### Nội dung gộp từ `tmp/GET_TABLES_VIA_MCP.md`

```text
# Yêu cầu AI sử dụng Supabase MCP để lấy thông tin Tables
... (xem lại full content trong git history nếu cần) ...
```

---

## 9) Supabase tables summary (thời điểm API trả 404)

### Nội dung gộp từ `tmp/SUPABASE_TABLES_SUMMARY.md`

```text
# Danh sách Tables trong Supabase Database
... (xem lại full content trong git history nếu cần) ...
```

---

## 10) Ghi chú dọn dẹp

- Các file sau đã/đang được coi là **temporary artifacts** và có thể xóa sau khi đã có file archive này:
  - `tmp/MCP_DEBUG_SUMMARY.md`
  - `tmp/MCP_FINAL_TEST_REPORT.md`
  - `tmp/MCP_TOOLS_DETAILED_REPORT.md`
  - `tmp/MCP_SERVERS_AND_TOOLS.md`
  - `tmp/MCP_FETCH_FIX.md`
  - `tmp/MCP_FIX_REPORT.md`
  - `tmp/MCP_TOOLS_CHECK.md`
  - `tmp/GET_TABLES_VIA_MCP.md`
  - `tmp/SUPABASE_TABLES_SUMMARY.md`

