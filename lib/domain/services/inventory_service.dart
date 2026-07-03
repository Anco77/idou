import '../../core/database/daos/inventory_dao.dart';
import '../repositories/inventory_repository.dart';

/// 库存领域服务
class InventoryService {
  final InventoryRepository _repository;

  InventoryService(this._repository);

  /// 获取所有库存
  Future<List<InventoryWithColor>> getAllInventory() {
    return _repository.getAllInventory();
  }

  /// 获取单个色号
  Future<InventoryWithColor?> getInventory(int colorId) {
    return _repository.getInventory(colorId);
  }

  /// 消耗
  Future<bool> consume(int colorId, int quantity, {String? patternId}) {
    return _repository.consume(colorId, quantity, patternId: patternId);
  }

  /// 补货
  Future<bool> restock(int colorId, int quantity) {
    return _repository.restock(colorId, quantity);
  }

  /// 批量扣除（图纸用）
  Future<DeductResult> batchDeduct(Map<int, int> consumptions, {String? patternId}) {
    return _repository.batchDeduct(consumptions, patternId: patternId);
  }

  /// 初始化
  Future<void> initializeInventory({int defaultQty = 1200}) {
    return _repository.initializeInventory(defaultQty: defaultQty);
  }

  /// 设置单个色号数量
  Future<void> setQty(int colorId, int quantity) {
    return _repository.setQty(colorId, quantity);
  }

  /// 获取历史
  Future<List<InventoryLogItem>> getLogsForColor(int colorId, {int limit = 50}) {
    return _repository.getLogsForColor(colorId, limit: limit);
  }

  /// 获取低量色号
  Future<List<InventoryWithColor>> getLowStockColors({int threshold = 500}) {
    return _repository.getLowStockColors(threshold: threshold);
  }
}
