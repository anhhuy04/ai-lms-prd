# Roadmap: AI LMS PRD

**Created:** 2026-03-05
**Core Value:** Efficiently manage the complete assignment lifecycle: teachers create -> distribute -> students complete -> AI grades -> analytics provide insights

---

## Phase 1: Student Assignment Workflow COMPLETE

**Goal:** Enable students to view and complete assignments

**Status:** UAT Complete - All tests passed

**Plans:**
3/3 plans complete
- [x] 01-PLAN.md -- List view, detail view, routing, Submission entity
- [x] 02-PLAN.md -- Workspace, auto-save, file upload, submission
- [x] 03-PLAN.md -- Gap closure: fix assignment detail & workspace navigation
- [x] 04-PLAN.md -- Gap closure: add file upload UI, fix submit success screen
- [x] 05-PLAN.md -- Gap closure: add navigation to submission history screen

---

## Phase 2: Teacher Grading Workflow COMPLETE

**Goal:** Enable teachers to view submissions and grade student work

**Requirements:**
- TEA-01 to TEA-06

**Mô hình tư duy:**
- ATC (Air Traffic Control): Dashboard nhin luot biet van de
- Side-by-Side: Cot trai bai lam, cot phai dap an
- Human-in-the-loop: AI la assistant, teacher final approver
- Stage Curtain: Diem chi hien khi Publish
- Focus Lens: Mobile dung Bottom Sheet
- Skepticism Thermometer: AI confidence < 0.7 -> vang canh bao

**Tasks (6):**
1. Teacher Submission List (ATC Dashboard)
2. Submission Detail (Side-by-Side / Bottom Sheet)
3. Grading Interface (Human-in-the-loop)
4. Grade Override Audit Trail
5. Publish Grades (Stage Curtain)
6. Quick Navigation

**Status:** UAT Complete - 9/9 tests passed

---

## Phase 3: Rubric System

**Goal:** Enable teachers to create and apply rubrics for grading

**Requirements:**
- RUB-01 to RUB-04

**Success Criteria:**
1. Rubric builder UI functional
2. Rubric can be attached to assignments
3. Scoring calculation accurate

**Plans:** 10 plans in 4 waves
- [ ] 03-PLAN-ReadOnlyRubricViewer.md -- Dumb reusable rubric display component (compact + full modes)
- [ ] 03-PLAN-RubricSummaryButton.md -- Status indicator button for question editor (empty/configured/locked)
- [ ] 03-PLAN-RubricTemplateDatasource.md -- Template CRUD via profiles.metadata JSONB
- [ ] 03-PLAN-RubricBuilderComponent.md -- Full-screen bottom sheet rubric editor
- [ ] 03-PLAN-RubricTemplatePickerSheet.md -- Template selection bottom sheet
- [ ] 03-PLAN-InteractiveRubricGrader.md -- Clickable level cards for teacher grading
- [ ] 03-PLAN-TeacherCreateAssignmentScreen.md -- Rubric integration in question editor + publish validation
- [ ] 03-PLAN-QuestionAnswerCard.md -- Replace old _buildRubric with new widgets
- [ ] 03-PLAN-StudentWorkspaceScreen.md -- "Xem Tieu chi" button + bottom sheet
- [ ] 03-PLAN-StudentAssignmentDetailScreen.md -- Rubric preview cards with expand/collapse

---

## Phase 4: Learning Analytics COMPLETE

**Goal:** Provide actionable insights on student learning progress

**Requirements:**
- ANL-01 to ANL-04

**Success Criteria:**
1. Student analytics dashboard displays performance
2. Teacher class analytics show aggregate data
3. Trends visualized correctly

**Plans:**
3/3 plans complete
- [x] 04-01-PLAN.md -- Data Layer: Entities, Datasource, Providers
- [x] 04-02-PLAN.md -- Student Analytics Dashboard UI
- [x] 04-03-PLAN.md -- Teacher Analytics Dashboard UI

---

## Phase 5: Personalized Recommendations

**Goal:** Guide students and teachers with intelligent suggestions

**Requirements:**
- REC-01 to REC-03

**Success Criteria:**
1. Teacher sees intervention suggestions for struggling students
2. Student sees personalized learning resources
3. Peer comparison data available

**Plans:**
4/4 plans
- [x] 05-01-PLAN.md -- Data Layer: Recommendation entity, datasource, repository, providers
- [x] 05-02-PLAN.md -- UI Layer: Widgets, Screens, Dashboard integration, Peer comparison
- [x] 05-03-PLAN.md -- Gap closure: Add "Hoc tap" recommendations section (superseded by 05-04)
- [ ] 05-04-PLAN.md -- Gap closure (UAT): Fix missing "Hoc tap" entry-point, routes, dismiss pattern

---

## Phase 6: AI Grading ⏸ MERGED INTO PHASE 7

> Context da duoc tich hop vao Phase 7. Infrastructure (ai_queue worker, ai_evaluations) se duoc build trong Phase 7.
> Essay-specific AI grading (rubric scoring) defer den khi Phase 3 duoc re-enabled.

**Context:**
- [x] 06-CONTEXT.md (reference only)

---

## Phase 7: AI Analytics Pipeline

**Goal:** Dam bao pipeline du lieu tu "hoc sinh nop bai" -> "analytics co data thuc" hoat dong end-to-end. Build AI queue infrastructure san cho tuong lai.

