# Image-pipeline quality gates

## Required sample record

Each committed sample records: ID, license/source, palette, expected rows/columns, expected occupancy, expected colour IDs, input class, transformations, and whether it is regression or reference-only.

## Test groups

- Geometry: rectangular/square grids, border completeness, rotation, perspective, crop and EXIF orientation.
- Content: blank versus white, black, light pastel, transparent background, labels covering colour, one/two-cell colours.
- Input: clean digital, screenshot, scan, phone photo, pixel art, illustration and photo.
- Scale: small, 29, 52, 78, 104 and non-square grids.

## Metrics

- Grid detection success and exact row/column match.
- Occupancy precision/recall.
- Per-cell colour accuracy on occupied cells.
- Consumption-map equality.
- Low-confidence recall: unsafe results must be blocked.
- Runtime and peak-memory observation by size.

## Initial thresholds

- Clean synthetic: grid ≥ 98%, cell colour ≥ 97%.
- Disturbed synthetic/screenshot: grid ≥ 95%, cell colour ≥ 90%.
- First real set: grid ≥ 90%, cell colour ≥ 85%.
- Results below the applicable gate may be reviewable but cannot auto-enable inventory deduction.

## Coordinate invariant

Document transformations as matrices or explicit scale/offset values. Never combine OCR coordinates from one image size with cell coordinates from another. Use `floor` for mapping a point into a half-open cell interval and clamp only after validating bounds.

