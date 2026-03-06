# Domain Pitfalls: LMS Mobile App Development

**Project:** AI LMS PRD
**Researched:** 2026-03-05
**Confidence:** MEDIUM

---

## Critical Pitfalls

Mistakes that cause rewrites, major issues, or user trust loss.

### Pitfall 1: Assignment Submission Race Conditions

**What goes wrong:** Student taps submit multiple times, causing duplicate submissions or partial data loss.

**Why it happens:** No optimistic locking, no disable-on-submit UI pattern, network delay not handled.

**Consequences:**
- Duplicate submissions in database
- Students lose work
- Teacher sees inconsistent grading targets
- Data integrity issues

**Prevention:**
```dart
// Always use submission guards
bool _isSubmitting = false;

Future<void> submitAssignment() async {
  if (_isSubmitting) return;
  _isSubmitting = true;
  try {
    // Submit logic
  } finally {
    _isSubmitting = false;
  }
}
```

**Detection:** Check for duplicate `submissions` rows with same `student_id` + `assignment_id`.

---

### Pitfall 2: Auto-Save Data Loss

**What goes wrong:** Student writes long answer, app crashes or loses network, work is gone.

**Why it happens:**
- Auto-save only on screen exit
- No local persistence for drafts
- Debounce too long (>3s)
- SharedPreferences quota exceeded without handling

**Consequences:**
- Severe UX damage
- Students lose trust in app
- Support tickets spike
- Students stop using app

**Prevention:**
- Save draft to Drift (local DB) on every debounced change (2s)
- Save immediately on app lifecycle pause
- Show "Draft saved" indicator
- Recover drafts on app resume

---

### Pitfall 3: Real-Time Conflict (Teacher Grades While Student Views)

**What goes wrong:** Student sees old grade, teacher updates grade, student confused about actual score.

**Why it happens:** No real-time subscription, stale data, no refresh on screen focus.

**Consequences:**
- Parent meetings become confrontational
- Grade disputes
- Trust issues

**Prevention:**
- Use Supabase Realtime subscriptions for submissions/grades
- Refresh data on `AppLifecycleState.resumed`
- Show "Grade updated" banner when new data arrives
- Always show last_updated timestamp

---

### Pitfall 4: RLS Misconfiguration (Data Leakage)

**What goes wrong:** Student can see other students' grades, teacher sees wrong classes.

**Why it happens:**
- RLS policies not tested with all roles
- `(select auth.uid())` not used correctly
- Missing policies for new tables

**Consequences:**
- Privacy breach
- Legal liability
- Complete trust loss

**Prevention:**
- Test RLS as EACH role after every schema change
- Create test users for admin, teacher, student
- Always use `(select auth.uid())` not `auth.uid()` directly
- Add RLS check to new table checklist

---

### Pitfall 5: Offline Mode Ignored

**What goes wrong:** App completely breaks when network unavailable.

**Why it happens:** No offline-first architecture, all operations require network.

**Consequences:**
- Rural users cannot use
- Campus WiFi failures break entire class
- Students cannot submit when needed most

**Prevention:**
- Use Drift for offline-first data
- Queue submissions when offline, sync when online
- Show offline indicator in UI
- Test airplane mode regularly

---

## Moderate Pitfalls

### Pitfall 6: Poor AsyncValue Handling

**What goes wrong:** Error states not shown, loading spinners forever, null checks crash.

**Why it happens:**
- `state.when()` not used for all AsyncValue states
- No error boundaries
- Missing null guards on data

**Consequences:**
- Blank screens
- App crashes
- Confusing user experience

**Prevention:**
```dart
// Always handle all states
final submissions = ref.watch(submissionsProvider);
return submissions.when(
  data: (data) => ListView(...),
  loading: () => const ShimmerLoading(),
  error: (e, st) => ErrorWidget(message: e.toString()),
);
```

---

### Pitfall 7: Timezone Chaos

**What goes wrong:** Due date shows different times for teacher vs student, assignments appear "late" incorrectly.

**Why it happens:**
- Storing dates as local time instead of UTC
- No timezone conversion on display
- Server and client time mismatch

