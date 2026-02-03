---
name: 70_code_quality_and_lints
intent: Quality gates (lint/format/analyze), size limits, conventions
tags: [quality, lint, workflow]
---

## Intent

Giữ codebase “không nát”: dễ đọc, dễ review, ít bug.

## Triggers

- **keywords**: `print(`, `TODO`, “file quá dài”, “build() quá dài”
- **file_globs**: `analysis_options.yaml`, `lib/**`, `test/**`

## DO / DON'T

- **DO**: không dùng `print` → dùng `AppLogger` (lint `avoid_print: true`).
- **DO**: format + analyze trước khi kết thúc task.
- **DO**: function ≤ 50 lines; class ≤ 300 lines (tách/đóng gói lại).
- **DON'T**: ignore warning trừ khi có lý do rõ và scope nhỏ.

## Verification checklist (cuối task)

- `dart format` (hoặc Dart MCP format)
- `flutter analyze` (hoặc Dart MCP analyze)
- Nếu có sửa Freezed/JsonSerializable/Envied: chạy `build_runner` theo `.cursor/.cursorrules` (delete-conflicting-outputs).

## Ground truth

- `analysis_options.yaml`
- `.clinerules` (Code Quality section)

