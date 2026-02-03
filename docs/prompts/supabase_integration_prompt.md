# Prompt: Tích Hợp Supabase vào Flutter App - Questions & Assignments

**⚠️ PHẠM VI:** Prompt này chỉ tập trung vào tích hợp Supabase cho **Questions** và **Assignments**. Classes đã được tích hợp hoàn chỉnh, không nằm trong scope này.

## 1. Context & Overview

### 1.1 Mục Đích

**⚠️ PHẠM VI CỦA PROMPT NÀY:**

Prompt này **CHỈ** hướng dẫn tích hợp Supabase cho:
- **Question Bank**: Câu hỏi, lựa chọn, mục tiêu học tập
- **Assignments**: Bài tập, câu hỏi trong bài tập, phân phối bài tập

**KHÔNG BAO GỒM:**
- **Classes (Lớp học)**: Đã được tích hợp Supabase hoàn chỉnh
  - File: `lib/presentation/views/class/teacher/create_class_screen.dart` đã gọi `classNotifier.createClass()`
  - Repository: `lib/data/repositories/school_class_repository_impl.dart` đã implement đầy đủ
  - DataSource: `lib/data/datasources/school_class_datasource.dart` đã có sẵn
  - **Không cần tích hợp thêm** - chỉ reference khi cần

**LÝ DO:**
- Classes đã có đầy đủ CRUD operations với Supabase
- Questions và Assignments hiện tại chỉ lưu trong local state, chưa persist vào database
- Prompt này tập trung vào việc thay thế local state bằng Supabase persistence cho Questions và Assignments

### 1.2 Kiến Trúc Hiện Tại

App sử dụng **Clean Architecture** với 3 layers:

```
┌─────────────────────────────────────┐
│   Presentation Layer                 │
│   - Screens (UI)                     │
│   - Providers (Riverpod)             │
│   - ViewModels/Notifiers             │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Domain Layer                       │
│   - Entities (Question, Assignment)  │
│   - Repository Interfaces           │
│   - Use Cases                        │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│   Data Layer                         │
│   - Repository Implementations       │
│   - DataSources (Supabase)           │
│   - Mappers (JSON ↔ Entities)        │
└─────────────────────────────────────┘
```

**Data Flow:**
1. UI Screen → Call Repository (via Provider)
2. Repository → Call DataSource
3. DataSource → Supabase Client → Database
4. Response → Entity → Repository → UI

### 1.3 Files Đã Có Sẵn

#### Core Services
- **`lib/core/services/supabase_service.dart`**
  - `SupabaseService.initialize()` - Khởi tạo Supabase client
  - `SupabaseService.client` - Get Supabase client instance
  - Sử dụng environment variables từ `lib/core/env/env.dart`

#### Data Sources
- **`lib/data/datasources/supabase_datasource.dart`**
  - `BaseTableDataSource` - Base class cho CRUD operations
  - Methods: `getAll()`, `getById()`, `insert()`, `update()`, `delete()`, etc.
  
- **`lib/data/datasources/question_bank_datasource.dart`**
  - `QuestionBankDataSource` - Operations cho questions, choices, objectives
  - Methods: `insertQuestion()`, `getQuestionsByAuthor()`, `getChoicesByQuestionId()`, etc.

- **`lib/data/datasources/assignment_datasource.dart`**
  - `AssignmentDataSource` - Operations cho assignments, questions, distributions
  - Methods: `insertAssignment()`, `saveDraft()`, `publishAssignmentRpc()`, etc.

#### Repository Interfaces (Domain)
- **`lib/domain/repositories/question_repository.dart`**
  - `QuestionRepository` interface
  - Methods: `createQuestion()`, `getQuestionById()`, `getQuestionsByAuthor()`, `deleteQuestion()`

- **`lib/domain/repositories/assignment_repository.dart`**
  - `AssignmentRepository` interface
  - Methods: `createAssignment()`, `saveDraft()`, `publishAssignment()`, `getAssignmentById()`, etc.

#### Repository Implementations (Data)
- **`lib/data/repositories/question_repository_impl.dart`**
  - `QuestionRepositoryImpl` - Implements `QuestionRepository`
  - Converts JSON ↔ Entities, handles errors

- **`lib/data/repositories/assignment_repository_impl.dart`**
  - `AssignmentRepositoryImpl` - Implements `AssignmentRepository`
  - Converts JSON ↔ Entities, handles errors

#### Database Schema
- **`db/02_create_question_bank_tables.sql`**
  - Định nghĩa tất cả tables, indexes, RLS policies
  - Tables: `questions`, `question_choices`, `question_objectives`, `assignments`, `assignment_questions`, `assignment_distributions`
  - **Note:** Tables `classes`, `class_members`, `groups`, `group_members` đã được tạo trong migration trước và đã được tích hợp

#### Classes Integration (Reference Only - Đã Hoàn Thành)
- **`lib/data/datasources/school_class_datasource.dart`**
  - `SchoolClassDataSource` - Operations cho classes, class_members, groups
  - Methods: `createClass()`, `getClassesByTeacher()`, `updateClass()`, etc.
  - **Status:** ✅ Đã tích hợp Supabase hoàn chỉnh

- **`lib/data/repositories/school_class_repository_impl.dart`**
  - `SchoolClassRepositoryImpl` - Implements `SchoolClassRepository`
  - **Status:** ✅ Đã tích hợp Supabase hoàn chỉnh

- **`lib/presentation/views/class/teacher/create_class_screen.dart`**
  - Screen tạo lớp học mới
  - **Status:** ✅ Đã tích hợp Supabase (gọi `classNotifier.createClass()`)
  - **Reference:** Có thể tham khảo pattern này khi tích hợp Questions/Assignments

#### Providers (Riverpod)
- **`lib/presentation/providers/question_bank_providers.dart`**
  - `questionRepositoryProvider` - Provider cho QuestionRepository

- **`lib/presentation/providers/assignment_providers.dart`**
  - `assignmentRepositoryProvider` - Provider cho AssignmentRepository

#### UI Screens (Cần Tích Hợp - Focus của Prompt này)

**Questions:**
- **`lib/presentation/views/assignment/teacher/widgets/create_question/create_question_screen.dart`**
  - Screen tạo câu hỏi mới
  - **Current State:** `context.pop(questionData)` - chỉ return data về parent, chưa lưu vào database
  - **Target State:** Call repository → Save to Supabase → Return saved question với `id`

**Assignments:**
- **`lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart`**
  - Screen tạo bài tập mới
  - **Current State:** `// TODO: Implement actual save logic` - data chỉ lưu trong local state
  - **Target State:** Call repository → Save draft/Publish to Supabase → Navigate với saved assignment `id`

**Classes (Reference - Đã Hoàn Thành):**
- **`lib/presentation/views/class/teacher/create_class_screen.dart`**
  - Screen tạo lớp học mới
  - **Status:** ✅ Đã tích hợp Supabase (gọi `classNotifier.createClass()`)
  - **Pattern Reference:** Có thể tham khảo pattern này:
    ```dart
    // Pattern từ create_class_screen.dart (đã hoàn thành)
    final params = CreateClassParams(...);
    final newClass = await classNotifier.createClass(params);
    // newClass đã có id từ Supabase
    ```

---

## 2. Database Schema Reference

### 2.1 Questions Table

