# Context Reading Protocol

## Tổng quan

Protocol này đảm bảo AI agent luôn đọc đúng tài liệu liên quan trước khi thực hiện bất kỳ task nào, đặc biệt là khi làm việc với UI/giao diện.

## Workflow chuẩn

### Bước 1: Phân tích lệnh người dùng

Khi nhận lệnh, xác định category của task:

| Category | Mô tả | Tài liệu cần đọc |
|----------|-------|-----------------|
| **UI/Giao diện** | Sửa file trong `lib/presentation/views/`, `lib/widgets/` | `memory-bank/DESIGN_SYSTEM_GUIDE.md`<br>`memory-bank/systemPatterns.md` (Design System section)<br>`lib/core/constants/design_tokens.dart` |
| **Database/Repository** | Tạo/sửa repository, datasource, model | `memory-bank/systemPatterns.md` (Data Layer section)<br>`docs/ai/README_SUPABASE.md`<br>Supabase MCP để check schema |
| **State Management** | Tạo/sửa ViewModel, Provider | `memory-bank/systemPatterns.md` (State Management section)<br>`.cursor/.cursorrules` (Tech Stack section) |
| **Architecture** | Refactor, tạo layer mới | `docs/ai/AI_INSTRUCTIONS.md` (Section 2)<br>`memory-bank/systemPatterns.md` (Architecture section) |
| **Thư viện mới** | Thêm/sử dụng thư viện mới | MCP Fetch để đọc documentation từ pub.dev |

### Bước 2: Đọc tài liệu liên quan

Sử dụng `read_file` tool để đọc các file cần thiết:

```dart
// Ví dụ: Task về UI
read_file('memory-bank/DESIGN_SYSTEM_GUIDE.md')
read_file('memory-bank/systemPatterns.md') // Design System section
read_file('lib/core/constants/design_tokens.dart')
```

### Bước 3: Kiểm tra patterns hiện tại

Sử dụng `codebase_search` hoặc `grep` để tìm patterns tương tự:

```dart
// Ví dụ: Tìm cách sử dụng DesignTokens
codebase_search("How are DesignTokens used in widgets?")
grep("DesignColors\\.", path: "lib/widgets")
```

### Bước 4: Thực hiện task

Thực hiện task theo đúng patterns và standards đã đọc.

### Bước 5: Cập nhật memory-bank (nếu cần)

Nếu có thay đổi quan trọng, cập nhật:
- `memory-bank/activeContext.md` - Recently Completed
- `memory-bank/progress.md` - What Works
- `memory-bank/systemPatterns.md` - Nếu có pattern mới

## Quy tắc đặc biệt

### UI/Giao diện

**BẮT BUỘC đọc trước khi sửa:**
1. `memory-bank/DESIGN_SYSTEM_GUIDE.md`
2. `memory-bank/systemPatterns.md` (Design System Specifications section)
3. `lib/core/constants/design_tokens.dart`

**BẮT BUỘC tuân thủ:**
- ✅ Sử dụng `DesignColors.*` thay vì hardcode màu
- ✅ Sử dụng `DesignSpacing.*` thay vì hardcode spacing
- ✅ Sử dụng `DesignTypography.*` thay vì custom font sizes
- ✅ Sử dụng `DesignIcons.*` cho icon sizes
- ✅ Sử dụng `DesignRadius.*` cho border radius
- ✅ Sử dụng `DesignElevation.level*` cho shadows
- ✅ Tuân thủ Component Standards (button heights, input heights, etc.)
- ✅ Sử dụng `flutter_screenutil` cho responsive design
- ✅ Đảm bảo accessibility (contrast, touch targets)

### Database/Repository

**BẮT BUỘC:**
1. Sử dụng Supabase MCP để check schema trước khi tạo model
2. Đọc `memory-bank/systemPatterns.md` (Data Layer section)
3. Đọc `docs/ai/README_SUPABASE.md` để hiểu schema

### State Management

**BẮT BUỘC:**
1. Đọc `.cursor/.cursorrules` (Tech Stack section) để biết thư viện nào dùng
2. Ưu tiên Riverpod với `@riverpod` generator cho features mới
3. Đọc `memory-bank/systemPatterns.md` (State Management section)

### Thư viện mới

**BẮT BUỘC:**
1. Sử dụng MCP Fetch để đọc documentation từ pub.dev
2. Kiểm tra examples và best practices
3. Đảm bảo thư viện phù hợp với tech stack trong `.cursor/.cursorrules`

## Ví dụ

### Ví dụ 1: Sửa UI Screen

**Lệnh:** "Thêm button vào LoginScreen"

**Workflow:**
1. Phân tích: Category = UI/Giao diện
2. Đọc:
   - `memory-bank/DESIGN_SYSTEM_GUIDE.md`
   - `lib/core/constants/design_tokens.dart`
   - `memory-bank/systemPatterns.md` (Design System section)
3. Kiểm tra: Tìm cách buttons được implement trong các screens khác
4. Thực hiện: Sử dụng `DesignColors.primary`, `DesignSpacing.lg`, `DesignTypography.labelMedium`
5. Cập nhật: Nếu có pattern mới, cập nhật memory-bank

### Ví dụ 2: Tạo Repository mới

**Lệnh:** "Tạo AssignmentRepository"

**Workflow:**
1. Phân tích: Category = Database/Repository
2. Đọc:
   - `memory-bank/systemPatterns.md` (Data Layer section)
   - `docs/ai/README_SUPABASE.md`
3. Kiểm tra: Sử dụng Supabase MCP để check schema của bảng `assignments`
4. Thực hiện: Tạo repository theo pattern Clean Architecture
5. Cập nhật: Cập nhật `memory-bank/activeContext.md`

## Checklist

Trước khi bắt đầu task, đảm bảo:

- [ ] Đã xác định category của task
- [ ] Đã đọc tài liệu liên quan từ memory-bank hoặc docs
- [ ] Đã kiểm tra patterns hiện tại trong codebase
- [ ] Đã hiểu rõ standards và patterns cần tuân thủ
- [ ] Đã sử dụng MCP nếu được yêu cầu
- [ ] Đã chọn đúng thư viện từ tech stack

## Related Documentation

- [Design System Guide](../memory-bank/DESIGN_SYSTEM_GUIDE.md)
- [System Patterns](../memory-bank/systemPatterns.md)
- [Tech Context](../memory-bank/techContext.md)
- [.clinerules](../../.clinerules) - Mandatory Context Reading Protocol section
