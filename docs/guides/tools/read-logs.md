# Cách đọc Flutter logs trực tiếp

## Cách 1: Sử dụng adb logcat (Khuyến nghị)

### Đọc logs đã có:
```powershell
# Đọc tất cả Flutter logs
adb logcat -d -s flutter:* | Select-Object -Last 100

# Đọc logs với filter cụ thể
adb logcat -d | Select-String -Pattern "flutter:|NAVIGATION|UI|deleteClass" | Select-Object -Last 50
```

### Xem logs real-time:
```powershell
# Xem logs real-time với filter
adb logcat | Select-String -Pattern "flutter:"
```

## Cách 2: Ghi logs vào file

Có thể cấu hình Flutter để ghi logs vào file `.cursor/debug.log` để tôi có thể đọc trực tiếp.

## Cách 3: Sử dụng Flutter DevTools

Flutter DevTools có thể hiển thị logs trực tiếp trong browser.
