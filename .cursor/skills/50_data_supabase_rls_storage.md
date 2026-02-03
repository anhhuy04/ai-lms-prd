---
name: 50_data_supabase_rls_storage
intent: Supabase data access boundaries + RLS-first mindset + storage conventions
tags: [supabase, data, security]
---

## Intent

Đảm bảo an toàn (RLS), đúng kiến trúc (DataSource-only Supabase), và dễ mở rộng schema.

## Triggers

- **file_globs**: `lib/data/datasources/**`, `lib/data/repositories/**`, `lib/domain/repositories/**`
- **keywords**: `Supabase`, `from(`, `select`, `insert`, `update`
- **symptoms**: “không biết cột nào”, “query fail do RLS”

## DO / DON'T

- **DO**: check schema thật bằng Supabase MCP trước khi tạo entity/repo/query.
- **DO**: Supabase calls chỉ nằm trong `_datasource.dart`.
- **DO**: translate error message user-facing sang tiếng Việt ở Repository layer (không ở UI).
- **DO**: coi **RLS là bắt buộc**; không rely UI checks để thay cho policy.
- **DO**: report Sentry cho lỗi quan trọng ở boundary DataSource/Repository (đặc biệt write/update).
- **DO**: khi viết policy mới, dùng `(select auth.uid())` thay vì `auth.uid()` trực tiếp (theo Supabase advisor) để tránh re-evaluate per-row.
- **DO**: đảm bảo tất cả bảng `public` liên quan permission (profiles, classes, schools, groups, class_teachers, class_members, group_members, question/assignment tables) đã bật RLS trước khi mở API.
- **DON'T**: giả định có `created_at`/`updated_at` nếu chưa check.
- **DON'T**: log ra secrets/anon key/token.

## Class settings JSON (example)

Table `classes.class_settings` là JSONB; mapping đã chuẩn hóa (enrollment/qr_code/group_management/student_permissions/defaults).

## Storage + file metadata (khi app lớn)

- Upload file → Supabase Storage
- Metadata/linking → tables `files` và `file_links` (xem `docs/ai/README_SUPABASE.md`)

## Links

- `docs/ai/README_SUPABASE.md`
- `memory-bank/systemPatterns.md` (Data layer rules)
- `memory-bank/techContext.md` (Supabase + envied)

