# Phase 08-B: Shuffle Wiring — Nối Variant vào Workspace

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **Dependency:** Phase 08-A phải hoàn thành trước (DB functions đã viết lại, INT IDs đã fix).

**Goal:** Nối cơ chế shuffle vào toàn bộ luồng làm bài của học sinh: khi bắt đầu thi → tạo variant, khi load workspace → đọc variant để render thứ tự câu/đáp án đã đảo.

**Architecture:**
- `getOrCreateSubmission()` trong `assignment_datasource.dart`: sau INSERT `work_sessions` → gọi Supabase RPC `ensure_student_variant`.
- `getDistributionDetail()`: nhận thêm `studentId` → fetch variant của student → sort questions theo `display_order`, attach `shuffled_choices` vào mỗi câu.
- Workspace Flutter: render choices theo `shuffled_choices` order; khi student chọn đáp án → gửi ID gốc (INT), không gửi index.

**Tech Stack:** Dart/Flutter, Supabase (RPC), Riverpod

---

## File Map

| File | Action | Trách nhiệm |
|------|--------|-------------|
| `lib/data/datasources/assignment_datasource.dart` | MODIFY | Gọi ensure_student_variant sau tạo work_session; fetch + apply variant trong getDistributionDetail |
| `lib/presentation/providers/workspace_provider.dart` | MODIFY | Truyền studentId vào getDistributionDetail |
| `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart` | MODIFY | Render choices theo shuffled_choices thứ tự |

---

## Task 1: Gọi ensure_student_variant khi tạo work_session

**Files:**
- Modify: `lib/data/datasources/assignment_datasource.dart` (hàm `getOrCreateSubmission`, khoảng line 1089–1104)

- [ ] **Step 1: Thêm RPC call sau INSERT work_sessions**

Tìm đoạn (khoảng line 1089):
```dart
// Tạo mới submission draft
final newSubmission = await _client
    .from('work_sessions')
    .insert({
      'assignment_distribution_id': distributionId,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'status': 'in_progress',
    })
    .select()
    .single();

final result = Map<String, dynamic>.from(newSubmission);
result['attempt_count'] = attemptCount;
return result;
```

Sửa thành:
```dart
// Tạo mới work_session
final newSubmission = await _client
    .from('work_sessions')
    .insert({
      'assignment_distribution_id': distributionId,
      'assignment_id': assignmentId,
      'student_id': studentId,
      'status': 'in_progress',
    })
    .select()
    .single();

// Tạo variant ngay khi bắt đầu thi (Snapshot Architecture)
// ensure_student_variant: tạo 1 lần, idempotent nếu đã tồn tại
try {
  await _client.rpc('ensure_student_variant', params: {
    'p_assignment_id': assignmentId,
    'p_student_id': studentId,
  });
} catch (e) {
  // Variant failure không block học sinh làm bài — log và tiếp tục
  AppLogger.warning('[AssignmentDS] ensure_student_variant failed: $e');
}

final result = Map<String, dynamic>.from(newSubmission);
result['attempt_count'] = attemptCount;
return result;
```

- [ ] **Step 2: Analyze**

