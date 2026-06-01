# Batch A — Chấm điểm & Hồ sơ GV (Design Spec)

> Ngày: 2026-06-01 · Trạng thái: Đã duyệt thiết kế, chờ review spec
> Phạm vi: 6 hạng mục thuộc subsystem chấm điểm + hồ sơ giáo viên.
> Nguyên tắc: Apply migration trực tiếp lên DB production (idempotent + verify). Single-owner mỗi file chia sẻ. Test thật, không suy đoán.

## 1. Bối cảnh & hiện trạng (đã verify trên DB + code)

| Hạng mục | Backend hiện có | Frontend hiện có | Kết luận |
|---|---|---|---|
| #5 Teacher notes | bảng `teacher_notes` (id, teacher_id, student_id, content, is_private, created_at) — **thiếu `updated_at`** | 0 ref trong lib/ | Build mới UI + data layer |
| #4 Batch grading câu giống nhau | chỉ có `batch_regrade_assignment` (rescore sau sửa câu) | không có | RPC mới + màn mới |
| Batch publish | ✅ `publishAllGrades(distributionId)` đủ ở provider+datasource | thiếu nút | Chỉ thêm UI |
| AI rationale | ✅ edge sinh `criteria[]` + `rationale`; ghi `submission_answers.ai_feedback` | chưa render `criteria`/`rationale` | Chỉ thêm render |
| Side-by-side | — | xếp dọc (ListView, 1899 dòng) | Responsive wrapper |
| #6 Feedback tone | edge KHÔNG inject tone (prompt feedback dòng ~287, score dòng ~622) | không có setting | Inject prompt + setting UI |

**File chia sẻ (rủi ro xung đột song song):**
- `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` (1899 dòng) → side-by-side + AI rationale + nút batch publish.
- `supabase/functions/process-ai-queue/index.ts` → tone injection (2 prompt).
- `lib/data/datasources/submission_datasource.dart` → method batch grading.
- `lib/presentation/providers/teacher_submission_providers.dart` → provider batch grading.

## 2. Quyết định thiết kế (đã chốt với user)

1. **Tone lưu per-GV toàn cục** tại `profiles.metadata.feedback_tone` (JSONB, không migration bảng). 3 mức:
   - `encouraging` — động viên, ấm áp, nhấn mạnh điểm tốt trước.
   - `direct` — thẳng thắn, gọn, đi thẳng vào sai sót.
   - `detailed` — phân tích chi tiết, nhiều bước, học thuật.
   - Mặc định khi chưa set: `encouraging` (giữ hành vi cũ).
2. **Batch grading gom trong 1 đợt giao (distribution)** — tất cả HS cùng trả lời 1 `assignment_question_id`.
3. **Side-by-side = responsive wrapper** (KHÔNG viết lại 1899 dòng). Tách `_buildQuestionPanel()` + `_buildGradingPanel()`; ≥900px = `Row`, <900px = `Column` cũ.
4. **Teacher notes**: danh sách nhiều ghi chú per (GV, HS), editable → cần `updated_at`. Host trong `teacher_student_analytics_screen.dart` dưới dạng section "Ghi chú của giáo viên".

## 3. Thay đổi Schema (migration idempotent, apply trực tiếp + verify)

### 3.1 Migration `039_teacher_notes_updated_at`
```sql
ALTER TABLE public.teacher_notes
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();
-- trigger set updated_at on UPDATE (idempotent: drop+create)
-- Verify RLS: teacher chỉ thao tác note của chính mình (teacher_id = (select auth.uid()))
--   SELECT/INSERT/UPDATE/DELETE policy. Nếu chưa có → tạo.
```
Verify sau apply: `\d teacher_notes` có `updated_at`; `pg_policies` có 4 policy cho teacher_notes.

### 3.2 Migration `040_batch_grade_by_question_rpc`
Hai RPC `SECURITY DEFINER`, guard quyền GV sở hữu distribution/class:
```sql
-- Lấy mọi câu trả lời của 1 assignment_question trong 1 distribution (kèm HS, điểm AI, điểm chốt)
CREATE OR REPLACE FUNCTION public.get_distribution_answers_by_question(
  p_distribution_id uuid, p_assignment_question_id uuid)
RETURNS TABLE(answer_id uuid, session_id uuid, student_id uuid, student_name text,
  answer jsonb, ai_score numeric, ai_confidence numeric, final_score numeric,
  ai_feedback jsonb, graded_at timestamptz) ...

-- Duyệt hàng loạt ai_score → final_score cho danh sách answer (chỉ trong distribution GV sở hữu)
CREATE OR REPLACE FUNCTION public.batch_approve_ai_scores(
  p_answer_ids uuid[], p_graded_by uuid)
RETURNS integer ...  -- trả số bản ghi cập nhật; gọi recompute + maybe_mark_graded mỗi session
```
Guard: kiểm tra `p_graded_by` là teacher của class chứa distribution. Verify: gọi thử với distribution thật, đối chiếu count.

### 3.3 Tone — KHÔNG migration bảng
Lưu tại `profiles.metadata->>'feedback_tone'`. Edge đọc tại handleFeedback + handleScore.

## 4. Thay đổi Code theo Track (single-owner)

### Track 1 — Teacher notes (file mới, độc lập 100%)
- `lib/data/datasources/teacher_notes_datasource.dart` — CRUD: `getNotes(studentId)`, `addNote()`, `updateNote()`, `deleteNote()`.
- `lib/domain/entities/teacher_note.dart` (Freezed) + `lib/data/models/teacher_note_dto.dart`.
- `lib/domain/repositories/teacher_notes_repository.dart` + impl.
- `lib/presentation/providers/teacher_notes_provider.dart` (`@riverpod` notes list + notifier add/edit/delete, guard `_isUpdating`).
- `lib/presentation/views/grading/widgets/teacher_notes_section.dart` — section trong `teacher_student_analytics_screen.dart` (thêm 1 dòng nhúng widget, KHÔNG sửa logic khác). Dùng MathText nếu cần, design tokens.

