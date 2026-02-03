---
name: cusrurrulers
description: Canonical skills handbook index for AI_LMS_PRD (Cursor skills entrypoint)
---

## Overview

File entrypoint cho bộ skill trong `.cursor/skills/`.

**Mục tiêu:** giúp agent/dev tra cứu nhanh rule/pattern đúng lúc, đúng nơi (Flutter + Supabase + MCP), và có checklist để build dự án.

## Nguyên tắc chống “loạn”

- `.`**clinerules** là **single source of truth** cho rules toàn dự án.
- `SKILL.md` chỉ giữ vai trò **Index + playbook routing** (trỏ đến đúng module), không lặp nguyên văn `.clinerules`.
- Khi có rule mới: cập nhật `.clinerules` trước; `SKILL.md` chỉ thêm link trong Index nếu cần.

---

## Cách dùng nhanh

- **Nếu bạn đang làm UI** → xem `40_ui_design_system_tokens.md` + `70_code_quality_and_lints.md`
- **Nếu bạn đang làm routing** → xem `30_routing_gorouter_rbac_shellroute.md` + `critical_splash_no_manual_navigation.md`
- **Nếu bạn đang làm state/Riverpod** → xem `20_state_riverpod_asyncnotifier.md` + `critical_asyncnotifier_concurrency_guards.md`
- **Nếu bạn đang làm Supabase/data** → xem `50_data_supabase_rls_storage.md` + `playbook_add_new_supabase_table_and_rls.md`
- **Nếu bạn đang làm end-to-end feature** → xem `playbook_add_new_feature_end_to_end.md`

---

## Index (canonical)

### Foundations (modules)

- `00_task_classification_and_context_reading.md`
- `10_architecture_clean_mvvm.md`
- `20_state_riverpod_asyncnotifier.md`
- `30_routing_gorouter_rbac_shellroute.md`
- `40_ui_design_system_tokens.md`
- `50_data_supabase_rls_storage.md`
- `60_mcp_workflow.md`
- `70_code_quality_and_lints.md`
- `75_logging_and_observability.md`
- `80_testing_strategy_and_structure.md`
- `85_performance_and_responsiveness.md`
- `90_security_and_privacy.md`
- `95_local_storage_conventions.md`

### UX Performance (loading & tab smoothness)

- **Loading shimmer/skeleton**: dùng widgets trong `lib/widgets/loading/shimmer_loading.dart`:
  - `ShimmerLoading` (list lớp học)
  - `ShimmerListTileLoading` (list avatar + text)
  - `ShimmerDashboardLoading` (dashboard/page tổng hợp)
- **Async list chuẩn hóa**: dùng `AsyncListPage<T>` (`lib/widgets/async/async_list_page.dart`) cho các màn list mới nhận `Future<List<T>>`.
- **Tab switching smooth**: đảm bảo ShellRoute/IndexedStack preserve state, không chạy việc nặng trong `build()`.
- **Parallel fetching (bundle loader)**:
  - Đưa toàn bộ fetch của screen vào 1 method notifier kiểu `loadXxxBundle(...)`.
  - Dùng `Future.wait([...])` cho các request độc lập.
  - Chỉ commit `state = AsyncValue.data(...)` **1 lần** (tránh rebuild nhiều lần).
  - Secondary data: load riêng theo section (không set full-page loading), UI dùng shimmer/placeholder section.

### Micro-skills (gác cổng lỗi lớn)

- `critical_splash_no_manual_navigation.md`
- `critical_dashboard_refresh_no_auth_reset.md`
- `critical_asyncnotifier_concurrency_guards.md`

### Playbooks (workflow)

- `playbook_add_new_feature_end_to_end.md`
- `playbook_add_new_supabase_table_and_rls.md`
- `playbook_debug_and_fix_regression.md`
- `playbook_refactor_or_migration.md`

---

## Scenario drills (tự luyện để scale lên app lớn)

Mỗi tình huống dưới đây phải map được đến **1 playbook** + **1–3 skills** (và micro-skill nếu liên quan).

1) **Thêm màn hình mới + route mới (teacher)**: `playbook_add_new_feature_end_to_end.md` + `30_*` + `20_*` + `70_*`
2) **Pull-to-refresh bị đá về login**: `critical_dashboard_refresh_no_auth_reset.md` + `20_*`
3) **Splash loop / initState spam**: `critical_splash_no_manual_navigation.md` + `30_*`
4) **Toggle setting bị lỗi Future already completed**: `critical_asyncnotifier_concurrency_guards.md` + `20_*`
5) **Thêm bảng `assignments` + policies**: `playbook_add_new_supabase_table_and_rls.md` + `50_*` + `90_*`
6) **Thêm trường mới vào JSON `class_settings`**: `50_*` + `critical_asyncnotifier_concurrency_guards.md`
7) **Bug RenderFlex overflow**: `40_*` + `.cursor/.cursorrules` (UI rules)
8) **Cần thêm thư viện mới (vd: editor)**: `60_mcp_workflow.md` + `.cursor/.cursorrules` (Fetch docs trước)
9) **Lỗi RLS khi query**: `50_*` + `90_*` + Supabase MCP
10) **Auto-save cho workspace**: `85_*` + `95_*` + `50_*` (nếu sync Supabase)
11) **Tối ưu list lớn / pagination**: `85_*` + `70_*`
12) **Viết test cho notifier + repo**: `80_testing_strategy_and_structure.md`
13) **Offline-first (Drift) cho workspace/cache**: `95_local_storage_conventions.md` + `.cursor/.cursorrules` (Drift) + `playbook_add_new_feature_end_to_end.md`
14) **Tích hợp external API (Dio/Retrofit)**: `85_performance_and_responsiveness.md` (CancelToken) + `60_mcp_workflow.md` (Fetch docs) + `70_code_quality_and_lints.md`
15) **Deep link / reset-password / verify-email**: `30_routing_gorouter_rbac_shellroute.md` + `.clinerules` (RBAC redirect)
16) **Upload file (Supabase Storage + files/file_links)**: `50_data_supabase_rls_storage.md` + `90_security_and_privacy.md` + `playbook_add_new_supabase_table_and_rls.md`
17) **Thêm Freezed/Envied model → codegen**: `.cursor/.cursorrules` (build_runner) + `70_code_quality_and_lints.md`
18) **Bug liên quan schema mismatch (thiếu cột/constraint)**: `50_*` + `60_mcp_workflow.md` + Supabase MCP
19) **Thêm rich text editor/library mới**: `60_mcp_workflow.md` + `.cursor/.cursorrules` (Fetch docs trước) + `40_ui_design_system_tokens.md`
20) **Chuẩn hóa error messages VN + boundary handling**: `50_*` + `75_logging_and_observability.md`
21) **Debug regression sau khi merge/refactor**: `playbook_debug_and_fix_regression.md` + `70_*` + `75_*`
22) **Refactor/migration lớn (vd: Provider → Riverpod, đổi folder)**: `playbook_refactor_or_migration.md` + `10_*` + `20_*` + `70_*`

---
## Context reading (canonical)

Protocol đọc context là **canonical** trong `.clinerules` (xem `## Mandatory Context Reading Protocol`).
`SKILL.md` không lặp lại để tránh drift; khi cần chi tiết hãy mở:
- `00_task_classification_and_context_reading.md`
- `.clinerules` (context reading + MCP + docs rules)

