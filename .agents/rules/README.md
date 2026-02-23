# AI LMS PRD — Antigravity Rules Index

## Source of Truth Priority
1. `.agents/rules/**` ← this directory (highest)
2. `.agents/skills/**`
3. `docs/note sql.txt` and `db/` (for Database Schema and PostgreSQL specifics)
4. `memory-bank/**`
5. `.cursorrules` (if exists)

## Quick Navigation

| File | Category | When to Read | Notes |
|---|---|---|---|
| `00_context_and_priority.md` | Context Protocol | Every session start | |
| `10_tech_stack.md` | Libraries | Before any feature/library use | |
| `20_architecture.md` | Clean Arch, MVVM | Before structural changes | |
| `30_routing.md` | GoRouter, RBAC | Before any navigation work | |
| `40_state.md` | Riverpod, AsyncNotifier | Before any state changes | |
| `50_data_supabase.md` | Supabase, RLS, Data | Before DB/Data work | → xem thêm skill `supabase` + `error-handling` |
| `60_ui_design.md` | Design Tokens, UI/UX | Before any UI work | |
| `70_code_quality.md` | Error Prevention, Lint | Before every implementation | |
| `80_memory_bank.md` | Memory Bank Workflow | Every session start/end | |
| `90_mcp_and_git.md` | MCP, Git | For MCP usage + commits | |

## Scenario → Rule Mapping

- **Add new screen + route** → `30_routing.md` + `20_architecture.md` + `40_state.md`
- **Supabase table/RLS** → `50_data_supabase.md` + `70_code_quality.md`
- **UI component** → `60_ui_design.md` + `20_architecture.md`
- **State/provider** → `40_state.md` + `70_code_quality.md`
- **New library** → `10_tech_stack.md` + `90_mcp_and_git.md`
- **Debug/fix bug** → `70_code_quality.md` + `90_mcp_and_git.md`
- **Refactor** → `20_architecture.md` + `70_code_quality.md`
- **Splash/auth loop** → `30_routing.md` + `40_state.md` (critical_splash rules)
- **Tab refresh reset auth** → `40_state.md` (dashboard refresh guard)
- **AsyncNotifier concurrency** → `40_state.md` (concurrency guards)
