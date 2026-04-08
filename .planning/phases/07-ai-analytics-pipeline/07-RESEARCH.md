# Phase 7: AI Analytics Pipeline - Research

**Researched:** 2026-04-08
**Domain:** PostgreSQL Triggers, Supabase Edge Functions (Deno), Flutter data pipelines, analytics write paths
**Confidence:** HIGH

## Summary

Phase 7 bridges the gap between student submission and meaningful analytics data. The core problem: tables like `student_skill_mastery`, `question_stats`, `submission_analytics`, and `ai_recommendations` exist in the DB schema but have ZERO write paths -- all code only READs from them. This phase builds the write pipelines (primarily PostgreSQL triggers for reliability), adds a Supabase Edge Function skeleton for AI processing, and closes UAT debt from Phases 2/4/5.

The phase is well-scoped: Wave 1 is pure SQL (triggers + schema migration), Wave 2 adds Flutter-side writes and fixes, Wave 3 builds AI infrastructure, Wave 4 connects AI features, Wave 5 polishes UI. The trigger-first approach (D-01, D-02) ensures data consistency regardless of code path.

**Primary recommendation:** Implement DB triggers first (Wave 1) so data populates immediately on next submission, then layer Flutter changes and Edge Function on top.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- D-01: Skill Mastery Update via PostgreSQL trigger on `submission_answers` INSERT (NOT Flutter code)
- D-02: Question Stats via PostgreSQL trigger on `submission_answers` INSERT
- D-03: Submission Analytics via Flutter call in `submitAssignment()` after step 4 (non-blocking)
- D-04: Grade Override verification + push notification via `in_app_notifications` table
- D-05: AI Queue Edge Function `process-ai-queue` in Deno TypeScript
- D-06: Only MCQ (multiple_choice, true_false) updates skill_mastery in Phase 7 (`WHERE final_score IS NOT NULL`)
- D-07: Custom questions (question_id = NULL) skip trigger -- no learning_objectives
- D-08: Empty answers (final_score = 0) count as attempts (survivorship bias prevention)
- D-09: AFTER UPDATE trigger for grade override recalculation (full recount, not incremental)
- D-10: submission_analytics metrics use client-side time_log telemetry + questions.tags for accuracy_by_tag
- D-11: submitAssignment() parses `settings` JSONB null-safe with defaults
- D-12: Status remains 'submitted' briefly, then immediately transitions to 'graded' or 'ai_processing'
- D-13: `in_app_notifications` table (not FCM) -- PostgreSQL trigger on grade_overrides INSERT
- D-14: Recommendations dual-channel: student (mastery < 0.6) + teacher (class intervention)
- D-15: Recommendations via Edge Function ai_queue (analysis request_type), not Flutter direct
- D-16: SubmissionStatus.unknown for graceful degradation during schema rollout
- D-17: Realtime subscription on work_sessions for AI processing status updates
- D-18: Edge Function uses Analytics AI config from `profiles.metadata.analytics.*`
- D-19: Feedback writes to `submission_answers.ai_feedback` (column already exists)
- D-20: Service role key in Supabase secrets for Edge Function RLS bypass
- D-21: Edge Function self-JOINs context (no pre-populated payload)
- D-22: `get_class_average_skill_mastery` SQL function with SECURITY DEFINER (created in 7-09)
- D-23: Filter by Status bug investigation before fix (7-10a)
- D-24: pending_review UI = badge + filter chip (7-12)

### Claude's Discretion
- Trigger implementation details (single vs separate triggers for D-01/D-02)
- Exact per-question stopwatch implementation in workspace screen
- Edge Function error handling and retry logic details
- Specific UI layout choices within constraints

