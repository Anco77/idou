import '../../domain/ports/asset_store.dart';

class PersistedAssets {
  final String original;
  final String? preview;
  final List<String> completionPhotos;

  const PersistedAssets({
    required this.original,
    this.preview,
    this.completionPhotos = const [],
  });

  List<String> get all => [
        original,
        if (preview != null) preview!,
        ...completionPhotos,
      ];
}

class PersistAssets {
  final AssetStore _store;

  const PersistAssets(this._store);

  Future<PersistedAssets> call({
    required String assetId,
    required String originalPath,
    String? previewPath,
    List<String> completionPhotoPaths = const [],
    Future<void> Function(PersistedAssets assets)? commit,
  }) async {
    final created = <String>[];
    try {
      final original = await _persist(
        originalPath,
        assetId: '$assetId/original',
        created: created,
      );
      String? preview;
      if (previewPath != null) {
        preview = await _persist(
          previewPath,
          assetId: '$assetId/preview',
          created: created,
        );
      }
      final completionPhotos = <String>[];
      for (var index = 0; index < completionPhotoPaths.length; index++) {
        completionPhotos.add(
          await _persist(
            completionPhotoPaths[index],
            assetId: '$assetId/completion-$index',
            created: created,
          ),
        );
      }
      final assets = PersistedAssets(
        original: original,
        preview: preview,
        completionPhotos: completionPhotos,
      );
      if (commit != null) {
        await commit(assets);
      }
      return assets;
    } catch (_) {
      await _cleanup(created);
      rethrow;
    }
  }

  Future<String> _persist(
    String sourcePath, {
    required String assetId,
    required List<String> created,
  }) async {
    final path = await _store.persist(sourcePath, assetId: assetId);
    created.add(path);
    return path;
  }

  Future<void> _cleanup(Iterable<String> paths) async {
    for (final path in paths) {
      try {
        await _store.delete(path);
      } catch (_) {
        // AssetStore implementations persist failed cleanup for retry.
      }
    }
    await _store.retryPendingCleanup();
  }
}
