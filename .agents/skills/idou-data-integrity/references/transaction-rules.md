# Transaction and lifecycle rules

## Invariants

1. `inventory.quantity >= 0`.
2. Every quantity change has exactly one immutable movement with `balanceAfter`.
3. Pattern deduction movements have the final `patternId`.
4. A saved pattern's consumption map equals its non-null grid aggregation.
5. `inventoryDeducted` changes only through a successful deduction or explicit reversing operation.
6. Persistent media paths point inside the controlled application directory.

## Operation boundaries

| Operation | Transaction content | File compensation |
|---|---|---|
| Adjust inventory | conditional update/upsert + movement | none |
| Batch adjust | all updates + all movements | none |
| Save pattern | pattern + consumptions | remove new assets on DB failure |
| Save and deduct | preflight + all updates + movements + pattern + consumptions | remove new assets on DB failure |
| Deduct saved | conditional pattern state + inventory + movements | none |
| Complete | pattern completion fields | remove copied photos on DB failure |
| Delete | pattern state/record + cleanup queue | retry cleanup after commit |

## Migration gates

- Test empty new install.
- Test v1→latest and v2→latest with fixture databases.
- Compare row counts, inventory balances, movement totals, pattern paths, and foreign-key checks.
- Back up before migration; leave the old DB usable if migration fails.
- Never infer missing legacy grid cells. Mark the pattern legacy.

