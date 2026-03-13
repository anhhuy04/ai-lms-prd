# Phase 2 - Teacher Grading Workflow: Complete Technical Documentation

**Phiên bản:** 1.1
**Ngày:** 2026-03-12
**Trạng thái:** ✅ COMPLETED + Review Fixes

---

## 1. Tổng quan Phase

**Mục tiêu:** Xây dựng hệ thống chấm bài cho giáo viên với mô hình "Human-in-the-Loop" - AI hỗ trợ, GV quyết định.

### 6 Tasks đã hoàn thành

| Task | Mô tả | Status |
|------|--------|--------|
| 1 | Teacher Submission List (ATC Dashboard) | ✅ Done |
| 2 | Submission Detail - Side-by-Side Layout | ✅ Done |
| 3 | Grading Interface - Human-in-the-Loop | ✅ Done |
| 4 | Grade Override Audit Trail | ✅ Done |
| 5 | Publish Grades (Stage Curtain) | ✅ Done |
| 6 | Quick Navigation | ✅ Done |

---

## 1.1. Review Fixes (2026-03-12)

### 5 Fixes đã hoàn thành sau code review:

| Fix # | Mô tả | Files |
|-------|--------|-------|
| #1 | Hardcoded colors → DesignTokens | submission_filter_chips.dart, submission_list_item.dart, question_answer_card.dart, grading_action_buttons.dart, teacher_feedback_editor.dart, ai_confidence_indicator.dart |
| #2 | Input validation cho override score | grading_action_buttons.dart - thêm validation score >= 0 và <= maxScore |
| #3 | Loading states cho grading buttons | Đã có sẵn |
| #4 | State refresh sau grading actions | teacher_submission_providers.dart - thêm ref.invalidate() |
| #5 | DataSource provider injection | Đã có repository pattern |

---

## 1.2. Assignment Management Screen (2026-03-12)

### Màn hình mới: TeacherAssignmentManagementScreen

**Mục đích:** Cung cấp giao diện thuận tiện để GV quản lý bài tập và điều hướng đến các trang liên quan.

**Tính năng:**
- 3 tabs: Đang tạo, Đã tạo, Đã giao
- Mỗi bài tập có action buttons:
  - **Xem** - Xem/Edit assignment
  - **Giao** - Giao bài cho lớp
  - **Danh sách nộp** - Xem submissions
  - **Chấm bài** - Đi đến trang grading

**Route:** `/teacher/assignments/manage`

**Truy cập:** Assignment Hub → Nút "Quản lý"

---

## 2. Kiến trúc Logic

### 2.1 Mô hình tư duy (Design Patterns)

```
┌─────────────────────────────────────────────────────────────┐
│                    AIR TRAFFIC CONTROL (ATC)               │
│  Dashboard nhìn lướt biết bài nào có vấn đề               │
│  - Badge "Nộp muộn" (đỏ)                                  │
│  - AI Loading indicator                                     │
│  - Filter: Tất cả / Chưa chấm / Đã chấm / Nộp muộn       │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                     SIDE-BY-SIDE LAYOUT                    │
│  Desktop: 2 cột (Trái: Bài làm | Phải: Đáp án)           │
│  Mobile: Bottom Sheet trượt lên                            │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                  SKEPTICISM THERMOMETER                   │
│  AI Confidence < 0.7 → Nền vàng + Cảnh báo              │
│  Hiển thị thanh confidence + % cụ thể                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   HUMAN-IN-THE-LOOP                       │
│  AI đưa điểm sơ bộ + feedback                            │
│  GV: Approve (duyệt) / Override (sửa điểm)               │
│  GV: Feedback Override (sửa lời phê AI)                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      STAGE CURTAIN                         │
│  Điểm CHỈ hiện khi GV bấm "Xuất bản"                     │
│  Status: 'submitted' → 'graded'                           │
│  Student chỉ thấy điểm sau khi publish                   │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 Data Flow

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│   UI Layer   │────▶│  Providers   │────▶│  DataSource  │
│   (Screens)  │     │ (Riverpod)   │     │ (Supabase)  │
└──────────────┘     └──────────────┘     └──────────────┘
                                                 │
                                                 ▼
                                         ┌──────────────┐
                                         │  Database    │
                                         │ (PostgreSQL) │
                                         └──────────────┘
```

