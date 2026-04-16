# Phase 08-A: Data Contract Fix — Choice IDs & DB Function Rewrite

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Chuẩn hóa toàn bộ Data Contract: choice IDs phải là INT (0,1,2...) trong mọi custom_content, và viết lại DB function create_student_variant chỉ lưu ORDER pointer (không snapshot content).

**Architecture:** 
- SQL migration PostgreSQL: dùng `jsonb_array_elements` + `row_number()` để đổi UUID choice IDs → INT 0-based trong `assignment_questions.custom_content`.
- Viết lại hàm `create_student_variant` / `ensure_student_variant` trong migration mới chỉ trả về `[{assignment_question_id, display_order, shuffled_choices:[INT]}]`.
- Fix Dart code: `assignment_datasource.dart` + `teacher_create_question_screen.dart` dùng INT index khi build choices.

**Tech Stack:** PostgreSQL (Supabase), Dart/Flutter, Riverpod

---

## File Map

| File | Action | Trách nhiệm |
|------|--------|-------------|
| `db/migrations/008_fix_legacy_choice_ids.sql` | CREATE | Migration đổi UUID → INT trong custom_content.choices |
| `db/migrations/008_rewrite_shuffle_functions.sql` | CREATE | Viết lại create_student_variant + ensure_student_variant format mới |
| `lib/data/datasources/assignment_datasource.dart` | MODIFY | Fix build custom_content choices dùng INT index |
| `lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart` | MODIFY | Fix choice ID generation → INT |

---

## Task 1: Migration — Fix Legacy Choice IDs (UUID → INT)

**Files:**
- Create: `db/migrations/008_fix_legacy_choice_ids.sql`

- [ ] **Step 1: Viết SQL migration**

```sql
-- =============================================================
-- Migration 008: Fix legacy choice IDs (UUID string → INT 0-based)
-- Áp dụng cho: assignment_questions.custom_content.choices[]
-- =============================================================

CREATE OR REPLACE FUNCTION fix_legacy_choice_ids_in_assignment_questions()
RETURNS void AS $$
DECLARE
  rec RECORD;
  old_choices JSONB;
  new_choices JSONB;
  new_choice JSONB;
  choice_elem JSONB;
  idx INTEGER;
BEGIN
  FOR rec IN
    SELECT id, custom_content
    FROM assignment_questions
    WHERE custom_content IS NOT NULL
      AND custom_content ? 'choices'
      AND jsonb_typeof(custom_content->'choices') = 'array'
  LOOP
    old_choices := rec.custom_content->'choices';
    new_choices := '[]'::JSONB;
    idx := 0;

    FOR choice_elem IN SELECT * FROM jsonb_array_elements(old_choices)
    LOOP
      -- Chỉ cần fix nếu ID là string (UUID), nếu đã là integer thì skip
      IF jsonb_typeof(choice_elem->'id') = 'string' THEN
        new_choice := jsonb_set(choice_elem, '{id}', to_jsonb(idx));
      ELSE
        new_choice := choice_elem;
      END IF;

      new_choices := new_choices || jsonb_build_array(new_choice);
      idx := idx + 1;
    END LOOP;

    UPDATE assignment_questions
    SET custom_content = jsonb_set(custom_content, '{choices}', new_choices)
    WHERE id = rec.id;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Chạy migration
SELECT fix_legacy_choice_ids_in_assignment_questions();

-- Cleanup function sau khi dùng
DROP FUNCTION fix_legacy_choice_ids_in_assignment_questions();

-- Verify: xem 5 record đầu sau khi fix
-- SELECT id, custom_content->'choices' as choices FROM assignment_questions
-- WHERE custom_content ? 'choices' LIMIT 5;
```

- [ ] **Step 2: Apply migration lên Supabase**

Dùng Supabase MCP `apply_migration` hoặc chạy trong Supabase SQL editor.
Expected: "SELECT 1" (function ran and dropped cleanly)

- [ ] **Step 3: Verify kết quả**

