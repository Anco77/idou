import '../../core/database/daos/patterns_dao.dart';
import '../../domain/models/pattern_summary.dart';
import '../../domain/ports/pattern_reader.dart';

class PatternsReaderAdapter implements PatternReader {
  final PatternsDao _dao;

  const PatternsReaderAdapter(this._dao);

  @override
  Future<List<PatternSummary>> list({int limit = 100, int offset = 0}) async {
    final rows = await _dao.getAllPatterns(limit: limit, offset: offset);
    return rows.map(_toSummary).toList(growable: false);
  }

  PatternSummary _toSummary(PatternItem row) => PatternSummary(
        id: row.id,
        title: row.title,
        originalImage: row.originalImage,
        uploadTime: row.uploadTime,
        status: row.status,
        source: row.source,
      );
}
