# ADR S6-03: Platform verification boundary

Platform verification remains a release gate, not a claim inferred from unit
tests. Android and Windows builds, offline smoke, updater checksum validation,
and device OCR must be run in an authorized tool environment. Until those
gates execute, the task remains structurally prepared but release-blocked.
