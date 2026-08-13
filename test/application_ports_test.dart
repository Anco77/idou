import 'package:flutter_test/flutter_test.dart';
import 'package:idou/application/common/get_current_time.dart';
import 'package:idou/application/patterns/load_patterns.dart';
import 'package:idou/domain/models/pattern_summary.dart';
import 'package:idou/domain/ports/asset_store.dart';
import 'package:idou/domain/ports/clock.dart';
import 'package:idou/domain/ports/ocr_port.dart';
import 'package:idou/domain/ports/pattern_reader.dart';

void main() {
  test('LoadPatterns uses a replaceable reader port', () async {
    final reader = _FakePatternReader([
      PatternSummary(
        id: 'p-1',
        title: '示例图纸',
        originalImage: '/tmp/p-1.png',
        uploadTime: DateTime(2026, 8, 12),
        status: 'draft',
        source: 'recognition',
      ),
    ]);

    final result = await LoadPatterns(reader).call(limit: 3);

    expect(result.single.title, '示例图纸');
    expect(reader.lastLimit, 3);
  });

  test('Clock, AssetStore and OcrPort are replaceable contracts', () async {
    final clock = _FakeClock(DateTime(2026, 8, 12, 9));
    expect(GetCurrentTime(clock)(), DateTime(2026, 8, 12, 9));

    final assets = _FakeAssetStore();
    expect(await assets.persist('/input.png', assetId: 'asset-1'), 'asset-1');

    final ocr = _FakeOcrPort();
    final observations = await ocr.recognize('/input.png');
    expect(observations.single.text, 'A01');
  });
}

class _FakePatternReader implements PatternReader {
  _FakePatternReader(this.items);
  final List<PatternSummary> items;
  int? lastLimit;

  @override
  Future<List<PatternSummary>> list({int limit = 100, int offset = 0}) async {
    lastLimit = limit;
    return items;
  }
}

class _FakeClock implements Clock {
  _FakeClock(this.value);
  final DateTime value;

  @override
  DateTime now() => value;
}

class _FakeAssetStore implements AssetStore {
  @override
  Future<void> delete(String path) async {}

  @override
  Future<void> retryPendingCleanup() async {}

  @override
  Future<String> persist(String sourcePath, {required String assetId}) async =>
      assetId;
}

class _FakeOcrPort implements OcrPort {
  @override
  Future<List<OcrObservation>> recognize(String imagePath) async => [
        const OcrObservation(text: 'A01', row: 0, column: 0, confidence: 1),
      ];
}
