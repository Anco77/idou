# ADR S3-04: Empty-aware color fusion and quality gate

Recognition evidence remains separate until fusion. Empty cells resolve to
`null`; they are never coerced to a white bead. For occupied cells the stronger
OCR or color confidence wins and the resulting `PatternCell` records its
source and bounded confidence. A quality gate blocks drafts whose confidence
or occupied-cell ratio is below the configured threshold.
