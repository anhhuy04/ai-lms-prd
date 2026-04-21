# Design Spec: AI Generate Question Screen — 3-Mode Redesign

**Date:** 2026-04-21  
**Status:** Approved  
**Scope:** `teacher_ai_generate_question_screen.dart` · `ai_question_settings_screen.dart` · `ai_generation_settings_notifier.dart`

---

## 1. Bối cảnh & Vấn đề hiện tại

Màn hình tạo câu hỏi AI (`TeacherAiGenerateQuestionScreen`) hiện có:
- **2 chế độ** (`ProcessingMode.generation` / `ProcessingMode.extraction`) nhưng thực tế có **3 luồng khác nhau** về bản chất
- Cài đặt mode + file selection **ẩn trong `AiQuestionSettingsScreen`** — người dùng phải navigate ra ngoài để đổi mode, không có indicator nào trên màn chính
- **2 nút header trùng nhau** cùng navigate tới cùng một route
- Topic field **validate bắt buộc** dù ở mode extraction không cần topic
- Thiếu feedback trực quan về file đang được xử lý

---

## 2. Ba chế độ thực tế

### Mode 1 — ✏️ Nhập Prompt
- **Dùng khi:** Không có file sẵn, muốn AI sáng tác từ đầu
- **Input:** Topic text + quantity + difficulty + question types
- **Backend:** `aiRepository.generateQuestions()` — gọi LLM trực tiếp
- **Output:** Danh sách inline → user review → "Lưu Bank" hoặc "Xác nhận"
- **⚠️ KHÔNG thay đổi bất kỳ logic code nào của mode này**

### Mode 2 — 📥 Trích xuất
- **Dùng khi:** File **đã có câu hỏi sẵn** (đề thi cũ, bộ câu hỏi có sẵn)
- **AI không sáng tác** — chỉ đọc và trích xuất ra định dạng chuẩn
- **Input:** File Excel/Word (chọn inline trên màn chính)
- **Backend:**
  - Excel chuẩn header → `map()` thuần code, $0 API cost, ~0.1s
  - Excel lộn xộn / Word → gọi LLM nhưng chỉ extract
  - Flow: upload → `ai_queue` → poll → `result.extraction.questions`
- **Output:** `StagingAreaWidget` (bottom sheet xem trước)
- **File lifecycle:** Upload tạm → xử lý → **tự xóa** sau khi extract thành công

### Mode 3 — 📚 Từ Tài liệu
- **Dùng khi:** File là **giáo trình / tài liệu học** (chưa có câu hỏi)
- **AI sáng tác câu hỏi mới** dựa trên nội dung tài liệu
- **Input:** File + optional "hướng tập trung" text + quantity
- **Backend:** RAG pipeline — pgvector + embedding
- **Output:** Danh sách inline (giống Mode 1)
- **File lifecycle:** Upload tạm → vectorize → **tự xóa** sau khi generate xong

---

## 3. Kiến trúc UI — B+C Hybrid

### 3.1 Màn hình chính

```
Scaffold(
  backgroundColor: DesignColors.moonLight,
  endDrawer: _AiSettingsDrawer(),       ← NEW: thay thế navigate ra ngoài
  body: Column(
    children: [
      _AppHeader(),                      ← FIX: 1 nút ☰ duy nhất (bỏ nút thừa)
      _ModeTabsSection(),                ← NEW: 3 tabs inline
      _ModeBody(mode),                   ← NEW: context-aware body
      _BottomActionBar(),                ← EXISTING: không đổi logic
    ],
  ),
)
```

**`_ModeTabsSection`** — SegmentedButton 3 chế độ:
- Tap thay đổi `aiGenerationSettingsNotifierProvider.processingMode`
- Visual indicator màu theo mode: xanh dương / cam / xanh lá

**`_ModeBody`** — content thay đổi theo mode:
- **Mode 1:** Hiển thị đúng như hiện tại (topic, qty, difficulty, type chips, results)
- **Mode 2:** Hint card "chỉ đọc & trích xuất" + `ContextSourcesSection` inline + topic ẩn/mờ
- **Mode 3:** Hint card "AI RAG" + `ContextSourcesSection` inline + optional focus hint + qty

### 3.2 EndDrawer `_AiSettingsDrawer`

Thay thế việc navigate sang `AiQuestionSettingsScreen` cho các tác vụ thường dùng:

```
_AiSettingsDrawer (340px width, white)
├── Section: 🔑 API Key
│   └── ListTile → pushNamed(AppRoute.apiKeySetup)  [vẫn navigate như cũ]
├── Section: 📁 Thư viện tài liệu  
│   ├── Note: "File tạm thời — tự xóa sau khi xử lý"
│   ├── ListView: files từ teacherFilesProvider (status chip + nút xóa thủ công)
│   └── Nút "Tải file lên" → _pickAndUploadFile()
└── Section: 🛠 Công cụ
    └── ListTile → ExportTemplateBottomSheet.show()
```

