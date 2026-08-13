# ADR S3-02: Structured grid detection diagnostics

`GridDetector.detect` remains a compatibility method returning a nullable
result. New callers should use `detectDetailed`, which returns either the
candidate boundary, row/column counts, orientation and confidence, or a
typed failure reason. This lets the recognition flow distinguish an image
that is too small from one with missing grid axes or an unsupported shape,
without guessing a grid.
