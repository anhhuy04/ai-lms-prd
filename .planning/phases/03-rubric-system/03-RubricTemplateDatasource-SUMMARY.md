---
phase: 03-rubric-system
plan: 03-RubricTemplateDatasource
subsystem: data
tags: [supabase, profiles, metadata, rubric, datasource]

requires:
  - phase: 03-rubric-system
    provides: ProfileMetadataService (read/write profiles.metadata JSONB)

provides:
  - RubricTemplateDatasource with getSavedRubrics(), saveRubricTemplate(), deleteRubricTemplate()
  - CRUD for rubric templates stored in profiles.metadata['saved_rubrics']

affects:
  - 03-RubricBuilderComponent (Wave 2 calls this datasource)
  - 03-RubricTemplatePickerSheet (Wave 2 uses getSavedRubrics + deleteRubricTemplate)

tech-stack:
  added: []
  patterns:
    - Static methods on private-constructor class (matches ProfileMetadataService pattern)
    - JSONB array CRUD via metadata service without new DB table

key-files:
  created:
    - lib/data/datasources/rubric_template_datasource.dart
  modified: []

key-decisions:
  - "No new Supabase table — rubric templates stored in profiles.metadata['saved_rubrics'] (per D-05)"
  - "Static method pattern matching ProfileMetadataService for consistency"
  - "getMetadata() used directly in getSavedRubrics to avoid double-cache overhead"

patterns-established:
  - "JSONB sub-array CRUD: read full list → mutate → write full list back via ProfileMetadataService.set()"

requirements-completed: [RUB-01]

duration: 10min
completed: 2026-04-06
---

# Phase 03 Plan RubricTemplateDatasource: Summary

**RubricTemplateDatasource with CRUD for rubric templates backed by profiles.metadata JSONB — no new DB table.**

## Performance

- **Duration:** ~10 min
- **Started:** 2026-04-06T00:00:00Z
- **Completed:** 2026-04-06T00:10:00Z
- **Tasks:** 1 completed
- **Files modified:** 1

## Accomplishments

- Created `RubricTemplateDatasource` with 3 static methods: `getSavedRubrics()`, `saveRubricTemplate()`, `deleteRubricTemplate()`
- Templates stored in `profiles.metadata['saved_rubrics']` via `ProfileMetadataService` — no new Supabase table needed (D-05)
- Proper null safety guards, error handling with AppLogger, no print() calls
- dart analyze returns 0 issues

## Task Commits

1. **Task 3.3: Create RubricTemplateDatasource** - `452be0e` (feat)

## Files Created/Modified

- `lib/data/datasources/rubric_template_datasource.dart` - CRUD datasource for rubric templates stored in profiles.metadata JSONB

## Deviations from Plan

None — plan executed exactly as written.

## Known Stubs

None.

## Self-Check: PASSED

- File exists: lib/data/datasources/rubric_template_datasource.dart — FOUND
- Commit 452be0e — FOUND
- dart analyze: 0 issues
