# TODO — Làm lại bài tập (Redo Assignment) + Score Aggregation

> **File này là kế hoạch chi tiết cho tính năng "Làm lại bài tập" và logic gộp điểm khi có nhiều lần làm.**
> Mọi phiên AI/người làm việc trên feature này PHẢI đọc file này trước khi code.
> Cập nhật trạng thái checkbox `[x]` ngay khi hoàn thành mỗi TODO.

---

## 0. Nguyên tắc cốt lõi (BẤT BIẾN — không được phá)

1. **Bản ghi bất biến (Immutable Records)**
   - TUYỆT ĐỐI **không** `DELETE` hoặc `UPDATE` bài nộp cũ.
   - Mỗi lần làm lại = **một `work_session` mới hoàn toàn**, kèm `attempt = MAX(attempt) + 1`.
   - `submissions`, `submission_answers`, `autosave_answers` của attempt cũ giữ nguyên — phục vụ AI Analytics, kháng nại điểm, audit.

2. **Trình tự bắt buộc khi triển khai**
   ```
   Phase 1 (DB) ──► Phase 2 (Backend Dart) ──► Phase 3 (Flutter UI)
   ```
   - Không được code Flutter trước khi DB xong.
   - Không được code Dart datasource trước khi RPC + migration đã apply lên Supabase.

3. **Single Source of Truth**
   - Logic tạo session mới + tạo variant mới + tăng `attempt`: nằm **duy nhất** trong RPC `start_redo_session`. Dart chỉ gọi RPC, không tự xử lý.
   - Logic gộp điểm (`latest` / `max` / `average`): nằm trong RPC `get_aggregated_scores_for_distribution`. Frontend không tự gộp.

4. **AI Analytics chỉ ăn `latest` hoặc `max`** — KHÔNG dùng `average` (xem mục 6).

---

## 1. Tổng quan kiến trúc

### 1.1 Mô hình dữ liệu (sau khi migration)

```
assignment_distributions (1) ──< work_sessions (N) ──< submissions (1:1)
                                       │
                                       ├─ attempt = 1 (lần đầu)
                                       ├─ attempt = 2 (làm lại lần 1)
                                       └─ attempt = 3 (làm lại lần 2)
                                            │
                                            └─ assignment_variants riêng từng attempt
```

**Khoá UNIQUE mới**: `(assignment_distribution_id, student_id, attempt)` trên `work_sessions`
→ đảm bảo không bao giờ có 2 session trùng attempt cho cùng 1 cặp (distribution, student).

### 1.2 Settings JSON trên `assignment_distributions.settings`

Sau migration, JSON sẽ có **đủ** các key:
```json
{
  "shuffle_choices": false,
  "shuffle_questions": false,
  "show_score_immediately": true,
  "allow_retake": false,
  "max_attempts": 1,
  "score_aggregation_rule": "latest"
}
```
- `allow_retake`: GV có cho làm lại không.
- `max_attempts`: số lần tối đa được làm (kể cả lần đầu). `1` = chỉ làm 1 lần. `null`/`0` = không giới hạn.
- `score_aggregation_rule`: `'latest' | 'max' | 'average'` — chọn điểm hiển thị/lưu sổ.

### 1.3 3 kịch bản chính

| Kịch bản | Trạng thái distribution | Hành vi |
|----------|------------------------|---------|
| **1. GV cho làm lại** | `active`, `allow_retake=true`, attempt < max | RPC `start_redo_session` → tạo session mới + variant mới + attempt+1 |
| **2A. Bài đóng — student chưa làm/muốn làm lại** | `closed` HOẶC quá `due_at` + `allow_late=false` | Backend trả 403 → Frontend show `_ClosedBanner` |
| **2B. Bài tự đóng khi student đang làm** | Worker phát hiện `status='in_progress'` ở distribution closed | Auto-submit (gom autosave → submission_answers, set `submitted`) — ghi TODO, làm sau |

---

## 2. Trạng thái hiện tại (snapshot — đã verify bằng SQL)

