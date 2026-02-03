---
name: 10_architecture_clean_mvvm
intent: Enforce Clean Architecture + MVVM boundaries (Presentation → Domain → Data)
tags: [flutter, architecture, mvvm, clean-architecture]
---

## Intent

Giữ code scale được: tách đúng layer, dễ test, tránh Supabase leak lên UI.

## Triggers

- **file_globs**: `lib/presentation/**`, `lib/domain/**`, `lib/data/**`
- **keywords**: `Repository`, `DataSource`, `Supabase`, `Entity`, `UseCase`

## DO / DON'T

- **DO**: Presentation chỉ gọi ViewModel/Notifier; Domain chỉ chứa entity + interfaces; Data chứa implementation.
- **DO**: tất cả Supabase calls phải nằm trong `lib/data/datasources/**`.
- **DO**: features mới ưu tiên Riverpod (Provider/ChangeNotifier chỉ maintenance code cũ nếu chưa migrate).
- **DON'T**: View/ViewModel import `Supabase.instance.client` / `SupabaseService`.
- **DON'T**: nhảy layer (View → RepoImpl, ViewModel → DataSource trực tiếp).

## Examples (rule-of-thumb)

- **Good**: `View -> Notifier -> DomainRepo(interface) -> RepoImpl -> DataSource(Supabase)`
- **Bad**: `View -> Supabase query` / `Notifier -> DataSource`

## Links

- `memory-bank/systemPatterns.md` (Overall Architecture, Data Layer rules)
- `docs/ai/AI_INSTRUCTIONS.md` (Architecture sections; lưu ý phần legacy)