### Deferred Ideas (OUT OF SCOPE)
- RLHF Pipeline (grade overrides for fine-tuning)
- Real-time analytics push notifications
- Student feedback on AI grades
- AI grading for essay (Phase 3 re-enable)
- Rubric criteria scores display (`ai_evaluations.criteria_scores`)
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| 7-01 | Skill Mastery Write Pipeline | D-01 trigger on submission_answers, D-06/D-07/D-08 filtering, D-09 update trigger |
| 7-02 | Question Stats Pipeline | D-02 trigger, question_stats UPSERT pattern |
| 7-03 | Submission Analytics | D-03 Flutter call, D-10 time_per_question telemetry + accuracy_by_tag |
| 7-04 | Grade Override verification | D-04 verify wiring + D-13 in_app_notifications trigger |
| 7-05 | AI Queue Edge Function | D-05 Deno skeleton, D-18 analytics AI config, D-20 service role, D-21 self-JOIN |
| 7-06 | Phase 4 UAT Closure | Depends on 7-01 data, 7 skipped tests to re-run |
| 7-07 | AI Recommendations Generation | D-14 dual-channel, D-15 via ai_queue analysis |
| 7-08 | AI Feedback for MCQ | D-05 Edge Function feedback type, D-19 write to ai_feedback |
| 7-09 | Phase 5 UAT + VERIFICATION Closure | D-22 class avg RPC, standalone route fix, dismiss bug fix |
| 7-10 | Phase 2 UAT Closure | D-23 filter bug, grade audit re-test, override MCQ re-test |
| 7-11 | AI Grading Toggle | 7-11a DB migration (Wave 1), 7-11b Flutter enum + submit flow + UI (Wave 2) |
</phase_requirements>

## Standard Stack

### Core (Already in project)
| Library | Version | Purpose | Notes |
|---------|---------|---------|-------|
| supabase_flutter | (in pubspec) | Flutter Supabase client | Used for all DB operations |
| riverpod + @riverpod | (in pubspec) | State management | All providers follow generator pattern |
| freezed + json_serializable | (in pubspec) | Immutable models | SubmissionStatus enum needs build_runner after changes |
| flutter_screenutil | (in pubspec) | Responsive sizing | All UI components |

### New (Phase 7 specific)
| Component | Version | Purpose | Notes |
|-----------|---------|---------|-------|
| Supabase Edge Functions | Deno runtime | AI queue processing | `process-ai-queue` function |
| PostgreSQL triggers | N/A | Data pipeline (skill_mastery, question_stats) | Pure SQL, deployed via Supabase MCP |
| Supabase Realtime | (in supabase_flutter) | Status change subscriptions | For ai_processing status updates |

### No New Flutter Libraries Required
Phase 7 works entirely within the existing stack. No new pub dependencies needed.

## Architecture Patterns

### Recommended File Structure for New Code
```
db/migrations/
  007_skill_mastery_trigger.sql        # 7-01: AFTER INSERT trigger
  007_question_stats_trigger.sql       # 7-02: AFTER INSERT trigger  
  007_grade_override_recalc_trigger.sql # D-09: AFTER UPDATE trigger
  007_work_sessions_ai_status.sql      # 7-11a: ALTER CHECK constraint
  007_in_app_notifications.sql         # D-13: New table + trigger
  007_class_avg_skill_mastery_rpc.sql  # D-22: SECURITY DEFINER function

supabase/functions/
  process-ai-queue/
    index.ts                           # 7-05: Deno Edge Function

lib/data/datasources/
  notification_datasource.dart         # D-13: Read in_app_notifications
  (modify) assignment_datasource.dart  # 7-03, 7-11b: submit flow changes

lib/domain/entities/
  (modify) submission.dart             # 7-11b: SubmissionStatus enum expansion
  in_app_notification.dart             # D-13: Notification entity

lib/presentation/
  (modify) workspace screen            # D-10: per-question timer
  (modify) distribute screen           # 7-11b: AI toggle UI
  (modify) submission list             # 7-12: status badges
```

