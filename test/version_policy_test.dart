import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pubspec and public version metadata stay consistent', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final versionMatch =
        RegExp(r'^version:\s*(\d+\.\d+\.\d+)\+(\d+)', multiLine: true)
            .firstMatch(pubspec);
    expect(versionMatch, isNotNull);

    final metadata = jsonDecode(File('version.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(metadata['latest'], versionMatch!.group(1));
    expect(metadata['apk_url'], contains('v${versionMatch.group(1)}'));
  });
}
