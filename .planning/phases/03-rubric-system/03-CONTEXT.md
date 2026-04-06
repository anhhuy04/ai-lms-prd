# Phase 3: Rubric System - Context

**Gathered:** 2026-04-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Enable teachers to create rubrics with criteria and scoring levels, attach them to essay questions, and use them when grading. Students can view rubric criteria before and during their work.

**Scope (RUB-01 to RUB-04):**
- RUB-01: Rubric builder UI — teacher creates criteria + scoring levels
- RUB-02: Point scale per criterion — levels with points and descriptions
- RUB-03: Attach rubric to assignment questions (essay type only)
- RUB-04: Student preview of rubric before/during submission

**Out of Scope:**
- AI highlighted level display on Review screen — deferred to Phase 6 (requires `ai_evaluations.criteria_scores`)
- Rubric validation/analytics — Phase 6
- Rubric sharing between teachers — future phase

</domain>

<decisions>
## Implementation Decisions

### D-01: Rubric Builder Location — Separate Screen (NOT inline)

**CHỐT: Separate Full-screen Bottom Sheet (Mobile) / Side-panel (Web future)**

- In question editor (essay type): show summary button — *"Rubric: Đã cấu hình 3 tiêu chí (Nhấn để sửa)"* or *"Thêm Rubric"* if none configured
- Tap → opens Full-screen Bottom Sheet (Mobile) / push to dedicated route
- `RubricBuilderComponent` is fully isolated from `QuestionEditorComponent`
  - Input: existing rubric JSONB (or null)
  - Output: updated rubric JSONB
  - No shared state with question content
- Rationale: Rubric is a 2D matrix (Criteria × Levels) — inline rendering on mobile causes scroll conflicts, keyboard occlusion, and file bloat. Cognitive load separation is paramount.

### D-02: Rubric Structure — Full Levels (NOT simple criteria + max_points)

**CHỐT: Full levels schema — criteria + max_points + levels array with points + description**

Required JSONB structure (strict data contract):
```json
{
  "criteria": [
    {
      "id": "crit-1",
      "name": "Lập luận",
      "max_points": 5,
      "levels": [
        { "points": 5, "description": "Lập luận hoàn chỉnh, có dẫn chứng" },
        { "points": 3, "description": "Đúng ý chính, thiếu dẫn chứng" },
        { "points": 0, "description": "Lạc đề hoặc không trả lời" }
      ]
    }
  ]
}
```

- `levels` array is MANDATORY — payload without it is invalid
- Rationale: Phase 6 AI needs `description` per level to grade deterministically (no hallucination). Teacher grading UI uses click-to-select levels (D-04). Simple criteria-only breaks both.

### D-03: Student Rubric Visibility — 3 Locations

**CHỐT: Assignment Detail + Workspace + Review screen foundation**

**Giai đoạn 1 — Assignment Detail (before starting):**
- Rubric preview card per essay question — criteria names + max_points overview
- Student knows scoring criteria before entering workspace

**Giai đoạn 2 — Workspace (while working):**
- NEVER render rubric matrix inline in workspace
- Button *"ℹ️ Xem Tiêu chí"* at corner of essay text editor
- Tap → Bottom Sheet slides up (Mobile) / Side-panel or Popover (Web)
- Student closes sheet, continues writing — workspace state preserved, autosave NOT interrupted

**Giai đoạn 3 — Review screen (after grading) — Foundation only:**
- `ReadOnlyRubricViewer` renders full criteria + all levels
- Shows teacher-assigned score per criterion
- AI level highlight + rationale display = **placeholder, deferred to Phase 6** (requires `ai_evaluations.criteria_scores`)

**Architecture:** Single `ReadOnlyRubricViewer` Dumb Component:
- Input: `rubric` JSONB from `assignment_questions.rubric`
- Optional input: `selectedLevels` map (for Review screen)
- Used in all 3 locations — write once, place anywhere

### D-04: Teacher Grading Interaction — Click Level + Override with Reason

**CHỐT: Hybrid — Click-to-select level (happy path) + override with mandatory reason (exception path)**

**Happy Path (95%):**
- Teacher sees rubric criteria as clickable level cards
- Tap level card → auto-fills `score/max_points` for that criterion
- Selected level is visually highlighted
- Score calculated from selected levels across all criteria

**Exception Path (5%):**
- Edit icon (pencil) next to filled score
- Tap → custom number input enabled
- System allows custom score BUT **mandatorily prompts for "Lý do ghi đè"** text input
- Override written to `grade_overrides`: `old_score`, `new_score`, `reason`
- `reason` feeds Phase 6 RLHF fine-tuning pipeline

