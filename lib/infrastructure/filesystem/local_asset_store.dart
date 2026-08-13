import 'dart:io';

import '../../domain/ports/asset_store.dart';

/// Controlled application asset storage.
///
/// The application layer only sees [AssetStore]; path policy stays here.
class LocalAssetStore implements AssetStore {
  final Directory root;
  final File? cleanupQueueFile;

  const LocalAssetStore(this.root, {this.cleanupQueueFile});

  @override
  Future<String> persist(String sourcePath, {required String assetId}) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('源资源不存在', sourcePath);
    }
    final relative = assetId.replaceAll('\\', '/');
    if (relative.startsWith('/') || relative.split('/').contains('..')) {
      throw ArgumentError.value(assetId, 'assetId', '资源 id 不得越界');
    }
    final target = File('${root.path}${Platform.pathSeparator}$relative');
    await target.parent.create(recursive: true);
    final temporary =
        File('${target.path}.tmp-${DateTime.now().microsecondsSinceEpoch}');
    await source.copy(temporary.path);
    await temporary.rename(target.path);
    return target.path;
  }

  @override
  Future<void> delete(String path) async {
    final target = File(path);
    if (await target.exists()) {
      try {
        await target.delete();
      } catch (_) {
        if (cleanupQueueFile == null) rethrow;
        await cleanupQueueFile!.parent.create(recursive: true);
        await cleanupQueueFile!.writeAsString(
          '${cleanupQueueFile!.existsSync() ? cleanupQueueFile!.readAsStringSync() : ''}$path\n',
          flush: true,
        );
      }
    }
  }

  @override
  Future<void> retryPendingCleanup() async {
    final queue = cleanupQueueFile;
    if (queue == null || !await queue.exists()) return;
    final pending = await queue.readAsLines();
    final failed = <String>[];
    for (final path in pending.where((item) => item.isNotEmpty)) {
      try {
        await delete(path);
      } catch (_) {
        failed.add(path);
      }
    }
    if (failed.isEmpty) {
      await queue.delete();
    } else {
      await queue.writeAsString('${failed.join('\n')}\n', flush: true);
    }
  }
}
