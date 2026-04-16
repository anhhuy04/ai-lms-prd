---
phase: 07-ai-analytics-pipeline
plan: 06
status: completed
completed_at: 2026-04-10
wave: 3
---

# Summary: 07-06 — Edge Function process-ai-queue

## Mục tiêu
Tạo Supabase Edge Function chạy server-side xử lý `ai_queue` items, gọi AI API của giáo viên ngầm, ghi kết quả vào `submission_answers.ai_feedback`.

## Files tạo mới
- `supabase/functions/process-ai-queue/index.ts`

## Những gì đã làm

### Edge Function (Deno TypeScript)
- Handler `feedback`: đọc câu hỏi + đáp án học sinh → build prompt → gọi Gemini/Groq/Ollama → ghi `ai_feedback` JSON có cấu trúc
- Handler `analysis`: đọc `student_skill_mastery < 0.6` → INSERT `ai_recommendations`
- Handler `score`: stub (essay deferred đến Phase 3)
- Retry logic: max 3 attempts, mark `failed` nếu hết

### Prompt nâng cấp (so với plan gốc)
Output là JSON 5 trường thay vì plain text:
```json
{
  "summary": "1 câu kết luận",
  "explanation": "2-3 câu giải thích nguyên lý",
  "misconception": "lỗi tư duy nếu sai (rỗng nếu đúng)",
  "tip": "1 gợi ý học tập hành động",
  "encouragement": "động viên phù hợp kết quả"
}
```

### API key: chỉ giáo viên cần
Edge Function đọc API key từ `profiles.metadata.api_keys[provider]` của giáo viên — học sinh không cần cấu hình gì.

### Fix TypeScript errors
`createClient<any>` và `supabase: any` trong handler functions để tránh TS2345/TS2339 strict generic errors từ Supabase JS v2.

## Decisions
- Prompt output JSON thay vì plain text → Flutter UI có thể render từng section riêng (Task 6 pending)
- Fallback: nếu AI trả về text thô (không parse được JSON) → store vào `summary` field
- `raw` field lưu 500 ký tự đầu của raw response để debug

## Còn lại (Task 6)
`_buildAiFeedbackBox()` trong `teacher_submission_detail_screen.dart` hiện đọc `['text']` — cần update để render 5 trường JSON mới.
