---
name: playbook_debug_and_fix_regression
intent: Quy trình debug & fix regression an toàn (đặc biệt khi app lớn)
tags: [playbook, debug, quality]
---

## Khi dùng

Khi một bug xuất hiện (thường sau refactor/merge hoặc thêm feature mới) và bạn cần:
- Xác định root cause
- Sửa không phá chỗ khác
- Giữ chất lượng/tài liệu ổn

## Checklist (vòng debug)

1) **Xác nhận context**
- Đọc issue/log/user report (nếu có)
- Xác định screen/flow bị lỗi (vd: auth, dashboard, class, assignment)

2) **Thu thập dữ liệu**
- Check console/logs (`AppLogger` output, Sentry nếu có)
- Nếu có `logs.txt` (được bật): đọc đoạn liên quan
- Xác định stack trace (file, line, provider/notifier liên quan)

3) **Phân loại bug**
- UI/layout → xem `40_ui_design_system_tokens.md` + `.cursorrules` (UI rules)
- State/Routing → xem `20_state_riverpod_asyncnotifier.md`, `30_routing_gorouter_rbac_shellroute.md`, critical micro-skills
- Data/Supabase → xem `50_data_supabase_rls_storage.md`, `90_security_and_privacy.md`, Supabase MCP

4) **Chọn pattern sửa phù hợp**
- Loop splash / redirect sai → dùng `critical_splash_no_manual_navigation.md`, `critical_dashboard_refresh_no_auth_reset.md`
- AsyncNotifier error/concurrency → `critical_asyncnotifier_concurrency_guards.md`
- RLS/query fail → `playbook_add_new_supabase_table_and_rls.md` + `50_*`

5) **Thực hiện fix nhỏ, có target**
- Sửa đúng layer (UI vs Notifier vs Repo vs DataSource)
- Giữ thay đổi tập trung (1 regression → 1 commit/tập thay đổi)

6) **Verify & bảo vệ**
- Test lại flow gây bug + các luồng liên quan
- Thêm test (unit/widget/integration) nếu bug đủ nghiêm trọng (`80_testing_strategy_and_structure.md`)
- Đảm bảo quality gates: `70_code_quality_and_lints.md`

## Links

- `.clinerules` (Debug & quality sections)
- `.cursor/.cursorrules` (Debug rules, logs.txt, Sentry)
- `70_code_quality_and_lints.md`
- `75_logging_and_observability.md`
- `80_testing_strategy_and_structure.md`