Chạy SQL verify:
```sql
-- Phải trả về 0 rows (không còn UUID string nào)
SELECT id 
FROM assignment_questions
WHERE custom_content IS NOT NULL
  AND custom_content ? 'choices'
  AND EXISTS (
    SELECT 1 FROM jsonb_array_elements(custom_content->'choices') elem
    WHERE jsonb_typeof(elem->'id') = 'string'
  );
```
Expected: 0 rows

- [ ] **Step 4: Commit**

```bash
git add db/migrations/008_fix_legacy_choice_ids.sql
git commit -m "fix(db): migrate custom_content choice IDs from UUID string to INT 0-based"
```

---

## Task 2: Migration — Viết lại DB Shuffle Functions (Format Mới)

**Files:**
- Create: `db/migrations/008_rewrite_shuffle_functions.sql`

- [ ] **Step 1: Viết lại các hàm shuffle**

```sql
-- =============================================================
-- Migration 008: Rewrite shuffle functions
-- Format mới của custom_questions (assignment_variants):
-- [{
--   "assignment_question_id": "uuid",
--   "display_order": 1,
--   "shuffled_choices": [2, 0, 3, 1]   -- mảng INT IDs đã đảo
-- }]
-- KHÔNG snapshot content! Frontend JOIN với assignment_questions.
-- =============================================================

-- Giữ nguyên hàm helper shuffle_with_seed (đã đúng, không đổi)
-- CREATE OR REPLACE FUNCTION shuffle_with_seed(...) -- đã tồn tại

-- =============================================================
-- Viết lại create_student_variant
-- =============================================================
CREATE OR REPLACE FUNCTION create_student_variant(
  p_assignment_id UUID,
  p_student_id    UUID,
  p_shuffle_questions BOOLEAN DEFAULT true,
  p_shuffle_choices   BOOLEAN DEFAULT true
)
RETURNS UUID AS $$
DECLARE
  v_variant_id UUID;
  v_aq_rows    JSONB;   -- mảng {id, order_idx, choices_ids[]}
  v_q_ids      JSONB;   -- mảng UUID string để shuffle thứ tự câu
  v_shuffled_q_ids JSONB;
  v_seed       BIGINT;
  v_result     JSONB := '[]'::JSONB;
  v_elem       JSONB;
  v_aq_id      TEXT;
  v_display_order INT := 1;
  v_choices_raw JSONB;
  v_choice_ids  JSONB;
  v_c           JSONB;
BEGIN
  -- Seed từ student_id + assignment_id (deterministic)
  v_seed := (
    (('x' || substr(md5(p_student_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000) * 1000000000 +
    ('x' || substr(md5(p_assignment_id::TEXT), 1, 15))::bit(64)::bigint % 1000000000
  );

  -- Lấy tất cả assignment_questions (chỉ lấy id và order_idx, không lấy content)
  SELECT jsonb_agg(
    jsonb_build_object('aq_id', aq.id::TEXT, 'order_idx', aq.order_idx)
    ORDER BY aq.order_idx
  ) INTO v_aq_rows
  FROM assignment_questions aq
  WHERE aq.assignment_id = p_assignment_id;

  IF v_aq_rows IS NULL OR jsonb_array_length(v_aq_rows) = 0 THEN
    RAISE EXCEPTION 'No questions found for assignment %', p_assignment_id;
  END IF;

  -- Tách ra mảng aq_ids để shuffle thứ tự câu
  SELECT jsonb_agg(elem->>'aq_id')
  INTO v_q_ids
  FROM jsonb_array_elements(v_aq_rows) elem;

  -- Shuffle thứ tự câu nếu cần
  IF p_shuffle_questions THEN
    v_shuffled_q_ids := shuffle_with_seed(v_q_ids, v_seed);
  ELSE
    v_shuffled_q_ids := v_q_ids;
  END IF;

  -- Build result array: mỗi phần tử là pointer + shuffled_choices
  FOR v_display_order IN 1..jsonb_array_length(v_shuffled_q_ids)
  LOOP
    v_aq_id := v_shuffled_q_ids->>(v_display_order - 1);

    -- Lấy choice IDs (INT) từ custom_content.choices của assignment_question này
    -- Hỗ trợ cả câu từ bank (question_choices) và câu custom (custom_content.choices)
    SELECT
      CASE
        -- Câu custom: lấy từ custom_content.choices[].id (đã là INT sau migration)
        WHEN aq.question_id IS NULL AND aq.custom_content ? 'choices' THEN
          (SELECT jsonb_agg((c->>'id')::INT)
           FROM jsonb_array_elements(aq.custom_content->'choices') c)
        -- Câu từ bank: lấy từ question_choices.id (INT)
        WHEN aq.question_id IS NOT NULL THEN
          (SELECT jsonb_agg(qc.id ORDER BY qc.id)
           FROM question_choices qc
           WHERE qc.question_id = aq.question_id)
        ELSE '[]'::JSONB
      END
    INTO v_choices_raw
    FROM assignment_questions aq
    WHERE aq.id = v_aq_id::UUID;

    v_choice_ids := COALESCE(v_choices_raw, '[]'::JSONB);

    -- Shuffle choices nếu cần
    IF p_shuffle_choices AND jsonb_array_length(v_choice_ids) > 1 THEN
      v_choice_ids := shuffle_with_seed(v_choice_ids, v_seed + v_display_order * 997);
    END IF;

    -- Append pointer vào result
    v_result := v_result || jsonb_build_array(
      jsonb_build_object(
        'assignment_question_id', v_aq_id,
        'display_order',          v_display_order,
        'shuffled_choices',       v_choice_ids
      )
    );
  END LOOP;

  -- Upsert: nếu đã có variant cũ thì replace
  DELETE FROM assignment_variants
  WHERE assignment_id = p_assignment_id
    AND variant_type = 'student'
    AND student_id = p_student_id;

  INSERT INTO assignment_variants (
    assignment_id, variant_type, student_id, custom_questions, created_at
  ) VALUES (
    p_assignment_id, 'student', p_student_id, v_result, NOW()
  )
  RETURNING id INTO v_variant_id;

  RETURN v_variant_id;
END;
$$ LANGUAGE plpgsql;


-- =============================================================
-- Viết lại ensure_student_variant (logic giữ nguyên, gọi hàm mới)
-- =============================================================
CREATE OR REPLACE FUNCTION ensure_student_variant(
  p_assignment_id UUID,
  p_student_id    UUID
)
RETURNS UUID AS $$
DECLARE
  v_variant_id UUID;
  v_settings   JSONB;
  v_shuffle_q  BOOLEAN := false;
  v_shuffle_c  BOOLEAN := false;
BEGIN
  -- Kiểm tra đã có variant chưa
  SELECT id INTO v_variant_id
  FROM assignment_variants
  WHERE assignment_id = p_assignment_id
    AND variant_type = 'student'
    AND student_id = p_student_id
  LIMIT 1;

  IF v_variant_id IS NOT NULL THEN
    RETURN v_variant_id;
  END IF;

  -- Lấy settings từ distribution (ưu tiên individual > group > class)
  SELECT ad.settings INTO v_settings
  FROM assignment_distributions ad
  WHERE ad.assignment_id = p_assignment_id
    AND (
      (ad.distribution_type = 'individual' AND p_student_id = ANY(ad.student_ids))
      OR (ad.distribution_type = 'group' AND EXISTS (
          SELECT 1 FROM group_members gm
          WHERE gm.group_id = ad.group_id AND gm.student_id = p_student_id
      ))
      OR (ad.distribution_type = 'class' AND EXISTS (
          SELECT 1 FROM class_members cm
          WHERE cm.class_id = ad.class_id AND cm.student_id = p_student_id
            AND cm.status = 'approved'
      ))
    )
  ORDER BY CASE ad.distribution_type
    WHEN 'individual' THEN 1 WHEN 'group' THEN 2 WHEN 'class' THEN 3
  END
  LIMIT 1;

  IF v_settings IS NOT NULL THEN
    v_shuffle_q := COALESCE((v_settings->>'shuffle_questions')::BOOLEAN, false);
    v_shuffle_c := COALESCE((v_settings->>'shuffle_choices')::BOOLEAN, false);
  END IF;

  -- Luôn tạo variant kể cả khi shuffle=false (Consistency: Dumb TV pattern)
  v_variant_id := create_student_variant(
    p_assignment_id, p_student_id, v_shuffle_q, v_shuffle_c
  );

  RETURN v_variant_id;
END;
$$ LANGUAGE plpgsql;
```

