import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  final String version;
  final String url;
  final String releaseNotes;

  const UpdateInfo({
    required this.version,
    required this.url,
    required this.releaseNotes,
  });
}

class AppUpdateService {
  static const _githubOwner = 'Anco77';
  static const _githubRepo = 'idou';

  String? _currentVersion;
  UpdateInfo? _updateInfo;

  Future<String> getCurrentVersion() async {
    if (_currentVersion != null) return _currentVersion!;
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;
    return _currentVersion!;
  }

  String get _targetExtension => Platform.isAndroid ? '.apk' : '.exe';

  Future<UpdateInfo?> checkForUpdate() async {
    await getCurrentVersion();

    try {
      final url = Uri.parse(
        'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest',
      );
      final response = await http.get(
        url,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      final assets = data['assets'] as List<dynamic>? ?? [];
      final matchedAsset = assets.cast<Map<String, dynamic>>().firstWhere(
        (a) => (a['name'] as String).endsWith(_targetExtension),
        orElse: () => <String, dynamic>{},
      );

      if (matchedAsset.isEmpty) return null;

      final remoteInfo = UpdateInfo(
        version: version,
        url: matchedAsset['browser_download_url'] as String,
        releaseNotes: data['body'] as String? ?? '',
      );

      if (_isNewerVersion(remoteInfo.version)) {
        _updateInfo = remoteInfo;
        return remoteInfo;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  bool _isNewerVersion(String remoteVersion) {
    try {
      final local = _currentVersion!.split('.').map(int.parse).toList();
      final remote = remoteVersion.split('.').map(int.parse).toList();
      for (int i = 0; i < remote.length; i++) {
        final rv = remote[i];
        final lv = i < local.length ? local[i] : 0;
        if (rv > lv) return true;
        if (rv < lv) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<String?> downloadUpdate(void Function(double) onProgress) async {
    if (_updateInfo == null) return null;

    try {
      final dir = await getTemporaryDirectory();
      final fileName = _updateInfo!.url.split('/').last;
      final filePath = p.join(dir.path, fileName);
      final file = File(filePath);

      final response = await http.Client().send(
        http.Request('GET', Uri.parse(_updateInfo!.url)),
      );

      if (response.statusCode != 200) return null;

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;
      final sink = file.openWrite(mode: FileMode.write);

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          onProgress(receivedBytes / totalBytes);
        }
      }

      await sink.close();
      return filePath;
    } catch (_) {
      return null;
    }
  }

  Future<bool> installUpdate(String installerPath) async {
    try {
      if (Platform.isAndroid) {
        final result = await OpenFilex.open(installerPath);
        return result.type == ResultType.done;
      } else {
        await Process.run(installerPath, ['/S']);
        exit(0);
      }
    } catch (_) {
      return false;
    }
  }
}
