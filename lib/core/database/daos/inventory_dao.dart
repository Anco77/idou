import 'package:drift/drift.dart';
import '../app_database.dart';

const Map<String, String> seriesNames = {
  'A': '黄色系',
  'B': '绿色系',
  'C': '蓝色系',
  'D': '紫色系',
  'E': '粉色系',
  'F': '红色系',
  'G': '棕色系',
  'H': '黑白灰',
  'M': '哑色系',
};

const List<String> seriesOrder = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'M'];

/// 库存 + 色号信息的联合数据
class InventoryWithColor {
  final int colorId;
  final String colorName;
  final String hexValue;
  final int r;
  final int g;
  final int b;
  final int currentQty;
  final DateTime updatedAt;
  final int totalConsumed;

  const InventoryWithColor({
    required this.colorId,
    required this.colorName,
    required this.hexValue,
    required this.r,
    required this.g,
    required this.b,
    required this.currentQty,
    required this.updatedAt,
    this.totalConsumed = 0,
  });

  bool get isLowStock => currentQty < 500;

  String get series {
    final name = colorName;
    if (name.length < 6) return '';
    return name.substring(5, 6);
  }

  String get mardId {
    final name = colorName;
    if (name.length < 6) return '';
    return name.substring(5);
  }

  Map<String, dynamic> toMap() => {
    'color_id': colorId,
    'color_name': colorName,
    'hex_value': hexValue,
    'r': r, 'g': g, 'b': b,
    'current_qty': currentQty,
    'updated_at': updatedAt.toIso8601String(),
    'total_consumed': totalConsumed,
  };

  factory InventoryWithColor.fromMap(Map<String, dynamic> map) => InventoryWithColor(
    colorId: map['color_id'] as int,
    colorName: map['color_name'] as String,
    hexValue: map['hex_value'] as String,
    r: map['r'] as int,
    g: map['g'] as int,
    b: map['b'] as int,
    currentQty: (map['current_qty'] as int?) ?? 0,
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : DateTime.now(),
    totalConsumed: (map['total_consumed'] as int?) ?? 0,
  );
}

/// 库存变更记录
class InventoryLogItem {
  final int id;
  final int colorId;
  final String changeType;
  final int quantity;
  final int resultQty;
  final String? patternId;
  final DateTime createdAt;

