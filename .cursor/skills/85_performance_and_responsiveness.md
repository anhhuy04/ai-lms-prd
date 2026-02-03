---
name: 85_performance_and_responsiveness
intent: Performance guardrails (rebuilds, lists, debounce autosave, realtime limits)
tags: [performance, ux]
---

## Intent

UI mượt, không lag, không “đốt” realtime/subscription.

## Triggers

- **keywords**: `ListView.builder`, `Stream`, `realtime`, `debounce`, `setState` spam

## DO / DON'T

- **DO**: tách widget nhỏ + `const` để giảm rebuild.
- **DO**: autosave dùng debounce (vd: 2s) + backup local (SharedPreferences) nếu phù hợp.
- **DO**: với search/fast-switching UI dùng Dio, dùng `CancelToken` để tránh race conditions (theo `.cursor/.cursorrules`).
- **DON'T**: subscribe realtime cho bảng lớn/không cần thiết.

## Links

- `memory-bank/systemPatterns.md` (Auto-save pattern, performance notes)

