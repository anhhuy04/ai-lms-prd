# Question Bank — E2E Manual Verification Checklist

**Date:** 2026-05-17
**App URL:** http://localhost:51821 (or current dev server)
**Status:** Awaiting manual login + flow verification

## Automated smoke test (passed)

✅ **Build + launch:** `flutter run -d chrome` boots cleanly
✅ **No runtime errors:** `mcp__dart__get_runtime_errors` → "No runtime errors found"
✅ **Login screen renders:** 13 interactive elements, no overflow
✅ **AppLogger working:** `[QuestionBank][...]` tags visible in app logs (after triggering Question Bank operations)
✅ **VM service responsive:** Marionette connected, widget tree introspectable

## Manual checklist — User runs these after login as teacher

### F1: Hub entry & navigation

- [ ] Login as teacher → home screen
- [ ] Navigate to "Quản lý bài tập" hub
- [ ] **Verify:** Row mới "Kho câu hỏi" hiển thị (teal theme, icon `quiz_outlined`) with live count
- [ ] Tap card → navigate to `/teacher/question-bank`
- [ ] **Verify:** TeacherQuestionBankScreen render với:
  - AppBar "Ngân hàng câu hỏi"
  - Source chips: Tất cả / Của tôi / AI tạo / Toàn cầu
  - Search field
  - Empty state OR list of questions
  - FAB "Tạo câu hỏi mới"

### F2: Tạo câu hỏi mới (Bank-first)

- [ ] Tap FAB → push to teacher_create_question screen
- [ ] Fill content → tap save
- [ ] **Verify:** SnackBar success + back to bank list
- [ ] **Verify (DB):** New row in `questions` table với `source='teacher'`, `is_global=false`, `content_hash NOT NULL`
- [ ] **Verify (logs):** `[QuestionBank][Notifier:Create] source=teacher`

### F3: Duplicate pre-check

- [ ] Tạo lại câu hỏi nội dung GIỐNG HỆT câu vừa tạo
- [ ] **Verify:** `SimilarQuestionDialog` xuất hiện với preview câu cũ
- [ ] Test 3 buttons:
  - [ ] "Hủy" → đóng dialog, không tạo gì
  - [ ] "Vẫn tạo mới" → DB sẽ throw 23505 → snackbar "Câu hỏi tương tự đã tồn tại"
  - [ ] "Dùng câu cũ" → liên kết với câu existing

### F4: Picker từ Assignment Builder

- [ ] Mở assignment builder (Tạo bài tập mới hoặc draft cũ)
- [ ] Mở drawer Tools → tap "Ngân hàng câu hỏi"
- [ ] **Verify drawer:** Icon `bookmarks_outlined`, subtitle "Chọn từ N câu trong kho của bạn"
- [ ] **Verify:** `QuestionBankPickerBottomSheet` slide up từ bottom
  - Title "Chọn câu hỏi từ kho"
  - Search field + filter chips
  - Checkbox list
  - Footer "Đã chọn N — Thêm vào bài tập"
- [ ] Select 2-3 câu → tap "Thêm N câu"
- [ ] **Verify:** Sheet đóng, snackbar "Đã thêm N câu hỏi từ kho", câu mới xuất hiện ở list bài tập
- [ ] **Verify (DB sau publish):** `assignment_questions.question_id NOT NULL` cho mỗi câu đã pick

### F5: Soft delete + Undo

- [ ] Mở Question Bank → tap menu 3-dot trên một câu → "Xóa"
- [ ] **Verify:** Confirm dialog "Xóa câu hỏi? Câu hỏi sẽ vào Thùng rác..."
- [ ] Tap "Xóa"
- [ ] **Verify:** Câu hỏi biến mất khỏi list, snackbar 30s "Đã xóa — Hoàn tác"
- [ ] Tap "Hoàn tác" trong window 30s
- [ ] **Verify:** Câu hỏi xuất hiện lại tại vị trí cũ
- [ ] **Verify (logs):** `[QuestionBank][Notifier:SoftDelete] optimistic_remove → confirmed`, sau đó restore

### F6: Trash screen + Restore sau timeout

