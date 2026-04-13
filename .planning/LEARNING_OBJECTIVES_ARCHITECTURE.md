# Kiến trúc learning_objectives (đã duyệt)

**Ngày duyệt:** 2026-04-13  
**Trạng thái:** Approved, chưa implement

---

## Vấn đề gốc

- `learning_objectives` hiện là Global Table — không có visibility scoping, không tracking provenance
- AI Generate tạo LO mà không có `created_by` → sau khi thêm RLS, dữ liệu cũ sẽ bị ẩn
- `ObjectiveSelectorSheet` chỉ read-only — giáo viên không tạo được LO mới khi tạo câu hỏi tay
- Trigger `trg_sa_01_skill_mastery` bỏ qua custom questions (`question_id IS NULL`) — blind spot lớn

---

## Mô hình tư duy: "Thư viện Quốc gia & Tủ sách Cá nhân"

```
is_global = true  → Thư viện Quốc gia (mọi người đều thấy)
  ├── source = 'system'  → CT GDPT 2018, seeded bởi LMS team
  └── source = 'admin'   → Admin trường định nghĩa thêm

is_global = false → Tủ sách Cá nhân (chỉ mình thấy)
  ├── source = 'teacher'       → GV tự tạo cho lớp độc lập (Flutter, IELTS...)
  └── source = 'ai_generated'  → AI tự tạo khi generate câu hỏi cho GV đó
```

---

## DDL đã duyệt

```sql
ALTER TABLE public.learning_objectives
  ADD COLUMN is_global   boolean  NOT NULL DEFAULT true,
  ADD COLUMN created_by  uuid     REFERENCES auth.users(id),
  ADD COLUMN source      text     NOT NULL DEFAULT 'system'
    CHECK (source IN ('system', 'admin', 'ai_generated', 'teacher'));

-- Backfill: dữ liệu cũ (AI-generated, không có created_by) → giữ is_global=true (backward compat)
UPDATE public.learning_objectives
SET source = 'ai_generated'
WHERE created_by IS NULL;
```

---

## 4 hồ sơ dữ liệu

| is_global | source | created_by | Ý nghĩa |
|-----------|--------|------------|---------|
| true | 'system' | null | CT GDPT 2018 — LMS team seed |
| true | 'admin' | uuid | Admin trường tạo thêm |
| false | 'teacher' | uuid | GV tự tạo, private |
| false | 'ai_generated' | uuid | AI tạo cho GV đó, private |

---

## RLS Policies

```sql
-- SELECT: Thư viện Quốc gia (is_global=true) + Tủ sách cá nhân (created_by=me)
CREATE POLICY "lo_select" ON learning_objectives
  FOR SELECT USING (
    is_global = true OR created_by = (SELECT auth.uid())
  );

-- INSERT: GV chỉ tạo private; Admin mới tạo global
CREATE POLICY "lo_insert" ON learning_objectives
  FOR INSERT WITH CHECK (
    (is_global = false AND created_by = (SELECT auth.uid()))
    OR
    (is_global = true AND EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = (SELECT auth.uid())
        AND raw_user_meta_data->>'role' = 'admin'
    ))
  );

-- UPDATE/DELETE: chỉ sửa của mình hoặc admin
CREATE POLICY "lo_update_delete" ON learning_objectives
  FOR ALL USING (
    created_by = (SELECT auth.uid())
    OR EXISTS (
      SELECT 1 FROM auth.users
      WHERE id = (SELECT auth.uid())
        AND raw_user_meta_data->>'role' = 'admin'
    )
  );
```

---

## Fix bắt buộc kèm theo

### 1. AI Generate phải pass created_by

File: `lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart`  
Hàm: `_mapAiQuestionToCreateQuestionParams()`

```dart
final userId = Supabase.instance.client.auth.currentUser?.id;
final created = await loRepo.createObjective({
  'subject_code': subjectCode,
  'code': code,
  'description': desc,
  'is_global': false,
  'source': 'ai_generated',
  'created_by': userId,  // BẮT BUỘC — thiếu thì RLS nuốt mất sau migration
});
```

### 2. Custom questions support objectives (trigger update)

Lưu `objective_ids` vào `custom_content` JSONB của `assignment_questions`:
```json
{ "type": "multiple_choice", "text": "...", "objective_ids": ["uuid1", "uuid2"] }
```

Cập nhật trigger `fn_update_skill_mastery` — đọc từ 2 nguồn:

```sql
WITH objectives AS (
  -- Path 1: linked question (question_id NOT NULL) → question_objectives
  SELECT qo.objective_id
  FROM assignment_questions aq
  JOIN question_objectives qo ON qo.question_id = aq.question_id
  WHERE aq.id = NEW.assignment_question_id

  UNION

  -- Path 2: custom question (question_id NULL) → custom_content.objective_ids JSONB
  SELECT obj_id::uuid
  FROM assignment_questions aq,
       jsonb_array_elements_text(
         COALESCE(aq.custom_content->'objective_ids', '[]'::jsonb)
       ) AS obj_id
  WHERE aq.id = NEW.assignment_question_id
    AND aq.question_id IS NULL
)
-- INSERT INTO student_skill_mastery ... FROM objectives o ...
```

### 3. ObjectiveSelectorSheet — thêm allowCreate + phân nhóm

```dart
ObjectiveSelectorSheet.show(context,
  selectedIds: ...,
  allowCreate: true,  // giáo viên được tạo private objectives
)
```

Grouping trong sheet:
- 📚 **Chuẩn chương trình** — `is_global=true, source IN ('system','admin')`
- 🤖 **AI gợi ý** — `source='ai_generated'`
- ✍️ **Của tôi** — `is_global=false, created_by=me, source='teacher'`
- `[+ Tạo mục tiêu mới]` → insert với `is_global=false, source='teacher', created_by=uid`

### 4. Admin scaffolding (plumbing, không build UI)

Thêm vào `LearningObjectiveDataSource` + `LearningObjectiveRepository`:
- `updateObjective(id, payload)`
- `deleteObjective(id)`
- Route placeholder: `admin-learning-objectives` trong `route_constants.dart`

---

## Scope KHÔNG làm ngay

- Full admin management screen (UI) → future
- `school_id` trên `learning_objectives` → future B2B khi có school accounts
- "Promote to global" flow cho teacher objectives → future

---

## Lý do loại approach is_official

`is_official` chỉ là label, không enforce visibility qua RLS.  
`is_global=true + source IN ('system','admin')` đã cover hoàn toàn.

- `is_global` (insight B2B/B2C) → giải quyết visibility/scoping thực sự  
- `source` (insight provenance) → giải quyết UX filtering và analytics  
- Kết hợp = đủ mạnh, không over-engineer
