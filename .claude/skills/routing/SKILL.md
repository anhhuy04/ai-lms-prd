---
name: routing
description: "Kích hoạt khi được yêu cầu cấu hình điều hướng (Navigation), quản lý routes, bảo mật chuyển trang (RBAC), hoặc Deep Links bằng GoRouter."
---

# Kỹ năng: Điều hướng (Routing) với GoRouter

Tuân thủ các chuẩn sau khi viết cấu hình hoặc thực hiện chuyển trang bằng GoRouter:

## 1. Chuẩn chung bắt buộc
- BẮT BUỘC dùng GoRouter v14+ (Declarative routing) cho toàn bộ ứng dụng.
- KHÔNG dùng `Navigator.push()` để chuyển screen chính.
- Mọi route phải được định nghĩa bằng hằng số (vd: `class AppRoute { static const home = '/home'; }`).

## 1.1. Back Navigation (Quan trọng)
- **Khi dùng GoRouter** (`context.go()`, `context.goNamed()`): Dùng `context.pop()` (extension method của GoRouter) hoặc `context.go(previousPath)` để quay lại.
- ** KHÔNG dùng `Navigator.pop()`** vì GoRouter quản lý navigation stack riêng, không tương thích với Navigator.
- **Trường hợp dùng Navigator.pop()**: Chỉ dùng cho dialog, bottom sheet, modal overlay.
- **Alternative**: Tạo helper như `NavigationHelper.goBack(context)` để handle cả hai trường hợp an toàn.

```dart
// ✅ ĐÚNG: Dùng GoRouter extension
context.pop(); // quay lại route trước đó
context.goNamed(AppRoute.home); // explicit route

// ✅ Alternative: Dùng helper
NavigationHelper.goBack(context);

// ❌ SAI: Không dùng Navigator với GoRouter
Navigator.of(context).pop(); // KHÔNG hoạt động với GoRouter!
```

## 2. ShellRoute & Bottom Navigation
- Sử dụng `StatefulShellRoute.indexedStack` khi cần giữ trạng thái của các tab trong Bottom Navigation Bar.
- Nested routing phải con tuân theo path của cha (vd: nhánh cha `/student` -> nhánh con `/student/courses`).

## 3. Redirect & RBAC (Role-Based Access Control)
- Quản lý Auth State bằng một provider (vd: `authNotifierProvider`) và lắng nghe nó trong thuộc tính `refreshListenable` của GoRouter.
- Thuộc tính `redirect` của router phải chứa rule:
  - Chưa login -> Dẫn về `/login`.
  - Đã login nhưng đang ở `/login` -> Dẫn về Home (theo Role của user).
  - Sai Role -> Dẫn về NotFound hoặc màn mặc định tương ứng.

## 4. Route Ordering (Cực kỳ quan trọng)
- Nguyên tắc: **Route cụ thể ĐỨNG TRƯỚC route có tham số (parameter).**
- Ví dụ ĐÚNG:
  1. `/courses/search`
  2. `/courses/:id`
- Ví dụ SAI: Nếu đặt `/courses/:id` lên trước, `/courses/search` sẽ bị hiểu `search` là `id`.