- [ ] **Step 2: Apply migration**

Apply qua Supabase MCP hoặc SQL editor.
Expected: Functions replaced cleanly.

- [ ] **Step 3: Verify bằng test SQL**

```sql
-- Test: Tạo variant cho 1 student mẫu (thay bằng ID thật từ DB)
-- SELECT ensure_student_variant('your-assignment-uuid', 'your-student-uuid');

-- Verify format output:
-- SELECT custom_questions FROM assignment_variants
-- WHERE assignment_id = 'your-assignment-uuid' LIMIT 1;
-- Expected: [{"assignment_question_id":"...","display_order":1,"shuffled_choices":[2,0,3,1]}]
```

- [ ] **Step 4: Commit**

```bash
git add db/migrations/008_rewrite_shuffle_functions.sql
git commit -m "feat(db): rewrite create_student_variant — pointer-only format, no content snapshot"
```

---

## Task 3: Fix Dart — Choice ID Generation dùng INT

**Files:**
- Modify: `lib/data/datasources/assignment_datasource.dart` (line ~638-646)
- Modify: `lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart`

- [ ] **Step 1: Tìm và fix trong assignment_datasource.dart**

Tìm đoạn (khoảng line 638):
```dart
questionChoices = choices.map((c) {
  final choice = c as Map<String, dynamic>;
  return {
    'id': choice['id'] ?? '',        // ← BUG: UUID string
    'content': {'text': choice['text'] ?? ''},
    'is_correct': choice['isCorrect'] ?? choice['is_correct'] ?? false,
  };
}).toList();
```

