---
name: Cursor Skills Handbook
overview: Tổng hợp rules/kỹ thuật/kỹ năng đã có trong codebase và chuẩn hoá thành bộ “skill modules” trong `.cursor/skills` để bạn luyện tập và tái dùng khi build dự án.
todos:
  - id: inventory-rules
    content: Trích và gom nhóm rules/patterns từ các nguồn chuẩn trong repo
    status: pending
  - id: design-structure
    content: Chốt cấu trúc modules + outline và mapping nguồn → module
    status: pending
    dependencies:
      - inventory-rules
  - id: rewrite-skill-index
    content: Refactor `SKILL.md` thành index + hướng dẫn dùng + đường dẫn modules
    status: pending
    dependencies:
      - design-structure
  - id: write-modules
    content: Tạo và viết nội dung các skill modules trong `.cursor/skills/` theo template thống nhất
    status: pending
    dependencies:
      - design-structure
  - id: consistency-pass
    content: Rà soát trùng lặp/mâu thuẫn, gắn nhãn legacy, chuẩn hoá thuật ngữ và checklist luyện tập
    status: pending
    dependencies:
      - rewrite-skill-index
      - write-modules
---

# Chuẩn hoá skill@.cursor/skills

## Mục tiêu

- Chắt lọc toàn bộ **rules + kỹ thuật + patterns** đã hình thành trong repo (Flutter/Riverpod/GoRouter/Supabase/MCP/Design System/Code Quality/Docs workflow).
- Tổ chức lại thành **nhiều skill modules** trong `.cursor/skills/` để dễ học, dễ tra cứu, dùng như “playbook” khi xây dự án.

## Nguồn chuẩn để tổng hợp (không suy đoán)

- `.cursor/skills/cusrurrulers/SKILL.md`
- `.clinerules`
- `docs/ai/AI_INSTRUCTIONS.md`
- `README.md`
- `analysis_options.yaml`
- `memory-bank/systemPatterns.md`, `memory-bank/activeContext.md`, `memory-bank/techContext.md`
- `docs/guides/development/context-reading-protocol.md`

## Thiết kế cấu trúc skill modules (đề xuất)

- **Index/Entry**: cập nhật `SKILL.md` để làm trang điều hướng + nguyên tắc sử dụng.
- **Modules** (mỗi module 1 file, nội dung ngắn-gọn, có checklist luyện tập):
- `00_task_classification_and_context_reading.md`: phân loại task + đọc đúng tài liệu/tool (tổng hợp từ `SKILL.md`, `.clinerules`, `docs/guides/...`).
- `10_architecture_clean_mvvm.md`: boundaries, layer rules, DataSource-only-Supabase (từ `systemPatterns.md`, `AI_INSTRUCTIONS.md`).
- `20_state_riverpod_asyncnotifier.md`: patterns `ref.watch/ref.read`, AsyncNotifier, tránh lỗi refresh/auth reset (từ `systemPatterns.md`, `activeContext.md`, `techContext.md`).
- `30_routing_gorouter_rbac_shellroute.md`: “Tứ Trụ” GoRouter+Riverpod+RBAC+ShellRoute, rules goNamed/pathParameters/no hardcode/no Navigator.push (từ `.clinerules`, `techContext.md`, `systemPatterns.md`).
- `40_ui_design_system_tokens.md`: DesignTokens, responsive spacing, component standards, accessibility, widget organization (từ `.clinerules`, `systemPatterns.md`, `DESIGN_SYSTEM_GUIDE.md`).
- `50_data_supabase_rls_storage.md`: datasource/repo rules, RLS mindset, storage naming, error translation VN (từ `systemPatterns.md`, `techContext.md`, `AI_INSTRUCTIONS.md`).
- `60_mcp_workflow.md`: Supabase MCP / Fetch / Context7 / Dart MCP: khi nào dùng, checklist trước khi code (từ `.clinerules`, `techContext.md`, `CURSOR_SETUP.md`).
- `70_code_quality_and_lints.md`: function<50 lines/class<300, avoid_print/AppLogger, format/analyze workflow, conventions (từ `.clinerules`, `analysis_options.yaml`, `README.md`).

## Nội dung chuẩn cho mỗi module

- **Rule Set**: “DO / DON’T” thật cụ thể (trích từ nguồn).
- **Why**: 1-2 đoạn giải thích ngắn (lý do tồn tại của rule).
- **Golden patterns**: snippet/pseudocode ngắn (không dài, chỉ minh hoạ).
- **Checklist luyện tập**: 5-10 gạch đầu dòng kiểu “khi làm X thì phải làm Y”.
- **Anti-patterns**: lỗi hay gặp trong repo (ví dụ: gọi `context.go()` sai chỗ, refresh reset auth, hardcode spacing/colors).
- **Links**: trỏ về file nguồn trong repo.

## Các thay đổi dự kiến trong repo

- **Cập nhật** `d:/code/Flutter_Android/AI_LMS_PRD/.cursor/skills/cusrurrulers/SKILL.md` để:
- bỏ tham chiếu mơ hồ/khó dùng, thay bằng mục lục modules + “how to use”.
- thống nhất thuật ngữ: `.clinerules` là “central rules”, không nhầm `.cursorrules`.
- **Tạo mới** các file module trong `d:/code/Flutter_Android/AI_LMS_PRD/.cursor/skills/` (chỉ trong thư mục này, theo quyền bạn đã cho).

## Tiêu chí hoàn thành

- `SKILL.md` trở thành **entrypoint** rõ ràng.
- Mỗi module đọc trong 2–5 phút, có checklist thực hành.
- Không còn rule trùng lặp/mâu thuẫn; chỗ nào legacy (Provider/AppRoutes) được gắn nhãn rõ.

## Todos

- `inventory-rules`: Trích rule/pattern cốt lõi từ `.clinerules`, `memory-bank/*`, `docs/ai/*`.
- `design-structure`: Chốt danh sách modules + outline từng module.
- `rewrite-skill-index`: Refactor `SKILL.md` thành index + usage.
- `write-modules`: Viết các module files theo template thống nhất.
- `consistency-pass`: Rà soát trùng lặp/mâu thuẫn, chuẩn hoá thuật ngữ (GoRouter v2, Riverpod primary, Provider legacy, docs rules).