```sql
create table public.questions (
  id uuid primary key default gen_random_uuid(),
  author_id uuid references auth.users not null,
  type text check (type in ('multiple_choice','short_answer','essay','true_false','matching','problem_solving','file_upload','fill_in_blank')) not null,
  content jsonb not null, -- {text: string, images: string[], latex?: string, explanation?: string, hints?: string[]}
  answer jsonb, -- {correct_choices: [0,2]} hoặc {text: "đáp án"}
  default_points numeric(7,2) default 1 check (default_points > 0),
  difficulty int check (difficulty between 1 and 5),
  tags text[],
  is_public boolean default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

**Key Fields:**
- `content` (jsonb): Chứa `text`, `images`, `explanation`, `hints`
- `type`: String value từ `QuestionType.dbValue` (ví dụ: `'multiple_choice'`)
- `author_id`: UUID của user tạo câu hỏi (tự động từ `auth.uid()`)

### 2.2 Question Choices Table

```sql
create table public.question_choices (
  id int not null check (id >= 0), -- Thứ tự (0, 1, 2, 3...)
  question_id uuid references public.questions on delete cascade not null,
  content jsonb not null, -- {text: string, image?: string}
  is_correct boolean default false,
  primary key (id, question_id)
);
```

**Key Fields:**
- `id`: Thứ tự option (0-based index)
- `content`: JSON với `text` và optional `image`
- `is_correct`: Boolean cho đáp án đúng

### 2.3 Question Objectives Table

```sql
create table public.question_objectives (
  question_id uuid references public.questions on delete cascade not null,
  objective_id uuid references public.learning_objectives on delete cascade not null,
  primary key (question_id, objective_id)
);
```

**Purpose:** Link questions với learning objectives (many-to-many)

### 2.4 Assignments Table

```sql
create table public.assignments (
  id uuid primary key default gen_random_uuid(),
  class_id uuid references public.classes on delete cascade,
  teacher_id uuid references auth.users not null,
  title text not null,
  description text,
  is_published boolean default false,
  published_at timestamptz,
  due_at timestamptz,
  available_from timestamptz,
  time_limit_minutes int check (time_limit_minutes is null or time_limit_minutes > 0),
  allow_late boolean default true,
  total_points numeric(8,2) check (total_points is null or total_points >= 0),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);
