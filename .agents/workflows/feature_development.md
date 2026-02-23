---
description: Comprehensive workflow for implementing new features or making significant changes in the app.
---
# Workflow: Feature Development

This workflow guides you through the process of implementing a new feature in the AI LMS PRD application. It follows a strict "Plan -> Execute -> Debug -> Check" cycle.

1. **Read Core Context**
   - Read `.agents/rules/README.md` to identify the relevant rules for this feature.
   - Read the relevant `memory-bank` context (`activeContext.md` and `progress.md`).
   - Call the `read_resource` tool for any necessary UI Design Tokens or Architecture rules if they apply to your task.

2. **Plan (Analyze & Design)**
   - Ask the USER for clarification if the requirements are ambiguous.
   - Analyze the existing codebase (grep for existing providers/routing configurations to prevent duplication).
   - Write down an Implementation Plan (using the `write_to_file` tool on `implementation_plan.md`) covering:
     - Proposed Architecture (MVVM layers)
     - State Management (Riverpod AsyncNotifier)
     - Routing (GoRouter)
     - UI Design Tokens
   - Use the `notify_user` tool to request approval on the `implementation_plan.md`. Do not proceed until approved.

3. **Execute (Implement the Code)**
   - Implement the changes according to the approved plan.
   - Adhere strictly to the `.agents/rules/` for syntax, architecture, state, and UI.
   - Use `build_runner` if you modify `Freezed` or `JsonSerializable` models.

// turbo-all
4. **Debug (Static Analysis)**
   - Run `flutter analyze` from the terminal.
   - If there are errors, fix them iteratively. Do not proceed to the Check phase with failing analysis.

5. **Check (Verify & Document)**
   - Test the feature (write unit/widget tests if applicable according to rules).
   - Update `memory-bank/progress.md` with the new feature status.
   - Run `flutter analyze` one final time before completing the task.
   - Use `notify_user` to report the completion of the feature and present the final results.
