import 'package:flutter_test/flutter_test.dart';
import 'package:idou/application/recognition/recognize_pattern.dart';
import 'package:idou/domain/ports/ocr_port.dart';

void main() {
  test('recognition reports progress and supports cancellation', () async {
    final useCase = RecognizePattern(_FakeOcr());
    final progress = <RecognitionStage>[];
    final result = await useCase(
      'sample.png',
      onProgress: (value) => progress.add(value.stage),
    );
    expect(result, isA<RecognitionSucceeded>());
    expect(progress, contains(RecognitionStage.completed));

    final cancelled = await useCase('sample.png', isCancelled: () => true);
    expect(cancelled, isA<RecognitionCancelled>());
  });
}

class _FakeOcr implements OcrPort {
  @override
  Future<List<OcrObservation>> recognize(String imagePath) async => [
        const OcrObservation(text: 'A1', row: 0, column: 0, confidence: .9),
      ];
}
