# Test Plan — Dashboard Stats Dedup (Bug "3/1")

## Bối cảnh
Trước fix: card "X/Y đã nộp" đếm raw `work_sessions` → 1 HS làm lại 3 lần hiển thị "3/1".
Sau fix: dùng RPC `get_teacher_distribution_dashboard_stats` dedupe theo `(student_id, distribution_id)`.

Ngữ nghĩa mới (multi-lens):
- `submission_count` = participation: HS đã nộp ít nhất 1 lần (dedupe).
- `total_students` = mẫu số theo `distribution_type` (class/group/individual).
- `graded_count` = HS có **latest** attempt = `graded`.
- `pending_action_count` = HS có **latest** attempt = `submitted` chưa `graded` → "việc cần GV xử lý".
- `late_count` = HS có **latest non-in_progress** attempt nộp muộn so với `due_at`.

---

## Phần 1 — SQL Verification (Supabase MCP)

Chạy trên Supabase Studio hoặc qua MCP (`mcp__supabase__execute_sql`). Mỗi block là một test độc lập.

### Test 1.1 — RPC chạy không lỗi
```sql
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub":"<TEACHER_UUID>","role":"authenticated"}';
SELECT * FROM public.get_teacher_distribution_dashboard_stats() LIMIT 5;
```
**Pass:** trả ≥ 1 row, không lỗi `42702`/permission.

### Test 1.2 — Permission check
```sql
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub":"00000000-0000-0000-0000-000000000099","role":"authenticated"}';
SELECT * FROM public.get_teacher_distribution_dashboard_stats('<class_id_không_thuộc_user>') LIMIT 1;
```
**Pass:** trả 0 row (RLS qua `assignments.teacher_id = v_teacher_id`), không leak data.

### Test 1.3 — Dedup retake (the "3/1" smoking gun)
Tìm 1 distribution có HS đã làm ≥ 2 lần:
```sql
SELECT
  ws.assignment_distribution_id AS dist_id,
  ws.student_id,
  COUNT(*) AS attempts
FROM public.work_sessions ws
WHERE ws.status <> 'in_progress'
GROUP BY ws.assignment_distribution_id, ws.student_id
HAVING COUNT(*) >= 2
LIMIT 5;
```
Lấy 1 `dist_id` từ kết quả, sau đó:
```sql
SET LOCAL ROLE authenticated;
SET LOCAL "request.jwt.claims" = '{"sub":"<TEACHER_UUID>","role":"authenticated"}';
-- Lấy stats từ RPC
SELECT participation_count, graded_count, total_expected, pending_action_count
FROM public.get_teacher_distribution_dashboard_stats()
WHERE distribution_id = '<dist_id>';

-- So sánh: số HS UNIQUE đã nộp (dedupe đúng)
SELECT COUNT(DISTINCT student_id) AS unique_submitters
FROM public.work_sessions
WHERE assignment_distribution_id = '<dist_id>'
  AND status <> 'in_progress';
```
**Pass:** `participation_count` từ RPC = `unique_submitters` query thủ công (không phải `COUNT(*)` raw).

### Test 1.4 — Total expected khớp distribution_type
```sql
WITH t AS (
  SELECT id, distribution_type, class_id, group_id, student_ids
  FROM public.assignment_distributions LIMIT 5
)
SELECT
  t.id AS dist_id, t.distribution_type,
  CASE t.distribution_type
    WHEN 'class' THEN (SELECT COUNT(*) FROM public.class_members WHERE class_id=t.class_id AND status='approved')
    WHEN 'group' THEN (SELECT COUNT(*) FROM public.group_members WHERE group_id=t.group_id)
    ELSE COALESCE(array_length(t.student_ids,1),0)
  END AS expected_manual,
  s.total_expected AS expected_rpc
FROM t
LEFT JOIN public.get_teacher_distribution_dashboard_stats() s ON s.distribution_id = t.id;
```
**Pass:** `expected_manual` = `expected_rpc` mỗi row.

### Test 1.5 — Pending action chỉ đếm latest=submitted
```sql
-- HS có latest attempt = submitted (chưa graded)
WITH latest AS (
  SELECT DISTINCT ON (student_id, assignment_distribution_id)
    student_id, assignment_distribution_id AS dist_id, status, submitted_at
  FROM public.work_sessions
  ORDER BY student_id, assignment_distribution_id, attempt DESC, created_at DESC
)
SELECT
  dist_id,
  COUNT(*) FILTER (WHERE submitted_at IS NOT NULL AND status<>'graded') AS pending_manual
FROM latest GROUP BY dist_id LIMIT 10;
```
So sánh với `pending_action_count` từ RPC tương ứng.
**Pass:** khớp 100%.

