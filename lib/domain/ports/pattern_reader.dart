import '../models/pattern_summary.dart';

abstract interface class PatternReader {
  Future<List<PatternSummary>> list({int limit = 100, int offset = 0});
}