**Rationale:** Rubric enforces consistent calibrated grading. Override exists for pedagogical exceptions but leaves audit trail. "UI dictates behavior" — if teacher needs a new score point, proper flow is to edit the rubric, not override individual submissions.

### D-05: Rubric Template Reuse — profiles.metadata JSONB (NOT new table)

**CHỐT: Store saved rubrics in `profiles.metadata['saved_rubrics']` array**

- No new table, no DB migration
- Two buttons in `RubricBuilderComponent`:
  - **"Lưu thành Template"** → `UPDATE profiles SET metadata = jsonb_set(metadata, '{saved_rubrics}', ...)`
  - **"Load from template"** → read `profiles.metadata['saved_rubrics']` array, pick one, fill form
- Templates are per-teacher (scoped by `auth.uid()`)
- Template entry structure: `{ "name": "Rubric Tự luận Toán", "rubric": {...} }`
- Rationale: JSONB column in `profiles` was designed for personal settings/preferences. Rubric templates are user-scoped, never need JOINs or GROUP BY — JSONB is the right tool.

### D-06: Points Auto-Sync — Rubric is Single Source of Truth

**CHỐT: AUTO-SYNC + HARD BLOCK**

- For `essay` and `short_answer` questions **with rubric configured**: `assignment_questions.points` field in Question Editor is **disabled (locked/greyed out)**
- `points` auto-calculated: `criteria.reduce((sum, c) => sum + c.max_points, 0)`
- When rubric is removed entirely → `points` field unblocks → returns to manual input
- Backend validation: if `assignment_questions.points != sum(criteria[].max_points)` → HTTP 400 Bad Request
- Rationale: Prevents data inconsistency where AI grades 8/8 (100%) but system has `points = 10`, causing wrong `final_score`

### D-07: Rubric Applies to Both essay AND short_answer

**CHỐT: Both `QuestionType.essay` and `QuestionType.shortAnswer` trigger rubric builder**

- AI grading (Phase 6) uses rubric for both types — no distinction in `ai_queue` worker
- `short_answer` can use minimal rubric: 1 criterion ("Mức độ chính xác") + 2 levels (đúng/sai)
- Consistent with existing codebase pattern: `essay || shortAnswer` already grouped together throughout

### D-08: Validation — Lifecycle-Aware (Draft bypass, Publish hard block)

**CHỐT: Contextual validation based on `is_published` flag — NOT static endpoint validation**

**Save Draft (`is_published = false`):**
- Backend BYPASSES all rubric validation
- `rubric = null`, empty criteria, incomplete levels → all allowed
- Teacher preserves in-progress work freely
- Rationale: "Bản thảo giấy" — forcing perfection on drafts is a UX crime

**Publish / Distribute (`is_published = true` or `assignment_distributions.status = 'active'`):**
- Backend erects full validation wall:

| Rule | Constraint |
|------|-----------|
| Min criteria per rubric | 1 |
| Min levels per criterion | 2 (must have max-points level AND 0-point level) |
| Essay/short_answer with no rubric | **HARD BLOCK** — HTTP 400 Bad Request |

- Frontend highlights the offending question(s) in red on publish attempt
- Backend DTO is second enforcement layer
- Existing assignments with `rubric = null` NOT retroactively blocked

### D-09: Rubric Edit Lock — Conditional Disable After Work Sessions Exist

**CHỐT: Rubric locked (read-only) when `COUNT(work_sessions) > 0` for this assignment**

**Lock condition (frontend checks before rendering RubricBuilderComponent):**
1. Query `assignment_distributions` — has any `status = 'active'` for this assignment?
2. Query `work_sessions` — `COUNT(work_sessions.id) WHERE assignment_id = X > 0`?
3. If either true → entire rubric form is **disabled (greyed out, read-only)**

**Escape hatch for teacher:** Clone assignment → edit rubric on new copy → create new distribution. NEVER edit-in-place on live data.

**Rationale:** `ai_evaluations.rationale` references `criteria_id` from rubric at grading time. Changing rubric descriptions post-grading = semantic data corruption. AI rationale points to one description, Review screen shows another → perceived hallucination.

### Claude's Discretion
- Animation/transitions for bottom sheet open/close
- Empty state for rubric builder (first criterion prompt)
- Level card visual design (color, border, check icon when selected)
- Template picker UI (list vs grid)
- Which level is pre-selected as "0-point floor" in new rubric creation

</decisions>

<specifics>
## Specific Ideas