```bash
flutter analyze lib/data/datasources/assignment_datasource.dart
```
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add lib/data/datasources/assignment_datasource.dart
git commit -m "feat(shuffle): call ensure_student_variant on work_session creation"
```

---

## Task 2: getDistributionDetail nhận studentId và apply variant

**Files:**
- Modify: `lib/data/datasources/assignment_datasource.dart` (hàm `getDistributionDetail`, khoảng line 518)

- [ ] **Step 1: Thêm tham số studentId vào signature**

Tìm:
```dart
Future<Map<String, dynamic>> getDistributionDetail(
  String distributionId,
) async {
```

Sửa thành:
```dart
Future<Map<String, dynamic>> getDistributionDetail(
  String distributionId, {
  String? studentId,
}) async {
```

- [ ] **Step 2: Sau khi build `questions` list (~line 708), thêm logic fetch và apply variant**

Tìm đoạn comment `// Đếm sĩ số lớp từ class_members` (khoảng line 711), chèn TRƯỚC đoạn đó:

```dart
// ── Apply variant nếu có studentId (Shuffle Architecture) ──────────────
if (studentId != null && questions.isNotEmpty) {
  try {
    // Fetch variant của student cho assignment này
    final variantRes = await _client
        .from('assignment_variants')
        .select('custom_questions')
        .eq('assignment_id', assignmentId!)
        .eq('variant_type', 'student')
        .eq('student_id', studentId)
        .maybeSingle();

    if (variantRes != null) {
      final customQuestions = variantRes['custom_questions'] as List<dynamic>?;

      if (customQuestions != null && customQuestions.isNotEmpty) {
        // Build lookup: assignment_question_id → {display_order, shuffled_choices}
        final variantMap = <String, Map<String, dynamic>>{};
        for (final vq in customQuestions) {
          final vqMap = vq as Map<String, dynamic>;
          variantMap[vqMap['assignment_question_id'] as String] = vqMap;
        }

        // Apply variant: sort by display_order, attach shuffled_choices
        questions = questions.map((q) {
          final aqId = q['id'] as String?;
          if (aqId == null) return q;
          final variant = variantMap[aqId];
          if (variant == null) return q;
          return {
            ...q,
            'display_order': variant['display_order'] as int,
            'shuffled_choices': variant['shuffled_choices'] as List<dynamic>? ?? [],
          };
        }).toList();

        // Sort questions theo display_order từ variant
        questions.sort((a, b) {
          final aOrder = a['display_order'] as int? ?? (a['order_idx'] as int? ?? 0);
          final bOrder = b['display_order'] as int? ?? (b['order_idx'] as int? ?? 0);
          return aOrder.compareTo(bOrder);
        });
      }
    }
  } catch (e) {
    // Variant fetch failure không block — dùng order_idx gốc
    AppLogger.warning('[AssignmentDS] Failed to apply variant for student $studentId: $e');
  }
}
// ────────────────────────────────────────────────────────────────────────
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/datasources/assignment_datasource.dart
git commit -m "feat(shuffle): getDistributionDetail applies student variant for question/choice order"
```

---

## Task 3: Truyền studentId từ Repository và Provider

**Files:**
- Modify: `lib/domain/repositories/assignment_repository.dart`
- Modify: `lib/data/repositories/assignment_repository_impl.dart`
- Modify: `lib/presentation/providers/workspace_provider.dart`

- [ ] **Step 1: Cập nhật interface trong assignment_repository.dart**

Tìm:
```dart
Future<Map<String, dynamic>> getDistributionDetail(String distributionId);
```

Sửa thành:
```dart
Future<Map<String, dynamic>> getDistributionDetail(
  String distributionId, {
  String? studentId,
});
```

- [ ] **Step 2: Cập nhật impl trong assignment_repository_impl.dart**

Tìm hàm `getDistributionDetail` trong impl (khoảng line 390):
```dart
Future<Map<String, dynamic>> getDistributionDetail(
  String distributionId,
) async {
  try {
    return await _ds.getDistributionDetail(distributionId);
```

Sửa thành:
```dart
Future<Map<String, dynamic>> getDistributionDetail(
  String distributionId, {
  String? studentId,
}) async {
  try {
    return await _ds.getDistributionDetail(distributionId, studentId: studentId);
```

- [ ] **Step 3: Truyền studentId trong workspace_provider.dart**

Tìm trong `initialize()` (khoảng line 75):
```dart
final detail = await repo.getDistributionDetail(distributionId);
```

Sửa thành:
```dart
final detail = await repo.getDistributionDetail(
  distributionId,
  studentId: studentId,
);
```

(`studentId` đã được lấy ở line trước đó: `final studentId = auth.value?.id;`)

- [ ] **Step 4: Analyze + build_runner**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/domain/repositories/assignment_repository.dart \
        lib/data/repositories/assignment_repository_impl.dart \
        lib/presentation/providers/workspace_provider.dart
git commit -m "feat(shuffle): propagate studentId through repo/provider to apply variant order"
```

---

## Task 4: Workspace UI — Render choices theo shuffled_choices

**Files:**
- Modify: `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart`

- [ ] **Step 1: Tìm chỗ render choices trong workspace**

```bash
grep -n "question_choices\|choices\|shuffled_choices" \
  lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart | head -30
```

- [ ] **Step 2: Cập nhật logic render choices**

Tìm đoạn build choices list (thường là `ListView.builder` hoặc `Column` với `choices.map`). Thêm logic sắp xếp theo `shuffled_choices`:

```dart
// Helper: lấy choices đã sort theo shuffled_choices order
List<Map<String, dynamic>> _getSortedChoices(Map<String, dynamic> question) {
  final rawChoices = question['question_choices'] as List<dynamic>? ?? [];
  final shuffledIds = question['shuffled_choices'] as List<dynamic>?;

  if (shuffledIds == null || shuffledIds.isEmpty) {
    // Không có variant → render thứ tự gốc
    return rawChoices.cast<Map<String, dynamic>>();
  }

  // Build lookup: id → choice
  final choiceById = <int, Map<String, dynamic>>{};
  for (final c in rawChoices) {
    final cMap = c as Map<String, dynamic>;
    final id = cMap['id'];
    if (id is int) choiceById[id] = cMap;
  }

  // Render theo thứ tự shuffled_ids
  return shuffledIds
      .map((sid) => choiceById[sid is int ? sid : int.tryParse(sid.toString())])
      .whereType<Map<String, dynamic>>()
      .toList();
}
```

- [ ] **Step 3: Áp dụng helper vào chỗ build choices UI**

Nơi đang render choices (thường dạng):
```dart
// TRƯỚC:
final choices = question['question_choices'] as List<dynamic>? ?? [];
...ListView.builder(itemCount: choices.length, ...)

// SAU:
final choices = _getSortedChoices(question);
...ListView.builder(itemCount: choices.length, ...)
```

- [ ] **Step 4: Verify: answer gửi lên là ID gốc (không phải index)**

Tìm chỗ học sinh tap chọn đáp án → gọi `updateAnswer()`. Confirm đang gửi `choice['id']` (INT), không phải `index`. Nếu đang gửi index thì sửa:

```dart
// ĐÚNG: gửi ID gốc
onTap: () => ref
    .read(workspaceNotifierProvider(distributionId).notifier)
    .updateAnswer(questionId, {'selected_choice_ids': [choice['id']]});

// SAI (nếu đang dùng index):
// onTap: () => updateAnswer(questionId, {'selected_choice_ids': [index]});
```

- [ ] **Step 5: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/student/
```
Expected: no errors.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart
git commit -m "feat(shuffle): workspace renders choices in variant shuffled_choices order"
```

---

## Self-Review

**Spec coverage:**
- [x] ensure_student_variant gọi khi bắt đầu làm bài (Task 1)
- [x] shuffle=false vẫn tạo variant (DB function đã handle trong 08-A)
- [x] getDistributionDetail apply variant order (Task 2)
- [x] Frontend gửi ID gốc khi chọn đáp án, không gửi index (Task 4 Step 4)
- [x] Variant failure không block học sinh (Task 1: try/catch + warning)

**Type consistency:** `shuffled_choices` là `List<dynamic>` chứa INT, cast đúng trong Task 4.