### Đã có
- [x] `work_sessions.attempt INTEGER DEFAULT 1`
- [x] `assignment_distributions.status TEXT DEFAULT 'active'`
- [x] `assignment_distributions.allow_late BOOLEAN DEFAULT true`
- [x] `assignment_distributions.settings JSONB` (có `shuffle_choices`, `shuffle_questions`, `show_score_immediately`)
- [x] Bảng `autosave_answers`, `submission_answers`, `assignment_variants` đầy đủ
- [x] Frontend `_ClosedBanner` cho kịch bản 2A
- [x] RPC `ensure_student_variant` (idempotent theo `assignment_id + student_id` — KHÔNG hỗ trợ multi-attempt)

### Còn thiếu
- [ ] UNIQUE constraint `(assignment_distribution_id, student_id, attempt)` trên `work_sessions`
- [ ] Key `allow_retake`, `max_attempts`, `score_aggregation_rule` trong default `settings`
- [ ] RPC `start_redo_session(distribution_id, student_id)` — atomic, SECURITY DEFINER
- [ ] RPC `ensure_student_variant_for_session(p_session_id, p_assignment_id, p_student_id, p_attempt)` — variant theo session
- [ ] RPC `get_aggregated_scores_for_distribution(p_distribution_id, p_rule)` — gộp điểm
- [ ] View `v_student_attempts_summary` — tóm tắt attempt cho UI Teacher
- [ ] Worker auto-submit khi distribution close (Phase 2B — defer)

### Bug đang tồn tại trong code
- [ ] **Bug 1**: `assignment_datasource.dart` line ~1209 đọc `settings['maxAttempts']` (sai camelCase) → phải sửa thành `settings['max_attempts']`.
- [ ] **Bug 2**: `assignment_datasource.dart` lines ~1334-1342 INSERT `work_sessions` không set `attempt` → mọi session mặc định `attempt=1`, khi có UNIQUE sẽ conflict.
- [ ] **Bug 3**: RPC `ensure_student_variant` idempotent theo `(assignment_id, student_id)` → redo lần 2 sẽ trả đúng đề lần 1 (vô hiệu mục đích shuffle).

---

## 3. PHASE 1 — DB Migration

> **Output**: 1 file SQL `db/migration_06_redo_assignment.sql` apply qua `mcp__supabase__apply_migration`.
> Đặt tên migration: `phase_06_redo_assignment_and_score_aggregation`.

### TODO 3.1 — Thêm UNIQUE constraint cho `work_sessions`
- [x] **File**: `db/migration_06_redo_assignment.sql`
- **Mô tả**: Thêm `UNIQUE (assignment_distribution_id, student_id, attempt)`.
- **Lưu ý**: Trước khi thêm, **CHẠY query kiểm tra dữ liệu rác**:
  ```sql
  SELECT assignment_distribution_id, student_id, attempt, COUNT(*)
  FROM work_sessions
  GROUP BY 1,2,3 HAVING COUNT(*) > 1;
  ```
  Nếu có row trùng → cần script dedupe trước (giữ row mới nhất `created_at`).
- **Loại**: feature mới (kèm cleanup dữ liệu legacy nếu cần).

### TODO 3.2 — Backfill `settings` JSON cho mọi distribution cũ
- [ ] **File**: cùng file migration trên
- **Mô tả**: `UPDATE assignment_distributions SET settings = settings || jsonb_build_object('allow_retake', false, 'max_attempts', 1, 'score_aggregation_rule', 'latest') WHERE NOT (settings ? 'allow_retake')`.
- **Loại**: bug fix (data backfill).

### TODO 3.3 — Cập nhật DEFAULT của cột `settings`
- [ ] **File**: cùng file migration
- **Mô tả**: `ALTER TABLE assignment_distributions ALTER COLUMN settings SET DEFAULT '{"shuffle_choices": false, "shuffle_questions": false, "show_score_immediately": true, "allow_retake": false, "max_attempts": 1, "score_aggregation_rule": "latest"}'::jsonb`.
- **Loại**: feature mới.