### 2.3 State Management (Riverpod)

```dart
// Providers chính
teacherSubmissionListProvider    // Danh sách submissions
teacherSubmissionDetailProvider  // Chi tiết 1 submission
submissionAnswersProvider       // Danh sách câu trả lời
submissionGradingNotifierProvider // Actions: approve, override, publish
```

---

## 3. Cấu trúc Files

### 3.1 Files ĐÃ TẠO MỚI

```
lib/
├── presentation/
│   ├── providers/
│   │   └── teacher_submission_providers.dart     # Providers + Notifier
│   └── views/assignment/teacher/
│       ├── teacher_submission_list_screen.dart    # ATC Dashboard
│       ├── teacher_submission_detail_screen.dart  # Side-by-Side
│       └── widgets/submission/
│           ├── submission_filter_chips.dart       # Filter chips
│           ├── submission_list_item.dart          # List item + Badge
│           ├── ai_confidence_indicator.dart       # Skepticism Thermometer
│           ├── grading_action_buttons.dart       # Approve/Override
│           ├── question_answer_card.dart         # Q&A display
│           └── teacher_feedback_editor.dart      # Feedback Override
```

### 3.2 Files ĐÃ CÓ (Sử dụng lại)

```
lib/
├── data/
│   ├── datasources/
│   │   ├── submission_datasource.dart           # CRUD submissions
│   │   └── grade_override_datasource.dart        # Audit trail
│   └── repositories/
│       └── submission_repository_impl.dart
├── domain/
│   └── repositories/
│       └── grade_override_repository.dart        # Interface
```

### 3.3 Database Schema (Đã có)

```sql
-- submissions table
CREATE TABLE submissions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id),
  assignment_distribution_id UUID,
  is_late BOOLEAN DEFAULT false,
  total_score NUMERIC(7,2),
  ai_graded BOOLEAN DEFAULT false,
  status VARCHAR(50) DEFAULT 'submitted',  -- 'draft', 'submitted', 'graded'
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- submission_answers table
CREATE TABLE submission_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_id UUID REFERENCES submissions(id),
  question_id UUID,
  ai_score NUMERIC(7,2),
  ai_confidence NUMERIC(3,2),  -- 0.0 - 1.0
  ai_feedback JSONB,
  teacher_feedback JSONB,
  final_score NUMERIC(7,2),
  graded_by UUID REFERENCES profiles(id),
  graded_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- grade_overrides table (Audit Trail)
CREATE TABLE grade_overrides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  submission_answer_id UUID NOT NULL REFERENCES submission_answers(id),
  overridden_by UUID NOT NULL REFERENCES auth.users(id),
  old_score NUMERIC(7,2),
  new_score NUMERIC(7,2) NOT NULL,
  reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- work_sessions table
CREATE TABLE work_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES profiles(id),
  assignment_distribution_id UUID,
  status VARCHAR(50) DEFAULT 'in_progress',  -- 'in_progress', 'submitted', 'graded'
  started_at TIMESTAMPTZ DEFAULT now(),
  submitted_at TIMESTAMPTZ,
  graded_at TIMESTAMPTZ
);
```

---

## 4. Chi tiết từng Component

### 4.1 ATC Dashboard (TeacherSubmissionListScreen)

**File:** `teacher_submission_list_screen.dart`

**Chức năng:**
- Hiển thị danh sách submissions
- Filter chips: Tất cả / Chưa chấm / Đã chấm / Nộp muộn
- AI Loading indicator (khi đang chờ AI phân tích)
- Nút "Xuất bản điểm" trong AppBar và FAB

**UI Elements:**
```dart
Scaffold
├── AppBar
│   └── IconButton(Icons.publish)  // Xuất bản điểm
├── Column
│   ├── SubmissionFilterChips      // Filter tabs
│   ├── AI Loading Banner         // Hiển thị khi AI đang phân tích
│   └── ListView.builder          // Danh sách submissions
└── FloatingActionButton          // Xuất bản điểm toàn lớp
```

### 4.2 Submission List Item (SubmissionListItem)

**File:** `submission_list_item.dart`

