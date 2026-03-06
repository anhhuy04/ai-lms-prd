---
name: cleanup
description: Clean up temporary files after task completion. Use after verifying task succeeds (flutter analyze, flutter test pass). Deletes temp artifacts but keeps documentation.
argument-hint: "[--yes]"
---

# Cleanup Skill

After completing a task and verification succeeds, clean up temporary files:

## Autonomous Execution

- **With `--yes` flag**: Execute cleanup directly without asking
  - Delete agreed-upon temp files immediately
  - No confirmation needed

- **For /tests or /temp folders**: Decide autonomously based on task context
  - Create test files if needed for verification
  - Create temp files if needed for debugging
  - No need to ask permission

## Step 1: Find Temp Files

```bash
ls -la *.md 2>/dev/null | grep -v "^README"
```

## Step 2: Classify

**DELETE (temp):**
- `test_*.md`, `*_report.md`, `*_draft.md`
- `debug_*.log`, `*.tmp`
- `experiment_*.dart`, `draft_*.dart`

**KEEP (important):**
- `memory-bank/*.md` - Project knowledge
- `.claude/*.md` - Rules
- `lib/**`, `test/**` - Source code

## Step 3: Delete

```bash
rm test_*.md *_report.md debug_*.log *.tmp experiment_*.dart 2>/dev/null
```

## Step 4: Verify

```bash
ls -la *.md
# Should only show README.md
```

Done!