### Pattern 1: PostgreSQL Trigger for Data Pipeline (D-01, D-02)
**What:** AFTER INSERT trigger on `submission_answers` that UPSERTs analytics tables
**When to use:** When data must be consistent regardless of code path (submit, re-grade, override)
**Example:**
```sql
-- Trigger function for student_skill_mastery
CREATE OR REPLACE FUNCTION fn_update_skill_mastery()
RETURNS TRIGGER AS $$
BEGIN
  -- Skip if no final_score (essay not yet graded)
  IF NEW.final_score IS NULL THEN
    RETURN NEW;
  END IF;
  
  -- Skip custom questions (no question_id link)
  -- JOIN assignment_questions -> question_objectives -> learning_objectives
  INSERT INTO student_skill_mastery (student_id, objective_id, attempts, correct, mastery_level, last_updated)
  SELECT 
    ws.student_id,
    qo.objective_id,
    1,  -- attempts
    CASE WHEN NEW.final_score = aq.points THEN 1 ELSE 0 END,  -- correct
    CASE WHEN NEW.final_score = aq.points THEN 1.0 ELSE 0.0 END,  -- mastery_level
    now()
  FROM work_sessions ws
  JOIN assignment_questions aq ON aq.id = NEW.assignment_question_id
  JOIN question_objectives qo ON qo.question_id = aq.question_id
  WHERE ws.id = NEW.session_id
    AND aq.question_id IS NOT NULL  -- D-07: skip custom questions
  ON CONFLICT (student_id, objective_id)
  DO UPDATE SET
    attempts = student_skill_mastery.attempts + 1,
    correct = student_skill_mastery.correct + 
      CASE WHEN NEW.final_score = (SELECT points FROM assignment_questions WHERE id = NEW.assignment_question_id) 
           THEN 1 ELSE 0 END,
    mastery_level = (student_skill_mastery.correct + 
      CASE WHEN NEW.final_score = (SELECT points FROM assignment_questions WHERE id = NEW.assignment_question_id)
           THEN 1 ELSE 0 END)::numeric / (student_skill_mastery.attempts + 1),
    last_updated = now();
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_submission_answers_skill_mastery
  AFTER INSERT ON submission_answers
  FOR EACH ROW
  EXECUTE FUNCTION fn_update_skill_mastery();
```

### Pattern 2: AFTER UPDATE Trigger for Grade Override Recalculation (D-09)
**What:** When teacher overrides `final_score`, recalculate mastery from scratch
**When to use:** Grade override changes final_score on existing submission_answer
**Key difference from Pattern 1:** Full recount, not incremental delta
```sql
-- On UPDATE of final_score: recalculate from all submission_answers
-- DELETE old mastery record, re-aggregate all answers for that student+objective
```

### Pattern 3: Non-blocking Flutter Write (D-03)
**What:** Insert `submission_analytics` after submit, wrapped in try-catch so failure does not block
**When to use:** Cross-table aggregation that is expensive for a trigger
```dart
// In submitAssignment(), after step 4:
try {
  await _insertSubmissionAnalytics(sessionId, submissionId);
} catch (e) {
  AppLogger.warning('[SUBMIT] submission_analytics insert failed: $e');
  // Non-blocking: submission still succeeds
}
```

### Pattern 4: Supabase Edge Function (D-05)
**What:** Deno TypeScript function processing `ai_queue` items
**Structure:**
```typescript
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

Deno.serve(async (req) => {
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!  // D-20: bypass RLS
  );
  
  // Fetch pending items from ai_queue
  const { data: items } = await supabase
    .from("ai_queue")
    .select("*")
    .eq("status", "pending")
    .order("created_at")
    .limit(10);
  
  for (const item of items ?? []) {
    // Mark processing
    await supabase.from("ai_queue")
      .update({ status: "processing", attempts: item.attempts + 1 })
      .eq("id", item.id);
    
    try {
      if (item.request_type === "feedback") {
        // D-21: Self-JOIN to get question context
        // Process MCQ feedback
      } else if (item.request_type === "analysis") {
        // D-14/D-15: Generate recommendations
      } else if (item.request_type === "score") {
        // STUB: Essay scoring deferred
        console.log("Score request deferred:", item.id);
      }
      
      await supabase.from("ai_queue")
        .update({ status: "completed", updated_at: new Date().toISOString() })
        .eq("id", item.id);
    } catch (error) {
      // Retry logic: max 3 attempts
      if (item.attempts + 1 >= 3) {
        await supabase.from("ai_queue")
          .update({ status: "failed" }).eq("id", item.id);
      } else {
        await supabase.from("ai_queue")
          .update({ status: "pending" }).eq("id", item.id);
      }
    }
  }
  
  return new Response(JSON.stringify({ processed: items?.length ?? 0 }));
});
```

### Pattern 5: SubmissionStatus Enum Extension with Graceful Degradation (D-16)
```dart
enum SubmissionStatus {
  draft,
  submitted,
  aiProcessing,      // NEW
  pendingReview,     // NEW  
  graded,
  unknown,           // D-16: graceful degradation
}
```
**JSON parsing must handle unknown strings gracefully** -- map any unrecognized value to `unknown`. This requires custom fromJson or a default in the generated code.

