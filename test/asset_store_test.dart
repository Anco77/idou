import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:idou/application/assets/persist_assets.dart';
import 'package:idou/domain/ports/asset_store.dart';
import 'package:idou/infrastructure/filesystem/local_asset_store.dart';

void main() {
  late Directory temp;
  late File source;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('idou-assets-');
    source = File('${temp.path}/picked-cache.png')..writeAsStringSync('image');
  });

  tearDown(() => temp.delete(recursive: true));

  test('persists through a temp file and never returns picker cache path',
      () async {
    final root = Directory('${temp.path}/controlled');
    final store = LocalAssetStore(root);

    final persisted = await PersistAssets(store)(
      assetId: 'pattern-1',
      originalPath: source.path,
    );

    expect(persisted.original, isNot(source.path));
    expect(persisted.original, startsWith(root.path));
    expect(await File(persisted.original).readAsString(), 'image');
    expect(File('${persisted.original}.tmp').existsSync(), isFalse);
  });

  test('rejects path traversal before writing outside controlled root',
      () async {
    final root = Directory('${temp.path}/controlled');
    final store = LocalAssetStore(root);

    expect(
      () => store.persist(source.path, assetId: '../escape'),
      throwsArgumentError,
    );
    expect(File('${temp.parent.path}/escape').existsSync(), isFalse);
  });

  test('compensates already persisted assets when a later asset fails',
      () async {
    final root = Directory('${temp.path}/controlled');
    final store = _FailingAssetStore(LocalAssetStore(root));

    await expectLater(
      PersistAssets(store)(
        assetId: 'pattern-2',
        originalPath: source.path,
        previewPath: '${temp.path}/missing-preview.png',
      ),
      throwsA(isA<FileSystemException>()),
    );
    expect(File('${root.path}/pattern-2/original').existsSync(), isFalse);
  });

  test('cleans assets when the persistence boundary fails', () async {
    final root = Directory('${temp.path}/controlled');
    final store = LocalAssetStore(root);

    await expectLater(
      PersistAssets(store)(
        assetId: 'pattern-3',
        originalPath: source.path,
        commit: (_) async => throw StateError('database failure'),
      ),
      throwsStateError,
    );
    expect(File('${root.path}/pattern-3/original').existsSync(), isFalse);
  });

  test('retries a cleanup that initially fails', () async {
    final store = _RetryingCleanupStore();
    await expectLater(
      PersistAssets(store)(
        assetId: 'pattern-4',
        originalPath: source.path,
        commit: (_) async => throw StateError('database failure'),
      ),
      throwsStateError,
    );
    expect(store.deleteAttempts, 2);
    expect(store.retryCalled, isTrue);
  });
}

class _FailingAssetStore implements AssetStore {
  _FailingAssetStore(this.delegate);
  final LocalAssetStore delegate;

  @override
  Future<String> persist(String sourcePath, {required String assetId}) {
    if (assetId.endsWith('preview')) {
      throw const FileSystemException('simulated database boundary failure');
    }
    return delegate.persist(sourcePath, assetId: assetId);
  }

  @override
  Future<void> delete(String path) => delegate.delete(path);

  @override
  Future<void> retryPendingCleanup() => delegate.retryPendingCleanup();
}

class _RetryingCleanupStore implements AssetStore {
  int deleteAttempts = 0;
  bool retryCalled = false;

  @override
  Future<String> persist(String sourcePath, {required String assetId}) async =>
      'controlled/$assetId';

  @override
  Future<void> delete(String path) async {
    deleteAttempts++;
    if (deleteAttempts == 1) {
      throw StateError('temporary cleanup failure');
    }
  }

  @override
  Future<void> retryPendingCleanup() async {
    retryCalled = true;
    await delete('controlled/pattern-4/original');
  }
}
