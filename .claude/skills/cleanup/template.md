# Cleanup Skill — Template

> Template for cleanup operation results. Agent fills this after cleanup.

---

## Cleanup Operation Report

**Date:** YYYY-MM-DD

**Flag Used:** `--yes` / (none)

---

## Files Deleted

| File Pattern | Count | Examples |
|--------------|-------|----------|
| `test_*.md` | N | test_report.md, test_draft.md |
| `*_report.md` | N | weekly_report.md |
| `*_draft.md` | N | idea_draft.md |
| `debug_*.log` | N | debug_session.log |
| `*.tmp` | N | temp_file.tmp |
| `experiment_*.dart` | N | experiment_test.dart |

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
# Only README.md should remain
```

**Status:** ✅ Complete / ⚠️ Issues Found

---

## Notes

(Any issues encountered or special decisions made)