### Anti-Patterns to Avoid
- **Hand-rolling mastery calculation in Flutter:** Use DB triggers. Flutter has multiple submit paths -- trigger catches all.
- **Blocking submission on analytics failure:** D-03 explicitly says non-blocking. Always try-catch.
- **Incremental delta for grade override:** D-09 says full recount. Old approach of `mastery -= old, mastery += new` is error-prone with concurrent updates.
- **Pre-populating ai_queue payload:** D-21 says Edge Function self-JOINs. Stale data risk otherwise.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Skill mastery calculation | Flutter-side aggregation | PostgreSQL trigger UPSERT | Multiple code paths (submit, override, re-grade) |
| Question statistics | Manual counter in code | PostgreSQL trigger | Same reason -- trigger catches all INSERT paths |
| Notification delivery | Custom polling | Supabase Realtime on `in_app_notifications` | Already have `subscribeToChanges()` in `supabase_datasource.dart` |
| AI API calls from Flutter | Direct HTTP from mobile | Supabase Edge Function | API keys must not be on client; service role key needed |
| Status polling | Timer-based polling | Supabase Realtime on `work_sessions` | D-17: subscribe to row changes |

## Common Pitfalls

### Pitfall 1: Trigger Execution Order
**What goes wrong:** Multiple triggers on same table fire in alphabetical order by trigger name
**Why it happens:** PostgreSQL fires AFTER INSERT triggers alphabetically. If skill_mastery trigger depends on question_stats, ordering matters.
**How to avoid:** Make triggers independent (both read from `submission_answers` directly). Name with consistent prefix: `trg_sa_01_skill`, `trg_sa_02_stats`.
**Warning signs:** Data inconsistency between tables after same INSERT.

### Pitfall 2: Trigger Performance on Bulk Insert
**What goes wrong:** `submitAssignment()` inserts N submission_answers in a loop. Each INSERT fires trigger. For 30 questions = 30 trigger executions.
**Why it happens:** FOR EACH ROW triggers fire per row, not per statement.
**How to avoid:** This is acceptable for <50 questions. If performance becomes an issue, batch into single INSERT with RETURNING and use FOR EACH STATEMENT trigger.
**Warning signs:** Submit takes >5s for large assignments.

### Pitfall 3: Enum Deserialization Crash
**What goes wrong:** DB has `ai_processing` but Flutter only knows `draft`, `submitted`, `graded`. JSON parse throws.
**Why it happens:** 7-11a deploys DB migration before 7-11b deploys Flutter code.
**How to avoid:** D-16 -- add `unknown` enum value as catch-all. Deploy DB first, Flutter second.
**Warning signs:** "Failed to decode" errors in logs after DB migration.

### Pitfall 4: Missing Settings in Distribution Query
**What goes wrong:** `submitAssignment()` reads `distribution` but doesn't SELECT `settings` column.
**Why it happens:** Current query only selects `due_at, allow_late, late_policy`.
**How to avoid:** D-11 -- add `settings` to the SELECT. Parse null-safe with defaults.
**Warning signs:** `settings` always null, AI toggle never activates.

### Pitfall 5: Edge Function Cannot Read Teacher API Keys
**What goes wrong:** Edge Function tries to read `profiles.metadata` but RLS blocks it.
**Why it happens:** `profiles` has RLS -- Edge Function needs service role key.
**How to avoid:** D-20 -- use `SUPABASE_SERVICE_ROLE_KEY` in Edge Function createClient.
**Warning signs:** "Permission denied" or empty result when querying profiles.

### Pitfall 6: Realtime Subscription Leak
**What goes wrong:** Student navigates away from submission screen but Realtime channel stays open.
**Why it happens:** Forgot to call `unsubscribe()` in dispose.
**How to avoid:** Use `ref.onDispose()` in Riverpod provider to clean up channel. Or use `autoDispose` provider.
**Warning signs:** Multiple channels accumulating, WebSocket connection count growing.

### Pitfall 7: Grade Override Trigger Double-Fires
**What goes wrong:** Teacher overrides score -> trigger recalculates mastery -> BUT the `submission_answers` UPDATE also fires the INSERT trigger.
**Why it happens:** UPDATE on `final_score` column fires both AFTER UPDATE trigger (D-09) and potentially AFTER INSERT trigger if poorly scoped.
**How to avoid:** INSERT trigger only fires on INSERT. UPDATE trigger (D-09) only fires on UPDATE. They are separate events. BUT ensure the UPDATE trigger does a full recount (not delta), since the INSERT trigger already counted the original value.
**Warning signs:** Mastery counts are off by 1 after override.

