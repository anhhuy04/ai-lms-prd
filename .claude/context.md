# Session Context - 2026-03-12

## Tổng quan

Phiên làm việc này tập trung vào việc **fix auto-grading cho Multiple Choice và True/False questions**. Tất cả các lỗi đã được fix và verify hoạt động đúng.

---

## Các lỗi đã Fix

### 1. Type Cast Error (Line 915)
- **Lỗi:** `type 'int' is not a subtype of type 'String' in type cast`
- **Nguyên nhân:** `question_choices.id` từ DB là int, nhưng code cast trực tiếp sang String
- **Fix:** Dùng `.toString()` trước khi add vào map

### 2. True/False Grading Always Wrong
- **Lỗi:** So sánh "true"/"false" string với int 0/1 không khớp
- **Fix:** Convert int 0→"true", 1→"false" trước khi so sánh

### 3. UI selected_choices Comparison
- **Lỗi:** So sánh int vs String trong selected_choices
- **Fix:** Dùng `e == choice.id || e.toString() == choice.id.toString()`

### 4. Backward Compatibility
- **Thêm fallback:** `choices` → `options` (format cũ)
- **Thêm fallback:** `isCorrect` → `is_correct`
- **Thêm fallback:** `override_text` → `text`

---

## Verification Results

```
Test Case 1:
- Question 67fa1869: Student selected [0], Correct [0] → ✅ 5.0 points
- Question 6af629dd: Student selected [1], Correct [1] → ✅ 5.0 points
- Total: 10.0/10.0 ✅

Unit Tests: 17/17 passed ✅
```

---

## Files Changed

| File | Changes |
|------|---------|
| `lib/data/datasources/assignment_datasource.dart` | Fix type cast, add TF grading, add fallback |
| `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart` | Fix selected_choices comparison |
| `lib/presentation/views/assignment/teacher/teacher_preview_assignment_screen.dart` | Add fallback for choices/options |
| `lib/presentation/views/class/teacher/teacher_assignment_detail_screen.dart` | Add fallback for choices/options |
| `test/auto_grading_test.dart` | Unit tests for grading logic |

---

## Format JSONB (Đã xác định)

### Schema cho `assignment_questions.custom_content`

```json
// Multiple Choice / True-False
{
  "type": "multiple_choice",
  "override_text": "Nội dung câu hỏi",
  "choices": [
    {"id": 0, "text": "Đáp án A", "isCorrect": true},
    {"id": 1, "text": "Đáp án B", "isCorrect": false}
  ]
}
```

### Quy tắc quan trọng:
1. **Luôn đọc `override_text` trước, fallback `text`**
2. **Luôn đọc `choices` trước, fallback `options`**
3. **Choice ID luôn là INT (0,1,2,3...) - KHÔNG phải String**
4. **Dùng `isCorrect` (camelCase), không phải `is_correct`**

---

## Test Data Cleanup

File: `db/20_cleanup_all_submission_data.sql`

```sql
-- Xóa dữ liệu test
DELETE FROM public.ai_queue;
DELETE FROM public.submission_answers;
DELETE FROM public.submissions;
DELETE FROM public.autosave_answers;
DELETE FROM public.work_sessions;
```

---

## Status: ✅ COMPLETED

Auto-grading đã hoạt động ổn định. Có thể test thêm với True/False questions.
