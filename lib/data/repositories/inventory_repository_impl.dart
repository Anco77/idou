import '../../core/database/daos/inventory_dao.dart';
import '../../domain/repositories/inventory_repository.dart';

/// 库存仓库实现
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryDao _dao;

  InventoryRepositoryImpl(this._dao);

  @override
  Future<List<InventoryWithColor>> getAllInventory() {
    return _dao.getAllInventory();
  }

  @override
  Future<InventoryWithColor?> getInventory(int colorId) {
    return _dao.getInventory(colorId);
  }

  @override
  Future<bool> consume(int colorId, int quantity, {String? patternId}) async {
    final inv = await _dao.getInventory(colorId);
    if (inv == null || inv.currentQty < quantity) return false;

    final newQty = inv.currentQty - quantity;
    await _dao.updateQuantity(colorId, newQty);
    await _dao.addLog(
      colorId: colorId,
      changeType: 'consume',
      quantity: -quantity,
      resultQty: newQty,
      patternId: patternId,
    );
    return true;
  }

  @override
  Future<bool> restock(int colorId, int quantity) async {
    final inv = await _dao.getInventory(colorId);
    final currentQty = inv?.currentQty ?? 0;
    final newQty = currentQty + quantity;

    await _dao.updateQuantity(colorId, newQty);
    await _dao.addLog(
      colorId: colorId,
      changeType: 'restock',
      quantity: quantity,
      resultQty: newQty,
    );
    return true;
  }

  @override
  Future<DeductResult> batchDeduct(Map<int, int> consumptions, {String? patternId}) async {
    final insufficient = <InsufficientColor>[];

    // 预检：检查所有色号是否充足
    for (final entry in consumptions.entries) {
      final inv = await _dao.getInventory(entry.key);
      final available = inv?.currentQty ?? 0;
      if (available < entry.value) {
        insufficient.add(InsufficientColor(
          colorId: entry.key,
          colorName: inv?.colorName ?? '未知',
          required: entry.value,
          available: available,
        ));
      }
    }

    if (insufficient.isNotEmpty) {
      return DeductResult(success: false, insufficientColors: insufficient);
    }

    // 执行批量扣除
    final logs = <Map<String, dynamic>>[];
    for (final entry in consumptions.entries) {
      final inv = await _dao.getInventory(entry.key);
      final newQty = inv!.currentQty - entry.value;
      await _dao.updateQuantity(entry.key, newQty);
      logs.add({
        'color_id': entry.key,
        'change_type': 'deduct_pattern',
        'quantity': -entry.value,
        'result_qty': newQty,
        'pattern_id': patternId,
      });
    }
    await _dao.addLogs(logs);

    return DeductResult(success: true, deductedCount: consumptions.length);
  }

  @override
  Future<void> initializeInventory({int defaultQty = 1200}) async {
    // 获取所有色号
    // 先获取色号列表
    final rows = await _dao.db.customSelect(
      'SELECT color_id FROM color_standards ORDER BY color_id'
    ).get();

    // 清空库存和日志
    await _dao.db.customUpdate('DELETE FROM inventory');
    await _dao.db.customUpdate('DELETE FROM inventory_logs');

    // 批量写入
    final now = DateTime.now().toIso8601String();
    await _dao.db.batch((batch) {
      for (final row in rows) {
        final colorId = row.data['color_id'] as int;
        batch.customStatement(
          'INSERT INTO inventory (color_id, current_qty, updated_at) VALUES (?, ?, ?)',
          [colorId, defaultQty, now],
        );
        batch.customStatement(
          'INSERT INTO inventory_logs (color_id, change_type, quantity, result_qty, created_at) VALUES (?, ?, ?, ?, ?)',
          [colorId, 'init', defaultQty, defaultQty, now],
        );
      }
    });
  }

  @override
  Future<void> clearAllData() async {
    await _dao.db.customUpdate('DELETE FROM inventory');
    await _dao.db.customUpdate('DELETE FROM inventory_logs');
  }

  @override
  Future<void> setQty(int colorId, int quantity) async {
    final inv = await _dao.getInventory(colorId);
    final oldQty = inv?.currentQty ?? 0;
    await _dao.updateQuantity(colorId, quantity);
    await _dao.addLog(
      colorId: colorId,
      changeType: 'set',
      quantity: quantity - oldQty,
      resultQty: quantity,
    );
  }

  @override
  Future<List<OperationLogItem>> getAllLogs({String? changeType, int limit = 200, int offset = 0}) {
    return _dao.getAllLogs(changeType: changeType, limit: limit, offset: offset);
  }

  @override
  Future<List<InventoryLogItem>> getLogsForColor(int colorId, {int limit = 50}) {
    return _dao.getLogsForColor(colorId, limit: limit);
  }

  @override
  Future<List<InventoryWithColor>> getLowStockColors({int threshold = 500}) {
    return _dao.getLowStockColors(threshold: threshold);
  }
}
