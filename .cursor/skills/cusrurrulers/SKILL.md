---
name: cusrurrulers
description: This is a new rule
---

# Overview
# SMART CONTEXT READING PROTOCOL

## Nguyên tắc

`.clinerules` là file trung tâm điều phối. Đọc có chọn lọc theo task category, chỉ đọc sections liên quan, reference đến các file chi tiết khi cần. Tránh đọc toàn bộ file nếu chỉ cần một phần. Sử dụng `read_file` với offset và limit để đọc selective. Luôn bắt đầu với task classification.

## Workflow

### Bước 1: Phân loại Task

Xác định task category từ user request:
- **Category 1: UI/Widget** - Tạo/chỉnh sửa screen, widget, drawer, component
- **Category 2: Database/Repository/Model** - Tạo entity, model, repository, datasource, query, migration
- **Category 3: Documentation** - Tạo file markdown, documentation
- **Category 4: Architecture/Refactoring** - Refactor code, extract components, implement patterns
- **Category 5: Git Operations** - Commit, branch, merge operations
- **Category 6: MCP Operations** - Sử dụng MCP servers

### Bước 2: Đọc có chọn lọc theo Category

#### Category 1: UI/Widget (Flutter UI)

**Đọc:**
1. `.clinerules` - Section "Flutter Refactoring" (lines ~509-533)
2. `.clinerules` - Section "HTML → Dart Conversion" (lines ~174-508) - chỉ nếu convert HTML
3. `.clinerules` - Section "Drawer System" (lines ~535-581) - chỉ nếu làm drawer
4. `.clinerules` - Section "Flutter Architecture (MVVM & Clean Architecture)" (lines ~134-145)
5. `.clinerules` - Section "Code Quality" (lines ~147-159)
6. `memory-bank/systemPatterns.md` - Section "Widget Component Patterns" và "Design System Specifications"
7. `memory-bank/activeContext.md` - Section "Active Preferences & Standards"
8. `docs/ai/AI_INSTRUCTIONS.md` - Section 1 (Cấu trúc thư mục), Section 2 (Architecture), Section 3 (Presentation Layer), Section 4 (Design System nếu có)
9. `docs/guides/development/responsive-system-guide.md` - chỉ nếu cần responsive

**Không đọc:**
- Database & MCP sections
- Git Workflow
- Memory Bank Workflow
- Docs creation rules

**MCP Tools:** Dart MCP (format code sau khi viết), Supabase MCP (nếu cần query data)

#### Category 2: Database/Repository/Model

**Đọc:**
1. `.clinerules` - Section "Database & MCP" (lines ~31-37)
2. `.clinerules` - Section "Quy tắc sử dụng MCP Servers" (lines ~59-132)
3. `.clinerules` - Section "Flutter Architecture (MVVM & Clean Architecture)" (lines ~134-145)
4. `.clinerules` - Section "Code Quality" (lines ~147-159) - cho Repository
5. `docs/ai/README_SUPABASE.md` - Schema reference
6. `memory-bank/systemPatterns.md` - Section "Data Layer" và "Repository Pattern"
7. `memory-bank/techContext.md` - Section "Database Schema"
8. `docs/ai/AI_INSTRUCTIONS.md` - Section 1 (Cấu trúc thư mục), Section 2 (Architecture), Section 5 (Data Layer), Section 6 (Repository nếu có)

**Không đọc:**
- UI/Widget sections
- HTML conversion
- Flutter Refactoring (trừ khi cần)
- Docs creation rules

**MCP Tools:** Supabase MCP (check schema, query/check data)

#### Category 3: Documentation

**Đọc:**
1. `.clinerules` - Section "Docs & Memory Prompt" (lines ~39-57)
2. `docs/DOCS_STRUCTURE.md` - Toàn bộ file để hiểu cấu trúc
3. `docs/ai/DOCS_PROMPT_RULES.md` - Rules tạo docs

**Không đọc:**
- UI sections
- Database sections
- Code quality (trừ khi cần)
- Architecture details

**MCP Tools:** None

#### Category 4: Architecture/Refactoring

**Đọc:**
1. `.clinerules` - Section "Flutter Architecture (MVVM & Clean Architecture)" (lines ~134-145)
2. `.clinerules` - Section "Code Quality" (lines ~147-159)
3. `.clinerules` - Section "Flutter Refactoring" (lines ~509-533)
4. `memory-bank/systemPatterns.md` - Toàn bộ file
5. `docs/ai/AI_INSTRUCTIONS.md` - Section 2 (Architecture), Section 3 (Presentation Layer)
6. `memory-bank/activeContext.md` - Section "Active Preferences & Standards"

**Không đọc:**
- UI specific sections (trừ khi refactor UI)
- Database MCP details (trừ khi refactor data layer)
- HTML conversion
- Docs creation rules

**MCP Tools:** Dart MCP (analyze code, format)

#### Category 5: Git Operations

**Đọc:**
1. `.clinerules` - Section "Git Workflow" (lines ~165-172)

**Không đọc:**
- Tất cả sections khác

**MCP Tools:** None

#### Category 6: MCP Operations

**Đọc:**
1. `.clinerules` - Section "Quy tắc sử dụng MCP Servers" (lines ~59-132)
2. `docs/ai/MCP_GUIDE.md` - Chi tiết MCP usage
3. `memory-bank/techContext.md` - Section "MCP Setup"

**Không đọc:**
- UI sections
- Architecture details (trừ khi cần)
- Database details (trừ khi cần)

**MCP Tools:** Tùy theo MCP server cần sử dụng

### Bước 3: Thực hiện Task

Sau khi đọc đủ context theo category, thực hiện task theo patterns và standards đã đọc.

### Bước 4: Cập nhật (nếu cần)

Cập nhật memory-bank nếu có thay đổi quan trọng về patterns, standards, hoặc architecture.

## Lưu ý Implementation

- Luôn bắt đầu với task classification
- Sử dụng `read_file` với offset và limit để đọc selective sections
- Sử dụng `grep` để tìm sections cụ thể trước khi đọc
- Không đọc toàn bộ `.clinerules` nếu chỉ cần 1 section
- Không đọc memory-bank files nếu không liên quan đến task
- Reference đến files chi tiết chỉ khi cần thông tin cụ thể

## Ví dụ: Tạo UI mới

1. Phân loại: "tạo màn hình mới" → Category 1 (UI/Widget)
2. Đọc `.clinerules` lines 509-533 (Flutter Refactoring)
3. Đọc `.clinerules` lines 134-145 (Flutter Architecture)
4. Đọc `memory-bank/systemPatterns.md` section "Widget Component Patterns"
5. Đọc `docs/ai/AI_INSTRUCTIONS.md` section 1 (Cấu trúc thư mục)
6. Implement code theo patterns đã đọc
7. Sử dụng Dart MCP để format code

