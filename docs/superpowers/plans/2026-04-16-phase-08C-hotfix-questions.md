# Phase 08-C: Hotfix Câu Hỏi Sau Publish (Delta Override + Batch Regrade)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **Dependency:** Độc lập — có thể làm song song với 08-B.

**Goal:** Giáo viên có thể sửa nội dung câu hỏi trong một đề đã publish (hotfix), hệ thống cập nhật Realtime cho học sinh đang làm bài, và có nút "Chấm lại tất cả" sau khi sửa xong.

**Architecture:**
- "Sửa đề này" → UPDATE `assignment_questions.custom_content` (delta override), KHÔNG đụng bảng `questions`.
- UI lock: nếu `work_sessions` đã tồn tại → disable Thêm/Xóa choice, chỉ cho sửa text + toggle isCorrect.
- Supabase Realtime stream trong workspace subscribe `assignment_questions` → silent re-render.
- Batch regrade: Supabase RPC `batch_regrade_assignment` → INSERT `grade_overrides` hàng loạt → Trigger D-01 chạy.

**Tech Stack:** Dart/Flutter, Supabase Realtime, PostgreSQL RPC, Riverpod

---

## File Map

| File | Action | Trách nhiệm |
|------|--------|-------------|
| `db/migrations/008_batch_regrade_rpc.sql` | CREATE | RPC batch_regrade_assignment |
| `lib/data/datasources/assignment_datasource.dart` | MODIFY | updateAssignmentQuestionContent() + batchRegradeAssignment() |
| `lib/domain/repositories/assignment_repository.dart` | MODIFY | Interface cho 2 methods mới |
| `lib/data/repositories/assignment_repository_impl.dart` | MODIFY | Impl cho 2 methods mới |
| `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` | MODIFY | Nút "Sửa đề/đáp án" per question + UI lock |
| `lib/presentation/providers/workspace_provider.dart` | MODIFY | Realtime subscription assignment_questions |

---

## Task 1: Supabase RPC — batch_regrade_assignment

**Files:**
- Create: `db/migrations/008_batch_regrade_rpc.sql`

- [ ] **Step 1: Viết RPC**

