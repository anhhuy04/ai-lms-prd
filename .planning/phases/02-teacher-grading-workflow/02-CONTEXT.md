# Phase 2: Teacher Grading Workflow - Context

**Gathered:** 2026-03-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Cho phép giáo viên xem danh sách bài nộp và chấm điểm bài làm của học sinh với giao diện trực quan, dễ sử dụng.

</domain>

<decisions>
## Implementation Decisions

### 1. ATC Dashboard - Entry & Flow

- **Entry:** Từ Assignment Management → chọn bài tập → Xem danh sách nộp
- **Flow:**
  1. Chọn Assignment → Hiển thị danh sách Class với stats (đã nộp / chưa nộp / nộp muộn)
  2. Chọn Class → Hiển thị danh sách HS nộp bài của lớp đó
  3. Hoặc: Chọn Assignment → Hiển thị tất cả HS nộp (mọi lớp)

### 2. ATC - Class Selection Screen

- **Hiển thị:** Danh sách các lớp đã giao bài tập đó
- **Stats mỗi lớp:** Đã nộp / Chưa nộp / Nộp muộn (có số lượng)

### 3. ATC - Submission List

- **Filter:** Dạng Tab có số
  - [Tất cả (X)] [Chưa chấm (X)] [Đã chấm (X)] [Nộp muộn (X)]
- **Filter phụ trong mỗi tab:**
  - Tìm kiếm theo tên HS (riêng)
  - Lọc theo ngày (riêng)
  - Lọc nộp muộn (riêng)
- **Sort:** Bottom Sheet chọn cách sắp xếp
  - Thời gian nộp ↓ (mới nhất)
  - Thời gian nộp ↑ (cũ nhất)
  - Tên HS A-Z
  - Tên HS Z-A
  - Điểm cao → Thấp
  - Điểm Thấp → Cao
- **Item hiển thị:** Tên HS, thời gian nộp, badge Nộp muộn (đỏ), điểm

### 4. UI Chấm điểm (Grading Interface)

- **Layout:** Kết hợp:
  - Desktop: Side-by-Side 2 cột (trái: bài làm HS, phải: đáp án)
  - Mobile: Bottom sheet trượt lên
- **Hiển thị theo câu hỏi:** Câu hỏi → Câu trả lời HS → Đáp án đúng
- **Mã màu MCQ:**
  - HS chọn sai → Tô đỏ đáp án HS chọn, tô xanh đáp án đúng
  - HS chọn đúng → Tô xanh cả hai
- **Tự luận (Essay):** Hiển thị điểm AI + Feedback AI + Cho phép GV override
- **AI Confidence:** Hiển thị thanh confidence, < 70% → nền vàng + cảnh báo
- **Rubric:** Hiển thị có điều kiện (có → hiển thị, không → ẩn)
- **Tổng điểm:** Hiển thị từng phần rồi tổng lại

### 5. Cập nhật trạng thái (State Updates)

- **Sau khi chấm:** Dừng lại ở bài hiện tại, GV tự bấm sang bài khác
- **Sau khi lưu:** Snackbar hiện "Đã lưu", có thể undo trong 3s
- **Refresh:** Pull-to-refresh để tải dữ liệu mới nhất

### 6. Xử lý lỗi (Error Handling)

- **Lỗi mạng:** Hiển thị snackbar lỗi + nút Thử lại ngay
- **Auto retry:** Tự động thử lại 3 lần trước khi báo lỗi
- **Lỗi server (500):** Hiển thị dialog lỗi chi tiết + nút liên hệ support
- **Validation điểm:** Inline error - hiển thị text đỏ ngay dưới input, không cho lưu

### 7. Tiện ích (Usability)

- **Auto-save local:** Không lưu tạm - dữ liệu mất khi reload
- **Submit:** Bấm Enter để submit luôn sau khi nhập điểm
- **Loading:** Skeleton loading thay vì spinner

</decisions>

<specifics>
## Specific Ideas

- Giao diện chấm bài giống các app phổ biến: Google Classroom, Moodle, Canvas LMS
- Pattern phổ biến: Câu hỏi → Câu trả lời HS → Đáp án đúng với mã màu

</specifics>

## Existing Code Insights

### Reusable Assets
- ShimmerLoading: Có sẵn trong project cho loading states
- DesignTokens: DesignColors, DesignSpacing, DesignTypography để sử dụng cho mã màu
- SubmissionListItem widget: Đã có badge "Nộp muộn"
- TeacherSubmissionListScreen: Đã có filter chips

### Established Patterns
- Riverpod với @riverpod annotation
- Repository pattern
- GoRouter với pushNamed cho navigation

### Integration Points
- teacherSubmissionListProvider: Lấy danh sách submissions
- submissionGradingNotifierProvider: Actions approve/override/publish
- Route: teacher-submission-list, teacher-grade-submission

</code_context>

<deferred>
## Deferred Ideas

- Tự động chuyển sang bài tiếp theo sau khi chấm xong (sau này có thể thêm)
- Auto-save local cho dữ liệu nhập (sau này có thể thêm)

</deferred>

---

*Phase: 02-teacher-grading-workflow*
*Context gathered: 2026-03-13*
