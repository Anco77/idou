import 'dart:math';

import 'package:image/image.dart' as img;

/// Rectangle and dimensions of a detected bead-pattern grid.
class GridDetectionResult {
  final int cropX;
  final int cropY;
  final int cropW;
  final int cropH;
  final int gridCols;
  final int gridRows;
  final double confidence;
  final double orientationDegrees;

  const GridDetectionResult({
    required this.cropX,
    required this.cropY,
    required this.cropW,
    required this.cropH,
    required this.gridCols,
    required this.gridRows,
    required this.confidence,
    this.orientationDegrees = 0,
  });
}

enum GridDetectionFailureReason {
  imageTooSmall,
  missingAxisLines,
  unsupportedShape
}

class GridDetectionFailure {
  final GridDetectionFailureReason reason;
  final String message;

  const GridDetectionFailure(this.reason, this.message);
}

class GridDetectionAttempt {
  final GridDetectionResult? result;
  final GridDetectionFailure? failure;

  const GridDetectionAttempt.success(this.result) : failure = null;
  const GridDetectionAttempt.failed(this.failure) : result = null;

  bool get isSuccess => result != null;
}

class _LineSequence {
  final List<int> positions;
  final double score;

  const _LineSequence(this.positions, this.score);
}

/// Detects the repeated horizontal and vertical rules of a printed pattern.
///
/// The old implementation only returned a high-variance bounding box. That
/// commonly included the title/legend and still required the user to guess the
/// board size. This detector looks for a long, near-regular sequence of neutral
/// dark rules instead, so arbitrary rectangular charts (for example 29×25) are
/// supported without OpenCV.
class GridDetector {
  static GridDetectionResult? detect(img.Image source) {
    return detectDetailed(source).result;
  }

  static GridDetectionAttempt detectDetailed(img.Image source) {
    if (source.width < 40 || source.height < 40) {
      return const GridDetectionAttempt.failed(
        GridDetectionFailure(
          GridDetectionFailureReason.imageTooSmall,
          'Image is too small for grid detection.',
        ),
      );
    }

    const maxSide = 1400;
    final scale = maxSide / max(source.width, source.height);
    final image = scale < 1
        ? img.copyResize(
            source,
            width: (source.width * scale).round(),
            height: (source.height * scale).round(),
          )
        : source;

    final horizontal = _detectAxis(image, horizontal: true);
    final vertical = _detectAxis(image, horizontal: false);
    if (horizontal == null || vertical == null) {
      return const GridDetectionAttempt.failed(
        GridDetectionFailure(
          GridDetectionFailureReason.missingAxisLines,
          'Repeated horizontal and vertical grid lines were not found.',
        ),
      );
    }

    final rows = horizontal.positions.length - 1;
    final cols = vertical.positions.length - 1;
    if (rows < 2 || cols < 2) {
      return const GridDetectionAttempt.failed(
        GridDetectionFailure(
          GridDetectionFailureReason.unsupportedShape,
          'Detected line sequences do not form a usable rectangular grid.',
        ),
      );
    }

    final inverseScale = scale < 1 ? 1 / scale : 1.0;
    final left = (vertical.positions.first * inverseScale).round();
    final right = (vertical.positions.last * inverseScale).round();
    final top = (horizontal.positions.first * inverseScale).round();
    final bottom = (horizontal.positions.last * inverseScale).round();

    return GridDetectionAttempt.success(GridDetectionResult(
      cropX: left.clamp(0, source.width - 1),
      cropY: top.clamp(0, source.height - 1),
      cropW: (right - left).clamp(1, source.width - left),
      cropH: (bottom - top).clamp(1, source.height - top),
      gridCols: cols,
      gridRows: rows,
      confidence: ((horizontal.score + vertical.score) / 2).clamp(0, 1),
    ));
  }

