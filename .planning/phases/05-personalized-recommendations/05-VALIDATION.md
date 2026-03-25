---
phase: 5
slug: personalized-recommendations
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-25
---

# Phase 5 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (SDK) + mocktail |
| **Config file** | none — Wave 0 sets up test directory |
| **Quick run command** | `flutter test` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30-60 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter test`
- **After every plan wave:** Run `flutter test`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** ~60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 5-01-01 | 01 | 1 | REC-01, REC-02, REC-03 | unit | `flutter test` | ✅ W0 | ⬜ pending |
| 5-01-02 | 01 | 1 | REC-01, REC-02, REC-03 | unit | `flutter test` | ✅ W0 | ⬜ pending |
| 5-02-01 | 02 | 2 | REC-01 | unit | `flutter test` | ✅ W0 | ⬜ pending |
| 5-02-02 | 02 | 2 | REC-02 | unit | `flutter test` | ✅ W0 | ⬜ pending |
| 5-02-03 | 02 | 2 | REC-03 | unit | `flutter test` | ✅ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/data/datasources/recommendation_datasource_test.dart` — stubs for recommendation datasource tests
- [ ] `test/presentation/providers/recommendation_providers_test.dart` — stubs for recommendation provider tests
- [ ] `test/domain/entities/recommendation_test.dart` — stubs for recommendation entity tests

*If none: "Existing infrastructure covers all phase requirements."*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| DB Trigger fires correctly | REC-01, REC-02 | Requires actual Supabase DB + submission event | Manually submit assignment, verify recommendation inserted |
| pg_cron runs at 2AM | REC-01, REC-02 | Time-based cron job | Check Supabase logs next morning |
| RLS policy enforcement | REC-03 | Requires multiple student accounts | Test student A cannot see student B's recommendations |
| UI rendering correctness | REC-01, REC-02, REC-03 | Visual verification | UAT on device/emulator |

*If none: "All phase behaviors have automated verification."*

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
