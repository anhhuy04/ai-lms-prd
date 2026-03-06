# 📊 PROJECT REPORT: AI LMS PRD

## What does this app do?

Ứng dụng Flutter quản lý học tập (Learning Management System) cho phép:
- **Giáo viên**: Tạo lớp học, tạo & phân phối bài tập, quản lý câu hỏi, chấm điểm
- **Học sinh**: Tham gia lớp qua QR code, làm bài tập, nộp bài
- **Quản trị**: Quản lý toàn bộ hệ thống

## Tech Stack

| Category | Package | Version |
|----------|---------|---------|
| State Management | `flutter_riverpod` | ^2.5.1 |
| Code Generation | `riverpod_annotation` | ^2.6.1 |
| Routing | `go_router` | ^14.0.0 |
| Backend | `supabase_flutter` | ^2.0.0 |
| Networking | `dio` | ^5.4.0 |
| Local DB | `drift` | ^2.30.1 |
| Secure Storage | `flutter_secure_storage` | ^9.0.0 |
| QR Code | `pretty_qr_code` | ^3.5.0 |
| QR Scanner | `mobile_scanner` | ^6.0.2 |
| Image Picker | `image_picker` | ^1.0.7 |
| UI | `flutter_screenutil` | ^5.9.0 |
| Error Reporting | `sentry_flutter` | ^9.10.0 |
| Logging | `logger` | ^2.0.0 |
| Env Config | `envied` | ^1.3.2 |
| Models | `freezed_annotation` | ^2.4.0 |

## How to Run

```bash
# Install dependencies
flutter pub get

# Generate code (Freezed, Riverpod, etc.)
dart run build_runner build -d

# Run app
flutter run

# Build APK
flutter build apk --debug

# Analyze code
flutter analyze
dart format .
```

---

## Project Status

### What Works

**Core Infrastructure:**
- Supabase integration & authentication (sign-in, sign-up, sign-out)
- Role-based navigation (Student/Teacher/Admin dashboards)
- Clean Architecture structure (presentation -> domain -> data)
- Design Tokens system (colors, spacing, typography)
- GoRouter v14 with ShellRoute + RBAC

**Features Completed:**
- Class Management (Teacher: create, edit, delete, settings)
- Class Enrollment (Student: join via QR code, leave class)
- QR Code generation & scanning
- Search system (generic SearchScreen<T>)
- Drawer system (ActionEndDrawer, ClassSettingsDrawer)
- Question Bank Schema (8 tables + RLS + RPC)
- Assignment Creation & Distribution (Teacher)
- Pagination & Performance optimization (Future.wait)

**Recent Sessions:**
- 2026-02-24: Performance optimization for Distribute Assignment (N+1 -> Future.wait)
- 2026-01-30: Question Bank Schema + RLS + Assignment Publish RPC
- 2026-01-29: Student Class features, QR Scan redesign
- 2026-01-27: Class Settings, Drawers, Search infrastructure

### In Progress

**Assignment Feature:**
- Assignment entity model
- Question types enum
- Assignment Repository & DataSource
- Assignment Builder UI (in progress)
- Distribute Assignment flow

### What's Left

**High Priority:**
- Complete Assignment Builder UI
- Assignment Preview screen
- Student Workspace (lam bai tap)
- Submission flow

**Medium Priority:**
- AI Grading integration
- Learning Analytics
- Notifications

---

## Key Files to Know

| File | Purpose |
|------|---------|
| `lib/core/routes/app_router.dart` | GoRouter config + RBAC |
| `lib/core/routes/route_constants.dart` | All route names & paths |
| `lib/core/constants/design_tokens.dart` | Design system (colors, spacing) |
| `lib/presentation/providers/` | Riverpod providers |
| `lib/domain/entities/` | Domain models (Freezed) |
| `lib/data/repositories/` | Repository implementations |
| `lib/data/datasources/` | Supabase queries |
| `memory-bank/activeContext.md` | Current sprint & session notes |
| `memory-bank/progress.md` | Full progress tracker |

---

## Code Health

### Overview
- Build Status: Compiles successfully
- Lint Warnings: Few (acceptable)
- Architecture: Clean Architecture

### Good Things
- Clean separation: Presentation -> Domain -> Data
- Design Tokens system enforced
- GoRouter v14 with proper RBAC
- RLS policies on all Supabase tables
- Error handling with Vietnamese messages
- Performance optimized (Future.wait, pagination)

### Needs Improvement
| Problem | Priority | Fix |
|---------|----------|-----|
| Some widgets still use hardcoded sizes | Medium | Migrate to DesignTokens |
| Unit tests not written yet | High | Add tests in Phase 2 |
| No offline mode | Low | Future feature |

---

## Upgrade Plan

### Current State
- Phase: Assignment Builder (Chapter 1)
- Database: Question Bank tables ready (8 tables)
- RLS: Configured for all tables

### Next Features (Easy to Add)
Based on architecture, these are straightforward:
1. Complete Assignment Builder -> Distribute flow
2. Student Workspace (lam bai, nop bai)
3. Auto-save with SharedPreferences

### Refactoring Needed
| Priority | Item |
|----------|------|
| Low | Rename `lib/core/ultils/` -> `utils/` |
| Medium | Add unit tests |
| Medium | Complete DesignTokens migration |

---

## Notes for Takeover

### Key Patterns
- State: Riverpod + `@riverpod` annotation (NOT Provider)
- Navigation: `context.goNamed()` - NO Navigator.push
- Data: All Supabase calls in `data/datasources/`
- Errors: Vietnamese messages in Repository layer
- Design: Use `DesignColors.*`, `DesignSpacing.*`, `DesignTypography.*`

### Critical Files
- `memory-bank/activeContext.md` - Start here for current context
- `.cursor/rules/CORE_ROLE.mdc` - Always read first
- `db/` - Database migrations

### Gotchas
- RLS must be enabled on ALL new tables
- Use `Future.wait()` for parallel API calls
- Shimmer only wraps content, NOT header
- Concurrency guard (`_isUpdating`) needed for AsyncNotifier mutations