  const InventoryLogItem({
    required this.id,
    required this.colorId,
    required this.changeType,
    required this.quantity,
    required this.resultQty,
    this.patternId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'color_id': colorId,
    'change_type': changeType,
    'quantity': quantity,
    'result_qty': resultQty,
    'pattern_id': patternId,
    'created_at': createdAt.toIso8601String(),
  };

  factory InventoryLogItem.fromMap(Map<String, dynamic> map) => InventoryLogItem(
    id: map['id'] as int,
    colorId: map['color_id'] as int,
    changeType: map['change_type'] as String,
    quantity: map['quantity'] as int,
    resultQty: map['result_qty'] as int,
    patternId: map['pattern_id'] as String?,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}

/// 全局操作日志（含色号信息和颜色值）
class OperationLogItem {
  final int id;
  final int colorId;
  final String mardId;
  final String colorName;
  final String hexValue;
  final int r;
  final int g;
  final int b;
  final String changeType;
  final int quantity;
  final int resultQty;
  final DateTime createdAt;

  const OperationLogItem({
    required this.id,
    required this.colorId,
    required this.mardId,
    required this.colorName,
    required this.hexValue,
    required this.r,
    required this.g,
    required this.b,
    required this.changeType,
    required this.quantity,
    required this.resultQty,
    required this.createdAt,
  });
}

/// 库存数据访问对象（使用 raw SQL 避免代码生成依赖）
class InventoryDao {
  final AppDatabase db;

  InventoryDao(this.db);

  /// 获取所有色号的库存（含色号信息和总消耗量）
  Future<List<InventoryWithColor>> getAllInventory() async {
    final rows = await db.customSelect(
      'SELECT cs.*, inv.current_qty, inv.updated_at, '
      'COALESCE(('
      '  SELECT SUM(ABS(quantity)) FROM inventory_logs '
      '  WHERE color_id = cs.color_id AND change_type IN (\'consume\', \'deduct_pattern\')'
      '), 0) AS total_consumed '
      'FROM color_standards cs '
      'LEFT JOIN inventory inv ON cs.color_id = inv.color_id '
      'ORDER BY cs.color_id ASC',
    ).get();
    return rows.map((row) => InventoryWithColor.fromMap(row.data)).toList();
  }

  /// 获取单个色号库存
  Future<InventoryWithColor?> getInventory(int colorId) async {
    final rows = await db.customSelect(
      'SELECT cs.*, inv.current_qty, inv.updated_at, '
      'COALESCE(('
      '  SELECT SUM(ABS(quantity)) FROM inventory_logs '
      '  WHERE color_id = cs.color_id AND change_type IN (\'consume\', \'deduct_pattern\')'
      '), 0) AS total_consumed '
      'FROM color_standards cs '
      'LEFT JOIN inventory inv ON cs.color_id = inv.color_id '
      'WHERE cs.color_id = ?',
      variables: [Variable.withInt(colorId)],
    ).get();
    if (rows.isEmpty) return null;
    return InventoryWithColor.fromMap(rows.first.data);
  }

  /// 更新库存数量
  Future<void> updateQuantity(int colorId, int newQty) async {
    await db.customUpdate(
      'UPDATE inventory SET current_qty = ?, updated_at = ? WHERE color_id = ?',
      variables: [
        Variable.withInt(newQty),
        Variable(DateTime.now().toIso8601String()),
        Variable.withInt(colorId),
      ],
    );
  }

  /// 写入库存变更记录
  Future<void> addLog({
    required int colorId,
    required String changeType,
    required int quantity,
    required int resultQty,
    String? patternId,
  }) async {
    await db.customInsert(
      'INSERT INTO inventory_logs (color_id, change_type, quantity, result_qty, pattern_id, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withInt(colorId),
        Variable(changeType),
        Variable.withInt(quantity),
        Variable.withInt(resultQty),
        Variable(patternId),
        Variable(DateTime.now().toIso8601String()),
      ],
    );
  }

  /// 批量写入库存变更记录
  Future<void> addLogs(List<Map<String, dynamic>> logEntries) async {
    await db.batch((batch) {
      for (final entry in logEntries) {
        batch.customStatement(
          'INSERT INTO inventory_logs (color_id, change_type, quantity, result_qty, pattern_id, created_at) '
          'VALUES (?, ?, ?, ?, ?, ?)',
          [
            entry['color_id'] as int,
            entry['change_type'] as String,
            entry['quantity'] as int,
            entry['result_qty'] as int,
            entry['pattern_id'] as String?,
            DateTime.now().toIso8601String(),
          ],
        );
      }
    });
  }

  /// 获取色号的变更历史
  Future<List<InventoryLogItem>> getLogsForColor(int colorId, {int limit = 50}) async {
    final rows = await db.customSelect(
      'SELECT * FROM inventory_logs WHERE color_id = ? ORDER BY created_at DESC LIMIT ?',
      variables: [Variable.withInt(colorId), Variable.withInt(limit)],
    ).get();
    return rows.map((row) => InventoryLogItem.fromMap(row.data)).toList();
  }

  /// 获取全局操作日志（按时间倒序，可筛选类型）
  Future<List<OperationLogItem>> getAllLogs({String? changeType, int limit = 200, int offset = 0}) async {
    String where = '';
    final params = <dynamic>[];
    if (changeType != null && changeType.isNotEmpty) {
      where = 'WHERE il.change_type = ?';
      params.add(changeType);
    }
    params.add(limit);
    params.add(offset);

    final rows = await db.customSelect(
      'SELECT il.id, il.color_id, cs.color_name, cs.hex_value, cs.r, cs.g, cs.b, '
      'il.change_type, il.quantity, il.result_qty, il.created_at '
      'FROM inventory_logs il '
      'INNER JOIN color_standards cs ON il.color_id = cs.color_id '
      '$where '
      'ORDER BY il.created_at DESC LIMIT ? OFFSET ?',
      variables: params.map((p) => p is int ? Variable.withInt(p) : Variable(p as String)).toList(),
    ).get();

    return rows.map((row) {
      final d = row.data;
      final name = d['color_name'] as String;
      final mardId = name.length >= 6 ? name.substring(5) : name;
      return OperationLogItem(
        id: d['id'] as int,
        colorId: d['color_id'] as int,
        mardId: mardId,
        colorName: name,
        hexValue: d['hex_value'] as String,
        r: d['r'] as int,
        g: d['g'] as int,
        b: d['b'] as int,
        changeType: d['change_type'] as String,
        quantity: d['quantity'] as int,
        resultQty: d['result_qty'] as int,
        createdAt: DateTime.parse(d['created_at'] as String),
      );
    }).toList();
  }

  /// 获取所有低量色号
  Future<List<InventoryWithColor>> getLowStockColors({int threshold = 500}) async {
    final rows = await db.customSelect(
      'SELECT cs.*, inv.current_qty, inv.updated_at, '
      'COALESCE(('
      '  SELECT SUM(ABS(quantity)) FROM inventory_logs '
      '  WHERE color_id = cs.color_id AND change_type IN (\'consume\', \'deduct_pattern\')'
      '), 0) AS total_consumed '
      'FROM color_standards cs '
      'INNER JOIN inventory inv ON cs.color_id = inv.color_id '
      'WHERE inv.current_qty < ? '
      'ORDER BY inv.current_qty ASC',
      variables: [Variable.withInt(threshold)],
    ).get();
    return rows.map((row) => InventoryWithColor.fromMap(row.data)).toList();
  }
}
