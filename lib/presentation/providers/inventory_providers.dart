import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/inventory_dao.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/services/inventory_service.dart';

/// DAO Provider
final inventoryDaoProvider = Provider<InventoryDao>((ref) {
  final db = ref.watch(databaseProvider);
  return InventoryDao(db);
});

/// Repository Provider
final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final dao = ref.watch(inventoryDaoProvider);
  return InventoryRepositoryImpl(dao);
});

/// Service Provider
final inventoryServiceProvider = Provider<InventoryService>((ref) {
  final repo = ref.watch(inventoryRepositoryProvider);
  return InventoryService(repo);
});

/// 库存排序方式
enum InventorySortMode {
  byColorId,     // 按色号
  byRemaining,   // 按余量
  byConsumption, // 按消耗量
}

/// 库存数据状态
class InventoryState {
  final List<InventoryWithColor> items;
  final List<InventoryWithColor> lowStockItems;
  final InventorySortMode sortMode;
  final bool ascending;
  final String searchQuery;
  final bool isLoading;
  final String? error;

  const InventoryState({
    this.items = const [],
    this.lowStockItems = const [],
    this.sortMode = InventorySortMode.byColorId,
    this.ascending = true,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
  });

  InventoryState copyWith({
    List<InventoryWithColor>? items,
    List<InventoryWithColor>? lowStockItems,
    InventorySortMode? sortMode,
    bool? ascending,
    String? searchQuery,
    bool? isLoading,
    String? error,
  }) => InventoryState(
    items: items ?? this.items,
    lowStockItems: lowStockItems ?? this.lowStockItems,
    sortMode: sortMode ?? this.sortMode,
    ascending: ascending ?? this.ascending,
    searchQuery: searchQuery ?? this.searchQuery,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  /// 获取排序后的过滤列表
  List<InventoryWithColor> get filteredItems {
    var result = List<InventoryWithColor>.from(items);

    // 搜索过滤
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result.where((item) =>
        item.colorName.toLowerCase().contains(query) ||
        item.colorId.toString().contains(query)
      ).toList();
    }

    // 排序
    switch (sortMode) {
      case InventorySortMode.byColorId:
        result.sort((a, b) => ascending
            ? a.colorId.compareTo(b.colorId)
            : b.colorId.compareTo(a.colorId));
        break;
      case InventorySortMode.byRemaining:
        result.sort((a, b) => ascending
            ? a.currentQty.compareTo(b.currentQty)
            : b.currentQty.compareTo(a.currentQty));
        break;
      case InventorySortMode.byConsumption:
        // 消耗量排序在UI层处理，这里默认按余量
        result.sort((a, b) => ascending
            ? a.currentQty.compareTo(b.currentQty)
            : b.currentQty.compareTo(a.currentQty));
        break;
    }

    return result;
  }

  /// 按系列分组
  Map<String, List<InventoryWithColor>> get groupedItems {
    final grouped = <String, List<InventoryWithColor>>{};
    for (final item in filteredItems) {
      grouped.putIfAbsent(item.series, () => []).add(item);
    }
    return grouped;
  }
}

/// 库存状态 Provider
final inventoryStateProvider =
    StateNotifierProvider<InventoryStateNotifier, InventoryState>((ref) {
  final service = ref.watch(inventoryServiceProvider);
  return InventoryStateNotifier(service);
});

class InventoryStateNotifier extends StateNotifier<InventoryState> {
  final InventoryService _service;

  InventoryStateNotifier(this._service) : super(const InventoryState()) {
    loadInventory();
  }

  /// 加载库存数据
  Future<void> loadInventory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _service.getAllInventory();
      final lowStock = await _service.getLowStockColors();
      state = state.copyWith(
        items: items,
        lowStockItems: lowStock,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// 切换排序方式
  void setSortMode(InventorySortMode mode) {
    if (state.sortMode == mode) {
      state = state.copyWith(ascending: !state.ascending);
    } else {
      state = state.copyWith(sortMode: mode, ascending: true);
    }
  }

  /// 搜索
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// 消耗，返回是否成功（库存不足时返回 false）
  Future<bool> consume(int colorId, int quantity) async {
    try {
      final success = await _service.consume(colorId, quantity);
      await loadInventory();
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 补货
  Future<void> restock(int colorId, int quantity) async {
    try {
      await _service.restock(colorId, quantity);
      await loadInventory();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// 初始化库存
  Future<void> initializeInventory({int defaultQty = 1200}) async {
    try {
      state = state.copyWith(isLoading: true);
      await _service.initializeInventory(defaultQty: defaultQty);
      await loadInventory();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

/// 获取指定色号的操作日志
final colorLogsProvider = FutureProvider.autoDispose.family<List<InventoryLogItem>, int>((ref, colorId) {
  final service = ref.watch(inventoryServiceProvider);
  return service.getLogsForColor(colorId, limit: 50);
});
