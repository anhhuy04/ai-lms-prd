---
phase: 9
slug: ai-settings-refactor-document-import
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-04-19
---

# Phase 9 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Flutter test (built-in) + mocktail |
| **Config file** | none — existing setup |
| **Quick run command** | `flutter analyze && flutter test test/unit/ --no-pub` |
| **Full suite command** | `flutter test && flutter analyze` |
| **Estimated runtime** | ~30-60 seconds |

---

## Sampling Rate

- **After every task commit:** Run `flutter analyze && flutter test test/unit/ --no-pub`
- **After every plan wave:** Run `flutter test && flutter analyze`
- **Before `/gsd:verify-work`:** Full suite must be green + manual device smoke test
- **Max feedback latency:** 60 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| DB migrations | 01 | 1 | 9-02, 9-03 | manual SQL | Supabase MCP verify tables | ❌ W0 | ⬜ pending |
| AiQuestionSettingsScreen | 01 | 1 | 9-01 | widget test | `flutter test test/widget/ai_settings_test.dart` | ❌ W0 | ⬜ pending |
| TeacherFileDataSource | 02 | 1 | 9-02 | unit test | `flutter test test/unit/teacher_file_datasource_test.dart` | ❌ W0 | ⬜ pending |
| File upload pipeline | 02 | 1 | 9-02 | integration | manual Supabase Storage check | manual | ⬜ pending |
| Gear icon route change | 02 | 1 | 9-01 | widget test | `flutter test test/widget/ai_settings_test.dart` | ❌ W0 | ⬜ pending |
| Context Sources UI | 03 | 2 | 9-02 | widget test | `flutter test test/widget/ai_settings_test.dart` | ❌ W0 | ⬜ pending |
| Edge Function vectorize | 04 | 2 | 9-03 | unit test | `supabase/functions/process-document-queue/index.test.ts` | ❌ W0 | ⬜ pending |
| Heuristic Router | 04 | 2 | 9-03 | unit test | Edge Function test | ❌ W0 | ⬜ pending |
| Stateful checkpointing | 04 | 2 | 9-03 | unit test | Edge Function test | ❌ W0 | ⬜ pending |
| Content hash differential | 04 | 2 | 9-03 | unit test | Edge Function test | ❌ W0 | ⬜ pending |
| QuestionDTO unified schema | 05 | 3 | 9-03 | unit test | `flutter test test/unit/question_dto_test.dart` | ❌ W0 | ⬜ pending |
| Staging Area widget | 05 | 3 | 9-03 | widget test | `flutter test test/widget/staging_area_test.dart` | ❌ W0 | ⬜ pending |
| Save to Bank action | 05 | 3 | 9-03 | unit test | `flutter test test/unit/teacher_file_datasource_test.dart` | ❌ W0 | ⬜ pending |
| Save + Add to Assignment | 05 | 3 | 9-03 | integration | manual DB Transaction check | manual | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/unit/teacher_file_datasource_test.dart` — stubs for REQ 9-02 (upload + DB inserts)
- [ ] `test/unit/question_dto_test.dart` — stubs for REQ 9-03 (unified QuestionDTO schema)
- [ ] `test/widget/ai_settings_test.dart` — stubs for REQ 9-01 (navigation, route change)
- [ ] `test/widget/staging_area_test.dart` — stubs for REQ 9-03 (staging area display)
- [ ] `supabase/functions/process-document-queue/index.test.ts` — stubs for REQ 9-03 (heuristic router, checkpointing, content hash)

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| file_picker trả về .xlsx/.docx bytes | 9-02 | Không mock được native OS file picker | Chạy app trên device, tap [+] Thêm tài liệu, chọn file Excel/Word |
| Upload lên Supabase Storage thành công | 9-02 | Cần real Supabase connection | Kiểm tra Supabase Dashboard → Storage → teacher-documents bucket |
| INSERT files + file_links trong DB | 9-02 | Integration test cần real DB | Supabase Dashboard → Table Editor → files, file_links tables |
| match_document_chunks RPC trả về Top 5 | 9-03 | SQL function cần real pgvector | Chạy query trong Supabase SQL Editor |
| "Lưu và Thêm vào Đề thi" không tạo Orphan Data | 9-03 | DB Transaction verification cần real DB | Kiểm tra questions + assignment_questions tables sau khi save |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 60s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
