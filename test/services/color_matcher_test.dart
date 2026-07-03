import 'package:flutter_test/flutter_test.dart';
import 'package:idou/core/utils/color_matcher.dart';

void main() {
  group('ColorMatcher', () {
    late List<StandardColor> standards;
    late ColorMatcher matcher;

    setUp(() {
      standards = [
        const StandardColor(colorId: 1, colorName: '黑色', hexValue: '#000000', r: 0, g: 0, b: 0),
        const StandardColor(colorId: 2, colorName: '白色', hexValue: '#FFFFFF', r: 255, g: 255, b: 255),
        const StandardColor(colorId: 3, colorName: '红色', hexValue: '#FF0000', r: 255, g: 0, b: 0),
        const StandardColor(colorId: 4, colorName: '绿色', hexValue: '#00FF00', r: 0, g: 255, b: 0),
        const StandardColor(colorId: 5, colorName: '蓝色', hexValue: '#0000FF', r: 0, g: 0, b: 255),
      ];
      matcher = ColorMatcher(standards);
    });

    test('纯红色应该匹配到红色(色号3)', () {
      final result = matcher.findNearest(255, 0, 0);
      expect(result.color.colorId, equals(3));
      expect(result.color.colorName, equals('红色'));
    });

    test('纯白色应该匹配到白色(色号2)', () {
      final result = matcher.findNearest(255, 255, 255);
      expect(result.color.colorId, equals(2));
    });

    test('接近黑色的深灰色应该匹配到黑色(色号1)', () {
      final result = matcher.findNearest(10, 10, 10);
      expect(result.color.colorId, equals(1));
    });

    test('浅红色应该匹配到红色(色号3)', () {
      final result = matcher.findNearest(200, 50, 50);
      expect(result.color.colorId, equals(3));
    });

    test('距离计算应该非负', () {
      final result = matcher.findNearest(128, 128, 128);
      expect(result.distance, greaterThanOrEqualTo(0));
    });
  });
}
