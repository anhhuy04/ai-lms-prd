# Screen Usage Guide - AI LMS

## Tổng quan

Tài liệu này mô tả cách sử dụng các màn hình chính trong ứng dụng AI LMS, cách setup và các chức năng liên quan.

## Cấu trúc Screens

### Authentication Screens

#### Login Screen (`lib/presentation/views/auth/login_screen.dart`)

**Mục đích:** Màn hình đăng nhập cho người dùng.

**Chức năng:**
- Đăng nhập bằng email/password
- Validation form
- Error handling
- Navigation đến Register screen

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.login);
```

**ViewModel:** `AuthViewModel`
- `login(String email, String password)` - Thực hiện đăng nhập
- `isLoading` - Trạng thái loading
- `errorMessage` - Thông báo lỗi

**Responsive:**
- Sử dụng `ResponsiveScreen` wrapper
- Form tự động điều chỉnh theo device type

#### Register Screen (`lib/presentation/views/auth/register_screen.dart`)

**Mục đích:** Màn hình đăng ký tài khoản mới.

**Chức năng:**
- Đăng ký với email/password
- Validation form
- Error handling
- Navigation đến Login screen

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.register);
```

**ViewModel:** `AuthViewModel`
- `register(String email, String password, String fullName)` - Thực hiện đăng ký
- `isLoading` - Trạng thái loading
- `errorMessage` - Thông báo lỗi

---

### Dashboard Screens

#### Student Dashboard (`lib/presentation/views/dashboard/student_dashboard_screen.dart`)

**Mục đích:** Màn hình chính cho sinh viên.

**Chức năng:**
- Hiển thị thông tin cá nhân ở header
- Bottom navigation với 5 tabs:
  1. Trang chủ (StudentHomeContentScreen)
  2. Lớp học (StudentClassListScreen)
  3. Bài tập (AssignmentListScreen)
  4. Điểm số (ScoresScreen)
  5. Cá nhân (ProfileScreen)
- Pull-to-refresh

**Setup:**
```dart
StudentDashboardScreen(userProfile: profile)
```

**ViewModel:** `StudentDashboardViewModel`
- `refresh()` - Làm mới dữ liệu
- `isRefreshing` - Trạng thái refresh

**Responsive:**
- Header tự động điều chỉnh spacing
- Bottom navigation responsive
- Sử dụng `ResponsiveRow` cho header layout

#### Student Home Content (`lib/presentation/views/dashboard/home/student_home_content_screen.dart`)

**Mục đích:** Nội dung trang chủ của sinh viên.

**Chức năng:**
- Hiển thị tiến độ tuần này (progress card)
- Thống kê bài tập (đã nộp, chờ chấm)
- Danh sách bài tập sắp đến hạn
- Điểm số mới nhất

**Responsive:**
- Sử dụng `ResponsiveCard` cho các cards
- Sử dụng `ResponsiveText` cho text
- Sử dụng `ResponsiveRow` cho stats row
- Grid layout responsive cho due list

#### Teacher Dashboard (`lib/presentation/views/dashboard/teacher_dashboard_screen.dart`)

**Mục đích:** Màn hình chính cho giáo viên.

**Chức năng:**
- Tương tự Student Dashboard nhưng với các tabs phù hợp giáo viên

**Setup:**
```dart
TeacherDashboardScreen(userProfile: profile)
```

---

### Class Screens

#### Student Class List (`lib/presentation/views/class/student/student_class_list_screen.dart`)

**Mục đích:** Danh sách lớp học của sinh viên.

**Chức năng:**
- Hiển thị danh sách lớp học đã tham gia
- Tìm kiếm lớp học
- Tham gia lớp học mới

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.studentClassList);
```

**ViewModel:** `StudentClassListViewModel`
- `loadClasses()` - Tải danh sách lớp
- `searchClasses(String query)` - Tìm kiếm
- `joinClass(String classCode)` - Tham gia lớp

**Responsive:**
- Grid layout responsive (1-2-3 columns)
- Search bar tự động điều chỉnh

#### Join Class Screen (`lib/presentation/views/class/student/join_class_screen.dart`)

**Mục đích:** Màn hình tham gia lớp học bằng mã code hoặc QR.

**Chức năng:**
- Nhập mã lớp học
- Quét QR code
- Validation và join class

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.joinClass);
```

**QR Scan Screen:** `qr_scan_screen.dart`
- Quét QR code để lấy mã lớp
- Tự động join sau khi quét

#### Teacher Class List (`lib/presentation/views/class/teacher/teacher_class_list_screen.dart`)

**Mục đích:** Danh sách lớp học của giáo viên.

**Chức năng:**
- Hiển thị danh sách lớp đã tạo
- Tạo lớp mới
- Chỉnh sửa lớp
- Quản lý sinh viên

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.teacherClassList);
```

#### Create Class Screen (`lib/presentation/views/class/teacher/create_class_screen.dart`)

**Mục đích:** Tạo lớp học mới.

**Chức năng:**
- Form tạo lớp học
- Validation
- Tạo mã lớp tự động
- Generate QR code

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.createClass);
```

**ViewModel:** `CreateClassViewModel`
- `createClass(String name, String description)` - Tạo lớp
- `generateClassCode()` - Tạo mã lớp
- `generateQRCode()` - Tạo QR code

---

### Assignment Screens

#### Assignment List Screen (`lib/presentation/views/assignment/assignment_list_screen.dart`)

**Mục đích:** Danh sách bài tập.

