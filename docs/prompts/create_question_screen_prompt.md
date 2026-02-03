# Prompt: Tạo Màn Hình Tạo Câu Hỏi (Create Question Screen)

## 1. Context & Overview

### Mục đích
Tạo màn hình `CreateQuestionScreen` để giáo viên có thể tạo câu hỏi mới cho bài tập. Màn hình này là một separate screen được mở từ `TeacherCreateAssignmentScreen` và cho phép:

- Tạo câu hỏi trắc nghiệm (Multiple Choice - Single Answer)
- Nhập đầy đủ thông tin câu hỏi (text, images, options, metadata)
- Preview câu hỏi theo góc nhìn học sinh
- Validate và lưu câu hỏi
- Quay lại assignment screen với câu hỏi đã tạo

### User Flow
1. Từ `TeacherCreateAssignmentScreen`, user click "Thêm câu hỏi" → chọn loại câu hỏi
2. Navigate đến `CreateQuestionScreen` với `questionType` parameter
3. User nhập thông tin câu hỏi (text, options, images, etc.)
4. User có thể preview câu hỏi
5. User click "Lưu" → validate → return question data về assignment screen
6. Nếu có unsaved changes và user click back → hiển thị warning dialog

### Integration Points
- **Navigation**: Sử dụng GoRouter với named route `AppRoute.teacherCreateQuestion`
- **Data Flow**: Pass question data qua `context.pop(questionData)` khi save
- **State Management**: Local state với `StatefulWidget`, form validation với `GlobalKey<FormState>`

---

## 2. Design System Specifications

### 2.1 Color Palette

**MUST USE** các tokens từ `DesignColors` class trong `lib/core/constants/design_tokens.dart`:

| Token | Hex Code | Use Case |
|-------|----------|----------|
| `DesignColors.moonLight` | `#F5F7FA` | Scaffold background |
| `DesignColors.white` | `#FFFFFF` | Card background (light mode) |
| `Color(0xFF1A2632)` | `#1A2632` | Card background (dark mode) |
| `DesignColors.primary` | `#4A90E2` | Primary buttons, accents, focus borders |
| `DesignColors.textPrimary` | `#04202A` | Main text color |
| `DesignColors.textSecondary` | `#546E7A` | Secondary text, labels |
| `Colors.grey[200]!` | - | Borders (light mode) |
| `Colors.grey[700]!` | - | Borders (dark mode) |
| `Colors.grey[600]` | - | Label text (light mode) |
| `Colors.grey[400]` | - | Label text (dark mode) |
| `DesignColors.error` | `#EF5350` | Error states, validation errors |
| `DesignColors.success` | `#4CAF50` | Success states |
| `DesignColors.warning` | `#FFA726` | Warning states |

**Rules:**
- ❌ **NEVER** hardcode colors như `Color(0xFF4A90E2)`
- ✅ **ALWAYS** use `DesignColors.primary`, `DesignColors.textPrimary`, etc.
- ✅ Use `isDark` check để switch giữa light/dark mode colors

### 2.2 Spacing Scale

**MUST USE** các tokens từ `DesignSpacing` class:

| Token | Value | Use Case |
|-------|-------|----------|
| `DesignSpacing.xs` | 4dp | Minimal spacing, icon padding |
| `DesignSpacing.sm` | 8dp | Small spacing, list item margins |
| `DesignSpacing.md` | 12dp | Medium spacing, field spacing |
| `DesignSpacing.lg` | 16dp | **STANDARD** - card padding, screen padding |
| `DesignSpacing.xl` | 18dp | Extra large spacing |
| `DesignSpacing.xxl` | 22dp | Section spacing |
| `DesignSpacing.xxxl` | 28dp | Large section separators |

**Semantic Names:**
- `DesignSpacing.screenPadding` = `lg` (16dp) - padding từ screen edges
- `DesignSpacing.cardPadding` = `lg` (16dp) - padding trong cards
- `DesignSpacing.itemSpacing` = `md` (12dp) - spacing giữa list items
- `DesignSpacing.sectionSpacing` = `xxl` (22dp) - spacing giữa sections

**Rules:**
- ❌ **NEVER** hardcode spacing như `EdgeInsets.all(16)`
- ✅ **ALWAYS** use `EdgeInsets.all(DesignSpacing.lg)`
- ✅ Use `context.spacing.lg` cho responsive spacing (tự động scale trên tablet/desktop)

