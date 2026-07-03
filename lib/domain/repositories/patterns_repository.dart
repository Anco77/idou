import '../../core/database/daos/patterns_dao.dart';

/// 图纸仓库接口
abstract class PatternsRepository {
  /// 保存图纸及消耗明细
  Future<void> savePattern({
    required PatternItem pattern,
    required List<PatternConsumptionItem> consumptions,
  });

  /// 获取所有图纸
  Future<List<PatternItem>> getAllPatterns({int limit = 100, int offset = 0});

  /// 获取单个图纸
  Future<PatternItem?> getPattern(String id);

  /// 获取图纸消耗明细（含色号信息）
  Future<List<ConsumptionWithColor>> getConsumptions(String patternId);

  /// 更新完成信息
  Future<void> updateCompletion({
    required String patternId,
    required DateTime completeTime,
    required List<String> photos,
  });

  /// 更新标题
  Future<void> updateTitle(String patternId, String title);

  /// 删除图纸
  Future<void> deletePattern(String patternId);
}

/// 消耗明细（含色号信息）
class ConsumptionWithColor {
  final int colorId;
  final String colorName;
  final String hexValue;
  final int quantity;

  const ConsumptionWithColor({
    required this.colorId,
    required this.colorName,
    required this.hexValue,
    required this.quantity,
  });
}
