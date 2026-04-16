# Phase 3 — Pending Items (Cần thảo luận & xử lý)

> Tổng hợp từ UAT session 2026-04-07. UAT hoàn thành: 3 pass / 6 issues / 1 skipped / 10 tổng.
> Sắp xếp theo priority: Bugs chặn trải nghiệm trước, cải thiện sau.

---

## Tóm tắt nhanh

| # | Mục | Severity | Loại | Cần thảo luận? |
|---|-----|----------|------|----------------|
| 1 | Nút "Xem Tiêu chí" không có trong workspace | Major | Bug | Không — fix ngay |
| 2 | Section "Tiêu chí chấm điểm" không có ở detail | Major | Bug | Không — fix ngay |
| 3 | Dialog crash khi lưu mẫu (màn hình đỏ) | Minor | Bug | Không — fix ngay |
| 4 | Test 8: Rubric lock (D-09) chưa verify | Minor | Test gap | Không — cần data |
| 5 | UI Audit RubricBuilderComponent | Minor | UI | Có — cần screenshot |
| 6 | D-06 Warning khi auto-sync điểm | Minor | UX | Có — chọn option |

---

## 1. [BUG - Major] Nút "Xem Tiêu chí" không hiển thị trong workspace

**Test:** 10  
**Vấn đề:** Câu essay trong workspace không có nút "Xem Tiêu chí" để xem rubric read-only.

**File cần kiểm tra:**
- `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart`

**Nghi ngờ:** Widget `ReadOnlyRubricViewer` / nút xem tiêu chí chưa được render cho câu essay, hoặc có điều kiện kiểm tra `rubric != null` nhưng data rubric không được truyền xuống workspace.

**Checklist fix:**
- [ ] Tìm nơi build câu essay trong workspace
- [ ] Kiểm tra rubric data có được load và truyền xuống question item không
- [ ] Thêm hoặc sửa điều kiện hiển thị nút "Xem Tiêu chí"
- [ ] Test: nút hiện → tap → sheet read-only mở

---

## 2. [BUG - Major] Section "Tiêu chí chấm điểm" không hiển thị ở màn hình chi tiết

**Test:** 9  
**Vấn đề:** Màn hình chi tiết bài tập (student) không có section rubric preview bên dưới câu essay.

**File cần kiểm tra:**
- `lib/presentation/views/assignment/student/student_assignment_detail_screen.dart`

**Nghi ngờ:** `ReadOnlyRubricViewer` chưa được gọi, hoặc điều kiện `hasRubric && essayTypes.contains(type)` bị false vì type string mismatch.

**Checklist fix:**
- [ ] Tìm widget build cho câu hỏi trong detail screen
- [ ] Kiểm tra `rubric` field có trong question data từ API không
- [ ] Kiểm tra type string format: `'essay'` hay `'Essay'` hay `'short_answer'`?
- [ ] Thêm `ReadOnlyRubricViewer` vào question item nếu chưa có
- [ ] Test: section hiện → tap để expand → xem đầy đủ levels

---

## 3. [BUG - Minor] Flutter Dialog Crash khi "Lưu thành Mẫu"

**Test:** 6  
**Vấn đề:** Sau khi tap "Lưu" trong dialog, màn hình đỏ. **Lưu thực tế thành công**, chỉ là Flutter assertion lỗi hiển thị.

**Stack trace key:**
```
_HighlightModeManager.notifyListeners
→ _InkResponseState.handleFocusHighlightModeChange
→ Looking up a deactivated widget's ancestor is unsafe
```

**Root cause:** TextField trong dialog có focus → đóng dialog → Flutter gửi focus highlight notification đến widget đã deactivated.

**Hướng fix (chọn 1):**
| Option | Code | Effort |
|--------|------|--------|
| A | `FocusScope.of(ctx).unfocus()` ngay trước `Navigator.pop(ctx, text)` | Rất thấp |
| B | `FocusManager.instance.primaryFocus?.unfocus()` trước pop | Rất thấp |
| C | Wrap toàn bộ dialog trong `WillPopScope` để unfocus khi pop | Thấp |

**File:** `lib/widgets/rubric/rubric_builder_component.dart` — method `_saveAsTemplate()`, dòng `Navigator.pop(ctx, text)`

**Đề xuất:** Thử Option A trước — 1 dòng code.

---

## 4. [TEST GAP] Test 8: Rubric lock (D-09) chưa verify

**Vấn đề:** Không có data để test — cần bài tập đã phân phối VÀ có học sinh đang làm bài (work_session tồn tại).

**Cách tạo data test:**
1. Teacher tạo bài tập có rubric → phân phối cho lớp
2. Học sinh đăng nhập → vào workspace câu essay (không cần submit)
3. Teacher mở lại bài tập đó → tap nút rubric

**Kết quả mong đợi khi test:**
- Banner vàng "Rubric đã khoá vì có học sinh đang làm bài"
- Tất cả inputs disabled
- Bottom chỉ có nút "Đóng"

**Priority:** Thấp — logic đã implement, chỉ cần verify.

---

## 5. [UI] RubricBuilderComponent — UI fixes (thảo luận xong, fix sau)

**File chính:** `lib/widgets/rubric/rubric_builder_component_builders.dart`

### 5a. Level row layout lệch + nút X mất cân đối