```

**Key Fields:**
- `is_published`: `false` = draft, `true` = published
- `teacher_id`: UUID của giáo viên tạo bài tập
- `total_points`: Tổng điểm (tự động tính từ `assignment_questions`)

### 2.5 Assignment Questions Table

```sql
create table public.assignment_questions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade not null,
  question_id uuid references public.questions on delete set null, -- NULL nếu tạo mới, không reuse
  custom_content jsonb, -- Override content nếu sửa từ question bank
  points numeric(7,2) not null default 1 check (points > 0),
  rubric jsonb, -- Tiêu chí chấm điểm
  order_idx int not null, -- Thứ tự (1, 2, 3...)
  unique (assignment_id, order_idx)
);
```

**Key Fields:**
- `question_id`: NULL nếu question được tạo mới trong assignment (không lưu vào question bank)
- `custom_content`: Override content nếu giáo viên sửa question từ bank
- `order_idx`: Thứ tự câu hỏi trong bài tập (1-based)

### 2.6 Assignment Distributions Table

```sql
create table public.assignment_distributions (
  id uuid primary key default gen_random_uuid(),
  assignment_id uuid references public.assignments on delete cascade not null,
  distribution_type text check (distribution_type in ('class','group','individual')) not null,
  class_id uuid references public.classes on delete cascade,
  group_id uuid references public.groups on delete cascade,
  student_ids uuid[],
  available_from timestamptz,
  due_at timestamptz,
  time_limit_minutes int check (time_limit_minutes is null or time_limit_minutes > 0),
  allow_late boolean default true,
  late_policy jsonb,
  created_at timestamptz default now()
);
```

**Key Fields:**
- `distribution_type`: `'class'`, `'group'`, hoặc `'individual'`
- Constraints: Type phải match với `class_id`, `group_id`, hoặc `student_ids`

### 2.7 Row-Level Security (RLS)

Tất cả tables đều có RLS enabled:
- **Questions**: Teachers chỉ có thể CRUD questions của mình
- **Assignments**: Teachers chỉ có thể CRUD assignments của mình
- **Assignment Questions**: Inherit permissions từ assignment

**Important:** Mọi operations phải có authenticated user (`auth.uid()`)

---

## 3. Implementation Workflow

### 3.1 Vòng Lặp Implementation

Mỗi chức năng theo pattern:

```
1. IMPLEMENT → 2. TEST → 3. VERIFY → 4. CLEANUP → 5. NEXT
```

**Chi Tiết:**
1. **Implement**: Viết code cho chức năng
2. **Test**: Tạo test script `test/temp_test_[function_name].dart`
3. **Verify**: Run test → Verify kết quả trong database
4. **Cleanup**: Xóa test file và test data
5. **Next**: Chuyển sang chức năng tiếp theo

### 3.2 Danh Sách Chức Năng Cần Tích Hợp

**⚠️ LƯU Ý:** Prompt này chỉ tập trung vào Questions và Assignments. Classes đã được tích hợp hoàn chỉnh, không nằm trong scope này.

#### Phase 1: Question Bank Integration

**1. Create Question** - Lưu question từ `CreateQuestionScreen` vào Supabase
- **Input**: Question data từ UI (text, type, options, images, etc.)
- **Process**:
  - Map UI data → `CreateQuestionParams`
  - Call `QuestionRepository.createQuestion()`
  - Repository → DataSource → Insert vào `questions` table
  - Insert `question_choices` (nếu multiple choice)
  - Insert `question_objectives` (nếu có)
- **Output**: Saved `Question` entity với `id`
- **Test**: `test/temp_test_create_question.dart`
- **Integration Point**: `create_question_screen.dart` → `_handleSave()`

**2. Get Questions** - Load questions từ Supabase vào Question Bank
- **Input**: Filters (author, type, difficulty, tags, page, pageSize)
- **Process**:
  - Call `QuestionRepository.getQuestionsByAuthor()`
  - Query `questions` table với filters
  - Load `question_choices` cho mỗi question
  - Load `question_objectives` cho mỗi question
- **Output**: List of `Question` entities
- **Test**: `test/temp_test_get_questions.dart`
- **Integration Point**: Question Bank screen (nếu có)

**3. Update Question** - Cập nhật question đã có
- **Input**: Question ID + Updated data
- **Process**:
  - Update `questions` table
  - Replace `question_choices` (delete old + insert new)
  - Replace `question_objectives` (delete old + insert new)
- **Output**: Updated `Question` entity
- **Test**: `test/temp_test_update_question.dart`
- **Integration Point**: Edit question screen (nếu có)

**4. Delete Question** - Xóa question
- **Input**: Question ID
- **Process**:
  - Delete từ `questions` table (cascade sẽ xóa choices và objectives)
- **Output**: Void
- **Test**: `test/temp_test_delete_question.dart`
- **Integration Point**: Delete question dialog

#### Phase 2: Assignment Integration

**5. Create Assignment Draft** - Lưu assignment draft
- **Input**: Assignment data từ UI (title, description, dueDate, etc.)
- **Process**:
  - Insert `assignments` table (`is_published = false`)
  - Insert `assignment_questions` table
  - Insert `assignment_distributions` table (nếu có)
- **Output**: Saved `Assignment` entity với `id`
- **Test**: `test/temp_test_create_assignment_draft.dart`
- **Integration Point**: `teacher_create_assignment_screen.dart` → `_handleSaveDraft()`

**6. Save Assignment Draft** - Cập nhật assignment draft
- **Input**: Assignment ID + Updated data
- **Process**:
  - Update `assignments` table
  - Replace `assignment_questions` (delete old + insert new)
  - Replace `assignment_distributions` (delete old + insert new)
- **Output**: Updated `Assignment` entity
- **Test**: `test/temp_test_save_assignment_draft.dart`
- **Integration Point**: `teacher_create_assignment_screen.dart` → `_handleSaveDraft()`

**7. Publish Assignment** - Xuất bản assignment
- **Input**: Assignment data + Questions + Distributions
- **Process**:
  - Sử dụng RPC `publish_assignment` (transaction server-side)
  - Update `assignments` (`is_published = true`, `published_at = now()`)
  - Insert/Update `assignment_questions`
  - Insert/Update `assignment_distributions`
- **Output**: Published `Assignment` entity
- **Test**: `test/temp_test_publish_assignment.dart`
- **Integration Point**: `teacher_create_assignment_screen.dart` → `_handleSaveAndPublish()`

**8. Load Assignment** - Load assignment từ Supabase
- **Input**: Assignment ID
- **Process**:
  - Query `assignments` table
  - Load `assignment_questions` với `questions` join
  - Load `assignment_distributions`
- **Output**: `Assignment` entity với full data
- **Test**: `test/temp_test_load_assignment.dart`
- **Integration Point**: Edit assignment screen (nếu có)

#### Phase 3: Image Upload (Optional - Future Enhancement)

**9. Upload Question Images** - Upload images lên Supabase Storage
- **Input**: Image file(s) từ device
- **Process**:
  - Upload file → `question-images/{questionId}/{filename}`
  - Get public URL
  - Update `questions.content.images` với URLs
- **Output**: List of image URLs
- **Test**: `test/temp_test_upload_images.dart`
- **Integration Point**: `create_question_screen.dart` → Image picker

---

## 4. Data Mapping Specifications

### 4.1 Question Data Mapping

#### From UI (CreateQuestionScreen) → To Database

**UI Format:**
```dart
{
  'type': QuestionType.multipleChoice, // Enum
  'text': 'Question text',
  'images': ['/path/to/image1.jpg', '/path/to/image2.jpg'], // Local paths
  'options': [
    {'text': 'Option 1', 'isCorrect': true},
    {'text': 'Option 2', 'isCorrect': false},
  ],
  'difficulty': 3, // 1-5
  'tags': ['tag1', 'tag2'],
  'learningObjectives': ['objective-id-1', 'objective-id-2'],
  'explanation': 'Explanation text',
  'hints': ['hint1', 'hint2'],
}
```

**Database Format (questions table):**
```dart
{
  'author_id': 'user-uuid', // From auth.uid()
  'type': 'multiple_choice', // QuestionType.dbValue
  'content': {
    'text': 'Question text',
    'images': ['url1', 'url2'], // URLs after upload (or local paths temporarily)
    'explanation': 'Explanation text',
    'hints': ['hint1', 'hint2'],
  },
  'answer': {
    'correct_choices': [0], // Index of correct options
  },
  'default_points': 1.0,
  'difficulty': 3,
  'tags': ['tag1', 'tag2'],
  'is_public': false,
}
```

**Database Format (question_choices table):**
```dart
[
  {
    'id': 0, // Index
    'question_id': 'question-uuid',
    'content': {'text': 'Option 1'},
    'is_correct': true,
  },
  {
    'id': 1,
    'question_id': 'question-uuid',
    'content': {'text': 'Option 2'},
    'is_correct': false,
  },
]
```

**Database Format (question_objectives table):**
```dart
[
  {
    'question_id': 'question-uuid',
    'objective_id': 'objective-id-1',
  },
  {
    'question_id': 'question-uuid',
    'objective_id': 'objective-id-2',
  },
]
```

#### Mapping Helper Function

```dart
CreateQuestionParams _mapQuestionDataToParams(Map<String, dynamic> questionData) {
  final type = questionData['type'] as QuestionType;
  final options = questionData['options'] as List<Map<String, dynamic>>?;
  
  // Build content JSON
  final content = {
    'text': questionData['text'] as String,
    'images': questionData['images'] as List<String>? ?? [],
    if (questionData['explanation'] != null)
      'explanation': questionData['explanation'] as String,
    if (questionData['hints'] != null)
      'hints': questionData['hints'] as List<String>,
  };
  
  // Build answer JSON (for multiple choice)
  Map<String, dynamic>? answer;
  if (type == QuestionType.multipleChoice && options != null) {
    final correctIndices = options
        .asMap()
        .entries
        .where((e) => e.value['isCorrect'] == true)
        .map((e) => e.key)
        .toList();
    answer = {'correct_choices': correctIndices};
  }
  
  // Build choices (for multiple choice)
  List<Map<String, dynamic>>? choices;
  if (type == QuestionType.multipleChoice && options != null) {
    choices = options.asMap().entries.map((e) {
      return {
        'id': e.key, // 0, 1, 2, ...
        'content': {'text': e.value['text'] as String},
        'is_correct': e.value['isCorrect'] as bool? ?? false,
      };
    }).toList();
  }
  
  return CreateQuestionParams(
    type: type,
    content: content,
    answer: answer,
    defaultPoints: 1.0, // Default, can be overridden
    difficulty: questionData['difficulty'] as int?,
    tags: questionData['tags'] as List<String>?,
    isPublic: false, // Default to private
    objectiveIds: questionData['learningObjectives'] as List<String>?,
    choices: choices,
  );
}
```

### 4.2 Assignment Data Mapping

#### From UI (TeacherCreateAssignmentScreen) → To Database

**UI Format:**
```dart
{
  'title': 'Assignment title',
  'description': 'Assignment description',
  'dueDate': DateTime(2024, 1, 15, 23, 59),
  'timeLimit': '45', // String minutes
  'questions': [
    {
      'number': 1,
      'type': QuestionType.multipleChoice,
      'text': 'Question 1',
      'options': [...],
      'points': 10.0, // Points for this question in assignment
    },
    // ...
  ],
  'scoringConfigs': [
    {
      'type': QuestionType.multipleChoice,
      'totalPoints': 20.0, // Total points for all MCQ questions
    },
  ],
  'distributions': [
    {
      'distributionType': 'class',
      'classId': 'class-uuid',
      'dueAt': DateTime(2024, 1, 15, 23, 59),
    },
  ],
}
```

**Database Format (assignments table):**
```dart
{
  'teacher_id': 'user-uuid', // From auth.uid()
  'class_id': 'class-uuid', // Optional, can be null
  'title': 'Assignment title',
  'description': 'Assignment description',
  'is_published': false, // Draft
  'due_at': '2024-01-15T23:59:00Z', // ISO 8601 string
  'time_limit_minutes': 45, // int
  'total_points': 100.0, // Calculated from questions
  'allow_late': true,
}
```

**Database Format (assignment_questions table):**
```dart
[
  {
    'assignment_id': 'assignment-uuid',
    'question_id': null, // NULL if question is new (not from bank)
    'custom_content': {
      'type': 'multiple_choice',
      'text': 'Question 1',
      'options': [...],
    },
    'points': 10.0,
    'order_idx': 1, // 1-based
  },
  // ...
]
```

**Database Format (assignment_distributions table):**
```dart
[
  {
    'assignment_id': 'assignment-uuid',
    'distribution_type': 'class',
    'class_id': 'class-uuid',
    'due_at': '2024-01-15T23:59:00Z',
    'time_limit_minutes': 45, // Optional override
    'allow_late': true,
  },
]
```

#### Mapping Helper Functions

```dart
// Map assignment UI data to database format
Map<String, dynamic> _mapAssignmentToDb(Map<String, dynamic> assignmentData) {
  final dueDate = assignmentData['dueDate'] as DateTime?;
  final timeLimit = assignmentData['timeLimit'] as String?;
  
  return {
    'teacher_id': Supabase.instance.client.auth.currentUser!.id,
    'class_id': assignmentData['classId'] as String?,
    'title': assignmentData['title'] as String,
    'description': assignmentData['description'] as String?,
    'is_published': false,
    'due_at': dueDate?.toIso8601String(),
    'time_limit_minutes': timeLimit != null ? int.tryParse(timeLimit) : null,
    'total_points': _calculateTotalPoints(assignmentData['questions']),
    'allow_late': true,
  };
}

