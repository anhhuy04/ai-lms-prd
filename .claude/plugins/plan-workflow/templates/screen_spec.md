# Screen Specification Template

> Template cho màn hình trong memory-bank/plan/

---

```markdown
# [Screen Name]

## 1. Context & Mục tiêu

| Field | Value |
|-------|-------|
| **Mục tiêu** | [Mô tả ngắn gọn] |
| **Users** | [teacher/student/admin] |
| **Nguồn** | [Feature/User flow] |
| **Dependencies** | [Related screens] |

## 2. Luồng Flow (User Flow)

### 2.1 Entry Points
| From Screen | Action | Screen |
|-------------|--------|--------|
| [Screen A] | Click [action] | [This Screen] |
| [Screen B] | [action] | [This Screen] |

### 2.2 Exit Points
| Action | To Screen |
|--------|-----------|
| [action] | [Screen X] |
| [action] | [Screen Y] |

### 2.3 User Actions
| Action | Business Logic | Validation | Next Screen |
|--------|----------------|------------|-------------|
| [action_1] | [logic] | [rules] | [screen] |
| [action_2] | [logic] | [rules] | [screen] |

### 2.4 Error Flows
| Error | Condition | Handling | Message |
|-------|-----------|----------|---------|
| [error_1] | [when] | [handling] | [msg] |
| [error_2] | [when] | [handling] | [msg] |

## 3. Database & Data Layer

### 3.1 Tables Used
| Table | Operations | Foreign Keys |
|-------|-----------|--------------|
| [table_1] | C/R/U/D | [refs] |
| [table_2] | R | [refs] |

### 3.2 Queries
```sql
-- Primary query
SELECT * FROM [table] WHERE [conditions];

-- Secondary queries
SELECT * FROM [related_table];
```

### 3.3 RLS Policies
| Table | Policy Name | Condition |
|-------|-------------|-----------|
| [table] | [policy] | [condition] |

## 4. State Management

### 4.1 Providers Required
```dart
@riverpod
class [Screen]Notifier extends _$Screen]Notifier {
  @override
  FutureOr<[State]> build() async {
    // Fetch initial data
  }

  Future<void> [action1]() async {
    // Business logic
  }
}
```

### 4.2 State Transitions
```
[Initial] --load--> [Loading] --success--> [Loaded]
[Loaded] --action--> [ActionLoading] --success--> [Loaded]
[Loaded] --error--> [Error] --retry--> [Loading]
```

## 5. UI/UX Design

### 5.1 Layout Structure
```
┌─────────────────────────────────┐
│ AppBar: [Title] + [Actions]    │
├─────────────────────────────────┤
│ Content                         │
│ ┌─────────────────────────────┐ │
│ │ Section 1: [Header/Stats]   │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ Section 2: [List/Grid]     │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ Section 3: [Details]       │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│ Bottom Actions                  │
└─────────────────────────────────┘
```

### 5.2 Components
| Component | Location | States | Design Token |
|-----------|----------|--------|--------------|
| [Component] | [section] | [states] | DesignColors/Typography |

### 5.3 Visual Design
| Element | Value | Source |
|---------|-------|--------|
| Primary Color | DesignColors.primary | Design System |
| Background | DesignColors.surface | Design System |
| Typography | DesignTypography.bodyMedium | Design System |
| Spacing | DesignSpacing.md | Design System |
| Border Radius | DesignRadius.md | Design System |

### 5.4 Responsive
| Device | Layout |
|--------|--------|
| Mobile | Single column |
| Tablet | Two columns |
| Desktop | Full width |

### 5.5 Loading States
| State | UI |
|-------|-----|
| Initial Load | ShimmerListTileLoading |
| Action Loading | CircularProgressIndicator |
| Empty | [EmptyStateWidget] |
| Error | [ErrorWidget with retry] |

## 6. Dependencies

### 6.1 Packages
```yaml
dependencies:
  - [package]: ^version  # [reason]
```

### 6.2 Backend
| Type | Name | Description |
|------|------|-------------|
| Table | [table] | [purpose] |
| RLS | [policy] | [condition] |
| Edge Function | [name] | [purpose] |

### 6.3 Assets
| Type | Name | Usage |
|------|------|-------|
| Icon | [name] | [usage] |
| Image | [name] | [usage] |

## 7. Edge Cases

### 7.1 Data Edge Cases
| Case | Handling |
|------|----------|
| Empty data | Show empty state UI |
| Partial data | Show available data |
| Large dataset | Pagination / lazy load |

### 7.2 Network Edge Cases
| Case | Handling |
|------|----------|
| Offline | Show offline indicator, queue actions |
| Slow connection | Show shimmer/skeleton |
| API error | Show error with retry button |

### 7.3 Permission Edge Cases
| Case | Handling |
|------|----------|
| Unauthorized | Redirect to login |
| Forbidden | Show access denied |

### 7.4 Concurrent Operations
| Operation | Guard | Rollback |
|-----------|-------|----------|
| [op_1] | [_isUpdating] | Yes |

## 8. Cross-References

### 8.1 Related Screens
| Screen | Relationship | Data Flow |
|--------|--------------|-----------|
| [screen_A] | Parent | Via provider |
| [screen_B] | Child | Via route params |

### 8.2 Shared Components
| Component | Used By | Location |
|-----------|---------|----------|
| [Component] | [screens] | lib/widgets/ |

## 9. Design System Fixes Applied

### 9.1 Colors
| File | Before | After |
|------|--------|-------|
| [file] | Color(0xFF...) | DesignColors.primary |

### 9.2 Typography
| File | Before | After |
|------|--------|-------|
| [file] | fontSize: 20 | DesignTypography.titleLarge |

## 10. Generated Widgets

| Widget | File | Source |
|--------|------|--------|
| [Widget] | lib/widgets/generated/[name].dart | Template |

---

## Metadata

| Field | Value |
|-------|-------|
| Created | [YYYY-MM-DD] |
| Updated | [YYYY-MM-DD] |
| Status | [Draft/In Review/Approved] |
| Author | [AI/User] |
| Version | 1.0.0 |
```
