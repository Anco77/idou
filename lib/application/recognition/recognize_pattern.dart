import '../../domain/ports/ocr_port.dart';

enum RecognitionStage {
  loading,
  grid,
  ocr,
  fusion,
  completed,
  failed,
  cancelled
}

class RecognitionProgress {
  final RecognitionStage stage;
  final double fraction;

  const RecognitionProgress(this.stage, this.fraction);
}

class RecognitionFailure {
  final String code;
  final String message;

  const RecognitionFailure(this.code, this.message);
}

sealed class RecognitionResult {
  const RecognitionResult();
}

final class RecognitionSucceeded extends RecognitionResult {
  final List<OcrObservation> observations;

  const RecognitionSucceeded(this.observations);
}

final class RecognitionFailed extends RecognitionResult {
  final RecognitionFailure failure;

  const RecognitionFailed(this.failure);
}

final class RecognitionCancelled extends RecognitionResult {
  const RecognitionCancelled();
}

class RecognizePattern {
  final OcrPort _ocr;

  const RecognizePattern(this._ocr);

  Future<RecognitionResult> call(
    String imagePath, {
    void Function(RecognitionProgress progress)? onProgress,
    bool Function()? isCancelled,
  }) async {
    if (isCancelled?.call() ?? false) return const RecognitionCancelled();
    onProgress?.call(const RecognitionProgress(RecognitionStage.ocr, .35));
    try {
      final observations = await _ocr.recognize(imagePath);
      if (isCancelled?.call() ?? false) return const RecognitionCancelled();
      onProgress
          ?.call(const RecognitionProgress(RecognitionStage.completed, 1));
      return RecognitionSucceeded(observations);
    } catch (error) {
      return RecognitionFailed(
        RecognitionFailure('ocr_failed', 'OCR recognition failed: $error'),
      );
    }
  }
}
