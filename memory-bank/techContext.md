# Technical Context

## Technology Stack

### Core Framework
- **Flutter** - Cross-platform mobile UI framework (iOS & Android)
- **Dart** - Programming language (SDK: ^3.8.1)
- **Pub** - Dart package manager

### Backend & Database
- **Supabase** - Backend-as-a-Service (PostgreSQL + Auth + Real-time + Storage)
  - **URL:** `https://vazhgunhcjdwlkbslroc.supabase.co`
  - **Anon Key:** Stored in environment or hardcoded (review security)
  - **Features Used:**
    - Auth (sign up, sign in, sign out, password reset)
    - PostgreSQL (table queries, RLS policies)
    - Real-time subscriptions (for live updates)
    - Storage (file uploads for submissions, assignment media)
    - Edge Functions (optional - for AI grading API calls)

### State Management
- **Provider** (v6.0.0+) - Reactive state management using ChangeNotifier pattern
  - Dependency injection via `ChangeNotifierProvider`
  - Scoped access to ViewModels via `Consumer` or `context.read`

### UI & Utilities
- **Cupertino Icons** (v1.0.8) - iOS-style icon set
- **Marquee** (v2.2.0) - Scrolling text widget (for long labels)
- **Shared Preferences** (v2.15) - Local key-value storage for caching & drafts
- **Flutter Launcher Icons** (v0.13.1) - App icon generation tooling
- **Flutter Lints** (v5.0.0) - Code quality and style checking

### Development & Testing
- **Flutter Test** - Unit and widget testing framework (built-in)
- **Dart Analysis** - Static code analysis for quality assurance

### Optional/Future Dependencies
- **flutter_secure_storage** - Secure token storage (not yet added; recommended for production)
- **image_picker** - Photo/document selection (for assignment submissions)
- **intl** - Internationalization & date formatting (for Vietnamese localization)
- **http** or **dio** - HTTP client for external AI grading API (when needed)
- **charts_flutter** - Charts library for analytics dashboards
- **uuid** - Generate unique IDs for records

## Development Environment Setup

### Prerequisites
- **Flutter SDK** installed and in PATH
- **Dart SDK** (comes with Flutter)
- **Android Studio** with Android SDK (for Android development)
- **Xcode** (for iOS development on macOS)
- **Git** version control

### Project Setup
```bash
# Clone repository
git clone <repo-url>
cd AI_LMS_PRD

# Install dependencies
flutter pub get

# (Optional) Generate app icons
flutter pub run flutter_launcher_icons

# Run on device/emulator
flutter run                    # Auto-detect device
flutter run -d <device-id>   # Specific device
```

### IDE Configuration
- **VS Code:** Install Flutter + Dart extensions
- **Android Studio:** Built-in Flutter support
- **Recommended Extensions:**
  - Dart Code (Dart & Flutter support)
  - Flutter Intl (i18n tooling - for future Vietnamese localization)

## Supabase Database Schema

### Core Tables (Current)
1. **auth.users** - Managed by Supabase Auth
   - email, password (hashed), email_verified_at, etc.
   - No manual interaction; use Supabase Auth API

2. **profiles** - User profiles
   - Columns: id (FK to auth.users), full_name, role, avatar_url, bio, metadata, created_at, updated_at
   - Roles: 'student', 'teacher', 'admin'
   - Auto-created via `on_auth_user_created` trigger

### Tables to Create (Planned)
3. **schools** - School/institution records
4. **classes** - Class/section records
5. **assignments** - Assignment definitions
6. **questions** - Individual questions within assignments
7. **submissions** - Student assignment submissions
8. **grades** - Grade records (for submissions)
9. **ai_evaluations** - AI grading results & confidence scores
10. **learning_objectives** - Curriculum learning objectives
11. **skill_mastery** - Student skill progression
12. **feedback** - Teacher/AI feedback on submissions

### RLS Policies (Row-Level Security)
- Students can only see their own submissions
- Teachers can only see submissions for their classes
- Admins can see all data
- (To be implemented as tables are created)

## Build & Release Configuration

### Android
- **Minimum SDK:** API 21 (Android 5.0)
- **Target SDK:** API 34 (Android 14)
- **Gradle:** Version 8.x
- **Signing:** Requires keystore for production APK

**Key Files:**
- [android/app/build.gradle.kts](android/app/build.gradle.kts) - App-level build config
- [android/build.gradle.kts](android/build.gradle.kts) - Project-level build config
- [android/local.properties](android/local.properties) - Local SDK paths

