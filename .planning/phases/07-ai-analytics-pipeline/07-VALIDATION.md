---
phase: 7
slug: ai-analytics-pipeline
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-08
---

# Phase 7 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter test + Supabase SQL verification |
| **Config file** | `pubspec.yaml` (flutter test) |
| **Quick run command** | `flutter analyze` |
| **Full suite command** | `flutter test && flutter analyze` |
| **Estimated runtime** | ~30 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter analyze`
- **After every plan wave:** Run `flutter test && flutter analyze`
- **Before `/gsd:verify-work`:** Full suite must be green
- **Max feedback latency:** 30 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 7-01-01 | skill-mastery-pipeline | 1 | 7-01 | SQL trigger | `supabase db reset --local` | ❌ W0 | ⬜ pending |
| 7-02-01 | question-stats-pipeline | 1 | 7-02 | SQL trigger | `supabase db reset --local` | ❌ W0 | ⬜ pending |
| 7-03-01 | submission-analytics | 2 | 7-03 | SQL/Dart | `flutter analyze` | ❌ W0 | ⬜ pending |
| 7-04-01 | grade-override-verify | 2 | 7-04 | Manual | Manual E2E | N/A | ⬜ pending |
| 7-05-01 | ai-queue-edge-fn | 2 | 7-05 | Supabase CLI | `supabase functions serve` | ❌ W0 | ⬜ pending |
| 7-06-01 | phase4-uat | 3 | 7-06 | Manual UAT | Manual | N/A | ⬜ pending |
| 7-07-01 | ai-recommendations | 3 | 7-07 | SQL/Dart | `flutter analyze` | ❌ W0 | ⬜ pending |
| 7-08-01 | ai-feedback-mcq | 3 | 7-08 | SQL/Dart | `flutter analyze` | ❌ W0 | ⬜ pending |
| 7-09-01 | phase5-closure | 3 | 7-09 | Manual UAT | Manual | N/A | ⬜ pending |
| 7-10-01 | phase2-closure | 3 | 7-10 | Manual UAT | Manual | N/A | ⬜ pending |
| 7-11-01 | ai-grading-toggle | 4 | 7-11 | Dart | `flutter analyze` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] SQL migration files for triggers (skill_mastery, question_stats)
- [ ] SQL migration for submission_analytics inserts
- [ ] Edge Function scaffold in `supabase/functions/process-ai-queue/`
- [ ] SQL migration for ai_recommendations
- [ ] SQL migration for ai_queue feedback rows

*Note: Flutter project uses `flutter analyze` as primary automated check. SQL migrations verified via Supabase MCP.*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Student submit MCQ → skill_mastery updated | 7-01 | Requires live Supabase + real submission | Login as student, submit MCQ assignment, check student_skill_mastery table |
| Phase 4 analytics screen shows real data | 7-06 | UI validation | Open analytics tab, verify charts non-empty |
| Teacher override score → grade_overrides record | 7-04 | E2E UI + DB | Submit override, check grade_overrides via Supabase |
| ai_queue Edge Function deploys | 7-05 | Requires Supabase CLI deploy | `supabase functions deploy process-ai-queue` |
| Phase 2 UAT closure | 7-10 | UI regression | Re-run Phase 2 UAT scripts |
| Phase 5 UAT + VERIFICATION closure | 7-09 | UI regression + bug fixes | Re-run Phase 5 UAT, verify 3 specific bugs fixed |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
