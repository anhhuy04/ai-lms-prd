```
---
name: "Setup Plan Workflow"
version: "1.0.0"
description: "Phân tích memory-bank + DB + Design Sync + UI Template Transformer"
trigger: "/ag/setupplan"
alwaysApply: true
---

# /ag/setupplan — Screen Planning + Design Sync

---

## STAGE 1: Load All Memory-Bank + DB

### Đọc 6 Memory-Bank Files:
```
memory-bank/projectbrief.md
memory-bank/productContext.md
memory-bank/activeContext.md
memory-bank/systemPatterns.md
memory-bank/techContext.md
memory-bank/progress.md
```

### Load Database Schema (Supabase MCP):
```sql
SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
```

---

## STAGE 2: Database Deep Analysis

```markdown
## Database Analysis: [Screen]

### Tables Used
| Table | CRUD | Foreign Keys |
|-------|------|-------------|
| [table] | C/R/U/D | [refs] |

### RLS Policies
| Table | Policy | Condition |
|-------|--------|-----------|
| [table] | [policy] | [condition] |
```

---

## STAGE 3: Logic Deep Dive

```markdown
## Logic: [Screen]

### Actions
| Action | Logic | Validation | Error |
|--------|-------|------------|-------|
| [action] | [logic] | [rules] | [handling] |

### State Machine
[Loading] → [Loaded] → [Action] → [Loaded/Error]
```

---

## STAGE 4: Design System Sync

### 4.1 Scan UI Files
```bash
grep -r "Color(" lib/ --include="*.dart"
grep -r "fontSize:" lib/ --include="*.dart"
```

### 4.2 Report Inconsistencies
```markdown
## Design System Sync

### Colors
| Current | Should Use |
|---------|------------|
| Color(0xFF...) | DesignColors.primary |

### Typography
| Current | Should Use |
|---------|------------|
| fontSize: 20 | DesignTypography.titleLarge |
```

### 4.3 Fix Suggestions
```dart
// BEFORE
Container(color: Color(0xFF123456))

// AFTER
Container(color: DesignColors.primary)
```

---

## STAGE 5: UI Template Transformer

### 5.1 Input Types
- URL (Figma, Web, Dribbble)
- HTML/CSS Code
- Screenshot

### 5.2 Analyze Template
```markdown
## Template Analysis

### Layout (Giữ nguyên)
- Container → Column/Row
- Card → Card
- List → ListView

### Elements Map
| Element | Template | Design System |
|---------|----------|---------------|
| Primary | #3B82F6 | DesignColors.primary |
| Text | 16px | DesignTypography.bodyMedium |
```

### 5.3 Transform to Flutter
```dart
// INPUT: HTML <div class="card">
// OUTPUT: Flutter with Design System

Card(
  elevation: DesignElevation.level1,
  shape: RoundedRectangleBorder(
    borderRadius: DesignRadius.md,
  ),
  child: Padding(
    padding: DesignSpacing.md,
    child: Column(...),
  ),
)
```

### Transformation Rules
| Template | → | Design System |
|----------|---|---------------|
| Primary Color | → | DesignColors.primary |
| H1 | → | DesignTypography.headlineLarge |
| md spacing | → | DesignSpacing.md |
| rounded-lg | → | DesignRadius.md |
| button | → | FilledButton |
| card | → | Card |

---

## STAGE 6: Cross-Reference & Pattern

```markdown
## Cross-References

### Related Screens
| Screen | Relationship |
|--------|--------------|
| [screen] | [parent/child] |

### Shared Components
- [Component]: Used by [screens]
```

---

## STAGE 7: Generate Screen Specification

Lưu vào `memory-bank/plan/[screen_name].md`:

```markdown
# [Screen Name]

## 1. Context
- Mục tiêu: [description]
- Users: [teacher/student/admin]

## 2. Flows
### Entry/Exit
- [From] → [Action] → [To]

### Actions
| Action | Logic | Next |
|--------|-------|------|
| [action] | [logic] | [screen] |

## 3. Database
| Table | CRUD | RLS |
|-------|------|-----|
| [table] | C/R/U/D | [policies] |

## 4. State
```dart
// Provider code
```

## 5. UI/UX
### Layout
[Structure giữ nguyên từ template]

### Design
- Colors: DesignColors.*
- Typography: DesignTypography.*
- Spacing: DesignSpacing.*

### Generated Widgets
| Widget | File |
|--------|------|
| [Widget] | lib/widgets/generated/ |

## 6. Edge Cases
| Case | Handling |
|------|----------|
| [error] | [solution] |

## 7. Design Fixes
- [ ] [File]: [change]
```

---

## OUTPUT

```markdown
# 🎉 Screen Planning Complete

## Summary
- Screens: [X] analyzed
- DB Tables: [N]
- Design Fixes: [N]
- Widgets Generated: [N]

## Files Created
- memory-bank/plan/[screen].md
- lib/widgets/generated/
```