### TODO 3.4 — RPC `ensure_student_variant_for_session`
- [ ] **File**: cùng file migration
- **Mô tả**: Bản multi-attempt của `ensure_student_variant`. Idempotent theo `session_id` (KHÔNG theo `assignment_id+student_id`).
- **Signature**:
  ```sql
  CREATE OR REPLACE FUNCTION public.ensure_student_variant_for_session(
    p_session_id UUID,
    p_assignment_id UUID,
    p_student_id UUID,
    p_attempt INTEGER
  ) RETURNS UUID  -- variant_id
  SECURITY DEFINER SET search_path = public LANGUAGE plpgsql
  ```
- **Logic**:
  1. Check `assignment_variants` đã có row cho `session_id` chưa → có thì return.
  2. Đọc `shuffle_questions`, `shuffle_choices` từ distribution.settings.
  3. Sinh variant mới (seed = hash(session_id) để deterministic theo session).
  4. Insert vào `assignment_variants` kèm `session_id`. **Cột `assignment_variants.session_id` cần thêm nếu chưa có** — kiểm tra schema trước.
- **Loại**: feature mới.

### TODO 3.5 — RPC `start_redo_session` (TRÁI TIM của tính năng)
- [ ] **File**: cùng file migration
- **Signature**:
  ```sql
  CREATE OR REPLACE FUNCTION public.start_redo_session(
    p_distribution_id UUID,
    p_student_id UUID
  ) RETURNS JSONB  -- {session_id, attempt, variant_id}
  SECURITY DEFINER SET search_path = public LANGUAGE plpgsql
  ```
- **Logic (atomic — bọc trong BEGIN/EXCEPTION)**:
  1. Lock distribution: `SELECT ... FOR UPDATE` lấy `assignment_id`, `status`, `due_at`, `allow_late`, settings.
  2. Validate:
     - `status = 'active'` (else RAISE `distribution_closed`).
     - `(allow_late OR due_at IS NULL OR due_at > now())` (else RAISE `past_due`).
     - `settings->>'allow_retake' = 'true'` (else RAISE `retake_not_allowed`).
  3. Đếm attempt hiện tại: `SELECT COALESCE(MAX(attempt), 0) FROM work_sessions WHERE distribution_id = ... AND student_id = ...`.
  4. Validate `max_attempts`: nếu `current_max >= max_attempts` → RAISE `max_attempts_reached`.
  5. **Quan trọng**: kiểm tra session attempt cũ phải `status IN ('submitted','graded')` — không cho redo khi có session `in_progress`.
  6. INSERT `work_sessions` với `attempt = current_max + 1`, `status = 'in_progress'`.
  7. Gọi `ensure_student_variant_for_session(new_session_id, assignment_id, student_id, attempt)`.
  8. Return `jsonb_build_object('session_id', ..., 'attempt', ..., 'variant_id', ...)`.
- **Loại**: feature mới.

### TODO 3.6 — RPC `get_aggregated_scores_for_distribution`
- [ ] **File**: cùng file migration
- **Signature**:
  ```sql
  CREATE OR REPLACE FUNCTION public.get_aggregated_scores_for_distribution(
    p_distribution_id UUID,
    p_rule TEXT DEFAULT NULL  -- override rule, default đọc từ distribution.settings
  ) RETURNS TABLE (
    student_id UUID,
    final_score NUMERIC,
    attempts_count INTEGER,
    final_submission_id UUID,
    final_session_id UUID
  )
  SECURITY DEFINER SET search_path = public LANGUAGE plpgsql
  ```
- **Logic**:
  - `latest`: `ROW_NUMBER() OVER (PARTITION BY student_id ORDER BY ws.attempt DESC)` lấy row số 1.
  - `max`: `ROW_NUMBER() OVER (PARTITION BY student_id ORDER BY s.total_score DESC NULLS LAST, ws.attempt DESC)`.
  - `average`: `AVG(s.total_score) GROUP BY student_id`, `final_submission_id` và `final_session_id` = NULL (không có 1 submission đại diện).
  - Chỉ tính submissions có `is_voided = false`.
