# Widgets Directory Structure

Mục tiêu: mô tả **các widget dùng chung** trong `lib/widgets/` và hướng dẫn nơi đặt widget theo feature.

## Quy ước phân loại

- `lib/widgets/`: **shared/reusable UI** (không chứa logic nghiệp vụ theo feature).
- `lib/presentation/views/**/widgets/`: widget **gắn với 1 feature/screen** (đặc biệt là drawers theo role).

## Cấu trúc thư mục

```
lib/widgets/
├── buttons/          # Button widgets (quick_action_button, etc.)
├── cards/            # Card widgets (base_card, statistics_card, etc.)
├── dialogs/          # Dialog widgets (error, success, warning, etc.)
├── drawers/          # Shared drawer primitives (action tiles, toggle tiles, etc.)
├── list/             # List container widgets
├── list_item/        # Individual list item widgets
│   ├── class/        # Class-related list items
│   └── assignment/   # Assignment-related list items
├── loading/          # Loading states (shimmer, skeletons, etc.)
├── navigation/       # Navigation handlers và utilities
├── responsive/       # Responsive layout widgets
├── search/           # Search-related widgets (screens, dialogs, fields)
└── text/             # Text utilities (highlight, marquee, etc.)
```

## 1) Buttons (`lib/widgets/buttons/`)

Button widgets dùng chung:

- `quick_action_button.dart`: Quick action button với các variants (primary, gradient, default)

## 2) Cards (`lib/widgets/cards/`)

Card widgets dùng chung:

- `base_card.dart`: Base card widget với icon, label và số lượng (tái sử dụng cho nhiều loại card)
- `statistics_card.dart`: Statistics card với label và value (có border, layout đơn giản)

## 3) Dialogs (`lib/widgets/dialogs/`)

Các dialog widgets dùng chung cho toàn app:

- `error_dialog.dart`: Error dialogs
- `success_dialog.dart`: Success dialogs
- `warning_dialog.dart`: Confirm/unsaved/save flows
- `flexible_dialog.dart`: Dialog wrapper linh hoạt
- `delete_confirmation_dialog.dart`: Xác nhận xóa (được dùng trong teacher class drawer)

## 4) Drawers (`lib/widgets/drawers/`)

### Shared drawer primitives (giữ ở `lib/widgets/drawers/`)

- `action_end_drawer.dart`: Khung drawer bên phải (`Scaffold.endDrawer`) + header
- `drawer_action_tile.dart`: Tile hành động (icon + title + subtitle + chevron)
- `drawer_section_header.dart`: Header section trong drawer
- `drawer_toggle_tile.dart`: Tile toggle (switch) trong drawer

### Feature drawers (đã chuyển về gần screens)

- Teacher class drawers:
  - `lib/presentation/views/class/teacher/widgets/drawers/class_settings_drawer.dart`: Drawer "Tùy chọn lớp học" cho giáo viên
  - `lib/presentation/views/class/teacher/widgets/drawers/class_create_class_setting_drawer.dart`: Drawer cài đặt nâng cao cho màn hình tạo lớp học

- Student class drawers:
  - `lib/presentation/views/class/student/widgets/drawers/student_class_settings_drawer.dart`: Drawer "Tùy chọn lớp học" cho học sinh

## 5) List (`lib/widgets/list/`)

Container widgets cho danh sách:

- `class_detail_assignment_list.dart`: Container list bài tập trong class detail (hỗ trợ teacher/student view mode)

## 6) List Item (`lib/widgets/list_item/`)

Widgets hiển thị từng item trong danh sách, được tổ chức theo feature:

### Class Items (`lib/widgets/list_item/class/`)
- `class_item_widget.dart`: Item lớp học trong danh sách (hỗ trợ highlight khi search)
- `class_status_badge.dart`: Badge trạng thái lớp học

### Assignment Items (`lib/widgets/list_item/assignment/`)
- `class_detail_assignment_list_item.dart`: Item bài tập trong class detail (teacher/student view mode)

## 7) Loading (`lib/widgets/loading/`)

Widgets hiển thị trạng thái loading:

- `shimmer_loading.dart`: Shimmer loading skeleton cho danh sách

## 8) Navigation (`lib/widgets/navigation/`)

Navigation handlers và utilities:

- `back_button_handler.dart`: Xử lý nút back vật lý cho toàn app (ngăn app tự động thoát, điều hướng về dashboard)

