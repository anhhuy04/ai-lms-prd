# Batch A — Chấm điểm & Hồ sơ GV: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps dùng checkbox (`- [ ]`).
> Spec: `docs/superpowers/specs/2026-06-01-batch-a-grading-teacher-profile-design.md`

**Goal:** Bổ sung 6 hạng mục chấm điểm & hồ sơ GV (teacher notes, batch grade by question, batch publish UI, AI rationale render, side-by-side responsive, feedback tone) mà KHÔNG phá luồng chấm điểm hiện có.

**Architecture:** 4 track single-owner. Track 1/2/3 độc lập (song song được); Track 4 sau Track 2. Mỗi track: coder → reviewer (soi lỗi ẩn + hỏi "tại sao code cũ như thế") → tester thật → loop ≤3 vòng. Migration idempotent apply trực tiếp + verify.

**Tech Stack:** Flutter, Riverpod (@riverpod), Freezed, GoRouter, Supabase (Postgres RLS + Edge Deno), flutter_test.

**NGUYÊN TẮC BẮT BUỘC (mọi track):** Trước khi sửa code cũ, đọc & nêu rõ "đoạn này tồn tại để làm gì" rồi mới sửa. Ưu tiên thêm/bọc wrapper thay vì viết lại. Không xóa/đổi cột DB cũ. Dùng design tokens, MathText cho nội dung câu hỏi/đáp án, AppLogger (không print).

---

## File Structure

**Track 1 — Teacher notes (toàn file mới):**
- Create `lib/domain/entities/teacher_note.dart` (Freezed entity)
- Create `lib/data/models/teacher_note_dto.dart` (Freezed + json)
- Create `lib/data/datasources/teacher_notes_datasource.dart`
- Create `lib/domain/repositories/teacher_notes_repository.dart`
- Create `lib/data/repositories/teacher_notes_repository_impl.dart`
- Create `lib/presentation/providers/teacher_notes_provider.dart`
- Create `lib/presentation/views/grading/widgets/teacher_notes_section.dart`
- Modify `lib/presentation/views/grading/teacher_student_analytics_screen.dart` (nhúng 1 widget)
- Tests: `test/data/teacher_notes_datasource_test.dart`, `test/providers/teacher_notes_provider_test.dart`, `test/widgets/teacher_notes_section_test.dart`
- Migration `039_teacher_notes_updated_at`

**Track 2 — Batch grade by question + batch publish UI (file mới + 2 method):**
- Modify `lib/data/datasources/submission_datasource.dart` (+2 method)
- Modify `lib/presentation/providers/teacher_submission_providers.dart` (+1 provider, +1 method)
- Create `lib/presentation/views/assignment/teacher/batch_grade_by_question_screen.dart`
- Modify `lib/core/routes/route_constants.dart` + `app_router.dart` (route mới)
- Modify submission list screen (nút "Chấm theo câu" + "Xuất bản tất cả")
- Tests: `test/data/batch_grade_datasource_test.dart`, `test/providers/batch_grade_provider_test.dart`, `test/widgets/batch_grade_screen_test.dart`
- Migration `040_batch_grade_by_question_rpc`

**Track 3 — Feedback tone (edge + setting):**
- Modify `supabase/functions/process-ai-queue/index.ts` (buildToneInstruction + đọc profile tone)
- Modify/Create setting UI cho GV chọn tone → lưu `profiles.metadata.feedback_tone`
- Tests: edge invoke thật + widget test dropdown

**Track 4 — Detail screen (1 owner, sau Track 2):**
- Modify `lib/presentation/views/assignment/teacher/teacher_submission_detail_screen.dart` (tách panel + responsive + render rationale/criteria)
- Tests: `test/widgets/submission_detail_responsive_test.dart`

---

## Track 1 — Teacher Notes

### Task 1.1: Migration `039_teacher_notes_updated_at`
**Files:** apply qua Supabase MCP (idempotent)
- [ ] Đọc RLS hiện tại của `teacher_notes` (pg_policies) — hiểu policy đang có trước khi thêm.
- [ ] Apply: `ALTER TABLE public.teacher_notes ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();` + trigger set updated_at on UPDATE (drop+create idempotent). Nếu thiếu RLS policy cho teacher (SELECT/INSERT/UPDATE/DELETE với `teacher_id = (select auth.uid())`) → tạo `IF NOT EXISTS` qua DO block.
- [ ] Verify: query `information_schema.columns` có `updated_at`; `pg_policies` đủ 4 policy.

