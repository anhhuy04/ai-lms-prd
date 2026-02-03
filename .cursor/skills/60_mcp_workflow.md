---
name: 60_mcp_workflow
intent: Khi nào dùng MCP nào + checklist “check trước khi code”
tags: [mcp, workflow]
---

## Intent

Dùng MCP đúng chỗ để giảm đoán mò và tránh sai schema/docs.

## Triggers

- **keywords**: `schema`, `migration`, `docs`, `pub.dev`, `Supabase MCP`, `Context7`, `Fetch`

## DO / DON'T
- **DO**: Khi cần tài liệu thư viện/API (Flutter/Dart/Supabase/3rd party), LUÔN ưu tiên dùng **Context7 MCP** (hoặc MCP Fetch nếu Context7 không áp dụng) để đọc doc & example MỚI NHẤT trước khi viết / sửa code.
- **DO**: Trước khi gọi MCP cho schema/docs, đọc nhanh **skill standard** tương ứng trong `.cursor/skills/common/**`, `.cursor/skills/dart/**`, `.cursor/skills/flutter/**`, sau đó (nếu cần) đọc thêm **skill custom** qua `.cursor/skills/cusrurrulers/SKILL.md` theo đúng thứ tự trong `.clinerules`.
- **DO**: DB-related → dùng Supabase MCP để list tables/columns trước.
- **DO**: thêm thư viện mới → dùng Fetch MCP đọc docs/examples trước khi implement.
- **DO**: tìm pattern trong repo → dùng semantic `codebase_search` (ưu tiên) hoặc Context7.
- **DO**: nếu kiến thức nội bộ có thể “cũ” (pre-2025) về lib trong tech stack → Fetch/Context7 docs trước khi code (theo `.cursor/.cursorrules`).
- **DON'T**: tự suy đoán schema/behavior lib.

## MCP mapping (quick)

- **Supabase MCP**: schema/query/migrations/logs/advisors
- **Fetch MCP**: docs web/pub.dev/examples
- **Context7**: tra cứu docs lib/code examples (up-to-date) 
- **Dart MCP**: format/analyze (sau khi code)

## Links

- `docs/ai/AI_INSTRUCTIONS.md` (Section 10)
- `memory-bank/techContext.md` (MCP setup)
- `.clinerules` (Database & MCP)

