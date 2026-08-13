import '../models/pattern.dart';
import '../models/bead_color.dart';

class CellEvidence {
  final int? ocrColorId;
  final int? colorColorId;
  final double ocrConfidence;
  final double colorConfidence;

  const CellEvidence({
    this.ocrColorId,
    this.colorColorId,
    this.ocrConfidence = 0,
    this.colorConfidence = 0,
  });

  PatternCell? resolve({required Map<int, BeadColor> palette}) {
    final id = ocrConfidence >= colorConfidence ? ocrColorId : colorColorId;
    if (id == null) return null;
    final color = palette[id];
    if (color == null) return null;
    final confidence =
        ocrConfidence >= colorConfidence ? ocrConfidence : colorConfidence;
    return PatternCell(
      color: color,
      source:
          ocrConfidence >= colorConfidence ? CellSource.ocr : CellSource.color,
      confidence: confidence.clamp(0, 1).toDouble(),
    );
  }
}

class RecognitionQualityGate {
  final double minimumConfidence;
  final double minimumOccupiedRatio;

  const RecognitionQualityGate({
    this.minimumConfidence = .7,
    this.minimumOccupiedRatio = .02,
  });

  bool accepts({required double confidence, required double occupiedRatio}) =>
      confidence >= minimumConfidence && occupiedRatio >= minimumOccupiedRatio;
}
