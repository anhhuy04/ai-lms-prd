---
phase: 09-ai-settings-refactor-document-import
plan: "02"
subsystem: dependencies
tags: [file-picker, android, ios, permissions, dependencies]
dependency_graph:
  requires: []
  provides: [file_picker ^11.0.2 installed, platform permissions configured]
  affects: [09-04-teacher-file-datasource]
tech_stack:
  added: [file_picker ^11.0.2]
  patterns: [FilePicker.platform.pickFiles with withData:true for scoped storage]
key_files:
  modified:
    - pubspec.yaml
    - android/app/src/main/AndroidManifest.xml
    - ios/Runner/Info.plist
decisions:
  - User approved file_picker ^11.0.2 install (over defer option) — enables REQ 9-02 document upload pipeline
metrics:
  duration: ~5 minutes
  completed: 2026-04-19
  tasks_completed: 1
  files_modified: 3
---

# Phase 9 Plan 02: file_picker Dependency Install Summary

**One-liner:** file_picker ^11.0.2 added to pubspec with Android READ_EXTERNAL_STORAGE/READ_MEDIA_IMAGES and iOS NSPhotoLibraryUsageDescription permissions.

## What Was Done

Task 1 (checkpoint:decision) was pre-resolved by user approval ("approve"). Task 2 executed as continuation.

### Task 2: Install file_picker and update platform manifests

Added `file_picker: ^11.0.2` to `pubspec.yaml` dependencies (alphabetically before `fl_chart`). Updated both platform manifests with required permissions.

**pubspec.yaml change:**
```yaml
file_picker: ^11.0.2
```

**Android permissions added** (before `<queries>` block):
- `READ_EXTERNAL_STORAGE` with `android:maxSdkVersion="32"` (API < 33)
- `READ_MEDIA_IMAGES` (API >= 33)

**iOS Info.plist key added:**
- `NSPhotoLibraryUsageDescription` — "Cần quyền truy cập thư viện để tải lên tài liệu dạy học"

## Verification Results

- `flutter pub get`: Resolved successfully — `Changed 1 dependency!` (file_picker 11.0.2). Windows symlink warning on D: drive is pre-existing, unrelated to this change.
- `flutter analyze --no-pub`: 10 issues found — all pre-existing (env.g.dart not generated, unused element warnings). Zero new issues introduced by file_picker.

## Commits

| Hash | Message |
|------|---------|
| ff6a829 | feat(09-02): install file_picker ^11.0.2 + platform permissions |

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None — this plan is dependency installation only; no UI or data-layer stubs created.

## Self-Check: PASSED

- pubspec.yaml contains `file_picker: ^11.0.2`: FOUND
- AndroidManifest.xml contains READ_EXTERNAL_STORAGE: FOUND
- iOS Info.plist contains NSPhotoLibraryUsageDescription: FOUND
- Commit ff6a829: FOUND