**Consequences:**
- Assignment deadline disputes
- Students submit "late" when they weren't
- Grading confusion

**Prevention:**
- Store ALL datetime as UTC in Supabase
- Convert to local time only on display
- Show timezone indicator (e.g., "Due: 11:59 PM (ICT)")
- Use `DateTime.toLocal()` only at UI layer

---

### Pitfall 8: File Upload Without Progress

**What goes wrong:** Large files upload forever with no feedback, users think app froze.

**Why it happens:**
- No upload progress tracking
- No file size limits
- No retry mechanism
- No upload cancellation

**Consequences:**
- Users kill app mid-upload
- Duplicate uploads
- frustration

**Prevention:**
- Show upload progress percentage
- Limit file size (e.g., 10MB max)
- Implement retry with exponential backoff
- Allow cancellation
- Compress images before upload

---

### Pitfall 9: Rubric Over-Engineering

**What goes wrong:** Teachers spend hours creating complex rubrics, students can't understand grading criteria.

**Why it happens:**
- Too many rubric levels (5+)
- Unclear criteria descriptions
- No rubric preview for students

**Consequences:**
- Teachers abandon feature
- Inconsistent grading
- Student complaints

**Prevention:**
- Limit rubric to 3-4 levels
- Use clear, simple language
- Show rubric to students before submission
- Pre-built templates for common assignment types

---

### Pitfall 10: Analytics Query Performance

**What goes wrong:** Analytics page takes 30+ seconds to load, crashes on large datasets.

**Why it happens:**
- N+1 queries
- No pagination
- Computing aggregations in Flutter instead of SQL
- No caching

**Consequences:**
- App feels slow
- Battery drain
- Users abandon analytics

**Prevention:**
- Use Supabase RPC for complex aggregations
- Implement cursor-based pagination
- Cache analytics for 5-10 minutes
- Show skeleton while loading

---

## Minor Pitfalls

### Pitfall 11: Notification Overload

**What goes wrong:** Push notifications for every assignment, grade, comment - users disable all.

**Why it happens:**
- No notification preferences
- Too many events trigger notifications
- No quiet hours

**Consequences:**
- Users disable notifications entirely
- Miss important deadlines

**Prevention:**
- Allow users to select notification types
- Batch notifications (digest vs immediate)
- Respect quiet hours
- Don't notify for "draft saved"

---

### Pitfall 12: Hardcoded Strings

**What goes wrong:** UI shows English in Vietnamese app, no easy translation.

**Why it happens:**
- Hardcoded strings in widgets
- No localization system
- Localization added too late

**Consequences:**
- Rework required
- Inconsistent UI
- Cannot expand to other languages

**Prevention:**
- Use localization keys from day 1
- Design tokens for all text styles
- Build localization system early

---

## Phase-Specific Warnings

| Phase | Likely Pitfall | Mitigation |
|-------|---------------|------------|
| **Student Workspace** | Auto-save data loss | Implement Drift draft storage before building UI |
| **Grading Workflow** | Real-time sync | Add Supabase subscriptions early, not as afterthought |
| **Analytics** | Query performance | Design analytics queries in SQL, not Flutter |
| **Rubric System** | Over-engineering | Start simple, add complexity only if needed |
| **Recommendations** | Irrelevant suggestions | Start with rule-based, ML only after data |

---

## Common Flutter-Specific Issues

### Provider Scoping Mistakes
- **Issue:** Provider created at wrong scope, causes unnecessary rebuilds
- **Fix:** Use `ref.watch` at correct level, `ref.read` in callbacks

### Memory Leaks
- **Issue:** `StreamSubscription` not disposed, controller not disposed
- **Fix:** Use `ref.onDispose` for cleanup

### Build Context Issues
- **Issue:** Using `context` after async gap
- **Fix:** Check `mounted` before using context

---

## Sources

- General LMS development patterns and common failures (Flutter/Riverpod ecosystem)
- Supabase documentation on RLS best practices
- Mobile app offline-first architecture patterns
- Assignment submission race condition patterns
