---
name: critical_dashboard_refresh_no_auth_reset
intent: Ngăn refresh làm reset auth state và bị router redirect về login
tags: [critical, riverpod, routing]
---

## Symptom

- Pull-to-refresh xong bị đá về `/login` dù user vẫn đăng nhập.

## Trigger

- **keywords**: `refresh()`, `checkCurrentUser`, `AsyncValue.loading`

## Rule

- Refresh dashboard **chỉ refresh data providers** (classes/assignments/…).
- **Không gọi** `checkCurrentUser()` trong refresh.
- **Tránh set** state về `loading` trong refresh nếu router guard theo auth state.

## Links

- `memory-bank/systemPatterns.md` (Dashboard refresh pattern)
- `memory-bank/activeContext.md` (Student/Teacher dashboard refresh fixes)

