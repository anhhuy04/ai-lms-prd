---
trigger: always_on
glob: "**/*"
description: "AI LMS PRD — always-on base rules pointer"
---

# Base Rules Pointer

Read `.agents/rules/README.md` for full index, then load relevant rule files by task category.

## Critical Defaults (Always Apply)
- Respond in Vietnamese (technical terms in English)
- Read `memory-bank/activeContext.md` + `progress.md` at session start
- Never `print()` → `AppLogger`
- Never hardcode colors/spacing → use `DesignTokens`
- Never `Navigator.push*()` for screen nav → `context.goNamed()`
- Never define new provider without grep-checking for duplicates first
- Run build_runner after ANY Freezed/JsonSerializable change
- Run `flutter analyze` before every commit

## Full Rules Index
→ `.agents/rules/README.md`