### iOS
- **Minimum Deployment Target:** iOS 12.0
- **CocoaPods:** Dependency management
- **Signing:** Apple Developer account required

**Key Files:**
- [ios/Podfile](ios/Podfile) - iOS dependencies
- [ios/Runner/Info.plist](ios/Runner/Info.plist) - App configuration
- [ios/Runner.xcodeproj/project.pbxproj](ios/Runner.xcodeproj/project.pbxproj) - Xcode project config

## File Structure & Key Paths

```
lib/
├── main.dart                          # App entry point, provider setup
├── core/
│   ├── constants/ui_constants.dart    # UI constants (colors, spacing, etc.)
│   ├── services/supabase_service.dart # Supabase client initialization
│   ├── theme/app_theme.dart          # Material Design theme
│   ├── routes/app_routes.dart        # Route definitions & navigation
│   └── utils/ & ultils/              # Utility functions (note: typo in folder)
├── data/
│   ├── datasources/supabase_datasource.dart  # Direct Supabase queries
│   └── repositories/auth_repository_impl.dart # Repository implementations
├── domain/
│   ├── entities/profile.dart         # Domain models
│   └── repositories/auth_repository.dart # Abstract interfaces
└── presentation/
    ├── views/                         # Screens (login, dashboard, etc.)
    ├── viewmodels/                    # State management (MVVM)
    └── widgets/                       # Reusable UI components
```

## Important Configuration Files

### pubspec.yaml
- Declares all Flutter dependencies
- Specifies Flutter SDK version constraint
- Manages assets (images, fonts, data files)
- **Location:** [pubspec.yaml](pubspec.yaml)

### analysis_options.yaml
- Dart linting rules (code quality standards)
- Enforces consistent code style
- **Location:** [analysis_options.yaml](analysis_options.yaml)

### devtools_options.yaml
- DevTools configuration
- **Location:** [devtools_options.yaml](devtools_options.yaml)

## Performance & Size Optimization

### Bundle Size
- Current APK size: ~50-100 MB (depends on architecture)
- Monitor with `flutter build apk --analyze-size`
- Remove unused dependencies annually

### Runtime Performance
- Target: <5 second cold start
- Target: <500ms UI response time
- Profile with `flutter run --profile`

## Code Quality Standards

### Linting
- Run `flutter analyze` regularly
- All warnings must be addressed (no ignores unless justified)
- Fix with `dart fix --apply` when possible

### Formatting
- Use `dart format` to auto-format all code
- Configure IDE to format on save
- Consistency over personal preferences

### Commit Standards
- Small, focused commits (one feature per commit)
- Descriptive commit messages in English
- Feature branch naming: `feature/assignment-builder` or `fix/auth-issue`

## MCP (Model Context Protocol) Setup

### MCP Servers Configured

Dự án sử dụng các MCP servers sau để tăng hiệu quả làm việc với AI agent:

1. **Supabase Official MCP** (`@supabase/mcp-server-supabase`)
   - **Mục đích**: Quản lý database, kiểm tra schema, query dữ liệu, apply migrations
   - **Location**: `c:\Users\<username>\.cursor\mcp.json`
   - **Config**: Project ref và access token đã được cấu hình
   - **Use Cases**: 
     - Kiểm tra schema trước khi tạo model/repository
     - Query dữ liệu để hiển thị trực tiếp
     - Apply migrations
     - Xem logs và advisors

2. **Context7 MCP** (`@upstash/context7-mcp`)
   - **Mục đích**: Quản lý context và tìm kiếm trong codebase
   - **Use Cases**: Tìm patterns, hiểu codebase structure

3. **Fetch MCP** (`mcp-fetch-server`)
   - **Mục đích**: Fetch documentation và web content
   - **Config**: Default limit 50000 characters
   - **Use Cases**: 
     - Fetch documentation khi thêm thư viện mới
     - Tìm examples và best practices từ web

4. **GitHub MCP** (`@modelcontextprotocol/server-github`)
   - **Mục đích**: Quản lý Git operations (commits, branches, PRs)
   - **Config**: Cần GitHub Personal Access Token trong env
   - **Use Cases**: 
     - Tạo commits khi được yêu cầu
     - Xem branches và PRs
     - Quản lý Git workflow

5. **Filesystem MCP** (`@modelcontextprotocol/server-filesystem`)
   - **Mục đích**: Đọc/ghi files và navigate codebase
   - **Config**: Đường dẫn dự án: `D:\code\Flutter_Android\AI_LMS_PRD`
   - **Use Cases**: 
     - Đọc nhiều files cùng lúc để hiểu context
     - Navigate codebase khi cần truy cập nhiều files

