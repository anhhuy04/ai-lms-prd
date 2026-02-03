@echo off
REM LIST ONLY - does NOT delete anything.
REM Usage:
REM   tools\list_cleanup_candidates.cmd
REM   tools\list_cleanup_candidates.cmd report docs\reports\cleanup_candidates.md
REM   tools\list_cleanup_candidates.cmd binaries
REM   tools\list_cleanup_candidates.cmd binaries report docs\reports\cleanup_candidates.md

setlocal enabledelayedexpansion

set "INCLUDE_BINARIES="
set "OUT_REPORT="

if /I "%~1"=="binaries" (
  set "INCLUDE_BINARIES=-IncludeBinaries"
  shift
)

if /I "%~1"=="report" (
  set "OUT_REPORT=-OutReport %~2"
)

powershell -ExecutionPolicy Bypass -File tools\list_cleanup_candidates.ps1 -Root . %INCLUDE_BINARIES% %OUT_REPORT%
endlocal
