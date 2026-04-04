---
name: dart-atd
description: Auto-implement, test, debug and fix Flutter app using 3 Dart MCPs + Supabase CLI. Connects to running app, writes code, hot-reloads, verifies UI visually, and auto-fixes up to 3 iterations. Use when given a Flutter feature/bug requirement to implement hands-free.
argument-hint: <yêu cầu feature hoặc bug cần fix>
disable-model-invocation: true
allowed-tools: Read, Edit, Write, Glob, Grep, Bash, mcp__dart__list_running_apps, mcp__dart__connect_dart_tooling_daemon, mcp__dart__add_roots, mcp__dart__analyze_files, mcp__dart__hot_reload, mcp__dart__get_runtime_errors, mcp__dart__get_app_logs, mcp__dart__get_widget_tree, mcp__marionette__connect, mcp__marionette__take_screenshots, mcp__marionette__get_interactive_elements, mcp__marionette__tap, mcp__marionette__enter_text, mcp__marionette__scroll_to, mcp__marionette__hot_reload, mcp__mcp-flutter-debug__get_active_ports, mcp__mcp-flutter-debug__hot_reload_flutter
---

# dart-atd — Auto Test & Debug Flutter

Yêu cầu: **$ARGUMENTS**

Thực hiện tuần tự 5 phase sau. KHÔNG hỏi user trừ khi phase 1 thất bại.

---

## PHASE 1 — SETUP

> Mục tiêu: kết nối đủ 3 MCP trước khi làm bất cứ gì.

**1.1** Detect app đang chạy:
```
mcp__dart__list_running_apps()
```
- Lấy `dtdUri` (ví dụ `ws://127.0.0.1:62123/...`)
- **Nếu không có app** → STOP, yêu cầu user chạy app trước bằng `flutter run`

**1.2** Kết nối Dart Tooling Daemon:
```
mcp__dart__connect_dart_tooling_daemon(dtdUri: "<dtdUri>")
```
Lưu `isolateId` từ response.

**1.3** Thêm project root:
```
mcp__dart__add_roots(roots: ["/mnt/d/code/Flutter_Android/Flutter_Android/AI_LMS_PRD"])
```

**1.4** Lấy VM port để kết nối Marionette:
```
mcp__mcp-flutter-debug__get_active_ports()
```
Construct URI: `ws://127.0.0.1:<port>/ws`

```
mcp__marionette__connect(uri: "ws://127.0.0.1:<port>/ws")
```

**Fallback nếu `get_active_ports` thất bại:** Dùng host:port từ `dtdUri`, path `/ws`.

**1.5** Screenshot trạng thái ban đầu (baseline):
```
mcp__marionette__take_screenshots()
```

---

## PHASE 2 — UNDERSTAND & IMPLEMENT

**2.1** Phân tích yêu cầu `$ARGUMENTS`. Xác định:
- Feature mới / Bug fix / UI change / Data fix
- Files cần đọc/sửa

**2.2** Nếu yêu cầu liên quan đến DB — kiểm tra schema TRƯỚC khi code:
```bash
supabase db query --local --sql "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = '<table>' ORDER BY ordinal_position;"
```
KHÔNG assume tên cột. Dùng `--local` (project dùng Supabase local Docker).

**2.3** Đọc files liên quan bằng `Read`, `Grep`, `Glob` trước khi sửa.

**2.4** Implement theo Clean Architecture:
- `domain/` → entities, repository interfaces
- `data/` → Freezed models, datasources, repository impls
- `presentation/providers/` → Riverpod (`@riverpod` generator)
- `presentation/views/` → screens, widgets

Rules bắt buộc:
- Design tokens: `DesignColors.*`, `DesignSpacing.*`, `DesignTypography.*`, `DesignRadius.*`
- State: `@riverpod`, `AsyncValue.guard()`, `ref.watch()` trong UI / `ref.read()` trong callbacks
- KHÔNG hardcode values, KHÔNG `print()` → dùng `AppLogger`

**2.5** Analyze sau khi viết code:
```
mcp__dart__analyze_files(path: "/mnt/d/code/Flutter_Android/Flutter_Android/AI_LMS_PRD")
```
Fix **tất cả** lỗi. Nếu có Freezed/JsonSerializable thay đổi:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## PHASE 3 — VERIFY

**3.1** Hot reload:
```
mcp__dart__hot_reload(isolateId: "<isolateId>", clearRuntimeErrors: true)
```
Fallback: `mcp__mcp-flutter-debug__hot_reload_flutter()`

**3.2** Screenshot sau reload — so sánh với baseline:
```
mcp__marionette__take_screenshots()
```

**3.3** Kiểm tra runtime errors:
```
mcp__dart__get_runtime_errors(isolateId: "<isolateId>")
```

**3.4** Nếu cần test flow UI:
```
mcp__marionette__get_interactive_elements()
```
Rồi tap/enter theo flow:
```
mcp__marionette__tap(key: "<ValueKey>")
mcp__marionette__enter_text(key: "<ValueKey>", text: "<value>")
mcp__marionette__scroll_to(key: "<ValueKey>")
```

---

## PHASE 4 — AUTO-FIX (tối đa 3 vòng)

Nếu phase 3 phát hiện lỗi, thực hiện loop:

```
for attempt in 1..3:
  1. Đọc error message / screenshot hiện tại
  2. Phân tích root cause (KHÔNG đoán mò)
  3. Sửa code → analyze_files → fix tất cả lỗi
  4. hot_reload(clearRuntimeErrors: true)
  5. take_screenshots()
  6. get_runtime_errors()
  7. Nếu clean → break → sang PHASE 5
```

**Sau 3 vòng vẫn lỗi** → báo user:
- Screenshot hiện tại
- Error message đầy đủ
- Những gì đã thử (từng attempt)
- Đề xuất hướng xử lý tiếp theo

---

## PHASE 5 — DONE

**5.1** Final screenshot:
```
mcp__marionette__take_screenshots()
```

**5.2** Báo cáo:
```
✅ Hoàn thành: <mô tả>

Files đã thay đổi:
- <file>: <thay đổi gì>

Visual: <mô tả screenshot trước/sau>

Cần làm thêm (nếu có):
- ...
```

---

## Reference nhanh

| Mục đích | Tool |
|----------|------|
| Detect app | `mcp__dart__list_running_apps` |
| Kết nối DTD | `mcp__dart__connect_dart_tooling_daemon` |
| Add roots | `mcp__dart__add_roots` |
| Lấy VM port | `mcp__mcp-flutter-debug__get_active_ports` |
| Kết nối UI | `mcp__marionette__connect` |
| Screenshot | `mcp__marionette__take_screenshots` |
| Analyze | `mcp__dart__analyze_files` |
| Hot reload | `mcp__dart__hot_reload` |
| Runtime errors | `mcp__dart__get_runtime_errors` |
| Widget tree | `mcp__dart__get_widget_tree` |
| UI elements | `mcp__marionette__get_interactive_elements` |
| DB schema | `supabase db query --local --sql "..."` |

**DTD URI ≠ VM service URI**: DTD từ `list_running_apps` (cho dart MCP); VM port từ `get_active_ports` → `ws://127.0.0.1:<port>/ws` (cho marionette).
