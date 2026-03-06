# AI LMS PRD - Autonomous Workflow
# Hướng dẫn vận hành tự động cho AI Agent

## Quick Start

**Để bắt đầu một phiên làm việc mới:**
1. Đọc `memory-bank/activeContext.md` để hiểu context hiện tại
2. Đọc `memory-bank/progress.md` để xem tiến độ
3. Đọc `.clinerules` để hiểu quy tắc cốt lõi
4. Bắt đầu với task được mô tả trong phần "Currently In Progress" của activeContext.md

---

## Session Start Protocol

### Bước 1: Đọc Context (BẮT BUỘC - 2 phút)

```bash
# Đọc các file memory-bank quan trọng
memory-bank/activeContext.md    # Context hiện tại
memory-bank/progress.md         # Tiến độ dự án
.clinerules                     # Quy tắc cốt lõi
```

### Bước 2: Xác định Task (1 phút)

- Đọc phần "Currently In Progress" trong activeContext.md
- Đọc phần "Immediate Next Steps" để biết cần làm gì tiếp theo
- Nếu có task cụ thể từ user → Tiến hành luôn

### Bước 3: Đọc Technical Context (3-5 phút)

```bash
# Đọc system patterns và tech context
memory-bank/systemPatterns.md    # Patterns hệ thống
memory-bank/techContext.md      # Tech stack và setup
docs/ai/AI_INSTRUCTIONS.md     # Hướng dẫn AI
```

---

## Task Execution Protocol

### Quy trình thực hiện một feature mới:

```
1. PHÂN TÍCH TASK
   ↓
2. ĐỌC RELATED DOCS (xem Protocol bên dưới)
   ↓
3. KIỂM TRA SCHEMA (nếu liên quan Supabase)
   ↓
4. IMPLEMENT CODE
   ↓
5. CHẠY ANALYZE & FORMAT
   ↓
6. UPDATE MEMORY BANK
   ↓
7. COMMIT (nếu cần)
```

### Protocol Đọc Related Docs:

**Task liên quan đến UI:**
- Đọc `memory-bank/DESIGN_SYSTEM_GUIDE.md`
- Đọc `memory-bank/systemPatterns.md` (Design System section)
- Kiểm tra `lib/core/constants/design_tokens.dart`

**Task liên quan đến Database:**
- Dùng Supabase MCP để kiểm tra schema
- Đọc `docs/ai/README_SUPABASE.md`
- Đọc `memory-bank/systemPatterns.md` (Data Layer section)

**Task liên quan đến State Management:**
- Đọc `memory-bank/systemPatterns.md` (State Management section)
- Kiểm tra pattern trong `lib/presentation/providers/`

**Task liên quan đến Routing:**
- Đọc `.clinerules` (Router & Navigation section)
- Kiểm tra `lib/core/routes/route_constants.dart`
- Kiểm tra `lib/core/routes/app_router.dart`

---

## Autonomous Decision Making

### AI được phép tự quyết định:

1. **Code Structure:**
   - Tạo file mới trong đúng vị trí theo Clean Architecture
   - Tách widget khi cần (≥50 dòng → tách)
   - Sử dụng composition pattern

2. **UI/UX:**
   - Sử dụng DesignTokens có sẵn
   - Thêm shimmer loading khi cần
   - Sử dụng optimistic updates

3. **Error Handling:**
   - Sử dụng ErrorTranslationUtils
   - Thêm try-catch khi cần
   - Log với AppLogger

4. **Performance:**
   - Parallel fetching với Future.wait()
   - Pagination khi cần
   - Shimmer loading thay vì spinner

### AI cần hỏi user:

1. **Thay đổi Architecture lớn:**
   - Thay đổi state management pattern
   - Thay đổi routing approach
   - Thêm thư viện mới (ngoài tech stack)

2. **Quyết định business:**
   - Logic nghiệp vụ phức tạp
   - Quyền truy cập dữ liệu
   - UX flow quan trọng

3. **Rủi ro:**
   - Xóa file quan trọng
   - Thay đổi schema database
   - Refactoring lớn

---

## MCP Usage Protocol

