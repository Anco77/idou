import '../../core/services/ocr_service.dart';
import '../../domain/ports/ocr_port.dart';

class OcrPortAdapter implements OcrPort {
  final OcrService _service;
  final int cropX;
  final int cropY;
  final int cropW;
  final int cropH;
  final int gridCols;
  final int gridRows;

  const OcrPortAdapter(
    this._service, {
    required this.cropX,
    required this.cropY,
    required this.cropW,
    required this.cropH,
    required this.gridCols,
    required this.gridRows,
  });

  @override
  Future<List<OcrObservation>> recognize(String imagePath) async {
    final results = await _service.recognizeMardIds(
      imagePath,
      cropX,
      cropY,
      cropW,
      cropH,
      gridCols,
      gridRows,
    );
    return results
        .map(
          (result) => OcrObservation(
            text: result.mardId,
            row: result.row,
            column: result.col,
            confidence: 1,
          ),
        )
        .toList(growable: false);
  }
}
