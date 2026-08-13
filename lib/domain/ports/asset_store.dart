abstract interface class AssetStore {
  Future<String> persist(String sourcePath, {required String assetId});

  Future<void> delete(String path);

  Future<void> retryPendingCleanup();
}
