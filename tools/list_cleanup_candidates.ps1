param(
  # Root project directory (default: current directory)
  [string]$Root = '.',

  # If set, writes a markdown report to this path
  [string]$OutReport = '',

  # Include large/binary artifacts that are usually noise (installers, vsix, etc.)
  [switch]$IncludeBinaries
)

$ErrorActionPreference = 'Stop'

function Write-Section([string]$Title) {
  Write-Host ''
  Write-Host '===================='
  Write-Host $Title
  Write-Host '===================='
}

function Normalize-Path([string]$Path) {
  return (Resolve-Path -Path $Path).Path
}

$rootPath = Normalize-Path $Root

Write-Section "Cleanup Candidates (LIST ONLY - NO DELETE)"
Write-Host ('Root: {0}' -f $rootPath)

# Patterns / rules:
# - Keep this conservative: list likely-noise files only.
$candidates = @()

function Add-CandidatesByGlob([string]$Glob, [string]$Reason) {
  $items = Get-ChildItem -Path $rootPath -Recurse -Force -ErrorAction SilentlyContinue -File `
    | Where-Object { $_.FullName -like (Join-Path $rootPath $Glob) }
  foreach ($it in $items) {
    $script:candidates += [pscustomobject]@{
      Path   = $it.FullName
      SizeKB = [math]::Round($it.Length / 1KB, 1)
      Reason = $Reason
    }
  }
}

function Add-CandidatesByNameRegex([string]$Regex, [string]$Reason) {
  $items = Get-ChildItem -Path $rootPath -Recurse -Force -ErrorAction SilentlyContinue -File `
    | Where-Object { $_.Name -match $Regex }
  foreach ($it in $items) {
    $script:candidates += [pscustomobject]@{
      Path   = $it.FullName
      SizeKB = [math]::Round($it.Length / 1KB, 1)
      Reason = $Reason
    }
  }
}

# 1) tmp/** (experiments/logs)
Add-CandidatesByGlob 'tmp\*' 'tmp/* thường là log/experiment. Nên merge nội dung cần thiết vào docs rồi xóa.'

# 2) Temporary reports / debug logs by naming
Add-CandidatesByNameRegex '(?i)debug' "Tên file chứa 'debug' thường là log tạm."
Add-CandidatesByNameRegex '(?i)report_tmp|tmp_report' "Report tạm (report_tmp) nên merge/replace bằng report chính."
Add-CandidatesByNameRegex '(?i)err(ors?)?\.txt$|_err\.txt$' "Log lỗi tạm (err.txt) thường không cần commit lâu dài."

# 3) AI / prompt clutter (optional - be careful, only list)
Add-CandidatesByNameRegex '(?i)prompt|roadmap|plan' "Có thể là file prompt/plan (review: giữ nếu còn dùng, merge nếu trùng)."

# 4) Common binary artifacts (optional)
if ($IncludeBinaries) {
  Add-CandidatesByNameRegex '(?i)\.exe$|\.msi$|\.vsix$|\.zip$' "Binary artifact/installer (thường không nên nằm trong repo)."
}

# Deduplicate by Path
$candidates = $candidates | Sort-Object Path -Unique

Write-Section ('Found {0} candidates' -f $candidates.Count)

if ($candidates.Count -eq 0) {
  Write-Host 'No candidates found for the current patterns.'
} else {
  $candidates | Sort-Object SizeKB -Descending | Select-Object -First 200 `
    | Format-Table SizeKB, Reason, Path -AutoSize

  Write-Host ''
  Write-Host 'Tip: Review before deleting. This script never deletes.'
}

if ($OutReport -ne '') {
  Write-Section 'Writing report'
  $outPath = Join-Path $rootPath $OutReport
  $lines = @()
  $lines += '# Cleanup Candidates (LIST ONLY)'
  $lines += ''
  $lines += ('- Generated: {0}' -f (Get-Date -Format s))
  $lines += ('- Root: {0}' -f $rootPath)
  $lines += ('- Total: {0}' -f $candidates.Count)
  $lines += ''
  $lines += '| Size (KB) | Reason | Path |'
  $lines += '|---:|---|---|'
  foreach ($c in ($candidates | Sort-Object SizeKB -Descending)) {
    $safePath = $c.Path.Replace('|', '\|')
    $safeReason = $c.Reason.Replace('|', '\|')
    $lines += ('| {0} | {1} | {2} |' -f $c.SizeKB, $safeReason, $safePath)
  }
  $lines | Out-File -FilePath $outPath -Encoding utf8
  Write-Host ('Report written to: {0}' -f $outPath)
}

Write-Section 'DONE'
