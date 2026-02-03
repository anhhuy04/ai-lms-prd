# Nâng cấp plan xây dựng bộ skill `.cursor/skills` cho AI_LMS_PRD (v2)

### Chẩn đoán plan v1: còn thiếu gì / vì sao cần chỉnh

- **Thiếu “nguồn luật gốc” quan trọng**: v1 chủ yếu tổng hợp từ `memory-bank/*` + vài file tổng kết. Nhưng trong repo còn 3 nguồn thường là “luật chuẩn” cho agent/đội dev:
- [`analysis_options.yaml`](analysis_options.yaml) (lint/format rules thực thi)
- [`AI_INSTRUCTIONS.md`](AI_INSTRUCTIONS.md) (hướng dẫn triển khai, MCP usage patterns, cấu trúc dự án)
- **`.clinerules` / `.cursor/.cursorrules`** (nếu tồn tại) – thường là các quy tắc *mạnh* như giới hạn độ dài hàm/file, refactor rules, git workflow.

- **Chia skill theo module là hợp lý nhưng chưa tối ưu cho “build dự án”**: khi dev thật, task thường theo *workflow* (thêm feature end-to-end, sửa bug, refactor/migrate, thêm table/RLS, viết test). Nếu chỉ module-based, agent có thể biết “đúng kỹ thuật” nhưng thiếu “playbook” để chạy theo tuyến.

- **Thiếu nhóm skill về “quality gates” và “operational readiness”**: codebase có Sentry/logger, test folder, checklist build/analyze, nhưng chưa thành skill riêng để agent luôn làm đúng.

### Tự đặt câu hỏi “Vì sao chia như vậy?” và đề xuất tối ưu

#### Câu hỏi 1: Vì sao chọn mức `medium granularity`?

- **Lý do đúng**: module-level đủ nhỏ để học nhanh và đủ lớn để bao phủ pattern.
- **Điểm yếu**: một số pattern “đắt giá” (vd: *splash reactive navigation*, *optimistic class settings*, *dashboard refresh không reset auth*) dễ bị chìm nếu không có trigger/guard rõ.

**Tối ưu**: giữ module-level làm xương sống, nhưng thêm:

- **“Critical-pattern micro skills”** (2–5 skill) cho các bug/pattern từng gây lỗi nặng (loop splash, Future already completed, refresh auth reset). Chúng không nhiều nhưng tác dụng lớn.

#### Câu hỏi 2: Module-based hay workflow-based mới tối ưu?

- **Module-based**: tốt để tra cứu nhanh theo thư mục/file.
- **Workflow-based**: tốt để agent tự chạy từ A→Z.

**Tối ưu**: dùng **2 tầng skill**:

- **Tầng A (Foundations / Module-based)**: kiến trúc, state, routing, design system, supabase, mcp.
- **Tầng B (Playbooks / Workflow-based)**: thêm feature mới, refactor/migrate, debug/perf, schema+RLS, release checklist.

### Danh sách skill v2 (đề xuất)

#### A) Foundations (module-based, giữ từ v1 nhưng bổ sung)

- `flutter_clean_architecture`
- `flutter_state_management_riverpod`
- `flutter_state_management_provider_legacy`
- `routing_gorouter_rbac_shellroute`
- `design_system_tokens_and_enforcement`
- `design_system_responsive_and_accessibility`
- `widgets_drawer_system`
- `widgets_dialog_system`
- `widgets_search_system`
- `supabase_integration_and_env`
- `repository_and_error_handling`
- `class_settings_and_optimistic_updates`

**Bổ sung mới (foundation) cần có để build dự án**:

- `logging_and_observability`
- Chuẩn: dùng `AppLogger`, cách log có context, khi nào gửi Sentry.
- `testing_strategy_and_structure`
- Unit/widget/integration: naming, boundaries mock (repo vs datasource), cách viết test theo MVVM/Riverpod.
- `performance_and_responsiveness`
- Quy tắc tránh rebuild nặng, debounce autosave, list performance, pagination, realtime subscription limits.
- `security_and_privacy_supabase`
- RLS-first mindset, phân quyền theo role, nguyên tắc không lộ keys/logs nhạy cảm.
- `local_storage_conventions`
- `flutter_secure_storage` vs SharedPreferences: cái gì lưu ở đâu, naming keys, migration.

