# PLAN — Sửa luồng tạo câu hỏi (soạn nhiều câu → lưu 1 lần)

> Chốt với user 2026-05-31. Hướng 1: soạn nhiều câu trong editor, không nhảy trang, lưu gom 1 lần.

## Bằng chứng bug (đã verify bằng Supabase MCP)
- Tạo 1 câu inline qua FAB "+" → bài tập hiện **"2 câu"** (dư 1 câu rỗng ảo), điểm 0.
- DB phát sinh 1 câu **kho private** ngoài ý muốn (`questions` +1) cho mỗi câu inline.
- Câu bank mới lưu `content = {override_text}` thay vì `{text}` (BUG A — "tầng rác 2", doc đã hoãn, KHÔNG sửa lần này).

## Gốc rễ
1. Parent `_addQuestionFromScreen.onSaveAndAddNew` (teacher_create_assignment_screen.dart ~1031): sau khi thêm câu, chèn **1 câu rỗng tạm** + `context.pop()` + `_addQuestionFromScreen()` (push lại) → BOUNCE + phantom.
2. Child `_handleSaveAndAddNew` (teacher_create_question_screen.dart ~1585): luôn gọi `_saveQuestionToSupabase` (ghi kho) + sau callback còn gọi `_resetForNewQuestion()` trên widget vừa bị pop → race.

## Ràng buộc (user nêu)
- Drawer `QuestionListDrawer` đọc `_localQuestions` (liệt kê/thống kê) → sau mỗi "+" phải cập nhật `_localQuestions`.
- Màn dùng 2 chế độ: **inline** (assignment, `onSaveAndAddNew != null`) vs **kho độc lập** (bank-detail Nhân bản, `onSaveAndAddNew == null` → PHẢI giữ ghi-kho).
- Phải giữ luồng **sửa câu đã có** (edit) hoạt động (update, không append).

## Thiết kế

### Child `_handleSaveAndAddNew` (FAB "+")
- Validate (giữ nguyên).
- `questionData = _buildQuestionDataFromForm()`.
- **NẾU chế độ kho** (`onSaveAndAddNew == null`): giữ nguyên — `_saveQuestionToSupabase` (createQuestion + dedup) → `context.pop(questionData)`.
- **NẾU chế độ inline** (`onSaveAndAddNew != null`):
  - KHÔNG ghi kho (câu inline; questionId = null).
  - `widget.onSaveAndAddNew!(questionData)` → parent append/update vào `_questions`.
  - `_localQuestions = [..._localQuestions, questionData]` (cho drawer + title "Câu N+1").
  - `_resetForNewQuestion()` → form trống, **Ở LẠI** (không pop, không push).
  - Toast: "Đã thêm câu. Soạn tiếp hoặc bấm quay lại để lưu tất cả."
- BỎ `_resetForNewQuestion()` chạy vô điều kiện sau callback (fix race).

### Parent add-new callback (~1031)
- Bỏ chèn câu rỗng + bỏ `context.pop()` + bỏ `_addQuestionFromScreen()` re-push.
- Chỉ: append `savedQuestionData` vào `_questions` → `_setQuestions` + `_updateQuestionPoints`. Return index.

### Parent post-await (~1141)
- Editor đóng (back 1 lần) → `_questions` đã có tất cả (qua callback) → giữ in-memory, KHÔNG auto-persist/reload (để user bấm Lưu nháp/Xuất bản ghi 1 lần). Khối `if (questionData != null && editIndex==null)` không chạy vì child inline pop không data.

### Edit path (`_editQuestion` ~1178) — GIỮ NGUYÊN lần này
- Child phân biệt bằng `_localCurrentIndex`: null = thêm mới (ở lại); != null = sửa (giữ hành vi cũ: callback update + pop). Không đổi để tránh vỡ.

## Verify (Supabase MCP, mốc created_at > '2026-05-31 04:17:00+00')
1. Tạo 2 câu inline qua "+", drawer hiện 2, title "Câu 3" trống, KHÔNG nhảy trang.
2. Back 1 lần → bài tập hiện đúng **2 câu** (không phantom).
3. `questions` (kho private) KHÔNG tăng khi tạo inline.
4. Bấm Lưu nháp → `assignment_questions`: 2 dòng, question_id=NULL, S3, objective_ids đúng, garbage=0.

## Không làm
- BUG A (override_text trong questions.content) — hoãn (tầng rác 2).
- Edit path refactor — giữ nguyên.
