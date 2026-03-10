# AI LMS PRD - Project Context

## What This Is

AI LMS (Learning Management System) is a mobile application for digitalizing the complete assignment workflow with AI-powered grading and personalized learning recommendations. The project is 50% complete with Flutter/Supabase stack.

## Core Value

Efficiently manage the complete assignment lifecycle: teachers create → distribute → students complete → AI grades → analytics provide insights.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] **Student Assignment Workflow**
  - [ ] StudentAssignmentListScreen - Danh sách bài tập của học sinh
  - [ ] StudentAssignmentDetailScreen - Xem chi tiết bài tập
  - [ ] StudentWorkspaceScreen - Workspace làm bài (auto-save, file upload)
  - [ ] StudentSubmitConfirmationScreen - Xác nhận nộp bài

- [ ] **Teacher Grading Workflow**
  - [ ] TeacherAssignmentSubmissionsScreen - Danh sách bài nộp
  - [ ] TeacherAssignmentGradingScreen - Chấm điểm chi tiết

- [ ] **Rubric System**
  - [ ] RubricBuilderScreen - Tạo rubric chấm điểm

- [ ] **Analytics**
  - [ ] StudentAnalyticsScreen - Analytics cá nhân học sinh
  - [ ] TeacherClassAnalyticsScreen - Analytics lớp học
  - [ ] AdminAnalyticsDashboard - Tổng hợp hệ thống

- [ ] **Recommendations**
  - [ ] TeacherRecommendationsScreen - Gợi ý can thiệp cho giáo viên
  - [ ] StudentRecommendationsScreen - Gợi ý học tập cho học sinh

### Out of Scope

- Desktop/web version — mobile-first only
- Video conferencing features
- Plagiarism detection
- Parent portal
- Advanced scheduling/calendar features

## Context

### Current Status (2026-03-10)

**Đã hoàn thành (~50%):**
- ✅ Authentication: Login, Register, Splash, RBAC
- ✅ Class Management: Teacher & Student class CRUD
- ✅ Assignment Distribution: Hub, Create, Preview, AI Generate, Distribute workflow
- ✅ Student Assignment Workflow: List, Detail, Workspace (auto-save), Submit
- ✅ Auto-Grading: Synchronous MCQ/True-False scoring on submission
- ✅ Database schema: assignments, questions, distributions, submissions tables

**Cấu trúc thư mục hiện tại:**
```
lib/
├── core/           # Routes, services, utils, constants
├── data/           # Datasources, repository implementations
├── domain/         # Entities, repository interfaces
├── presentation/   # Views, providers (Riverpod)
├── widgets/        # Shared reusable widgets
└── main.dart
```

### Technology Stack

- Flutter 3.8.x + Dart 3.8.1
- Riverpod 2.5.1 (state management)
- GoRouter 14.0 (routing with RBAC)
- Supabase (backend: auth, DB, storage)
- Freezed (immutable models)
- Design Tokens (DesignColors, DesignSpacing, DesignTypography)

### Architecture Patterns

- Clean Architecture (presentation → domain → data)
- Riverpod với @riverpod annotation
- GoRouter với ShellRoute + RBAC redirect
- Repository pattern (interface in domain, impl in data)
- ShimmerLoading cho loading states

---

## Data Structure & Submission Flows

> **CRITICAL:** This section documents the canonical data model and submission workflows.
> All code MUST follow these patterns. See `.planning/sql-flow-decisions.md` for detailed SQL.

### Core Tables Relationship

```
┌─────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│   assignments   │────<│ assignment_questions  │────<│    questions    │
│                 │     │                      │     │  (question bank)│
└────────┬────────┘     └──────────┬───────────┘     └─────────────────┘
         │                         │
         │                         │
         ▼                         ▼
┌─────────────────────┐     ┌──────────────────────┐
│assignment_distributions│   │  question_choices    │
│  (SSOT for due_at)  │     │  (MCQ/True-False)   │
└──────────┬──────────┘     └──────────────────────┘
           │
           ▼
┌─────────────────┐     ┌─────────────────┐     ┌──────────────────┐
│  work_sessions  │────<│ autosave_answers │     │  submission_answers │
│  (SSOT status)  │     │    (Buffer)      │────<│    (Core)        │
└────────┬────────┘     └─────────────────┘     └────────┬─────────┘
         │                                                │
         │                                                ▼
         │                                    ┌──────────────────┐
         │                                    │   submissions    │
         │                                    │    (CQRS)        │
         └──────────────────────────────────>└──────────────────┘
```

