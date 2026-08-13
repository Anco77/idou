import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../application/patterns/load_patterns.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/patterns_dao.dart';
import '../../domain/ports/clock.dart';
import '../../domain/ports/asset_store.dart';
import '../../domain/ports/pattern_reader.dart';
import '../../infrastructure/common/system_clock.dart';
import '../../infrastructure/patterns/patterns_reader_adapter.dart';
import '../../infrastructure/filesystem/local_asset_store.dart';

final clockProvider = Provider<Clock>((ref) => const SystemClock());

final assetStoreProvider = FutureProvider<AssetStore>((ref) async {
  final root = await getApplicationSupportDirectory();
  final assetRoot = Directory(p.join(root.path, 'assets'));
  final cleanupQueue = File(p.join(root.path, 'asset-cleanup.queue'));
  return LocalAssetStore(assetRoot, cleanupQueueFile: cleanupQueue);
});

final patternReaderProvider = Provider<PatternReader>((ref) {
  final database = ref.watch(databaseProvider);
  return PatternsReaderAdapter(PatternsDao(database));
});

final loadPatternsProvider = Provider<LoadPatterns>(
  (ref) => LoadPatterns(ref.watch(patternReaderProvider)),
);