### Test 1.6 — Edge case: HS attempt 1 graded, attempt 2 in_progress
Tạo data:
```sql
-- (chỉ chạy trên test DB) — verify "trong-flight" không đếm vào pending
INSERT INTO public.work_sessions (student_id, assignment_distribution_id, status, attempt, created_at)
VALUES ('<sid>', '<did>', 'graded', 1, now() - interval '2 days'),
       ('<sid>', '<did>', 'in_progress', 2, now());

-- Mong đợi:
-- participation_count += 1 (any_completed có attempt 1)
-- pending_action_count += 0 (latest=in_progress, không vào queue)
-- graded_count += 0 (latest != graded)
```

---

## Phần 2 — Flutter Manual UAT

### Setup
1. App có sẵn 1 lớp với ≥ 1 bài tập đã giao.
2. Login bằng tài khoản học sinh, làm bài đó **lần 1**, nộp.
3. (Nếu rule = `latest`) Mở redo → làm **lần 2**, nộp.
4. (Tuỳ chọn) Làm tiếp **lần 3** chưa nộp (status=in_progress).
5. Login bằng tài khoản giáo viên.

### Scenario 2.1 — Card lớp chi tiết
**Path:** Lớp → "Bài tập của lớp" → card bài đó.
**Expected:**
- "X/Y đã nộp" — X = số HS unique đã nộp, KHÔNG bao giờ vượt Y.
- Nếu HS chưa làm → X=0, badge ẩn.
- Nếu HS đã nộp lần 2 + chưa chấm → badge đỏ "1 chờ chấm" hiển thị.
- Sau khi GV chấm lần 2 → badge biến mất (về 0).
- Nếu GV mở redo và HS đang làm lần 3 (in_progress) → badge vẫn = 0 (chưa nộp).

**Fail nếu:** "X/Y" lớn hơn sĩ số lớp; "đã chấm" lớn hơn "đã nộp".

### Scenario 2.2 — Hub bài tập teacher
**Path:** Bottom nav → Bài tập → tab Hub.
**Expected:**
- Số "chờ chấm" badge tổng = sum(`pending_action_count`) của mọi distribution.
- Quay lại sau khi chấm hết → badge = 0.

### Scenario 2.3 — Phân tích lớp (regression test cho fix trước)
**Path:** Phân tích Lớp học → click 1 lớp.
**Expected:**
- Avatar lớp hiển thị `classAverage` ≠ 0.
- Số học sinh ≠ 0.
- Heatmap, top/bottom performers có data.

**Fail nếu:** màn hình "Không thể tải dữ liệu" hoặc tất cả số = 0.

### Scenario 2.4 — Late count
**Setup:** 1 distribution có `due_at` đã qua, 1 HS nộp bản cuối SAU due.
**Expected:** card hiển thị late_count = 1.
**Edge:** HS muộn lần 1, đúng giờ lần 2 (rule=latest) → late_count = 0 (vì latest đúng giờ).

### Scenario 2.5 — Distribution type variants
| Type | Mẫu số | Test |
|---|---|---|
| `class` | sĩ số lớp approved | Tạo dist class → "X/30" với 30 = số HS |
| `group` | số thành viên group | Tạo dist group 5 HS → "X/5" |
| `individual`/`student` | length(`student_ids`) | Giao 3 HS → "X/3" |

---

## Phần 3 — Quick smoke test bằng Bash

Chạy nhanh 3 lệnh sau để confirm fix toàn diện:

```bash
# 1. Static analyze
flutter analyze lib/data/datasources/assignment_datasource.dart \
  lib/widgets/list_item/assignment/class_detail_assignment_list_item.dart \
  lib/presentation/providers/teacher_dashboard_providers.dart \
  lib/domain/entities/assignment_distribution.dart

# 2. Build runner (verify entity compile)
dart run build_runner build --delete-conflicting-outputs

# 3. Migration applied
# (qua Supabase Studio) Database → Functions → search "get_teacher_distribution_dashboard_stats"
# Phải thấy function với SECURITY DEFINER + STABLE.
```

---

## Phần 4 — Regression checklist

Sau fix, các điểm sau KHÔNG được hỏng:

- [ ] HS làm bài lần đầu → status thay đổi đúng (in_progress → submitted → graded).
- [ ] HS làm lại sau khi đã graded → tạo work_session mới với `attempt > 1`.
- [ ] GV chấm điểm → cập nhật được latest attempt.
- [ ] `score_aggregation_rule` (latest/first/max/average) ở Sổ Điểm vẫn đúng (test bằng `get_class_final_scores`).
- [ ] Phân tích Lớp học load được data (fix migration `fix_class_final_scores_ambiguous_student_id`).

---

## Tóm tắt: 3 dấu hiệu fix đã thành công

1. **Number sanity:** `submission_count ≤ total_students` luôn đúng (không bao giờ thấy "3/1").
2. **Action queue:** Badge "N chờ chấm" tăng/giảm khớp với hành động của GV — chấm xong, badge tụt.
3. **Retake invariance:** HS làm lại N lần, các con số card KHÔNG đổi (chỉ pending_action_count chuyển trạng thái).
