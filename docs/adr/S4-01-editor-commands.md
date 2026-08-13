# ADR S4-01: Reversible editor commands

The editor operates on immutable `PatternGrid` snapshots. Cell edits, fills,
low-confidence confirmations, and color merges are commands with explicit
before/after state. The command stack keeps independent undo and redo stacks;
executing a new command invalidates redo history. This preserves grid
occupancy and material counts while making manual corrections auditable.

The editor does not deduct inventory. Persistence and deduction remain later
application boundaries so a local edit can always be undone before save.