- [ ] Xóa câu hỏi → đợi snackbar 30s biến mất
- [ ] Navigate vào trash screen (manual URL: `/teacher/question-bank/trash` — note: chưa có entry UI điều hướng, có thể defer)
- [ ] **Verify:** Câu vừa xóa hiện trong trash với badge "Đã xóa N ngày trước"
- [ ] Tap "Khôi phục"
- [ ] **Verify:** Snackbar "Đã khôi phục câu hỏi", câu biến mất khỏi trash, hiện lại trong bank chính

### F7: Ghost Sync Banner (chỉ cho assignment cũ pre-migration)

- [ ] Mở assignment cũ (có inline questions chưa thuộc kho — `assignment_questions.question_id IS NULL`)
- [ ] **Verify:** `GhostQuestionsBanner` hiện trên đầu list questions với "Phát hiện N câu chưa đồng bộ vào kho"
- [ ] Tap "Đồng bộ ngay" → confirm dialog
- [ ] **Verify:** Modal loading "Đang đồng bộ..."
- [ ] Sau success: snackbar "Đã tạo X mới, liên kết Y câu trùng"
- [ ] **Verify (logs):** `[QuestionBank][Sync] rpc_start → rpc_done created=X linked=Y`
- [ ] **Verify (DB):** `assignment_questions.question_id` đã fill cho tất cả ghost rows

### F8: AI Generate → source tracking

- [ ] Vào AI Generate screen → sinh 3 câu hỏi
- [ ] Save vào kho
- [ ] **Verify (DB):** Mỗi câu mới có `source='ai_generated'`
- [ ] Quay lại Question Bank → tap chip "AI tạo"
- [ ] **Verify:** Filter hiển thị đúng các câu vừa sinh

### F9: Detail screen + 3 tabs

- [ ] Tap 1 câu hỏi từ list → push detail screen
- [ ] **Verify Tab "Xem trước":**
  - Meta chips: type, difficulty stars, source label, isGlobal badge
  - Content text full
  - Choices (cho MC) với check mark cho đáp án đúng
  - Tags wrap chips
- [ ] **Verify Tab "Thống kê":**
  - Nếu chưa có submission: "Câu hỏi chưa được dùng — chưa có thống kê"
  - Nếu có: 4 cards (Lượt làm, Đúng, Tỉ lệ đúng, Cập nhật gần nhất)
- [ ] **Verify Tab "Lịch sử dùng":** placeholder

### F10: RLS Security (cần 2 accounts để test)

- [ ] Account A (teacher): create câu hỏi → SQL inspect: `is_global = false` (KHÔNG được fake true)
- [ ] Account B (teacher khác): query Question Bank → KHÔNG thấy câu của A
- [ ] Account Admin: set `is_global = true` cho 1 câu của A
- [ ] Account B query lại → THẤY câu global của A
- [ ] Test soft-delete: RLS chặn hard DELETE từ client SDK (verify in SQL editor: `DELETE FROM questions ...` → 0 rows affected)

## Performance verification

- [ ] Tạo 50+ câu hỏi (script hoặc thủ công) → mở Question Bank
- [ ] **Verify:** Render mượt, không lag, scroll mượt
- [ ] **Verify:** Detect ghost query <200ms (xem network tab)
- [ ] **Verify:** Sync 20-50 ghost <3s

## Regression check

- [ ] Tạo assignment với câu hỏi từ kho + câu hỏi mới (mixed)
- [ ] Publish assignment
- [ ] Sau publish, sửa câu hỏi gốc trong Bank
- [ ] Mở student workspace cho assignment đã publish
- [ ] **Verify:** Student vẫn thấy nội dung CŨ (snapshot via `assignment_variants`), không bị nội dung mới của Bank đè lên

## Known limitations (defer)

- ❗ Integration test F1-F4 trong `integration_test/` chưa viết — manual E2E thay thế
- ❗ Detail screen widget test chưa viết — coverage có thể bổ sung sau
- ❗ TrashScreen chưa có entry point trong UI (chỉ truy cập qua URL hoặc nếu thêm menu sau)
- ❗ "Sao chép câu hỏi" + "Sửa từ detail screen" hiện chỉ snackbar placeholder — Phase sau wire vào create_question screen với mode

## Reporting bugs

Nếu phát hiện bug trong checklist, ghi nhận:
1. Bước nào fail
2. Expected vs Actual
3. Screenshot
4. AppLogger output (filter: `[QuestionBank]`)
5. Sentry breadcrumb (nếu có)

Báo cáo vào file `docs/reports/qb-bugs-{date}.md` để fix trong sprint sau.