## Code Examples

### Current submitAssignment() Flow (lines 1075-1496)
The existing flow in `assignment_datasource.dart`:
1. Read autosave_answers + distribution (parallel)
2. Read assignment_questions + questions (for grading)
3. Insert submission_answers (with auto-graded final_score for MCQ)
4. Insert/update submissions record
5. Update work_sessions status to 'submitted'
6. Delete autosave_answers

**Phase 7 modifications needed:**
- Step 1: Add `settings` to distribution SELECT (D-11)
- After step 4: Insert submission_analytics (D-03, non-blocking)
- Step 5: Conditionally set status to `graded` or `ai_processing` based on `settings.ai_feedback_enabled` (D-11, D-12)
- After step 5: If AI enabled, INSERT `feedback` requests into ai_queue for ALL MCQ answers (D-11)

### Invoking Edge Function from Flutter
```dart
// In assignment_datasource.dart or separate service
final response = await _client.functions.invoke(
  'process-ai-queue',
  body: {'submission_id': submissionId, 'retroactive': true},
);
if (response.status != 200) {
  AppLogger.warning('[AI] Edge function invocation failed: ${response.status}');
}
```

### Realtime Subscription for AI Status (D-17)
```dart
// Using existing supabase_datasource.dart pattern
final channel = _client.channel('work-session-$sessionId')
  .onPostgresChanges(
    event: PostgresChangeEvent.update,
    schema: 'public',
    table: 'work_sessions',
    filter: PostgresChangeFilter(
      type: PostgresChangeFilterType.eq,
      column: 'id',
      value: sessionId,
    ),
    callback: (payload) {
      final newStatus = payload.newRecord['status'] as String?;
      if (newStatus == 'graded' || newStatus == 'pending_review') {
        // Refresh UI, show score
      }
    },
  )
  .subscribe();
```

