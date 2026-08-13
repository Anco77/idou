/// Read-only pattern data used by list and dashboard screens.
///
/// This is intentionally separate from Drift's `PatternItem` so application
/// and presentation code do not depend on database row types.
class PatternSummary {
  final String id;
  final String title;
  final String originalImage;
  final DateTime uploadTime;
  final String status;
  final String source;

  const PatternSummary({
    required this.id,
    required this.title,
    required this.originalImage,
    required this.uploadTime,
    required this.status,
    required this.source,
  });

  bool get isCompleted => status == 'completed';
}
