# Hướng dẫn lấy Supabase Service Role Key

## Bước 1: Truy cập Supabase Dashboard

1. Đăng nhập vào: https://supabase.com/dashboard
2. Chọn project của bạn: `vazhgunhcjdwlkbslroc`

## Bước 2: Lấy Service Role Key

1. Vào **Project Settings** (biểu tượng bánh răng ở sidebar bên trái)
2. Chọn tab **API**
3. Tìm phần **Project API keys**
4. Copy giá trị của **`service_role`** key (không phải `anon` key)

⚠️ **QUAN TRỌNG**: 
- Service Role Key có quyền **BYPASS Row Level Security (RLS)**
- **KHÔNG BAO GIỜ** commit key này vào Git
- Chỉ dùng cho server-side operations
- File `.env.dev` đã được thêm vào `.gitignore` để bảo mật

## Bước 3: Cập nhật file `.env.dev`

Mở file `.env.dev` và thay thế dòng:
```
SUPABASE_SERVICE_ROLE_KEY=your-dev-service-role-key-here
```

Thành:
```
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZhemhndW5oY2pkd2xrYnNscm9jIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NTExMjc1OSwiZXhwIjoyMDgwNjg4NzU5fQ.YOUR_ACTUAL_SERVICE_ROLE_KEY_HERE
```

## Bước 4: Regenerate env.g.dart

Sau khi cập nhật `.env.dev`, chạy lại build_runner:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Lưu ý

- Service Role Key bắt đầu bằng `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (JWT token)
- Key này dài hơn Anon Key
- Nếu bạn không thấy Service Role Key, có thể cần reset lại key trong Supabase Dashboard
