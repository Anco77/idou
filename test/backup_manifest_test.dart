import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:idou/application/backup/backup_manifest.dart';

void main() {
  test('backup manifest is versioned and round-trippable', () {
    const manifest = BackupManifest(schemaVersion: 3, assets: ['source/a.png']);
    final decoded = jsonDecode(manifest.encode()) as Map<String, dynamic>;
    expect(decoded['schemaVersion'], 3);
    expect(decoded['assets'], ['source/a.png']);
  });
}