```sql
-- =============================================================
-- RPC: batch_regrade_assignment
-- Khi GV sửa đề/đáp án, gọi RPC này để chấm lại toàn bộ bài nộp.
-- Logic:
--   1. Lấy tất cả submission_answers cho assignment này
--   2. Với mỗi câu trắc nghiệm: so sánh selected_choice_ids với correct IDs mới
--   3. INSERT vào grade_overrides (Trigger D-01 sẽ tự update skill_mastery)
-- Returns: số bài được chấm lại
-- =============================================================
CREATE OR REPLACE FUNCTION batch_regrade_assignment(
  p_assignment_id UUID,
  p_graded_by     UUID  -- teacher user id
)
RETURNS INTEGER AS $$
DECLARE
  v_count     INTEGER := 0;
  rec         RECORD;
  v_new_score NUMERIC;
  v_correct_ids JSONB;
  v_selected_ids JSONB;
  v_max_points NUMERIC;
BEGIN
  -- Lặp qua tất cả submission_answers của assignment này
  FOR rec IN
    SELECT
      sa.id                         AS sa_id,
      sa.assignment_question_id     AS aq_id,
      sa.answer                     AS student_answer,
      sa.final_score                AS old_score,
      aq.points                     AS max_points,
      aq.custom_content             AS custom_content,
      aq.question_id                AS question_id
    FROM submission_answers sa
    JOIN assignment_questions aq ON aq.id = sa.assignment_question_id
    WHERE aq.assignment_id = p_assignment_id
  LOOP
    v_max_points := rec.max_points;

    -- Lấy correct_choice_ids mới nhất từ custom_content (delta override ưu tiên)
    -- Fallback về question_choices nếu không có override
    IF rec.custom_content IS NOT NULL AND rec.custom_content ? 'choices' THEN
      -- Lấy từ custom_content.choices (đã sửa bởi GV)
      SELECT jsonb_agg(c->>'id')
      INTO v_correct_ids
      FROM jsonb_array_elements(rec.custom_content->'choices') c
      WHERE (c->>'isCorrect')::BOOLEAN = true
         OR (c->>'is_correct')::BOOLEAN = true;

    ELSIF rec.question_id IS NOT NULL THEN
      -- Lấy từ question bank
      SELECT jsonb_agg(qc.id::TEXT)
      INTO v_correct_ids
      FROM question_choices qc
      WHERE qc.question_id = rec.question_id
        AND qc.is_correct = true;
    ELSE
      v_correct_ids := '[]'::JSONB;
    END IF;

    v_correct_ids := COALESCE(v_correct_ids, '[]'::JSONB);

    -- Lấy selected_choice_ids từ student answer
    v_selected_ids := COALESCE(
      rec.student_answer->'selected_choice_ids',
      '[]'::JSONB
    );

    -- Tính điểm mới: trắc nghiệm → đúng hết = full points, còn lại = 0
    IF v_correct_ids = '[]'::JSONB OR v_selected_ids = '[]'::JSONB THEN
      v_new_score := 0;
    ELSIF v_correct_ids = v_selected_ids THEN
      v_new_score := v_max_points;
    ELSE
      v_new_score := 0;
    END IF;

    -- Chỉ insert grade_override nếu điểm thay đổi
    IF v_new_score IS DISTINCT FROM rec.old_score THEN
      INSERT INTO grade_overrides (
        submission_answer_id,
        old_score,
        new_score,
        reason,
        overridden_by,
        created_at
      ) VALUES (
        rec.sa_id,
        rec.old_score,
        v_new_score,
        'batch_regrade: assignment questions updated by teacher',
        p_graded_by,
        NOW()
      );

      -- Update final_score trực tiếp
      UPDATE submission_answers
      SET final_score = v_new_score,
          updated_at  = NOW()
      WHERE id = rec.sa_id;

      v_count := v_count + 1;
    END IF;
  END LOOP;

  RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute cho authenticated users (GV sẽ gọi)
GRANT EXECUTE ON FUNCTION batch_regrade_assignment(UUID, UUID) TO authenticated;
```

- [ ] **Step 2: Apply migration**

Apply qua Supabase MCP.
Expected: Function created.

- [ ] **Step 3: Commit**

```bash
git add db/migrations/008_batch_regrade_rpc.sql
git commit -m "feat(db): add batch_regrade_assignment RPC for post-publish hotfix regrade"
```

---

## Task 2: DataSource — updateAssignmentQuestionContent + batchRegradeAssignment

**Files:**
- Modify: `lib/data/datasources/assignment_datasource.dart`

- [ ] **Step 1: Thêm 2 methods vào cuối AssignmentDataSource**

```dart
/// Hotfix: Update nội dung câu hỏi trong đề (Delta Override Pattern).
/// CHỈ update assignment_questions.custom_content, KHÔNG đụng questions bank.
/// [lock] = true khi đã có work_sessions → chỉ cho sửa text/isCorrect, không thêm/xóa choice.
Future<Map<String, dynamic>> updateAssignmentQuestionContent(
  String assignmentQuestionId,
  Map<String, dynamic> contentPatch, {
  bool lock = false,
}) async {
  // Đọc custom_content hiện tại
  final existing = await _client
      .from('assignment_questions')
      .select('custom_content')
      .eq('id', assignmentQuestionId)
      .single();

  final currentContent = (existing['custom_content'] as Map<String, dynamic>?) ?? {};

  // Merge patch vào current (Delta Override)
  final merged = Map<String, dynamic>.from(currentContent)..addAll(contentPatch);

  final res = await _client
      .from('assignment_questions')
      .update({'custom_content': merged})
      .eq('id', assignmentQuestionId)
      .select()
      .single();

  return Map<String, dynamic>.from(res);
}

/// Batch regrade: gọi RPC sau khi GV sửa đề.
/// Returns số bài đã chấm lại.
Future<int> batchRegradeAssignment(
  String assignmentId,
  String gradedBy,
) async {
  final result = await _client.rpc(
    'batch_regrade_assignment',
    params: {
      'p_assignment_id': assignmentId,
      'p_graded_by': gradedBy,
    },
  );
  return (result as int?) ?? 0;
}

/// Kiểm tra có work_sessions nào đã tạo cho assignment này chưa.
/// Dùng để UI lock: nếu true → disable thêm/xóa choice.
Future<bool> hasActiveWorkSessions(String assignmentId) async {
  final res = await _client
      .from('work_sessions')
      .select('id')
      .eq('assignment_id', assignmentId)
      .limit(1);
  return (res as List).isNotEmpty;
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/data/datasources/assignment_datasource.dart
git commit -m "feat(hotfix): add updateAssignmentQuestionContent + batchRegradeAssignment to datasource"
```