- **Loại**: feature mới.

### TODO 3.7 — View `v_student_attempts_summary`
- [ ] **File**: cùng file migration
- **Mô tả**: View phục vụ Teacher UI hiển thị danh sách attempts của 1 student.
- **Schema**:
  ```sql
  CREATE OR REPLACE VIEW v_student_attempts_summary AS
  SELECT
    ws.id AS session_id,
    ws.assignment_distribution_id,
    ws.student_id,
    ws.attempt,
    ws.status AS session_status,
    ws.started_at,
    ws.submitted_at,
    s.id AS submission_id,
    s.total_score,
    s.is_late,
    s.is_voided
  FROM work_sessions ws
  LEFT JOIN submissions s ON s.session_id = ws.id
  ORDER BY ws.student_id, ws.attempt;
  ```
- **Loại**: feature mới.

### TODO 3.8 — RLS cho RPC mới
- [ ] **File**: cùng file migration
- **Mô tả**: `start_redo_session` SECURITY DEFINER nhưng phải kiểm tra `auth.uid() = p_student_id` ở đầu function (else RAISE `permission_denied`). RPC `get_aggregated_scores_*` chỉ teacher của class hoặc admin được gọi.
- **Loại**: feature mới.

### TODO 3.9 — Apply migration & verify
- [ ] Chạy `mcp__supabase__apply_migration` với name `phase_06_redo_assignment_and_score_aggregation`.
- [ ] Verify bằng `mcp__supabase__execute_sql`:
  ```sql
  -- 1. UNIQUE tồn tại
  SELECT conname FROM pg_constraint
  WHERE conrelid = 'work_sessions'::regclass AND contype = 'u';
  -- 2. Settings backfill xong
  SELECT COUNT(*) FROM assignment_distributions WHERE NOT (settings ? 'allow_retake');
  -- 3. RPC tồn tại
  SELECT proname FROM pg_proc WHERE proname IN
    ('start_redo_session','ensure_student_variant_for_session','get_aggregated_scores_for_distribution');
  ```

---

## 4. PHASE 2 — Backend Dart (Datasource + Providers)

> Chỉ bắt đầu khi Phase 1 hoàn thành. Mỗi TODO ghi rõ là **bug fix** hay **feature mới**.

### TODO 4.1 — [BUG FIX] Sửa key `maxAttempts` → `max_attempts`
- [ ] **File**: `lib/data/datasources/assignment_datasource.dart` line ~1209
- **Cũ**: `final maxAttempts = settings['maxAttempts'] as int?;`
- **Mới**: `final maxAttempts = settings['max_attempts'] as int?;`
- **Lý do**: Supabase dùng snake_case; key cũ luôn return null → logic chặn retake không hoạt động.

### TODO 4.2 — [BUG FIX] Set `attempt` khi INSERT `work_sessions`
- [ ] **File**: `lib/data/datasources/assignment_datasource.dart` lines ~1334-1342
- **Mô tả**: Khi tạo session đầu tiên (lần 1), explicit set `'attempt': 1`. Khi chạy redo, KHÔNG dùng path này — phải gọi RPC `start_redo_session`.
- **Lý do**: Mặc dù DB có DEFAULT 1, sau khi có UNIQUE constraint, để rõ ràng + tránh trượt khi data race.

### TODO 4.3 — [FEATURE] Method `startRedoSession`
- [ ] **File**: `lib/data/datasources/assignment_datasource.dart`
- **Signature**:
  ```dart
  Future<RedoSessionResult> startRedoSession({
    required String distributionId,
    required String studentId,
  });
  ```
- **Logic**: Gọi `_client.rpc('start_redo_session', params: {...})` → parse response thành DTO `RedoSessionResult { sessionId, attempt, variantId }`.
- **Error mapping** (xem TODO 4.5).

