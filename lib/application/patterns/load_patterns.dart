import '../../domain/models/pattern_summary.dart';
import '../../domain/ports/pattern_reader.dart';

class LoadPatterns {
  final PatternReader _reader;

  const LoadPatterns(this._reader);

  Future<List<PatternSummary>> call({int limit = 100, int offset = 0}) {
    return _reader.list(limit: limit, offset: offset);
  }
}
