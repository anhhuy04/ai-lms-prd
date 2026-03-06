---
name: supabase
description: "Kích hoạt khi làm việc với Supabase: truy vấn database, RLS policies, Realtime subscriptions, Storage, Edge Functions, hoặc authentication."
---

# Kỹ năng: Supabase Integration

## 1. Schema-First Approach

Luôn kiểm tra schema trước khi viết query. Dùng Supabase MCP để lấy schema thực tế:

```
# Kiểm tra schema trước khi code
mcp_supabase_get_tables → xem danh sách bảng
mcp_supabase_execute_sql → test query trước khi đưa vào code
```

## 2. RLS (Row Level Security) — Bắt buộc

- **MỌI bảng** phải bật RLS. Không có bảng nào public hoàn toàn.
- Dùng `(select auth.uid())` thay vì `auth.uid()` trực tiếp để tối ưu performance:

```sql
-- ✅ ĐÚNG — subquery tối ưu
CREATE POLICY "Users see own data" ON profiles
  FOR SELECT USING (id = (SELECT auth.uid()));

-- ❌ SAI — gọi function mỗi row
CREATE POLICY "Users see own data" ON profiles
  FOR SELECT USING (id = auth.uid());
```

## 3. Truy vấn từ Flutter

```dart
// Datasource pattern — không gọi Supabase trực tiếp từ Notifier
class ClassDatasource {
  ClassDatasource(this._supabase);
  final SupabaseClient _supabase;

  Future<List<ClassDto>> getClasses() async {
    final response = await _supabase
        .from('classes')
        .select('*, teacher:profiles!teacher_id(id, full_name, avatar_url)')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return (response as List).map((e) => ClassDto.fromJson(e)).toList();
  }
}
```

## 4. Multi-table Writes — Dùng RPC

Khi cần write vào nhiều bảng trong 1 transaction, dùng Supabase Edge Function hoặc RPC:

```dart
// ✅ Atomic multi-table write qua RPC
final result = await _supabase.rpc('create_class_with_members', params: {
  'class_name': name,
  'teacher_id': teacherId,
  'member_ids': memberIds,
});
```

```sql
-- Edge Function / RPC trong Supabase
CREATE OR REPLACE FUNCTION create_class_with_members(
  class_name TEXT,
  teacher_id UUID,
  member_ids UUID[]
) RETURNS JSON AS $$
DECLARE
  new_class_id UUID;
BEGIN
  INSERT INTO classes (name, teacher_id) VALUES (class_name, teacher_id)
  RETURNING id INTO new_class_id;

  INSERT INTO class_members (class_id, user_id)
  SELECT new_class_id, unnest(member_ids);

  RETURN json_build_object('class_id', new_class_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## 5. Async List Parsing với Isolate

Cho danh sách lớn (>100 items), parse JSON trong isolate để không block UI:

```dart
Future<List<ClassEntity>> _parseClasses(List<dynamic> rawData) async {
  return await compute(
    (data) => data.map((e) => ClassDto.fromJson(e).toDomain()).toList(),
    rawData,
  );
}
```

## 6. Realtime Subscriptions

```dart
// Subscribe trong provider — tự cleanup khi dispose
@riverpod
Stream<List<MessageEntity>> classMessages(ClassMessagesRef ref, String classId) {
  final supabase = ref.watch(supabaseClientProvider);

  return supabase
      .from('messages')
      .stream(primaryKey: ['id'])
      .eq('class_id', classId)
      .order('created_at')
      .map((data) => data.map((e) => MessageDto.fromJson(e).toDomain()).toList());
}
```

## 7. Supabase Storage

```dart
// Upload file
Future<String> uploadAvatar(String userId, Uint8List bytes) async {
  final path = 'avatars/$userId.jpg';
  await _supabase.storage.from('profiles').uploadBinary(
    path,
    bytes,
    fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
  );
  return _supabase.storage.from('profiles').getPublicUrl(path);
}
```

## 8. Checklist khi thêm bảng mới

- [ ] Tạo migration file trong `supabase/migrations/`
- [ ] Bật RLS: `ALTER TABLE new_table ENABLE ROW LEVEL SECURITY;`
- [ ] Viết policies cho SELECT/INSERT/UPDATE/DELETE
- [ ] Tạo DTO class với `@freezed` + `fromJson`
- [ ] Tạo Entity class trong domain
- [ ] Thêm `toDomain()` method vào DTO
- [ ] Tạo Repository interface trong domain
- [ ] Implement Repository trong data layer
- [ ] Đăng ký provider trong Riverpod
- [ ] Báo cáo lỗi Supabase lên Sentry