### 2.3 Typography

**MUST USE** các TextStyle từ `DesignTypography` class:

| Style | Font Size | Weight | Line Height | Use Case |
|-------|-----------|--------|-------------|----------|
| `DesignTypography.labelSmallSize` | 11dp | Bold | 1.4 | Field labels (uppercase) |
| `DesignTypography.bodyMedium` | 14dp | Regular | 1.5 | Body text, descriptions |
| `DesignTypography.bodyLarge` | 16dp | Regular | 1.5 | Input text, larger body |
| `DesignTypography.titleLarge` | 18dp | Bold | 1.4 | Screen title, section headers |
| `DesignTypography.titleMedium` | 16dp | Semi-Bold | 1.4 | Card titles |
| `DesignTypography.bodySmall` | 12dp | Regular | 1.5 | Helper text, captions |

**Label Style Pattern:**
```dart
TextStyle(
  fontSize: DesignTypography.labelSmallSize, // 11dp
  fontWeight: FontWeight.bold,
  letterSpacing: 0.5,
).copyWith(
  color: isDark ? Colors.grey[400] : Colors.grey[600],
)
```

**Body Text Style:**
```dart
DesignTypography.bodyMedium.copyWith(
  color: isDark ? Colors.white : DesignColors.textPrimary,
)
```

**Rules:**
- ❌ **NEVER** hardcode font sizes như `TextStyle(fontSize: 14)`
- ✅ **ALWAYS** use predefined `DesignTypography.*` styles
- ✅ Use `copyWith()` để override color cho dark mode

### 2.4 Border Radius

**MUST USE** các tokens từ `DesignRadius` class:

| Token | Value | Use Case |
|-------|-------|----------|
| `DesignRadius.lg * 1.5` | 24dp | **STANDARD** - Cards, input fields, buttons |
| `DesignRadius.md` | 12dp | Small cards, badges |
| `DesignRadius.sm` | 8dp | Small buttons |
| `DesignRadius.full` | 50dp+ | Pill-shaped badges, avatars |

**Rules:**
- ❌ **NEVER** hardcode radius như `BorderRadius.circular(12)`
- ✅ **ALWAYS** use `BorderRadius.circular(DesignRadius.lg * 1.5)` cho cards và inputs

### 2.5 Elevation & Shadows

**MUST USE** các shadows từ `DesignElevation` class:

| Level | Blur | Offset | Use Case |
|-------|------|--------|----------|
| `DesignElevation.level2` | 6dp | (0, 3) | **STANDARD** - Cards |
| `DesignElevation.level4` | 24dp | (0, 12) | Dialogs, modals |

**Card Shadow Pattern:**
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.05),
    blurRadius: 10,
    offset: const Offset(0, 4),
  ),
]
```

**Rules:**
- ✅ Use `DesignElevation.level2` cho cards
- ✅ Use `DesignElevation.level4` cho dialogs

### 2.6 Component Sizing

**MUST USE** các constants từ `DesignComponents` class:

| Component | Height | Width | Padding | Notes |
|-----------|--------|-------|---------|-------|
| Input Field | `DesignComponents.inputFieldHeight` (48dp) | Full | `DesignSpacing.lg` (16dp) | Standard input |
| Button (Medium) | `DesignComponents.buttonHeightMedium` (40dp) | Auto | `DesignSpacing.lg` H, 10dp V | Standard button |
| Card Padding | - | - | `DesignSpacing.lg + 4` (20dp) | Card content padding |
| Icon Size | `DesignIcons.mdSize` (22dp) | - | - | Button icons |
| Icon Size (Small) | `DesignIcons.smSize` (18dp) | - | - | Decorative icons |

**Rules:**
- ✅ Use `DesignComponents.inputFieldHeight` cho input fields
- ✅ Use `DesignIcons.mdSize` cho button icons
- ✅ Use `DesignIcons.smSize` cho decorative icons

---

## 3. UI/UX Requirements

### 3.1 Layout Structure

**Single Column Layout:**
- Scrollable `SingleChildScrollView` với padding `DesignSpacing.lg`
- Tất cả fields xếp dọc từ trên xuống
- Section spacing: `DesignSpacing.xxl` (22dp) giữa các sections

**Screen Structure:**
```
Scaffold
  backgroundColor: DesignColors.moonLight
  body:
    Column
      - Header (sticky)
      - Expanded
        - SingleChildScrollView
          - Question Text Section
          - Question Images Section
          - Options Section (for Multiple Choice)
          - Metadata Section (Difficulty, Tags, Learning Objectives)
          - Explanation Section
          - Hints Section
          - Preview Button
