# Phase 9: AI Settings Refactor & Document Import - Context

**Gathered:** 2026-04-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 9 cải thiện trải nghiệm tạo câu hỏi AI theo 2 hướng:
1. **Refactor Settings**: Tạo màn hình AI Settings mới, tách khỏi general settings, gear icon link trực tiếp đến đây
2. **Document Import**: Giáo viên upload file Excel/Word, AI phân tích theo 2 pipeline độc lập và trả về List<QuestionDTO> thống nhất

Không bao gồm: Pinecone external setup, general settings refactor, student-facing features.

</domain>

<decisions>
## Implementation Decisions

### Settings Screen Refactor

- **D-01:** Tạo màn hình mới `AiQuestionSettingsScreen` — hoàn toàn tách biệt với `SettingsScreen` (general settings)
- **D-02:** Gear icon trên `TeacherAiGenerateQuestionScreen` (line 904) đổi route từ `AppRoute.settingsPath` sang route mới của `AiQuestionSettingsScreen`
- **D-03:** `AiQuestionSettingsScreen` gồm 2 phần:
  - Tile/nút "Cài đặt API Key" → push đến `ApiKeySetupScreen` (existing, không thay đổi)
  - Section "Thư viện Tài liệu" — quản lý file đã upload (list + [+] thêm mới)

### Knowledge Library Architecture

- **D-04:** Files LUÔN được lưu persistent — không bao giờ throw away sau 1 lần dùng (Knowledge Library model, không phải Incinerator model)
- **D-05:** File upload pipeline (5 bước):
  1. Upload binary lên Supabase Storage (`teachers/{teacher_id}/{filename}`)
  2. INSERT vào `files` table (metadata + URL)
  3. INSERT vào `file_links` (`target_type='teacher'`, `target_id=teacher_id`)
  4. INSERT vào `ai_queue` payload `{"file_id": "uuid", "action": "extract_or_vectorize"}` — AI Worker xử lý ngầm
  5. UI hiển thị chip ngay lập tức — **không chờ AI chạy xong**
- **D-06:** `file_links.target_type = 'teacher'`, `target_id = teacher_id (profile UUID)` — file là Intellectual Property của giáo viên, đi theo profile suốt đời, không bị giới hạn theo lớp. Tính đa hình: cùng 1 file vật lý có thể có thêm link `target_type='assignment'` khi được đính kèm vào bài tập — INSERT thêm 1 dòng, không duplicate file.

### Context Sources UI (TeacherAiGenerateQuestionScreen)

- **D-07:** Thêm section "📚 Nguồn Dữ Liệu Tham Khảo" vào `TeacherAiGenerateQuestionScreen`
- **D-08:** Hiển thị dạng Chip/Tag có thể tick chọn — liệt kê các file đã upload từ trước (query qua `file_links` của teacher)
- **D-09:** Nút [+] Thêm tài liệu mới — mở file picker, chạy upload pipeline ngầm, file mới xuất hiện dưới dạng chip đã tick

### AI Processing Mode Toggle

- **D-10:** Bắt buộc có UI Toggle cho phép giáo viên chọn mode rõ ràng — không dùng "God Prompt" tự đoán intent
- **D-11:** 2 mode:
  - **Trích xuất** (Extraction): File đã có câu hỏi sẵn (đề thi cũ, bộ câu hỏi)
  - **Sinh câu hỏi** (Generation): Tài liệu học, giáo trình (AI sáng tác dựa trên nội dung)

### Extraction Pipeline (Luồng 1 — "Nhà máy Tái chế")

- **D-12:** Xử lý: Parse file → Direct LLM call với Few-Shot Prompting → Strict JSON output
- **D-13:** KHÔNG qua Vector DB — fast path, xử lý vài chục giây
- **D-14:** Prompt dùng kỹ thuật Few-Shot: bơm format chuẩn của bảng `questions` vào prompt, ép AI nhả ra đúng schema
- **D-15:** Yêu cầu độ chính xác tuyệt đối — AI không được tự chế thêm nội dung ngoài file

