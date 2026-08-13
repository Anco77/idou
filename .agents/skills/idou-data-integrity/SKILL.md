---
name: idou-data-integrity
description: Design, implement, and verify idou inventory and pattern persistence, Drift schema migrations, atomic deductions, immutable movement logs, controlled media storage, deletion cleanup, backup, and restore. Use whenever a task changes database tables, repositories, transactions, inventory quantities, pattern save/deduct state, file paths, or user-data lifecycle.
---

# Protect idou data integrity

Assume every failure can occur between two writes and prove that the resulting state remains valid.

## Prepare

1. Read root `AGENTS.md`, PAT/INV/NFR requirements, schema, repositories, and existing migrations.
2. Read [references/transaction-rules.md](references/transaction-rules.md).
3. Write invariants and failure points before code.
4. Add a failing repository/migration test using a temporary database and fake asset store.

## Implement

- Put multi-record business operations in application use cases and one DB transaction.
- Prefer conditional updates and validate affected rows.
- Generate IDs before related mutations.
- Use controlled paths, temporary files, atomic rename, and compensating cleanup.
- Preserve immutable inventory history; undo with reversing movements.
- Keep domain models free of SQL/Drift mapping.
- Add migration logic through Drift sources and regenerate, never hand-edit generated code.

## Verify

Test success plus failure before/after every boundary: media write, preflight, inventory update, movement insert, pattern insert, consumption insert, commit, and cleanup. Verify new install, every supported upgrade path, idempotent retry, no negative inventory, no orphan media/path, and grid-consumption equality.

Do not mark a task complete from UI testing alone.

