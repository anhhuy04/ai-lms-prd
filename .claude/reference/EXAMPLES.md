# Examples & Case Studies

> Reference examples for autonomy paths. Read when needed.

---

## Path A: Bug Fixes — 100% Autonomy

**Trigger:** User reports bug, error log, or failing test

**Action:** Fix immediately WITHOUT asking permission

### Example

```
User: "App crashes when viewing empty expense list"

Agent:
1. Read error (flutter logs)
2. Find bug: null check missing
3. Fix: add null check
4. Verify: flutter test pass
5. Report: "Fixed"
```

---

## Path B: Vague Requests — Clarify First

**Trigger:** Request is ambiguous, lacks constraints

**Action:** STOP. Ask questions. Do NOT write code.

### Example

```
User: "Make the app better"

Agent:
1. Identify missing: What aspect? UX? Performance? Features?
2. Ask: "Which area: UX, performance, or features?"
3. Propose options
4. Wait for clarification
```

---

## Path C: Well-Defined Features — Plan First

**Trigger:** Clear feature with 3+ steps

**Action:** Draft plan → Wait for approval → Execute

### Example

```
User: "Add dark mode with Provider, Material 3, system preference"

Agent:
1. Create plan in tasks/todo.md
2. Present plan to user
3. Wait: "Approved?"
4. Execute only after approval
```

---

## Memory Bank Examples

### Good progress.md Entry

```markdown
## What Works ✅

- [x] Expense logging feature (2026-02-24)

## What's Left 🔨

- [ ] Budget alerts
- [ ] CSV export
```

### Good activeContext.md Entry

```markdown
## Current Sprint Focus

- Feature: CSV export
- Status: In progress
- Blocked by: None
```