### 3.3 `AiQuestionSettingsScreen` (giữ lại nhưng đơn giản hóa)

Bỏ:
- `SegmentedButton` ProcessingMode (chuyển sang màn chính)
- `ContextSourcesSection` (chuyển sang màn chính)

Giữ (dùng làm "full settings" nếu navigate từ drawer):
- API Key section
- Document Library (read-only view)
- Export tool

---

## 4. State Management

```dart
// Thêm giá trị thứ 3 vào enum
enum ProcessingMode { 
  promptOnly,   // Mode 1 — đổi tên từ 'generation' để rõ nghĩa hơn
  extraction,   // Mode 2 — giữ nguyên
  ragGeneration // Mode 3 — NEW
}
```

**Lưu ý backward compat:** Code hiện tại check `processingMode == ProcessingMode.generation` → đổi thành `processingMode == ProcessingMode.promptOnly`. Logic bên trong không thay đổi.

---

## 5. Validation Rules

| Mode | Topic | File | Validate |
|------|-------|------|----------|
| 1 — Prompt | ✅ Bắt buộc | ❌ Không cần | topic.isNotEmpty |
| 2 — Trích xuất | ❌ Không dùng | ✅ Bắt buộc ≥1 | selectedFileIds.isNotEmpty |
| 3 — Tài liệu | ❌ Không dùng | ✅ Bắt buộc ≥1 | selectedFileIds.isNotEmpty |

---

## 6. File Lifecycle (Mode 2 & 3)

```
Upload → ai_queue INSERT → process → result
                                       ↓
                              Xóa storage + DB record
                         (sau khi poll trả về 'completed')
```

Xóa được thực hiện trong `_pollForDocumentResults()` sau khi đọc xong result:
```dart
// Sau khi extract/generate xong:
await ref.read(teacherFileRepositoryProvider).deleteFile(fileId);
ref.invalidate(teacherFilesProvider);
```

---

## 7. Design System Compliance

Tất cả UI mới phải dùng:
- `DesignColors.*` — màu (primary #4A90E2, moonLight #F5F7FA, v.v.)
- `DesignSpacing.*` — padding/margin (lg=16dp là chuẩn)
- `DesignTypography.*` — text styles
- `DesignRadius.*` — border radius (md=12dp cho card, full cho chip)
- `DesignElevation.level1` — shadow cho card
- Pattern card: `white bg, 1px grey[200] border, DesignRadius.md, level1 shadow`

---

## 8. Những gì KHÔNG thay đổi

- Toàn bộ logic `_handleGenerate()` cho Mode 1
- `_pollForDocumentResults()` — chỉ thêm delete sau khi complete
- `StagingAreaWidget` — giữ nguyên
- `_buildAiResponseSection()` — giữ nguyên
- `_handleRegenerateSingle()`, `_handleSaveToQuestionBank()` — giữ nguyên
- `_handleRegenerateExplanation()` — giữ nguyên
- `AiService`, `aiRepository` — giữ nguyên
- `TeacherFileDataSource`, `teacherFilesProvider` — giữ nguyên

---

## 9. Files thay đổi

| File | Loại thay đổi |
|------|--------------|
| `ai_generation_settings_notifier.dart` | Thêm `ragGeneration` vào enum, đổi tên `generation` → `promptOnly` |
| `teacher_ai_generate_question_screen.dart` | Thêm mode tabs, endDrawer, conditional body, fix duplicate button, fix validation |
| `ai_question_settings_screen.dart` | Bỏ mode toggle + ContextSourcesSection |
| `teacher_file_datasource.dart` | Thêm `deleteFile()` method |
| `teacher_file_repository.dart` / `_impl.dart` | Thêm `deleteFile()` |
| `teacher_file_notifier.dart` | Thêm `deleteFile()` action |

---

## 10. Out of Scope

- RAG pipeline backend (pgvector/embedding) cho Mode 3 — UI sẵn sàng nhưng backend là task riêng
- Thay đổi bất kỳ logic grading, StagingAreaWidget, hoặc question bank

## 11. Mode 3 — Trạng thái nút khi backend chưa sẵn sàng

Nút "🧠 Sinh từ tài liệu" sẽ **hiển thị bình thường** nhưng khi tap sẽ show SnackBar:
> "Tính năng đang phát triển — sắp ra mắt"

Không disable hoàn toàn để tránh confuse người dùng về sự tồn tại của chức năng.  
Khi RAG backend sẵn sàng → bỏ SnackBar guard, kết nối vào pipeline thực.
