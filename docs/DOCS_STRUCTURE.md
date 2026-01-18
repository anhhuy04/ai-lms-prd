# Cấu Trúc Thư Mục Documentation - AI LMS Project

**Ngày tạo:** 2026-01-16  
**Mục đích:** Mô tả cấu trúc thư mục và mục đích của từng file documentation trong dự án

> **⚠️ QUAN TRỌNG:** File này được tự động cập nhật khi tạo file markdown mới.  
> **File trung tâm điều phối:** `.clinerules` - Tất cả quy tắc và references chính đều nằm trong file này.

---

## 🎯 File Trung Tâm Điều Phối

**`.clinerules`** là file TRUNG TÂM điều phối tất cả quy tắc và hướng dẫn trong dự án.

**Cấu trúc điều phối:**
```
.clinerules (TRUNG TÂM)
  ├── → docs/ai/AI_INSTRUCTIONS.md (Core instructions)
  ├── → docs/DOCS_STRUCTURE.md (Cấu trúc docs - file này)
  ├── → memory-bank/ (Context & memory)
  └── → Các quy tắc và patterns khác
```

**Quy tắc:**
- ✅ Tất cả quy tắc chính → `.clinerules`
- ✅ Chi tiết kỹ thuật → `docs/ai/AI_INSTRUCTIONS.md`
- ✅ Cấu trúc docs → `docs/DOCS_STRUCTURE.md` (file này)
- ✅ Context dự án → `memory-bank/`

**Khi tạo file mới:**
1. Đọc `.clinerules` để hiểu quy tắc chung
2. Đọc `docs/DOCS_STRUCTURE.md` để biết cấu trúc
3. Tạo file theo đúng cấu trúc
4. Cập nhật `docs/DOCS_STRUCTURE.md`

---

## 📁 Tổng Quan Cấu Trúc

```
docs/
├── ai/                          # 📘 AI Agent Documentation
│   ├── AI_INSTRUCTIONS.md       # Core instructions cho AI agents
│   ├── DOCS_PROMPT_RULES.md     # Rules tạo documentation
│   ├── MCP_GUIDE.md             # Hướng dẫn sử dụng MCP servers
│   ├── MEMORY_MCP_PROMPT.md     # Memory MCP usage guide
│   ├── CURSOR_SETUP.md          # Cursor IDE setup guide
│   └── README_SUPABASE.md       # Database schema reference
│
├── guides/                      # 📗 Human-Readable Guides
│   ├── development/            # Developer guides
│   ├── features/               # Feature-specific documentation
│   └── tools/                  # Tools & utilities guides
│
├── reports/                     # 📊 Reports & Analysis
│   └── optimization-report.md  # Optimization reports
│
└── DOCS_STRUCTURE.md           # 📋 File này - Cấu trúc docs

memory-bank/                     # 🧠 AI Agent Memory (KHÔNG ĐỔI)
├── projectbrief.md              # Tổng quan dự án
├── productContext.md            # Context sản phẩm
├── activeContext.md             # Context hiện tại
├── systemPatterns.md            # Patterns hệ thống
├── techContext.md               # Context kỹ thuật
├── progress.md                  # Tiến độ dự án
└── DESIGN_SYSTEM_GUIDE.md       # Design system guide
```

---

## 📘 AI Agent Documentation (`docs/ai/`)

**Mục đích:** Tài liệu dành cho AI agents khi làm việc với dự án.

### Files:

| File | Mục đích | Khi nào đọc |
|------|----------|-------------|
| `AI_INSTRUCTIONS.md` | Core instructions, architecture rules, patterns | **BẮT BUỘC** trước mọi task |
| `DOCS_PROMPT_RULES.md` | Rules tạo/cập nhật markdown files | Trước khi tạo file .md mới |
| `MCP_GUIDE.md` | Hướng dẫn sử dụng MCP servers | Khi cần dùng MCP tools |
| `MEMORY_MCP_PROMPT.md` | Memory MCP usage patterns | Khi cần lưu context |
| `CURSOR_SETUP.md` | Cursor IDE và MCP setup | Khi setup môi trường |
| `README_SUPABASE.md` | Database schema reference | Khi làm việc với database |

**Quy tắc:**
- ✅ Chỉ AI agents đọc
- ✅ Không sửa trừ khi có yêu cầu
- ✅ Reference trong `.clinerules`

---

## 📗 Human-Readable Guides (`docs/guides/`)

**Mục đích:** Tài liệu dành cho developers, testers, và users.

