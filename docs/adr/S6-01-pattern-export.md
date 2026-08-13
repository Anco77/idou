# ADR S6-01: Deterministic pattern export

The first export boundary is a pure application service over `PatternGrid`.
CSV is row-major and leaves empty cells blank; JSON carries dimensions,
color identity, source, and confidence. PNG/PDF renderers can consume the
same JSON model later without coupling storage or UI to an export format.
