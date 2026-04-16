---
phase: 3
slug: rubric-system
status: audited
nyquist_compliant: true
wave_0_complete: true
created: 2026-04-06
audited: 2026-04-07
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter test |
| **Config file** | `analysis_options.yaml` |
| **Quick run command** | `flutter analyze` |
| **Full suite command** | `flutter analyze && flutter test` |
| **Estimated runtime** | ~30 seconds (analyze) / ~120 seconds (full) |

---

## Sampling Rate

- **After every task commit:** Run `flutter analyze`
- **After every plan wave:** Run `flutter analyze && flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green (0 analyze errors)
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | Status |
|---------|------|------|-------------|-----------|-------------------|--------|
| 03-01-01 | 01 | 1 | RUB-01 | analyze | `flutter analyze lib/presentation/views/assignment/teacher/widgets/rubric/` | ✅ green |
| 03-01-02 | 01 | 1 | RUB-01 | analyze | `flutter analyze lib/domain/entities/rubric_criterion.dart` | ✅ green |
| 03-01-03 | 01 | 2 | RUB-02 | analyze | `flutter analyze lib/presentation/widgets/rubric/` | ✅ green |
| 03-02-01 | 02 | 1 | RUB-03 | analyze | `flutter analyze lib/presentation/views/assignment/teacher/teacher_create_assignment_screen.dart` | ✅ green |
| 03-02-02 | 02 | 2 | RUB-03 | analyze | `flutter analyze lib/data/datasources/profiles_datasource.dart` | ✅ green |
| 03-03-01 | 03 | 1 | RUB-04 | analyze | `flutter analyze lib/presentation/views/assignment/student/` | ✅ green |
| 03-03-02 | 03 | 2 | RUB-04 | manual | On device: student workspace shows "ℹ️ Xem Tiêu chí" bottom sheet | ⬜ pending |
| 03-04-01 | 04 | 1 | RUB-01,02 | analyze | `flutter analyze lib/presentation/views/assignment/teacher/widgets/submission/` | ✅ green |
| 03-04-02 | 04 | 2 | RUB-02 | manual | On device: click level card → score auto-fills | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- Existing infrastructure covers all phase requirements.
- No new test framework installation needed.
- `flutter analyze` is the primary automated gate.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Click level card → score auto-fills | RUB-02 | Requires UI interaction on device | Open grading screen, tap a level card, verify score field fills correctly |
| "ℹ️ Xem Tiêu chí" opens bottom sheet in workspace | RUB-04 | Requires device interaction | Enter student workspace for essay question, tap button, verify bottom sheet shows criteria |
| Save Draft bypasses rubric validation | D-08 | Requires full flow test | Create essay question with no rubric, tap Save Draft, verify saves without error |
| Publish blocked when essay has no rubric | D-08 | Requires full flow test | Create essay question with no rubric, tap Publish, verify HTTP 400 / error message |
| Rubric locked after work_sessions > 0 | D-09 | Requires DB state setup | Create distribution, simulate student start, re-open rubric builder, verify read-only |
| Template save/load via profiles.metadata | D-05 | Requires DB read/write | Save rubric as template, create new essay question, load template, verify JSONB matches |

---

## Validation Sign-Off

- [x] All tasks have automated `flutter analyze` gate
- [x] Manual-only behaviors documented with test instructions
- [x] Wave 0: no new infrastructure needed
- [x] No watch-mode flags
- [x] Feedback latency < 30s (flutter analyze)
- [x] `nyquist_compliant: true` set in frontmatter when all tasks green

**Approval:** automated tasks green — 2026-04-07

---

## Validation Audit 2026-04-07

| Metric | Count |
|--------|-------|
| Gaps found | 0 |
| Automated tasks checked | 7 |
| All green | 7 |
| Manual-only pending | 2 |
| Escalated | 0 |

> `flutter analyze` toàn project: **No errors**. Tất cả 7 automated tasks xanh. 2 task manual cần kiểm tra trên thiết bị.
