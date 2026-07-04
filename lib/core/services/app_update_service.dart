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

  Map<String, dynamic> toJson() => {
        'version': version,
        'url': url,
        'releaseNotes': releaseNotes,
      };

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        version: json['version'] as String,
        url: json['url'] as String,
        releaseNotes: json['releaseNotes'] as String? ?? '',
      );
}

sealed class UpdateCheckResult {
  const UpdateCheckResult();
}

class UpdateAvailable extends UpdateCheckResult {
  final UpdateInfo info;
  const UpdateAvailable(this.info);
}

class NoUpdate extends UpdateCheckResult {
  final String latestVersion;
  const NoUpdate(this.latestVersion);
}

class CheckFailed extends UpdateCheckResult {
  final String message;
  const CheckFailed(this.message);
}

class AppUpdateService {
  static const _githubOwner = 'Anco77';
  static const _githubRepo = 'idou';
  static const _cacheFileName = 'update_cache.json';

  String? _currentVersion;

  Future<String> getCurrentVersion() async {
    if (_currentVersion != null) return _currentVersion!;
    final info = await PackageInfo.fromPlatform();
    _currentVersion = info.version;
    return _currentVersion!;
  }

  String get _targetExtension => Platform.isAndroid ? '.apk' : '.exe';
  String get _platformName => Platform.isAndroid ? 'android' : 'windows';

  Future<UpdateCheckResult> checkForUpdate() async {
    await getCurrentVersion();

    // Try GitHub API
    final result = await _checkApi();
    if (result case UpdateAvailable(:final info)) {
      await _cacheUpdateInfo(info);
      return result;
    }

    // Try fallback: raw.githubusercontent.com version.json
    if (result is CheckFailed) {
      final fallback = await _checkFallback();
      if (fallback case UpdateAvailable(:final info)) {
        await _cacheUpdateInfo(info);
        return fallback;
      }
    }

    // All remotes failed — try local cache
    final cached = await _readCachedUpdateInfo();
    if (cached != null && _isNewerVersion(cached.version)) {
      return UpdateAvailable(cached);
    }

    return result;
  }

  Future<UpdateCheckResult> _checkApi() async {
    try {
      final url = Uri.parse(
        'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest',
      );
      final response = await http
          .get(url, headers: {'Accept': 'application/vnd.github.v3+json'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 403) {
        return const CheckFailed('API 访问受限');
      }
      if (response.statusCode != 200) {
        return CheckFailed('服务器响应异常 (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      final assets = data['assets'] as List<dynamic>? ?? [];
      final matchedAsset = assets.cast<Map<String, dynamic>>().firstWhere(
            (a) => (a['name'] as String).endsWith(_targetExtension),
            orElse: () => <String, dynamic>{},
          );

      if (matchedAsset.isEmpty) return const CheckFailed('未找到安装包');

      final remoteInfo = UpdateInfo(
        version: version,
        url: matchedAsset['browser_download_url'] as String,
        releaseNotes: data['body'] as String? ?? '',
      );

      if (_isNewerVersion(remoteInfo.version)) return UpdateAvailable(remoteInfo);
      return NoUpdate(remoteInfo.version);
    } catch (_) {
      // Retry once
      try {
        final url = Uri.parse(
          'https://api.github.com/repos/$_githubOwner/$_githubRepo/releases/latest',
        );
        final response = await http
            .get(url, headers: {'Accept': 'application/vnd.github.v3+json'})
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          return const CheckFailed('网络连接失败');
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final tagName = data['tag_name'] as String? ?? '';
        final version = tagName.startsWith('v') ? tagName.substring(1) : tagName;

        final assets = data['assets'] as List<dynamic>? ?? [];
        final matchedAsset = assets.cast<Map<String, dynamic>>().firstWhere(
              (a) => (a['name'] as String).endsWith(_targetExtension),
              orElse: () => <String, dynamic>{},
            );

        if (matchedAsset.isEmpty) return const CheckFailed('未找到安装包');

        final remoteInfo = UpdateInfo(
          version: version,
          url: matchedAsset['browser_download_url'] as String,
          releaseNotes: data['body'] as String? ?? '',
        );

        if (_isNewerVersion(remoteInfo.version)) return UpdateAvailable(remoteInfo);
        return NoUpdate(remoteInfo.version);
      } catch (_) {
        return const CheckFailed('网络连接失败');
      }
    }
  }

  Future<UpdateCheckResult> _checkFallback() async {
    try {
      final url = Uri.parse(
        'https://raw.githubusercontent.com/$_githubOwner/$_githubRepo/main/version.json',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return const CheckFailed('网络连接失败');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final version = data['latest'] as String? ?? '';

      final apkUrl = data['apk_url'] as String? ?? '';
      final exeUrl = data['exe_url'] as String? ?? '';
      final downloadUrl = Platform.isAndroid ? apkUrl : exeUrl;

      if (version.isEmpty || downloadUrl.isEmpty) {
        return const CheckFailed('更新信息不完整');
      }

      final remoteInfo = UpdateInfo(
        version: version,
        url: downloadUrl,
        releaseNotes: data['notes'] as String? ?? '',
      );

      if (_isNewerVersion(remoteInfo.version)) return UpdateAvailable(remoteInfo);
      return NoUpdate(remoteInfo.version);
    } catch (_) {
      return const CheckFailed('网络连接失败');
    }
  }

  Future<void> _cacheUpdateInfo(UpdateInfo info) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, _cacheFileName));
      await file.writeAsString(jsonEncode(info.toJson()));
    } catch (_) {}
  }

  Future<UpdateInfo?> _readCachedUpdateInfo() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, _cacheFileName));
      if (!file.existsSync()) return null;
      final content = await file.readAsString();
      return UpdateInfo.fromJson(jsonDecode(content) as Map<String, dynamic>);
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
    final cached = await _readCachedUpdateInfo();
    if (cached == null) return null;

    try {
      final dir = await getTemporaryDirectory();
      final fileName = 'idou-$_platformName-v${cached.version}$_targetExtension';
      final filePath = p.join(dir.path, fileName);
      final file = File(filePath);

      final response = await http.Client().send(
        http.Request('GET', Uri.parse(cached.url)),
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
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
