# Plan Workflow Plugin

> AI-powered Tech Vision & Screen Planning for Flutter Projects

---

## Overview

Plugin cung cấp 2 workflows chính:

1. **`/ag/plan`** - Tech Vision: Biến ý tưởng thành tech stack
2. **`/ag/setupplan`** - Screen Planning: Tạo đặc tả chi tiết với Design Sync

---

## Features

### Tech Vision (`/ag/plan`)
- Phân tích ý tưởng thành tech requirements
- Kiểm tra compatibility với existing stack
- Phát hiện xung đột (tech, architecture, data flow)
- Auto-update memory-bank

### Screen Planning (`/ag/setupplan`)
- Đọc toàn bộ 6 memory-bank files
- Database Deep Analysis (tables, RLS, relationships)
- Logic Deep Dive (validation, state machine, errors)
- **Design System Sync** - Đồng bộ màu/size/bố cục
- **UI Template Transformer** - Biến mẫu giao diện thành Flutter
- Cross-Reference & Pattern recognition
- Generate đặc tả chi tiết

---

## Commands

| Command | Mô tả |
|---------|--------|
| `/ag/plan [idea]` | Tạo tech vision từ ý tưởng |
| `/ag/setupplan` | Tạo/mở rộng đặc tả màn hình |
| `/ag/tech-vision` | Alias cho /ag/plan |
| `/ag/screen-plan` | Alias cho /ag/setupplan |

---

## Usage

### Tech Vision
```
/ag/plan Tôi muốn thêm tính năng chat realtime
```

→ AI sẽ:
1. Load memory-bank
2. Phân tích requirements
3. Đề xuất tech stack
4. Kiểm tra conflicts
5. Tạo vision document
6. Update memory-bank

### Screen Planning
```
/ag/setupplan
```

→ AI sẽ:
1. Load 6 memory-bank files + DB schema
2. Analyze database
3. Analyze logic
4. Sync Design System
5. Transform UI templates (nếu có)
6. Generate screen specification
7. Save to memory-bank/plan/

---

## Output Locations

| Type | Location |
|------|----------|
| Tech Vision | `memory-bank/tech-vision/[feature]-vision.md` |
| Screen Spec | `memory-bank/plan/[screen_name].md` |
| Generated Widgets | `lib/widgets/generated/` |

---

## Dependencies

- **memory-bank**: Project context files
- **supabase-mcp**: Database schema analysis
- **context7**: Library documentation
- **fetch**: URL content extraction

---

## Structure

```
plan-workflow/
├── config/
│   └── plugin.json          # Plugin configuration
├── workflows/
│   ├── tech_vision.md      # /ag/plan workflow
│   └── setup_plan.md       # /ag/setupplan workflow
├── templates/
│   ├── screen_spec.md      # Screen specification template
│   └── tech_vision.md      # Tech vision template
├── skills/
│   └── (future extensions)
└── README.md
```

---

## Version

- **1.0.0** - Initial release
