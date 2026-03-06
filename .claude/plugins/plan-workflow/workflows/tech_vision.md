```
---
name: "Tech Vision Workflow"
version: "1.0.0"
description: "Biến ý tưởng thành tech stack, phát hiện xung đột hệ thống"
trigger: "/ag/plan"
alwaysApply: true
---

# /ag/plan — Tech Vision Workflow

> **Role:** Tech Architect - Biến ý tưởng thành công nghệ, đánh giá compatibility

---

## STAGE 1: Load Memory Bank

Đọc các files:
- `memory-bank/techContext.md` → Tech stack
- `memory-bank/systemPatterns.md` → Patterns
- `memory-bank/progress.md` → Status
- `memory-bank/activeContext.md` → Focus

---

## STAGE 2: Interactive Idea Refinement

### User cung cấp ý tưởng:
- Tính năng mới
- Vấn đề kỹ thuật
- Yêu cầu cải tiến

### AI Analysis (TỰ ĐỘNG):

```markdown
## 💡 Idea: [User's Idea]

### Tech Requirements
- Packages: [list]
- Alternatives: [options với pros/cons]

### Compatibility
- ✅ Compatible: [existing tech]
- ⚠️ Conflicts: [potential issues]

### Missing from Memory-Bank
- [ ] [Tech/pattern] → cần thêm
```

### Ask User Decision:
```markdown
## 🤝 Decision Needed
1. Option A: [tech] - [reason]
2. Option B: [tech] - [reason]
→ **CHỜ USER TRẢ LỜI**
```

---

## STAGE 3: Conflict Detection

### Tech Conflicts
| Tech A | Tech B | Solution |
|--------|--------|----------|
| [Riverpod] | [GetX] | Stick with Riverpod |

### Architecture Conflicts
- [Pattern] vs [Pattern]: [issue] → [resolution]

### Future Compatibility
- [Feature A] + [Feature B]: [compatible/not]

---

## STAGE 4: Generate Tech Vision

Lưu vào `memory-bank/tech-vision/[feature]-vision.md`:

```markdown
# Tech Vision: [Feature]
Date: [YYYY-MM-DD]
Status: [Draft/Approved]

## Goal
[What user wants]

## Tech Stack
| Component | Choice | Reason |
|-----------|--------|--------|
| Frontend | Flutter | [reason] |
| State | Riverpod | [reason] |
| Backend | Supabase | [reason] |

## Conflicts Resolved
- [Conflict] → [Solution]

## Dependencies
- packages: [list]
- tables: [list]

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| [Risk] | [Solution] |
```

---

## STAGE 5: Auto-Update Memory-Bank

- `techContext.md`: Add new tech
- `systemPatterns.md`: Add new patterns
- `progress.md`: Add vision status
- `activeContext.md`: Update focus

---

## OUTPUT

```markdown
# 🎯 TECH VISION COMPLETE

## Input
- Idea: [User's idea]

## Tech Stack
| Component | Choice |
|-----------|--------|
| [Component] | [Choice] |

## Conflicts Resolved
- [Conflict] → [Solution]

## Memory-Bank Updates
- techContext.md
- systemPatterns.md
- tech-vision/[name].md
```

---

## CHECKLIST

- [ ] Load memory-bank files
- [ ] Analyze tech requirements
- [ ] Check compatibility
- [ ] Detect conflicts
- [ ] Ask user decisions
- [ ] Generate vision doc
- [ ] Update memory-bank
