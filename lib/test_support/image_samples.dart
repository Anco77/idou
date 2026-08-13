class ImageSample {
  final String id;
  final String source;
  final int rows;
  final int columns;
  final List<bool> occupancy;
  final List<int?> colorIds;
  final String inputClass;

  const ImageSample({
    required this.id,
    required this.source,
    required this.rows,
    required this.columns,
    required this.occupancy,
    required this.colorIds,
    required this.inputClass,
  });

  Map<String, Object?> toJson() => {
        'id': id,
        'source': source,
        'rows': rows,
        'columns': columns,
        'occupancy': occupancy,
        'colorIds': colorIds,
        'inputClass': inputClass,
      };
}

class ImageSampleManifest {
  static final standard = <ImageSample>[
    ImageSample(
      id: 'clean-29x29-blank-white',
      source: 'generated://idou/clean-grid-v1',
      rows: 29,
      columns: 29,
      occupancy: _cleanOccupancy(),
      colorIds: _cleanColors(),
      inputClass: 'clean_synthetic',
    ),
    ImageSample(
      id: 'disturbed-52x29',
      source: 'generated://idou/disturbed-grid-v1',
      rows: 29,
      columns: 52,
      occupancy: _disturbedOccupancy(),
      colorIds: _disturbedColors(),
      inputClass: 'disturbed_synthetic',
    ),
  ];

  static List<bool> _cleanOccupancy() {
    final values = List<bool>.filled(29 * 29, false);
    values[0] = true;
    values[2] = true;
    values[3] = true;
    return values;
  }

  static List<int?> _cleanColors() {
    final values = List<int?>.filled(29 * 29, null);
    values[0] = 3;
    values[2] = 2;
    values[3] = 1;
    return values;
  }

  static List<bool> _disturbedOccupancy() {
    final values = List<bool>.filled(29 * 52, false);
    values[0] = true;
    values[1] = true;
    values[3] = true;
    return values;
  }

  static List<int?> _disturbedColors() {
    final values = List<int?>.filled(29 * 52, null);
    values[0] = 7;
    values[1] = 8;
    values[3] = 9;
    return values;
  }
}

class ImageMetricReport {
  final bool gridExact;
  final double occupancyAccuracy;
  final double colorAccuracy;

  const ImageMetricReport({
    required this.gridExact,
    required this.occupancyAccuracy,
    required this.colorAccuracy,
  });

  Map<String, Object?> toJson() => {
        'gridExact': gridExact,
        'occupancyAccuracy': occupancyAccuracy,
        'colorAccuracy': colorAccuracy,
      };
}

class ImageMetricRunner {
  static ImageMetricReport compare(
    ImageSample sample, {
    required List<bool> occupancy,
    required List<int?> colorIds,
  }) {
    if (sample.occupancy.length != occupancy.length ||
        sample.colorIds.length != colorIds.length) {
      throw ArgumentError('样本预测长度不匹配');
    }
    var occupancyMatches = 0;
    var colorMatches = 0;
    var occupied = 0;
    for (var i = 0; i < occupancy.length; i++) {
      if (sample.occupancy[i] == occupancy[i]) occupancyMatches++;
      if (sample.occupancy[i]) {
        occupied++;
        if (sample.colorIds[i] == colorIds[i]) colorMatches++;
      }
    }
    return ImageMetricReport(
      gridExact: sample.rows * sample.columns == occupancy.length,
      occupancyAccuracy: occupancyMatches / occupancy.length,
      colorAccuracy: occupied == 0 ? 1 : colorMatches / occupied,
    );
  }
}