### Task 1.2: Entity + DTO
**Files:** Create `teacher_note.dart`, `teacher_note_dto.dart`
- [ ] Entity `TeacherNote { String id; String teacherId; String studentId; String content; bool isPrivate; DateTime createdAt; DateTime updatedAt; }` (Freezed).
- [ ] DTO map từ JSON snake_case → entity; `toInsertJson()` (content, student_id, is_private).
- [ ] Chạy `dart run build_runner build -d`.

### Task 1.3: Datasource (TDD)
**Files:** Create `teacher_notes_datasource.dart`, Test `teacher_notes_datasource_test.dart`
- [ ] Viết test trước: mock SupabaseClient, verify `getNotes(studentId)` select đúng filter + order updated_at desc; `addNote`, `updateNote`, `deleteNote` gọi đúng table/payload. Test FAIL.
- [ ] Implement datasource: `getNotes`, `addNote`, `updateNote`, `deleteNote` (null-safe, AppLogger, Sentry cho lỗi).
- [ ] Test PASS. Commit.

### Task 1.4: Repository + Provider (TDD)
**Files:** repo interface + impl, `teacher_notes_provider.dart`, Test `teacher_notes_provider_test.dart`
- [ ] Test provider với ProviderContainer + override repo: list load, add → refresh, concurrency guard `_isUpdating`. FAIL.
- [ ] Implement `@riverpod` notes family provider + notifier (add/edit/delete, `AsyncValue.guard`). PASS. Commit.

### Task 1.5: UI Section (widget test)
**Files:** `teacher_notes_section.dart`, modify analytics screen, Test widget
- [ ] Đọc `teacher_student_analytics_screen.dart` — hiểu cấu trúc trước khi nhúng. Nhúng section dưới cùng (1 dòng), không sửa logic khác.
- [ ] Section: list notes (MathText nếu cần), nút thêm (dialog), sửa/xóa, badge "riêng tư". Design tokens.
- [ ] Widget test: render list, tap thêm → dialog, empty state. Commit.

---

## Track 2 — Batch Grade By Question + Batch Publish UI

### Task 2.1: Migration `040_batch_grade_by_question_rpc`
**Files:** apply qua Supabase MCP
- [ ] Đọc RPC hiện có `recompute_submission_total`, `maybe_mark_session_graded`, `batch_regrade_assignment` — hiểu pattern guard quyền + recompute trước khi viết RPC mới.
- [ ] Apply `get_distribution_answers_by_question(p_distribution_id, p_assignment_question_id)` (SECURITY DEFINER, guard GV sở hữu class) trả về answer_id, session_id, student_id, student_name, answer, ai_score, ai_confidence, final_score, ai_feedback, graded_at.
- [ ] Apply `batch_approve_ai_scores(p_answer_ids uuid[], p_graded_by uuid)` → set final_score=ai_score cho từng answer (chỉ trong class GV sở hữu), gọi recompute + maybe_mark_graded mỗi session, trả count.
- [ ] Verify: gọi 2 RPC với 1 distribution thật, đối chiếu count + dữ liệu.

### Task 2.2: Datasource methods (TDD)
**Files:** modify `submission_datasource.dart`, Test `batch_grade_datasource_test.dart`
- [ ] Đọc method datasource hiện có (`approveAiScore`, `_recomputeAndMaybeGrade`) — hiểu pattern gọi RPC + xử lý lỗi.
- [ ] Test: `getDistributionAnswersByQuestion` gọi đúng RPC + map; `batchApproveAiScores` gọi RPC + trả count. FAIL → implement → PASS. Commit.

### Task 2.3: Provider + method (TDD)
**Files:** modify `teacher_submission_providers.dart`, Test
- [ ] Provider family `distributionAnswersByQuestion(distributionId, assignmentQuestionId)`; method `batchApproveScores(ids)` trong SubmissionGradingNotifier (guard, invalidate liên quan). Test ProviderContainer. Commit.

