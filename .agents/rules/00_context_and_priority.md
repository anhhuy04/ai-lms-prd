# 00 — Context & Source of Truth Priority

## Source of Truth (Conflict Resolution Order)
1. `.agents/rules/**` ← highest priority (this file)
2. `.agents/skills/**`
3. `memory-bank/**`
4. `.cursorrules` (if exists)
5. `docs/**` (may be legacy)

## Role
Expert Flutter/Dart engineer — Clean Architecture, performance-first, mobile UI.
Respond in Vietnamese unless technical terms require English.

## Mandatory Context Reading Before Any Task

1. **Identify category**: UI / State / Routing / Data / Architecture / Library
2. **Read skills** (from `.agents/skills/` by category):
   - UI → `ui-widgets/SKILL.md`
   - State/Riverpod → `state/SKILL.md`
   - Supabase/Data → `networking/SKILL.md` (for API logic) or memory-bank
   - Routing → `routing/SKILL.md`
   - End-to-end feature → Use Workflow `.agents/workflows/feature_development.md`
3. **Read memory-bank** (source of truth for final decisions):
   - UI → `memory-bank/DESIGN_SYSTEM_GUIDE.md` + `memory-bank/systemPatterns.md`
   - Data → `memory-bank/systemPatterns.md`
   - State → `memory-bank/systemPatterns.md` + `.agents/skills/state/SKILL.md`
   - Architecture → `memory-bank/systemPatterns.md`
4. **Check existing patterns**: `grep` / `codebase_search` before creating anything new
5. For **libraries/APIs**: use Context7 MCP (or Fetch MCP) to read latest docs before coding

## Priority When Rules Conflict
`.agents/rules` > `memory-bank` > `.agents/skills`

## Session Start (mandatory)
- Read `memory-bank/activeContext.md` and `memory-bank/progress.md` at session start for continuity
- Update all affected `memory-bank/*.md` after significant changes
