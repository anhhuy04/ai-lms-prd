---
description: Targeted workflow for debugging regressions, compilation errors, or logic issues.
---
# Workflow: Bug Fixing

This workflow guides you through the process of resolving bugs in the AI LMS PRD application. It emphasizes the Scientific Method (Observe, Hypothesize, Experiment, Fix).

1. **Plan (Observe & Hypothesize)**
   - Read the exact error message provided by the USER or from terminal logs.
   - Look up relevant rules in `.agents/rules/` (especially `70_code_quality.md` for common bug patterns).
   - Read `memory-bank/activeContext.md` to understand the current state.
   - Form a hypothesis about the root cause. If needed, formulate an experiment (e.g., adding `AppLogger` statements) and ask the USER to reproduce the bug.

2. **Execute (Experiment & Fix)**
   - Implement the fix carefully. Do not completely rewrite a class unless absolutely necessary; prefer targeted, minimal edits.
   - Ensure the fix doesn't violate existing Architecture (e.g., don't put business logic in the UI) or State Management rules (e.g., maintain Riverpod `ref.invalidate` patterns).

// turbo-all
3. **Debug (Verify Fix locally)**
   - Run `flutter analyze` to ensure no syntax or typing errors were introduced.
   - Run specific tests if available: `flutter test lib/path/to/test.dart`.

4. **Check (Document & Prevent)**
   - If the bug is a common pattern that isn't documented, suggest an update to the `memory-bank`.
   - Update `memory-bank/progress.md` to reflect the bug fix.
   - Use `notify_user` to report the resolution of the bug and outline the exact cause and fix.