**Chức năng:**
- Hiển thị danh sách bài tập
- Lọc theo trạng thái
- Tìm kiếm bài tập
- Xem chi tiết bài tập

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.assignmentList);
```

**ViewModel:** `AssignmentListViewModel`
- `loadAssignments()` - Tải danh sách
- `filterByStatus(Status status)` - Lọc
- `searchAssignments(String query)` - Tìm kiếm

**Responsive:**
- List layout responsive
- Filter chips tự động wrap

---

### Grading Screens

#### Scores Screen (`lib/presentation/views/grading/scores_screen.dart`)

**Mục đích:** Xem điểm số của sinh viên.

**Chức năng:**
- Hiển thị điểm số theo môn học
- Thống kê điểm trung bình
- Lọc theo môn học
- Xem chi tiết từng bài kiểm tra

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.scores);
```

**ViewModel:** `ScoresViewModel`
- `loadScores()` - Tải điểm số
- `filterBySubject(String subject)` - Lọc theo môn

---

### Profile Screen

#### Profile Screen (`lib/presentation/views/profile/profile_screen.dart`)

**Mục đích:** Quản lý thông tin cá nhân.

**Chức năng:**
- Xem thông tin cá nhân
- Chỉnh sửa profile
- Upload avatar
- Đổi mật khẩu
- Đăng xuất

**Setup:**
```dart
Navigator.pushNamed(context, AppRoutes.profile);
```

**ViewModel:** `ProfileViewModel`
- `loadProfile()` - Tải thông tin
- `updateProfile(Profile profile)` - Cập nhật
- `uploadAvatar(File image)` - Upload avatar
- `changePassword(String oldPassword, String newPassword)` - Đổi mật khẩu
- `logout()` - Đăng xuất

---

## Navigation

### Routes (`lib/core/routes/app_routes.dart`)

Tất cả routes được định nghĩa trong `AppRoutes`:

```dart
// Authentication
AppRoutes.login
AppRoutes.register

// Dashboard
AppRoutes.studentDashboard
AppRoutes.teacherDashboard

// Classes
AppRoutes.studentClassList
AppRoutes.joinClass
AppRoutes.teacherClassList
AppRoutes.createClass

// Assignments
AppRoutes.assignmentList

// Profile
AppRoutes.profile
```

### Navigation Pattern

```dart
// Push named route
Navigator.pushNamed(context, AppRoutes.targetScreen);

// Push with arguments
Navigator.pushNamed(
  context,
  AppRoutes.targetScreen,
  arguments: arguments,
);

// Pop
Navigator.pop(context);
```

---

## State Management

### Provider Pattern

Tất cả ViewModels được register trong `main.dart`:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthViewModel(...)),
    ChangeNotifierProvider(create: (_) => StudentDashboardViewModel(...)),
    // ... other providers
  ],
  child: MyApp(),
)
```

### Sử dụng ViewModel trong Screen

```dart
// Read ViewModel
final viewModel = context.read<ViewModel>();

// Watch ViewModel (rebuild khi state thay đổi)
Consumer<ViewModel>(
  builder: (context, viewModel, child) {
    return Text(viewModel.data);
  },
)
```

---

## Responsive Design

Tất cả screens nên sử dụng responsive system:

1. **Wrap với ResponsiveScreen** (cho screens mới)
2. **Sử dụng ResponsiveWidgets** (ResponsiveText, ResponsiveCard, etc.)
3. **Sử dụng ResponsiveUtils** để lấy config
4. **Test trên multiple screen sizes**

Xem chi tiết trong [responsive-system-guide.md](./responsive-system-guide.md).

---

## Error Handling

### Pattern chung

```dart
try {
  await viewModel.performAction();
} catch (e) {
  // Hiển thị error dialog hoặc snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}
```

### Error từ ViewModel

```dart
Consumer<ViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.errorMessage != null) {
      return ErrorWidget(viewModel.errorMessage!);
    }
    return ContentWidget();
  },
)
```

---

## Loading States

### Pattern chung

```dart
Consumer<ViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return ContentWidget();
  },
)
```

---

## Best Practices

1. **Luôn sử dụng Design Tokens** cho colors, spacing, typography
2. **Sử dụng Responsive System** cho tất cả screens
3. **Tách widget** nếu function > 50 dòng
4. **Error handling** phải có trong mọi async operations
5. **Loading states** phải được hiển thị rõ ràng
6. **Validation** form phải được thực hiện
7. **Const constructors** khi có thể
8. **Code formatting** với `dart format`

---

## Testing

### Test trên các device sizes

- Mobile: 375x667 (iPhone SE)
- Tablet: 768x1024 (iPad)
- Desktop: 1920x1080

### Test checklist

- [ ] Layout hiển thị đúng trên mobile
- [ ] Layout hiển thị đúng trên tablet
- [ ] Layout hiển thị đúng trên desktop
- [ ] Navigation hoạt động đúng
- [ ] Error handling hoạt động
- [ ] Loading states hiển thị đúng
- [ ] Pull-to-refresh hoạt động (nếu có)

---

## Troubleshooting

### Vấn đề: Screen không responsive

**Giải pháp:** Đảm bảo sử dụng ResponsiveScreen wrapper và responsive widgets.

### Vấn đề: Navigation không hoạt động

**Giải pháp:** Kiểm tra route đã được định nghĩa trong AppRoutes và register trong main.dart.

### Vấn đề: ViewModel không update UI

**Giải pháp:** Đảm bảo gọi `notifyListeners()` sau mỗi state change và sử dụng Consumer.

---

## Tài liệu tham khảo

- Responsive System: [responsive-system-guide.md](./responsive-system-guide.md)
- Design Tokens: `lib/core/constants/design_tokens.dart`
- Routes: `lib/core/routes/app_routes.dart`
- Plan File: `.cursor/plans/bảng_kế_hoạch_tổng_quát_ai_lms_b4a74f53.plan.md`
