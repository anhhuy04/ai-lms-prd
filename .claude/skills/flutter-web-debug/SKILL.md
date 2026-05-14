---
name: flutter-web-debug
description: "Kích hoạt khi cần debug Flutter app đang chạy (web hoặc mobile) — inspect widget tree, đọc console/runtime errors, screenshot, tap/scroll/enter text, hot reload. Auto-connect VM service hoặc Chrome browser."
---

# Kỹ năng: Flutter Web & Mobile Debug Tự Động

> Workflow chuẩn để debug Flutter app đang chạy. **Quan trọng:** Flutter render bằng Canvas/SKIA — DOM tree gần như rỗng. KHÔNG dùng `chrome-devtools-mcp` để inspect UI, dùng các MCP server dưới đây.

---

## 1. Bảng quyết định MCP theo platform

| Platform | Inspect Widget | Tương tác (tap/scroll) | Console/Errors | Screenshot | Hot Reload |
|----------|---------------|----------------------|---------------|-----------|-----------|
| **Flutter Web** (Chrome) | `dart` + `marionette` | `marionette` | `claude-in-chrome` (browser console) + `dart` (runtime errors) | `claude-in-chrome` | `dart` / `mcp-flutter-debug` |
| **Flutter Mobile** (Android/iOS) | `dart` + `marionette` | `marionette` | `dart` (runtime errors + app logs) | `marionette` | `dart` / `marionette` |

**Luật vàng:** Widget tree luôn đọc qua VM service (`dart`/`marionette`), KHÔNG đọc qua DOM. DOM của Flutter web chỉ là `<flt-glass-pane>` rỗng.

---

## 2. Quy trình khởi động (Auto-Connect)

### Bước 0 — Phát hiện app đang chạy

Trước khi làm gì, kiểm tra xem app đã chạy chưa:

```
mcp__dart__list_running_apps         → trả về VM service URI nếu có
mcp__mcp-flutter-debug__get_active_ports  → backup, list debug ports
```

Nếu KHÔNG có app chạy → yêu cầu user start app trước (xem Bước 1A/1B).

### Bước 1A — Start Flutter Web (nếu user muốn web)

Khuyến nghị user chạy lệnh trong terminal của họ (KHÔNG chạy qua Bash vì sẽ block session):

```powershell
flutter run -d chrome --web-port=8080 --debug `
  --web-browser-flag="--remote-debugging-port=9222"