  static _LineSequence? _detectAxis(img.Image image,
      {required bool horizontal}) {
    final axisLength = horizontal ? image.height : image.width;
    final crossLength = horizontal ? image.width : image.height;
    final step = max(1, crossLength ~/ 700);
    final scores = List<double>.filled(axisLength, 0);

    for (var axis = 0; axis < axisLength; axis++) {
      var neutralDark = 0;
      var samples = 0;
      for (var cross = 0; cross < crossLength; cross += step) {
        final pixel = horizontal
            ? image.getPixel(cross, axis)
            : image.getPixel(axis, cross);
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        final maxChannel = max(r, max(g, b));
        final minChannel = min(r, min(g, b));
        final luminance = (r * 299 + g * 587 + b * 114) ~/ 1000;
        // Grid rules are normally grey/black. Ignoring saturated pixels keeps
        // broad coloured artwork from becoming a false line.
        if (luminance < 185 && maxChannel - minChannel < 42) neutralDark++;
        samples++;
      }
      scores[axis] = samples == 0 ? 0 : neutralDark / samples;
    }

    final sorted = [...scores]..sort();
    final p90 = sorted[(sorted.length * .90).floor()];
    final p98 = sorted[(sorted.length * .98).floor()];
    final threshold = max(.045, p90 + (p98 - p90) * .28);
    final candidates = _peakCenters(scores, threshold);
    if (candidates.length < 4) return null;

    return _bestRegularSequence(candidates, scores, axisLength);
  }

  static List<int> _peakCenters(List<double> scores, double threshold) {
    final result = <int>[];
    var start = -1;
    for (var i = 0; i <= scores.length; i++) {
      final above = i < scores.length && scores[i] >= threshold;
      if (above && start < 0) {
        start = i;
      } else if (!above && start >= 0) {
        var best = start;
        for (var j = start + 1; j < i; j++) {
          if (scores[j] > scores[best]) best = j;
        }
        result.add(best);
        start = -1;
      }
    }
    return result;
  }

  static _LineSequence? _bestRegularSequence(
    List<int> candidates,
    List<double> scores,
    int axisLength,
  ) {
    _LineSequence? best;
    var bestRank = double.negativeInfinity;
    final maxGap = max(6, axisLength ~/ 3);

    for (var i = 0; i < candidates.length - 1; i++) {
      for (var j = i + 1; j < candidates.length; j++) {
        final gap = candidates[j] - candidates[i];
        if (gap < 5 || gap > maxGap) continue;

        final tolerance = max(2, (gap * .16).round());
        final sequence = <int>[candidates[i]];
        var expected = candidates[i] + gap;
        var cursor = i + 1;

        while (expected < axisLength + tolerance) {
          while (cursor < candidates.length &&
              candidates[cursor] < expected - tolerance) {
            cursor++;
          }
          if (cursor >= candidates.length ||
              candidates[cursor] > expected + tolerance) {
            break;
          }
          var chosen = cursor;
          if (cursor + 1 < candidates.length &&
              candidates[cursor + 1] <= expected + tolerance &&
              (candidates[cursor + 1] - expected).abs() <
                  (candidates[cursor] - expected).abs()) {
            chosen = cursor + 1;
          }
          sequence.add(candidates[chosen]);
          cursor = chosen + 1;
          expected = sequence.first + sequence.length * gap;
        }

        if (sequence.length < 4) continue;
        final span = sequence.last - sequence.first;
        final coverage = span / axisLength;
        final strength = sequence
                .map((position) => scores[position])
                .reduce((a, b) => a + b) /
            sequence.length;
        final regularity = _regularity(sequence, gap);
        // Repeated lines matter most; coverage prevents short text baselines
        // from winning, while strength breaks ties between real/faint grids.
        final rank =
            sequence.length * 3.0 + coverage * 10 + strength * 3 + regularity;
        final confidence =
            (sequence.length / 12 * .55 + coverage * .3 + regularity * .15)
                .clamp(0.0, 1.0);
        if (rank > bestRank) {
          best = _LineSequence(sequence, confidence);
          bestRank = rank;
        }
      }
    }
    return best;
  }

  static double _regularity(List<int> positions, int expectedGap) {
    if (positions.length < 2) return 0;
    var error = 0.0;
    for (var i = 1; i < positions.length; i++) {
      error +=
          ((positions[i] - positions[i - 1]) - expectedGap).abs() / expectedGap;
    }
    return (1 - error / (positions.length - 1)).clamp(0, 1);
  }
}
