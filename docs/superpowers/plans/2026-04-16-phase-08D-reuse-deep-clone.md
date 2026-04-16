# Phase 08-D: Reuse & Deep Clone — Tái Sử Dụng Bài Tập

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

> **Dependency:** Độc lập — có thể làm song song với 08-B và 08-C.

**Goal:** Giáo viên có 2 hành động tái sử dụng bài cũ: (1) "Giao bài cho lớp khác" → tạo distribution mới, giữ nguyên assignment_id; (2) "Nhân bản & Chỉnh sửa" → Deep Clone ra assignment_id mới → vào editor.

**Architecture:**
- "Giao bài cho lớp khác": chỉ tạo `assignment_distributions` mới trỏ về `assignment_id` cũ → redirect sang màn hình distribute.
- "Nhân bản & Chỉnh sửa": Supabase RPC `deep_clone_assignment(src_id)` → INSERT `assignments` + copy `assignment_questions` (giữ `question_id`, `custom_content=null`) → trả về `new_assignment_id` → redirect editor.
- UI xuất hiện trong: 3-dot card menu (shortcut) + Assignment Detail screen (nút rõ ràng).

**Tech Stack:** Dart/Flutter, Supabase RPC, Riverpod, GoRouter

---

## File Map

| File | Action | Trách nhiệm |
|------|--------|-------------|
| `db/migrations/008_deep_clone_rpc.sql` | CREATE | RPC deep_clone_assignment |
| `lib/data/datasources/assignment_datasource.dart` | MODIFY | deepCloneAssignment() method |
| `lib/domain/repositories/assignment_repository.dart` | MODIFY | Interface deepCloneAssignment() |
| `lib/data/repositories/assignment_repository_impl.dart` | MODIFY | Impl deepCloneAssignment() |
| `lib/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card.dart` | MODIFY | 3-dot menu: thêm 2 actions |
| `lib/presentation/views/assignment/teacher/teacher_assignment_management_screen.dart` | MODIFY | Xử lý action callbacks từ card |
| `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` | MODIFY | Nút "Giao lớp khác" + "Nhân bản" trong detail |
| `lib/core/routes/route_constants.dart` | MODIFY (nếu cần) | Route constants |

---

## Task 1: Supabase RPC — deep_clone_assignment

**Files:**
- Create: `db/migrations/008_deep_clone_rpc.sql`

- [ ] **Step 1: Viết RPC**

```sql
-- =============================================================
-- RPC: deep_clone_assignment
-- Tạo bản sao bất biến (Immutable Deep Clone) của assignment.
-- Logic:
--   1. INSERT assignments row mới (copy fields từ src, reset is_published=false)
--   2. INSERT assignment_questions rows mới (copy từ src, giữ question_id, custom_content=NULL)
-- Returns: new_assignment_id (UUID)
-- =============================================================
CREATE OR REPLACE FUNCTION deep_clone_assignment(
  p_src_assignment_id UUID,
  p_cloned_by         UUID   -- teacher user id
)
RETURNS UUID AS $$
DECLARE
  v_src       RECORD;
  v_new_id    UUID;
  v_aq        RECORD;
BEGIN
  -- Lấy thông tin assignment gốc
  SELECT * INTO v_src
  FROM assignments
  WHERE id = p_src_assignment_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Assignment % not found', p_src_assignment_id;
  END IF;

  -- Verify người gọi là teacher của assignment này
  IF v_src.teacher_id != p_cloned_by THEN
    RAISE EXCEPTION 'Permission denied: only assignment owner can clone';
  END IF;

  -- INSERT assignment mới
  INSERT INTO assignments (
    class_id,
    teacher_id,
    title,
    description,
    is_published,
    total_points,
    default_shuffle_questions,
    default_shuffle_choices,
    created_at,
    updated_at
  ) VALUES (
    v_src.class_id,
    p_cloned_by,
    v_src.title || ' (Bản sao)',  -- Đánh dấu là bản sao
    v_src.description,
    false,         -- Bắt đầu ở trạng thái draft
    v_src.total_points,
    v_src.default_shuffle_questions,
    v_src.default_shuffle_choices,
    NOW(),
    NOW()
  )
  RETURNING id INTO v_new_id;

  -- Copy assignment_questions sang ID mới
  -- Giữ: question_id (tham chiếu bank), points, order_idx, rubric
  -- Reset: custom_content = NULL (bản sao bắt đầu clean, override khi GV sửa)
  FOR v_aq IN
    SELECT * FROM assignment_questions
    WHERE assignment_id = p_src_assignment_id
    ORDER BY order_idx
  LOOP
    INSERT INTO assignment_questions (
      assignment_id,
      question_id,
      custom_content,   -- NULL: không copy override cũ sang bản sao
      points,
      rubric,
      order_idx
    ) VALUES (
      v_new_id,
      v_aq.question_id,
      NULL,             -- Bản sao bắt đầu không có override
      v_aq.points,
      v_aq.rubric,
      v_aq.order_idx
    );
  END LOOP;

  RETURN v_new_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute
GRANT EXECUTE ON FUNCTION deep_clone_assignment(UUID, UUID) TO authenticated;
```