### Task 2.4: Màn batch grade (widget test) + route
**Files:** `batch_grade_by_question_screen.dart`, route files, Test
- [ ] Đọc route_constants + app_router — hiểu thứ tự route (specific trước parameterized) trước khi thêm.
- [ ] Màn: chọn câu (dropdown/list assignment_questions) → list đáp án HS (mỗi dòng: tên HS, đáp án MathText, điểm AI, confidence) → nút "Duyệt tất cả AI" + chỉnh lẻ. Design tokens, shimmer loading.
- [ ] Route mới `pushNamed`. Widget test render + tap duyệt. Commit.

### Task 2.5: Nút batch publish + entry batch grade ở submission list
**Files:** modify submission list screen
- [ ] Đọc list screen — hiểu nơi đặt action. Thêm nút "Xuất bản tất cả" (gọi `publishAllGrades` đã có, confirm dialog) + nút "Chấm theo câu" (mở màn 2.4).
- [ ] Widget test 2 nút hiển thị đúng điều kiện. Commit.

---

## Track 3 — Feedback Tone

### Task 3.1: Edge inject tone (test thật)
**Files:** modify `supabase/functions/process-ai-queue/index.ts`
- [ ] Đọc handleFeedback (~dòng 287) + handleScore (~dòng 622) — hiểu prompt hiện tại + vì sao có field encouragement, để không phá format JSON output.
- [ ] Thêm `buildToneInstruction(tone)`: 3 nhánh encouraging/direct/detailed + fallback. Chèn đoạn chỉ dẫn đầu prompt feedback & score.
- [ ] Đọc tone: join submission → assignment → teacher_id → `profiles.metadata->>'feedback_tone'`. Fallback 'encouraging'.
- [ ] Deploy lại edge. Test THẬT: insert/queue 1 feedback với teacher tone='direct' và 1 với 'encouraging' → invoke → đối chiếu `ai_feedback`/`ai_evaluations` giọng khác nhau. KHÔNG suy đoán.

### Task 3.2: Setting UI chọn tone
**Files:** tìm settings screen GV (grep), thêm dropdown
- [ ] Grep màn cài đặt/profile GV hiện có. Hiểu chỗ lưu `profiles.metadata` (đã có model/provider analytics).
- [ ] Thêm dropdown "Giọng điệu phản hồi AI" (3 lựa chọn + mô tả) lưu `metadata.feedback_tone`. Design tokens.
- [ ] Widget test dropdown đổi giá trị → gọi update. Commit.

---

## Track 4 — Detail Screen (sau Track 2)

### Task 4.1: Tách panel + responsive side-by-side
**Files:** modify `teacher_submission_detail_screen.dart`
- [ ] Đọc kỹ vùng render câu hỏi (dòng ~387-621) — hiểu vì sao xếp dọc + logic AI feedback box, để tách an toàn KHÔNG đổi hành vi <900px.
- [ ] Tách `_buildQuestionPanel(answer)` (câu hỏi + đáp án HS) và `_buildGradingPanel(answer)` (AI feedback + actions + audit). ≥900px (`DesignBreakpoints`) = `Row`, <900px = `Column` cũ y nguyên.
- [ ] Widget test 2 breakpoint: ≥900 có Row, <900 giữ Column. Không regression.

### Task 4.2: Render AI rationale + criteria
**Files:** modify cùng file
- [ ] Đọc vùng render ai_feedback (dòng ~943-1177) — hiểu các field đang render. Thêm render `ai_feedback.criteria[]` (bảng tiêu chí: tên/điểm/nhận xét) + `rationale` nếu có, ẩn khi null.
- [ ] Widget test: feedback có criteria → bảng hiện; null → ẩn. Commit.

---

## Verify hợp nhất (sau mỗi đợt + cuối batch)
- [ ] `flutter analyze` toàn repo = 0 error.
- [ ] `flutter test` toàn bộ pass.
- [ ] `dart run build_runner build -d` không lỗi (Freezed).
- [ ] E2E marionette app thật: tạo note → batch grade 1 câu → đổi tone thấy khác → side-by-side 2 breakpoint → batch publish.

## Self-Review coverage
- 6 hạng mục spec ↔ Track 1 (notes), Track 2 (batch grade + batch publish), Track 3 (tone), Track 4 (side-by-side + rationale). ✅ phủ hết.
- Không placeholder TBD. Interface nhất quán: `getDistributionAnswersByQuestion`/`batchApproveAiScores` dùng đồng nhất giữa datasource↔provider↔RPC.