### Per-Question Timer for Workspace (D-10)
```dart
// Track time per question in workspace
final Map<String, Stopwatch> _questionTimers = {};
String? _currentQuestionId;

void onQuestionChanged(String newQuestionId) {
  // Pause old timer
  if (_currentQuestionId != null) {
    _questionTimers[_currentQuestionId!]?.stop();
  }
  // Start/resume new timer
  _questionTimers.putIfAbsent(newQuestionId, () => Stopwatch());
  _questionTimers[newQuestionId]!.start();
  _currentQuestionId = newQuestionId;
}

Map<String, int> getTimeLog() {
  return _questionTimers.map(
    (id, sw) => MapEntry(id, sw.elapsed.inSeconds),
  );
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Flutter-side analytics writes | PostgreSQL triggers | Phase 7 decision | Guarantees data consistency |
| FCM push notifications | in_app_notifications table + Realtime | D-13 | Simpler, no external service |
| Single submission status (3 values) | Extended status (5 values + unknown) | 7-11 | Supports AI workflow |
| Polling for AI results | Supabase Realtime subscriptions | D-17 | Real-time, no wasted requests |

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test + integration_test |
| Config file | (default Flutter test config) |
| Quick run command | `flutter test test/unit/ -x` |
| Full suite command | `flutter test` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| 7-01 | Skill mastery populated after MCQ submit | manual (DB trigger) | SQL query verification | N/A - DB trigger |
| 7-02 | Question stats populated after submit | manual (DB trigger) | SQL query verification | N/A - DB trigger |
| 7-03 | submission_analytics created after submit | unit | `flutter test test/unit/datasources/submission_analytics_test.dart -x` | Wave 0 |
| 7-04 | Grade override creates record | integration | `flutter test test/integration/grading_flow_test.dart -x` | Exists (needs update) |
| 7-05 | Edge Function processes ai_queue | manual (Deno test) | `supabase functions serve` + curl test | Wave 0 |
| 7-06 | Phase 4 UAT closure | manual (app test) | N/A | N/A |
| 7-07 | Recommendations generated from skill gaps | manual (DB + Edge Function) | SQL query verification | N/A |
| 7-08 | AI feedback written to submission_answers | manual (Edge Function) | curl test | N/A |
| 7-09 | Phase 5 UAT closure | manual (app test) | N/A | N/A |
| 7-10 | Phase 2 UAT closure (filter bug) | manual (app test) | N/A | N/A |
| 7-11 | SubmissionStatus enum + submit flow changes | unit | `flutter test test/unit/entities/submission_status_test.dart -x` | Wave 0 |

### Sampling Rate
- **Per task commit:** `flutter analyze` (0 errors required)
- **Per wave merge:** `flutter test` full suite
- **Phase gate:** Full suite green + manual UAT on device

### Wave 0 Gaps
- [ ] SQL trigger tests: verify via Supabase MCP `execute_sql` after deploying triggers
- [ ] `test/unit/entities/submission_status_test.dart` -- covers 7-11 enum parsing + unknown fallback
- [ ] Edge Function test: manual curl invocation after `supabase functions serve`
- [ ] Most Phase 7 validation is **manual UAT** (submit MCQ -> check DB tables have data)

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter | All | Yes | 3.38.7 | -- |
| Supabase CLI | Edge Function deploy | Yes | 2.78.1 | -- |
| Deno | Edge Function local dev | No | -- | Use `supabase functions serve` (bundles Deno runtime) |
| Supabase MCP | SQL migrations | Yes | (MCP tool) | Direct SQL via dashboard |
| PostgreSQL (Supabase) | Triggers | Yes (remote) | -- | -- |

**Missing dependencies with no fallback:**
- None -- all critical dependencies available

**Missing dependencies with fallback:**
- Deno CLI not installed locally, but Supabase CLI 2.78.1 includes built-in Edge Runtime for `supabase functions serve`. No separate Deno install needed for development.

## Open Questions

1. **Trigger vs Separate Function for D-01/D-02**
   - What we know: Both need AFTER INSERT on `submission_answers`. Can be one function or two.
   - What's unclear: Whether combining into one trigger function is better for performance or maintainability.
   - Recommendation: Use separate trigger functions for clarity. Each is ~30 lines. Independent = easier to debug.

2. **Per-question timer accuracy on app background**
   - What we know: D-10 requires client-side `time_log` per question
   - What's unclear: What happens when app is backgrounded mid-question? Stopwatch keeps running.
   - Recommendation: Validate server-side per D-10: `SUM(time_log) <= time_spent_seconds + tolerance`. If invalid, store null.

3. **Edge Function cold start latency**
   - What we know: Supabase Edge Functions have cold starts (100-500ms)
   - What's unclear: Whether this affects the post-submit queue processing experience
   - Recommendation: Not an issue -- queue processing is async. Student sees "AI processing..." badge immediately. Edge Function processes in background.

## Sources

### Primary (HIGH confidence)
- Project codebase: `assignment_datasource.dart` lines 1075-1496 (submit flow)
- Project codebase: `grade_override_datasource.dart` (complete, 114 lines)
- Project codebase: `analytics_datasource.dart` (READ path for skill_mastery, lines 220-280)
- Project codebase: `recommendation_datasource.dart` (READ path for ai_recommendations)
- Project codebase: `supabase_datasource.dart` (Realtime subscription pattern, lines 557-613)
- DB schema: `schema_03_submissions_ai_analytics.sql` (all target tables)
- DB schema: `schema_02_questions_assignments.sql` (question_objectives, questions.tags)
- Project CONTEXT.md: D-01 through D-24 (all locked decisions)

### Secondary (MEDIUM confidence)
- [Supabase Edge Functions docs](https://supabase.com/docs/guides/functions) - Deno.serve pattern, deployment
- [Supabase Edge Function secrets](https://supabase.com/docs/guides/functions/secrets) - SUPABASE_SERVICE_ROLE_KEY
- [Supabase RLS bypass with service role](https://supabase.com/docs/guides/api/api-keys) - service_role key always bypasses RLS

### Tertiary (LOW confidence)
- None -- all findings verified against codebase or official docs

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - no new libraries, all existing project dependencies
- Architecture: HIGH - patterns directly from CONTEXT.md decisions + existing codebase
- Pitfalls: HIGH - derived from code analysis of actual submit flow and schema
- Edge Function: MEDIUM - no existing Edge Functions in project, pattern from Supabase docs

**Research date:** 2026-04-08
**Valid until:** 2026-05-08 (stable -- PostgreSQL triggers and Supabase Edge Functions are mature)
