import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/services/ocr_service.dart';

void main() {
  test('maps hOCR center to a half-open grid cell and normalizes text', () {
    const hocr =
        '''<span class="ocrx_word" title="bbox 20 20 60 60; x_wconf 92">bO7</span>''';

    final result = OcrService().parseHocr(
      hocr,
      cropW: 100,
      cropH: 100,
      gridCols: 2,
      gridRows: 2,
    );

    expect(result, hasLength(1));
    expect(result.single.col, 0);
    expect(result.single.row, 0);
    expect(result.single.mardId, 'B7');
    expect(result.single.x1, 20);
    expect(result.single.confidence, closeTo(.92, .001));
  });

  test('ignores unsupported colour ids and out-of-range numbers', () {
    const hocr = '''
      <span class='ocrx_word' title='bbox 120 20 160 60'>A100</span>
      <span class='ocrx_word' title='bbox 20 20 60 60'>Z12</span>
    ''';

    expect(
      OcrService().parseHocr(
        hocr,
        cropW: 100,
        cropH: 100,
        gridCols: 2,
        gridRows: 2,
      ),
      isEmpty,
    );
  });
}
