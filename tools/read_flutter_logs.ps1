# Script để đọc Flutter logs từ Android device/emulator
# Usage: .\tools\read_flutter_logs.ps1 [filter] [lines]

param(
    [string]$Filter = "flutter:",
    [int]$Lines = 100
)

Write-Host "Reading Flutter logs from Android device/emulator..." -ForegroundColor Cyan
Write-Host "Filter: $Filter" -ForegroundColor Gray
Write-Host "Lines: $Lines" -ForegroundColor Gray
Write-Host ""

# Đọc logs từ logcat và filter
adb logcat -d | Select-String -Pattern $Filter | Select-Object -Last $Lines

Write-Host ""
Write-Host "To watch logs in real-time, run: adb logcat | Select-String -Pattern '$Filter'" -ForegroundColor Yellow
