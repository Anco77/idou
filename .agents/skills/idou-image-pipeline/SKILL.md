---
name: idou-image-pipeline
description: Develop and verify idou grid detection, OCR, bead-colour recognition, blank-cell classification, photo-to-pattern conversion, palette reduction, and pattern editing algorithms. Use for any change involving uploaded images, recognition accuracy, crop or coordinate mapping, conversion quality, image samples, confidence scoring, or image-pipeline performance.
---

# Develop idou image pipelines

Treat image behavior as a measured pipeline, not a UI demo.

## Prepare

1. Read root `AGENTS.md`, the active task, and relevant REC/CONV/EDIT requirements.
2. Read [references/quality-gates.md](references/quality-gates.md).
3. Identify whether the task is recognition, conversion, or shared editor behavior. Do not merge these engine entry points.
4. Add or select a licensed/generated sample with manifest and ground truth.
5. Record the current metric or reproducible failure before editing the algorithm.

## Implement

- Keep one explicit coordinate space through orientation, crop, scale, grid, OCR, and sampling.
- Model blank cells independently from white colours.
- Preserve cell candidates, final source, distance/confidence, and manual override.
- Make every optional cleanup/merge reversible.
- Move expensive pixel/grid work off the UI isolate.
- Keep palette access independent of inventory initialization.

## Verify

1. Run focused parser/geometry/colour tests.
2. Run the deterministic synthetic regression set.
3. Run the relevant disturbed and real-sample set.
4. Compare grid dimensions, occupancy mask, per-cell colour, consumptions, confidence gate, and runtime.
5. Reject an accuracy improvement that silently increases false deductions or regresses protected samples.
6. Store metric output in the progress entry and update the sample manifest when applicable.