// Map questions UI data to assignment_questions format
List<Map<String, dynamic>> _mapQuestionsToAssignmentQuestions(
  String assignmentId,
  List<Map<String, dynamic>> questions,
) {
  return questions.asMap().entries.map((e) {
    final index = e.key;
    final question = e.value;
    
    return {
      'assignment_id': assignmentId,
      'question_id': null, // New question, not from bank
      'custom_content': {
        'type': (question['type'] as QuestionType).dbValue,
        'text': question['text'] as String,
        'images': question['images'] as List<String>? ?? [],
        'options': question['options'] as List<Map<String, dynamic>>?,
      },
      'points': question['points'] as double? ?? 1.0,
      'order_idx': index + 1, // 1-based
    };
  }).toList();
}

double _calculateTotalPoints(List<Map<String, dynamic>> questions) {
  return questions.fold<double>(
    0.0,
    (sum, q) => sum + (q['points'] as double? ?? 0.0),
  );
}
```

---

## 5. Test Script Template

### 5.1 Test Script Pattern

Mỗi chức năng cần test script với pattern sau:

```dart
// File: test/temp_test_[function_name].dart
import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/data/datasources/question_bank_datasource.dart';
import 'package:ai_mls/data/repositories/question_repository_impl.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuestionBankDataSource datasource;
  late QuestionRepositoryImpl repository;
  String? testQuestionId; // For cleanup

  setUpAll(() async {
    // Initialize Supabase
    await SupabaseService.initialize();
    
    // Setup datasource and repository
    datasource = QuestionBankDataSource(SupabaseService.client);
    repository = QuestionRepositoryImpl(datasource);
  });

  tearDownAll(() async {
    // Cleanup test data
    if (testQuestionId != null) {
      try {
        await datasource.deleteQuestion(testQuestionId!);
      } catch (e) {
        // Ignore cleanup errors
      }
    }
  });

  test('Test [function_name]', () async {
    // 1. Create test data
    final testData = {
      // ... test data
    };
    
    // 2. Execute function
    final result = await repository.createQuestion(
      CreateQuestionParams.fromMap(testData),
    );
    
    // 3. Verify result
    expect(result, isNotNull);
    expect(result.id, isNotEmpty);
    
    // 4. Verify in database
    final saved = await datasource.getQuestionById(result.id);
    expect(saved, isNotNull);
    expect(saved!['title'], equals(testData['title']));
    
    // 5. Store ID for cleanup
    testQuestionId = result.id;
  });
}
```

### 5.2 Test Requirements

**MUST HAVE:**
- ✅ Initialize Supabase client trong `setUpAll()`
- ✅ Create test data với unique identifiers (UUID hoặc timestamp)
- ✅ Execute function under test
- ✅ Verify result (check return value)
- ✅ Verify in database (query lại để confirm)
- ✅ Cleanup test data trong `tearDownAll()`
- ✅ Delete test file sau khi pass

**BEST PRACTICES:**
- Sử dụng `temp_` prefix trong filename để dễ identify
- Mỗi test phải độc lập (không phụ thuộc vào test khác)
- Cleanup phải robust (try-catch để không fail nếu data đã bị xóa)
- Verify cả success cases và error cases (nếu có)

### 5.3 Test Execution Commands

```bash
# Run single test
flutter test test/temp_test_[function_name].dart

# Run with verbose output
flutter test test/temp_test_[function_name].dart --verbose

# After test passes, delete file
# Windows PowerShell:
Remove-Item test/temp_test_[function_name].dart

# Linux/Mac:
rm test/temp_test_[function_name].dart
```

---

## 6. Error Handling & Validation

### 6.1 RLS Policies

**Important:** Tất cả operations phải có authenticated user.

```dart
// Check authentication before operation
final user = Supabase.instance.client.auth.currentUser;
if (user == null) {
  throw Exception('Bạn cần đăng nhập để thực hiện thao tác này');
}
```

**RLS Rules:**
- **Questions**: Teachers chỉ có thể CRUD questions của mình (`author_id = auth.uid()`)
- **Assignments**: Teachers chỉ có thể CRUD assignments của mình (`teacher_id = auth.uid()`)
- **Public Questions**: Mọi người có thể xem questions với `is_public = true`

### 6.2 Validation Rules

#### Question Validation
- ✅ `type` phải là valid QuestionType
- ✅ `content.text` không được rỗng
- ✅ `difficulty` phải trong range 1-5 (nếu có)
- ✅ Multiple choice: Phải có ít nhất 2 options
- ✅ Multiple choice: Phải có ít nhất 1 correct answer
- ✅ `tags` phải là array of strings (nếu có)

#### Assignment Validation
- ✅ `title` không được rỗng
- ✅ `due_at` phải là future date (nếu có)
- ✅ `time_limit_minutes` phải > 0 (nếu có)
- ✅ `questions` phải có ít nhất 1 question
- ✅ `total_points` phải >= 0 (nếu có)

### 6.3 Error Messages

Repository implementations sử dụng `ErrorTranslationUtils.translateError()` để convert database errors sang user-friendly messages:

```dart
try {
  // ... operation
} catch (e, stackTrace) {
  AppLogger.error('🔴 [REPO ERROR] operation: $e', error: e, stackTrace: stackTrace);
  throw ErrorTranslationUtils.translateError(e, 'Tên thao tác');
}
```

**Common Errors:**
- `23505`: Duplicate key → "Dữ liệu bị trùng lặp"
- `23503`: Foreign key violation → "Dữ liệu liên quan không tồn tại"
- `23502`: Not null violation → "Thiếu dữ liệu bắt buộc"
- `42501`: Permission denied → "Không có quyền thực hiện thao tác này"
- `PGRST116`: Not found → "Không tìm thấy dữ liệu"

### 6.4 Transaction Safety

**For Complex Operations:**
- Sử dụng RPC functions cho operations cần transaction (ví dụ: `publish_assignment`)
- RPC functions chạy server-side, đảm bảo atomicity

**Example:**
```dart
// Publish assignment (transaction-safe)
final result = await _ds.publishAssignmentRpc(
  assignment: assignmentData,
  questions: questionsData,
  distributions: distributionsData,
);
```

---

## 7. Integration Points

### 7.1 CreateQuestionScreen Integration

**Current State:**
- `_handleSave()` method builds `questionData` và `context.pop(questionData)`
- Data chỉ được return về parent screen, chưa lưu vào database

**Target State:**
- Call repository để save question vào Supabase
- Show loading state trong quá trình save
- Handle errors với SnackBar
- Return saved question với `id` về parent

**Implementation:**

```dart
// In create_question_screen.dart
import 'package:ai_mls/data/repositories/question_repository_impl.dart';
import 'package:ai_mls/data/datasources/question_bank_datasource.dart';
import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateQuestionScreen extends ConsumerStatefulWidget {
  // ... existing code
}