**Hiển thị:**
- Avatar học sinh (CircleAvatar)
- Tên học sinh
- Thời gian nộp (format: "X phút trước")
- Badge "Nộp muộn" (màu đỏ) nếu `isLate = true`
- AI Loading spinner nếu đang chờ AI
- Điểm số (nếu đã chấm)

### 4.3 Side-by-Side Layout (TeacherSubmissionDetailScreen)

**File:** `teacher_submission_detail_screen.dart`

**Desktop Layout:**
```
┌─────────────────────────────┬─────────────────────────────┐
│     BÀI LÀM (HS)           │    ĐÁP ÁN + RUBRIC         │
│                             │                            │
│  - Câu hỏi                 │  - Câu hỏi                 │
│  - Câu trả lời HS          │  - Đáp án đúng            │
│  - File đính kèm           │  - Rubric chấm điểm        │
│                             │                            │
├─────────────────────────────┼─────────────────────────────┤
│                             │                            │
│  [Student Info]             │  [AI Confidence]           │
│                             │  [Grading Actions]         │
│                             │  - Duyệt / Sửa điểm       │
│                             │  [Feedback Editor]         │
└─────────────────────────────┴─────────────────────────────┘
```

**Mobile Layout:**
- PageView với swipe giữa các câu hỏi
- Bottom Sheet hiển thị đáp án + rubric

### 4.4 AI Confidence Indicator (Skepticism Thermometer)

**File:** `ai_confidence_indicator.dart`

**Logic:**
```dart
if (confidence < 0.7) {
  // Low confidence - vàng cảnh báo
  backgroundColor: DesignColors.warning.withAlpha(25)
  border: 2px warning
  showWarningText: true
} else {
  // High confidence - xanh lá
  backgroundColor: DesignColors.success.withAlpha(25)
  border: 1px success
}
```

**Hiển thị:**
- Icon: `Icons.warning_amber` (thấp) / `Icons.verified` (cao)
- Thanh progress bar (LinearProgressIndicator)
- Text: "AI Confidence: XX%"
- Warning text khi < 70%: "AI phân vân - Yêu cầu GV kiểm tra kỹ"

### 4.5 Grading Action Buttons

**File:** `grading_action_buttons.dart`

**Buttons:**
- **Duyệt điểm** (màu xanh): Approve AI score → `final_score = ai_score`
- **Sửa điểm** (outline): Override với dialog nhập điểm mới + lý do

**Override Dialog:**
```dart
AlertDialog
├── TextField: Điểm mới (number)
├── TextField: Lý do sửa (multiline)
└── Actions: Hủy / Lưu
```

### 4.6 Teacher Feedback Editor

**File:** `teacher_feedback_editor.dart`

**Tính năng:**
- Hiển thị AI Feedback (read-only)
- TextField cho GV nhập lời phê
- **Debounce 1000ms** - tự động lưu sau 1 giây không gõ
- Nút "Lưu ngay" force save
- Trạng thái: "Chưa lưu" / "Đang lưu" / "Đã lưu"

**Logic:**
```dart
Timer? _debounceTimer;

void _onTextChanged() {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(Duration(milliseconds: 1000), () {
    _saveFeedback();
  });
}
```

### 4.7 Publish Grades (Stage Curtain)

**Logic:**
1. GV bấm nút "Xuất bản điểm"
2. Hiện dialog xác nhận
3. Gọi API: `UPDATE work_sessions SET status = 'graded'`
4. Student app subscribe realtime → tự động hiển thị điểm

**Provider Method:**
```dart
Future<void> publishAllGrades(String distributionId) async {
  final repository = ref.read(submissionRepositoryProvider);
  await repository.publishAllGrades(distributionId);
}
```

---

## 5. Providers & State Management

### 5.1 TeacherSubmissionListProvider

```dart
@riverpod
Future<TeacherSubmissionListState> teacherSubmissionList(
  Ref ref, {
  required String distributionId,
  SubmissionFilter filter = SubmissionFilter.all,
})
```

**State:**
```dart
class TeacherSubmissionListState {
  final String distributionId;
  final String assignmentTitle;
  final List<TeacherSubmissionItem> submissions;
  final SubmissionFilter filter;
  final bool isLoadingAi;  // Có submission đang chờ AI
}
```

### 5.2 SubmissionGradingNotifier

