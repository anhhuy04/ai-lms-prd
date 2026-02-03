---
name: 20_state_riverpod_asyncnotifier
intent: Riverpod (primary) patterns + anti-patterns (refresh/auth/reset, AsyncNotifier)
tags: [flutter, riverpod, state]
---

## Intent

Chuẩn hóa state management cho features mới, tránh regressions đã từng gặp.

> **Chuẩn dự án (ground truth):** Feature mới ưu tiên Riverpod. Provider/ChangeNotifier chỉ để **maintenance code cũ** khi chưa kịp migrate.

## Triggers

- **file_globs**: `lib/presentation/providers/**`, `lib/presentation/views/**`
- **keywords**: `ConsumerWidget`, `ConsumerStatefulWidget`, `ref.watch`, `ref.read`, `AsyncNotifier`, `AsyncValue`
- **symptoms**: “refresh kéo về login”, “Future already completed”

## DO / DON'T

- **DO**: dùng `ref.watch()` cho UI reactive; `ref.read()` cho one-shot call.
- **DO**: hiển thị state với `.when(loading/error/data)`.
- **DO**: refresh dashboard chỉ refresh data providers; giữ auth state ổn định.
- **DON'T**: gọi `checkCurrentUser()` trong refresh (dễ reset auth → router redirect).
- **DON'T**: set state về `loading` trong refresh nếu router đang guard theo auth state.

## Links

- `memory-bank/systemPatterns.md` (Riverpod migration + refresh rules)
- `memory-bank/activeContext.md` (Dashboard refresh + optimistic updates notes)