```

### 3.2 Header Pattern

**Sticky Header** (giống `teacher_create_assignment_screen.dart`):

```dart
Container(
  color: isDark ? const Color(0xFF1A2632) : Colors.white,
  padding: EdgeInsets.only(
    left: 16,
    right: 16,
    top: statusBarHeight + 8,
    bottom: 8,
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        onPressed: () => _handleBack(),
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),
      Expanded(
        child: Text(
          'Tạo Câu Hỏi',
          style: DesignTypography.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : DesignColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      IconButton(
        onPressed: () => _showPreview(),
        icon: const Icon(Icons.visibility, size: 20),
        color: isDark ? Colors.grey[300] : Colors.grey[700],
      ),
    ],
  ),
)
```

**Features:**
- Back button (left) - với unsaved changes detection
- Title (center, expanded)
- Preview button (right) - optional

### 3.3 Form Fields Pattern

**LabeledTextField Pattern:**
- Label phía trên với style: `labelSmallSize`, bold, uppercase, grey[600]
- Input field: white background, rounded `DesignRadius.lg * 1.5`, border grey[200]
- Focus state: border `DesignColors.primary`, width 2
- Padding: `EdgeInsets.symmetric(horizontal: 12, vertical: 12)`

**LabeledTextarea Pattern:**
- Tương tự `LabeledTextField` nhưng với `minLines: 3`, `maxLines: null`
- Có thể có `showToolbar: true` cho formatting (bold, italic, link)
- Toolbar: small container với 3 buttons (format_bold, format_italic, link)

**Example:**
```dart
LabeledTextarea(
  label: 'NỘI DUNG CÂU HỎI',
  controller: _questionTextController,
  hintText: 'Nhập nội dung câu hỏi...',
  minLines: 3,
  showToolbar: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập nội dung câu hỏi';
    }
    return null;
  },
)
```

### 3.4 Card Pattern

**Standard Card** (giống `teacher_create_assignment_screen.dart`):

```dart
Container(
  decoration: BoxDecoration(
    color: isDark ? const Color(0xFF1A2632) : Colors.white,
    borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
    border: Border.all(
      color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  padding: EdgeInsets.all(DesignSpacing.lg + 4),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Section header with icon
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: DesignColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignRadius.lg),
            ),
            child: Icon(Icons.help_outline, size: 20, color: DesignColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'TÙY CHỌN NÂNG CAO',
              style: TextStyle(
                fontSize: DesignTypography.labelSmallSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ).copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
      Divider(
        height: DesignSpacing.xxl,
        color: isDark ? Colors.grey[700] : Colors.grey[100],
      ),
      // Card content
      ...
    ],
  ),
)
```

### 3.5 Options Management (Multiple Choice)

**Options List Pattern:**

Mỗi option là một card với:
- Radio button (left) - để mark correct answer
- Text field (center, expanded) - để nhập nội dung option
- Delete button (right) - icon button để xóa option

**Add Option Button:**
```dart
OutlinedButton.icon(
  onPressed: _canAddOption ? () => _addOption() : null,
  icon: const Icon(Icons.add, size: 18),
  label: const Text('Thêm lựa chọn'),
  style: OutlinedButton.styleFrom(
    side: BorderSide(
      color: Colors.grey[300]!,
      style: BorderStyle.solid,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
    ),
  ),
)
```

**Bulk Import:**
- Button "Import nhiều lựa chọn"
- Dialog với textarea để paste (mỗi dòng = 1 option)
- Parse và add vào options list

**Validation:**
- Min 2 options
- Max 8 options
- Ít nhất 1 option phải được mark là correct
- Option text không được rỗng

### 3.6 Image Picker Pattern

**Multiple Images Grid:**

- Grid view với thumbnails (2-3 columns tùy screen width)
- Mỗi image có:
  - Thumbnail (rounded corners)
  - Delete button overlay (top-right corner)
- Add image button: Dashed border, icon + text "Thêm hình ảnh"
- Max images: 5

**Image Picker Options:**
- Gallery picker
- Camera capture
- Sử dụng `image_picker` package

### 3.7 Preview Mode

**Preview Button:**
- Icon button ở header (right) hoặc button ở bottom
- Khi click → mở dialog/screen với preview

**Preview Format:**
- Hiển thị câu hỏi theo góc nhìn học sinh
- Format giống như sẽ hiển thị trong assignment
- Options với radio buttons (disabled state)
- Images hiển thị đầy đủ

---

## 4. Functional Requirements

### 4.1 Question Type Support

**Multiple Choice (Single Answer):**
- Chỉ chọn 1 đáp án đúng
- Radio buttons cho options
- Validation: Phải có ít nhất 1 đáp án đúng

### 4.2 Data Fields

| Field | Type | Required | Widget | Notes |
|-------|------|----------|--------|-------|
| Question Text | String | ✅ Yes | `LabeledTextarea` | Với `showToolbar: true` |
| Question Images | List<String> | ❌ No | Custom image picker | Max 5 images |
| Options | List<Option> | ✅ Yes | Custom options list | Min 2, Max 8 |
| Difficulty | int (1-5) | ❌ No | `SelectField` | Dropdown 1-5 |
| Tags | List<String> | ❌ No | Chip input | Có thể thêm nhiều tags |
| Learning Objectives | List<String> | ❌ No | Search/Select | Liên kết với `learning_objectives` table |
| Explanation | String | ❌ No | `LabeledTextarea` | Giải thích đáp án |
| Hints | List<String> | ❌ No | List of text fields | Có thể thêm/xóa hints |

### 4.3 Validation Rules

**Required Fields:**
- Question text: Không được rỗng
- Options: Ít nhất 2 options
- Correct answer: Ít nhất 1 option phải được mark là correct

**Choices Validation:**
- Min options: 2
- Max options: 8
- Option text: Không được rỗng
- At least 1 correct: Phải có ít nhất 1 option được mark là correct

**Image Validation:**
- Max images: 5
- Image size: Validate khi upload (có thể limit max size)
- Image format: Validate format (jpg, png, etc.)

**Error Display:**
- Hiển thị error message dưới field (red text)
- Error border: `DesignColors.error` với width 2
- SnackBar cho validation errors khi submit

### 4.4 Unsaved Changes Detection

**Detection Logic:**
- Track initial state (khi screen mở)
- Compare với current state khi user click back
- Nếu có changes → hiển thị warning dialog

**Warning Dialog:**
```
Title: "Có thay đổi chưa lưu"
Message: "Bạn có thay đổi chưa được lưu. Bạn có muốn lưu nháp trước khi quay lại?"
Actions:
  - "Lưu nháp" (Primary) → Save draft → Pop
  - "Hủy thay đổi" (Secondary) → Discard → Pop
  - "Tiếp tục chỉnh sửa" (Tertiary) → Stay on screen
