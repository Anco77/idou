import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/bootstrap/application_providers.dart';
import '../../application/patterns/load_patterns.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/patterns_dao.dart';
import '../../data/repositories/patterns_repository_impl.dart';
import '../../domain/models/pattern_summary.dart';
import '../../domain/repositories/patterns_repository.dart';
import '../../domain/services/inventory_service.dart';
import 'inventory_providers.dart';

final patternsDaoProvider = Provider<PatternsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return PatternsDao(db);
});

final patternsRepositoryProvider = Provider<PatternsRepository>((ref) {
  final dao = ref.watch(patternsDaoProvider);
  return PatternsRepositoryImpl(dao);
});

class PatternsState {
  final List<PatternItem> patterns;
  final bool isLoading;
  final String? error;

  const PatternsState({
    this.patterns = const [],
    this.isLoading = false,
    this.error = null,
  });

  PatternsState copyWith({
    List<PatternItem>? patterns,
    bool? isLoading,
    String? error,
  }) =>
      PatternsState(
        patterns: patterns ?? this.patterns,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

final patternsStateProvider =
    StateNotifierProvider<PatternsStateNotifier, PatternsState>((ref) {
  final repo = ref.watch(patternsRepositoryProvider);
  return PatternsStateNotifier(repo);
});

class PatternsStateNotifier extends StateNotifier<PatternsState> {
  final PatternsRepository _repository;

  PatternsStateNotifier(this._repository) : super(const PatternsState()) {
    loadPatterns();
  }

  Future<void> loadPatterns() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final patterns = await _repository.getAllPatterns();
      state = state.copyWith(patterns: patterns, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> savePattern({
    required PatternItem pattern,
    required List<PatternConsumptionItem> consumptions,
  }) async {
    await _repository.savePattern(pattern: pattern, consumptions: consumptions);
    await loadPatterns();
  }

  Future<void> deletePattern(String patternId) async {
    await _repository.deletePattern(patternId);
    await loadPatterns();
  }

  Future<void> updateTitle(String patternId, String title) async {
    await _repository.updateTitle(patternId, title);
    await loadPatterns();
  }
}

/// 首页仪表盘数据
class HomeState {
  final int totalColors;
  final int lowStockCount;
  final int totalBeads;
  final List<PatternSummary> recentPatterns;
  final bool isLoading;

  const HomeState({
    this.totalColors = 221,
    this.lowStockCount = 0,
    this.totalBeads = 0,
    this.recentPatterns = const [],
    this.isLoading = false,
  });

  HomeState copyWith({
    int? totalColors,
    int? lowStockCount,
    int? totalBeads,
    List<PatternSummary>? recentPatterns,
    bool? isLoading,
  }) =>
      HomeState(
        totalColors: totalColors ?? this.totalColors,
        lowStockCount: lowStockCount ?? this.lowStockCount,
        totalBeads: totalBeads ?? this.totalBeads,
        recentPatterns: recentPatterns ?? this.recentPatterns,
        isLoading: isLoading ?? this.isLoading,
      );
}

final homeStateProvider =
    StateNotifierProvider<HomeStateNotifier, HomeState>((ref) {
  final inventoryService = ref.watch(inventoryServiceProvider);
  final loadPatterns = ref.watch(loadPatternsProvider);
  return HomeStateNotifier(inventoryService, loadPatterns);
});

class HomeStateNotifier extends StateNotifier<HomeState> {
  final InventoryService _inventoryService;
  final LoadPatterns _loadPatterns;

  HomeStateNotifier(this._inventoryService, this._loadPatterns)
      : super(const HomeState()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true);
    try {
      final lowStock = await _inventoryService.getLowStockColors();
      final all = await _inventoryService.getAllInventory();
      final totalBeads = all.fold<int>(0, (sum, item) => sum + item.currentQty);
      final recent = await _loadPatterns(limit: 3);

      state = state.copyWith(
        lowStockCount: lowStock.length,
        totalBeads: totalBeads,
        recentPatterns: recent,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}
