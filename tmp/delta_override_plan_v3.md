# Kế Hoạch Thực Thi: Delta Override — Data Contract Enforcement (v3)

**Mục tiêu:** Xóa bỏ rác dữ liệu, ép buộc hệ thống tuân thủ mô hình "The Library Book vs. The Sticky Note" (Nguyên bản vs. Ghi chú mặt nạ) cho các bài tập.
**Cảnh báo Kiến trúc:** TUYỆT ĐỐI không tính "diff" (khoảng cách) đối với các trường Mảng (Array) như `choices` (đáp án). Phải dùng cơ chế "Snapshot" (Gửi trọn bộ mảng) để tránh hiệu ứng *Array Annihilation* (PostgreSQL ghi đè xóa sạch mảng khi merge JSONB).

---

## 🎯 Kiến Trúc Data Contract Chuẩn

Hệ thống có 3 kịch bản tạo câu hỏi:
- **S1 (Link Gốc):** Chọn từ Bank, KHÔNG sửa. `question_id = UUID`, `custom_content = NULL`.
- **S2 (Delta Override):** Chọn từ Bank, ĐÃ sửa. `question_id = UUID`, `custom_content = {override_text?, choices?...}`.
  - *Primitive fields (text, points):* Chỉ lưu diff (lưu nếu khác Bank).
  - *Array fields (choices, blanks):* BẮT BUỘC lưu Snapshot (gửi TRỌN BỘ mảng từ UI xuống nếu có bất kỳ sự thay đổi nào trong mảng).
- **S3 (Inline):** Gõ tay mới hoàn toàn. `question_id = NULL`, `custom_content = {type, override_text, choices...}` (Lưu toàn bộ).

---

## 📋 CHI TIẾT TODO CHO AI AGENT (Thực thi theo thứ tự)

### TODO 1: Thiết lập Kiến trúc DTO Hybrid (Tầng Flutter Domain/Data)
**Vị trí:** Tạo file `lib/data/models/assignment_question_dto.dart` (hoặc đặt trong folder models/dto tương ứng).
**Hành động:**
- Tạo class `AssignmentQuestionDTO` với các biến `original...` (từ Bank) và `override...` (từ `custom_content`).
- Viết các Getter tự động Fallback:
  ```dart
  String get displayText => overrideText ?? originalText ?? '';
  // TUYỆT ĐỐI KHÔNG lặp qua từng phần tử mảng để trộn. Dùng fallback mảng:
  List<Map<String, dynamic>> get displayChoices => overrideChoices ?? originalChoices ?? [];
  ```
- Viết hàm `fromJson` đọc dữ liệu trả về từ DB (phân tách rõ phần đọc từ `content` của bảng `questions` và phần đọc từ `custom_content` của bảng `assignment_questions`).

### TODO 2: Refactor Read Path (Xóa bỏ Merge thủ công)
**Vị trí:** `lib/data/datasources/assignment_datasource.dart` (hàm `getDistributionDetail` và `_doSubmitAssignment`).
**Hành động:**
- Xóa bỏ **toàn bộ** logic `if (customContent != null)` kéo dài hàng trăm dòng đang cố gắng trộn mảng `choices` bằng vòng lặp (khoảng dòng 842-1004).
- Thay thế bằng việc map trực tiếp JSON trả về từ Supabase sang `AssignmentQuestionDTO` (từ TODO 1).
- Chuyển logic UI/Submit sử dụng thẳng các getter `displayText`, `displayChoices` của DTO. Các UI components sẽ trở thành "Dumb UI".

### TODO 3: Implement `_diffAgainstBank` Logic (Client Write Path)
**Vị trí:** `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart`.
**Hành động:**
- Viết hàm trợ giúp `_diffAgainstBank(Map formData, Map bankQuestion)` trả về một `Map<String, dynamic>?` (trả về null nếu không có thay đổi).
- **Logic bên trong hàm:**
  1. So sánh `text` của UI với `bankText`. Nếu khác, đưa vào map `override_text`.
  2. So sánh danh sách `options` của UI với `choices` của Bank. 
  3. **CRITICAL:** Nếu mảng `options` trên UI có BẤT KỲ thay đổi nào (so với Bank), gán **TOÀN BỘ MẢNG** `options` (đã map format id, text, isCorrect) vào key `choices` trong diff map. Không bao giờ lọc ra chỉ đáp án bị sửa!
  4. Trả về diff map.

### TODO 4: Sửa lỗi Nhồi Full Data (V1 Violation)
**Vị trí:** `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` (hàm `_mapQuestionsToAssignmentQuestions`).
**Hành động:**
- Khai báo một Cache Map lưu lại Bank Question gốc khi teacher pick câu hỏi từ `QuestionBankPickerSheet`.
- Trong vòng lặp build payload, kiểm tra `q['questionId']`:
  - **Trường hợp Inline (NULL):** Build full `customContent` như cũ (S3).
  - **Trường hợp Bank-linked (NOT NULL):** Gọi hàm `_diffAgainstBank`. 
    - Nếu trả về `null` → gán `customContent = null` (Ép thành S1 chuẩn).
    - Nếu trả về data → gán `customContent = diffData` (Ép thành S2 chuẩn).
- **Tuyệt đối giữ nguyên** `question_id` (trỏ về bank gốc).

### TODO 5: Viết SQL Server Guard & Cleanup (Bảo vệ DB)
**Vị trí:** Tạo file `db/migrations/016_delta_override_guard.sql`.
**Hành động:**
1. **Sửa RPC `create_assignment_with_questions` và `publish_assignment`:**
   - Cập nhật logic SQL: Nếu `question_id IS NOT NULL`, áp dụng **Whitelist**. Strip (Xóa) các key không được phép khỏi `custom_content` (xóa `type`, `tags`, `difficulty`, `explanation`, `images`...).
   - Đoạn check `v_custom_content = v_base_content` cũ là sai vì khác shape. Sửa lại: Lấy `custom_content->>'override_text'` so với `base_content->>'text'`, nếu giống nhau thì strip key `override_text`.
2. **Backfill Cleanup (Dọn rác cũ):**
   - Viết lệnh `UPDATE assignment_questions` để dọn các dòng đã bị nhồi full data trong quá khứ.
   - Trừ đi (`-`) các key rác (như `type`, `tags`...) nếu `question_id IS NOT NULL`.
   - Nếu `override_text` trùng `text` gốc, trừ tiếp `override_text`.
   - Cuối cùng, nếu `custom_content` trở thành mảng rỗng `{}`, set nó bằng `NULL`.

### TODO 6: Áp dụng CHECK Constraint (Khóa cửa vĩnh viễn)
**Vị trí:** Cuối file `db/migrations/016_delta_override_guard.sql`.
**Hành động:**
- Thêm đoạn lệnh thêm constraint:
  ```sql
  ALTER TABLE assignment_questions
  ADD CONSTRAINT aq_no_full_schema_in_delta
  CHECK (
    question_id IS NULL
    OR custom_content IS NULL
    OR NOT (custom_content ? 'type')
  )
  NOT VALID;
  ```
- (Lưu ý: Dùng `NOT VALID` để không block migration, sau này khi script cleanup chạy ổn định có thể VALIDATE sau).

---

> **LỜI KHUYÊN CHO AI CODER:** Khi thực thi kế hoạch này, hãy làm theo đúng trình tự từ TODO 1 đến TODO 6. Đừng nhảy cóc. Khó nhất là TODO 2 (phải gỡ cẩn thận các dòng if/else cũ) và TODO 3 (viết hàm so sánh mảng chính xác để quyết định có tạo Snapshot array hay không). Chúc may mắn!