## 9) Responsive (`lib/widgets/responsive/`)

Widgets hỗ trợ responsive layout:

- `responsive_card.dart`: Card responsive
- `responsive_container.dart`: Container responsive
- `responsive_grid.dart`: Grid responsive
- `responsive_padding.dart`: Padding responsive
- `responsive_row.dart`: Row responsive
- `responsive_screen.dart`: Screen wrapper responsive
- `responsive_text.dart`: Text responsive

## 10) Search (`lib/widgets/search/`)

Tất cả widgets liên quan đến tìm kiếm:

- **Search Screens (full-screen, config-driven)**:
  - `screens/core/search_screen_config.dart`: `SearchScreenConfig<T>` – cấu hình chung (title, hint, providers, itemBuilder, onItemTap, debounceKey...)
  - `screens/ui/search_screen.dart`: `SearchScreen<T>` – UI khung search full-screen, đọc config và render list/pagination

- **Quick Search Dialogs (overlay)**:
  - `dialogs/quick_search_dialog.dart`: `QuickSearchDialog` – dialog tìm kiếm overlay (teacher/student class screens)
  - `dialogs/quick_search_recent_section.dart`: `QuickSearchRecentSection` – section hiển thị “Gần đây”
  - `dialogs/quick_search_result_item.dart`: `QuickSearchResultItem` – item kết quả (có highlight theo query)

- **Shared**:
  - `shared/search_field.dart`: `SearchField` – widget UI thanh tìm kiếm (dùng chung cho nhiều màn)
  - (các helper/utils khác dùng chung cho toàn bộ search)

## 11) Text (`lib/widgets/text/`)

Text utility widgets:

- `smart_highlight_text.dart`: Highlight text với từ khóa tìm kiếm (hỗ trợ tiếng Việt không dấu)
- `smart_marquee_text.dart`: Marquee/scroll text tự động khi text quá dài

## Hướng dẫn sử dụng

### Khi nào đặt widget ở `lib/widgets/`?

- Widget được sử dụng ở **nhiều feature/screen khác nhau**
- Widget **không chứa logic nghiệp vụ** cụ thể cho một feature
- Widget là **UI component tái sử dụng** (button, card, input, etc.)

### Khi nào đặt widget ở `lib/presentation/views/**/widgets/`?

- Widget **chỉ được sử dụng trong một feature/screen cụ thể**
- Widget **chứa logic nghiệp vụ** của feature đó
- Widget là **feature-specific** (ví dụ: class settings drawer cho teacher, assignment cards cho teacher hub)

**Ví dụ:**
- `lib/presentation/views/assignment/teacher/widgets/` - Widgets riêng cho teacher assignment hub
- `lib/presentation/views/class/teacher/widgets/` - Widgets riêng cho teacher class screens
- `lib/presentation/views/class/student/widgets/` - Widgets riêng cho student class screens

### Ví dụ

✅ **Đúng**: `lib/widgets/list_item/class/class_item_widget.dart`
- Được dùng trong nhiều màn hình (class list, search, etc.)
- Không chứa logic nghiệp vụ cụ thể
- Có thể dùng cho cả teacher và student

✅ **Đúng**: `lib/widgets/cards/base_card.dart`
- Widget generic có thể tái sử dụng
- Không chứa logic nghiệp vụ cụ thể

✅ **Đúng**: `lib/presentation/views/class/teacher/widgets/drawers/class_settings_drawer.dart`
- Chỉ dùng trong teacher class detail screen
- Chứa logic nghiệp vụ cụ thể cho teacher class settings

✅ **Đúng**: `lib/presentation/views/assignment/teacher/widgets/activity_overview_card.dart`
- Chỉ dùng trong teacher assignment hub screen
- Sử dụng BaseCard nhưng có logic riêng cho assignment context

## Best Practices

1. **Tổ chức theo chức năng**: Gom các widget liên quan vào cùng một thư mục
2. **Đặt tên rõ ràng**: Tên file và class phải mô tả rõ chức năng
3. **Tái sử dụng**: Ưu tiên tạo widget generic có thể tái sử dụng
4. **Tách biệt concerns**: Tách UI components và logic nghiệp vụ
5. **Cập nhật README**: Luôn cập nhật README khi thêm/sửa/xóa widget