**Root cause:** `crossAxisAlignment: CrossAxisAlignment.start` + `IconButton` không có constraints cố định.

**Fix:**
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.center,  // đổi từ start → center
  children: [
    SizedBox(width: 60, child: TextFormField(maxLines: 1, labelText: 'Điểm')),
    SizedBox(width: DesignSpacing.sm),
    Expanded(child: TextFormField(maxLines: null, labelText: 'Mô tả')),
    SizedBox(
      width: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(maxWidth: 32, maxHeight: 32),
        ...
      ),
    ),
  ],
)
```

### 5b. Label "Điểm" và "Mô tả mức điểm" chưa rõ

**Vấn đề:** Label không truyền đạt đủ context — user không biết "Điểm" là điểm của mức này.

**Fix:** Đổi label:
- `'Điểm'` → `'Điểm mức'` hoặc thêm hint text `'VD: 5'`
- `'Mô tả mức điểm'` → `'Mô tả'` (ngắn hơn, đủ rõ trong context)

### 5c. Collapsed criterion header: tên dài bị cắt

**Fix:** Khi card collapsed, hiển thị tên bằng `SmartMarqueeText` thay vì để `TextFormField` tự truncate.

```dart
// collapsed state: read-only display
SmartMarqueeText(
  text: c.nameController.text.isEmpty ? 'Tiêu chí ${index + 1}' : c.nameController.text,
  style: DesignTypography.titleMedium,
  height: 22,
)
// expanded state: giữ nguyên TextFormField để edit
```

### 5d. Validation errors chỉ show sau khi tap "Lưu Rubric"

**Vấn đề:** Errors show ngay khi mở builder (fields trống → trigger ngay).

**Fix:** Thêm `bool _hasAttemptedSave = false`. Chỉ set `_errors` khi `_hasAttemptedSave == true`.

---

## 6. [UX - CHỐT] D-06 — Points Ceiling + Label chi tiết

**QUYẾT ĐỊNH (từ thảo luận 2026-04-08):**

- `question.points` (set ngoài card) là CEILING bất biến
- `RubricBuilderComponent` nhận thêm param `questionPoints` 
- Label đổi thành: `"Tổng: Xđ / Tối đa: Yđ"` với màu trạng thái:
  - `sum < max` → cam: `"Còn thiếu Zđ"`
  - `sum == max` → xanh: `"Đủ Yđ ✓"`  
  - `sum > max` → đỏ: `"Vượt Yđ — giảm xuống"`
- Validation publish: `sum != questionPoints` → hard block
- AI hard-cap bởi `question.points`

**File:** `lib/widgets/rubric/rubric_builder_component.dart` + `_builders.dart`

---

## 7. [Logic - CHỐT] D-08 — Min levels: 2 → 1

**QUYẾT ĐỊNH (từ thảo luận 2026-04-08):**

Min levels per criterion đổi từ **2** xuống **1**.

**File:** Backend validation + frontend `_validate()` method

---

## Thứ tự xử lý

```
Đợt 1 — Fix bugs (không cần thảo luận thêm):
  → #1: Nút "Xem Tiêu chí" trong workspace
  → #2: Section "Tiêu chí chấm điểm" ở detail screen
  → #3: Dialog crash (unfocus trước pop)

Đợt 2 — Fix UI + Logic (đã thảo luận xong):
  → #5a: Level row crossAxisAlignment + X button constraints
  → #5b: Label "Điểm mức" + "Mô tả" rõ hơn
  → #5c: SmartMarqueeText cho collapsed criterion name
  → #5d: Validation chỉ show sau _hasAttemptedSave
  → #6:  RubricBuilderComponent nhận questionPoints, label Tổng/Tối đa
  → #7:  Min levels 2 → 1

Đợt 3 — Verify (cần chuẩn bị data):
  → #4: Verify Test 8 (D-09 rubric lock)
```

---

## Fixes đã hoàn thành trong UAT session này

| Fix | File |
|-----|------|
| ✅ "Template" → "Mẫu" toàn bộ UI + căn giữa nút | builder, template_picker |
| ✅ C-1: TemplatePickerSheet → StatefulWidget + xóa ngay | `rubric_template_picker_sheet.dart` |
| ✅ C-2: Navigator.pop(sheetCtx) đúng context | `rubric_builder_component.dart` |
| ✅ C-3: Validate score >= 0 | `interactive_rubric_grader.dart` |
| ✅ C-4: Rename assignmentId → distributionId (+ 2 caller bị sót) | router, detail screen, class detail, assignment list |
| ✅ L-2 đến L-6: mounted guards, boxShadow, SnackBar threshold, type set | nhiều file |
| ✅ U-1 đến U-6: Raw colors, text thiếu dấu, code quality | nhiều file |
| ✅ W-7 đến W-10: stackTrace param, duplicate comment, SnackBar colors | nhiều file |
| ✅ Dialog "Lưu thành Mẫu": sync → async fix, UI cải thiện | `rubric_builder_component.dart` |
| ✅ Dialog "Áp dụng mẫu": replace/append choice, tiếng Việt, UI đẹp | `rubric_builder_component.dart` |
| ✅ Text lỗi D-08 thiếu dấu: "Cau hoi tu luan..." → có dấu | `teacher_create_assignment_screen.dart` |