### Track 2 — Batch grading by question (file mới + 1 method datasource)
- `lib/data/datasources/submission_datasource.dart` — thêm `getDistributionAnswersByQuestion(...)`, `batchApproveAiScores(...)` (gọi 2 RPC mới).
- `lib/presentation/providers/teacher_submission_providers.dart` — thêm provider `distributionAnswersByQuestion(...)` + method `batchApproveScores()` trong notifier.
- `lib/presentation/views/assignment/teacher/batch_grade_by_question_screen.dart` (màn mới): chọn câu → list đáp án HS cạnh nhau → "Duyệt tất cả AI" / chỉnh lẻ.
- Route mới trong `route_constants.dart` + `app_router.dart` (specific trước parameterized), entry point từ submission list (nút "Chấm theo câu").

### Track 3 — Feedback tone (edge + setting UI)
- `supabase/functions/process-ai-queue/index.ts`:
  - Hàm `buildToneInstruction(tone)` → đoạn chỉ dẫn chèn đầu prompt feedback (dòng ~287) và score (dòng ~622).
  - Đọc tone từ profile GV của assignment (join qua submission → assignment → teacher_id → profiles.metadata.feedback_tone). Fallback `encouraging`.
  - Deploy lại edge function. Verify bằng invoke thật.
- Setting UI: thêm dropdown "Giọng điệu phản hồi AI" vào màn cài đặt GV hiện có (tìm settings screen; nếu chưa có chỗ phù hợp → thêm vào màn profile/settings GV). Lưu `profiles.metadata.feedback_tone`.

### Track 4 — Detail screen (1 CHỦ duy nhất file 1899 dòng)
- Tách render thành `_buildQuestionPanel()` + `_buildGradingPanel()`.
- ≥900px (`DesignBreakpoints`): `Row(question | grading)`; <900px: giữ `Column`.
- Render thêm `ai_feedback.criteria[]` (bảng tiêu chí điểm) + `rationale` trong AI feedback box.
- Thêm nút "Xuất bản tất cả" (gọi `publishAllGrades`) vào AppBar/footer của submission list (đụng list — phối hợp với Track 2 owner; để Track 4 sở hữu nút này nếu nằm ở detail footer, hoặc Track 2 nếu ở list — **chốt: nút batch publish nằm ở submission list → Track 2 sở hữu**).

> Điều chỉnh ownership nút batch publish: đặt ở **submission list** → thuộc Track 2 (đã sở hữu providers list). Track 4 chỉ lo detail screen (side-by-side + rationale).

## 5. Điều phối multi-agent (team 4 vai/track, loop ≤3 vòng)

Mỗi track chạy như một pipeline:
1. **Coder** — implement theo spec.
2. **Reviewer** — soi lỗi ẩn: null-safety, RLS, route order, provider duplicate, design tokens, concurrency guard, freezed regen.
3. **Tester** — chạy thật: `flutter analyze` (track files), `flutter test` (test mới), build_runner nếu Freezed.
4. **Loop** — nếu đỏ → quay lại coder, tối đa **3 vòng/track**. Vượt 3 vòng → dừng, báo cáo để người quyết.

Track 1, 2, 3 chạy **song song** (không đụng file chung). Track 4 chạy **sau** Track 2 (vì nút batch publish + tránh đụng providers). Verify hợp nhất sau mỗi đợt: `flutter analyze` toàn repo + `flutter test`.

## 6. Chiến lược test (yêu cầu "test chuẩn")

| Loại | Phạm vi | Cách |
|---|---|---|
| Unit | teacher_notes datasource, batch grading datasource | mock `SupabaseClient`/`PostgrestBuilder` |
| Unit | providers (notes, batch) | `ProviderContainer` + override repository |
| Unit | `buildToneInstruction()` | thuần hàm, 3 tone + fallback |
| Widget | teacher_notes_section, batch_grade screen | `testWidgets`, pump + verify |
| Widget | side-by-side | test 2 breakpoint (≥900 = Row, <900 = Column) |
| Edge thật | tone injection | insert ai_queue + invoke `process-ai-queue` thật → đối chiếu `ai_evaluations`/`ai_feedback` thay đổi giọng |
| E2E UI/UX | toàn batch | marionette trên app thật sau khi tất cả track xanh |

## 7. Tiêu chí hoàn thành (Definition of Done)

- [ ] 2 migration applied + verify trên DB production.
- [ ] Edge `process-ai-queue` deploy lại, tone hoạt động (verify thật).
- [ ] Tất cả file mới + sửa qua `flutter analyze` 0 error.
- [ ] Unit + widget test mới pass.
- [ ] `flutter test` toàn bộ pass.
- [ ] E2E marionette: tạo note, batch grade 1 câu, đổi tone thấy khác, side-by-side render đúng 2 breakpoint, batch publish.
- [ ] Không regression các luồng chấm điểm hiện có.

## 8. Rủi ro & giảm thiểu

- **DB production có dữ liệu thật** (328 profiles, 344 submissions): mọi migration `IF NOT EXISTS`/idempotent, RPC `SECURITY DEFINER` có guard quyền. Không xóa/đổi cột hiện có.
- **File 1899 dòng**: chỉ 1 owner (Track 4), tách hàm thay vì viết lại.
- **Edge tone**: fallback `encouraging` đảm bảo không vỡ khi profile thiếu metadata.
- **Loop vô hạn**: cứng giới hạn 3 vòng/track.
