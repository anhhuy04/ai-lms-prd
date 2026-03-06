# Context for Next Session - AI LMS PRD

## Current Status
**Date:** 2026-03-05
**Phase:** 1 - Student Assignment Workflow (Ready to Execute)

## What Has Been Done

### GSD Workflow Completed:
- ✅ PROJECT.md created
- ✅ REQUIREMENTS.md created
- ✅ ROADMAP.md created (5 phases)
- ✅ config.json created (YOLO mode)
- ✅ Research completed (SUMMARY.md)
- ✅ Phase 1 CONTEXT.md created
- ✅ Phase 1 PLANS created (2 plans, 2 waves)

### Key Decisions (From Discussion):

#### 1. Entities CẦN TẠO (Not in codebase yet):
- `lib/domain/entities/submission.dart` → Table: submissions
- `lib/domain/entities/work_session.dart` → Table: work_sessions
- `lib/domain/entities/submission_answer.dart` → Table: submission_answers
- `lib/domain/entities/autosave_answer.dart` → Table: autosave_answers

#### 2. Repository Interface CẦN TẠO:
- `lib/domain/repositories/submission_repository.dart` (interface)

#### 3. Screens CẦN TẠO:
```
lib/presentation/views/assignment/student/
├── student_assignment_list_screen.dart    # Tab "Bài tập" in Student Dashboard
├── student_assignment_detail_screen.dart  # Xem chi tiết bài tập
├── student_workspace_screen.dart         # Workspace làm bài
├── student_submit_confirmation_screen.dart # Xác nhận nộp
└── student_submission_history_screen.dart # Lịch sử nộp bài
```

#### 4. Routing:
- Add to `route_constants.dart`:
  - `studentAssignmentList` → /student/assignments
  - `studentAssignmentDetail` → /student/assignment/:id
  - `studentWorkspace` → /student/assignment/:id/workspace
  - `studentSubmitConfirmation` → /student/assignment/:id/submit
  - `studentSubmissionHistory` → /student/submissions

#### 5. API Design (Confirmed with User):
- `GET /my-assignments?class_id=xxx&status=pending|submitted|graded`
- `POST /work-sessions/{id}/submit` (SINGLE API - transaction wrapped)
- `POST /work-sessions` (start work session)
- `PATCH /autosave-answers` (auto-save with debounce 2s)

#### 6. Key Database Tables (from docs/note sql.txt):
- `work_sessions` - Phiên làm việc
- `autosave_answers` - Lưu tạm câu trả lời
- `submission_answers` - Câu trả lời cuối cùng
- `submissions` - Bảng tổng hợp
- `assignment_distributions` - Phân phối bài tập

## Next Session Should:

1. **Read this file first** for context
2. **Execute Phase 1** using:
   ```
   /gsd:execute-phase 1
   ```
3. **Create the 4 new entities** in `lib/domain/entities/`
4. **Create SubmissionRepository interface** in `lib/domain/repositories/`
5. **Create all 5 screens** following existing patterns
6. **Add routes** to route_constants.dart and app_router.dart
7. **Create providers** in `lib/presentation/providers/`

## Code Patterns to Follow:
- Use Riverpod with @riverpod annotation
- Use ConsumerStatefulWidget for screens
- Use DesignTokens (DesignColors, DesignSpacing, DesignTypography)
- Use ShimmerListTileLoading for loading states
- Follow existing patterns from `lib/presentation/views/assignment/teacher/`

## Important Notes:
- User confirmed: Submit is ONE API only (POST /work-sessions/{id}/submit)
- Auto-save uses 2-second debounce
- File upload: target_type = 'answer' or 'assignment'
- Student Assignment List: Global tab + filtered in Class Detail
- All new entities MUST use Freezed pattern

---

*Context saved: 2026-03-05*
