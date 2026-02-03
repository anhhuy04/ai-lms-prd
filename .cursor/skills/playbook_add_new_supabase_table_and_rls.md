---
name: playbook_add_new_supabase_table_and_rls
intent: Checklist thêm bảng Supabase + RLS + integrate vào app (MCP-first)
tags: [playbook, supabase, security, mcp]
---

## Khi dùng

Khi cần thêm/đổi schema (bảng mới, cột mới, policy mới) hoặc build feature phụ thuộc schema.

## Checklist (MCP-first)

### 1) Check hiện trạng (không đoán)

- Dùng Supabase MCP: list tables / inspect columns / constraints
- Đối chiếu với `docs/ai/README_SUPABASE.md`
- Luôn đối chiếu rule ưu tiên nguồn: `.clinerules` → `.cursor/.cursorrules` → skills → memory-bank → docs

### 2) Thiết kế schema + RLS

- Xác định owner/role access (student/teacher/admin)
- Viết policies theo principle of least privilege
- Test queries theo role (đặc biệt đường đọc/ghi)

### 3) Apply migration (DDL)

- DDL → dùng migration (không hardcode IDs trong data migration)
- Sau khi đổi schema: chạy advisors (security/performance) nếu có

### 4) App integration

- Domain entity (`freezed`) + json serialization
- Domain repository interface
- DataSource Supabase queries
- RepoImpl mapping + translate error VN

### 5) Verification

- Test flow trên UI + 1–2 unit tests nếu logic quan trọng
- Confirm RLS behavior (không rely UI checks)
- Critical flows: report Sentry nếu lỗi block user task (theo `.cursor/.cursorrules`)

## Links

- `docs/ai/AI_INSTRUCTIONS.md` (Section 10 MCP)
- `docs/ai/README_SUPABASE.md`
- `memory-bank/systemPatterns.md` (Supabase + security notes)

