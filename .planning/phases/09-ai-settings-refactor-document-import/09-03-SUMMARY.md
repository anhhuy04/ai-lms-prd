---
phase: 09-ai-settings-refactor-document-import
plan: "03"
subsystem: routing + settings UI
tags: [routing, go_router, settings, ai, flutter]
dependency_graph:
  requires: ["09-00"]
  provides: ["aiQuestionSettings route", "AiQuestionSettingsScreen"]
  affects: ["app_router.dart", "route_constants.dart", "teacher_ai_generate_question_screen.dart"]
tech_stack:
  added: []
  patterns: ["GoRoute named route", "StatelessWidget with const constructors", "design tokens", "Clipboard API"]
key_files:
  created:
    - lib/presentation/views/settings/ai_question_settings_screen.dart
  modified:
    - lib/core/routes/route_constants.dart
    - lib/core/routes/app_router.dart
    - lib/presentation/views/assignment/teacher/teacher_ai_generate_question_screen.dart
decisions:
  - "AiQuestionSettingsScreen is StatelessWidget — no local state needed; _downloadExcelTemplate uses Clipboard API, no url_launcher"
  - "Excel template URL kept as TODO placeholder per plan instruction — actual Supabase project ref not fabricated"
  - "Gear icon updated from context.push(settingsPath) to context.pushNamed(aiQuestionSettings) — decouples AI workflow from general settings"
metrics:
  duration: "~8 minutes"
  completed: "2026-04-19"
  tasks_completed: 2
  files_changed: 4
---

# Phase 09 Plan 03: AiQuestionSettingsScreen + Gear Icon Route Summary

**One-liner:** Dedicated AI settings screen with API Key tile, empty document library section, and Excel template download — wired via new `aiQuestionSettings` GoRoute with gear icon redirected from general settings.

## Tasks Completed

| Task | Name | Commit | Files |
|------|------|--------|-------|
| 1 | Add aiQuestionSettings route constants and GoRoute | 21f897f | route_constants.dart, app_router.dart, ai_question_settings_screen.dart |
| 2 | Fix gear icon route to pushNamed aiQuestionSettings | 5fbe741 | teacher_ai_generate_question_screen.dart |

## What Was Built

### route_constants.dart
- Added `AppRoute.aiQuestionSettings = 'ai-question-settings'`
- Added `AppRoute.aiQuestionSettingsPath = '/settings/ai-questions'`
- Added `aiQuestionSettings` to `teacherRoutes` set in `canAccessRoute()` — teacher-only, students cannot access

### app_router.dart
- Added import for `AiQuestionSettingsScreen`
- Added `GoRoute(path: aiQuestionSettingsPath, name: aiQuestionSettings, builder: AiQuestionSettingsScreen)` adjacent to apiKeySetup route

### ai_question_settings_screen.dart (new)
- `StatelessWidget` with `const` constructors throughout
- `build()` delegates to 3 section builders (CLAUDE.md 50-line rule)
- **Section 1** — API Key Setup: `ListTile` → `context.pushNamed(AppRoute.apiKeySetup)`
- **Section 2** — Thư viện Tài liệu: empty state (folder icon + text + disabled OutlinedButton with Tooltip) — Plan 05 activates upload
- **Section 3** — Công cụ: "Xuất file mẫu Excel" `ListTile` (D-16-ext) using `Clipboard.setData` + `SnackBar` (no url_launcher)
- All colors/spacing/typography via `DesignColors.*`, `DesignSpacing.*`, `DesignTypography.*`, `DesignRadius.*`
- Reusable `_SectionCard` and `_IconBox` private widgets

### teacher_ai_generate_question_screen.dart
- Line 904: `context.push(AppRoute.settingsPath)` → `context.pushNamed(AppRoute.aiQuestionSettings)` — gear icon now routes directly to AI settings

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

- `_templateUrl` in `AiQuestionSettingsScreen` contains placeholder `<YOUR_SUPABASE_PROJECT>` — intentional per plan instruction. The actual project URL must be substituted when the Storage bucket is provisioned (Plan 01/05 scope).
- Document library section shows empty state — "Thêm tài liệu" button is disabled. Plan 05 wires the upload pipeline.

## Self-Check: PASSED

- `lib/presentation/views/settings/ai_question_settings_screen.dart` — FOUND
- `lib/core/routes/route_constants.dart` contains `aiQuestionSettings` — FOUND
- `lib/core/routes/app_router.dart` contains `aiQuestionSettingsPath` GoRoute — FOUND
- Commits `21f897f`, `5fbe741` — FOUND
- `flutter analyze lib/core/routes/ lib/presentation/views/settings/` — 0 issues
