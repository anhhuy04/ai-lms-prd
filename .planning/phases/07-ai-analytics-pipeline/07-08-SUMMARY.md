---
phase: 07-ai-analytics-pipeline
plan: 08
status: completed
completed_at: 2026-04-10
wave: 4
---

# Summary: 07-08 — Wire ai_queue feedback + analysis + trigger

## Mục tiêu
Kết nối Flutter submit flow với Edge Function: INSERT ai_queue items cho MCQ feedback và session analysis, sau đó fire-and-forget trigger Edge Function.

## Files thay đổi
- `lib/data/datasources/assignment_datasource.dart`

## Những gì đã làm

### 1. ai_queue INSERT cho MCQ feedback (D-11)
Trong vòng lặp xử lý từng câu hỏi của `submitAssignment()`:
```dart
} else if (aiEnabled && !needsAIGrading) {
  // MCQ + AI enabled → queue feedback explanation
  await _client.from('ai_queue').insert({
    'submission_answer_id': answerId,
    'request_type': 'feedback',
    'status': 'pending',
  });
}
```
Essay/short_answer vẫn INSERT `request_type='score'` (stub).

### 2. ai_queue INSERT cho analysis (D-15)
Sau khi tất cả câu được xử lý, INSERT 1 analysis request kèm `session_id`:
```dart
await _client.from('ai_queue').insert({
  'submission_answer_id': null,
  'request_type': 'analysis',
  'status': 'pending',
  'payload': {'session_id': sessionId},
});
```

### 3. Fire-and-forget trigger Edge Function
`unawaited(_triggerAiQueue(sessionId))` — không block submit flow.

Method `_triggerAiQueue()` gọi HTTP POST đến:
`${Env.supabaseUrl}/functions/v1/process-ai-queue`

Với header `Authorization: Bearer ${Env.supabaseAnonKey}`.

Lỗi trigger không ảnh hưởng submit (try/catch non-blocking).

### 4. Imports thêm
- `dart:async` (cho `unawaited`)
- `package:ai_mls/core/env/env.dart`
- `package:dio/dio.dart`

## Flow hoàn chỉnh sau plan này
```
Student submit
    → INSERT submission_answers (MCQ graded)
    → INSERT ai_queue {feedback} × N câu MCQ   (nếu aiEnabled)
    → INSERT ai_queue {analysis} × 1            (nếu aiEnabled)
    → unawaited HTTP POST → Edge Function       (fire & forget)
    → return result ngay (không chờ AI)

[server-side background]
    Edge Function → đọc teacher API key → gọi AI → ghi ai_feedback
```

## Decisions
- `unawaited()` thay vì `.then()` để rõ ràng hơn về intent
- Dio timeout: connect 10s, receive 30s — Edge Function có thể chậm khi cold start
- Không retry trigger nếu fail — Edge Function có retry logic riêng qua `attempts` column
