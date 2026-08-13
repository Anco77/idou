# idou Agent Instructions

## Scope

These instructions apply to the whole repository.

## Canonical project context

Before changing code, read:

1. `docs/00_项目总览与现状审计.md`
2. `docs/01_目标架构.md`
3. `docs/02_产品目标与需求基线.md`
4. `docs/04_AI全流程执行计划.md`
5. `docs/AI_TASKS.yaml`
6. The skill selected for the task under `.agents/skills/`

Treat `docs/AI_TASKS.yaml` as the resumable execution state. Historical documents outside this repository are references, not the active plan.

## Mandatory task loop

1. Inspect `git status` and preserve unrelated user changes.
2. Select exactly one task whose status is `ready`, or continue the single `in_progress` task.
3. Verify every dependency in the task board is `done`.
4. Change the task to `in_progress` before implementation and record the start in `docs/AI_PROGRESS.md`.
5. Establish a failing test or a reproducible baseline before behavior changes.
6. Implement the smallest complete vertical slice allowed by the task scope.
7. Run the task's required quality gates. Do not describe unrun checks as passed.
8. Review the diff for layer violations, partial writes, stale paths, accidental generated files, and unrelated changes.
9. Update affected architecture, requirements, task-board, progress, migration, and release documentation.
10. Mark the task `done` only when every acceptance criterion and gate passes. Otherwise use `blocked` with evidence and a concrete next action.

Do not start a second feature while the current task is incomplete. Split a task before implementation when it cannot be completed and verified as one reviewable change.

## Skills

- Use `.agents/skills/idou-execute-plan` for selecting and completing plan tasks.
- Use `.agents/skills/idou-image-pipeline` for grid detection, OCR, colour recognition, conversion, image samples, confidence, or image-pipeline performance.
- Use `.agents/skills/idou-data-integrity` for Drift schema, migration, inventory, pattern persistence, media lifecycle, transactions, backup, or restore.
- Use `.agents/skills/idou-release` for full verification, version changes, builds, Git delivery, tags, release metadata, or release documentation.

Use all applicable skills. The execute-plan skill coordinates; specialist skills add stricter gates.

## Architecture boundaries

- `domain` must not import Flutter, Drift, platform plugins, `dart:io`, SQL mappers, or DAO types.
- `application` coordinates use cases and depends on domain contracts.
- `infrastructure` implements database, filesystem, OCR, image, update, and export ports.
- `presentation` handles interaction state and calls application use cases. Do not add direct DAO, raw SQL, filesystem, or repository-implementation access.
- Keep recognition and image conversion as separate engines. Share palette, `PatternGrid`, editor, consumption, inventory preview, persistence, and export.
- Do not hand-edit `app_database.g.dart`; regenerate it from Drift sources.

## Data safety

- Inventory quantity must never become negative.
- Every inventory mutation and its movement log must share one database transaction.
- Pattern save-and-deduct must atomically validate, deduct, write movements, save the pattern, and save consumptions.
- Generate `patternId` before deduction so every related movement records it.
- Persist picked media into the controlled application directory before storing paths.
- Use compensating cleanup if media creation succeeds but the database transaction fails.
- Never delete inventory history to undo an operation; create a reversing movement.
- Every schema change requires new-install and upgrade-path tests.

## Image pipeline integrity

- Never assess an algorithm from one screenshot or visual impression.
- Add or update a licensed/generated sample, manifest entry, and ground truth before fixing an image case.
- Keep blank cells distinct from white beads.
- OCR, colour sampling, grid cells, crop, rotation, and perspective correction must use one documented coordinate space.
- Preserve per-cell source and confidence. Low-quality results must not enable automatic inventory deduction.
- Run expensive image work outside the UI isolate.

## Quality gates

Run the smallest gate while iterating, then the full task gate before completion:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Also run as applicable:

- Focused unit/widget test for the changed module.
- Database migration and rollback/failure-injection tests.
- Image regression suite with ground-truth report.
- `flutter build apk` for Android-sensitive changes.
- `flutter build windows` for Windows-sensitive changes.
- The release skill's `scripts/project_gate.ps1` for release candidates.

If the toolchain hangs or is unavailable, record the exact command, timeout, and environment evidence. The task remains `blocked` or `in_progress`, never `done`.

## Documentation and traceability

- Every implementation task must reference stable requirement IDs such as `INV-004`, `REC-005`, or `PAT-003`.
- Update `docs/AI_TASKS.yaml` and append `docs/AI_PROGRESS.md` in the same change.
- Update `docs/01_目标架构.md` for boundary decisions and schema changes.
- Update `docs/02_产品目标与需求基线.md` only for approved requirement changes, not to make implementation easier.
- Add an ADR under `docs/adr/` for irreversible or cross-cutting decisions.
- Update user-visible README/changelog/release notes whenever behavior changes.

## Git and release rules

- Do not discard, reset, or rewrite user changes.
- Keep commits task-scoped; separate mechanical refactors from behavior changes.
- Suggested commit format: `type(scope): summary [REQ-ID]`.
- Do not commit, push, tag, publish a release, or upload artifacts unless the active user request authorizes that action.
- Before an authorized push: show the diff summary, gate results, document updates, target branch, and commits to be pushed.
- Create a version tag only after the release gate passes and version values, schema version, `version.json`, changelog, and artifacts agree.

## Deletion rules

- Delete obsolete code only after all references have migrated and tests pass.
- Resolve and verify exact paths before recursive deletion.
- Generated caches and stale worktrees may be removed only when outside the active repository state and deletion is explicitly within task scope.

