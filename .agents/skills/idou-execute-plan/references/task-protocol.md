# Task protocol

## Status values

- `planned`: defined but dependencies or scheduling are unresolved.
- `ready`: all dependencies are done and acceptance criteria are executable.
- `in_progress`: currently owned; at most one repository-wide.
- `blocked`: cannot proceed safely; evidence and unblock action are recorded.
- `done`: implementation, tests, documentation, and review gates passed.
- `cancelled`: explicitly removed from scope with a reason.

## Definition of ready

A task needs stable requirement IDs, dependencies, allowed scope, acceptance criteria, required tests, and rollback/data-risk notes.

## Task sizing

Split a task when it mixes schema migration with unrelated UI, requires more than one independent behavior change, cannot be tested in isolation, or would produce an unreviewable diff. Preserve the parent requirement mapping.

## Progress entry

Append:

```text
## YYYY-MM-DD HH:mm — TASK-ID — status
- Goal:
- Baseline/evidence:
- Changes:
- Gates:
- Docs:
- Risks/blocker:
- Next:
```

## Completion evidence

Record exact commands and pass/fail results. For image tasks attach metric output; for data tasks name migration and failure-injection tests; for release tasks record artifact paths and checksums.

