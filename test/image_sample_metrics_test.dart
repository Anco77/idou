import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:idou/test_support/image_samples.dart';

void main() {
  test('sample manifest validates required ground truth fields', () {
    final manifest = ImageSampleManifest.standard;
    expect(manifest, isNotEmpty);
    for (final sample in manifest) {
      expect(sample.source, isNotEmpty);
      expect(sample.rows, greaterThan(0));
      expect(sample.columns, greaterThan(0));
      expect(sample.occupancy.length, sample.rows * sample.columns);
      expect(sample.colorIds.length, sample.rows * sample.columns);
    }
  });

  test('deterministic regression report compares occupancy and colours', () {
    final sample = ImageSampleManifest.standard.first;
    final report = ImageMetricRunner.compare(
      sample,
      occupancy: sample.occupancy,
      colorIds: sample.colorIds,
    );
    expect(report.gridExact, isTrue);
    expect(report.occupancyAccuracy, 1);
    expect(report.colorAccuracy, 1);
    final encoded = jsonEncode({
      'sample': sample.toJson(),
      'metrics': report.toJson(),
    });
    final decoded = jsonDecode(encoded) as Map<String, dynamic>;
    expect(decoded['sample']['id'], sample.id);
    expect(decoded['metrics']['gridExact'], isTrue);
  });
}
