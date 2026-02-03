# Hệ thống Dialog Linh hoạt cho AI LMS

Hệ thống dialog mới được thiết kế để thay thế và mở rộng các dialog hiện có trong ứng dụng AI LMS. Hệ thống này cung cấp các dialog linh hoạt, tái sử dụng được với hỗ trợ responsive design và tuân thủ hoàn toàn Design System.

## Cấu trúc thư mục

```
lib/widgets/dialogs/
├── flexible_dialog.dart        # Widget dialog linh hoạt chính
├── success_dialog.dart         # Dialog thành công với các biến thể
├── warning_dialog.dart         # Dialog cảnh báo với các biến thể
├── error_dialog.dart           # Dialog lỗi với các biến thể
├── dialog_examples.dart        # Ví dụ sử dụng và demo screen
└── README.md                  # Tài liệu này
```

## Tính năng chính

### 1. FlexibleDialog - Widget cơ bản

Widget dialog linh hoạt hỗ trợ:

- **5 loại dialog**: success, warning, error, info, confirm
- **Responsive design**: Tự động điều chỉnh kích thước theo màn hình
  - Mobile: 80% chiều rộng (mặc định), max 560px
  - Tablet: 70% chiều rộng, max 480px
  - Desktop: 50% chiều rộng, max 560px
- **Button Layout**: 
  - 2 nút: Hiển thị trên cùng 1 dòng
    - Nút đồng ý (primary): Bên trái, có màu nền
    - Nút không đồng ý (secondary): Bên phải, không màu nền, chỉ chữ có màu
  - Nhiều hơn 2 nút: Hiển thị dọc
- **Barrier Dismiss**: Khi bấm ra ngoài dialog, dialog sẽ đóng và trả về `null` (hủy)
- **Dark mode**: Tự động hỗ trợ
- **Animation**: Hiệu ứng fade và scale mượt mà
- **Multiple actions**: Hỗ trợ lên đến 3 nút hành động

### 2. Các biến thể dialog chuyên dụng

#### SuccessDialog
```dart
// Dialog thành công đơn giản
SuccessDialog.showSimple(
  context: context,
  title: 'Thành công',
  message: 'Dữ liệu đã được lưu.',
);

// Dialog thành công với chi tiết (theo thiết kế HTML gốc)
SuccessDialog.showWithDetails(
  context: context,
  title: 'Đã duyệt thành công',
  message: 'Học sinh Nguyễn Văn A đã được thêm vào lớp.',
  onViewDetails: () => navigateToStudentProfile(),
);
```

#### WarningDialog
```dart
// Dialog cảnh báo xác nhận
WarningDialog.showConfirmation(
  context: context,
  title: 'Cảnh báo',
  message: 'Bạn có chắc chắn muốn xóa?',
  confirmText: 'Xóa',
  cancelText: 'Hủy',
  isDestructive: true,
);

// Dialog cảnh báo không lưu thay đổi
// Trả về: true nếu chọn "Lưu thay đổi", false nếu chọn "Không lưu", null nếu bấm ra ngoài (hủy)
final result = await WarningDialog.showUnsavedChanges(
  context: context,
);
if (result == true) {
  // User chọn "Lưu thay đổi"
  await saveChanges();
  navigateBack();
} else if (result == false) {
  // User chọn "Không lưu"
  navigateBack();
}
// result == null: User bấm ra ngoài (hủy) → ở lại trang
```

#### ErrorDialog
```dart
// Dialog lỗi đơn giản
ErrorDialog.showSimple(
  context: context,
  title: 'Lỗi',
  message: 'Đã xảy ra lỗi không mong muốn.',
);

// Dialog lỗi mạng với thử lại
ErrorDialog.showNetworkError(
  context: context,
  onRetry: () => reloadData(),
);

// Dialog lỗi với mã lỗi
ErrorDialog.showErrorWithCode(
  context: context,
  errorCode: 'AUTH-403',
  errorMessage: 'Bạn không có quyền truy cập.',
  onDetails: () => showErrorDetails(),
);
```

### 3. Responsive Design

Hệ thống tự động tính toán kích thước dialog dựa trên:

- **Kích thước màn hình**: Sử dụng `MediaQuery` để lấy chiều rộng màn hình
- **Loại thiết bị**: Phân biệt mobile, tablet, desktop
- **Kích thước tối đa**: Giới hạn max-width để đảm bảo trải nghiệm tốt

