---
name: memory-bank
description: Load relevant memory-bank files based on current task. Use at session start to get project context efficiently without reading all files.
---

# Memory Bank Skill

At session start, load only relevant files:

## Decision Tree

```
What are you doing?
├─ New feature?
│  └─ → projectbrief + productContext + progress
├─ Bug fix?
│  └─ → progress + systemPatterns
├─ Refactor?
│  └─ → systemPatterns + progress
└─ Unknown?
   └─ → activeContext + progress (quick overview)
```

## Quick Reference

| Task | Files to Read |
|------|---------------|
| New Feature | projectbrief.md, productContext.md, progress.md |
| Bug Fix | progress.md, systemPatterns.md |
| Technical Work | techContext.md, systemPatterns.md |
| Any Session | activeContext.md, progress.md (always) |

## File Purposes

- `projectbrief.md` - Goals & scope
- `productContext.md` - User needs & UX
- `systemPatterns.md` - Architecture decisions
- `techContext.md` - Tech stack
- `activeContext.md` - Current focus (always read)
- `progress.md` - Status (always read)

## Don't Read Everything

- ❌ NOT: Read all 6 files
- ✅ DO: Read 2-3 relevant files

This saves ~2,000 tokens per session.
