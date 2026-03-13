# Phase 2: Teacher Grading Workflow - Research

**Researched:** 2026-03-13
**Domain:** Flutter LMS - Teacher Grading Workflow
**Confidence:** HIGH

## Summary

Phase 2 implemented a complete Teacher Grading Workflow with 6 tasks: ATC Dashboard, Side-by-Side Layout, Grading Interface, Grade Override Audit Trail, Publish Grades (Stage Curtain), and Quick Navigation. The implementation follows Clean Architecture with Riverpod state management and integrates with existing Supabase database schema.

**Primary recommendation:** Phase 2 implementation is complete and verified. All requirements (TEA-01 to TEA-06) have been implemented.

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions
- Entry: From Assignment Management → select assignment → View submissions
- Flow: Assignment → Class list with stats → Student list
- ATC Dashboard: Class selection with stats (submitted / not submitted / late)
- Filter: Tab-based with counts + secondary filters (search, date, late)
- Sort: Bottom Sheet with multiple sort options
- Grading Layout: Desktop side-by-side / Mobile bottom sheet
- AI Confidence: < 70% → yellow background + warning text
- Feedback: Separate AI feedback (read-only) + Teacher feedback (editable)
- Publish: Stage Curtain model - grades hidden until teacher publishes

### Claude's Discretion
- Auto-advance to next submission after grading (deferred)
- Auto-save local for feedback input (deferred)

### Deferred Ideas (OUT OF SCOPE)
- Auto-advance to next submission after grading
- Auto-save local for feedback input
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-------------------|
| TEA-01 | View list of submissions for an assignment | ATC Dashboard with class/student filtering |
| TEA-02 | View student submission details | Side-by-Side / Bottom Sheet layout |
| TEA-03 | Grade objective questions (auto-graded) | Read-only MCQ with override option |
| TEA-04 | Grade essay questions manually | AI preliminary score + teacher override |
| TEA-05 | Provide feedback for each question | AI feedback (read-only) + Teacher feedback (editable) |
| TEA-06 | Override AI-assigned grades | Override button + grade_overrides table audit |
</phase_requirements>

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_riverpod | ^2.5.1 | State management | Required by project |
| go_router | ^14.0.0 | Navigation | Required by project |
| freezed | ^2.4.0 | Immutable models | Required by project |
| json_serializable | ^6.7.0 | JSON serialization | Required by project |

### Supporting
| Library | Purpose | When to Use |
|---------|---------|-------------|
| shimmer | Loading states | Skeleton loading for submission lists |
| flutter_screenutil | Responsive sizing | All UI sizing |
| DesignTokens | Colors, spacing, typography | Consistent design system |

**Installation:**
```bash
# Already in pubspec.yaml - no new packages needed
flutter pub get
```

## Architecture Patterns

### Recommended Project Structure
```
lib/
├── data/
│   ├── datasources/
│   │   ├── submission_datasource.dart
│   │   └── grade_override_datasource.dart
│   └── repositories/
│       └── submission_repository_impl.dart
├── domain/
│   └── repositories/
│       ├── submission_repository.dart
│       └── grade_override_repository.dart
└── presentation/
    ├── providers/
    │   └── teacher_submission_providers.dart
    └── views/assignment/teacher/
        ├── teacher_submission_list_screen.dart
        ├── teacher_submission_detail_screen.dart
        └── widgets/submission/
            ├── submission_filter_chips.dart
            ├── submission_list_item.dart
            ├── ai_confidence_indicator.dart
            ├── grading_action_buttons.dart
            ├── question_answer_card.dart
            └── teacher_feedback_editor.dart
```

### Pattern 1: ATC Dashboard (Air Traffic Control)
**What:** Teacher sees submissions organized by class with stats (submitted/not submitted/late counts)
**When to use:** Entry point for grading workflow
**Example:**
```dart
// Source: teacher_submission_list_screen.dart
class TeacherSubmissionListScreen extends ConsumerWidget {
  // Stats per class: submitted / not_submitted / late
  // Filter by status tabs
}
```

### Pattern 2: Side-by-Side / Bottom Sheet
**What:** Desktop shows 2 columns (student work | answer key), Mobile shows bottom sheet
**When to use:** Submission detail view
**Example:**
```dart
// Source: teacher_submission_detail_screen.dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return Row(children: [studentColumn, answerColumn]);
    }
    return BottomSheetLayout();
  }
)
```

### Pattern 3: Skepticism Thermometer
**What:** AI confidence indicator with visual warning when < 0.7
**When to use:** Displaying AI-generated scores
**Example:**
```dart
// Source: ai_confidence_indicator.dart
if (aiConfidence < 0.7) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: DesignColors.warning),
    ),
    child: Text('AI phân vân - Yêu cầu kiểm tra kỹ'),
  );
}
```

### Pattern 4: Human-in-the-Loop
**What:** Teacher approves or overrides AI scores
**When to use:** Grading interface
**Example:**
```dart
// Source: grading_action_buttons.dart
// Approve: Use AI score directly
// Override: Insert into grade_overrides table with old_score, new_score, reason
```

