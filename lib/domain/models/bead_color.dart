/// A palette colour. This model deliberately has no Flutter, Drift or IO dependency.
class BeadColor {
  final int id;
  final String code;
  final String displayName;
  final int red;
  final int green;
  final int blue;

  BeadColor({
    required this.id,
    required this.code,
    required this.displayName,
    required this.red,
    required this.green,
    required this.blue,
  }) {
    if (id < 0 || code.trim().isEmpty || displayName.trim().isEmpty) {
      throw ArgumentError('色号必须包含非负 id、code 和名称');
    }
    if ([red, green, blue].any((value) => value < 0 || value > 255)) {
      throw ArgumentError('RGB 分量必须在 0 到 255 之间');
    }
  }

  @override
  bool operator ==(Object other) => other is BeadColor && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
