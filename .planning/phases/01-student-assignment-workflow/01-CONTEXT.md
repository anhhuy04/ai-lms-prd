# Phase 1: Student Assignment Workflow - Context

**Gathered:** 2026-03-05
**Status:** Ready for planning

<domain>
## Phase Boundary

Enable students to view and complete assignments. This includes:
- Assignment list view
- Assignment detail view with questions
- Workspace for completing assignments
- Auto-save draft answers
- File upload capability
- Submission with confirmation
- Submission history view

This is the core student-facing workflow that completes the assignment lifecycle.

</domain>

<decisions>
## Implementation Decisions

### Student Assignment List
- Card-based layout (reuse existing AssignmentCard pattern)
- Show: title, subject, due date, status badge, completion %
- Sort by: due date (nearest first)
- Filter by: status (all/pending/submitted/graded)

### Assignment Detail View
- Scrollable question list (not wizard/stepper)
- Each question shows: number, content, type icon, points
- Expandable for essay questions to show text field
- Due date and time remaining prominently displayed

### Workspace (Core Feature)
- Single scrollable page with all questions
- Question types supported:
  - Multiple choice: Radio buttons with options
  - True/False: Toggle buttons
  - Essay: Multi-line text field
  - Fill-in-blank: Text fields
- Progress indicator at top (X/Y questions answered)

### Auto-Save
- Debounce: 2 seconds after last keystroke
- Backend save via API (existing endpoint)
- Local backup via SharedPreferences as safety net
- Status indicator: "Saving..." → "Saved" → hidden

### File Upload
- Supported types: images (jpg, png), PDF, documents
- Max file size: 10MB per file
- Max files per submission: 5
- Upload progress indicator
- Preview thumbnails after upload

### Submission
- Confirmation dialog before final submit
- Disable submit button during submission (prevent race condition)
- Success screen with: timestamp, confirmation number
- Option to view submitted work

### Submission History
- List view of past submissions
- Show: assignment name, submitted date, score (if graded)
- Tap to view full submission details

</decisions>

<specifics>
## Specific Ideas

- Reuse existing AssignmentCard component for list items
- Follow existing LoadingStates pattern (ShimmerListTileLoading)
- Use DesignTokens consistently (colors, spacing, typography)
- Auto-save pattern: easy_debounce package already in project

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- AssignmentCard, AssignmentList, AssignmentListView: Reusable for student assignment list
- ShimmerListTileLoading: For loading states
- DesignTokens: DesignColors, DesignSpacing, DesignTypography

### Established Patterns
- Riverpod with @riverpod annotation
- ConsumerStatefulWidget for screens
- ref.watch() for reactive state, ref.read() for callbacks

### Integration Points
- Routes: Add to student routes in route_constants.dart
- Providers: Create student_assignment_providers.dart
- Entities: Need Submission entity (not yet created)

</code_context>

<deferred>
## Deferred Ideas

- AI-generated suggestions for answers — Phase 5
- Offline mode with sync queue — future enhancement
- Push notifications for new assignments — future enhancement

</deferred>

---

*Phase: 01-student-assignment-workflow*
*Context gathered: 2026-03-05*
