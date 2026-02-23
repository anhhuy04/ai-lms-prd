# 50 — Data Layer & Supabase

## Schema First: Always Check Schema Before Coding
Before creating any model/repository/datasource:
1. Review the SQL schema definitions in `docs/note sql.txt` and migrations in the `db/` directory. These are the primary sources of truth for table structures, relationships, and RLS policies.
2. Use **Supabase MCP** to inspect the actual table schema in the live database to verify changes.
3. Do NOT assume column names (e.g., never assume `created_at` exists without checking)
4. Notes about schema → write to `memory-bank/README_SUPABASE.md`
...
- File upload/download: `memory-bank/README_SUPABASE.md` → Storage section
...
4. Update `memory-bank/README_SUPABASE.md`

```sql
-- Check via Supabase MCP execute_sql
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name = 'your_table';
```

## RLS (Row Level Security) — Mandatory Rules
- ALL public tables via PostgREST MUST have RLS enabled
  - Especially: `profiles`, `classes`, `schools`, `groups`, `class_teachers`, `class_members`, `group_members`, question/assignment tables
- Use `(select auth.uid())` NOT `auth.uid()` directly (avoids per-row re-evaluation per Supabase Advisor)
- Explicit policies for each role: **admin / teacher / student**

```sql
-- ✅ CORRECT
CREATE POLICY "teachers_read_own_classes" ON classes
  FOR SELECT USING (teacher_id = (select auth.uid()));

-- ❌ WRONG (per-row re-evaluation)
CREATE POLICY "..." ON classes
  FOR SELECT USING (teacher_id = auth.uid());
```

## Complex Multi-Table Writes
- Prefer a **single RPC (security definer + explicit auth checks)** over multiple client-side round-trips
- Example: publish assignment + questions + distributions → 1 RPC

## Data Access Pattern (Clean Architecture)
```
UI → Provider(Riverpod) → Repository(interface) → DataSource → Supabase/Drift
```
- DataSource: raw Supabase calls, maps to Freezed models
- Repository impl: `data/repositories/`, implements `domain/repositories/` interface
- Parse heavy JSON in Isolate: `compute(() => ...)` in DataSource

## Async List Pattern (Large Lists)
```dart
// DataSource: parse in isolate
Future<List<ClassEntity>> getClasses() async {
  final raw = await supabase.from('classes').select();
  return compute(_parseClasses, raw);  // isolate
}

// UI: use AsyncListPage widget
AsyncListPage<ClassEntity>(
  future: ref.watch(classListProvider.future),
  itemBuilder: (ctx, item) => ClassItemWidget(item: item),
)
```

## Supabase Storage
- File upload/download: `docs/ai/README_SUPABASE.md` → Storage section
- All storage operations: check RLS on `storage.objects` + `storage.buckets`
- Reference: `50_data_supabase_rls_storage.md` + `90_security_and_privacy.md`

## New Table Checklist (Supabase)
1. Write the schema definition/migration in the `db/` directory.
2. Synchronize any schema definition changes with `docs/note sql.txt`.
3. Apply the table via Supabase MCP migration using the SQL from `db/`.
4. Enable RLS immediately.
5. Write policies for all 3 roles (admin/teacher/student).
6. Update `memory-bank/README_SUPABASE.md`.
7. Create Freezed model.
8. Create DataSource + Repository.
9. Run `dart run build_runner build -d`.
