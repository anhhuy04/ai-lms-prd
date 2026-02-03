---
name: class-module-next-steps
overview: ""
todos: []
---

# Kế hoạch hoàn thiện module lớp học (4 hạng mục)

## 1. Hoàn thiện flow tham gia lớp bằng mã (student)

- **Phân tích & thiết kế API**
  - Xác định rõ contract giữa `join_code` và `classId` (kiểu dữ liệu, unique, thời hạn, trạng thái hoạt động).
  - Thiết kế method mới trong repository, ví dụ: `Future<Class?> getClassByJoinCode(String joinCode)`.
- **Cập nhật tầng domain/infrastructure**
  - Thêm method tương ứng trong repository interface & implementation (remote API hoặc local mock).
  - Đảm bảo xử lý rõ các lỗi: mã không tồn tại, mã hết hạn, lớp bị khóa, vượt quá `manual_join_limit`.
- **Cập nhật `ClassNotifier`** (`lib/presentation/providers/class_notifier.dart`)
  - Thêm hàm public sử dụng repository mới (vd: `resolveClassByJoinCode`) để các màn UI gọi.
  - Cập nhật `requestJoinClass` (nếu cần) để làm việc với `classId` thực thay vì `classCode` tạm.
- **Chỉnh `JoinClassScreen`** (`lib/presentation/views/class/student/join_class_screen.dart`)
  - Thay đoạn TODO ở `_joinClass` để:
    - Gọi hàm resolve `join_code → class`.
    - Nếu không tìm thấy hoặc bị chặn, show SnackBar với message cụ thể.
    - Nếu hợp lệ, gọi `requestJoinClass` với `classId` thật.
  - Bổ sung loading/error state hợp lý, tránh dùng `BuildContext` khi widget đã dispose.
```mermaid
flowchart TD
  student[Student] --> enterCode["Nhập join_code ở JoinClassScreen"]
  enterCode --> callResolve[resolveClassByJoinCode(join_code)]
  callResolve -->|Không tồn tại/hết hạn| showError["SnackBar lỗi"]
  callResolve -->|OK| callRequestJoin[requestJoinClass(classId, studentId)]
  callRequestJoin -->|Yêu cầu chờ duyệt| showPending["SnackBar: Đã gửi yêu cầu"]
  callRequestJoin -->|Lỗi khác| showJoinError["SnackBar lỗi tham gia"]
```


## 2. Kết nối `StudentListScreen` với dữ liệu thật

- **Thiết kế model & source dữ liệu**
  - Dùng entity member hiện có (vd: `ClassMember`) hoặc tạo mới nếu thiếu (kiểm tra ở `domain/entities`).
  - Đảm bảo có các field: `id`, `studentId`, `name`, `avatarUrl`, `status`, `role`, `joinedAt`.
- **Mở rộng repository & notifier**
  - Bổ sung method lấy danh sách member cho lớp: `Future<List<ClassMember>> getClassMembers(String classId, {String? status})`.
  - Thêm method duyệt / từ chối: `approveMember`, `rejectMember` hoặc `removeMember` trong repository + `ClassNotifier`.
- **Refactor `StudentListScreen` UI** (`lib/presentation/views/class/teacher/student_list_screen.dart`)
  - Chuyển từ list mock `_students` sang state lấy từ Riverpod (`ConsumerStatefulWidget` hoặc dùng `Consumer`/`HookConsumer`):
    - Load data khi vào màn hình (vd: `initState` gọi notifier → state AsyncValue).
    - Render `loading/error/empty` states.
  - Cập nhật `_approveStudent` và `_rejectStudent` để gọi notifier thay vì chỉ sửa list local.
  - Giữ nguyên UX hiện tại (search bar, filter tabs) nhưng filter trên list từ state.
