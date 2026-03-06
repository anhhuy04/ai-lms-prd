```
---
description: "Setup Plan Workflow - Phân tích toàn bộ memory-bank + Design System Sync + UI Template Transformer"
trigger: "/ag/setupplan"
---

# /ag/setupplan — Execute & Generate Screen Plans

> **Trigger:** Sau khi user đã approve tech vision từ /ag/plan, HOẶC khi cần tạo/mở rộng đặc tả màn hình
> **Purpose:** Đọc toàn bộ memory-bank → Deep Analysis → Design Sync → Generate Screen Plans

---

## CORE CONCEPT

### Input: Memory-Bank + DB + (Optional) UI Templates
```
memory-bank/projectbrief.md     → Mục tiêu, timeline
memory-bank/productContext.md   → Lý do, UX goals
memory-bank/activeContext.md    → Focus hiện tại
memory-bank/systemPatterns.md   → Design Tokens, patterns
memory-bank/techContext.md      → Tech stack
memory-bank/progress.md         → Features status
Supabase Database              → Tables, relationships
(Optional) UI Templates         → Mẫu giao diện từ user
```

### Process: 7-Stage Deep Analysis
1. **Load** — Memory-Bank + DB Schema
2. **Database Analysis** — Tables, RLS, relationships
3. **Logic Analysis** — Business rules, validation, errors
4. **Design System Sync** — Đồng bộ màu/size/bố cục
5. **UI Template Transformer** — Biến mẫu thành Flutter code
6. **Cross-Reference** — Dependencies, patterns
7. **Generate Spec** — Tạo đặc tả chi tiết

---

## STAGE 1: Load All Memory-Bank & Database (BẮT BUỘC)

### 1.1 Đọc 6 Memory-Bank Files:

```
memory-bank/projectbrief.md     → Project goals
memory-bank/productContext.md   → Business context
memory-bank/activeContext.md    → Current focus
memory-bank/systemPatterns.md   → Design Tokens, patterns
memory-bank/techContext.md      → Tech stack
memory-bank/progress.md         → Status
```

### 1.2 Load Database Schema (Supabase MCP):

```sql
SELECT table_name FROM information_schema.tables
WHERE table_schema = 'public';

-- Get relationships
SELECT tc.table_name, kcu.column_name,
       ccu.table_name AS foreign_table_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY';
```

### 1.3 Extract Key Info:

```markdown
## Memory-Bank Summary

### Project
- Goal: [từ projectbrief]
- Tech: Flutter + Riverpod + Supabase

### Design System (From systemPatterns.md)
- Colors: [DesignColors.primary, secondary, surface...]
- Typography: [DesignTypography.headline, body, label...]
- Spacing: [DesignSpacing.xs, sm, md, lg, xl]
- Border Radius: [DesignRadius.sm, md, lg]
- Icons: [DesignIcons sizes]

### Features
- Completed: [list]
- Screens Planned: [list from memory-bank/plan/]
```

---

## STAGE 2: Database Deep Analysis

### 2.1 Tables & Relationships:

```markdown
## Database Analysis: [Screen Name]

### Tables Used
| Table | CRUD | Foreign Keys |
|-------|------|--------------|
| [table] | C/R/U/D | [references] |

### RLS Policies
| Table | Policy | Condition |
|-------|--------|-----------|
| [table] | [policy] | [condition] |

### Query Patterns
- Primary: [query]
- Joins: [tables]
```

---

## STAGE 3: Logic Deep Dive

### 3.1 Business Logic:

```markdown
## Logic: [Screen Name]

### Actions & Validation
| Action | Logic | Validation | Error |
|--------|-------|------------|-------|
| [action] | [business logic] | [rules] | [handling] |

### State Machine
[Loading] → [Loaded] → [Action] → [Loaded/Error]

### Error Handling
- Network: [offline/timeout/401]
- Data: [validation/not found/conflict]
```

---

## STAGE 4: Design System Sync (TỰ ĐỘNG)

### 4.1 Scan Existing UI Files

Quét tất cả UI files để phát hiện inconsistencies:

```bash
# Tìm tất cả UI files
find lib/presentation/views -name "*.dart"

# Extract colors đang dùng
grep -r "Color(" lib/ --include="*.dart" | head -50

# Extract hardcoded sizes
grep -r "fontSize:|height:|width:" lib/ --include="*.dart" | head -30
```

### 4.2 Generate Design Tokens Report

```markdown
## Design System Sync Report