### TODO 4.4 — [FEATURE] Method `getAggregatedScores`
- [ ] **File**: `lib/data/datasources/assignment_datasource.dart`
- **Signature**:
  ```dart
  Future<List<AggregatedScore>> getAggregatedScores({
    required String distributionId,
    String? overrideRule,
  });
  ```

### TODO 4.5 — [FEATURE] Custom exceptions cho redo
- [ ] **File**: `lib/data/datasources/assignment_datasource.dart` (hoặc file errors riêng)
- **Mô tả**: Map PostgresException theo `code/message`:
  - `distribution_closed` → `RedoBlockedException(reason: closed)`
  - `past_due` → `RedoBlockedException(reason: pastDue)`
  - `retake_not_allowed` → `RedoBlockedException(reason: notAllowed)`
  - `max_attempts_reached` → `RedoBlockedException(reason: maxReached)`
  - `permission_denied` → `RedoBlockedException(reason: permission)`
- **Lý do**: UI cần biết chính xác lý do để show banner/snackbar phù hợp.

### TODO 4.6 — [FEATURE] Provider `redoSessionProvider`
- [ ] **File**: `lib/presentation/providers/student_assignment_providers.dart`
- **Signature**:
  ```dart
  final redoSessionProvider = AsyncNotifierProvider.family
    .autoDispose<RedoSessionNotifier, RedoSessionResult, String /*distributionId*/>(...);
  ```
- **Hành vi**: `notifier.start()` → gọi datasource → invalidate `studentAssignmentDetailProvider(distributionId)` để refresh attempt list.

### TODO 4.7 — [FEATURE] Provider `aggregatedScoresProvider`
- [ ] **File**: `lib/presentation/providers/teacher_assignment_providers.dart` (hoặc tạo nếu chưa có)
- **Signature**: `FutureProvider.family<List<AggregatedScore>, String distributionId>`.
- **Caching**: invalidate khi GV đổi `score_aggregation_rule` hoặc khi có submission mới.

### TODO 4.8 — [FEATURE] Cập nhật `distribute_assignment_notifier`
- [ ] **File**: `lib/presentation/providers/distribute_assignment_notifier.dart`
- **Mô tả**: Thêm 3 field vào state: `allowRetake`, `maxAttempts`, `scoreAggregationRule`. Khi save → ghi vào `settings` JSON.
- **Loại**: feature mới.

### TODO 4.9 — [FEATURE] Workspace provider phải biết `attempt`
- [ ] **File**: `lib/presentation/providers/workspace_provider.dart`
- **Mô tả**: Khi load workspace, đọc `attempt` của session hiện tại → expose ra UI để hiển thị badge "Lần làm thứ N".
- **Loại**: feature mới.

---

## 5. PHASE 3 — Flutter UI (Student + Teacher)

> Chỉ bắt đầu khi Phase 2 hoàn thành.
> **CHÚ Ý**: `student_assignment_detail_screen.dart` đang trong trạng thái nhạy cảm — chỉ ADD widget mới, KHÔNG refactor cấu trúc hiện có trừ khi có yêu cầu rõ ràng.

### 5.1 Student View

#### TODO 5.1.1 — Nút "Làm lại" trên student detail screen
- [ ] **File**: `lib/presentation/views/assignment/student/student_assignment_detail_screen.dart`
- **Vị trí**: trong phần action bar khi `submission` đã có (`status IN submitted/graded`).
- **Điều kiện hiển thị** (đọc từ provider):
  - `distribution.status == 'active'`
  - `settings.allow_retake == true`
  - `current_attempt < settings.max_attempts`
  - Distribution chưa quá hạn (hoặc `allow_late=true`)
- **OnTap**: gọi `redoSessionProvider(distributionId).notifier.start()` → khi success navigate workspace với `sessionId` mới.
- **Loại**: feature mới.

#### TODO 5.1.2 — Confirm dialog trước khi redo
- [ ] **File**: cùng file trên
- **Mô tả**: Dialog cảnh báo "Bài làm cũ vẫn được lưu. Sau khi làm lại, điểm cuối cùng được tính theo quy tắc: <rule>". Có nút Cancel/Confirm.
- **Loại**: feature mới.

