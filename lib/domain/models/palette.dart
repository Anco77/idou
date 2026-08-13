import 'bead_color.dart';

class Palette {
  final String id;
  final String name;
  final List<BeadColor> colors;

  Palette(
      {required this.id, required this.name, required List<BeadColor> colors})
      : colors = List.unmodifiable(colors) {
    if (id.trim().isEmpty || name.trim().isEmpty || this.colors.isEmpty) {
      throw ArgumentError('色卡必须包含 id、名称和至少一个颜色');
    }
    final ids = this.colors.map((color) => color.id).toSet();
    if (ids.length != this.colors.length) {
      throw ArgumentError('色卡不能包含重复颜色 id');
    }
  }

  BeadColor? byId(int id) {
    for (final color in colors) {
      if (color.id == id) return color;
    }
    return null;
  }

  BeadColor? byCode(String code) {
    final normalized = code.trim().toUpperCase();
    for (final color in colors) {
      if (color.code.toUpperCase() == normalized) return color;
    }
    return null;
  }
}