```dart
// Ví dụ tính toán kích thước
double dialogWidth = screenWidth * percentage;
dialogWidth = dialogWidth.clamp(280.0, 560.0); // Min: 280px, Max: 560px
```

### 4. Hỗ trợ Dark Mode

Tất cả dialog tự động thích ứng với theme hiện tại:

- **Màu nền**: `#1a2632` (dark) / `#FFFFFF` (light)
- **Màu text**: Tự động điều chỉnh cho phù hợp
- **Màu nút**: Giữ nguyên màu sắc chức năng nhưng điều chỉnh text color

## Cách sử dụng

### 1. Import các dialog cần thiết

```dart
import 'package:ai_mls/widgets/dialogs/success_dialog.dart';
import 'package:ai_mls/widgets/dialogs/warning_dialog.dart';
import 'package:ai_mls/widgets/dialogs/error_dialog.dart';
import 'package:ai_mls/widgets/dialogs/flexible_dialog.dart';
```

### 2. Hiển thị dialog

```dart
// Ví dụ: Hiển thị dialog thành công
await SuccessDialog.showSimple(
  context: context,
  title: 'Thành công',
  message: 'Học sinh đã được thêm vào lớp.',
);

// Ví dụ: Hiển thị dialog cảnh báo với xác nhận
final confirmed = await WarningDialog.showConfirmation(
  context: context,
  title: 'Xác nhận xóa',
  message: 'Bạn có chắc chắn muốn xóa bài tập này?',
);

if (confirmed == true) {
  // Thực hiện xóa
}
```

### 3. Tùy chỉnh dialog

```dart
// Sử dụng FlexibleDialog cho thiết kế tùy chỉnh
FlexibleDialog.show(
  context: context,
  title: 'Thông báo',
  message: 'Bạn có muốn lưu thay đổi?',
  type: DialogType.info,
  customIcon: Icons.notifications,
  actions: [
    DialogAction(
      text: 'Lưu',
      onPressed: () => saveChanges(),
      type: DialogActionType.primary,
    ),
    DialogAction(
      text: 'Hủy',
      onPressed: () => Navigator.pop(context),
      type: DialogActionType.secondary,
    ),
  ],
  maxWidth: 400, // Tùy chỉnh kích thước tối đa
);
```

## Best Practices

### 1. Sử dụng biến thể phù hợp

- **SuccessDialog**: Cho các hoạt động thành công (lưu, duyệt, hoàn thành)
- **WarningDialog**: Cho các hành động cần xác nhận (xóa, hủy, bỏ qua)
- **ErrorDialog**: Cho các lỗi và thất bại (mạng, xác thực, hệ thống)
- **FlexibleDialog**: Cho các trường hợp tùy chỉnh đặc biệt

### 2. Message rõ ràng và ngắn gọn

- Tiêu đề: 1 dòng, mô tả trạng thái (Thành công, Lỗi, Cảnh báo)
- Nội dung: 1-2 dòng, giải thích cụ thể
- Tránh text quá dài hoặc phức tạp

### 3. Sử dụng nút hành động phù hợp

- **Primary**: Hành động chính, nổi bật (Xác nhận, Lưu, Thử lại)
- **Secondary**: Hành động phụ, trung tính (Hủy, Đóng)
- **Tertiary**: Hành động thứ ba, nhẹ nhàng (Bỏ qua, Nhắc sau)

### 4. Xử lý kết quả dialog

```dart
// Ví dụ xử lý kết quả từ dialog xác nhận
final shouldDelete = await WarningDialog.showConfirmation(
  context: context,
  title: 'Xác nhận xóa',
  message: 'Bạn có chắc chắn muốn xóa?',
);

if (shouldDelete == true) {
  await deleteItem();
} else {
  // Người dùng đã hủy (result == false) hoặc bấm ra ngoài (result == null)
}

// Ví dụ xử lý dialog không lưu thay đổi
final result = await WarningDialog.showUnsavedChanges(context: context);
if (result == true) {
  // User chọn "Lưu thay đổi" → lưu rồi mới back
  await saveChanges();
  Navigator.pop(context);
} else if (result == false) {
  // User chọn "Không lưu" → back ngay
  Navigator.pop(context);
}
// result == null: User bấm ra ngoài (hủy) → ở lại trang, không làm gì
```

