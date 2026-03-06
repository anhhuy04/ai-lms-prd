# Cleanup Skill — Example Output

> Example showing what agent should produce after cleanup.

---

## Cleanup Operation Report

**Date:** 2026-02-24

**Flag Used:** `--yes`

---

## Files Deleted

| File Pattern | Count | Examples |
|--------------|-------|----------|
| `test_*.md` | 2 | test_analysis.md, test_summary.md |
| `*_report.md` | 1 | weekly_progress_report.md |
| `*_draft.md` | 0 | — |
| `debug_*.log` | 3 | debug_session.log, debug_error.log, debug_build.log |
| `*.tmp` | 1 | cache_temp.tmp |
| `experiment_*.dart` | 0 | — |

**Total Deleted:** 7 files

---

## Files Kept

| File/Folder | Reason |
|-------------|--------|
| `memory-bank/*.md` | Project knowledge (persistent) |
| `.claude/*.md` | Rules & skills |
| `lib/**` | Source code |
| `test/**` | Test files |
| `README.md` | Documentation |

---

## Verification Result

```
$ ls -la *.md
-rw-r--r--  1 AnhHuy 197121 1234 Feb 24 14:00 README.md
```

**Status:** ✅ Complete — All temp files removed, only README.md remains

---

## Notes

- Used `--yes` flag: executed directly without confirmation
- No errors encountered during deletion
- Verified no .md files other than README.md remain in root
