class OcrObservation {
  final String text;
  final int row;
  final int column;
  final double confidence;

  const OcrObservation({
    required this.text,
    required this.row,
    required this.column,
    required this.confidence,
  });
}

abstract interface class OcrPort {
  Future<List<OcrObservation>> recognize(String imagePath);
}
