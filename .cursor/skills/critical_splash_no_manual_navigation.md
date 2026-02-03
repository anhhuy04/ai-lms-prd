---
name: critical_splash_no_manual_navigation
intent: Ngăn loop splash/rebuild bằng cách tránh manual navigation từ widget
tags: [critical, routing, riverpod]
---

## Symptom

- App đứng ở splash / log spam `initState` / widget bị dispose rồi tạo lại liên tục.

## Trigger

- **keywords**: `initState`, `context.go`, `context.push`, `SplashScreen`

## Golden rule

**Không manual `context.go()` từ widget “managed by router” trong `initState()`/`build()`.**  
Thay vào đó: widget chỉ render state; router redirect dựa trên provider.

## Links

- `ARCHITECTURE_FIX.md`
- `QUICK_REFERENCE.md`
- `memory-bank/systemPatterns.md` (Router architecture)