```mermaid
flowchart TD
  teacher[Teacher] --> openScreen["Mở StudentListScreen(classId)"]
  openScreen --> loadMembers[getClassMembers(classId)]
  loadMembers --> uiList[Render danh sách theo filter]
  uiList --> approveAction[Tap duyệt]
  uiList --> rejectAction[Tap từ chối]
  approveAction --> callApprove[approveMember(memberId)]
  rejectAction --> callReject[rejectMember/removeMember(memberId)]
  callApprove --> refreshList[Reload/Update state]
  callReject --> refreshList
```


## 3. Hoàn thiện flow QR join class

- **Thiết kế màn `studentQrScan`**
  - Tạo (hoặc hoàn thiện) screen `StudentQrScanScreen` trong `lib/presentation/views/class/student/`.
  - Tích hợp lib quét QR (VD: `mobile_scanner` hoặc `qr_code_scanner`), kiểm tra permission camera.
- **Chuẩn hóa format dữ liệu QR**
  - Thống nhất 1 trong 2 format chính: 
    - Deep-link (`https://app.example.com/join-class/<classId or join_code>`), hoặc
    - Raw `join_code`.
  - Implement parse function: nhận string từ QR → trả về `joinCode` (hoặc `classId`).
- **Tái sử dụng logic join**
  - Trên `StudentQrScanScreen`, sau khi scan thành công:
    - Parse dữ liệu.
    - Gọi chung 1 hàm join (có thể trích `_joinClassLogic` riêng trong `JoinClassScreen` hoặc tạo service dùng chung) để tránh duplicate.
  - Xử lý UI: overlay khung quét, trạng thái "đang quét", chặn scan nhiều lần.
- **Cập nhật `ClassSettingsDrawerHandlers.showShareClassDialog`** (`lib/presentation/views/class/teacher/widgets/drawers/class_settings_drawer_handlers.dart`)
  - Thay container placeholder QR bằng widget sinh QR thật từ `classLink`/`joinCode` (vd: `QrImageView(data: classLink)`).
  - Đảm bảo `classLink` khớp với cách `StudentQrScan` parse.

## 4. Rà soát navigation & phân quyền route

- **Kiểm tra GoRouter config**
  - Mở file cấu hình router chính (vd: `lib/core/routes/app_router.dart`):
    - Đảm bảo có đầy đủ entries cho `AppRoute.studentJoinClass`, `studentQrScan`, `teacherStudentList`, `teacherClassDetail`…
    - Kiểm tra `name` trùng với hằng số trong `AppRoute`.
- **Áp dụng `AppRoute.canAccessRoute`** (`lib/core/routes/route_constants.dart`)
  - Ở middleware/redirect logic của GoRouter, dùng `canAccessRoute(role, state.name)` để chặn route không đúng role.
  - Định nghĩa luồng redirect rõ: nếu bị chặn → đi đến `AppRoute.forbidden` hoặc dashboard phù hợp.
- **Test luồng điều hướng chính**
  - Student:
    - Từ dashboard → `student-class-list` → `student-join-class` → gửi request → back.
    - Scan QR → join.
  - Teacher:
    - Từ `teacher-class-list` → `teacher-class-detail` → open `teacher-student-list` → duyệt/từ chối học sinh.
  - Đảm bảo không role nào truy cập nhầm màn của role khác bằng URL tay.

---

## TODO chi tiết

- **join-class-flow**: Thiết kế & implement API/method `join_code → classId`, cập nhật `ClassNotifier` và logic `_joinClass` trong `JoinClassScreen` để dùng `classId` thật và xử lý đầy đủ case lỗi.
- **student-list-integration**: Kết nối `StudentListScreen` với repository/notifier, thay list mock bằng dữ liệu thật, implement approve/reject thật với state Riverpod và các trạng thái loading/error/empty.
- **qr-join-flow**: Tạo/hoàn thiện màn `StudentQrScanScreen`, chuẩn hóa format dữ liệu QR + parse, sinh QR thật trong `ClassSettingsDrawerHandlers.showShareClassDialog` và tái sử dụng chung logic join.
- **route-guarding-and-nav**: Rà lại cấu hình