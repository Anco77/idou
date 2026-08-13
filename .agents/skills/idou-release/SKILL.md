---
name: idou-release
description: Prepare and deliver an idou repository release by running full quality gates, validating migrations and artifacts, updating versions and release documentation, reviewing Git changes, creating authorized commits or tags, and pushing or publishing only when explicitly requested. Use for release candidates, repository delivery, version bumps, build artifacts, changelogs, tags, pushes, or final project verification.
---

# Release idou safely

Separate verification from mutations and require explicit authorization for Git push, tags, or publication.

## Prepare

1. Read root `AGENTS.md`, `docs/AI_TASKS.yaml`, `docs/AI_PROGRESS.md`, and [references/release-checklist.md](references/release-checklist.md).
2. Confirm no incomplete P0 task is being included unintentionally.
3. Inspect status, diff, branch, upstream, recent tags, version files, and schema version.
4. Run `scripts/project_gate.ps1 -Mode full`; use release builds only when requested or required by the active release task.

## Verify and document

- Record exact gate commands and outputs.
- Verify migration fixtures, image metrics, offline core flow, artifact version and checksum.
- Update README, changelog/release notes, task board, progress, and release checklist.
- Present changed files, commits, risks, target branch, tag, and artifacts before any remote action.

## Deliver

- Commit only when authorized; keep commits task-scoped.
- Push, tag, or publish only when explicitly authorized in the current request.
- After remote delivery, verify the remote commit, tag, or release and record URLs/checksums.
- If any gate fails, stop release actions and leave a resumable blocker entry.

