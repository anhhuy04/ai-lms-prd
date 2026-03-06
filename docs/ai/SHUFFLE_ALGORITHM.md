# Shuffle Algorithm - Random Đề Thi

## Tổng quan

Thuật toán random đề đảm bảo:
1. **Không học sinh nào trùng đề** - Mỗi học sinh có seed khác nhau
2. **Không câu hỏi trùng vị trí** - Fisher-Yates shuffle với seed riêng
3. **Đáp án cũng không trùng** - Mỗi câu hỏi shuffle với seed = base + order_idx * 997
4. **Deterministic** - Cùng student + assignment = cùng đề (có thể replay)

## Database Changes

### File: `db/09_add_distribution_settings.sql`
Thêm các cột vào bảng:

```sql
-- Thêm cột settings vào assignment_distributions
ALTER TABLE public.assignment_distributions
ADD COLUMN IF NOT EXISTS settings jsonb DEFAULT '{"shuffle_questions": false, "shuffle_choices": false, "show_score_immediately": true}';

-- Indexes cho performance
CREATE INDEX idx_assignment_variants_student ON assignment_variants(student_id) WHERE variant_type = 'student';
CREATE INDEX idx_assignment_variants_group ON assignment_variants(group_id) WHERE variant_type = 'group';

-- Thêm columns shuffle vào assignments
ALTER TABLE public.assignments
ADD COLUMN IF NOT EXISTS default_shuffle_questions boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS default_shuffle_choices boolean DEFAULT false;
```

### File: `db/10_shuffle_algorithm.sql`
Tạo các functions:

| Function | Mô tả |
|----------|-------|
| `shuffle_with_seed()` | Fisher-Yates shuffle deterministic |
| `create_student_variant()` | Tạo đề unique cho 1 học sinh |
| `create_group_variant()` | Tạo đề cho cả nhóm (cùng đề) |
| `create_class_student_variants()` | Batch tạo variants cho lớp |
| `create_groups_variants()` | Batch cho nhiều nhóm |
| `create_students_variants()` | Batch cho danh sách học sinh |
| `ensure_student_variant()` | Auto tạo khi học sinh bắt đầu làm |

## Cách hoạt động

### 1. Khi giáo viên phân phối bài tập

```dart
// Frontend gửi settings kèm distribution
final settings = {
  'shuffle_questions': true,
  'shuffle_choices': true,
  'show_score_immediately': true,
};

await repository.distributeAssignment(
  assignmentId: 'xxx',
  classId: 'yyy',
  settings: settings,
);
```

### 2. Khi học sinh bắt đầu làm bài

```sql
-- Backend gọi ensure_student_variant()
SELECT ensure_student_variant('assignment-id', 'student-id');
```

### 3. Variant được lưu vào `assignment_variants.custom_questions`

```json
{
  "questions": [
    {
      "original_assignment_question_id": "aq-uuid-1",
      "original_question_id": "q-uuid-1",
      "order_idx": 3,
      "points": 1,
      "custom_content": {
        "text": "Câu hỏi 1",
        "choices": [
          {"id": "c1", "text": "Đáp án C", "is_correct": false},
          {"id": "c2", "text": "Đáp án A", "is_correct": true},
          {"id": "c3", "text": "Đáp án D", "is_correct": false},
          {"id": "c4", "text": "Đáp án B", "is_correct": false}
        ]
      }
    }
  ],
  "seed": 123456789012345,
  "shuffle_questions": true,
  "shuffle_choices": true,
  "generated_at": "2026-02-24T10:00:00Z"
}
```

## Seed Generation

Seed được tạo từ:
```sql
v_seed := (
    (hash(student_id) % 1B) * 1B +
    (hash(assignment_id) % 1B)
);
```

Đảm bảo:
- Student khác nhau → seed khác nhau → thứ tự khác
- Cùng student + assignment → cùng seed → cùng đề (deterministic)

## Frontend Integration

### Entity Updates

**AssignmentDistribution entity:**
```dart
class AssignmentDistribution {
  // ... existing fields
  Map<String, dynamic>? settings; // shuffle_questions, shuffle_choices, show_score_immediately
}
```

**AssignmentVariant entity:**
```dart
class AssignmentVariant {
  // ... existing fields
  Map<String, dynamic>? custom_questions; // shuffled questions with audit trail
}
```

### Reading Variant

```dart
final variant = await repository.getVariant(assignmentId, studentId);
if (variant.customQuestions != null) {
  final questions = variant.customQuestions!['questions'] as List;
  // Render questions in new order
}
```

## Verification Queries

```sql
-- Kiểm tra variants đã tạo
SELECT av.id, av.student_id, av.custom_questions->>'seed' as seed
FROM assignment_variants av
WHERE av.assignment_id = 'assignment-uuid'
ORDER BY av.created_at;

-- Kiểm tra settings trong distributions
SELECT id, settings FROM assignment_distributions
WHERE assignment_id = 'assignment-uuid';
```

## Last Updated

2026-02-24