### 1. Developer Guides (`docs/guides/development/`)

**Mục đích:** Hướng dẫn cho developers khi phát triển.

| File | Mục đích | Khi nào đọc |
|------|----------|-------------|
| `context-reading-protocol.md` | Protocol đọc tài liệu trước khi thực hiện task | **BẮT BUỘC** - Trước mọi task để biết đọc tài liệu nào |
| `environment-setup.md` | Hướng dẫn setup environment variables với envied | Khi setup dev/staging/prod environments |
| `qr-code-usage.md` | Hướng dẫn sử dụng QR code với QrHelper | Khi cần generate QR codes |
| `quick-reference.md` | Quick reference cho các fixes/features | Khi cần tra cứu nhanh |
| `screen-usage-guide.md` | Hướng dẫn sử dụng các screens | Khi implement screens mới |
| `responsive-system-guide.md` | Hướng dẫn responsive system | Khi làm UI responsive |
| `mvvm-integration-guide.md` | Hướng dẫn tích hợp MVVM | Khi tạo ViewModel mới |
| `database-schema-summary.md` | Tóm tắt database schema | Khi làm việc với database |

**Quy tắc:**
- ✅ Developers đọc để hiểu patterns
- ✅ Có thể cập nhật khi có thay đổi
- ✅ Sử dụng kebab-case naming

### 2. Feature Documentation (`docs/guides/features/`)

**Mục đích:** Tài liệu cho từng feature cụ thể.

#### Cấu trúc:
```
docs/guides/features/
└── {feature-name}/          # Tên feature (kebab-case)
    ├── index.md            # Overview và index
    ├── {specific-doc}.md   # Các docs cụ thể
    └── ...
```

#### Ví dụ: Delete Class Feature (`docs/guides/features/delete-class/`)

| File | Mục đích |
|------|----------|
| `index.md` | Overview và index tất cả docs về feature |
| `fixes-overview.md` | Overview các fixes đã thực hiện |
| `fix-summary.md` | Chi tiết các fixes |
| `testing-guide.md` | Hướng dẫn test feature |
| `debugging-guide.md` | Hướng dẫn debug |
| `function-review.md` | Code review |
| `issue-analysis.md` | Phân tích issues |
| `rls-check-report.md` | Database/RLS check report |

**Quy tắc:**
- ✅ Mỗi feature có folder riêng
- ✅ Tên folder: kebab-case (ví dụ: `delete-class`, `assignment-builder`)
- ✅ Luôn có `index.md` làm entry point
- ✅ Các docs cụ thể: kebab-case naming

### 3. Tools Guides (`docs/guides/tools/`)

**Mục đích:** Hướng dẫn sử dụng tools và utilities.

| File | Mục đích |
|------|----------|
| `read-logs.md` | Hướng dẫn đọc Flutter logs |

**Quy tắc:**
- ✅ Tools guides cho developers
- ✅ Kebab-case naming

---

## 📊 Reports (`docs/reports/`)

**Mục đích:** Báo cáo và phân tích.

| File | Mục đích |
|------|----------|
| `optimization-report.md` | Báo cáo tối ưu hóa |

**Quy tắc:**
- ✅ Reports về performance, optimization
- ✅ Kebab-case naming

---

## 🧠 Memory Bank (`memory-bank/`)

**Mục đích:** Context và memory cho AI agents (KHÔNG ĐỔI).

| File | Mục đích |
|------|----------|
| `projectbrief.md` | Tổng quan dự án |
| `productContext.md` | Context sản phẩm |
| `activeContext.md` | Context hiện tại và next steps |
| `systemPatterns.md` | Patterns và kiến trúc |
| `techContext.md` | Tech stack và setup |
| `progress.md` | Tiến độ và status |
| `DESIGN_SYSTEM_GUIDE.md` | Design system guide |

**Quy tắc:**
- ✅ **KHÔNG di chuyển** files trong memory-bank
- ✅ Chỉ AI agents đọc
- ✅ Cập nhật sau mỗi thay đổi quan trọng

---

## 📋 Quy Tắc Đặt Tên

### Naming Convention:

1. **Folders:**
   - ✅ Kebab-case: `delete-class`, `assignment-builder`
   - ❌ Không dùng: `DeleteClass`, `delete_class`

2. **Files:**
   - ✅ Kebab-case: `quick-reference.md`, `testing-guide.md`
   - ❌ Không dùng: `QuickReference.md`, `TESTING_GUIDE.md`

