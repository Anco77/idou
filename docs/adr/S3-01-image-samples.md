# ADR S3-01: Deterministic image samples and machine-readable metrics

## Decision

The image pipeline starts with a repository-owned deterministic manifest in
`lib/test_support/image_samples.dart`. Samples use a `generated://` source URI,
explicit dimensions, an occupancy mask, and nullable color IDs. `null` means
an empty cell; a color ID is only meaningful for an occupied cell.

The first baseline covers a clean 29x29 sample and a disturbed rectangular
29x52 sample. It intentionally does not claim production accuracy for camera
photos. The metric runner compares grid shape, occupancy, and occupied-cell
colors, and exposes JSON-safe maps so CI can persist or compare reports.

## Consequences

- Regression tests are reproducible without shipping unlicensed photographs.
- Empty cells cannot be silently converted to white beads in the baseline.
- Real-photo and device OCR datasets remain a later, separately authorized
  expansion of the manifest.
