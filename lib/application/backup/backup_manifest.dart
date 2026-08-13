import 'dart:convert';

class BackupManifest {
  final int schemaVersion;
  final List<String> assets;

  const BackupManifest({required this.schemaVersion, required this.assets});

  Map<String, Object?> toJson() => {
        'schemaVersion': schemaVersion,
        'assets': assets,
      };

  String encode() => jsonEncode(toJson());
}
