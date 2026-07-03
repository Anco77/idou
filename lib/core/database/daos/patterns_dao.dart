import 'package:drift/drift.dart';
import '../app_database.dart';

/// 图纸数据
class PatternItem {
  final String id;
  final String title;
  final String originalImage;
  final DateTime uploadTime;
  final DateTime? completeTime;
  final String? completePhotos;
  final String status;
  final String source;
  final DateTime createdAt;

  const PatternItem({
    required this.id,
    required this.title,
    required this.originalImage,
    required this.uploadTime,
    this.completeTime,
    this.completePhotos,
    required this.status,
    required this.source,
    required this.createdAt,
  });

  bool get isCompleted => status == 'completed';

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'original_image': originalImage,
    'upload_time': uploadTime.toIso8601String(),
    'complete_time': completeTime?.toIso8601String(),
    'complete_photos': completePhotos,
    'status': status,
    'source': source,
    'created_at': createdAt.toIso8601String(),
  };

  factory PatternItem.fromMap(Map<String, dynamic> map) => PatternItem(
    id: map['id'] as String,
    title: map['title'] as String,
    originalImage: map['original_image'] as String,
    uploadTime: DateTime.parse(map['upload_time'] as String),
    completeTime: map['complete_time'] != null ? DateTime.parse(map['complete_time'] as String) : null,
    completePhotos: map['complete_photos'] as String?,
    status: map['status'] as String,
    source: map['source'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}

/// 图纸消耗明细
class PatternConsumptionItem {
  final int id;
  final String patternId;
  final int colorId;
  final int quantity;

  const PatternConsumptionItem({
    required this.id,
    required this.patternId,
    required this.colorId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'pattern_id': patternId,
    'color_id': colorId,
    'quantity': quantity,
  };

  factory PatternConsumptionItem.fromMap(Map<String, dynamic> map) => PatternConsumptionItem(
    id: map['id'] as int,
    patternId: map['pattern_id'] as String,
    colorId: map['color_id'] as int,
    quantity: map['quantity'] as int,
  );
}

/// 图纸数据访问对象
class PatternsDao {
  final AppDatabase db;

  PatternsDao(this.db);

  /// 保存图纸
  Future<void> insertPattern(PatternItem pattern) async {
    await db.customInsert(
      'INSERT OR REPLACE INTO patterns (id, title, original_image, upload_time, complete_time, complete_photos, status, source, created_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
      variables: [
        Variable(pattern.id),
        Variable(pattern.title),
        Variable(pattern.originalImage),
        Variable(pattern.uploadTime.toIso8601String()),
        Variable(pattern.completeTime?.toIso8601String()),
        Variable(pattern.completePhotos),
        Variable(pattern.status),
        Variable(pattern.source),
        Variable(pattern.createdAt.toIso8601String()),
      ],
    );
  }

  /// 保存图纸消耗明细
  Future<void> insertConsumption(PatternConsumptionItem consumption) async {
    await db.customInsert(
      'INSERT OR REPLACE INTO pattern_consumptions (pattern_id, color_id, quantity) VALUES (?, ?, ?)',
      variables: [
        Variable(consumption.patternId),
        Variable.withInt(consumption.colorId),
        Variable.withInt(consumption.quantity),
      ],
    );
  }

  /// 批量保存消耗明细
  Future<void> insertConsumptions(String patternId, List<Map<String, dynamic>> consumptions) async {
    await db.batch((batch) {
      for (final c in consumptions) {
        batch.customStatement(
          'INSERT OR REPLACE INTO pattern_consumptions (pattern_id, color_id, quantity) VALUES (?, ?, ?)',
          [
            patternId,
            c['color_id'] as int,
            c['quantity'] as int,
          ],
        );
      }
    });
  }

  /// 获取所有图纸
  Future<List<PatternItem>> getAllPatterns({int limit = 100, int offset = 0}) async {
    final rows = await db.customSelect(
      'SELECT * FROM patterns ORDER BY created_at DESC LIMIT ? OFFSET ?',
      variables: [Variable.withInt(limit), Variable.withInt(offset)],
    ).get();
    return rows.map((row) => PatternItem.fromMap(row.data)).toList();
  }

  /// 获取单个图纸
  Future<PatternItem?> getPattern(String id) async {
    final rows = await db.customSelect(
      'SELECT * FROM patterns WHERE id = ?',
      variables: [Variable(id)],
    ).get();
    if (rows.isEmpty) return null;
    return PatternItem.fromMap(rows.first.data);
  }

  /// 获取图纸的消耗明细
  Future<List<PatternConsumptionItem>> getConsumptions(String patternId) async {
    final rows = await db.customSelect(
      'SELECT pc.*, cs.color_name, cs.hex_value '
      'FROM pattern_consumptions pc '
      'LEFT JOIN color_standards cs ON pc.color_id = cs.color_id '
      'WHERE pc.pattern_id = ? '
      'ORDER BY pc.color_id ASC',
      variables: [Variable(patternId)],
    ).get();
    return rows.map((row) => PatternConsumptionItem.fromMap(row.data)).toList();
  }

  /// 更新图纸（完成信息）
  Future<void> updatePatternCompletion({
    required String id,
    required DateTime completeTime,
    required String completePhotos,
  }) async {
    await db.customUpdate(
      'UPDATE patterns SET complete_time = ?, complete_photos = ?, status = ? WHERE id = ?',
      variables: [
        Variable(completeTime.toIso8601String()),
        Variable(completePhotos),
        Variable('completed'),
        Variable(id),
      ],
    );
  }

  /// 更新图纸标题
  Future<void> updatePatternTitle(String id, String title) async {
    await db.customUpdate(
      'UPDATE patterns SET title = ? WHERE id = ?',
      variables: [Variable(title), Variable(id)],
    );
  }

  /// 删除图纸及其消耗明细
  Future<void> deletePattern(String id) async {
    await db.customUpdate(
      'DELETE FROM pattern_consumptions WHERE pattern_id = ?',
      variables: [Variable(id)],
    );
    await db.customUpdate(
      'DELETE FROM patterns WHERE id = ?',
      variables: [Variable(id)],
    );
  }
}
