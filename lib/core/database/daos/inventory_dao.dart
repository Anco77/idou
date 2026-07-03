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

  const InventoryWithColor({
    required this.colorId,
    required this.colorName,
    required this.hexValue,
    required this.r,
    required this.g,
    required this.b,
    required this.currentQty,
    required this.updatedAt,
  });

  bool get isLowStock => currentQty < 500;

  String get series {
    final name = colorName; // e.g. "Mard_A1"
    if (name.length < 6) return '';
    return name.substring(5, 6); // extracts "A", "B", "C", etc.
  }

  Map<String, dynamic> toMap() => {
    'color_id': colorId,
    'color_name': colorName,
    'hex_value': hexValue,
    'r': r, 'g': g, 'b': b,
    'current_qty': currentQty,
    'updated_at': updatedAt.toIso8601String(),
  };

  factory InventoryWithColor.fromMap(Map<String, dynamic> map) => InventoryWithColor(
    colorId: map['color_id'] as int,
    colorName: map['color_name'] as String,
    hexValue: map['hex_value'] as String,
    r: map['r'] as int,
    g: map['g'] as int,
    b: map['b'] as int,
    currentQty: map['current_qty'] as int,
    updatedAt: DateTime.parse(map['updated_at'] as String),
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

/// 库存数据访问对象（使用 raw SQL 避免代码生成依赖）
class InventoryDao {
  final AppDatabase db;

  InventoryDao(this.db);

  /// 获取所有色号的库存（含色号信息）
  Future<List<InventoryWithColor>> getAllInventory() async {
    final rows = await db.customSelect(
      'SELECT cs.*, inv.current_qty, inv.updated_at '
      'FROM color_standards cs '
      'LEFT JOIN inventory inv ON cs.color_id = inv.color_id '
      'ORDER BY cs.color_id ASC',
    ).get();
    return rows.map((row) {
      final data = row.data;
      return InventoryWithColor(
        colorId: data['color_id'] as int,
        colorName: data['color_name'] as String,
        hexValue: data['hex_value'] as String,
        r: data['r'] as int,
        g: data['g'] as int,
        b: data['b'] as int,
        currentQty: (data['current_qty'] as int?) ?? 0,
        updatedAt: data['updated_at'] != null
            ? DateTime.parse(data['updated_at'] as String)
            : DateTime.now(),
      );
    }).toList();
  }

  /// 获取单个色号库存
  Future<InventoryWithColor?> getInventory(int colorId) async {
    final rows = await db.customSelect(
      'SELECT cs.*, inv.current_qty, inv.updated_at '
      'FROM color_standards cs '
      'LEFT JOIN inventory inv ON cs.color_id = inv.color_id '
      'WHERE cs.color_id = ?',
      variables: [Variable.withInt(colorId)],
    ).get();
    if (rows.isEmpty) return null;
    final data = rows.first.data;
    return InventoryWithColor(
      colorId: data['color_id'] as int,
      colorName: data['color_name'] as String,
      hexValue: data['hex_value'] as String,
      r: data['r'] as int,
      g: data['g'] as int,
      b: data['b'] as int,
      currentQty: (data['current_qty'] as int?) ?? 0,
      updatedAt: data['updated_at'] != null
          ? DateTime.parse(data['updated_at'] as String)
          : DateTime.now(),
    );
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
            Variable.withInt(entry['color_id'] as int),
            Variable(entry['change_type'] as String),
            Variable.withInt(entry['quantity'] as int),
            Variable.withInt(entry['result_qty'] as int),
            Variable(entry['pattern_id'] as String?),
            Variable(DateTime.now().toIso8601String()),
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

  /// 获取所有低量色号
  Future<List<InventoryWithColor>> getLowStockColors({int threshold = 500}) async {
    final rows = await db.customSelect(
      'SELECT cs.*, inv.current_qty, inv.updated_at '
      'FROM color_standards cs '
      'INNER JOIN inventory inv ON cs.color_id = inv.color_id '
      'WHERE inv.current_qty < ? '
      'ORDER BY inv.current_qty ASC',
      variables: [Variable.withInt(threshold)],
    ).get();
    return rows.map((row) {
      final data = row.data;
      return InventoryWithColor(
        colorId: data['color_id'] as int,
        colorName: data['color_name'] as String,
        hexValue: data['hex_value'] as String,
        r: data['r'] as int,
        g: data['g'] as int,
        b: data['b'] as int,
        currentQty: data['current_qty'] as int,
        updatedAt: DateTime.parse(data['updated_at'] as String),
      );
    }).toList();
  }
}
