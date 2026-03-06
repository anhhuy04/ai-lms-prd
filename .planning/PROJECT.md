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

### Current Status (2026-03-05)

**Đã hoàn thành (~50%):**
- ✅ Authentication: Login, Register, Splash, RBAC
- ✅ Class Management: Teacher & Student class CRUD
- ✅ Assignment Distribution: Hub, Create, Preview, AI Generate, Distribute workflow
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

### Key Integration Points

- Routes: `lib/core/routes/route_constants.dart` + `app_router.dart`
- Providers: `lib/presentation/providers/`
- Entities: `lib/domain/entities/`
- Shared widgets: `lib/widgets/`

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

---

*Last updated: 2026-03-05 after initialization*
