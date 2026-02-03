---
name: 80_testing_strategy_and_structure
intent: Testing strategy (unit/widget/integration) + boundaries mocking
tags: [testing, quality]
---

## Intent

Tăng độ tin cậy: fix bug không tạo bug mới.

## Triggers

- **file_globs**: `test/**`, `lib/**`
- **keywords**: `testWidgets`, `mocktail`, `AsyncNotifier`, `Repository`

## DO / DON'T

- **DO**: unit test cho notifier/viewmodel & repository logic quan trọng.
- **DO**: mock đúng layer (UI test mock notifier/repo; repo test mock datasource).
- **DON'T**: test “đụng Supabase thật” trừ integration test có chủ đích.

## Scale-up note (khi app lớn)

- Với feature quan trọng: thêm integration tests theo user flow (auth → dashboard → feature).
- Với DB: ưu tiên test logic mapping/validation ở repository, và chỉ “đụng Supabase thật” trong môi trường có chủ đích.

## Links

- `memory-bank/systemPatterns.md` (Testing Strategy)
- `memory-bank/techContext.md` (mocktail)
- `test/` (existing tests)

