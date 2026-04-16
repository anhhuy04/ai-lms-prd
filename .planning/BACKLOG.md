# Backlog — Deferred Tasks

Các task đã phân tích, hiểu rõ vấn đề nhưng chưa implement. Ghi lại để xử lý sau.

---

## [DEFER-01] Shuffle câu hỏi & đáp án — lưu thứ tự vào work_sessions

**Phase liên quan:** Phase 01 — Student Assignment Workflow  
**Ngày ghi:** 2026-04-15  
**Ưu tiên:** Medium

### Vấn đề
Flag `shuffle_choices` đã được lưu vào `assignment_distributions.settings` khi giáo viên phát bài, nhưng **chưa có logic shuffle thực tế phía client**.

### Phân tích kỹ thuật
- Đáp án MCQ/True-False lưu theo `choice.id` (integer DB ID) — không phải vị trí index → **an toàn khi shuffle**, đáp án vẫn đúng sau khi xem lại
- Câu hỏi keyed bằng `question.id` (UUID) → cũng an toàn
- **Gap hiện tại:** Nếu shuffle ngẫu nhiên mỗi lần load → học sinh thoát app rồi vào lại thấy thứ tự khác → confusing UX