```

### 4.5 Navigation Flow

**From Assignment Screen:**
```dart
final question = await context.push<Map<String, dynamic>>(
  AppRoute.teacherCreateQuestionPath,
  extra: {
    'questionType': QuestionType.multipleChoice,
  },
);

if (question != null) {
  // Add question to assignment
  _addQuestion(question);
}
```

**Return Data Format:**
```dart
{
  'type': QuestionType.multipleChoice,
  'text': String,
  'images': List<String>?, // image URLs hoặc file paths
  'options': List<Map<String, dynamic>>, // [{text: String, isCorrect: bool}]
  'difficulty': int?, // 1-5
  'tags': List<String>?,
  'learningObjectives': List<String>?, // IDs
  'explanation': String?,
  'hints': List<String>?,
  'points': double, // Từ assignment scoring config
}
```

**Back Navigation:**
- Click back button → Check unsaved changes → Show dialog nếu có → Pop với data hoặc null
- Click "Lưu" button → Validate → Pop với question data

---

## 5. Technical Specifications

### 5.1 File Structure

**Files to Create:**

1. **`lib/presentation/views/assignment/teacher/widgets/create_question/create_question_screen.dart`**
   - Main screen widget
   - StatefulWidget với local state
   - Form validation với `GlobalKey<FormState>`
   - Unsaved changes detection

2. **`lib/presentation/views/assignment/teacher/widgets/create_question/widgets/question_options_list.dart`**
   - Widget để quản lý danh sách options
   - Add/remove options
   - Mark correct answer (radio buttons)
   - Bulk import dialog

3. **`lib/presentation/views/assignment/teacher/widgets/create_question/widgets/question_image_picker.dart`**
   - Widget để chọn và hiển thị multiple images
   - Image picker integration (gallery + camera)
   - Thumbnail grid view
   - Delete image functionality

4. **`lib/presentation/views/assignment/teacher/widgets/create_question/widgets/question_preview_dialog.dart`**
   - Dialog/Screen để preview câu hỏi
   - Student view format
   - Read-only display

**Files to Modify:**

1. **`lib/core/routes/route_constants.dart`**
   ```dart
   static const String teacherCreateQuestion = 'teacher-create-question';
   static const String teacherCreateQuestionPath = '/teacher/assignment/question/create';
   ```

2. **`lib/core/routes/app_router.dart`**
   ```dart
   GoRoute(
     name: AppRoute.teacherCreateQuestion,
     path: AppRoute.teacherCreateQuestionPath,
     builder: (context, state) {
       final extra = state.extra as Map<String, dynamic>?;
       final questionType = extra?['questionType'] as QuestionType? ?? QuestionType.multipleChoice;
       return CreateQuestionScreen(questionType: questionType);
     },
   ),
   ```

3. **`lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart`**
   - Update navigation trong `ToolsDrawer` callbacks
   - Handle returned question data

### 5.2 State Management

**Local State Pattern:**
- Sử dụng `StatefulWidget` với local state
- Controllers cho text fields: `TextEditingController`
- State variables cho:
  - Question text
  - Images list
  - Options list
  - Difficulty, tags, learning objectives
  - Explanation, hints
  - Form validation state
  - Unsaved changes flag

**Form Validation:**
```dart
final _formKey = GlobalKey<FormState>();