### Anti-Patterns to Avoid
- **Missing Publish button:** Grades must NOT be visible to students until teacher explicitly publishes
- **Overwriting AI feedback:** Store teacher feedback in separate column, don't overwrite ai_feedback
- **No audit trail:** Every override must be logged to grade_overrides table

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Grade override logging | Custom audit table | `grade_overrides` table | Already exists with proper schema |
| AI confidence display | Custom calculation | `ai_confidence` column from DB | Stored on submission_answers |
| Feedback storage | Single column | Separate `ai_feedback` + `teacher_feedback` columns | Preserves AI feedback for review |

**Key insight:** The database schema already supports all grading requirements - leverage existing tables and columns.

## Common Pitfalls

### Pitfall 1: Missing Publish Button
**What goes wrong:** Students can see grades before teacher approves
**Why it happens:** Forgetting to implement Stage Curtain model
**How to avoid:** Always require explicit "Publish" action to change work_sessions.status to 'graded'
**Warning signs:** Students seeing grades in real-time before teacher review

### Pitfall 2: Overwriting AI Feedback
**What goes wrong:** Original AI feedback lost when teacher edits
**Why it happens:** Using single feedback column
**How to avoid:** Use separate `teacher_feedback` column, keep `ai_feedback` read-only
**Warning signs:** Cannot review what AI originally scored

### Pitfall 3: No Override Audit
**What goes wrong:** No record of grade changes for accountability
**Why it happens:** Skipping grade_overrides table usage
**How to avoid:** Always log overrides with old_score, new_score, reason, overridden_by
**Warning signs:** Missing audit trail for grade disputes

### Pitfall 4: Ignoring AI Confidence
**What goes wrong:** Teacher trusts low-confidence AI scores
**Why it happens:** Not displaying confidence indicator
**How to avoid:** Always show confidence, highlight < 0.7 with warning
**Warning signs:** AI confidence column exists but not displayed

## Code Examples

Verified patterns from implementation:

### ATC Dashboard Filter Chips
```dart
// Source: submission_filter_chips.dart
Row(
  children: [
    FilterChip(label: 'Tất cả (${allCount})', selected: filter == 'all'),
    FilterChip(label: 'Chưa chấm (${pendingCount})', selected: filter == 'pending'),
    FilterChip(label: 'Đã chấm (${gradedCount})', selected: filter == 'graded'),
    FilterChip(label: 'Nộp muộn (${lateCount})', selected: filter == 'late'),
  ],
)
```

### AI Confidence Indicator
```dart
// Source: ai_confidence_indicator.dart
Widget build(BuildContext context, double confidence) {
  final isLowConfidence = confidence < 0.7;
  return Container(
    decoration: isLowConfidence
        ? BoxDecoration(color: DesignColors.warning.withOpacity(0.1))
        : null,
    child: Column(
      children: [
        LinearProgressIndicator(value: confidence),
        if (isLowConfidence)
          Text('AI phân vân - Yêu cầu kiểm tra kỹ',
               style: TextStyle(color: DesignColors.warning)),
      ],
    ),
  );
}
```

### Grade Override with Audit
```dart
// Source: grade_override_datasource.dart
Future<void> overrideGrade({
  required String submissionAnswerId,
  required double oldScore,
  required double newScore,
  required String reason,
}) async {
  // Insert into grade_overrides table
  await supabase.from('grade_overrides').insert({
    'submission_answer_id': submissionAnswerId,
    'overridden_by': authUid,
    'old_score': oldScore,
    'new_score': newScore,
    'reason': reason,
  });
}
```

### Publish Grades (Stage Curtain)
```dart
// Source: submission_datasource.dart
Future<void> publishGrades(String assignmentDistributionId) async {
  await supabase.from('work_sessions').update({
    'status': 'graded'
  }).eq('assignment_distribution_id', assignmentDistributionId);
  // Supabase Realtime will notify students
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Real-time grade visibility | Stage Curtain (publish required) | Phase 2 | Students only see grades after teacher publishes |
| Single feedback column | Separate ai_feedback + teacher_feedback | Phase 2 | Preserves AI feedback for review |
| No override tracking | grade_overrides audit table | Phase 2 | Full accountability for grade changes |
| Hidden AI confidence | Skepticism Thermometer display | Phase 2 | Teachers aware of AI uncertainty |

**Deprecated/outdated:**
- Direct grade editing without audit (replaced by grade_overrides table)
- Single feedback storage (replaced by dual columns)

## Open Questions

1. **Supabase Realtime integration**
   - What we know: Student app should subscribe to work_sessions changes
   - What's unclear: Whether realtime is actually configured
   - Recommendation: Verify realtime subscription in student app

2. **Notification system**
   - What we know: Teachers can publish grades
   - What's unclear: How students are notified of new grades
   - Recommendation: Implement push notifications or in-app notification

## Sources

### Primary (HIGH confidence)
- Implementation files in lib/presentation/views/assignment/teacher/
- Database schema in db/13_create_remaining_tables.sql
- CONTEXT.md decisions from planning phase

### Secondary (MEDIUM confidence)
- Project CLAUDE.md for architecture standards
- ROADMAP.md for phase progression

---

## Metadata

**Confidence breakdown:**
- Standard Stack: HIGH - Using existing project libraries
- Architecture: HIGH - Clean Architecture with Riverpod
- Pitfalls: HIGH - All anti-patterns documented from implementation

**Research date:** 2026-03-13
**Valid until:** Phase 2 is complete, research serves as documentation