### Colors Used (Current)
| Color | Hex | Usage | Should Use |
|-------|-----|-------|------------|
| #FF0000 | red | [usage] | DesignColors.error |

### Typography Used (Current)
| Style | Size | Usage | Should Use |
|-------|------|-------|------------|
| 20.0 | fontSize | [usage] | DesignTypography.titleLarge |

### Spacing Used (Current)
| Value | Usage | Should Use |
|-------|-------|------------|
| 16.0 | padding | DesignSpacing.md |

### Inconsistencies Found
- [ ] [Issue 1]: [file:line] → [fix]
- [ ] [Issue 2]: [file:line] → [fix]
```

### 4.3 Auto-Fix Suggestions

```markdown
## Recommended Fixes

### Colors
// BEFORE (in [file])
Container(color: Color(0xFF123456))

// AFTER
Container(color: DesignColors.primary)

### Typography
// BEFORE
Text("Title", style: TextStyle(fontSize: 20))

// AFTER
Text("Title", style: DesignTypography.titleLarge)

### Spacing
// BEFORE
Padding(padding: EdgeInsets.all(16))

// AFTER
Padding(padding: DesignSpacing.md)
```

---

## STAGE 5: UI Template Transformer (KEY FEATURE)

### 5.1 Input: User Provides UI Template

User có thể cung cấp:
- URL đến giao diện mẫu (Figma, web, Dribbble...)
- Code mẫu (HTML/CSS, Flutter code khác)
- Screenshot/Hình ảnh

### 5.2 Analyze Template

**Nếu là URL/Webpage:**
- Sử dụng Fetch MCP để lấy HTML
- Sử dụng Puppeteer MCP để capture screenshot
- Extract colors từ webpage
- Extract layout structure

**Nếu là Code:**
```markdown
## Template Analysis

### Layout Structure (Giữ nguyên)
- [Container] → [Column/Row]
- [Card] → [Card]
- [List] → [ListView]

### Elements cần map
| Element | Template Style | Map To |
|---------|---------------|--------|
| Primary Color | #3B82F6 | DesignColors.primary |
| Background | #FFFFFF | DesignColors.surface |
| Text | 16px, #1F2937 | DesignTypography.bodyMedium |
| Button | rounded-lg | DesignRadius.md |
```

### 5.3 Transform to Flutter (Auto)

```dart
// === INPUT: HTML/CSS Template ===
<div class="card">
  <h1>Title</h1>
  <button class="btn-primary">Click</button>
</div>

// === OUTPUT: Flutter with Design System ===

