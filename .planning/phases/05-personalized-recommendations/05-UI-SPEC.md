---
phase: 5
slug: personalized-recommendations
status: draft
shadcn_initialized: false
preset: none
created: 2026-03-25
---

# Phase 5 — UI Design Contract

> Visual + interaction contract cho REC-01, REC-02, REC-03. Tài liệu này là chuẩn để implement UI nhất quán với DesignTokens hiện có.

---

## 1) Design System

| Property | Value |
|----------|-------|
| Tool | Flutter |
| Preset | not applicable |
| Component library | Flutter Material + Custom DesignTokens |
| Icon library | Material Icons |
| Font | System default (Roboto Android / SF iOS) |

**Ghi chú:** Đây là Flutter project, **không dùng shadcn/web registry**.

---

## 2) Spacing Scale

| Token | Value | Usage chính |
|------|-------|-------------|
| xs | 4px | Gap rất nhỏ, icon-text inline |
| sm | 8px | Padding chip, khoảng cách compact |
| md | 16px | Spacing mặc định giữa cụm nội dung |
| lg | 24px | Padding section/card chuẩn |
| xl | 32px | Tách nhóm nội dung lớn |
| xxl | 48px | Ngắt trang/major separation |
| xxxl | 64px | Major section breaks lớn |

---

## 3) Typography

| Role | Size | Weight | Line Height |
|------|------|--------|-------------|
| Body | 14px | 400 | 1.5 |
| Label | 12px | 600 | 1.4 |
| Title | 18px | 600 | 1.4 |
| Display | 24px | 600 | 1.25 |

**Rule:** Ưu tiên `DesignTypography.*`, không hardcode `TextStyle(fontSize: ...)`.

---

## 4) Color

| Role | Value | Usage |
|------|-------|-------|
| Background (dominant) | moonLight `#F5F7FA` | Nền dashboard/screen |
| Brand teal | tealPrimary `#0EA5A4` | Radar foreground, emphasis data |
| Accent primary | primary `#4A90E2` | CTA, type badge, active state |
| Success | success `#4CAF50` | Top performer badge |
| Warning | warning `#FFA726` | High priority / caution |
| Error | error `#EF5350` | Critical priority / intervention |
| Divider | dividerLight | Grid, chart lines, separators |

**Color ratio contract (60/30/10):**
- 60%: Background/surface (`moonLight`, neutral whites)
- 30%: Content/supporting visual (`text`, divider, neutral badges)
- 10%: Accent (`primary`, semantic highlights)

**Accent reserved for:**
- Primary CTA
- Active filter chip/tab state
- Route-to-detail CTA
- Key chart emphasis points

**Color ratio contract (60/30/10):**
- 60%: Background/surface (`moonLight`, neutral whites)
- 30%: Content/supporting visual (`text`, divider, neutral badges)
- 10%: Accent (`primary`, semantic highlights)

**Accent reserved for:**
- Primary CTA
- Active filter chip/tab state
- Route-to-detail CTA
- Key chart emphasis points

**Opacity contract:**
- Badge background: 10% (`withValues(alpha: 0.1)`)
- Radar fill student: 25%
- Radar fill class avg: 10%

---

## 5) Copywriting Contract

### Priority labels
- `1` → **Khẩn cấp**
- `2` → **Cao**
- `3` → **Trung bình**
- `4-5` → **Thấp**

### Type labels
- `individual` → **Cá nhân**
- `small_group` → **Nhóm nhỏ**
- `class` → **Cả lớp**

### Resource chip labels
- Exercise → **Ôn tập**
- Video → **Video**
- Document → **Tài liệu**

### Section headers
- **Cần chú ý**
- **Gợi ý khác**
- **So sánh với lớp**
- **So sánh kỹ năng**

### Peer badge copy
- Top performer: **Thứ top X%**
- Others: **Thứ X% của lớp**
- Tooltip: **Trung bình lớp: Y.Y**