// In build method
Form(
  key: _formKey,
  child: SingleChildScrollView(
    // Form fields
  ),
)

// On save
if (_formKey.currentState!.validate()) {
  // Save and return
}
```

### 5.3 Data Models

**Option Model:**
```dart
class QuestionOption {
  final String text;
  final bool isCorrect;
  
  QuestionOption({
    required this.text,
    this.isCorrect = false,
  });
}
```

**Question Data Model:**
```dart
Map<String, dynamic> toQuestionData() {
  return {
    'type': _questionType,
    'text': _questionTextController.text.trim(),
    'images': _images.map((img) => img.path).toList(),
    'options': _options.map((opt) => {
      'text': opt.text,
      'isCorrect': opt.isCorrect,
    }).toList(),
    'difficulty': _difficulty,
    'tags': _tags,
    'learningObjectives': _learningObjectiveIds,
    'explanation': _explanationController.text.trim(),
    'hints': _hints.map((h) => h.text.trim()).toList(),
    'points': _points, // From assignment scoring config
  };
}
```

### 5.4 Image Handling

**Image Picker Integration:**
```dart
import 'package:image_picker/image_picker.dart';

final ImagePicker _picker = ImagePicker();

// Pick from gallery
final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

// Pick from camera
final XFile? image = await _picker.pickImage(source: ImageSource.camera);
```

**Image Storage:**
- Tạm thời lưu local paths trong state
- Khi save question → upload lên Supabase Storage
- Return image URLs trong question data

---

## 6. Code Examples

### 6.1 Screen Structure

```dart
class CreateQuestionScreen extends StatefulWidget {
  final QuestionType questionType;
  
  const CreateQuestionScreen({
    super.key,
    required this.questionType,
  });

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionTextController = TextEditingController();
  final _explanationController = TextEditingController();
  
  List<XFile> _images = [];
  List<QuestionOption> _options = [];
  int? _difficulty;
  List<String> _tags = [];
  List<String> _learningObjectiveIds = [];
  List<TextEditingController> _hintControllers = [];
  
