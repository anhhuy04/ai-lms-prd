---
name: 90_security_and_privacy
intent: Security rules (RLS-first, secrets hygiene, permission boundaries)
tags: [security, supabase]
---

## Intent

Không rò rỉ dữ liệu, đúng phân quyền, giảm rủi ro vận hành.

## Triggers

- **keywords**: `RLS`, `policy`, `role`, `anon key`, `Authorization`, `storage`

## DO / DON'T

- **DO**: RLS-first: thiết kế schema + policy trước khi “mở” query.
- **DO**: secrets nằm trong env (`envied`), không commit, không log.
- **DO**: Storage cũng cần policy/permission rõ (đừng chỉ dựa vào UI).
- **DON'T**: bypass quyền ở client (UI) thay cho RLS.

## Links

- `docs/ai/README_SUPABASE.md`
- `memory-bank/systemPatterns.md` (Security patterns)

