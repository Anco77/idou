import '../../core/database/daos/inventory_dao.dart';

enum InventoryReason { restock, consume, patternDeduct, set, reversal, init }

extension InventoryReasonValue on InventoryReason {
  String get value => switch (this) {
        InventoryReason.restock => 'restock',
        InventoryReason.consume => 'consume',
        InventoryReason.patternDeduct => 'deduct_pattern',
        InventoryReason.set => 'set',
        InventoryReason.reversal => 'reversal',
        InventoryReason.init => 'init',
      };
}

/// 库存仓库接口
abstract class InventoryRepository {
  /// 获取所有库存（含色号信息）
  Future<List<InventoryWithColor>> getAllInventory();

  /// 获取单个色号库存
  Future<InventoryWithColor?> getInventory(int colorId);

  /// 消耗指定色号
  Future<bool> consume(int colorId, int quantity, {String? patternId});

  /// 补货指定色号
  Future<bool> restock(int colorId, int quantity);

  Future<BatchAdjustResult> batchAdjust(
    Map<int, int> quantities, {
    required bool restock,
  });

  Future<bool> reverseLog(int logId);

  /// 批量扣除（用于图纸确认）
  Future<DeductResult> batchDeduct(Map<int, int> consumptions,
      {String? patternId});

  /// 一键初始化库存
  Future<void> initializeInventory({int defaultQty = 1200});

  /// 清空所有库存数据和操作记录
  Future<void> clearAllData();

  /// 设置单个色号库存数量
  Future<void> setQty(int colorId, int quantity);

  /// 获取色号变更历史
  Future<List<InventoryLogItem>> getLogsForColor(int colorId, {int limit = 50});

  /// 获取全局操作日志
  Future<List<OperationLogItem>> getAllLogs(
      {String? changeType,
      int? colorId,
      DateTime? from,
      DateTime? to,
      int limit = 200,
      int offset = 0});

  /// 获取所有低量色号
  Future<List<InventoryWithColor>> getLowStockColors({int threshold = 500});
}

class BatchAdjustResult {
  final bool success;
  final List<InsufficientColor> insufficientColors;
  final int adjustedCount;

  const BatchAdjustResult({
    required this.success,
    this.insufficientColors = const [],
    this.adjustedCount = 0,
  });
}

/// 批量扣除结果
class DeductResult {
  final bool success;
  final List<InsufficientColor> insufficientColors;
  final int deductedCount;

  const DeductResult({
    required this.success,
    this.insufficientColors = const [],
    this.deductedCount = 0,
  });
}

class InsufficientColor {
  final int colorId;
  final String colorName;
  final int required;
  final int available;

  const InsufficientColor({
    required this.colorId,
    required this.colorName,
    required this.required,
    required this.available,
  });
}