Sửa thành (dùng index làm ID):
```dart
questionChoices = choices.asMap().entries.map((entry) {
  final idx = entry.key;
  final choice = entry.value as Map<String, dynamic>;
  return {
    'id': choice['id'] is int ? choice['id'] : idx,  // giữ INT nếu đã đúng, fallback index
    'content': {'text': choice['text'] ?? ''},
    'is_correct': choice['isCorrect'] ?? choice['is_correct'] ?? false,
  };
}).toList();
```

- [ ] **Step 2: Tìm và fix trong teacher_create_question_screen.dart**

Grep tìm chỗ gen choice ID:
```bash
grep -n "choice\['id'\]\|choiceId\|uuid.*choice\|id.*uuid" \
  lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart
```

Tìm pattern tương tự (có thể dùng `Uuid().v4()` cho choice) → sửa thành index INT:
```dart
// TRƯỚC (sai):
choices: [
  {'id': const Uuid().v4(), 'text': 'Đáp án A', 'isCorrect': false},
  ...
]

// SAU (đúng):
choices: [
  {'id': 0, 'text': 'Đáp án A', 'isCorrect': false},
  {'id': 1, 'text': 'Đáp án B', 'isCorrect': false},
  {'id': 2, 'text': 'Đáp án C', 'isCorrect': false},
  {'id': 3, 'text': 'Đáp án D', 'isCorrect': false},
]

// Khi thêm choice mới:
final newId = choices.length;  // tiếp nối index
choices.add({'id': newId, 'text': '', 'isCorrect': false});
```

- [ ] **Step 3: Analyze**

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```
Expected: no errors liên quan đến type.

- [ ] **Step 4: Commit**

```bash
git add lib/data/datasources/assignment_datasource.dart \
        lib/presentation/views/assignment/teacher/teacher_create_question_screen.dart
git commit -m "fix(dart): choice IDs use INT index instead of UUID string — enforce data contract"
```

---

## Self-Review

**Spec coverage:**
- [x] Migration đổi UUID → INT trong DB (Task 1)
- [x] Verify 0 legacy records còn sót (Task 1 Step 3)
- [x] Viết lại create_student_variant format pointer-only (Task 2)
- [x] ensure_student_variant luôn tạo variant kể cả shuffle=false (Task 2 Step 1)
- [x] Fix Dart choice ID generation (Task 3)

**Gaps:** Không có.

**Type consistency:** `shuffled_choices` luôn là `[INT]` xuyên suốt SQL → Dart.