### Generation Pipeline (Luồng 2 — "Nhà máy Chế tác") — RAG Architecture

- **D-16 (REVISED):** Dùng **RAG + pgvector** cho cả Phase 9 — KHÔNG dùng Long Context Window. Lý do: Decouple hoàn toàn Data Pipeline khỏi LLM Provider, tránh Vendor Lock-in (Gemini/Groq/Ollama đều hoạt động), Single Pipeline duy nhất dễ maintain.
- **D-17:** Chunking — dùng `RecursiveCharacterTextSplitter`: `chunk_size=500 tokens`, `chunk_overlap=100 tokens`. Cắt theo dấu câu/xuống dòng trước, khoảng trắng sau. Overlap đảm bảo Semantic Integrity — không bao giờ cắt đứt giữa câu.
- **D-18:** Embedding — gọi Embedding Model (text-embedding-3-small hoặc nomic-embed-text mã nguồn mở) để biến mỗi chunk thành vector float array. Lưu vào bảng `document_chunks` (file_id, chunk_text, embedding vector).
- **D-19:** pgvector trên Supabase — `CREATE EXTENSION vector;` + bảng `document_chunks`. Không cần Pinecone external.
- **D-20:** Batch processing qua `ai_queue` để tránh OOM (500MB RAM Free Tier): Edge Function xử lý 10 trang/lần → chunking → embedding → lưu → sleep 2s → 10 trang tiếp. Async hoàn toàn.
- **D-21:** Retrieval khi sinh câu hỏi: Query = vector hoá câu hỏi của GV → Cosine Similarity trên `document_chunks` → lấy Top 5 chunks (~2500 tokens) → nhét vào CO-STAR prompt → AI sinh câu hỏi.
- **D-22:** CO-STAR Prompt template cho Generation Pipeline:
  - `[Context]` — tài liệu trích xuất từ DB, giới hạn nghiêm ngặt
  - `[Objective]` — tạo N câu hỏi dựa HOÀN TOÀN vào tài liệu
  - `[Constraint]` — nếu không đủ thông tin → trả `[]`, KHÔNG tự bịa
  - `[Response Format]` — JSON Array chuẩn `List<QuestionDTO>`
- **D-23:** Temperature cao hơn Luồng 1 — cho phép tính sáng tạo trong ngữ cảnh được cung cấp

### Unified DTO Output

- **D-24:** Cả 2 pipeline đều trả về cùng 1 format: `List<QuestionDTO>` — same JSON schema
- **D-25:** Flutter Frontend không biết và không cần biết pipeline nào đã chạy — Clean Architecture. Tầng Data hoàn toàn Decoupled khỏi LLM Provider.

### Staging Area & Output Flow

- **D-26:** Sau khi AI trả về List<QuestionDTO>, hiển thị "Staging Area" — giáo viên xem trước, chỉnh sửa nếu cần
- **D-27:** 2 nút action:
  - **[Lưu vào Ngân hàng]** → INSERT vào bảng `questions` only
  - **[Lưu và Thêm vào Đề thi]** → DB Transaction: INSERT questions → lấy UUIDs → INSERT assignment_questions (với assignment_id hiện tại)
- **D-28:** Không có Option "Thêm thẳng vào Đề thi mà không lưu Bank" — tránh Orphan Data

### Claude's Discretion

- Animation/loading state khi pipeline đang xử lý (progress indicator, estimated time)
- Error handling cho file parse failures (file bị hỏng, format không hỗ trợ)
- File size limit và supported MIME types cụ thể
- Cách hiển thị staging area (bottom sheet vs full screen)

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Schema — Files & File Links & Chunks
- `db/schema_03_submissions_ai_analytics.sql` — Định nghĩa `files` table (storage_path, mime_type, metadata, uploaded_by) và `file_links` table (polymorphic: file_id, target_type, target_id)
- Cần tạo migration mới: bảng `document_chunks` (file_id, chunk_index, chunk_text, embedding vector) + `CREATE EXTENSION vector;`
- Cần tạo migration mới: thêm `target_type='teacher'` vào check constraint của `file_links` (nếu có)

