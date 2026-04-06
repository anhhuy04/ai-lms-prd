---
phase: 3
plan_id: 03-PLAN-RubricTemplateDatasource
wave: 1
depends_on: []
files_modified:
  - lib/data/datasources/rubric_template_datasource.dart
autonomous: true
requirements: [RUB-01]
---

# RubricTemplateDatasource -- Phase 3 Plan

## 1. Muc dich & Pham vi

Data layer for rubric template CRUD operations. Wraps `ProfileMetadataService` to read/write `profiles.metadata['saved_rubrics']` array. Per D-05, no new Supabase table needed.

**Layer:** Data layer (lib/data/datasources/)
**Type:** New file

## 2. File Path

- **Target:** `lib/data/datasources/rubric_template_datasource.dart`
- **Read first:**
  - `lib/core/services/profile_metadata_service.dart` (existing service with get/set/remove on profiles.metadata JSONB)

## 3. UI Spec

N/A -- pure data layer.

## 4. Flow & Logic

- `getSavedRubrics()`: Read `profiles.metadata['saved_rubrics']` via `ProfileMetadataService.get<List>('saved_rubrics')`. Returns `List<Map<String, dynamic>>` where each entry is `{ "name": "...", "rubric": {...} }`.
- `saveRubricTemplate(name, rubricJson)`: Read current saved_rubrics, append new entry, write back via `ProfileMetadataService.set('saved_rubrics', updatedList)`.
- `deleteRubricTemplate(index)`: Read current saved_rubrics, remove at index, write back.
- Per D-05, templates are per-teacher (scoped by auth.uid() inherently via ProfileMetadataService).

## 5. Data Contract

- **Input/Output:**
  - `getSavedRubrics()` -> `Future<List<Map<String, dynamic>>>`
  - `saveRubricTemplate(String name, Map<String, dynamic> rubric)` -> `Future<bool>`
  - `deleteRubricTemplate(int index)` -> `Future<bool>`
- **Supabase calls:** Through `ProfileMetadataService` (reads/writes `profiles.metadata`)

## 6. Cau truc Code

```dart
import 'package:ai_mls/core/services/profile_metadata_service.dart';
import 'package:ai_mls/core/utils/app_logger.dart';

class RubricTemplateDatasource {
  RubricTemplateDatasource._();

  static Future<List<Map<String, dynamic>>> getSavedRubrics() async { ... }
  static Future<bool> saveRubricTemplate(String name, Map<String, dynamic> rubric) async { ... }
  static Future<bool> deleteRubricTemplate(int index) async { ... }
}
```

## 7. Integration Points

- **Who calls this:** `RubricBuilderComponent` (Wave 2) for "Luu thanh Template" and "Chon tu Template" buttons. `RubricTemplatePickerSheet` (Wave 2) for loading template list and deleting.
- **What this calls:** `ProfileMetadataService.get()`, `ProfileMetadataService.set()`, `ProfileMetadataService.getMetadata()`

## 8. Tasks

<wave>1</wave>

<task id="3.3">
  <title>Create RubricTemplateDatasource</title>
  <read_first>
    - lib/core/services/profile_metadata_service.dart (understand getMetadata(), get<T>(), set<T>() API)
  </read_first>
  <action>
    1. Create `lib/data/datasources/rubric_template_datasource.dart`.
    2. Class `RubricTemplateDatasource` with private constructor (static methods pattern matching ProfileMetadataService).
    3. `static Future<List<Map<String, dynamic>>> getSavedRubrics() async`:
       - `final metadata = await ProfileMetadataService.getMetadata();`
       - `if (metadata == null) return [];`
       - `final savedRubrics = metadata['saved_rubrics'];`
       - `if (savedRubrics == null || savedRubrics is! List) return [];`
       - `return List<Map<String, dynamic>>.from(savedRubrics.map((e) => Map<String, dynamic>.from(e as Map)));`
       - Wrap in try/catch, log error via `AppLogger.error()`, return empty list on error.
    4. `static Future<bool> saveRubricTemplate(String name, Map<String, dynamic> rubric) async`:
       - `if (name.trim().isEmpty) return false;`
       - `final currentList = await getSavedRubrics();`
       - `final newEntry = {'name': name.trim(), 'rubric': rubric};`
       - `currentList.add(newEntry);`
       - `return await ProfileMetadataService.set('saved_rubrics', currentList);`
       - Log success via `AppLogger.info('Saved rubric template: $name')`.
    5. `static Future<bool> deleteRubricTemplate(int index) async`:
       - `final currentList = await getSavedRubrics();`
       - `if (index < 0 || index >= currentList.length) return false;`
       - `currentList.removeAt(index);`
       - `return await ProfileMetadataService.set('saved_rubrics', currentList);`
       - Log success via `AppLogger.info('Deleted rubric template at index $index')`.
    6. Use AppLogger for all logging (never print()).
  </action>
  <acceptance_criteria>
    - `lib/data/datasources/rubric_template_datasource.dart` exists
    - grep "class RubricTemplateDatasource" lib/data/datasources/rubric_template_datasource.dart
    - grep "getSavedRubrics" lib/data/datasources/rubric_template_datasource.dart
    - grep "saveRubricTemplate" lib/data/datasources/rubric_template_datasource.dart
    - grep "deleteRubricTemplate" lib/data/datasources/rubric_template_datasource.dart
    - grep "ProfileMetadataService" lib/data/datasources/rubric_template_datasource.dart
    - grep "AppLogger" lib/data/datasources/rubric_template_datasource.dart
    - NOT grep "print(" lib/data/datasources/rubric_template_datasource.dart
    - flutter analyze lib/data/datasources/rubric_template_datasource.dart returns 0 errors
  </acceptance_criteria>
</task>

## 9. Acceptance Criteria

- CRUD operations for rubric templates via profiles.metadata JSONB.
- No new Supabase table created (per D-05).
- Uses ProfileMetadataService for all DB access.
- Proper error handling and logging.