### Answer JSON Formats

| Question Type | Student Answer Format | Correct Answer Format |
|---------------|----------------------|----------------------|
| Multiple Choice | `{"selected_choices": ["choice_id"]}` | `{"correct_choices": ["id1"]}` hoặc `{"correct_choice": "id1"}` |
| True/False | `{"selected_choices": ["true"]}` | `{"correct_choices": ["false"]}` |
| Essay | `{"text": "Nội dung..."}` | `{"keywords": [...], "sample_essay": "..."}` |
| Fill-in-Blank | `{"blank_1": "answer", "blank_2": "answer"}` | `{"blank_1": "correct", "blank_2": "correct"}` |

### Submission Workflow (6 Steps)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     SUBMIT ASSIGNMENT FLOW                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1️⃣  READ:     autosave_answers (lấy câu trả lời tạm)                  │
│         ↓                                                                   │
│  1.1  READ:   assignment_distributions (lấy due_at)                    │
│         ↓                                                                   │
│  1.2  READ:   assignment_questions + questions (lấy đáp án đúng)        │
│         ↓                                                                   │
│  2️⃣  INSERT:  submission_answers (ghi đáp án + CHẤM NGAY final_score)   │
│              - MCQ/True-False: auto-grade → final_score = points         │
│              - Essay/Fill-blank: final_score = null (chờ AI)             │
│         ↓                                                                   │
│  3️⃣  UPDATE:  work_sessions (status = 'submitted')                     │
│         ↓                                                                   │
│  4️⃣  INSERT:  submissions (biên lai CQRS)                               │
│              - total_score: tổng điểm MCQ                                │
│              - is_late: submitted_at > due_at                            │
│         ↓                                                                   │
│  5️⃣  DELETE:  autosave_answers (dọn dẹp buffer)                        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Single Source of Truth (SSOT)

| Data | SSOT Table | Rationale |
|------|------------|-----------|
| Assignment Status | `work_sessions.status` | Track in_progress → submitted → graded |
| Late Submission | `submissions.is_late` | Computed from due_at |
| Question Score | `submission_answers.final_score` | Per-question grading |
| Total Score | `submissions.total_score` | Sum of final_score |

### CQRS Pattern - submissions Table

> **RULE:** submissions table is for FAST QUERIES only. Do NOT add business logic columns.

| Column | Purpose |
|--------|---------|
| `assignment_distribution_id` | FK - links to distribution |
| `student_id` | FK - links to student |
| `session_id` | FK - links to work_sessions |
| `submitted_at` | Timestamp of submission |
| `is_late` | Boolean - computed from due_at |
| `total_score` | Sum of all final_score (MCQ + AI) |
| `ai_graded` | Boolean - true when AI grading complete |
| `created_at`, `updated_at` | Audit timestamps |

**DO NOT ADD:**
- ❌ `status` - already in work_sessions
- ❌ Question-specific data - use submission_answers

---

### Key Integration Points

- Routes: `lib/core/routes/route_constants.dart` + `app_router.dart`
- Providers: `lib/presentation/providers/`
- Entities: `lib/domain/entities/`
- Shared widgets: `lib/widgets/`
- Database: See `.planning/sql-flow-decisions.md`

## Constraints

- **Platform**: Mobile only (Android/iOS)
- **Language**: Vietnamese UI
- **Backend**: Supabase (existing schema)
- **State**: Riverpod (existing patterns)

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Riverpod for state | Project already uses Riverpod | — Pending |
| GoRouter for routing | Existing routing pattern | — Pending |
| Design Tokens | Enforce consistency | — Pending |
| Auto-save pattern | Debounce 2s + SharedPreferences | — Pending |
| File upload | Supabase Storage integration | — Pending |
| **Auto-Grading** | Sync MCQ scoring on submit | ✅ Implemented |
| **SSOT Pattern** | Status only in work_sessions | ✅ Implemented |

---

*Last updated: 2026-03-10 - Added data structure & submission flows*
