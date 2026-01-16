Param(
  [switch]$Apply,
  [switch]$Verbose
)

$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $repoRoot

Set-Location $repoRoot

$exemptPaths = @(
  'README.md',
  'docs/',
  'memory-bank/',
  'lib/',
  'ios/',
  'android/',
  'supabase-mcp-server/',
  'fetch-mcp-server/'
)

function Is-Exempt([string]$relPath) {
  $p = $relPath.Replace('\\','/').TrimStart('./')
  foreach ($ex in $exemptPaths) {
    if ($ex.EndsWith('/')) {
      if ($p.StartsWith($ex)) { return $true }
    } else {
      if ($p -eq $ex) { return $true }
    }
  }
  return $false
}

$mdFiles = Get-ChildItem -Recurse -File -Filter *.md | ForEach-Object {
  $rel = Resolve-Path -Relative $_.FullName
  $rel.TrimStart('.\\')
}

$offenders = @()
foreach ($f in $mdFiles) {
  if (-not (Is-Exempt $f)) {
    $offenders += $f
  }
}

if ($offenders.Count -eq 0) {
  Write-Host 'OK: No stray .md files found outside docs/ (and exempted areas).'
  exit 0
}

Write-Host "Found $($offenders.Count) stray .md files:"
$offenders | ForEach-Object { Write-Host " - $_" }

if (-not $Apply) {
  Write-Host ''
  Write-Host 'Dry-run only. Re-run with -Apply to move root-level docs into docs/notes/ (safe subset).'
  exit 0
}

# Only auto-move a safe subset: root-level *.md excluding README.md
$rootMd = $offenders | Where-Object { $_ -match '^[^/]+\.md$' -and $_ -ne 'README.md' }

if ($rootMd.Count -eq 0) {
  Write-Host 'No root-level .md files eligible for auto-move. Please move manually based on the list above.'
  exit 0
}

New-Item -ItemType Directory -Force -Path 'docs/notes' | Out-Null

foreach ($f in $rootMd) {
  $dest = Join-Path 'docs/notes' (Split-Path -Leaf $f)
  if (Test-Path $dest) {
    Write-Host "SKIP (exists): $dest"
    continue
  }
  Write-Host "MOVE: $f -> $dest"
  Move-Item $f $dest
}

Write-Host 'Done.'