### Schema — Questions & Assignments
- `db/schema_02_questions_assignments.sql` — Định nghĩa `questions` table và `assignment_questions` table (để hiểu DB Transaction ở D-24)

### Existing AI Screen (thay đổi nhiều nhất)
- `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart` — 3127 dòng, gear icon tại line 904, existing save-to-bank flow để tái dùng pattern

### Existing Settings Screens (reference, không thay đổi)
- `lib/presentation/views/settings/settings_screen.dart` — General settings (giữ nguyên, không sửa)
- `lib/presentation/views/settings/api_key_setup_screen.dart` — 2371 dòng, AiQuestionSettingsScreen sẽ link đến đây

### Routes
- `lib/core/routes/route_constants.dart` — Cần thêm route mới cho AiQuestionSettingsScreen
- `lib/core/routes/app_router.dart` — Cần wire route mới

### AI Service (tham khảo pattern gọi LLM)
- `lib/core/services/ai_service.dart` — Pattern hiện tại để gọi Gemini/Groq/Ollama

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `_handleSaveToQuestionBank()` trong `TeacherAiGenerateQuestionScreen` — existing save-to-bank logic, reuse/extend cho D-24
- `ApiKeySetupScreen` — giữ nguyên, `AiQuestionSettingsScreen` chỉ navigation đến nó
- `ai_queue` infrastructure (Phase 7) — tái dùng cho RAG batch processing. Action mới: `'vectorize_document'`. Batch 10 trang/lần, sleep 2s giữa các batch tránh OOM.

### Established Patterns
- File upload flow đã có trong student workspace (tham khảo cho upload UI)
- Gemini/Groq/Ollama provider switching đã implement trong `ApiKeySetupScreen` — Edge Function cũng dùng cùng provider
- Save-to-bank + confirm dialog pattern đã có — extend thêm 1 button

### Integration Points
- Gear icon route change: `teacher_ai_generate_question_screen.dart` line 904
- New route: `route_constants.dart` + `app_router.dart`
- File upload: cần Supabase Storage bucket config + `files` datasource mới
- DB Transaction endpoint: cần RPC hoặc Edge Function cho "Lưu và Thêm vào Đề thi"

</code_context>

<specifics>
## Specific Ideas

- **Kiến trúc tư duy "Lò đốt rác vs Thư viện Tri thức"**: Files là Data Asset của trường, không phải throwaway. Lưu vào `files` + `file_links` để AI có thể reuse.
- **Kiến trúc tư duy "Trạm phân luồng cao tốc"**: UI Toggle → người dùng declare intent → Backend route đúng pipeline. Không dùng "God Prompt".
- **RAG = "Ổ cắm quốc tế"**: Chuẩn hoá đầu vào (Top 5 chunks ~2500 tokens), mọi LLM provider đều hoạt động. Tránh Vendor Lock-in. Single Pipeline — không maintain 2 luồng song song.
- **"Cửa hàng trưng bày và Đơn hàng"**: Staging Area xem trước → 1-click lưu cả Bank + Assignment (DB Transaction). Không để Orphan Data.

</specifics>

<deferred>
## Deferred Ideas

- **Pinecone external** — pgvector đủ dùng cho Phase 9. Upgrade Pinecone chỉ khi > hàng chục nghìn tài liệu.
- **AI Grading từ tài liệu** — Dùng uploaded docs làm grading rubric. Liên quan Phase 3 (Rubric System).
- **Analytics section trong settings** — `ApiKeySetupScreen` có phần "Phân tích dữ liệu học tập" riêng, không thuộc scope Phase 9.
- **PDF support** — User chỉ đề cập Excel + Word. PDF có thể thêm sau.

</deferred>

---

*Phase: 09-ai-settings-refactor-document-import*
*Context gathered: 2026-04-18*