### Empty / error copy
- Teacher empty: **Không có gợi ý nào**
- Teacher helper: **Các gợi ý sẽ xuất hiện khi có học sinh cần hỗ trợ thêm.**
- Student empty (pillbox): **Không có gợi ý nào**
- Student helper: **Bạn đang học tốt! Tiếp tục làm bài để cải thiện.**
- Data error: **Không thể tải dữ liệu. Vui lòng thử lại.**

### Date formatting
- Same day: **Hôm nay**
- 1 day ago: **Hôm qua**
- < 7 days: **X ngày trước**
- Else: **DD/MM**

---

## 6) Component Specifications

### 6.1 InterventionBadge (Teacher ATC)

**Mục đích:** Hiển thị số học sinh cần can thiệp ngay (priority <= 2).

**Behavior:**
- `count == 0` → ẩn (`SizedBox.shrink`)
- Tap badge → `goNamed(AppRoute.teacherRecommendationsTab)`

**Visual:**
- Pill shape: `DesignRadius.full`
- Border: `DesignColors.error`
- Background: `error` 10% opacity
- Icon: `warning_amber`
- Text: `"{count} học sinh cần chú ý"`

**Mockup:**
```text
[⚠  5 học sinh cần chú ý ]
```

---

### 6.2 RecommendationCard (Universal)

**Modes:**
1. **Normal** (Teacher screen / full list)
2. **Compact** (Student pillbox top-3)

**Normal layout:**
```text
[Khẩn cấp]  Title of recommendation                 [x]
Description (optional)
[Ôn tập] [Video] [Tài liệu]
[Cá nhân]                                       Hôm nay
```

**Compact layout:**
```text
[Cao]  Title                                   [x]
[Ôn tập] [Video]
```

**Rules:**
- Border color theo priority:
  - 1: error
  - 2: warning
  - 3+: neutral gray
- Urgent (<=2): border width 1.5px
- `resources` rỗng: ẩn chip row
- Dismiss icon chỉ hiện khi có `onDismiss`
- Dismiss action UX: hiển thị Snackbar **"Đã ẩn gợi ý"** + CTA **"Hoàn tác"** trong 5 giây
- Accessibility: dismiss icon phải có `Semantics(label: "Ẩn gợi ý")` + tooltip
- Dismiss action UX: hiển thị Snackbar **"Đã ẩn gợi ý"** + CTA **"Hoàn tác"** trong 5 giây
- Accessibility: dismiss icon phải có `Semantics(label: "Ẩn gợi ý")` + tooltip

**Resource actions:**
- Exercise chip → navigate assignment workspace
- Video/document chip → open external URL (`url_launcher`)

---

### 6.3 PeerComparisonBadge

**Mục đích:** Biểu diễn thứ hạng ẩn danh, không lộ điểm/tên học sinh khác.

**States:**
- `percentile <= 25`: success + `trending_up` + `Thứ top X%`
- Else: warning + `trending_flat` + `Thứ X% của lớp`

**Tooltip:** `Trung bình lớp: {classAverage}`

**Mockup:**
```text
[📈 Thứ top 15%]
```

---

### 6.4 DualRadarChart

**Mục đích:** So sánh skill-by-skill giữa student và class average.

**Data contract:**
- Student: `List<SkillMastery>`
- Class avg: `Map<objectiveId, masteryLevel>`

**Chart contract:**
- `RadarShape.polygon`
- 2 datasets:
  - Student: teal, border solid 2px, fill 25%
  - Class average: gray, border dashed 1px, fill 10%
- Max 8 skills để tránh rối
- Label dài >10 ký tự: truncate
- Empty state: `Chưa có dữ liệu kỹ năng`

**Legend:**
- Teal: **Kỹ năng của bạn**
- Gray dashed: **Trung bình lớp**

---

## 7) Screen Specifications

### 7.1 TeacherRecommendationsScreen

**Focal point:** nhóm **Cần chú ý (N)** là điểm hút mắt đầu tiên.

**Core structure:**
1. AppBar: `Gợi ý học tập` + back
2. Filter row (chip): `Tất cả`, `Khẩn cấp`
3. Grouped list:
   - **Cần chú ý (N)** với accent bar đỏ 4px
   - **Gợi ý khác (N)** với accent bar primary 4px
