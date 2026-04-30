/// Vai trò của file trong quá trình sinh câu hỏi AI.
///
/// - [template]: file được dùng làm mẫu cấu trúc (schema-only hoặc sameForm).
/// - [knowledgeSource]: file được dùng làm nguồn kiến thức (raw text).
///
/// Mặc định (null trên `LocalTempFile`): auto-detect — template nếu có
/// `parsedQuestions`, knowledgeSource nếu không. Dùng `LocalTempFile.effectiveRole`
/// để luôn nhận giá trị đã resolved.
enum FileRole { template, knowledgeSource }