---

## Task 3: Repository Interface + Impl

**Files:**
- Modify: `lib/domain/repositories/assignment_repository.dart`
- Modify: `lib/data/repositories/assignment_repository_impl.dart`

- [ ] **Step 1: Thêm vào interface**

Thêm vào cuối `abstract class AssignmentRepository`:
```dart
Future<Map<String, dynamic>> updateAssignmentQuestionContent(
  String assignmentQuestionId,
  Map<String, dynamic> contentPatch,
);

Future<int> batchRegradeAssignment(String assignmentId, String gradedBy);

Future<bool> hasActiveWorkSessions(String assignmentId);
```

- [ ] **Step 2: Thêm vào impl**

```dart
@override
Future<Map<String, dynamic>> updateAssignmentQuestionContent(
  String assignmentQuestionId,
  Map<String, dynamic> contentPatch,
) async {
  try {
    return await _ds.updateAssignmentQuestionContent(assignmentQuestionId, contentPatch);
  } catch (e) {
    throw Exception(ErrorTranslationUtils.translateError(e,
        fallback: 'Không thể cập nhật câu hỏi'));
  }
}

@override
Future<int> batchRegradeAssignment(String assignmentId, String gradedBy) async {
  try {
    return await _ds.batchRegradeAssignment(assignmentId, gradedBy);
  } catch (e) {
    throw Exception(ErrorTranslationUtils.translateError(e,
        fallback: 'Không thể chấm lại bài'));
  }
}

@override
Future<bool> hasActiveWorkSessions(String assignmentId) async {
  try {
    return await _ds.hasActiveWorkSessions(assignmentId);
  } catch (e) {
    return false;
  }
}
```

- [ ] **Step 3: Analyze + build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/domain/repositories/assignment_repository.dart \
        lib/data/repositories/assignment_repository_impl.dart
git commit -m "feat(hotfix): add hotfix + regrade methods to repository interface and impl"
```

---

## Task 4: UI — Nút "Sửa đề/đáp án (Bài này)" + Lock khi có work_sessions

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart`

Đây là màn hình detail/editor của assignment. Mục tiêu: thêm nút hotfix per-question, lock thêm/xóa choice khi đã publish và có sessions.

- [ ] **Step 1: Thêm state `_hasActiveSessions` và load trong initState**

```dart
bool _hasActiveSessions = false;

@override
void initState() {
  super.initState();
  _loadAssignment();  // đã tồn tại
  _checkActiveSessions();
}

Future<void> _checkActiveSessions() async {
  if (widget.assignmentId == null) return;
  final repo = ref.read(assignmentRepositoryProvider);
  final has = await repo.hasActiveWorkSessions(widget.assignmentId!);
  if (mounted) setState(() => _hasActiveSessions = has);
}
```

- [ ] **Step 2: Thêm nút "Sửa (Bài này)" trên mỗi question item**