- [ ] **Step 2: Apply migration**

Apply qua Supabase MCP.
Expected: Function created.

- [ ] **Step 3: Verify bằng test SQL**

```sql
-- Test (thay bằng ID thật):
-- SELECT deep_clone_assignment('src-assignment-uuid', 'teacher-uuid');
-- Sau đó check:
-- SELECT id, title, is_published FROM assignments ORDER BY created_at DESC LIMIT 2;
-- SELECT * FROM assignment_questions WHERE assignment_id = 'returned-new-id';
```

- [ ] **Step 4: Commit**

```bash
git add db/migrations/008_deep_clone_rpc.sql
git commit -m "feat(db): add deep_clone_assignment RPC — immutable clone for cohort reuse"
```

---

## Task 2: DataSource + Repository

**Files:**
- Modify: `lib/data/datasources/assignment_datasource.dart`
- Modify: `lib/domain/repositories/assignment_repository.dart`
- Modify: `lib/data/repositories/assignment_repository_impl.dart`

- [ ] **Step 1: Thêm deepCloneAssignment vào DataSource**

```dart
/// Deep Clone: tạo bản sao bất biến của assignment.
/// Returns new_assignment_id.
Future<String> deepCloneAssignment(
  String srcAssignmentId,
  String clonedBy,
) async {
  final result = await _client.rpc(
    'deep_clone_assignment',
    params: {
      'p_src_assignment_id': srcAssignmentId,
      'p_cloned_by': clonedBy,
    },
  );
  return result as String;
}
```

- [ ] **Step 2: Thêm vào Repository interface**

```dart
Future<String> deepCloneAssignment(String srcAssignmentId, String clonedBy);
```

- [ ] **Step 3: Thêm vào Repository impl**

```dart
@override
Future<String> deepCloneAssignment(
  String srcAssignmentId,
  String clonedBy,
) async {
  try {
    return await _ds.deepCloneAssignment(srcAssignmentId, clonedBy);
  } catch (e) {
    throw Exception(ErrorTranslationUtils.translateError(e,
        fallback: 'Không thể nhân bản bài tập'));
  }
}
```

- [ ] **Step 4: Analyze**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/data/datasources/assignment_datasource.dart \
        lib/domain/repositories/assignment_repository.dart \
        lib/data/repositories/assignment_repository_impl.dart
git commit -m "feat(clone): add deepCloneAssignment to datasource and repository"
```

---

## Task 3: UI — 3-dot Card Menu

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card.dart`

- [ ] **Step 1: Thêm 2 action vào PopupMenuButton trong card**

Tìm `PopupMenuButton` hoặc `IconButton` 3-dot trong card. Thêm 2 items:

```dart
PopupMenuButton<String>(
  onSelected: (value) {
    switch (value) {
      case 'distribute':
        widget.onDistribute?.call(widget.assignment);
        break;
      case 'clone':
        widget.onClone?.call(widget.assignment);
        break;
      // ... các actions hiện có
    }
  },
  itemBuilder: (ctx) => [
    // ... items hiện có ...
    const PopupMenuDivider(),
    const PopupMenuItem(
      value: 'distribute',
      child: ListTile(
        leading: Icon(Icons.send_outlined),
        title: Text('Giao bài cho lớp khác'),
        dense: true,
      ),
    ),
    const PopupMenuItem(
      value: 'clone',
      child: ListTile(
        leading: Icon(Icons.copy_all_outlined),
        title: Text('Nhân bản & Chỉnh sửa'),
        dense: true,
      ),
    ),
  ],
)
```

- [ ] **Step 2: Thêm callbacks vào card widget**

Tìm class AssignmentCard, thêm optional callbacks:
```dart
class AssignmentCard extends StatelessWidget {
  // ... existing fields ...
  final void Function(Assignment assignment)? onDistribute;
  final void Function(Assignment assignment)? onClone;

  const AssignmentCard({
    // ... existing params ...
    this.onDistribute,
    this.onClone,
  });
```

- [ ] **Step 3: Commit (chỉ UI card, chưa wire handler)**

```bash
git add lib/presentation/views/assignment/teacher/widgets/assignment_list/assignment_card.dart
git commit -m "feat(reuse): add Giao lớp khác + Nhân bản actions to assignment card menu"
```

---