#### B) Critical-pattern micro skills (ít nhưng “gác cổng” lỗi lớn)

- `critical_splash_no_manual_navigation`
- Golden rule: không `context.go()` trong init/build của màn do router quản.
- `critical_dashboard_refresh_no_auth_reset`
- Refresh chỉ refresh data provider; không set loading gây redirect.
- `critical_asyncnotifier_concurrency_guards`
- Tránh `Bad state: Future already completed`, khi nào dùng optimistic update vs full update.

#### C) Playbooks (workflow-based)

- `playbook_add_new_feature_end_to_end`
- Checklist: route → UI screen → notifier/viewmodel → domain interface → repo impl → datasource → UI states → error i18n.
- `playbook_add_new_supabase_table_and_rls`
- Checklist: schema → migration → RLS policies → types/models → datasource queries → repository → tests.
- `playbook_refactor_or_migration`
- Ví dụ: Provider→Riverpod, widget reorg, rename folder; cách làm incremental, tránh big bang.
- `playbook_debug_and_fix_regression`
- Logging checklist, reproduction, minimal fix, add test, verify.

### Chuẩn hóa schema cho từng skill (v2)

Để agent dùng được thật sự, v2 cần schema **có khả năng kích hoạt đúng lúc**:

- **metadata**: name, intent, tags, owner.
- **triggers** (rất quan trọng):
- **file_globs** (vd: `lib/core/routes/**`, `lib/widgets/dialogs/**`)
- **keywords** (vd: `context.go`, `ShellRoute`, `AsyncNotifier`, `class_settings`)
- **symptoms** (vd: “Future already completed”, “redirect to login on refresh”).
- **rules**: dạng checklist DO/DON’T ngắn.
- **examples**: 1 “good”, 1 “bad” (trích ngắn từ docs nội bộ).
- **links**: đường dẫn tới tài liệu trong repo.

### Bổ sung bước “Inventory hiện trạng `.cursor/skills`” trước khi viết

V1 chưa kiểm tra thư mục `.cursor/skills` hiện có và cách Cursor mong đợi format. V2 thêm bước:

- **Đọc cấu trúc hiện tại** dưới [`.cursor/skills`](.cursor/skills) và thư mục con `cusrurrulers/` để:
- không phá convention cũ
- chọn đúng format (json/yaml/md/whatever) theo thực tế.

### Cập nhật lộ trình (phân kỳ rõ hơn)

- **Phase 0 (Inventory & Ground truth)**
- Đọc/đối chiếu: `analysis_options.yaml`, `AI_INSTRUCTIONS.md`, `.clinerules`, `.cursor/.cursorrules`, `.cursor/skills/**`.
- **Phase 1 (Foundations)**
- Viết 6 skill nền tảng quan trọng nhất: architecture, riverpod, routing, design system enforcement, supabase env, repository error.
- **Phase 2 (Critical micro skills)**
- Viết 3 skill “gác cổng” lỗi lớn.
- **Phase 3 (Playbooks)**
- Viết 2 playbook quan trọng: add feature end-to-end; add table+RLS.
- **Phase 4 (Mở rộng & tinh chỉnh)**
- Drawer/dialog/search, optimistic updates, performance/security/testing/logging.

### Tiêu chí hoàn thành (Definition of Done)

- Mỗi skill có trigger rõ (file_globs/keywords/symptoms).
- Rules actionable, không dài.
- Có ít nhất 1 good/bad example.
- Có link tới “ground truth” trong repo.
- Thử nghiệm bằng 2–3 scenario (agent nhận task và áp dụng đúng).

---

Nếu bạn đồng ý hướng v2 này, bước tiếp theo (trong chế độ plan) là mình sẽ đọc thêm **`analysis_options.yaml`, `AI_INSTRUCTIONS.md`, `.clinerules`, và nội dung `.cursor/skills` hiện tại** để chốt schema/format chính xác trước khi viết skill thật.