## Ví dụ thực tế

### 1. Dialog duyệt học sinh thành công (theo thiết kế HTML gốc)

```dart
SuccessDialog.showWithDetails(
  context: context,
  title: 'Đã duyệt thành công',
  message: 'Học sinh <b>Nguyễn Văn A</b> đã được thêm vào danh sách lớp học.',
  onViewDetails: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StudentProfileScreen(studentId: studentId),
      ),
    );
  },
);
```

### 2. Dialog xác nhận xóa bài tập

```dart
final confirmed = await WarningDialog.showDeleteConfirmation(
  context: context,
  itemName: 'Bài tập Toán - Chương 1',
  onDelete: () async {
    try {
      await assignmentRepository.deleteAssignment(assignmentId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã xóa bài tập thành công')),
      );
    } catch (e) {
      ErrorDialog.showSimple(
        context: context,
        title: 'Lỗi',
        message: 'Không thể xóa bài tập: ${e.toString()}',
      );
    }
  },
);
```

### 3. Dialog lỗi mạng với thử lại

```dart
ErrorDialog.showNetworkError(
  context: context,
  onRetry: () async {
    try {
      await loadData();
    } catch (e) {
      // Hiển thị lỗi nếu thử lại thất bại
      ErrorDialog.showSimple(
        context: context,
        title: 'Lỗi',
        message: 'Không thể kết nối đến máy chủ.',
      );
    }
  },
);
```

## Tích hợp với dự án hiện tại

### 1. Thay thế dialog hiện có

Tìm và thay thế các dialog hiện có bằng hệ thống mới:

```dart
// Cũ: Sử dụng showDialog trực tiếp
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);

// Mới: Sử dụng hệ thống dialog mới
SuccessDialog.showSimple(
  context: context,
  title: 'Thành công',
  message: 'Hoạt động hoàn tất.',
);
```

### 2. Cập nhật các màn hình hiện có

- **StudentListScreen**: Sử dụng `SuccessDialog` cho xác nhận duyệt học sinh
- **AssignmentScreen**: Sử dụng `WarningDialog` cho xác nhận xóa bài tập
- **AuthScreen**: Sử dụng `ErrorDialog` cho lỗi đăng nhập
- **Dashboard**: Sử dụng `FlexibleDialog` cho thông báo hệ thống

### 3. Testing

Sử dụng `DialogDemoScreen` để test tất cả các loại dialog:

```dart
// Trong file routes của bạn
routes: {
  '/dialog-demo': (context) => DialogDemoScreen(),
}
```

## Tương lai và mở rộng

### 1. Hỗ trợ Rich Text

Hiện tại hệ thống hỗ trợ text đơn giản. Có thể mở rộng để hỗ trợ:

```dart
// Ví dụ tương lai với rich text
SuccessDialog.showWithDetails(
  context: context,
  title: 'Thành công',
  message: RichTextMessage(
    children: [
      TextSpan(text: 'Học sinh '),
      TextSpan(
        text: 'Nguyễn Văn A',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      TextSpan(text: ' đã được thêm vào lớp '),
      TextSpan(
        text: '10A1',
        style: TextStyle(color: DesignColors.primary),
      ),
    ],
  ),
);
```

### 2. Custom Layout

Cho phép tùy chỉnh layout dialog cho các trường hợp đặc biệt:

```dart
FlexibleDialog.show(
  context: context,
  customLayout: (context) => CustomDialogLayout(),
);
```

### 3. Animation tùy chỉnh

Hỗ trợ animation tùy chỉnh cho dialog:

```dart
FlexibleDialog.show(
  context: context,
  transitionBuilder: (context, animation, child) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(0, 1),
        end: Offset(0, 0),
      ).animate(animation),
      child: child,
    );
  },
);
```

## Kết luận

Hệ thống dialog mới cung cấp:

✅ **Linh hoạt**: Hỗ trợ nhiều loại dialog và tùy chỉnh
✅ **Responsive**: Tự động thích ứng với mọi kích thước màn hình
✅ **Design System**: Tuân thủ hoàn toàn design tokens hiện có
✅ **Dễ sử dụng**: API đơn giản và trực quan
✅ **Mở rộng**: Dễ dàng thêm tính năng mới

Hệ thống này sẵn sàng để tích hợp vào dự án AI LMS và thay thế các dialog hiện có.