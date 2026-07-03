import 'dart:convert';
import 'package:drift/drift.dart';
import '../../core/database/daos/patterns_dao.dart';
import '../../domain/repositories/patterns_repository.dart';

class PatternsRepositoryImpl implements PatternsRepository {
  final PatternsDao _dao;

  PatternsRepositoryImpl(this._dao);

  @override
  Future<void> savePattern({
    required PatternItem pattern,
    required List<PatternConsumptionItem> consumptions,
  }) async {
    await _dao.insertPattern(pattern);
    for (final c in consumptions) {
      await _dao.insertConsumption(c);
    }
  }

  @override
  Future<List<PatternItem>> getAllPatterns({int limit = 100, int offset = 0}) {
    return _dao.getAllPatterns(limit: limit, offset: offset);
  }

  @override
  Future<PatternItem?> getPattern(String id) {
    return _dao.getPattern(id);
  }

  @override
  Future<List<ConsumptionWithColor>> getConsumptions(String patternId) async {
    final rows = await _dao.db.customSelect(
      'SELECT pc.color_id, pc.quantity, cs.color_name, cs.hex_value '
      'FROM pattern_consumptions pc '
      'LEFT JOIN color_standards cs ON pc.color_id = cs.color_id '
      'WHERE pc.pattern_id = ? '
      'ORDER BY pc.quantity DESC',
      variables: [Variable(patternId)],
    ).get();

    return rows.map((row) {
      final data = row.data;
      return ConsumptionWithColor(
        colorId: data['color_id'] as int,
        colorName: data['color_name'] as String,
        hexValue: data['hex_value'] as String,
        quantity: data['quantity'] as int,
      );
    }).toList();
  }

  @override
  Future<void> updateCompletion({
    required String patternId,
    required DateTime completeTime,
    required List<String> photos,
  }) async {
    await _dao.updatePatternCompletion(
      id: patternId,
      completeTime: completeTime,
      completePhotos: jsonEncode(photos),
    );
  }

  @override
  Future<void> updateTitle(String patternId, String title) async {
    await _dao.updatePatternTitle(patternId, title);
  }

  @override
  Future<void> deletePattern(String patternId) async {
    await _dao.deletePattern(patternId);
  }
}