```dart
@riverpod
class SubmissionGradingNotifier extends _$SubmissionGradingNotifier {
  // Methods:
  Future<void> approveAiScore(String answerId)
  Future<void> overrideScore({answerId, newScore, reason})
  Future<void> updateTeacherFeedback({answerId, feedback})
  Future<void> publishGrades(String submissionId)
  Future<void> publishAllGrades(String distributionId)
}
```

**Concurrency Guard:**
```dart
bool _isUpdating = false;

Future<void> someMethod() async {
  if (_isUpdating) return;
  _isUpdating = true;
  try {
    // ... logic
  } finally {
    _isUpdating = false;
  }
}
```

---

## 6. Routing

### 6.1 Route Definition

```dart
// app_router.dart
GoRoute(
  path: '/teacher/assignment/:assignmentId/submissions',
  builder: (context, state) => TeacherSubmissionListScreen(
    distributionId: state.pathParameters['assignmentId']!,
  ),
),

GoRoute(
  path: '/teacher/grade-submission/:submissionId',
  builder: (context, state) => TeacherSubmissionDetailScreen(
    submissionId: state.pathParameters['submissionId']!,
  ),
),
```

### 6.2 Navigation

```dart
// Từ list sang detail
context.pushNamed(
  'teacher-grade-submission',
  pathParameters: {'submissionId': submission.submissionId},
);
```

---

## 7. Design System

### 7.1 Design Tokens Used

```dart
// Colors
DesignColors.primary       // Xanh chủ đạo
DesignColors.success       // Xanh lá - duyệt
DesignColors.warning       // Vàng - cảnh báo, AI thấp
DesignColors.error         // Đỏ - lỗi, nộp muộn

// Spacing
DesignSpacing.sm, md, lg, xl

// Radius
DesignRadius.sm, md, lg

// Typography
DesignTypography.bodyMedium, bodySmall, titleMedium
```

### 7.2 Responsive

- **Desktop (≥1024px):** Side-by-Side 2 cột
- **Mobile (<1024px):** PageView + Bottom Sheet

---

## 8. Verification

### 8.1 Build Verification

```bash
flutter analyze  # ✅ No errors
flutter build apk --debug  # ✅ SUCCESS
```

### 8.2 Features Verified

- [x] ATC Dashboard hiển thị danh sách submissions
- [x] Badge "Nộp muộn" màu đỏ
- [x] AI Loading indicator khi đang chờ AI
- [x] Filter chips hoạt động
- [x] Side-by-Side layout (Desktop 2 cột)
- [x] Mobile Bottom Sheet
- [x] AI Confidence indicator hiển thị
- [x] AI confidence < 0.7 → nền vàng + cảnh báo
- [x] Approve/Override điểm AI
- [x] Feedback Override textbox với debounce
- [x] Publish Grades button hoạt động
- [x] Grade override lưu audit trail
- [x] Next/Prev navigation

---

## 9. Files Modified During Phase

### 9.1 New Files Created (Phase 2)

| File | Mô tả |
|------|--------|
| `teacher_submission_list_screen.dart` | ATC Dashboard |
| `teacher_submission_detail_screen.dart` | Side-by-Side |
| `teacher_submission_providers.dart` | Providers + Notifier |
| `submission_filter_chips.dart` | Filter UI |
| `submission_list_item.dart` | List item + Badge |
| `ai_confidence_indicator.dart` | Confidence display |
| `grading_action_buttons.dart` | Approve/Override |
| `question_answer_card.dart` | Q&A display |
| `teacher_feedback_editor.dart` | Feedback textbox |

### 9.2 New Files Created (Assignment Management)

| File | Mô tả |
|------|--------|
| `teacher_assignment_management_screen.dart` | Màn hình quản lý bài tập |

### 9.3 Files Modified (Review Fixes)

| File | Thay đổi |
|------|-----------|
| `submission_filter_chips.dart` | Hardcoded colors → DesignColors.disabledLight |
| `submission_list_item.dart` | Hardcoded colors → DesignColors.disabledLight |
| `question_answer_card.dart` | Hardcoded colors → DesignColors.disabledLight |
| `grading_action_buttons.dart` | Hardcoded colors → DesignColors.disabledLight + validation |
| `teacher_feedback_editor.dart` | Hardcoded colors → DesignColors.disabledLight |
| `ai_confidence_indicator.dart` | Hardcoded colors → DesignColors.dividerLight |
| `teacher_submission_providers.dart` | Thêm state refresh |
| `teacher_submission_detail_screen.dart` | Pass distributionId |

