# Phase 9: AI Settings Refactor & Document Import - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-04-18
**Phase:** 09-ai-settings-refactor-document-import
**Areas discussed:** Settings Scope, Document Storage Architecture, AI Processing Mode, Vector DB Strategy, Output Flow

---

## Settings Scope

| Option | Description | Selected |
|--------|-------------|----------|
| A. AiQuestionSettingsScreen mới | Màn hình riêng, tách hoàn toàn, gear icon link thẳng | ✓ |
| B. Filter ApiKeySetupScreen | Thêm param context để ẩn bớt sections | |
| C. Scroll to section | Giữ nguyên, scroll đến đúng phần | |

**User's choice:** Option A — tạo màn hình mới hoàn toàn
**Notes:** Màn hình mới chứa 2 phần: (1) tile link đến ApiKeySetupScreen, (2) section document library chuẩn bị cho Phase 9

---

## Document Storage Architecture

| Option | Description | Selected |
|--------|-------------|----------|
| A. Knowledge Library | Files lưu persistent vào files + file_links, tái sử dụng nhiều lần | ✓ |
| B. Incinerator | Upload 1 lần, xử lý, throw away | |
| C. Hybrid | Tùy chọn lưu hoặc không lưu | |

**User's choice:** Option A — bắt buộc, không có ngoại lệ
**Notes:** Kiến trúc "Thư viện Tri thức". Files là Data Asset của trường. Lưu vào Supabase Storage → `files` table → `file_links` (target_type='teacher_document'). UI hiển thị Chip/Tag selector — files cũ liệt kê sẵn để tick, nút [+] thêm mới.

---

## AI Processing Mode

| Option | Description | Selected |
|--------|-------------|----------|
| A. Cả hai mode với UI Toggle | Extraction + Generation, user chọn intent | ✓ |
| B. Chỉ Extraction | Extract câu hỏi từ file có sẵn | |
| C. Chỉ Generation RAG | Sinh câu hỏi từ tài liệu học | |

**User's choice:** Option A — bắt buộc, không có ngoại lệ
**Notes:** "Trạm phân luồng cao tốc". UI Toggle bắt buộc để user declare intent. Không dùng "God Prompt" vì gây context confusion. 2 pipeline độc lập hoàn toàn — Extraction (Few-Shot, fast, strict) và Generation (Long Context, creative, CO-STAR).

---

## Vector DB Strategy (Q3)

| Option | Description | Selected |
|--------|-------------|----------|
| pgvector (Supabase native) | Có hỗ trợ nhưng 500MB RAM Free tier dễ OOM | |
| External (Pinecone, Weaviate) | Chuẩn enterprise nhưng tốn chi phí infra | |
| Long Context Window (MVP) | Gemini 1.5 Pro 1M tokens đọc file trực tiếp | ✓ |

**User's choice:** Long Context Window — bỏ qua Vector DB hoàn toàn cho Phase 9
**Notes:** Serverless 100%, zero infra cost. Parse file → plain text → nhét toàn bộ vào prompt với CO-STAR. Upgrade lên Pinecone chỉ khi scale tới hàng chục nghìn tài liệu.

---

## Output Flow (Q4)

| Option | Description | Selected |
|--------|-------------|----------|
| A. Chỉ lưu Question Bank | INSERT questions only | |
| B. Chọn: Bank hoặc Bank + Assignment | 2 nút trong Staging Area | ✓ |
| C. Thêm thẳng Assignment | Bypass bank, gây Orphan Data | |

**User's choice:** Option B — bắt buộc
**Notes:** Staging Area để xem trước. Nút [Lưu vào Ngân hàng] chỉ INSERT questions. Nút [Lưu và Thêm vào Đề thi] = DB Transaction: INSERT questions → lấy UUIDs → INSERT assignment_questions. Option C bị loại vì tạo Orphan Data — câu hỏi không tồn tại trong Bank, không thể tái sử dụng.

---

## Claude's Discretion

- Loading state / progress indicator khi pipeline xử lý file
- Error handling cho file hỏng hoặc format không hỗ trợ
- File size limits và MIME type validation
- Layout staging area (bottom sheet vs full screen)
- Animation khi file mới xuất hiện thành chip sau upload

## Deferred Ideas

- Vector DB / RAG đầy đủ (Pinecone) — Phase 10+ khi scale
- PDF support — chưa trong scope, thêm sau
- AI Grading dùng uploaded docs làm rubric — liên quan Phase 3
- Analytics AI settings section — không thuộc Phase 9
