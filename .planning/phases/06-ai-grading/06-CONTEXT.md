# Phase 6: AI Grading - Context

**Gathered:** 2026-03-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement AI-powered grading system that:
- Queues submissions for AI evaluation
- Stores AI evaluation results (model, rationale, score)
- Allows teacher overrides with feedback
- Collects data for RLHF (model improvement)

This phase handles the grading portion of the assignment lifecycle. Analytics and recommendations are separate phases.

</domain>

<decisions>
## Implementation Decisions

### AI Queue Table
- `request_type`: 'score' (grading), 'feedback' (comments), 'analysis' (skill update)
- `status`: 'pending' → 'running' → 'done' / 'failed'

### Retry Logic
- Attempt 1 fail: Wait 5s, retry
- Attempt 2 fail: Wait 30s, retry
- Attempt 3 fail: Mark 'failed', leave for manual grading
- **Key Decision:** Max 3 attempts only - prevents resource exhaustion when AI API is down

### AI Evaluations Table
- `model_name`: e.g., 'GPT-3.5', 'GPT-4o'
- `model_version`: Track which version graded
- `rationale`: Chain-of-Thought - AI explains its scoring
- **Key Decision:** Separated from submission_answers for MLOps - enables model performance comparison

### Grade Overrides Table
- `reason`: Optional at DB level, required at App level
- Notification: YES - push to student when teacher overrides
- **Key Decision:** Override data feeds RLHF for model improvement

### Complete Workflow
1. Student submits → Push to ai_queue
2. Worker picks job → Calls AI → UPDATE submission_answers + INSERT ai_evaluations
3. Trigger → Recalculate submissions.total_score
4. Teacher overrides → INSERT grade_overrides → Trigger notification + recalculate
5. RLHF Pipeline → Collect overrides for model fine-tuning

</decisions>

<specifics>
## Specific Ideas

- Follow CO-STAR framework for AI prompts:
  - Context: Learning trajectory data, skill mastery, question stats
  - Objective: Generate actionable recommendations for teachers
  - Style: Educational data scientist persona
  - Tone: Professional, actionable
  - Audience: Teachers
  - Response Format: JSON array matching ai_recommendations schema

</specifics>

#ai_context

## Existing Code Insights

### Reusable Assets
- submission_answers table: Already exists, needs ai_score columns
- work_sessions table: Already exists, triggers ai_queue insert
- grade_overrides: NEW table needed

### Integration Points
- Connects to: submissions, submission_answers tables from Phase 1
- Triggers: PostgreSQL triggers for score reconciliation
- Queue: Edge Function or external worker for processing

### Established Patterns
- JSONB for extensible settings
- RLS policies for security
- Transaction wrappers for multi-step operations

</ai_context>

<deferred>
## Deferred Ideas

- Analytics & Recommendations (skill mastery, question stats) — future phase
- Real-time grading status updates — future phase
- Student feedback on AI grades — future phase

</deferred>

---

## Phase 3 Integration — Việc cần làm khi Phase 6 hoàn thành

> Phase 3 (Rubric System) đã chuẩn bị sẵn hook cho Phase 6. Sau khi `ai_evaluations.criteria_scores` có data, cần wire lại các điểm sau:

### 1. AI Highlight Level trong ReadOnlyRubricViewer

**Widget đã sẵn sàng:** `lib/widgets/rubric/read_only_rubric_viewer.dart`
- Tham số `selectedLevels: Map<String, int>?` đã có — `criterion_id → level_index`
- Logic highlight đã viết, chỉ cần truyền data vào

**Việc cần làm:**
- [ ] Sau khi AI trả kết quả, lấy `criteria_scores` từ `ai_evaluations`
- [ ] Map thành `Map<String, int>` (criterion_id → level index trong rubric)
- [ ] Truyền vào `ReadOnlyRubricViewer(selectedLevels: mappedScores)` tại màn hình review

**Màn hình cần cập nhật:**
- `QuestionAnswerCard` — khi render rubric ở chế độ read-only sau chấm
- `TeacherSubmissionDetailScreen` — view kết quả chấm của AI

**File tham khảo:**
- `lib/widgets/rubric/read_only_rubric_viewer.dart` — xem param `selectedLevels`
- `.planning/phases/03-rubric-system/03-CONTEXT.md` — D-03, D-04

---

*Phase: 06-ai-grading*
*Context gathered: 2026-03-06*