  bool _hasUnsavedChanges = false;
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Scaffold(
      backgroundColor: DesignColors.moonLight,
      body: Column(
        children: [
          // Header
          _buildHeader(context, isDark, statusBarHeight),
          
          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(DesignSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Text
                    LabeledTextarea(
                      label: 'NỘI DUNG CÂU HỎI',
                      controller: _questionTextController,
                      hintText: 'Nhập nội dung câu hỏi...',
                      minLines: 3,
                      showToolbar: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập nội dung câu hỏi';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: DesignSpacing.xxl),
                    
                    // Question Images
                    _buildImagePicker(context, isDark),
                    SizedBox(height: DesignSpacing.xxl),
                    
                    // Options (for Multiple Choice)
                    if (widget.questionType == QuestionType.multipleChoice)
                      _buildOptionsSection(context, isDark),
                    
                    // Metadata Section
                    _buildMetadataSection(context, isDark),
                    
                    // Explanation
                    _buildExplanationSection(context, isDark),
                    
                    // Hints
                    _buildHintsSection(context, isDark),
                    
                    // Preview Button
                    SizedBox(height: DesignSpacing.xxl),
                    _buildPreviewButton(context, isDark),
                    
                    SizedBox(height: 100), // Space for bottom button
                  ],
                ),
              ),
            ),
          ),
          
          // Save Button (sticky bottom)
          _buildSaveButton(context, isDark),
        ],
      ),
    );
  }
}
```

### 6.2 Options List Widget

```dart
Widget _buildOptionsSection(BuildContext context, bool isDark) {
  return Container(
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1A2632) : Colors.white,
      borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
      border: Border.all(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: EdgeInsets.all(DesignSpacing.lg + 4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: DesignColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DesignRadius.lg),
              ),
              child: Icon(Icons.radio_button_checked, size: 20, color: DesignColors.primary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'CÁC LỰA CHỌN',
                style: TextStyle(
                  fontSize: DesignTypography.labelSmallSize,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ).copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        Divider(
          height: DesignSpacing.xxl,
          color: isDark ? Colors.grey[700] : Colors.grey[100],
        ),
        
        // Options List
        ..._options.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          return _buildOptionItem(context, isDark, index, option);
        }),
        
        SizedBox(height: DesignSpacing.md),
        
        // Add Option Button
        if (_options.length < 8)
          OutlinedButton.icon(
            onPressed: () => _addOption(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Thêm lựa chọn'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DesignRadius.lg * 1.5),
              ),
            ),
          ),
        
        // Bulk Import Button
        if (_options.length < 8)
          TextButton.icon(
            onPressed: () => _showBulkImportDialog(context),
            icon: const Icon(Icons.paste, size: 18),
            label: const Text('Import nhiều lựa chọn'),
          ),
      ],
    ),
  );
}

Widget _buildOptionItem(BuildContext context, bool isDark, int index, QuestionOption option) {
  return Container(
    margin: EdgeInsets.only(bottom: DesignSpacing.sm),
    padding: EdgeInsets.all(DesignSpacing.md),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[800]!.withValues(alpha: 0.5) : Colors.grey[50],
      borderRadius: BorderRadius.circular(DesignRadius.lg),
      border: Border.all(
        color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
      ),
    ),
    child: Row(
      children: [
        // Radio Button
        Radio<bool>(
          value: true,
          groupValue: option.isCorrect,
          onChanged: (value) {
            setState(() {
              // Uncheck all others (single answer)
              for (var opt in _options) {
                opt.isCorrect = false;
              }
              option.isCorrect = value ?? false;
            });
          },
        ),
        
        // Text Field
        Expanded(
          child: TextFormField(
            controller: option.controller,
            decoration: InputDecoration(
              hintText: 'Nhập lựa chọn ${index + 1}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DesignRadius.sm),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập nội dung lựa chọn';
              }
              return null;
            },
          ),
        ),
        
        // Delete Button
        IconButton(
          onPressed: _options.length > 2
              ? () => _removeOption(index)
              : null,
          icon: Icon(Icons.delete_outline, size: 20),
          color: DesignColors.error,
        ),
      ],
    ),
  );
}
```

### 6.3 Unsaved Changes Detection

```dart
void _checkUnsavedChanges() {
  // Compare current state with initial state
  final hasChanges = _questionTextController.text.isNotEmpty ||
      _images.isNotEmpty ||
      _options.any((opt) => opt.controller.text.isNotEmpty) ||
      _difficulty != null ||
      _tags.isNotEmpty ||
      _learningObjectiveIds.isNotEmpty ||
      _explanationController.text.isNotEmpty ||
      _hintControllers.any((c) => c.text.isNotEmpty);
  
  _hasUnsavedChanges = hasChanges;
}

