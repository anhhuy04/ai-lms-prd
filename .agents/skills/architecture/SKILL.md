---
name: architecture
description: "Kích hoạt khi thiết kế luồng module mới, cấu trúc thư mục feature, hoặc giao tiếp giữa Presentation, Domain và Data (Clean Architecture + DDD)."
---

# Kỹ năng: Kiến trúc Clean Architecture (Feature-based)

Áp dụng quy tắc cấu trúc thư mục sau khi tạo mới tính năng:

## 1. Cấu trúc thư mục (Feature-based)
Bất kỳ feature nào cũng nằm trong `lib/features/[tên_feature]/`:
- `domain/` (Cốt lõi)
  - `entities/`: Các class không phụ thuộc framework dính annotation `@freezed` (tùy chọn).
  - `repositories/`: Abstract classes (Interfaces) quy định các hàm fetch data.
  - `usecases/`: (Tùy chọn) Logic nghiệp vụ phức tạp.
- `data/` (Triển khai)
  - `datasources/`: Các class gọi API trực tiếp (Supabase, Dio).
  - `models/` (DTOs): Object dùng nội bộ Data layer để map JSON (nếu không map thẳng Entity).
  - `repositories/`: RepositoryImpl implements các interface phía Domain.
- `presentation/` (Giao diện & Trạng thái)
  - `providers/`: Nơi chứa Riverpod `@riverpod` hoặc `Notifier`.
  - `screens/` (hoặc `views/`): Smart widgets nhận state từ providers.
  - `widgets/`: Dumb widgets (Nhận data qua tham số, không gọi provider).

## 2. Ranh giới (Boundaries)
- **Presentation** chỉ gọi tới **Domain** (Thông qua interface Repo hoặc UseCase) hoặc tương tác Provider.
- **Data** implement **Domain**, phụ thuộc Domain.
- **TUYỆT ĐỐI CẤM** Presentation import các file từ Data layer (chẳng hạn không gọi trực tiếp Supabase từ widget).
- **TUYỆT ĐỐI CẤM** Data models chứa UI logic (Colors, TextStyles).

## 3. Phân biệt DTO và Entity
- Các dữ liệu trả về từ API rác (chứa các trường thừa thãi) -> dùng DTO để hứng JSON (Data Layer).
- Sau đó có hàm `toDomain()` để map thành Entity sạch (Domain Layer) trả về cho UI.