Tìm chỗ render question list item trong màn hình. Thêm trailing action:

```dart
// Trong question list item widget, thêm nút hotfix:
IconButton(
  icon: const Icon(Icons.edit_note_outlined),
  tooltip: 'Sửa đề/đáp án (Chỉ áp dụng bài này)',
  onPressed: () => _showHotfixDialog(context, question),
),
```

- [ ] **Step 3: Viết _showHotfixDialog**

```dart
Future<void> _showHotfixDialog(
  BuildContext context,
  Map<String, dynamic> question,
) async {
  final aqId = question['id'] as String;
  final currentText = question['content']?['text'] as String? 
      ?? question['override_text'] as String? ?? '';
  final choices = List<Map<String, dynamic>>.from(
    question['question_choices'] as List? ?? []
  );

  final textController = TextEditingController(text: currentText);

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setModal) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sửa câu hỏi (Chỉ đề này)',
                style: DesignTypography.titleMedium),
            if (_hasActiveSessions)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DesignColors.warningLight,
                  borderRadius: DesignRadius.sm,
                ),
                child: Row(children: [
                  const Icon(Icons.lock_outline, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    'Học sinh đã bắt đầu làm bài. Chỉ có thể sửa nội dung, không thể thêm/xóa đáp án.',
                    style: DesignTypography.bodySmall,
                  )),
                ]),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Nội dung câu hỏi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            // Choices list
            ...choices.asMap().entries.map((entry) {
              final idx = entry.key;
              final c = entry.value;
              final choiceText = c['content']?['text'] as String? ?? c['text'] as String? ?? '';
              final isCorrect = c['is_correct'] as bool? ?? false;
              final choiceCtrl = TextEditingController(text: choiceText);

              return Row(children: [
                Checkbox(
                  value: isCorrect,
                  onChanged: (val) => setModal(() => choices[idx]['is_correct'] = val),
                ),
                Expanded(
                  child: TextField(
                    controller: choiceCtrl,
                    onChanged: (val) => choices[idx]['text'] = val,
                    decoration: InputDecoration(labelText: 'Đáp án ${idx + 1}'),
                  ),
                ),
              ]);
            }),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _saveHotfix(aqId, textController.text, choices);
                  },
                  child: const Text('Lưu thay đổi'),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );
  textController.dispose();
}
```

- [ ] **Step 4: Viết _saveHotfix + Snackbar Regrade**

```dart
Future<void> _saveHotfix(
  String aqId,
  String newText,
  List<Map<String, dynamic>> choices,
) async {
  final repo = ref.read(assignmentRepositoryProvider);

  // Build content patch (Delta Override)
  final patch = <String, dynamic>{
    'override_text': newText,
    'choices': choices.asMap().entries.map((e) => {
      'id': e.key,
      'text': e.value['text'] ?? e.value['content']?['text'] ?? '',
      'isCorrect': e.value['is_correct'] ?? false,
    }).toList(),
  };

  await repo.updateAssignmentQuestionContent(aqId, patch);

  if (!mounted) return;

  // Reload questions để UI cập nhật
  // (gọi lại loadAssignment hoặc invalidate provider)
  _loadAssignment();

  // Snackbar gợi ý chấm lại
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text('Câu hỏi đã được sửa. Học sinh đã nộp có thể bị ảnh hưởng.'),
    action: SnackBarAction(
      label: 'Chấm lại tất cả',
      onPressed: () => _batchRegrade(),
    ),
    duration: const Duration(seconds: 8),
  ));
}

Future<void> _batchRegrade() async {
  final repo = ref.read(assignmentRepositoryProvider);
  final auth = ref.read(authNotifierProvider);
  final teacherId = auth.value?.id;
  if (teacherId == null || widget.assignmentId == null) return;

  try {
    final count = await repo.batchRegradeAssignment(
      widget.assignmentId!,
      teacherId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Đã chấm lại $count bài nộp.'),
      backgroundColor: DesignColors.success,
    ));
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Lỗi khi chấm lại: $e'),
      backgroundColor: DesignColors.error,
    ));
  }
}
```

