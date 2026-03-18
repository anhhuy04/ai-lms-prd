# Roadmap: AI LMS PRD

**Created:** 2026-03-05
**Core Value:** Efficiently manage the complete assignment lifecycle: teachers create → distribute → students complete → AI grades → analytics provide insights

---

## Phase 1: Student Assignment Workflow ✅ COMPLETE

**Goal:** Enable students to view and complete assignments

**Status:** UAT Complete - All tests passed

**Plans:**
- [x] 01-PLAN.md — List view, detail view, routing, Submission entity
- [x] 02-PLAN.md — Workspace, auto-save, file upload, submission
- [x] 03-PLAN.md — Gap closure: fix assignment detail & workspace navigation
- [x] 04-PLAN.md — Gap closure: add file upload UI, fix submit success screen
- [x] 05-PLAN.md — Gap closure: add navigation to submission history screen

---

## Phase 2: Teacher Grading Workflow ✅ PLANNED

**Goal:** Enable teachers to view submissions and grade student work

**Requirements:**
- TEA-01 to TEA-06

**Mô hình tư duy:**
- ATC (Air Traffic Control): Dashboard nhìn lướt biết vấn đề
- Side-by-Side: Cột trái bài làm, cột phải đáp án
- Human-in-the-loop: AI là assistant, teacher final approver
- Stage Curtain: Điểm chỉ hiện khi Publish
- Focus Lens: Mobile dùng Bottom Sheet
- Skepticism Thermometer: AI confidence < 0.7 → vàng cảnh báo

**Tasks (6):**
1. Teacher Submission List (ATC Dashboard)
2. Submission Detail (Side-by-Side / Bottom Sheet)
3. Grading Interface (Human-in-the-loop)
4. Grade Override Audit Trail
5. Publish Grades (Stage Curtain)
6. Quick Navigation

**Status:** Ready to execute

---

## Phase 3: Rubric System

**Goal:** Enable teachers to create and apply rubrics for grading

**Requirements:**
- RUB-01 to RUB-04

**Success Criteria:**
1. Rubric builder UI functional
2. Rubric can be attached to assignments
3. Scoring calculation accurate

---

## Phase 4: Learning Analytics

**Goal:** Provide actionable insights on student learning progress

**Requirements:**
- ANL-01 to ANL-04

**Success Criteria:**
1. Student analytics dashboard displays performance
2. Teacher class analytics show aggregate data
3. Trends visualized correctly

**Plans:**
- [x] 04-01-PLAN.md — Data Layer: Entities, Datasource, Providers
- [x] 04-02-PLAN.md — Student Analytics Dashboard UI
- [x] 04-03-PLAN.md — Teacher Analytics Dashboard UI

---

## Phase 5: Personalized Recommendations

**Goal:** Guide students and teachers with intelligent suggestions

**Requirements:**
- REC-01 to REC-03

**Success Criteria:**
1. Teacher sees intervention suggestions for struggling students
2. Student sees personalized learning resources
3. Peer comparison data available

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
*Last updated: 2026-03-18 - Phase 4 plans added (04-01, 04-02, 04-03)*