- **"Bản Án và Thước Cặp" model:** Rubric is a 2D matrix — Chiều dọc = Criteria, Chiều ngang = Levels, each cell = Description text. This mental model should guide the builder UI layout.
- **"Đường ray + Vô lăng khẩn cấp" model:** Click-to-select level is the train track (fast, consistent). Override with reason is the emergency steering wheel (flexible, but leaves audit trail).
- **"Luật Chơi Khép Kín" model:** Student sees rubric before, during, and after — closed loop rulebook. They always know what they're being graded on.
- **Mobile-first:** Bottom Sheet is the primary interaction pattern for both teacher builder and student viewer. Full-screen on mobile, side panel on web (future).
- **Summary button in question editor:** *"Rubric: Đã cấu hình 3 tiêu chí (Nhấn để sửa)"* — smart status indicator, not just an "Add" button.

</specifics>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Database Schema
- `db/schema_02_questions_assignments.sql` §rubric column (line 122) — `assignment_questions.rubric jsonb` definition and JSONB matrix structure comment (lines 169–182)
- `db/schema_03_submissions_ai_analytics.sql` §grade_overrides — Override table structure with `old_score`, `new_score`, `reason` columns
- `db/schema_01_core_users_classes.sql` §profiles — `profiles.metadata jsonb` column for template storage

### Requirements
- `.planning/REQUIREMENTS.md` — RUB-01 to RUB-04 acceptance criteria

### Architecture & Patterns
- `.planning/PROJECT.md` — Clean Architecture layers, submission workflow (6-step flow), SSOT patterns
- `.planning/phases/02-teacher-grading-workflow/02-CONTEXT.md` — Human-in-the-loop, Side-by-Side grading, Skepticism Thermometer, ATC patterns (grading UI context)
- `.planning/phases/06-ai-grading/06-CONTEXT.md` — AI queue payload structure, `ai_evaluations` schema (Phase 6 integration points)

### Existing Code
- `lib/domain/entities/assignment_question.dart` — `AssignmentQuestion` entity with `rubric` field
- `lib/domain/usecases/assignment_usecases.dart` lines 72, 132 — rubric passthrough in save flow
- `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` line 758 — rubric in RPC payload
- `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart` lines 80–102 — existing partial read-only rubric display (to extend/replace with `ReadOnlyRubricViewer`)

### Design System
- `memory-bank/DESIGN_SYSTEM_GUIDE.md` — Design tokens (DesignColors, DesignSpacing, DesignTypography, DesignRadius)
- `lib/core/constants/design_tokens.dart` — Token definitions

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AssignmentQuestion.rubric` field: Already in entity, already passed through to RPC — no data layer changes needed
- `question_answer_card.dart._buildRubric()`: Partial implementation exists — read, understand, then replace with `ReadOnlyRubricViewer`
- `grade_overrides` table: Already exists (migration `21_update_grade_overrides_constraints.sql`) — Phase 3 can write to it directly
- `profiles.metadata` column: Already exists — ready for `saved_rubrics` array

### Established Patterns
- Riverpod `@riverpod` annotation for all state (NEVER `StateNotifierProvider`)
- Bottom Sheet via `showModalBottomSheet` — used in Phase 2 grading
- Freezed models for entities
- Design tokens for all styling (NEVER raw `Color(0xFF...)` or `EdgeInsets.all(16)`)
- `AppLogger` not `print()`
- `flutter analyze` must pass with 0 errors before commit

### Integration Points
- **Question editor:** `lib/presentation/views/assignment/teacher/widgets/create_question/` — add rubric section/button for essay type
- **Teacher grading:** `lib/presentation/views/assignment/teacher/widgets/submission/question_answer_card.dart` — extend with interactive level cards
- **Student workspace:** `lib/presentation/views/assignment/student/` — add "Xem Tiêu chí" button for essay questions
- **Student assignment detail:** `lib/presentation/views/assignment/student/` — add rubric preview section
- **Routes:** `lib/core/routes/route_constants.dart` + `app_router.dart` — may need route for rubric builder if push navigation chosen over bottom sheet
- **Profiles datasource:** `lib/data/datasources/` — extend for `metadata.saved_rubrics` read/write

</code_context>

<deferred>
## Deferred Ideas

- **AI level highlight on Review screen** — Requires `ai_evaluations.criteria_scores` from Phase 6. `ReadOnlyRubricViewer` will have `selectedLevels` param ready, Phase 6 fills it in.
- **Real-time rubric co-editing** — Future enhancement
- **Rubric analytics (which levels teachers pick most)** — Future phase
- **Rubric sharing between teachers** — Future phase
- **Web Side-panel implementation** — Mobile is primary. Web side-panel noted for future platform expansion.
- **Peer rubric review** — Students compare each other's rubric scores (anonymized) — future

</deferred>

---

*Phase: 03-rubric-system*
*Context gathered: 2026-04-06*
