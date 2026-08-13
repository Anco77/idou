# Release checklist

## Repository

- Intended branch/upstream confirmed.
- No unrelated or unexplained changes.
- Task board contains no accidental `in_progress` task.
- Requirement, architecture, progress, README, and release notes are current.

## Quality

- Format, analyze, and all tests pass.
- Migration fixtures and foreign-key checks pass.
- Image regression report meets thresholds.
- Android/Windows builds required by the release succeed.
- Core flow works offline.

## Version and artifacts

- `pubspec.yaml`, `version.json`, schema version, changelog, and tag agree.
- Artifact filename embeds the version and platform.
- SHA-256 is recorded; installer/package opens on target platform.
- Upgrade from the last public version preserves user data.

## Remote delivery

- User explicitly authorized commit/push/tag/publish.
- Remote commit and tag resolve to reviewed code.
- Release notes list behavior, migrations, known issues, and rollback/backup advice.
- Uploaded artifact checksum matches the local record.