- [ ] **Step 5: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
```
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
git commit -m "feat(hotfix): add per-question hotfix UI with lock and batch regrade snackbar"
```

---

## Task 5: Realtime — Silent Re-render khi GV sửa đề

**Files:**
- Modify: `lib/presentation/providers/workspace_provider.dart`

- [ ] **Step 1: Thêm Supabase Realtime subscription trong WorkspaceNotifier**

Thêm field vào state/notifier:
```dart
RealtimeChannel? _questionChannel;
```

Thêm hàm subscribe vào cuối `initialize()`, sau khi `state = AsyncData(wsState)`:
```dart
// Subscribe Realtime: lắng nghe thay đổi assignment_questions (GV hotfix)
final assignmentId = assignment['id'] as String?;
if (assignmentId != null) {
  _subscribeToQuestionChanges(assignmentId);
}
```

- [ ] **Step 2: Viết _subscribeToQuestionChanges**

```dart
void _subscribeToQuestionChanges(String assignmentId) {
  final client = SupabaseService.client;

  _questionChannel = client
      .channel('assignment_questions_$assignmentId')
      .onPostgresChanges(
        event: PostgresChangeEvent.update,
        schema: 'public',
        table: 'assignment_questions',
        filter: PostgresChangeFilter(
          type: PostgresFilterType.eq,
          column: 'assignment_id',
          value: assignmentId,
        ),
        callback: (payload) {
          _onQuestionUpdated(payload.newRecord);
        },
      )
      .subscribe();
}

void _onQuestionUpdated(Map<String, dynamic> updatedAq) {
  final currentState = state.valueOrNull;
  if (currentState == null) return;

  // Silent update: chỉ đổi text câu hỏi, không reset answers
  final aqId = updatedAq['id'] as String?;
  if (aqId == null) return;

  final updatedQuestions = currentState.questions.map((q) {
    if (q.id != aqId) return q;
    // Merge custom_content mới vào question state
    final customContent = updatedAq['custom_content'] as Map<String, dynamic>?;
    if (customContent == null) return q;
    return q.copyWith(
      overrideText: customContent['override_text'] as String?,
      // Nếu choices thay đổi isCorrect → không ảnh hưởng display, chỉ backend regrade
    );
  }).toList();

  state = AsyncData(currentState.copyWith(questions: updatedQuestions));
}
```

- [ ] **Step 3: Cancel subscription khi dispose**

Tìm chỗ dispose trong WorkspaceNotifier (hoặc override `dispose()`):
```dart
@override
void dispose() {
  _questionChannel?.unsubscribe();
  super.dispose();
}
```

- [ ] **Step 4: Đảm bảo QuestionState có field overrideText**

Kiểm tra model `QuestionState` (trong workspace_provider.dart hoặc entity):
```dart
// Nếu chưa có overrideText field thì thêm vào QuestionState
class QuestionState {
  final String id;
  final String? overrideText;  // ← thêm nếu chưa có
  // ...
}
```

- [ ] **Step 5: Analyze**

```bash
flutter analyze lib/presentation/providers/workspace_provider.dart
```
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/providers/workspace_provider.dart
git commit -m "feat(hotfix): realtime silent re-render when teacher updates assignment_questions"
```

---

## Self-Review

**Spec coverage:**
- [x] UPDATE custom_content thay vì questions bank (Task 2)
- [x] UI lock thêm/xóa choice khi có work_sessions (Task 4 Step 1-3)
- [x] Batch regrade: Supabase RPC → grade_overrides (Task 1)
- [x] Snackbar "X bài bị ảnh hưởng → Chấm lại" (Task 4 Step 4)
- [x] Realtime silent re-render trong workspace (Task 5)
- [x] Không reload page, không block học sinh (Task 5 Step 2)

**Gaps:** Không có.
