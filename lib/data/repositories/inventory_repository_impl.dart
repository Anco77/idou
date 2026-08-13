import '../../core/database/daos/inventory_dao.dart';
import '../../domain/repositories/inventory_repository.dart';

class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryDao _dao;

  InventoryRepositoryImpl(this._dao);

  @override
  Future<List<InventoryWithColor>> getAllInventory() => _dao.getAllInventory();

  @override
  Future<InventoryWithColor?> getInventory(int colorId) =>
      _dao.getInventory(colorId);

  @override
  Future<bool> consume(int colorId, int quantity, {String? patternId}) {
    if (quantity <= 0) return Future.value(false);
    return _dao.applyMovementAtomic(
      colorId: colorId,
      delta: -quantity,
      changeType: InventoryReason.consume.value,
      patternId: patternId,
    );
  }

  @override
  Future<bool> restock(int colorId, int quantity) {
    if (quantity <= 0) return Future.value(false);
    return _dao.applyMovementAtomic(
      colorId: colorId,
      delta: quantity,
      changeType: InventoryReason.restock.value,
    );
  }

  @override
  Future<BatchAdjustResult> batchAdjust(Map<int, int> quantities,
      {required bool restock}) async {
    final result = await _dao.applyBatchAtomic(quantities, restock: restock);
    return BatchAdjustResult(
      success: result.success,
      insufficientColors: await _insufficient(result.insufficient),
      adjustedCount: result.success ? quantities.length : 0,
    );
  }

  @override
  Future<bool> reverseLog(int logId) => _dao.reverseLog(logId);

  @override
  Future<DeductResult> batchDeduct(Map<int, int> consumptions,
      {String? patternId}) async {
    final result =
        await _dao.applyDeductionAtomic(consumptions, patternId: patternId);
    return DeductResult(
      success: result.success,
      insufficientColors: await _insufficient(result.insufficient),
      deductedCount: result.success ? consumptions.length : 0,
    );
  }

  Future<List<InsufficientColor>> _insufficient(
      List<Map<String, int>> items) async {
    final result = <InsufficientColor>[];
    for (final item in items) {
      final inventory = await _dao.getInventory(item['colorId']!);
      result.add(InsufficientColor(
        colorId: item['colorId']!,
        colorName: inventory?.colorName ?? '未知',
        required: item['required']!,
        available: item['available']!,
      ));
    }
    return result;
  }

  @override
  Future<void> initializeInventory({int defaultQty = 1200}) async {
    final rows = await _dao.db
        .customSelect('SELECT color_id FROM color_standards ORDER BY color_id')
        .get();
    await _dao.db.transaction(() async {
      await _dao.db.customUpdate('DELETE FROM inventory');
      await _dao.db.customUpdate('DELETE FROM inventory_logs');
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
            [colorId, InventoryReason.init.value, defaultQty, defaultQty, now],
          );
        }
      });
    });
  }

  @override
  Future<void> clearAllData() => _dao.db.transaction(() async {
        await _dao.db.customUpdate('DELETE FROM inventory');
        await _dao.db.customUpdate('DELETE FROM inventory_logs');
      });

  @override
  Future<void> setQty(int colorId, int quantity) =>
      _dao.setQuantityAtomic(colorId, quantity);

  @override
  Future<List<InventoryLogItem>> getLogsForColor(int colorId,
          {int limit = 50}) =>
      _dao.getLogsForColor(colorId, limit: limit);

  @override
  Future<List<OperationLogItem>> getAllLogs(
          {String? changeType,
          int? colorId,
          DateTime? from,
          DateTime? to,
          int limit = 200,
          int offset = 0}) =>
      _dao.getAllLogs(
        changeType: changeType,
        colorId: colorId,
        from: from,
        to: to,
        limit: limit,
        offset: offset,
      );

  @override
  Future<List<InventoryWithColor>> getLowStockColors({int threshold = 500}) =>
      _dao.getLowStockColors(threshold: threshold);
}