Future<void> _handleBack() async {
  _checkUnsavedChanges();
  
  if (_hasUnsavedChanges) {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WarningDialog.showUnsavedChanges(
        context: context,
        onDiscard: () => Navigator.of(context).pop(true), // Discard
        onSave: () async {
          // Save draft logic
          Navigator.of(context).pop(true); // Save and pop
        },
      ),
    );
    
    if (result == true) {
      if (mounted) context.pop();
    }
  } else {
    if (mounted) context.pop();
  }
}
```

### 6.4 Validation on Save

```dart
Future<void> _handleSave() async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Vui lòng kiểm tra lại các trường bắt buộc'),
        backgroundColor: DesignColors.error,
      ),
    );
    return;
  }
  
  // Validate options
  if (widget.questionType == QuestionType.multipleChoice) {
    if (_options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng thêm ít nhất 2 lựa chọn'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }
    
    final hasCorrectAnswer = _options.any((opt) => opt.isCorrect);
    if (!hasCorrectAnswer) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 đáp án đúng'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }
  }
  
  // Build question data
  final questionData = toQuestionData();
  
  // Return to assignment screen
  if (mounted) {
    context.pop(questionData);
  }
}
```

---

## 7. Integration Guide

### 7.1 Navigation from Assignment Screen

**In `teacher_create_assignment_screen.dart`:**

```dart
// In ToolsDrawer callbacks
onAddMultipleChoice: () async {
  final question = await context.push<Map<String, dynamic>>(
    AppRoute.teacherCreateQuestionPath,
    extra: {
      'questionType': QuestionType.multipleChoice,
    },
  );
  
  if (question != null && mounted) {
    setState(() {
      _addQuestion(question);
    });
  }
  
  setState(() => _isDrawerOpen = false);
},
```

### 7.2 Handle Returned Question Data

**In `_addQuestion` method:**

```dart
void _addQuestion(Map<String, dynamic> questionData) {
  setState(() {
    final newNumber = _questions.length + 1;
    _questions.add({
      'number': newNumber,
      'type': questionData['type'] as QuestionType,
      'text': questionData['text'] as String,
      'images': questionData['images'] as List<String>?,
      'options': questionData['options'] as List<Map<String, dynamic>>?,
      'difficulty': questionData['difficulty'] as int?,
      'tags': questionData['tags'] as List<String>?,
      'learningObjectives': questionData['learningObjectives'] as List<String>?,
      'explanation': questionData['explanation'] as String?,
      'hints': questionData['hints'] as List<String>?,
      'points': _getPointsForQuestion(questionData['type'] as QuestionType),
    });
    _updateQuestionPoints();
  });
}
```

### 7.3 Route Configuration

**In `route_constants.dart`:**

```dart
class AppRoute {
  // ... existing routes ...
  
  // Create Question
  static const String teacherCreateQuestion = 'teacher-create-question';
  static const String teacherCreateQuestionPath = '/teacher/assignment/question/create';
  