#### TODO 5.1.3 — Badge "Lần thứ N/M" trên workspace
- [ ] **File**: `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart`
- **Mô tả**: Badge nhỏ ở app bar: "Lần làm thứ 2/3".
- **Loại**: feature mới.

#### TODO 5.1.4 — Lịch sử các lần làm
- [ ] **File**: `student_assignment_detail_screen.dart`
- **Mô tả**: Section "Các lần làm trước" — list tóm tắt từng attempt: số lần, thời gian nộp, điểm. Tap → mở submission read-only.
- **Loại**: feature mới.

#### TODO 5.1.5 — Map exception → snackbar message
- [ ] **File**: `student_assignment_detail_screen.dart`
- **Mô tả**: Khi `RedoBlockedException` ném ra:
  - `closed`/`pastDue` → "Bài tập đã đóng, không thể làm lại."
  - `maxReached` → "Bạn đã làm đủ số lần cho phép."
  - `notAllowed` → "Giáo viên không cho phép làm lại bài này."
  - `permission` → snackbar đỏ "Phiên hết hạn, đăng nhập lại."
- **Loại**: feature mới.

### 5.2 Teacher View

#### TODO 5.2.1 — Form distribute: thêm 3 control
- [ ] **File**: tìm screen distribute (thường `lib/presentation/views/assignment/teacher/distribute_assignment_screen.dart` hoặc tương tự — search nếu chưa rõ).
- **Control**:
  1. Switch "Cho phép làm lại" → `allow_retake`.
  2. NumberInput "Số lần tối đa" (chỉ enable khi switch ON, default 2, min 1, max 10).
  3. Dropdown "Quy tắc tính điểm": `Mới nhất | Cao nhất | Trung bình` → `score_aggregation_rule`.
- **Loại**: feature mới.

#### TODO 5.2.2 — Bảng điểm gộp cho teacher
- [ ] **File**: screen quản lý lớp/distribution của teacher.
- **Mô tả**: Cột "Điểm cuối" hiển thị từ `aggregatedScoresProvider`. Hover/tap row → expand chi tiết các attempts (dùng `v_student_attempts_summary`).
- **Loại**: feature mới.

#### TODO 5.2.3 — Cảnh báo khi đổi `score_aggregation_rule` sau khi đã có submissions
- [ ] **Mô tả**: Confirm dialog: "Đổi quy tắc sẽ thay đổi điểm cuối hiển thị cho tất cả học sinh đã nộp. Tiếp tục?".
- **Loại**: feature mới.

---

## 6. AI Analytics — Quy tắc đặc biệt

> **BẮT BUỘC** đọc trước khi viết bất kỳ analytics/recommendation feature nào.

- AI Analytics layer (skill mastery, recommendations, peer comparison) **CHỈ ĐƯỢC PHÉP** đọc submission được chọn theo rule `latest` HOẶC `max`.
- **CẤM** dùng `average` cho mục đích tính skill mastery → vì 1 lần làm tệt sẽ kéo skill xuống dù học sinh đã thực sự nắm vững ở lần làm sau.
- Nếu distribution đặt rule = `average`, AI Analytics phải fallback về `max` cho riêng nó.
- Implement: tạo thêm RPC `get_analytics_score_for_student(distribution_id, student_id)` → luôn return điểm theo `max` bất kể rule của distribution.
- **TODO** (mở để tracker phase analytics): [ ] Tạo RPC `get_analytics_score_for_student`.

---

## 7. Worker auto-submit (Phase 2B — DEFER)

> Mục này KHÔNG nằm trong scope ngay, nhưng ghi để không quên.

- [ ] **TODO defer**: Triển khai job (Edge Function + cron Supabase scheduler) quét mỗi 5 phút:
  ```sql
  SELECT ws.id, ws.assignment_distribution_id
  FROM work_sessions ws
  JOIN assignment_distributions ad ON ad.id = ws.assignment_distribution_id
  WHERE ws.status = 'in_progress'
    AND ad.status = 'closed'  -- hoặc due_at < now() AND allow_late = false
  LIMIT 100;
  ```
  → với mỗi row: gom `autosave_answers` → INSERT `submission_answers` → UPDATE `work_sessions.status='submitted'` + tạo `submissions` row.
