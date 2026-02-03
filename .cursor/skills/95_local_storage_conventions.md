---
name: 95_local_storage_conventions
intent: Quy ước lưu local (secure vs non-secure) + naming keys
tags: [storage, flutter]
---

## Intent

Lưu đúng nơi: token/secret an toàn, cache/draft dễ migrate.

## Triggers

- **keywords**: `SharedPreferences`, `flutter_secure_storage`, `token`, `draft`

## DO / DON'T

- **DO**: token/JWT/secret → `flutter_secure_storage`.
- **DO**: non-sensitive prefs/draft backup → SharedPreferences (naming key rõ ràng).
- **DO**: data relational/offline-first → Drift (theo `.cursor/.cursorrules`).
- **DON'T**: lưu secret vào SharedPreferences.

## Links

- `memory-bank/techContext.md` (flutter_secure_storage, SharedPreferences)
- `memory-bank/systemPatterns.md` (Auto-save backup idea)

