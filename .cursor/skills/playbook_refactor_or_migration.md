---
name: playbook_refactor_or_migration
intent: Quy trình refactor/migration lớn (vd: Provider → Riverpod, đổi router, reorganize widgets)
tags: [playbook, refactor, architecture]
---

## Khi dùng

Khi cần thay đổi kiến trúc hoặc structure lớn:
- Migrate từ pattern cũ sang mới (Provider → Riverpod, AppRoutes → GoRouter, v.v.)
- Tái tổ chức thư mục/widgets cho scale up

## Checklist (refactor an toàn)

1) **Đọc chuẩn kiến trúc hiện tại**
- `.clinerules` (Architecture, Router, Code Quality)
- `.cursor/.cursorrules` (tech stack chuẩn)
- `10_architecture_clean_mvvm.md`, `20_state_riverpod_asyncnotifier.md`, `30_routing_gorouter_rbac_shellroute.md`
- `memory-bank/systemPatterns.md` + `activeContext.md` (status migration hiện tại)

2) **Xác định phạm vi**
- Liệt kê screens/features bị ảnh hưởng
- Ưu tiên small steps (migrate từng screen/module, không big-bang)

3) **Lập kế hoạch refactor**
- Bước tạm (compatibility layer) nếu cần
- Thứ tự migrate: core/router/provider → screens → widgets

4) **Thực hiện từng bước nhỏ**
- Mỗi bước: giữ app chạy được, test manual nhanh flow chính
- Ưu tiên convert các entrypoint/flows quan trọng trước (auth, dashboards)

5) **Testing & cleanup**
- Sau mỗi batch: chạy `flutter analyze` + tests liên quan (`70_*`, `80_*`)
- Cleanup code cũ/legacy khi chắc chắn không còn dùng (và đã ghi nhận trong memory-bank nếu cần)

## Links

- `.clinerules` (Architecture & Router sections)
- `.cursor/.cursorrules` (tech stack chuẩn)
- `10_architecture_clean_mvvm.md`
- `20_state_riverpod_asyncnotifier.md`
- `30_routing_gorouter_rbac_shellroute.md`
- `40_ui_design_system_tokens.md`
- `70_code_quality_and_lints.md`

