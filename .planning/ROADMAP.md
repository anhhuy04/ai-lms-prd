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

## Phase 6: AI Grading (FINAL PHASE)

**Goal:** Implement AI-powered grading system

**Requirements:**
- AI Queue management
- AI Evaluation storage
- Grade Override functionality
- RLHF data collection

**Success Criteria:**
1. Submissions automatically queued for AI grading
2. AI scores stored with model info and rationale
3. Teacher can override AI grades
4. Override data collected for model improvement

**Context:**
- [x] 06-CONTEXT.md

---

*Roadmap created: 2026-03-05*
*Last updated: 2026-04-06 - Phase 3 rubric system planned (10 plans, 4 waves)*
