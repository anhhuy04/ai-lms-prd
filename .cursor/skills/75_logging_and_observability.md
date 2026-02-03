---
name: 75_logging_and_observability
intent: Logging chuẩn (AppLogger) + khi nào cần gửi Sentry
tags: [logging, sentry, observability]
---

## Intent

Debug nhanh, log có cấu trúc, không lộ dữ liệu nhạy cảm.

## Triggers

- **keywords**: `catch (e`, `stackTrace`, `AppLogger`, `Sentry`

## DO / DON'T

- **DO**: log có prefix/namespace theo feature (vd: `[ADD STUDENT]`, `[AUTH]`).
- **DO**: khi catch error, log cả `error` + `stackTrace` nếu có.
- **DO**: report Sentry cho **critical flows** (ví dụ: auth, ghi dữ liệu quan trọng, crash, lỗi boundary DataSource/Repository) theo chuẩn `.cursor/.cursorrules`.
- **DO**: khi debug runtime errors, ưu tiên xem `logs.txt` ở root **nếu file này tồn tại/được bật** theo chuẩn `.cursor/.cursorrules`.
- **DON'T**: log token/anon key/password/email raw nếu không cần.

## Links

- `analysis_options.yaml` (avoid_print)
- `memory-bank/techContext.md` (logger, sentry_flutter)

