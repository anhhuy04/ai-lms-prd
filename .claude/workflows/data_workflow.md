---
name: data_workflow
description: Workflow cho làm việc với database: tạo bảng mới, migration, RLS policies, Supabase operations.
trigger: /data
---

# Workflow: Data / Supabase

## 1. Schema First

### Kiểm tra Schema hiện tại
```sql
-- Dùng Supabase MCP
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'your_table';
```

### Đọc Docs
- `docs/note sql.txt` — schema definitions
- `memory-bank/README_SUPABASE.md` — Supabase patterns

---

## 2. Plan

### New Table Checklist
- [ ] Viết migration SQL trong `db/`
- [ ] Định nghĩa columns, types, constraints
- [ ] Thêm timestamps (created_at, updated_at)
- [ ] Xác định relationships

### RLS Planning
- [ ] SELECT policy cho từng role (admin/teacher/student)
- [ ] INSERT policy
- [ ] UPDATE policy
- [ ] DELETE policy

---

## 3. Execute

### Migration SQL
```sql
-- db/xx_add_new_table.sql
CREATE TABLE your_table (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  teacher_id UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE your_table ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "teachers_select_own" ON your_table
  FOR SELECT USING (teacher_id = (SELECT auth.uid()));

CREATE POLICY "teachers_insert_own" ON your_table
  FOR INSERT WITH CHECK (teacher_id = (SELECT auth.uid()));
```

### Apply Migration
```bash
# Dùng Supabase MCP
mcp_supabase_execute_sql
```

---

## 4. Flutter Implementation

### Entity
```dart
// lib/domain/entities/your_entity.dart
class YourEntity {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;

  YourEntity({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });
}
```

### Freezed Model
```dart
// lib/data/models/your_dto.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'your_dto.freezed.dart';
part 'your_dto.g.dart';

@freezed
class YourDto with _$YourDto {
  const factory YourDto({
    required String id,
    required String name,
    String? description,
    required DateTime createdAt,
  }) = _YourDto;

  factory YourDto.fromJson(Map<String, dynamic> json) =>
      _$YourDtoFromJson(json);
}
```

### DataSource
```dart
// lib/data/datasources/your_datasource.dart
class YourDatasource {
  YourDatasource(this._supabase);
  final SupabaseClient _supabase;

  Future<List<YourDto>> getAll() async {
    final response = await _supabase
        .from('your_table')
        .select()
        .order('created_at', ascending: false);
    return response.map((e) => YourDto.fromJson(e)).toList();
  }
}
```

### Repository
```dart
// lib/domain/repositories/i_your_repository.dart
abstract class IYourRepository {
  Future<List<YourEntity>> getAll();
}

// lib/data/repositories/your_repository_impl.dart
class YourRepositoryImpl implements IYourRepository {
  YourRepositoryImpl(this._datasource);
  final YourDatasource _datasource;

  @override
  Future<List<YourEntity>> getAll() async {
    final dtos = await _datasource.getAll();
    return dtos.map((d) => YourEntity(
      id: d.id,
      name: d.name,
      description: d.description,
      createdAt: d.createdAt,
    )).toList();
  }
}
```

### Provider
```dart
// lib/presentation/providers/your_provider.dart
@riverpod
IYourRepository yourRepository(YourRepositoryRef ref) {
  return YourRepositoryImpl(ref.watch(yourDatasourceProvider));
}

@riverpod
Future<List<YourEntity>> yourList(YourListRef ref) async {
  return ref.watch(yourRepositoryProvider).getAll();
}
```

---

## 5. Verify

### Analyze
```bash
flutter analyze
```

### Test
```bash
flutter test
```

---

## 6. Document

### Update Memory Bank
```markdown
## YYYY-MM-DD
- Database: Thêm bảng your_table
- Files: lib/domain/entities/, lib/data/models/, lib/data/datasources/, lib/data/repositories/
```

### Update Schema Docs
- Thêm vào `docs/note sql.txt`
- Update `memory-bank/README_SUPABASE.md`
