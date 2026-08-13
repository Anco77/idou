# ADR S4-01: Shared editor command stack

Editing changes are represented as reversible commands over immutable
`PatternGrid` snapshots. Executing a command clears the redo stack; undo and
redo both reuse the same command semantics. This keeps grid occupancy and
derived inventory counts consistent and gives mobile/desktop editors a shared
state primitive.