6. **Memory MCP** (`@modelcontextprotocol/server-memory`)
   - **Mục đích**: Lưu trữ context quan trọng giữa các sessions
   - **Use Cases**: 
     - Lưu các quyết định kiến trúc quan trọng
     - Lưu patterns đã được thống nhất
     - Maintain context giữa các sessions

### MCP Configuration File

**Location**: `c:\Users\<username>\.cursor\mcp.json` (Windows)

**Structure**:
```json
{
  "mcpServers": {
    "supabase-official": { ... },
    "github.com/upstash/context7-mcp": { ... },
    "github.com/zcaceres/fetch-mcp": { ... },
    "github": { ... },
    "filesystem": { ... },
    "memory": { ... }
  }
}
```

### MCP Usage Patterns

- **Luôn kiểm tra trước khi giả định**: Sử dụng Supabase MCP để kiểm tra schema trước khi tạo model
- **Sử dụng đúng tool cho đúng mục đích**: Mỗi MCP server có mục đích riêng
- **Kết hợp các MCP servers**: Có thể sử dụng nhiều MCP servers cùng lúc để có context đầy đủ
- **Document findings**: Lưu patterns quan trọng vào Memory MCP hoặc documentation

### MCP Documentation

- **Setup Guide**: [CURSOR_SETUP.md](../CURSOR_SETUP.md)
- **Usage Guide**: [MCP_GUIDE.md](../MCP_GUIDE.md)
- **AI Instructions**: [AI_INSTRUCTIONS.md](../AI_INSTRUCTIONS.md) - Section 10 về MCP Usage Patterns

## Documentation Locations

- **Project Overview:** [README.md](README.md)
- **Supabase Setup:** [README_SUPABASE.md](README_SUPABASE.md)
- **Implementation Instructions:** [AI_INSTRUCTIONS.md](AI_INSTRUCTIONS.md)
- **Cursor Setup:** [CURSOR_SETUP.md](../CURSOR_SETUP.md)
- **MCP Guide:** [MCP_GUIDE.md](../MCP_GUIDE.md)
- **Database Scripts:** [db/](db/) folder

## Deployment Pipeline (Future)

### Testing Checklist
- [ ] Dart analysis passes (`flutter analyze`)
- [ ] All tests pass (`flutter test`)
- [ ] APK builds successfully (`flutter build apk --release`)
- [ ] Manual testing on 2+ Android versions
- [ ] Manual testing on iOS (if applicable)

### Release Steps
1. Update version in `pubspec.yaml`
2. Tag commit: `git tag v1.0.0`
3. Build APK/AAB: `flutter build apk --release`
4. Upload to Google Play Store or internal distribution
5. Post-release monitoring for crashes

## Common Commands Reference

```bash
flutter pub get              # Install dependencies
flutter analyze             # Check for issues
dart format lib/            # Auto-format code
flutter test               # Run all unit/widget tests
flutter run                # Run app in development
flutter run --profile      # Profile app performance
flutter build apk          # Build Android APK (debug)
flutter build apk --release # Build Android APK (release)
flutter build ios          # Build iOS app (requires macOS)
flutter pub upgrade        # Update all dependencies
flutter pub outdated       # Check outdated packages
```

## Troubleshooting Notes

- **Gradle build issues:** Delete `android/.gradle` and `build/` folders, then run again
- **Pod issues (iOS):** Run `cd ios && pod repo update && pod install` then `cd ..`
- **Dependency conflicts:** Use `flutter pub get --no-offline` to refresh
- **Hot reload not working:** Try full app restart with `R`; restart adb if needed

---

# XEM THÊM

Để tìm hiểu thêm về các chủ đề liên quan, tham khảo:

- **MCP Usage Patterns:** `AI_INSTRUCTIONS.md` (Section 10) và `.clinerules` (Database & MCP section)
- **System Architecture:** `memory-bank/systemPatterns.md` (Overall Architecture section)
- **Database Schema:** `README_SUPABASE.md`
- **Code Quality Rules:** `.clinerules` (Code Quality section)
- **Directory Structure:** `AI_INSTRUCTIONS.md` (Section 1)
- **Current Work Focus:** `memory-bank/activeContext.md` (Current Sprint Focus section)
- **Supabase Integration:** `memory-bank/systemPatterns.md` (Key Technical Decisions section)