4. Pull-to-refresh

**States:**
- Loading: 3 shimmer cards
- Empty: check icon + copy empty
- Error: error icon + nút **Thử tải lại gợi ý**

---

### 7.2 StudentRecommendationsTab (Pillbox)

**Focal point:** block **Hạn chế nhất** + recommendation ưu tiên cao nhất.

**Pattern:** “Hộp thuốc đầu giường” — chỉ top 3 urgent recommendations.

**Structure:**
1. AppBar: `Gợi ý học tập`
2. Header block:
   - Title: `Hạn chế nhất`
   - Description ngắn theo ngữ cảnh
3. 3 compact RecommendationCards tối đa

**States:**
- Loading: compact shimmer x3
- Empty: thumbs-up + message tích cực

---

### 7.3 PeerComparisonSection (trong StudentAnalyticsScreen)

**Inline section:**
- Header `So sánh với lớp`
- PeerComparisonBadge
- CTA `Xem chi tiết` (radar icon)
- Inline mini compare card (student vs class avg)

**Bottom sheet details (tap CTA):**
- `DraggableScrollableSheet` initial 0.7
- Handle bar
- Header `So sánh kỹ năng` + badge
- DualRadarChart height 300
- Legend row
- Stats row:
  - Percentile card
  - Class average card

---

## 8) Dashboard Integration

### 8.1 Teacher Home
- Gắn `InterventionBadge` vào vùng ưu tiên dashboard.
- Nguồn dữ liệu: `interventionCountProvider`.
- Ẩn khi `count = 0`.

### 8.2 Student Home
- Gắn `PeerComparisonBadge` vào performance summary.
- ClassId lấy từ class đầu tiên trong analytics context.
- Nguồn dữ liệu: `studentPeerComparisonProvider(classId)`.
- Ẩn khi `totalStudents = 0`.

---

## 9) Navigation / Routes

- Route name: `teacherRecommendationsTab`
- Path: `/teacher/recommendations`
- Route phải nằm trong `teacherRoutes` (RBAC)
- Entry point từ `InterventionBadge` tap

---

## 10) fl_chart Configuration

```dart
RadarChartData(
  radarShape: RadarShape.polygon,
  tickCount: 4,
  titlePositionPercentageOffset: 0.15,
  dataSets: [studentDataSet, classAverageDataSet],
)
```

**Animation:** 400ms

---

## 11) Empty States Matrix

| Condition | Trigger | UI |
|-----------|---------|-----|
| Teacher no recommendations | `recs.isEmpty` | `check_circle_outline` + “Không có gợi ý nào” + helper copy |
| Student no recommendations | `recs.isEmpty` | `thumb_up_outlined` + “Bạn đang học tốt! Tiếp tục làm bài để cải thiện.” |
| Peer comparison no data | `totalStudents == 0` | Hidden (`SizedBox.shrink`) |
| Dual radar no skill data | `skills.isEmpty` | “Chưa có dữ liệu kỹ năng” |

---

## 12) Registry Safety

| Package | Purpose | Safety gate |
|---------|---------|-------------|
| fl_chart | Radar visualization | Not required (standard Flutter package) |
| url_launcher | Open learning resources | Not required (standard Flutter package) |

**shadcn/web registry:** Not used.

---

## 13) Checker Sign-Off

- [x] Dimension 1 Copywriting
- [x] Dimension 2 Visuals
- [x] Dimension 3 Color
- [x] Dimension 4 Typography
- [x] Dimension 5 Spacing
- [x] Dimension 6 Registry Safety

---

## 14) Implementation Guardrails

1. Không fetch raw class scores ở client cho REC-03.
2. Peer comparison chỉ dùng aggregate từ RPC (`class_average`, `percentile`, `rank`, `total_students`).
3. Không hiển thị leaderboard tên thật.
4. `RecommendationCard` giữ đúng 2 mode (normal/compact), không phát sinh mode thứ ba.
5. Ưu tiên `DesignTokens`; không hardcode color/spacing/font.
