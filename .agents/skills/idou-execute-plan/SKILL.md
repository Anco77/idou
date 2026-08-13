---
name: idou-execute-plan
description: Execute idou development work from the repository task board through implementation, focused tests, full verification, documentation updates, and delivery handoff. Use for requests to continue the plan, implement the next task or phase, fix a planned issue, complete a feature end to end, or report and advance project progress.
---

# Execute the idou plan

Work on one verifiable task at a time and leave the repository resumable.

## Start

1. Find the Git root and read `AGENTS.md` completely.
2. Read `docs/AI_TASKS.yaml`, `docs/AI_PROGRESS.md`, and the requirement/architecture sections referenced by the task.
3. Inspect `git status`, recent commits, and relevant code/tests.
4. Continue the sole `in_progress` task. If none exists, choose the highest-priority `ready` task whose dependencies are `done`.
5. Read [references/task-protocol.md](references/task-protocol.md).
6. Load `idou-image-pipeline`, `idou-data-integrity`, or `idou-release` when the task touches those domains.

## Execute

1. Restate the task ID, requirement IDs, allowed files, acceptance criteria, and required gates.
2. Mark it `in_progress` and append a start entry to `docs/AI_PROGRESS.md`.
3. Reproduce current behavior or add a failing test.
4. Implement the smallest complete vertical slice. Do not combine opportunistic cleanup.
5. Run focused tests after each meaningful change.
6. Run every task gate, inspect the final diff, and update documentation.

## Finish

- Mark `done` only when acceptance criteria and gates pass.
- Mark `blocked` only with command/output evidence, affected criterion, and an actionable unblock step.
- Leave partial work `in_progress`; record what remains and do not claim completion.
- Do not commit or push without explicit authorization.
- Hand off with task ID, outcome, files changed, tests run, known risks, and next ready task.

