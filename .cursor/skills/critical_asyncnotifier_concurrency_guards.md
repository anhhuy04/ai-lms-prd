---
name: critical_asyncnotifier_concurrency_guards
intent: Ngăn lỗi AsyncNotifier “Future already completed” và race conditions khi update state
tags: [critical, riverpod, concurrency]
---

## Symptom

- Runtime error: `Bad state: Future already completed`
- UI toggle setting bị giật/rollback sai khi update nhanh liên tục.

## Trigger

- **keywords**: `AsyncNotifier`, `_isUpdating`, `updateClass`, `updateClassSettingOptimistic`

## Rule

- Với update per-field (đặc biệt JSON settings): ưu tiên **optimistic update** + sync background + rollback on error.
- Với update “full”: cần **concurrency guard** (vd: `_isUpdating`) để tránh complete Future nhiều lần.
- Không set `state = AsyncLoading()` liên tục trong rapid toggles.

## Links

- `memory-bank/techContext.md` (ClassNotifier optimistic update notes)
- `memory-bank/activeContext.md` (Optimistic updates + guard)
