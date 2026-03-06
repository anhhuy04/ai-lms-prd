# Research Summary: AI LMS PRD

**Generated:** 2026-03-05
**Mode:** YOLO

---

## Key Findings

### Technology Stack
- **Auto-save**: Use existing `easy_debounce` package - debounce backend save by 2 seconds
- **File upload**: Native Supabase Storage API (no additional package needed)
- **Charts**: `fl_chart` recommended for analytics dashboards
- **Rich text**: `fleather` (Quill-based) for assignment content
- **State**: Project already uses correct Riverpod patterns

### Table Stakes (Must Have)
- Student assignment list and detail views
- Workspace for completing assignments
- Teacher submission viewing and grading
- Basic analytics

### Differentiators
- AI-generated questions (already implemented)
- AI auto-grading with confidence scoring
- Sophisticated recipient tree selector
- Rubric system

### Watch Out For
1. **Submission race conditions** - Disable button on submit, use optimistic locking
2. **Auto-save data loss** - Use Drift local storage as backup
3. **Real-time sync** - Subscribe to grade changes, refresh on focus
4. **RLS data leakage** - Test as each role
5. **Timezone handling** - Store UTC, convert at UI only

---

## Research Files

| File | Purpose |
|------|---------|
| `.planning/research/STACK.md` | Technology recommendations |
| `.planning/research/FEATURES.md` | Feature landscape |
| `.planning/research/ARCHITECTURE.md` | Architecture patterns |
| `.planning/research/PITFALLS.md` | Common mistakes to avoid |

---

*Summary generated: 2026-03-05*
