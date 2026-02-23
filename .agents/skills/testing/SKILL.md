---
name: testing
description: "Kích hoạt khi được yêu cầu viết, sửa chữa hoặc phân tích Test (Unit/Widget/Integration). Chứa các quy tắc mocktail, Arrange-Act-Assert, Robot Pattern và chống anti-patterns."
---

# Kỹ năng: Kiểm thử (Testing)

Tuân thủ các chuẩn sau khi viết bất kỳ loại Test nào:

## 1. Chuẩn chung (The Iron Law)
- **TDD (Test-Driven Development)**: Không viết code logic nếu chưa có test thất bại (Red-Green-Refactor).
- **Isolation**: BẮT BUỘC mock toàn bộ external dependencies (API, DB, SharedPreferences). Không gọi API thật trong Unit/Widget test.
- **Pattern AAA**: Viết comment rõ ràng `// ARRANGE`, `// ACT`, `// ASSERT` trong mỗi block test.
- **Khẳng định (Assertions)**: CẤM viết test không có `expect()`.

## 2. Unit Testing với Mocktail
- Dùng `mocktail` thay vì `mockito` để tương thích Null Safety tốt nhất.
- Khai báo: `class MockRepo extends Mock implements Repository {}`
- Nếu dùng `any()`, ĐỪNG QUÊN gọi `registerFallbackValue(DummyObject());` trong `setUpAll()`.
- Tránh hardcode object rác. Dùng pattern `Test Data Builder` (vd: `UserBuilder().withId('1').build()`).

## 3. Widget & Integration Testing
- **Widget Test**: Luôn bọc widget cần test trong `MaterialApp` hoặc `CupertinoApp` để cấp đủ context. Bắt buộc test cả trạng thái Error/Loading/Empty.
- **Robot Pattern**: Viết POM (Page Object Model) để gom các hàm test giao diện (vd: `robot.tapLoginButton()`).
- **Integration Test**: Dùng Patrol nếu test luồng native (Permission, Notifications), hoặc integration_test gốc cho luồng thuần Flutter.

## 4. Anti-Patterns (Tuyệt đối Cấm)
- CẤM test thư viện bên thứ 3 (Test code bạn gọi thư viện, không test internal của nó).
- CẤM assert `length`. Phải dùng Matcher đặc thù: `expect(list, hasLength(1))` thay vì `expect(list.length, 1)`.
- Khi test Async / Stream: Phải chờ bằng `await expectLater(stream, emits(value));`