3. **Feature folders:**
   - ✅ Tên feature: `delete-class`, `create-assignment`
   - ✅ Descriptive: `student-workspace`, `ai-grading`

---

## 🎯 Quy Tắc Tạo File Mới

### Khi tạo file markdown mới:

1. **Xác định loại:**
   - AI Agent doc → `docs/ai/`
   - Developer guide → `docs/guides/development/`
   - Feature doc → `docs/guides/features/{feature-name}/`
   - Tool guide → `docs/guides/tools/`
   - Report → `docs/reports/`

2. **Đặt tên:**
   - Sử dụng kebab-case
   - Descriptive name
   - Ví dụ: `assignment-builder-guide.md`

3. **Cập nhật `DOCS_STRUCTURE.md`:**
   - Thêm file vào bảng tương ứng
   - Mô tả mục đích và khi nào đọc

4. **Cập nhật index (nếu có):**
   - Nếu là feature doc, cập nhật `index.md` trong feature folder
   - Thêm link đến file mới

---

## 📝 Template Tạo File Mới

### Template: Developer Guide

```markdown
# {Title} - AI LMS

## Tổng quan

[Mô tả ngắn gọn]

## Nội dung

[Chi tiết]

## Tài liệu tham khảo

- [Link đến docs liên quan](./other-guide.md)
```

### Template: Feature Doc

```markdown
# {Feature Name} - {Specific Doc Type}

## Mục đích

[Mô tả mục đích của doc này]

## Nội dung

[Chi tiết]

## Related Docs

- [Index](./index.md)
- [Other docs](./other-doc.md)
```

---

## 🔗 Links Quan Trọng

### Core Files (Thứ tự ưu tiên):
1. **`.clinerules`** - ⭐ **FILE TRUNG TÂM** - Core rules và quy tắc điều phối
2. `docs/ai/AI_INSTRUCTIONS.md` - Core instructions cho AI agents
3. `docs/DOCS_STRUCTURE.md` - File này - Cấu trúc documentation
4. `memory-bank/` - Context và memory cho AI agents

### Index Files:
- `docs/guides/features/{feature-name}/index.md` - Feature index

---

## ✅ Checklist Khi Tạo File Mới

**BẮT BUỘC theo thứ tự:**
1. [ ] Đọc `.clinerules` để hiểu quy tắc chung
2. [ ] Đọc `docs/DOCS_STRUCTURE.md` (file này) để hiểu cấu trúc
3. [ ] Xác định đúng loại (AI/Human/Feature/Tool/Report)
4. [ ] Đặt tên đúng kebab-case
5. [ ] Tạo file ở đúng vị trí
6. [ ] **Cập nhật `docs/DOCS_STRUCTURE.md` (file này)** - BẮT BUỘC
7. [ ] Cập nhật index nếu là feature doc
8. [ ] Thêm links đến docs liên quan
9. [ ] Test links hoạt động

---

## 📊 Thống Kê

### Tổng số files:
- **AI Agent docs:** 7 files (`docs/ai/` + `memory-bank/`)
- **Developer guides:** 8 files (thêm: context-reading-protocol.md, environment-setup.md, qr-code-usage.md)
- **Feature docs:** 8 files (delete-class feature)
- **Tools guides:** 1 file
- **Reports:** 1 file
- **Total:** ~25 files

### Cập nhật lần cuối:
- **Date:** 2026-01-17
- **Version:** 1.1
- **Status:** ✅ Active
- **Changes:** Thêm context-reading-protocol.md, environment-setup.md, qr-code-usage.md

---

## 🚀 Maintenance

File này được tự động cập nhật khi:
- ✅ Tạo file markdown mới
- ✅ Di chuyển file
- ✅ Xóa file
- ✅ Thay đổi cấu trúc

**Lưu ý:** 
- Khi tạo file mới, **BẮT BUỘC** cập nhật file này theo quy tắc trong `.clinerules`
- `.clinerules` là file trung tâm điều phối - tất cả quy tắc chính đều ở đó

---

## 📖 Đọc Thêm

- **File trung tâm:** `.clinerules` - Tất cả quy tắc và references
- **AI Instructions:** `docs/ai/AI_INSTRUCTIONS.md` - Chi tiết kỹ thuật
- **Memory Bank:** `memory-bank/` - Context dự án

---

**Last Updated:** 2026-01-16  
**Maintained by:** AI Assistant (auto-update)  
**Reference:** `.clinerules` - Docs & Memory Prompt section
