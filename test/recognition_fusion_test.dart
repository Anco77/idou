import 'package:flutter_test/flutter_test.dart';
import 'package:idou/domain/models/bead_color.dart';
import 'package:idou/domain/services/recognition_fusion.dart';

void main() {
  final palette = {
    1: BeadColor(
        id: 1, code: 'A1', displayName: 'A1', red: 255, green: 0, blue: 0),
  };

  test('keeps empty cells separate and chooses the stronger evidence source',
      () {
    final cell = const CellEvidence(
      ocrColorId: 1,
      colorColorId: 1,
      ocrConfidence: .8,
      colorConfidence: .6,
    ).resolve(palette: palette);

    expect(cell, isNotNull);
    expect(cell!.source.name, 'ocr');
    expect(const CellEvidence().resolve(palette: palette), isNull);
  });

  test('quality gate blocks low-confidence or nearly empty grids', () {
    const gate = RecognitionQualityGate();
    expect(gate.accepts(confidence: .8, occupiedRatio: .1), isTrue);
    expect(gate.accepts(confidence: .5, occupiedRatio: .1), isFalse);
    expect(gate.accepts(confidence: .8, occupiedRatio: .001), isFalse);
  });
}