### 9.4 Files Modified (Assignment Management)

| File | Thay đổi |
|------|-----------|
| `route_constants.dart` | Thêm route teacherAssignmentManagement |
| `app_router.dart` | Thêm GoRoute cho Assignment Management |
| `teacher_assignment_hub_screen.dart` | Đổi nút "Tạo bằng AI" → "Quản lý" |
| `teacher_assignment_hub_notifier.dart` | Thêm assignments + distributions vào state |
| `assignment_repository.dart` | Thêm method getDistributionsByTeacher |
| `assignment_repository_impl.dart` | Implement getDistributionsByTeacher |
| `assignment_datasource.dart` | Thêm getDistributionsByTeacher |
| `assignment_distribution.dart` | Thêm extended fields |

---

## 10. API Calls Summary

### 10.1 GET Operations

```dart
// Lấy danh sách submissions
datasource.getSubmissionsByDistribution(distributionId)

// Lấy chi tiết 1 submission
datasource.getSubmissionById(submissionId)

// Lấy câu trả lời của submission
datasource.getSubmissionAnswers(submissionId)

// Lấy lịch sử override
gradeOverrideDatasource.getOverrideHistory(answerId)
```

### 10.2 POST/PUT Operations

```dart
// Duyệt điểm AI
datasource.approveAiScore(answerId)

// Override điểm
datasource.updateSubmissionAnswerGrade(answerId, finalScore, teacherId)
gradeOverrideDatasource.createGradeOverride(...)

// Cập nhật feedback
datasource.updateSubmissionAnswerGrade(answerId, teacherFeedback: feedback)

// Publish grades
repository.publishAllGrades(distributionId)
```

---

## 11. Dependencies

### 11.1 Pub Packages

```yaml
dependencies:
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  go_router: ^14.0.0
  supabase_flutter: ^2.0.0

dev_dependencies:
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
```

### 11.2 Project Structure

```
lib/
├── core/
│   ├── constants/design_tokens.dart    # Design system
│   └── services/supabase_service.dart # Supabase client
├── data/
│   ├── datasources/                   # Data layer
│   └── repositories/                  # Repository impl
├── domain/
│   └── repositories/                  # Repository interfaces
├── presentation/
│   ├── providers/                      # Riverpod providers
│   └── views/                         # UI screens
```

---

## 12. Next Steps

Phase 2 đã hoàn thành + Review Fixes + Assignment Management. Phase tiếp theo: **Phase 3 - Rubric System**

---

## 13. References

- **Plan:** `.planning/phases/02-teacher-grading-workflow/02-PLAN.md`
- **Summary:** `.planning/phases/02-teacher-grading-workflow/02-SUMMARY.md`
- **State:** `.planning/STATE.md`
- **Context:** `.claude/context.md`

---

## 14. Quick Access (Navigation)

```
Assignment Hub
    │
    ├── [Tạo bài mới] → Tạo assignment mới
    ├── [Quản lý] → TeacherAssignmentManagementScreen
    │       │
    │       ├── Tab: Đang tạo (draft assignments)
    │       │       └── [Xem] [Giao]
    │       │
    │       ├── Tab: Đã tạo (published assignments)
    │       │       └── [Xem] [Giao] [Danh sách nộp] [Chấm bài]
    │       │
    │       └── Tab: Đã giao (distributions)
    │               └── [Danh sách nộp] [Chấm bài]
    │
    ├── [Giao bài] → Chọn lớp để giao
    └── [Tìm bài] → Danh sách assignments

Danh sách nộp (Submission List)
    │
    └── Tap submission → TeacherSubmissionDetailScreen
            │
            ├── Desktop: Side-by-Side layout
            ├── Mobile: PageView + Bottom Sheet
            │
            ├── [Duyệt điểm] → Approve AI score
            ├── [Sửa điểm] → Override với lý do
            ├── AI Confidence < 0.7 → Warning indicator
            └── [Xuất bản điểm] → Stage Curtain
```
