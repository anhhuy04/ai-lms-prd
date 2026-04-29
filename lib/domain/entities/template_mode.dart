/// Sub-mode dành cho Mode 3 (sinh câu hỏi từ tài liệu) khi tài liệu được
/// nhận diện là "bài mẫu" (template).
///
/// • [styleOnly] — Tạo câu MỚI cùng phong cách. AI nhận schema-only context
///   (tags + difficulty + type, KHÔNG có text câu hỏi gốc). An toàn cho lý
///   thuyết, từ vựng, ngoại ngữ. **Mặc định**.
///
/// • [sameForm]  — Tạo câu CÙNG DẠNG (giữ cấu trúc, đổi giá trị/dữ kiện).
///   AI nhận text + options đã shuffle (ẩn đáp án đúng). Phù hợp toán đố,
///   bài tập có công thức/biến số. CHỈ enable khi tất cả câu mẫu là MCQ.
enum TemplateMode {
  styleOnly,
  sameForm,
}