```

Sau đó: User mở `localhost:8080` trên Chrome đã có extension `claude-in-chrome`.

### Bước 1B — Start Flutter Mobile (nếu user muốn mobile)

```powershell
mcp__dart__list_devices              → chọn device/emulator
mcp__dart__launch_app                 → launch với cwd của project
```

Hoặc user tự chạy `flutter run -d <device-id>` rồi cung cấp VM service URI.

### Bước 2 — Kết nối

**Web:**
```
mcp__claude-in-chrome__tabs_context_mcp   → lấy tabId của tab localhost:8080
mcp__marionette__connect                   → với VM service URI (ws://127.0.0.1:PORT/ws)
```

**Mobile:**
```
mcp__dart__list_running_apps              → lấy VM service URI
mcp__marionette__connect                   → connect VM
```

### Bước 3 — Verify connection

```
mcp__marionette__get_interactive_elements  → liệt kê widget có ValueKey/Text
mcp__mcp-flutter-debug__get_vm             → VM info
```

Báo lại cho user: số widget interactive, có lỗi runtime nào, screenshot hiện trạng.

---

## 3. Debug Recipes

### A. "App có lỗi gì không?"

```
mcp__dart__get_runtime_errors             → lỗi Flutter runtime + stack trace
mcp__dart__get_app_logs                   → log debugPrint/AppLogger
mcp__claude-in-chrome__read_console_messages  (chỉ web) → JS console
```

Filter log: dùng `pattern` regex (vd: `\[Auth\]` hoặc `ERROR`) để tránh nuốt context.

### B. "Tại sao button X không hoạt động?"

```
mcp__marionette__get_interactive_elements     → tìm button theo ValueKey
mcp__marionette__tap                          → tap thử
mcp__dart__get_runtime_errors                 → check lỗi sau tap
mcp__marionette__take_screenshots             → so sánh trước/sau
```

Nếu widget không có `ValueKey` → đề xuất user thêm `key: ValueKey('xxx_button')` vào source.

### C. "UI bị overflow / responsive sai"

```
mcp__marionette__take_screenshots             → screenshot full
mcp__dart__get_widget_tree                    → đọc cấu trúc widget tại điểm lỗi
mcp__dart__get_selected_widget                → nếu user đã tap pick widget trong app
```

Kiểm tra `MediaQuery`, `LayoutBuilder`, `flutter_screenutil` `.w/.h/.sp/.r`. Đối chiếu với `lib/core/constants/design_tokens.dart`.

### D. "Test luồng login → home"

```
mcp__marionette__enter_text (email_field)
mcp__marionette__enter_text (password_field)
mcp__marionette__tap (login_button)
mcp__dart__get_app_logs (pattern: "Auth|Login")
mcp__marionette__take_screenshots
```

Sau mỗi bước check `get_runtime_errors` để bắt crash sớm.

### E. "Sửa code xong, reload"

```
mcp__dart__hot_reload                     → ưu tiên (giữ state)
mcp__dart__hot_restart                    → khi đổi main()/init/providers
```

KHÔNG kill process Flutter rồi `flutter run` lại — quá chậm.

### F. "Đọc network requests" (chỉ web)

```
mcp__claude-in-chrome__read_network_requests
```

Mobile: dùng `AppLogger` + Dio interceptor logging, đọc qua `get_app_logs`.

---

## 4. Quy tắc khi dùng MCP browser tools

> Theo system instructions, mọi `mcp__claude-in-chrome__*` cần load schema trước:

```
ToolSearch query="select:mcp__claude-in-chrome__<tool_name>"   → load schema
→ Sau đó call tool bình thường
```

**KHÔNG trigger JS dialogs** (alert/confirm/prompt) — sẽ block extension. Nếu phải click button có confirm dialog: cảnh báo user trước, dùng `javascript_tool` dismiss dialog cũ.

**Reuse tab:** Mỗi session lấy tab mới qua `tabs_context_mcp`, KHÔNG dùng tabId cũ.

---

## 5. Project-specific shortcuts (AI_LMS_PRD)

- App entry: `lib/main.dart`. Provider chính: `authProvider`, `classListProvider`.
- ValueKey convention: `'<feature>_<action>_button'` (vd: `'login_submit_button'`).
- Routes định nghĩa trong `lib/core/routes/route_constants.dart` (`AppRoute.*`). Khi test navigation, đọc constants thay vì đoán path.
- Sau khi sửa Freezed/Riverpod generator → user phải chạy:
  ```
  flutter pub run build_runner build --delete-conflicting-outputs
  ```
  rồi mới `hot_restart`. Hot reload KHÔNG nhận file `.g.dart` mới.
- Verify cuối cùng (theo CLAUDE.md §15):
  ```
  flutter analyze
  flutter test
  ```

---

## 6. Anti-patterns (KHÔNG làm)

| ❌ Sai | ✅ Đúng |
|--------|--------|
| Inspect DOM Flutter web qua Chrome DevTools elements panel | Đọc widget tree qua `mcp__dart__get_widget_tree` |
| Cài thêm `chrome-devtools-mcp` | Đã có `claude-in-chrome` + `marionette` đủ rồi |
| `print()` trong code | `AppLogger.d/i/w/e()` theo CLAUDE.md §4 |
| Tap widget bằng tọa độ (x, y) | Tap bằng ValueKey qua `marionette` |
| Đọc toàn bộ console không filter | Dùng `pattern` regex |
| Kill app rồi `flutter run` lại sau mỗi sửa | `mcp__dart__hot_reload` |

---

## 7. Quick checklist khi kích hoạt skill

- [ ] Đã `list_running_apps`? Có VM URI?
- [ ] Web: tab `localhost:*` đang mở? Mobile: device connected?
- [ ] `marionette__connect` thành công?
- [ ] Đã `get_runtime_errors` để biết trạng thái app?
- [ ] Đã thông báo cho user: kết nối OK / widget có sẵn / lỗi hiện tại?

Sau khi check xong → sẵn sàng nhận lệnh debug từ user.