class TemplateCard extends StatelessWidget {
  const TemplateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Giữ nguyên layout structure
      elevation: DesignElevation.level1,
      shape: RoundedRectangleBorder(
        borderRadius: DesignRadius.md,
      ),
      child: Padding(
        padding: DesignSpacing.md,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map: h1 → headlineMedium
            Text(
              'Title',
              style: DesignTypography.headlineMedium,
            ),
            const SizedBox(height: DesignSpacing.sm),
            // Map: btn-primary → FilledButton
            FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: DesignColors.primary, // Map: #3B82F6
                foregroundColor: DesignColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: DesignRadius.md,
                ),
              ),
              child: const Text('Click'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 5.4 Transformation Rules

```markdown
## Transformation Mapping

### Colors
| Template | → | Design System |
|----------|---|----------------|
| Primary brand | → | DesignColors.primary |
| Secondary | → | DesignColors.secondary |
| Background | → | DesignColors.surface |
| Text primary | → | DesignColors.textPrimary |
| Error | → | DesignColors.error |
| Success | → | DesignColors.success |
| Warning | → | DesignColors.warning |

### Typography
| Template | → | Design System |
|----------|---|----------------|
| H1 | → | DesignTypography.headlineLarge |
| H2 | → | DesignTypography.headlineMedium |
| Body | → | DesignTypography.bodyMedium |
| Caption | → | DesignTypography.labelSmall |

### Spacing
| Template | → | Design System |
|----------|---|----------------|
| xs | → | DesignSpacing.xs |
| sm | → | DesignSpacing.sm |
| md | → | DesignSpacing.md |
| lg | → | DesignSpacing.lg |
| xl | → | DesignSpacing.xl |

### Border Radius
| Template | → | Design System |
|----------|---|----------------|
| sm | → | DesignRadius.sm |
| md | → | DesignRadius.md |
| lg | → | DesignRadius.lg |
| full | → | DesignRadius.full |

### Components
| Template | → | Flutter |
|----------|---|---------|
| button.btn-primary | → | FilledButton |
| button.btn-outline | → | OutlinedButton |
| card | → | Card |
| input | → | TextField |
| badge | → | Chip |
| avatar | → | CircleAvatar |
| list | → | ListView |
| grid | → | GridView |
```

---

## STAGE 6: Cross-Reference & Pattern

### 6.1 Feature Dependencies:

```markdown
## Cross-References: [Screen]

### Related Screens
| Screen | Relationship | Data |
|--------|--------------|------|
| [screen] | [parent/child] | [via provider] |

### Shared Components
- [Component]: Used by [screens]

### Circular Dependencies
- [Check]: [result]
```

### 6.2 Pattern Recognition:

```markdown
## Patterns: [Screen]

### Reusable
- [Widget]: Extract to [location]

### Anti-Patterns
- [Issue]: [fix]

### Scalability
- Performance: [assessment]
- Extensibility: [how]
```

---

## STAGE 7: Generate Screen Specification

### 7.1 Complete Specification Template

```markdown
# [Screen Name]

## 1. Context & Mục tiêu
- **Mục tiêu**: [mô tả]
- **Users**: [teacher/student/admin]
- **Dependencies**: [screens]

## 2. Luồng Flow
### 2.1 Entry/Exit Points
- [Từ đâu] → [Action] → [Đến đâu]

### 2.2 Actions
| Action | Logic | Validation | Next |
|--------|-------|------------|------|
| [action] | [logic] | [rules] | [screen] |

## 3. Database & Data
### 3.1 Tables
| Table | CRUD | RLS |
|-------|------|-----|
| [table] | C/R/U/D | [policies] |

### 3.2 Queries
SQL queries here

## 4. State Management
### 4.1 Providers
```dart
// Provider code
```

### 4.2 State
State machine diagram

## 5. UI/UX Design

### 5.1 Layout Structure
Layout structure giữ nguyên từ template

### 5.2 Components (với Design System Sync)
| Component | Design Token | Source |
|-----------|--------------|--------|
| [Component] | [DesignColors/Typography] | [template/original] |

### 5.3 Visual Design
- Colors: DesignColors.*
- Typography: DesignTypography.*
- Spacing: DesignSpacing.*
- Radius: DesignRadius.*

### 5.4 Generated Widgets
| Widget | File | From Template |
|--------|------|---------------|
| [Widget] | [path] | [template URL/code] |

## 6. Dependencies
### 6.1 Packages
packages needed

### 6.2 Backend
- Tables: [list]
- RLS: [list]

## 7. Edge Cases
| Case | Handling |
|------|----------|
| [error] | [solution] |

## 8. Design System Fixes
### 8.1 Applied Fixes
- [ ] [File]: [change]

### 8.2 Generated Widgets
- [Widget]: [path]
```

---

## STAGE 8: Execute & Update (Loop)

### 8.1 Execution Loop

1. Load memory-bank + DB
2. Analyze database
3. Analyze logic
4. Run Design System Sync
5. Transform UI Templates (if any)
6. Cross-reference
7. Generate spec
8. Save to memory-bank/plan/
9. Update memory-bank files

---

## STAGE 9: Progress & Completion

### 9.1 Final Report

```markdown
# 🎉 Screen Planning Complete

## Summary
- Screens: [X] analyzed
- DB Tables: [N] mapped
- Design Fixes: [N] identified
- Widgets Generated: [N] from templates

## Design System Sync
- Inconsistencies: [N] found
- Fixes applied: [N]

## UI Template Transformer
- Templates processed: [N]
- Widgets generated: [N]

## Files
- memory-bank/plan/screen.md
- lib/widgets/generated/

## Next Steps
- Review specs
- Approve to implement
```

---

## QUICK REFERENCE

| Stage | Action |
|-------|--------|
| 1 | Load memory-bank + DB |
| 2 | Database Analysis |
| 3 | Logic Analysis |
| 4 | **Design System Sync** |
| 5 | **UI Template Transformer** |
| 6 | Cross-Reference |
| 7 | Generate Spec |
| 8 | Loop |
| 9 | Report |

---

## UI TEMPLATE TRANSFORMER COMMANDS

| Command | Action |
|---------|--------|
| /transform [URL] | Transform từ URL |
| /transform [code] | Transform từ code snippet |
| /sync-design | Scan & fix Design System |
| /check-consistency | Check UI consistency |