  // Add to teacherRoutes
  static final List<String> teacherRoutes = [
    // ... existing routes ...
    teacherCreateQuestion,
  ];
}
```

**In `app_router.dart`:**

```dart
GoRoute(
  name: AppRoute.teacherCreateQuestion,
  path: AppRoute.teacherCreateQuestionPath,
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    final questionType = extra?['questionType'] as QuestionType? ?? QuestionType.multipleChoice;
    return CreateQuestionScreen(questionType: questionType);
  },
),
```

---

## 8. Validation Rules Summary

### 8.1 Required Fields

| Field | Validation Rule | Error Message |
|-------|----------------|---------------|
| Question Text | Not empty | "Vui lòng nhập nội dung câu hỏi" |
| Options (MCQ) | Min 2 options | "Vui lòng thêm ít nhất 2 lựa chọn" |
| Correct Answer (MCQ) | At least 1 correct | "Vui lòng chọn ít nhất 1 đáp án đúng" |
| Option Text | Not empty | "Vui lòng nhập nội dung lựa chọn" |

### 8.2 Optional Fields Validation

| Field | Validation Rule | Error Message |
|-------|----------------|---------------|
| Options Count | Max 8 options | "Tối đa 8 lựa chọn" |
| Images Count | Max 5 images | "Tối đa 5 hình ảnh" |
| Difficulty | 1-5 range | "Độ khó phải từ 1 đến 5" |

### 8.3 Error Display

- **Field-level errors**: Hiển thị dưới field với red text và error border
- **Form-level errors**: SnackBar với error message
- **Error border**: `DesignColors.error` với width 2

---

## 9. UI Mockup Description

### 9.1 Screen Layout

**Top to Bottom:**

1. **Header** (sticky, white background)
   - Back button (left)
   - "Tạo Câu Hỏi" title (center)
   - Preview button (right)

2. **Question Text Section**
   - Label: "NỘI DUNG CÂU HỎI"
   - Textarea với toolbar (bold, italic, link)
   - White background, rounded corners

3. **Question Images Section** (Card)
   - Header với icon và "HÌNH ẢNH" label
   - Grid view với thumbnails (2-3 columns)
   - "Thêm hình ảnh" button (dashed border)
   - Max 5 images indicator

4. **Options Section** (Card, chỉ cho Multiple Choice)
   - Header với icon và "CÁC LỰA CHỌN" label
   - List of option items (radio + text field + delete)
   - "Thêm lựa chọn" button
   - "Import nhiều lựa chọn" button
   - Min/Max indicator (2-8 options)

5. **Metadata Section** (Card, collapsible)
   - Header với icon và "TÙY CHỌN NÂNG CAO" label
   - Difficulty dropdown
   - Tags chip input
   - Learning Objectives search/select

6. **Explanation Section**
   - Label: "GIẢI THÍCH ĐÁP ÁN"
   - Textarea (optional)

7. **Hints Section** (Card, optional)
   - Header với icon và "GỢI Ý" label
   - List of hint text fields
   - "Thêm gợi ý" button

8. **Preview Button**
   - Primary button: "Xem trước"

9. **Save Button** (sticky bottom)
   - Primary button: "Lưu câu hỏi"
   - Full width, elevated

### 9.2 Visual Hierarchy

- **Primary Actions**: Save button (sticky bottom), Preview button (header)
- **Secondary Actions**: Add option, Add image, Add hint
- **Tertiary Actions**: Delete option, Delete image, Delete hint
- **Information**: Labels, helper text, indicators

### 9.3 Responsive Behavior

- **Mobile**: Single column, full width
- **Tablet**: Single column với max width constraint
- **Desktop**: Single column với max width constraint, larger spacing

---

## 10. Checklist for Implementation

### 10.1 Design System Compliance

- [ ] All colors use `DesignColors.*` tokens
- [ ] All spacing use `DesignSpacing.*` tokens
- [ ] All typography use `DesignTypography.*` styles
- [ ] All border radius use `DesignRadius.*` tokens
- [ ] All shadows use `DesignElevation.*` levels
- [ ] All component sizes use `DesignComponents.*` constants

### 10.2 Functionality

- [ ] Question text input với toolbar
- [ ] Multiple images picker và display
- [ ] Options management (add/remove/mark correct)
- [ ] Bulk import options
- [ ] Difficulty, tags, learning objectives inputs
- [ ] Explanation và hints inputs
- [ ] Preview functionality
- [ ] Form validation
- [ ] Unsaved changes detection
- [ ] Navigation integration

### 10.3 Code Quality

- [ ] Follow Flutter best practices
- [ ] Proper state management
- [ ] Error handling
- [ ] Accessibility support
- [ ] Dark mode support
- [ ] Responsive design

---

## 11. Additional Notes

### 11.1 Future Enhancements

- Support for other question types (short answer, essay, math)
- Rich text editor for question text
- Image editing (crop, resize)
- Question templates
- AI-assisted question generation

### 11.2 Performance Considerations

- Lazy load images (use cached network images)
- Debounce validation
- Optimize image picker (compress before display)
- Use `const` constructors where possible

### 11.3 Accessibility

- Semantic labels for all inputs
- Keyboard navigation support
- Screen reader support
- Minimum touch target sizes (48dp)

---

**End of Prompt**