class _CreateQuestionScreenState extends ConsumerState<CreateQuestionScreen> {
  bool _isSaving = false;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường bắt buộc'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    // Validate options for multiple choice
    if (_selectedQuestionType == QuestionType.multipleChoice) {
      if (_options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất 2 lựa chọn'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      final hasCorrectAnswer = _options.any((opt) => opt.isCorrect);
      if (!hasCorrectAnswer) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất 1 đáp án đúng'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      // Build question data
      final questionData = {
        'type': _selectedQuestionType,
        'text': _questionTextController.text.trim(),
        'images': _images.map((img) => img.path).toList(),
        'options': _options
            .map(
              (opt) => {
                'text': opt.controller.text.trim(),
                'isCorrect': opt.isCorrect,
              },
            )
            .toList(),
        'difficulty': _difficulty,
        'tags': _tags,
        'learningObjectives': _learningObjectiveIds,
        'explanation': _explanationController.text.trim(),
        'hints': _hintControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
      };

      // Map to CreateQuestionParams
      final params = _mapQuestionDataToParams(questionData);

      // Get repository from provider
      final repository = ref.read(questionRepositoryProvider);

      // Save to Supabase
      final savedQuestion = await repository.createQuestion(params);

      // Return to parent with saved question
      if (mounted) {
        context.pop(savedQuestion.toMap());
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu câu hỏi: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  CreateQuestionParams _mapQuestionDataToParams(Map<String, dynamic> questionData) {
    // ... mapping logic (see section 4.1)
  }
}
```

**Loading State:**
- Show CircularProgressIndicator trong AppBar hoặc overlay
- Disable save button khi đang save

**Error Handling:**
- Catch exceptions từ repository
- Show SnackBar với error message
- Log error với AppLogger

### 7.2 TeacherCreateAssignmentScreen Integration

**Current State:**
- `_handleSaveDraft()` và `_handleSaveAndPublish()` có `// TODO: Implement actual save logic`
- Data chỉ được lưu trong local state, chưa persist vào database

**Target State:**
- Save draft: Call `AssignmentRepository.saveDraft()`
- Publish: Call `AssignmentRepository.publishAssignment()`
- Show loading state
- Handle errors
- Navigate to assignment list hoặc detail sau khi save

**Implementation:**

```dart
// In teacher_create_assignment_screen.dart
import 'package:ai_mls/data/repositories/assignment_repository_impl.dart';
import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherCreateAssignmentScreen extends ConsumerStatefulWidget {
  // ... existing code
}

class _TeacherCreateAssignmentScreenState extends ConsumerState<TeacherCreateAssignmentScreen> {
  String? _assignmentId; // Store assignment ID after first save
  bool _isSaving = false;

  Future<void> _handleSaveDraft() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường bắt buộc'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Map assignment data
      final assignmentData = _mapAssignmentToDb({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dueDate': _dueDate != null && _dueTime != null
            ? DateTime(
                _dueDate!.year,
                _dueDate!.month,
                _dueDate!.day,
                _dueTime!.hour,
                _dueTime!.minute,
              )
            : null,
        'timeLimit': _timeLimit,
      });

      // Map questions data
      final questionsData = _mapQuestionsToAssignmentQuestions(
        _assignmentId ?? 'temp', // Will be replaced after first save
        _questions,
      );

      // Map distributions data (if any)
      final distributionsData = _distributions.map((d) => {
        // ... map distribution data
      }).toList();

      // Get repository
      final repository = ref.read(assignmentRepositoryProvider);

      Assignment savedAssignment;
      if (_assignmentId == null) {
        // Create new assignment
        savedAssignment = await repository.createAssignment(assignmentData);
        _assignmentId = savedAssignment.id;
      } else {
        // Update existing assignment
        savedAssignment = await repository.saveDraft(
          assignmentId: _assignmentId!,
          assignmentPatch: assignmentData,
          questions: questionsData,
          distributions: distributionsData,
        );
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu bản nháp thành công'),
            backgroundColor: DesignColors.success,
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu bản nháp: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleSaveAndPublish() async {
    // Similar to _handleSaveDraft, but call publishAssignment() instead
    // ... implementation
  }

  Map<String, dynamic> _mapAssignmentToDb(Map<String, dynamic> data) {
    // ... mapping logic (see section 4.2)
  }

  List<Map<String, dynamic>> _mapQuestionsToAssignmentQuestions(
    String assignmentId,
    List<Map<String, dynamic>> questions,
  ) {
    // ... mapping logic (see section 4.2)
  }
}
```

**Key Points:**
- Store `_assignmentId` sau lần save đầu tiên
- Nếu `_assignmentId == null` → Create new
- Nếu `_assignmentId != null` → Update existing
- Show loading state với CircularProgressIndicator
- Handle errors với SnackBar

---

## 8. Implementation Checklist

### 8.1 Phase 1: Question Bank Integration

#### Function 1: Create Question
- [ ] Review `CreateQuestionParams` structure
- [ ] Implement `_mapQuestionDataToParams()` helper trong `create_question_screen.dart`
- [ ] Update `_handleSave()` để call repository
- [ ] Add loading state
- [ ] Add error handling
- [ ] Write test script `test/temp_test_create_question.dart`
- [ ] Run test → Verify question được tạo trong database
- [ ] Delete test file
- [ ] Test end-to-end từ UI
- [ ] Document any issues

#### Function 2: Get Questions
- [ ] Check if Question Bank screen exists
- [ ] If exists: Integrate `getQuestionsByAuthor()` vào screen
- [ ] Write test script `test/temp_test_get_questions.dart`
- [ ] Run test → Verify query returns correct questions
- [ ] Delete test file
- [ ] Test end-to-end từ UI

#### Function 3: Update Question
- [ ] Check if Edit Question screen exists
- [ ] If exists: Implement update logic
- [ ] Write test script `test/temp_test_update_question.dart`
- [ ] Run test → Verify question được update
- [ ] Delete test file
- [ ] Test end-to-end từ UI

#### Function 4: Delete Question
- [ ] Update delete dialog để call repository
- [ ] Write test script `test/temp_test_delete_question.dart`
- [ ] Run test → Verify question được xóa
- [ ] Delete test file
- [ ] Test end-to-end từ UI

### 8.2 Phase 2: Assignment Integration

#### Function 5: Create Assignment Draft
- [ ] Implement `_mapAssignmentToDb()` helper
- [ ] Implement `_mapQuestionsToAssignmentQuestions()` helper
- [ ] Update `_handleSaveDraft()` để call repository
- [ ] Add loading state
- [ ] Add error handling
- [ ] Write test script `test/temp_test_create_assignment_draft.dart`
- [ ] Run test → Verify assignment được tạo
- [ ] Delete test file
- [ ] Test end-to-end từ UI

#### Function 6: Save Assignment Draft
- [ ] Update `_handleSaveDraft()` để handle update case
- [ ] Store `_assignmentId` sau lần save đầu tiên
- [ ] Write test script `test/temp_test_save_assignment_draft.dart`
- [ ] Run test → Verify assignment được update
- [ ] Delete test file
- [ ] Test end-to-end từ UI

#### Function 7: Publish Assignment
- [ ] Implement `_handleSaveAndPublish()` để call `publishAssignment()`
- [ ] Map distributions data (nếu có)
- [ ] Add loading state
- [ ] Add error handling
- [ ] Write test script `test/temp_test_publish_assignment.dart`
- [ ] Run test → Verify assignment được publish
- [ ] Delete test file
- [ ] Test end-to-end từ UI

#### Function 8: Load Assignment
- [ ] Check if Edit Assignment screen exists
- [ ] If exists: Implement load logic
- [ ] Write test script `test/temp_test_load_assignment.dart`
- [ ] Run test → Verify assignment được load đúng
- [ ] Delete test file
- [ ] Test end-to-end từ UI

### 8.3 Phase 3: Image Upload (Optional)

#### Function 9: Upload Question Images
- [ ] Research Supabase Storage API
- [ ] Implement upload function
- [ ] Update `_handleSave()` để upload images trước khi save question
- [ ] Write test script `test/temp_test_upload_images.dart`
- [ ] Run test → Verify images được upload
- [ ] Delete test file
- [ ] Test end-to-end từ UI

---

## 9. Code Examples

### 9.1 Example: Create Question (Full Implementation)

```dart
// In create_question_screen.dart

import 'package:ai_mls/data/repositories/question_repository_impl.dart';
import 'package:ai_mls/data/datasources/question_bank_datasource.dart';
import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:ai_mls/presentation/providers/question_bank_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateQuestionScreen extends ConsumerStatefulWidget {
  // ... existing code
}

class _CreateQuestionScreenState extends ConsumerState<CreateQuestionScreen> {
  bool _isSaving = false;

  Future<void> _handleSave() async {
    // Validation (existing code)
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường bắt buộc'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    if (_selectedQuestionType == QuestionType.multipleChoice) {
      if (_options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng thêm ít nhất 2 lựa chọn'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }

      final hasCorrectAnswer = _options.any((opt) => opt.isCorrect);
      if (!hasCorrectAnswer) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn ít nhất 1 đáp án đúng'),
            backgroundColor: DesignColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      // Build question data from UI
      final questionData = {
        'type': _selectedQuestionType,
        'text': _questionTextController.text.trim(),
        'images': _images.map((img) => img.path).toList(),
        'options': _options
            .map(
              (opt) => {
                'text': opt.controller.text.trim(),
                'isCorrect': opt.isCorrect,
              },
            )
            .toList(),
        'difficulty': _difficulty,
        'tags': _tags,
        'learningObjectives': _learningObjectiveIds,
        'explanation': _explanationController.text.trim(),
        'hints': _hintControllers
            .map((c) => c.text.trim())
            .where((t) => t.isNotEmpty)
            .toList(),
      };

      // Map to CreateQuestionParams
      final params = _mapQuestionDataToParams(questionData);

      // Get repository from provider
      final repository = ref.read(questionRepositoryProvider);

      // Save to Supabase
      final savedQuestion = await repository.createQuestion(params);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu câu hỏi thành công'),
            backgroundColor: DesignColors.success,
          ),
        );

        // Return to parent with saved question
        context.pop({
          'id': savedQuestion.id,
          'type': savedQuestion.type,
          'text': savedQuestion.content['text'],
          // ... other fields
        });
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu câu hỏi: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  CreateQuestionParams _mapQuestionDataToParams(Map<String, dynamic> questionData) {
    final type = questionData['type'] as QuestionType;
    final options = questionData['options'] as List<Map<String, dynamic>>?;

    // Build content JSON
    final content = {
      'text': questionData['text'] as String,
      'images': questionData['images'] as List<String>? ?? [],
      if (questionData['explanation'] != null && (questionData['explanation'] as String).isNotEmpty)
        'explanation': questionData['explanation'] as String,
      if (questionData['hints'] != null && (questionData['hints'] as List).isNotEmpty)
        'hints': questionData['hints'] as List<String>,
    };

    // Build answer JSON (for multiple choice)
    Map<String, dynamic>? answer;
    if (type == QuestionType.multipleChoice && options != null) {
      final correctIndices = options
          .asMap()
          .entries
          .where((e) => e.value['isCorrect'] == true)
          .map((e) => e.key)
          .toList();
      answer = {'correct_choices': correctIndices};
    }

    // Build choices (for multiple choice)
    List<Map<String, dynamic>>? choices;
    if (type == QuestionType.multipleChoice && options != null) {
      choices = options.asMap().entries.map((e) {
        return {
          'id': e.key, // 0, 1, 2, ...
          'content': {'text': e.value['text'] as String},
          'is_correct': e.value['isCorrect'] as bool? ?? false,
        };
      }).toList();
    }

    return CreateQuestionParams(
      type: type,
      content: content,
      answer: answer,
      defaultPoints: 1.0,
      difficulty: questionData['difficulty'] as int?,
      tags: questionData['tags'] as List<String>?,
      isPublic: false,
      objectiveIds: questionData['learningObjectives'] as List<String>?,
      choices: choices,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... existing build code
    // Add loading indicator when _isSaving is true
  }
}
```

### 9.2 Example: Save Assignment Draft (Full Implementation)

```dart
// In teacher_create_assignment_screen.dart

import 'package:ai_mls/data/repositories/assignment_repository_impl.dart';
import 'package:ai_mls/data/datasources/assignment_datasource.dart';
import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/presentation/providers/assignment_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeacherCreateAssignmentScreen extends ConsumerStatefulWidget {
  // ... existing code
}

class _TeacherCreateAssignmentScreenState extends ConsumerState<TeacherCreateAssignmentScreen> {
  String? _assignmentId; // Store assignment ID after first save
  bool _isSaving = false;

  Future<void> _handleSaveDraft() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng kiểm tra lại các trường bắt buộc'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất 1 câu hỏi'),
          backgroundColor: DesignColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Map assignment data
      final assignmentData = _mapAssignmentToDb({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'dueDate': _dueDate != null && _dueTime != null
            ? DateTime(
                _dueDate!.year,
                _dueDate!.month,
                _dueDate!.day,
                _dueTime!.hour,
                _dueTime!.minute,
              )
            : null,
        'timeLimit': _timeLimit,
      });

      // Map questions data
      final questionsData = _mapQuestionsToAssignmentQuestions(
        _assignmentId ?? 'temp', // Will be replaced
        _questions,
      );

      // Map distributions data (empty for now, can be added later)
      final distributionsData = <Map<String, dynamic>>[];

      // Get repository
      final repository = ref.read(assignmentRepositoryProvider);

      Assignment savedAssignment;
      if (_assignmentId == null) {
        // Create new assignment
        savedAssignment = await repository.createAssignment(assignmentData);
        _assignmentId = savedAssignment.id;

        // Now save questions and distributions with correct assignment_id
        final questionsDataWithId = _mapQuestionsToAssignmentQuestions(
          savedAssignment.id,
          _questions,
        );

        await repository.saveDraft(
          assignmentId: savedAssignment.id,
          assignmentPatch: {}, // No update needed
          questions: questionsDataWithId,
          distributions: distributionsData,
        );
      } else {
        // Update existing assignment
        savedAssignment = await repository.saveDraft(
          assignmentId: _assignmentId!,
          assignmentPatch: assignmentData,
          questions: questionsData,
          distributions: distributionsData,
        );
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu bản nháp thành công'),
            backgroundColor: DesignColors.success,
          ),
        );
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu bản nháp: $e'),
            backgroundColor: DesignColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Map<String, dynamic> _mapAssignmentToDb(Map<String, dynamic> data) {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('Bạn cần đăng nhập để tạo bài tập');
    }

    final dueDate = data['dueDate'] as DateTime?;
    final timeLimit = data['timeLimit'] as String?;

    // Calculate total points from questions
    final totalPoints = _questions.fold<double>(
      0.0,
      (sum, q) => sum + (_getPointsForQuestion(q['type'] as QuestionType)),
    );

    return {
      'teacher_id': user.id,
      'class_id': null, // Can be set later
      'title': data['title'] as String,
      'description': data['description'] as String?,
      'is_published': false,
      'due_at': dueDate?.toIso8601String(),
      'time_limit_minutes': timeLimit != null ? int.tryParse(timeLimit) : null,
      'total_points': totalPoints,
      'allow_late': true,
    };
  }

  List<Map<String, dynamic>> _mapQuestionsToAssignmentQuestions(
    String assignmentId,
    List<Map<String, dynamic>> questions,
  ) {
    return questions.asMap().entries.map((e) {
      final index = e.key;
      final question = e.value;
      final type = question['type'] as QuestionType;

      // Build custom_content
      final customContent = {
        'type': type.dbValue,
        'text': question['text'] as String,
        'images': question['images'] as List<String>? ?? [],
      };

      // Add options if multiple choice
      if (type == QuestionType.multipleChoice) {
        final options = question['options'];
        if (options is List<Map<String, dynamic>>) {
          customContent['options'] = options.map((opt) => {
            'text': opt['text'] as String,
            'isCorrect': opt['isCorrect'] as bool? ?? false,
          }).toList();
        } else if (options is List<String>) {
          // Legacy format
          customContent['options'] = options.map((text) => {
            'text': text,
            'isCorrect': false,
          }).toList();
        }
      }

      return {
        'assignment_id': assignmentId,
        'question_id': null, // New question, not from bank
        'custom_content': customContent,
        'points': _getPointsForQuestion(type),
        'order_idx': index + 1, // 1-based
      };
    }).toList();
  }

  // ... existing _getPointsForQuestion method
}
```

### 9.3 Example: Test Script Template

```dart
// File: test/temp_test_create_question.dart
import 'package:ai_mls/core/services/supabase_service.dart';
import 'package:ai_mls/data/datasources/question_bank_datasource.dart';
import 'package:ai_mls/data/repositories/question_repository_impl.dart';
import 'package:ai_mls/domain/entities/create_question_params.dart';
import 'package:ai_mls/domain/entities/question_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late QuestionBankDataSource datasource;
  late QuestionRepositoryImpl repository;
  String? testQuestionId; // For cleanup

  setUpAll(() async {
    // Initialize Supabase
    await SupabaseService.initialize();

    // Setup datasource and repository
    datasource = QuestionBankDataSource(SupabaseService.client);
    repository = QuestionRepositoryImpl(datasource);
  });

  tearDownAll(() async {
    // Cleanup test data
    if (testQuestionId != null) {
      try {
        await datasource.deleteQuestion(testQuestionId!);
        print('✅ Cleaned up test question: $testQuestionId');
      } catch (e) {
        print('⚠️ Failed to cleanup test question: $e');
        // Ignore cleanup errors
      }
    }
  });

  test('Test create question', () async {
    // 1. Create test data
    final params = CreateQuestionParams(
      type: QuestionType.multipleChoice,
      content: {
        'text': 'Test question: What is 2 + 2?',
        'images': [],
      },
      answer: {
        'correct_choices': [0], // First option is correct
      },
      defaultPoints: 1.0,
      difficulty: 2,
      tags: ['test', 'math'],
      isPublic: false,
      choices: [
        {
          'id': 0,
          'content': {'text': '4'},
          'is_correct': true,
        },
        {
          'id': 1,
          'content': {'text': '3'},
          'is_correct': false,
        },
        {
          'id': 2,
          'content': {'text': '5'},
          'is_correct': false,
        },
      ],
    );

    // 2. Execute function
    final result = await repository.createQuestion(params);

    // 3. Verify result
    expect(result, isNotNull);
    expect(result.id, isNotEmpty);
    expect(result.type, equals(QuestionType.multipleChoice));
    expect(result.content['text'], equals('Test question: What is 2 + 2?'));

    // 4. Verify in database
    final saved = await datasource.getQuestionById(result.id);
    expect(saved, isNotNull);
    expect(saved!['type'], equals('multiple_choice'));
    expect(saved['content']['text'], equals('Test question: What is 2 + 2?'));

    // 5. Verify choices were created
    final choices = await datasource.getChoicesByQuestionId(result.id);
    expect(choices.length, equals(3));
    expect(choices[0]['is_correct'], equals(true));
    expect(choices[1]['is_correct'], equals(false));
    expect(choices[2]['is_correct'], equals(false));

    // 6. Store ID for cleanup
    testQuestionId = result.id;

    print('✅ Test passed: Question created with ID $testQuestionId');
  });
}
```

---

## 10. Testing Strategy

### 10.1 Test Script Naming Convention

**Pattern:** `test/temp_test_[function_name].dart`

**Examples:**
- `test/temp_test_create_question.dart`
- `test/temp_test_save_assignment_draft.dart`
- `test/temp_test_publish_assignment.dart`

**Why `temp_` prefix?**
- Dễ identify test files cần cleanup
- Có thể search: `test/temp_test_*.dart`
- Tránh conflict với permanent test files

### 10.2 Test Execution Workflow

```bash
# 1. Run test
flutter test test/temp_test_[function_name].dart

# 2. Check output
# - If PASS: Continue to step 3
# - If FAIL: Fix errors, repeat from step 1

# 3. Delete test file (after pass)
# Windows PowerShell:
Remove-Item test/temp_test_[function_name].dart

# Linux/Mac:
rm test/temp_test_[function_name].dart

# 4. Verify file is deleted
ls test/temp_test_*.dart  # Should show no files (or other temp tests)
```

### 10.3 Test Data Cleanup

**Requirements:**
- Mỗi test phải cleanup data nó tạo
- Sử dụng `tearDownAll()` để cleanup
- Store test IDs trong variables để cleanup
- Wrap cleanup trong try-catch để không fail nếu data đã bị xóa

**Example:**
```dart
String? testQuestionId;
String? testAssignmentId;

tearDownAll(() async {
  // Cleanup in reverse order (dependencies first)
  if (testAssignmentId != null) {
    try {
      await assignmentDatasource.deleteAssignment(testAssignmentId!);
    } catch (e) {
      // Ignore
    }
  }
  
  if (testQuestionId != null) {
    try {
      await questionDatasource.deleteQuestion(testQuestionId!);
    } catch (e) {
      // Ignore
    }
  }
});
```

### 10.4 Continuous Loop Pattern

**Implementation Pattern:**

```
WHILE (còn chức năng chưa implement):
  1. Chọn chức năng tiếp theo từ checklist (section 8)
  2. Implement code theo specifications
  3. Tạo test script theo template (section 9.3)
  4. Run test: flutter test test/temp_test_[function_name].dart
  5. IF test pass:
     - Delete test file: rm test/temp_test_[function_name].dart
     - Mark chức năng complete trong checklist
     - Continue to next chức năng
  6. ELSE (test fail):
     - Analyze error message
     - Fix code hoặc test script
     - Repeat from step 4
END WHILE
```

**Checklist Tracking:**
- Update checklist trong section 8 sau mỗi chức năng complete
- Document any issues hoặc deviations

---

## 11. Troubleshooting

### 11.1 Common Errors

#### Error: "Supabase has not been initialized"
**Cause:** `SupabaseService.initialize()` chưa được gọi
**Solution:**
```dart
// In test file
setUpAll(() async {
  await SupabaseService.initialize();
});

// In app code
// Ensure SupabaseService.initialize() is called in main.dart
```

#### Error: "Bạn cần đăng nhập để thực hiện thao tác này"
**Cause:** `auth.currentUser` is null
**Solution:**
- Ensure user is authenticated before calling repository methods
- In tests: May need to sign in first (or mock authentication)

#### Error: "Lỗi Database tại questions.insert(): Code: 42501"
**Cause:** RLS policy blocking operation
**Solution:**
- Check that `author_id` matches `auth.uid()`
- Verify RLS policies in database
- Ensure user has correct role (teacher)

#### Error: "Lỗi Database tại questions.insert(): Code: 23502"
**Cause:** Required field is null
**Solution:**
- Check that all required fields are provided
- Verify data mapping is correct
- Check database schema for NOT NULL constraints

#### Error: "Lỗi Database tại questions.insert(): Code: 23505"
**Cause:** Duplicate key violation
**Solution:**
- Check unique constraints in database
- Ensure IDs are unique (use UUID, not hardcoded values)

### 11.2 Debugging Tips

**1. Enable Supabase Logging:**
```dart
// In main.dart or test file
Supabase.instance.client.auth.onAuthStateChange.listen((data) {
  print('Auth state: ${data.event}');
});
```

**2. Log Database Queries:**
```dart
// In datasource methods, add logging
AppLogger.debug('🟢 [DATASOURCE] insertQuestion: $payload');
```

**3. Verify Data Format:**
```dart
// Before calling repository, log the data
print('Question params: ${params.toJson()}');
```

**4. Check RLS Policies:**
```sql
-- In Supabase SQL Editor
SELECT * FROM pg_policies WHERE tablename = 'questions';
```

### 11.3 Testing Authentication

**In Tests:**
```dart
// May need to sign in before running tests
setUpAll(() async {
  await SupabaseService.initialize();
  
  // Sign in (if needed)
  final client = SupabaseService.client;
  await client.auth.signInWithPassword(
    email: 'test@example.com',
    password: 'testpassword',
  );
});
```

**Note:** For production, use proper authentication flow, not hardcoded credentials.

---

## 12. Next Steps

### 12.1 After Completing All Functions

**Scope:** Chỉ áp dụng cho Questions và Assignments (Classes đã hoàn thành)

1. **Review Integration:**
   - Test all UI flows end-to-end cho Questions và Assignments
   - Verify data persistence across app restarts
   - Check error handling in all scenarios
   - Verify RLS policies hoạt động đúng

2. **Optimization:**
   - Add caching for frequently accessed questions
   - Implement pagination cho question bank lists
   - Add offline support (if needed) cho assignments

3. **Documentation:**
   - Update API documentation cho Questions và Assignments
   - Document any custom mappings or transformations
   - Create user guides for new features

### 12.2 Future Enhancements

**For Questions & Assignments:**
- **Image Upload:** Implement Supabase Storage integration cho question images
- **Real-time Updates:** Use Supabase Realtime cho live updates của assignments
- **Search:** Implement full-text search for questions
- **Analytics:** Track question usage and performance
- **Export/Import:** Allow bulk import/export of questions

**Note:** Classes đã có đầy đủ features, không cần enhancement thêm trong scope này.

### 12.3 Maintenance

- **Monitor Errors:** Set up error tracking (Sentry) cho Questions và Assignments operations
- **Database Maintenance:** Regular backups và optimization cho question/assignment tables
- **RLS Policies:** Review và update RLS policies cho questions và assignments tables
- **Performance:** Monitor query performance và optimize indexes cho questions và assignments

---

## 13. Reference Files

### 13.1 Core Files
- `lib/core/services/supabase_service.dart` - Supabase initialization
- `lib/core/env/env.dart` - Environment configuration
- `lib/data/datasources/supabase_datasource.dart` - Base CRUD operations
- `lib/data/datasources/question_bank_datasource.dart` - Question operations
- `lib/data/datasources/assignment_datasource.dart` - Assignment operations
- `lib/data/datasources/school_class_datasource.dart` - Class operations (✅ Đã hoàn thành - Reference only)

### 13.2 Repository Files
- `lib/domain/repositories/question_repository.dart` - Question repository interface
- `lib/domain/repositories/assignment_repository.dart` - Assignment repository interface
- `lib/data/repositories/question_repository_impl.dart` - Question repository implementation
- `lib/data/repositories/assignment_repository_impl.dart` - Assignment repository implementation
- `lib/domain/repositories/school_class_repository.dart` - Class repository interface (✅ Đã hoàn thành - Reference only)
- `lib/data/repositories/school_class_repository_impl.dart` - Class repository implementation (✅ Đã hoàn thành - Reference only)

### 13.3 Entity Files
- `lib/domain/entities/question.dart` - Question entity
- `lib/domain/entities/question_choice.dart` - Question choice entity
- `lib/domain/entities/create_question_params.dart` - Create question parameters
- `lib/domain/entities/assignment.dart` - Assignment entity
- `lib/domain/entities/question_type.dart` - Question type enum

### 13.4 UI Files (Integration Points)
- `lib/presentation/views/assignment/teacher/widgets/create_question/create_question_screen.dart` - Create question screen (CẦN TÍCH HỢP)
- `lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` - Create assignment screen (CẦN TÍCH HỢP)
- `lib/presentation/views/class/teacher/create_class_screen.dart` - Create class screen (✅ ĐÃ TÍCH HỢP - Reference only)

### 13.5 Database Files
- `db/02_create_question_bank_tables.sql` - Database schema cho questions và assignments

### 13.6 Provider Files
- `lib/presentation/providers/question_bank_providers.dart` - Question repository provider
- `lib/presentation/providers/assignment_providers.dart` - Assignment repository provider
- `lib/presentation/providers/class_notifier.dart` - Class notifier (✅ Đã hoàn thành - Reference only)

---

## 14. Quick Reference

### 14.1 Repository Usage Pattern

```dart
// 1. Get repository from provider
final repository = ref.read(questionRepositoryProvider);

// 2. Call repository method
final result = await repository.createQuestion(params);

// 3. Handle result
if (result != null) {
  // Success
} else {
  // Error (should throw exception, not return null)
}
```

### 14.2 Data Mapping Quick Reference

**Question UI → Database:**
- `type` (enum) → `type` (string via `dbValue`)
- `text` → `content.text`
- `images` → `content.images`
- `options` → `question_choices` table
- `learningObjectives` → `question_objectives` table

**Assignment UI → Database:**
- `title` → `title`
- `description` → `description`
- `dueDate` → `due_at` (ISO 8601 string)
- `timeLimit` (string) → `time_limit_minutes` (int)
- `questions` → `assignment_questions` table

### 14.3 Test Commands

```bash
# Run all temp tests
flutter test test/temp_test_*.dart

# Run single test
flutter test test/temp_test_create_question.dart

# Run with coverage
flutter test --coverage test/temp_test_*.dart
```

---

**End of Prompt**