**Quy tac:** Tinh nang anh huong MCQ (trac nghiem) -> lam ngay. Tinh nang thuan essay -> defer.

**Requirements:**
- 7-01: Skill Mastery Write Pipeline
- 7-02: Question Stats Pipeline
- 7-03: Submission Analytics
- 7-04: Grade Override verification + push notification
- 7-05: AI Queue Edge Function
- 7-06: Phase 4 UAT Closure
- 7-07: AI Recommendations Generation
- 7-08: AI Feedback cho MCQ
- 7-09: Phase 5 UAT + VERIFICATION Closure
- 7-10: Phase 2 UAT Closure
- 7-11: AI Grading Toggle

**Plans:** 3/11 plans executed

Plans:
- [x] 07-01-PLAN.md -- Skill mastery AFTER INSERT trigger on submission_answers (7-01)
- [x] 07-02-PLAN.md -- Question stats AFTER INSERT trigger on submission_answers (7-02)
- [x] 07-03-PLAN.md -- work_sessions AI status + in_app_notifications + grade_override notification (7-11, 7-04)
- [ ] 07-04-PLAN.md -- Submission analytics: per-question timer + non-blocking INSERT (7-03)
- [ ] 07-05-PLAN.md -- Phase 2 UAT closure: Filter by Status fix + grade override verify (7-10)
- [ ] 07-06-PLAN.md -- AI Queue Edge Function skeleton: feedback + analysis + score stub (7-05)
- [x] 07-07-PLAN.md -- Phase 4 UAT closure: re-test 7 skipped tests with real data (7-06)
- [ ] 07-08-PLAN.md -- ai_queue wiring: feedback + analysis INSERT in submitAssignment (7-07, 7-08)
- [ ] 07-09-PLAN.md -- Phase 5 UAT + VERIFICATION closure: RPC + route + dismiss fix (7-09)
- [ ] 07-10-PLAN.md -- Flutter 7-11b: SubmissionStatus enum extension + Distribution UI AI toggle (7-11b)
- [ ] 07-11-PLAN.md -- SubmissionStatus UI Update: teacher/student badges + filter chip Chờ duyệt AI (7-12)

**Success Criteria:**
1. Student submit MCQ -> `student_skill_mastery` co record moi ngay sau submit
2. Phase 4 Analytics screen hien thi du lieu thuc (khong rong)
3. Phase 5 Recommendations dua tren skill gaps thuc
4. Teacher override diem -> record trong `grade_overrides` ton tai
5. `ai_queue` Edge Function deploy thanh cong (du chua co essay data)

**Deferred (essay re-enable sau):**
- Rubric-based AI scoring
- `ai_evaluations.criteria_scores` display
- AI grading UI cho cau tu luan

**Context:**
- [x] 07-CONTEXT.md

---

---

## Phase 8: Shuffle, Hotfix & Reuse COMPLETE

**Goal:** Hardening submit flow, server-side timing, shuffle wiring, deep clone & reuse

**Status:** Code complete — pending manual end-to-end testing

---

## Phase 9: AI Settings Refactor & Document Import

**Goal:** Cải thiện trải nghiệm tạo câu hỏi AI — refactor trang cài đặt AI và thêm tính năng import tài liệu (Excel/Word) để AI tự động phân tích và sinh câu hỏi

**Requirements:**
- 9-01: AI Settings Screen — chỉ hiện các settings liên quan đến AI (tạo câu hỏi), loại bỏ phần không liên quan
- 9-02: Document Upload — giáo viên upload file Excel/Word
- 9-03: AI phân tích tài liệu và sinh câu hỏi theo form mẫu hoặc extract câu hỏi có sẵn

**Success Criteria:**
1. Trang cài đặt AI (gear icon) chỉ hiển thị config liên quan đến AI tạo câu hỏi
2. Giáo viên có thể upload file Excel/Word từ màn hình tạo câu hỏi AI
3. AI phân tích tài liệu và trả về danh sách câu hỏi có thể lưu vào Question Bank

**Plans:** 6/8 plans executed

Plans:
- [x] 09-00-PLAN.md — Wave 0 test stubs (5 files: unit, widget, Edge Function)
- [x] 09-01-PLAN.md — DB Migrations 011-013: pgvector (768-dim), document_chunks, ai_queue constraint, Storage bucket, save_questions_to_assignment RPC
- [x] 09-02-PLAN.md — file_picker approval checkpoint + install (autonomous: false)
- [x] 09-03-PLAN.md — AiQuestionSettingsScreen + aiQuestionSettings route + gear icon fix (9-01)
- [x] 09-04-PLAN.md — TeacherFileDataSource + TeacherFileRepositoryImpl + teacherFilesProvider (9-02)
- [x] 09-05-PLAN.md — ContextSourcesSection widget + AI mode toggle + AiQuestionSettingsScreen doc library (9-02)
- [x] 09-06-PLAN.md — process-document-queue Edge Function: heuristic router, Gemini embedding 768-dim, checkpointing (D-29), content hashing (D-30) (9-03)
- [ ] 09-07-PLAN.md — StagingAreaWidget (DraggableScrollableSheet) + QuestionDTO + save_questions_to_assignment wiring (9-03)

---

*Roadmap created: 2026-03-05*
*Last updated: 2026-04-19 - Phase 9: 8 plans created*
