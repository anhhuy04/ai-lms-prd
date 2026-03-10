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

## 1.1. pushNamed vs goNamed (QUAN TRỌNG)
- **Mặc định dùng `pushNamed()`/`push()`** - thêm vào navigation stack, back button hoạt động
- **Chỉ dùng `goNamed()`/`go()`** khi KHÔNG cần quay lại ( VD: login → home, splash → main, bottom nav switch)

```dart
// ✅ ĐÚNG: Screen có nút back
context.pushNamed(AppRoute.submissionHistory); // thêm vào stack
context.pop(); // quay lại được

// ✅ ĐÚNG: Thay thế route (không cần back)
context.goNamed(AppRoute.home); // login thành công → về home

// ❌ SAI: Dùng goNamed cho detail screen
context.goNamed(AppRoute.assignmentDetail); // pop() không hoạt động!
```

## 1.2. Back Navigation
- **Luôn dùng `context.pop()`** (GoRouter extension) để quay lại
- **KHÔNG dùng `Navigator.pop()`** vì GoRouter quản lý stack riêng
- Dùng `Navigator.pop()` CHỈ cho: dialog, bottom sheet, modal overlay
- Dùng `NavigationHelper.goBack(context)` để an toàn

```dart
// ✅ ĐÚNG
context.pop();
NavigationHelper.goBack(context);

// ❌ SAI
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
