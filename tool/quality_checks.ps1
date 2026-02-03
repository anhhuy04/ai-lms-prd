param(
  [switch]$SkipPubGet,
  [switch]$SkipAnalyze
)

$ErrorActionPreference = "Stop"

function Write-Section([string]$Title) {
  Write-Host ""
  Write-Host "===================="
  Write-Host $Title
  Write-Host "===================="
}

Write-Section "AI_LMS_PRD - Code Health Checks"

if (-not $SkipPubGet) {
  Write-Section "flutter pub get"
  flutter pub get
}

if (-not $SkipAnalyze) {
  Write-Section "flutter analyze"
  flutter analyze --no-fatal-infos
}

Write-Section "dependency_validator (nợ kỹ thuật dependencies)"
dart run dependency_validator

Write-Section "dart fix (dry-run)"
dart fix --dry-run

Write-Section "DCM (nếu có)"
try {
  dcm --version | Out-Null
  Write-Host "DCM detected. Running checks..."
  dcm check-dependencies lib
  dcm check-unused-code lib
  dcm check-unused-files lib
} catch {
  Write-Host "DCM chưa được cài. Bỏ qua. (Xem docs để cài bản free/CLI)"
}

Write-Section "DONE"
