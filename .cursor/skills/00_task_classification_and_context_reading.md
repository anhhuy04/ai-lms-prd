---
name: 00_task_classification_and_context_reading
intent: Phân loại task + đọc đúng nguồn chuẩn trước khi code
tags: [workflow, context, rules]
---

## Intent

Dùng khi bắt đầu bất kỳ task nào để tránh đọc lan man, tránh sai pattern.

## Triggers

- **keywords**: `UI`, `Widget`, `routing`, `GoRouter`, `Supabase`, `Repository`, `MCP`, `migration`, `refactor`
- **symptoms**: “không chắc file nào”, “sợ làm sai chuẩn”, “codebase lớn”

## DO / DON'T

- **DO**: bắt đầu từ `.clinerules` (central rules) và đọc đúng section theo category.
- **DO**: dùng `read_file` với `offset/limit` để đọc đúng phần cần.
- **DO**: dùng `grep` để locate nhanh section/keyword trước khi đọc dài.
- **DON'T**: đọc toàn bộ `.clinerules`/memory-bank nếu task nhỏ.
- **DON'T**: “đoán” schema Supabase; phải check bằng Supabase MCP khi liên quan DB.

## Conflict resolution (khi tài liệu mâu thuẫn nhau)

- **Ưu tiên #1**: `.clinerules`
- **Ưu tiên #2**: `.cursor/.cursorrules`
- **Ưu tiên #3**: `.cursor/skills/**` (handbook này)
- **Ưu tiên #4**: `memory-bank/*`
- **Lưu ý**: `docs/ai/AI_INSTRUCTIONS.md` có một số phần legacy (Navigator/AppRoutes, ChangeNotifier). Nếu mâu thuẫn với các ưu tiên trên thì coi là legacy.

## Category → Nguồn cần đọc (ground truth)

### UI/Widget

- `.clinerules` (Flutter Refactoring, Code Quality, UI rules)
- `memory-bank/DESIGN_SYSTEM_GUIDE.md`, `memory-bank/systemPatterns.md`
- `lib/core/constants/design_tokens.dart`

### State/Routing

- `.clinerules` (GoRouter rules)
- `memory-bank/systemPatterns.md` (GoRouter + Riverpod + RBAC)
- **Lưu ý legacy**: `docs/ai/AI_INSTRUCTIONS.md` có đoạn Navigator/AppRoutes/ChangeNotifier → chỉ tham khảo, không dùng cho code mới nếu trái với `.clinerules`.

### Database/Repository/Model

- `.clinerules` (Database & MCP)
- `docs/ai/README_SUPABASE.md` (schema reference)
- `memory-bank/systemPatterns.md` (Data layer rules)

### MCP

- `docs/ai/AI_INSTRUCTIONS.md` (Section 10)
- `memory-bank/techContext.md` (MCP setup)

## Links

- `.clinerules`
- `analysis_options.yaml`
- `docs/ai/AI_INSTRUCTIONS.md`
- `docs/ai/README_SUPABASE.md`

