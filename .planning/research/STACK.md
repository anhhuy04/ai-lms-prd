# Technology Stack

**Project:** AI LMS PRD (Learning Management System)
**Researched:** 2026-03-05
**Confidence:** HIGH

## Recommended Stack

### Core Framework (Existing)
| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Flutter | 3.8.x | Cross-platform mobile | Already in use |
| Dart | 3.8.1 | Language | Already in use |
| Supabase Flutter | 2.0.0 | Backend client | Already in use |
| Riverpod | 2.5.1 | State management | Already in use |
| GoRouter | 14.0.0 | Routing | Already in use |

---

## Feature-Specific Recommendations

### 1. Student Workspace: Auto-Save (Debounce Pattern)

**Status:** ALREADY INSTALLED
| Library | Version | Purpose |
|---------|---------|---------|
| `easy_debounce` | 2.0.3 | Debounce for auto-save |

**Recommended Pattern:**

```dart
import 'package:easy_debounce/easy_debounce.dart';

// In Riverpod Notifier
void onTextChanged(String text) {
  // Update local state immediately (no debounce for UI)
  state = state.copyWith(content: text);

  // Debounce backend save (2 second delay)
  EasyDebounce.debounce(
    'auto-save',
    const Duration(seconds: 2),
    () => _saveToBackend(text),
  );
}

Future<void> _saveToBackend(String text) async {
  // Save to Supabase or local storage
  await repository.saveDraft(assignmentId, text);
}
```

**Why `easy_debounce`:**
- Already in pubspec.yaml
- Simple API: `EasyDebounce.debounce(name, duration, callback)`
- Cancel support: `EasyDebounce.cancel(name)`
- Lightweight (~30KB)

**Alternative Considered:**
| Option | Why Not |
|--------|---------|
| `rxdart` | Overkill - too many operators for simple debounce |
| Custom timer | Reinventing the wheel |

---

### 2. File Upload to Supabase Storage

**Status:** NO ADDITIONAL PACKAGE NEEDED

Supabase Flutter SDK v2.0.0 includes storage support natively:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

// Upload file
final storage = Supabase.instance.client.storage;
final file = await pickFile(); // from image_picker

final response = await storage.from('submissions').upload(
  '${userId}/${assignmentId}/${file.name}',
  file bytes,
  fileOptions: FileOptions(
    contentType: file.contentType,
    upsert: false,
  ),
);
```

**Best Practices:**
1. **Bucket Structure:** Use meaningful paths (`student_id/assignment_id/filename`)
2. **File Size Limit:** Enforce 10MB max on client before upload
3. **Progress Tracking:** Use `uploadBinary` with `UploadProgress` callback
4. **Mime Types:** Always set `contentType` for proper CDN serving

**Libraries Already Available:**
| Library | Purpose |
|---------|---------|
| `image_picker` | 1.0.7 - Select files from gallery/camera |
| `supabase_flutter` | 2.0.0 - Storage client |

---

### 3. Analytics/Dashboard Charts

**Recommended:**
| Library | Version | Purpose |
|---------|---------|---------|
| `fl_chart` | ^0.69.0 | Charts for analytics dashboard |

**Why fl_chart:**
- **MIT Licensed** - No commercial restrictions
- **Highly Customizable** - Pie, Line, Bar, Radar, Scatter charts
- **Performance** - Canvas-based rendering, handles 10K+ data points
- **Active Maintenance** - Regular updates, Flutter 3.x compatible
- **Popular** - 10K+ pub.dev likes, proven in production

**Installation:**
```bash
flutter pub add fl_chart
```

**Example - Line Chart for Progress:**
```dart
import 'package:fl_chart/fl_chart.dart';

LineChart(
  LineChartData(
    titlesData: FlTitlesData(
      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
    ),
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, 5),
          FlSpot(1, 8),
          FlSpot(2, 6),
          FlSpot(3, 9),
        ],
        isCurved: true,
        color: DesignColors.primary,
      ),
    ],
  ),
)
```

**Alternatives Considered:**
| Library | License | Why Not |
|---------|---------|---------|
| `syncfusion_flutter_charts` | Commercial (free tier) | License complexity, large bundle |
| `charts_flutter` | Apache 2.0 | Deprecated, moved to external repo |
| `mp_chart` | Apache 2.0 | Less Flutter-native, older architecture |

---

### 4. Rich Text Editing for Assignments

**Recommended:**
| Library | Version | Purpose |
|---------|---------|---------|
| `fleather` | ^1.16.0 | Rich text editor (Quill-based) |

**Why fleather:**
- **Quill Format** - Industry standard, JSON-based Delta format
- **Active Maintenance** - Regular updates, Flutter 3.x compatible
- **Features:** Bold, italic, lists, headings, code blocks, links
- **Customizable** - Toolbar customization, embed support

**Installation:**
```bash
flutter pub add fleather
```

**Example - Assignment Editor:**
```dart
import 'package:fleather/fleather.dart';