## Task 4: Wire Action Handlers trong Management Screen

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_assignment_management_screen.dart`

- [ ] **Step 1: Xử lý onDistribute — navigate sang distribute screen với assignmentId**

```dart
void _onDistribute(Assignment assignment) {
  context.pushNamed(
    AppRoute.teacherDistributeAssignment,
    queryParameters: {'assignmentId': assignment.id},
  );
}
```

- [ ] **Step 2: Xử lý onClone — gọi deepCloneAssignment + navigate editor**

```dart
Future<void> _onClone(Assignment assignment) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nhân bản bài tập'),
      content: Text(
        'Tạo bản sao của "${assignment.title}"?\n'
        'Bạn có thể chỉnh sửa bản sao mà không ảnh hưởng đến bài gốc.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Nhân bản'),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  try {
    final repo = ref.read(assignmentRepositoryProvider);
    final auth = ref.read(authNotifierProvider);
    final teacherId = auth.value?.id;
    if (teacherId == null) return;

    final newId = await repo.deepCloneAssignment(assignment.id, teacherId);

    if (!mounted) return;
    // Redirect vào editor với bài mới clone
    context.pushNamed(
      AppRoute.teacherCreateAssignment,
      queryParameters: {'assignmentId': newId},
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Lỗi khi nhân bản: $e'),
      backgroundColor: DesignColors.error,
    ));
  }
}
```

- [ ] **Step 3: Pass callbacks vào AssignmentCard**

```dart
AssignmentCard(
  assignment: assignment,
  onDistribute: _onDistribute,
  onClone: _onClone,
  // ... các callbacks hiện có
)
```

- [ ] **Step 4: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/teacher/
```
Expected: no errors.

- [ ] **Step 5: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_assignment_management_screen.dart
git commit -m "feat(reuse): wire Giao lớp khác and Nhân bản handlers in management screen"
```

---

## Task 5: Nút to trong Assignment Detail Screen

**Files:**
- Modify: `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart`

- [ ] **Step 1: Thêm 2 nút vào AppBar actions (hoặc bottom area) của detail screen**

Chỉ hiển thị khi assignment đã published (`is_published == true`):

```dart
// Trong AppBar actions hoặc FAB area, khi is_published == true:
if (_assignment?.isPublished == true) ...[
  OutlinedButton.icon(
    icon: const Icon(Icons.send_outlined),
    label: const Text('Giao lớp khác'),
    onPressed: () => context.pushNamed(
      AppRoute.teacherDistributeAssignment,
      queryParameters: {'assignmentId': _assignment!.id},
    ),
  ),
  const SizedBox(width: 8),
  ElevatedButton.icon(
    icon: const Icon(Icons.copy_all_outlined),
    label: const Text('Nhân bản & Sửa'),
    onPressed: () => _onCloneFromDetail(),
  ),
],
```

- [ ] **Step 2: Viết _onCloneFromDetail (tương tự Task 4 Step 2)**

```dart
Future<void> _onCloneFromDetail() async {
  if (widget.assignmentId == null) return;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nhân bản bài tập'),
      content: const Text(
        'Tạo bản sao để chỉnh sửa cho khoá sau?\n'
        'Bài gốc và dữ liệu học sinh cũ sẽ không bị ảnh hưởng.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Nhân bản'),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  try {
    final repo = ref.read(assignmentRepositoryProvider);
    final auth = ref.read(authNotifierProvider);
    final teacherId = auth.value?.id;
    if (teacherId == null) return;

    final newId = await repo.deepCloneAssignment(widget.assignmentId!, teacherId);

    if (!mounted) return;
    // Replace current screen với editor của bản clone mới
    context.pushReplacementNamed(
      AppRoute.teacherCreateAssignment,
      queryParameters: {'assignmentId': newId},
    );
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Lỗi khi nhân bản: $e'),
      backgroundColor: DesignColors.error,
    ));
  }
}
```

- [ ] **Step 3: Analyze**

```bash
flutter analyze lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
```
Expected: no errors.

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart
git commit -m "feat(reuse): add Giao lớp khác + Nhân bản buttons in assignment detail screen"
```

---

## Self-Review

**Spec coverage:**
- [x] "Giao bài cho lớp khác" → chỉ tạo distribution mới, giữ assignment_id cũ (Task 3-4)
- [x] "Nhân bản & Chỉnh sửa" → deep clone RPC → redirect editor (Task 1-5)
- [x] Clone giữ question_id, custom_content=NULL (Task 1 SQL)
- [x] Permission check: chỉ owner mới clone được (Task 1 SQL)
- [x] 2 nút trong card menu (shortcut) + detail screen (Task 3, 5)
- [x] Confirm dialog trước khi clone (Task 4 Step 2, Task 5 Step 2)
- [x] Bài gốc không bị ảnh hưởng (RPC design)

**Gaps:** Không có.