- **Owner**: tách phase riêng sau MVP.

---

## 8. KHÔNG ĐƯỢC LÀM (anti-patterns)

1. **KHÔNG** `DELETE` hoặc `UPDATE` work_sessions/submissions/autosave_answers cũ khi học sinh redo. Mỗi lần redo = INSERT row mới.
2. **KHÔNG** xử lý logic "tăng attempt + tạo session + tạo variant" ở phía Dart. Phải gọi RPC `start_redo_session` (atomic, server-side).
3. **KHÔNG** dùng RPC `ensure_student_variant` (cũ) cho session mới của redo — sẽ lấy lại variant cũ. Phải dùng `ensure_student_variant_for_session`.
4. **KHÔNG** đọc `settings['maxAttempts']` (camelCase). Đúng là `settings['max_attempts']`.
5. **KHÔNG** code Flutter UI trước khi datasource + provider có đủ method/state.
6. **KHÔNG** apply UNIQUE constraint trước khi backfill `attempt` cho data legacy.
7. **KHÔNG** cho phép student bấm "Làm lại" khi còn session `in_progress` — RPC sẽ throw nhưng UI cũng phải disable nút.
8. **KHÔNG** dùng rule `average` cho AI skill mastery (xem mục 6).
9. **KHÔNG** refactor `student_assignment_detail_screen.dart` ngoài scope (chỉ ADD widget mới).
10. **KHÔNG** cho phép GV đổi `max_attempts` xuống thấp hơn `MAX(attempt)` đã có — phải validate ở Dart hoặc DB constraint.

---

## 9. Definition of Done

Một feature gọi là DONE khi đủ các điều sau:

### DB
- [ ] Migration apply thành công, verify queries pass.
- [ ] RLS test bằng test user student & teacher.

### Backend Dart
- [ ] `flutter analyze` không có error/warning mới.
- [ ] Unit test `RedoBlockedException` mapping cho cả 5 reason codes.
- [ ] Integration test gọi `startRedoSession` 2 lần liên tiếp → attempt = 2, 3.

### Frontend
- [ ] Manual test: học sinh làm lần 1 → submit → redo → workspace mở với đề khác → submit → detail hiển thị 2 attempts.
- [ ] Teacher đổi rule `latest` → `max` → bảng điểm cập nhật.
- [ ] Bài đóng giữa chừng: snackbar đúng message.
- [ ] Đếm attempt = max_attempts: nút "Làm lại" disabled.

### AI Analytics
- [ ] Verify analytics dùng `max` bất kể rule của distribution.

---

## 10. Phụ lục — File path quan trọng

| Mục đích | Path |
|----------|------|
| Datasource chính | `lib/data/datasources/assignment_datasource.dart` |
| Provider student | `lib/presentation/providers/student_assignment_providers.dart` |
| Provider teacher | `lib/presentation/providers/teacher_assignment_providers.dart` (tạo nếu chưa có) |
| Provider workspace | `lib/presentation/providers/workspace_provider.dart` |
| Provider distribute | `lib/presentation/providers/distribute_assignment_notifier.dart` |
| UI student detail | `lib/presentation/views/assignment/student/student_assignment_detail_screen.dart` (nhạy cảm) |
| UI student workspace | `lib/presentation/views/assignment/student/student_assignment_workspace_screen.dart` |
| Schema reference | `db/schema_03_submissions_ai_analytics.sql` |
| Migration format mẫu | `db/migration_05_recommendations.sql` |
| Migration mới | `db/migration_06_redo_assignment.sql` (sẽ tạo trong Phase 1) |

---

## 11. Lịch sử cập nhật

| Ngày | Người | Thay đổi |
|------|-------|----------|
| 2026-04-30 | Architect | Khởi tạo file kế hoạch. |