### Supabase MCP:
```bash
# Luôn luôn kiểm tra schema trước khi tạo model
→ list_tables
→ execute_sql (SELECT * FROM table LIMIT 1)

# Khi cần query data cho user
→ execute_sql (SELECT ...)
```

### Context7 MCP:
```bash
# Tìm patterns trong codebase
→ search_code hoặc do_grep

# Tìm file liên quan
→ glob_file_search
```

### Fetch MCP:
```bash
# Đọc docs của thư viện mới
→ imageFetch (url từ pub.dev)
```

---

## Memory Bank Update Protocol

### Sau mỗi task hoàn thành:

1. **Cập nhật activeContext.md:**
   - Thêm vào "Recently Completed"
   - Cập nhật "Currently In Progress" nếu cần

2. **Cập nhật progress.md:**
   - Thêm completed items
   - Cập nhật status

3. **Tạo session note (nếu cần):**
   - File: `docs/ai/session-notes.md`
   - Format: ISO date + context + decisions + TODOs

### Format Session Note:

```markdown
## 2026-01-30T15:30Z

### Context
- Task: Student Class List Enhancement
- Files: student_class_list_screen.dart, class_providers.dart

### Decisions
- Sử dụng shimmer loading thay vì skeleton
- Thêm sorting A-Z/Z-A

### TODOs
- [ ] Implement filtering by status
- [ ] Add search screen

### References
- Related: docs/ai/AI_INSTRUCTIONS.md
```

---

## Git Workflow Protocol

### Commit Pattern:
```
[type] [description]

- [detail 1]
- [detail 2]
```

**Types:**
- `feat`: Feature mới
- `fix`: Bug fix
- `refactor`: Refactoring
- `docs`: Documentation
- `style`: Formatting
- `perf`: Performance

### Before Commit:
1. Chạy `flutter analyze` - không có errors
2. Chạy `dart format`
3. Kiểm tra không có debug logs

---

## Error Handling Protocol

### Khi gặp lỗi:

1. **Analyze lỗi:**
   - Đọc error message
   - Xác định nguyên nhân gốc

2. **Tìm solution:**
   - grep_search trong codebase
   - Xem docs liên quan
   - Thử fix

3. **Nếu không fix được:**
   - Ghi lại lỗi vào session notes
   - Tiếp tục task khác nếu có thể
   - Thông báo user nếu blocker

---

## Checkpoint Protocol

### Mỗi 30 phút:

1. **Kiểm tra progress:**
   - Đọc activeContext.md để xem đang ở đâu
   - Cập nhật nếu có thay đổi

2. **Kiểm tra memory:**
   - Đảm bảo đã update memory bank
   - Kiểm tra session notes

3. **Kiểm tra quality:**
   - flutter analyze đã chạy chưa
   - Code đã format chưa

---

## End Session Protocol

### Trước khi kết thúc:

1. **Hoàn thành current task:**
   - Nếu đang giữa chừng → ghi note
   - Nếu có thể hoàn thành → làm xong

2. **Update Memory Bank:**
   - activeContext.md: Recent sessions
   - progress.md: Nếu có milestone mới
   - session-notes.md: Ghi lại context

3. **Tổng kết:**
   - Liệt kê đã hoàn thành gì
   - Liệt kê còn dang dở
   - Đề xuất bước tiếp theo

---

## Quick Reference Card

| Situation | Action |
|-----------|--------|
| Bắt đầu phiên mới | Đọc activeContext.md + .clinerules |
| Task liên quan UI | Đọc DESIGN_SYSTEM_GUIDE.md |
| Task liên quan DB | Dùng Supabase MCP kiểm tra schema |
| Task liên quan State | Xem systemPatterns.md |
| Tạo file mới | Theo AI_INSTRUCTIONS.md structure |
| Gặp lỗi | Analyze → grep_search → Fix |
| Hoàn thành task | Update memory bank → Commit |
| Kết thúc phiên | Session notes + summary |

---

**Version:** 1.0
**Last Updated:** 2026-02-05
**Purpose:** Enable autonomous coding without constant human intervention
