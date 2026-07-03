import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
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

enum UpdateStatus {
  idle,
  checking,
  available,
  downloading,
  downloaded,
  error,
}

class AppUpdateService {
  static const _githubOwner = 'your-username';
  static const _githubRepo = 'idou';

  String? _currentVersion;
  UpdateInfo? _updateInfo;
  UpdateStatus _status = UpdateStatus.idle;
  double _downloadProgress = 0;

  UpdateStatus get status => _status;
  double get downloadProgress => _downloadProgress;
  UpdateInfo? get updateInfo => _updateInfo;

  Future<String> getCurrentVersion() async {
    if (_currentVersion != null) return _currentVersion!;
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;
    return _currentVersion!;
  }

  Future<UpdateInfo?> checkForUpdate() async {
    _status = UpdateStatus.checking;
    await getCurrentVersion();

    try {
      final url = Uri.parse(
        'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest',
      );
      final response = await http.get(
        url,
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _status = UpdateStatus.idle;
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      final assets = data['assets'] as List<dynamic>? ?? [];
      final exeAsset = assets.cast<Map<String, dynamic>>().firstWhere(
        (a) => (a['name'] as String).endsWith('.exe'),
        orElse: () => <String, dynamic>{},
      );

      if (exeAsset.isEmpty) {
        _status = UpdateStatus.idle;
        return null;
      }

      final remoteInfo = UpdateInfo(
        version: version,
        url: exeAsset['browser_download_url'] as String,
        releaseNotes: data['body'] as String? ?? '',
      );

      if (_isNewerVersion(remoteInfo.version)) {
        _updateInfo = remoteInfo;
        _status = UpdateStatus.available;
        return remoteInfo;
      }

      _status = UpdateStatus.idle;
      return null;
    } catch (_) {
      _status = UpdateStatus.idle;
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

    _status = UpdateStatus.downloading;
    _downloadProgress = 0;

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = _updateInfo!.url.split('/').last;
      final filePath = '${tempDir.path}\\$fileName';
      final file = File(filePath);

      final response = await http.Client().send(
        http.Request('GET', Uri.parse(_updateInfo!.url)),
      );

      if (response.statusCode != 200) {
        _status = UpdateStatus.error;
        return null;
      }

      final totalBytes = response.contentLength ?? 0;
      var receivedBytes = 0;
      final sink = file.openWrite(mode: FileMode.write);

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        if (totalBytes > 0) {
          _downloadProgress = receivedBytes / totalBytes;
          onProgress(_downloadProgress);
        }
      }

      await sink.close();
      _status = UpdateStatus.downloaded;
      return filePath;
    } catch (_) {
      _status = UpdateStatus.error;
      return null;
    }
  }

  Future<void> installUpdate(String installerPath) async {
    await Process.run(installerPath, ['/S']);
    exit(0);
  }

  void reset() {
    _status = UpdateStatus.idle;
    _downloadProgress = 0;
    _updateInfo = null;
  }
}