class AssignmentEditor extends StatefulWidget {
  @override
  State<AssignmentEditor> createState() => _AssignmentEditorState();
}

class _AssignmentEditorState extends State<AssignmentEditor> {
  late FleatherController _controller;

  @override
  void initState() {
    super.initState();
    final document = ParchmentDocument();
    _controller = FleatherController(document: document);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FleatherToolbar.basic(controller: _controller),
        Expanded(
          child: FleatherEditor(controller: _controller),
        ),
      ],
    );
  }
}
```

**Serialization (Save to Supabase):**
```dart
// Get Delta JSON
final delta = _controller.document.toDelta();
final json = jsonEncode(delta.toJson());

// Save to Supabase
await supabase.from('submissions').update({
  'content_json': json,
  'content_text': _controller.document.toPlainText(),
}).eq('id', submissionId);
```

**Alternatives Considered:**
| Library | Why Not |
|---------|---------|
| `flutter_quill` | Deprecated, recommend fleather as successor |
| `zefyr` | No longer maintained |
| `rich_text_editor` | Limited features |

---

### 5. State Management Best Practices (Riverpod)

**Status:** ALREADY IMPLEMENTED CORRECTLY

The project already uses the recommended patterns:

**Current Implementation (Correct):**
```dart
@riverpod
class StudentWorkspaceNotifier extends _$StudentWorkspaceNotifier {
  @override
  FutureOr<WorkspaceState> build() async {
    return repository.getWorkspace(assignmentId);
  }

  // Async method with loading state
  Future<void> saveDraft(String content) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      repository.saveDraft(assignmentId, content)
    );
  }
}
```

**Best Practices Confirmed:**

| Practice | Project Status | Recommendation |
|----------|-----------------|----------------|
| `@riverpod` annotation | ✅ Using | Keep using |
| `AsyncNotifier` for async state | ✅ Using | Keep using |
| `ref.watch()` in UI | ✅ Using | Keep using |
| `ref.read()` in callbacks | ✅ Using | Keep using |
| Concurrency guards | ✅ Implemented | Keep using `_isUpdating` pattern |
| Optimistic updates | ✅ Implemented | Keep using for settings |

**Key Patterns Used:**

1. **Loading State Without Reset:**
```dart
// Good - doesn't reset auth state
Future<void> refresh() async {
  state = await AsyncValue.guard(() => repository.loadData());
}
```

2. **Concurrency Guard:**
```dart
bool _isUpdating = false;

Future<void> updateContent(String content) async {
  if (_isUpdating) return;
  _isUpdating = true;
  try {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => repo.save(content));
  } finally {
    _isUpdating = false;
  }
}
```

3. **Optimistic Update Pattern:**
```dart
// Update UI immediately
state = state.copyWith(value: newValue);
// Then sync to backend
await repository.save(newValue);
```

---

## Summary: New Dependencies to Add

| Feature | Package | Version | Status |
|---------|---------|---------|--------|
| Auto-save debounce | `easy_debounce` | 2.0.3 | ✅ Already installed |
| File upload | (native) | - | ✅ Already in supabase_flutter |
| Charts | `fl_chart` | ^0.69.0 | 📦 Add to pubspec |
| Rich text editor | `fleather` | ^1.16.0 | 📦 Add to pubspec |
| State management | (native) | - | ✅ Already using Riverpod |

---

## Installation Commands

```bash
# Add new dependencies
flutter pub add fl_chart
flutter pub add fleather

# Verify no conflicts
flutter pub get

# Run code generation if needed
dart run build_runner build --delete-conflicting-outputs
```

---

## Sources

- [fl_chart pub.dev](https://pub.dev/packages/fl_chart) - HIGH confidence
- [fleather pub.dev](https://pub.dev/packages/fleather) - HIGH confidence
- [easy_debounce pub.dev](https://pub.dev/packages/easy_debounce) - HIGH confidence
- [Supabase Storage docs](https://supabase.com/docs/reference/dart/storage-from-upload) - HIGH confidence
- [Riverpod best practices](https://riverpod.dev/docs/essentials/automatic_disposal) - HIGH confidence
