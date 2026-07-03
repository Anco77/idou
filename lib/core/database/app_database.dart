import 'dart:async';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/color_standards_table.dart';
import 'tables/inventory_table.dart';
import 'tables/inventory_logs_table.dart';
import 'tables/patterns_table.dart';
import 'tables/pattern_consumptions_table.dart';

part 'app_database.g.dart';

/// 所有表定义索引
@DriftDatabase(
  tables: [
    ColorStandards,
    Inventory,
    InventoryLogs,
    Patterns,
    PatternConsumptions,
  ],
  daos: [],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
      await _seedColorStandards();
    },
    onUpgrade: (m, from, to) async {
      if (from == 1) {
        // v1→v2: 将旧 50 色占位数据替换为完整 Mard 221 色
        await delete(colorStandards).go();
        await _seedColorStandards();
      }
    },
  );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX idx_inventory_logs_color ON inventory_logs (color_id)'
    );
    await customStatement(
      'CREATE INDEX idx_inventory_logs_created ON inventory_logs (created_at)'
    );
    await customStatement(
      'CREATE INDEX idx_pattern_consumptions_pattern ON pattern_consumptions (pattern_id)'
    );
  }

  Future<void> _seedColorStandards() async {
    await batch((batch) {
      for (final color in _defaultColors) {
        batch.insert(colorStandards, ColorStandardsCompanion.insert(
          colorId: Value(color.colorId),
          colorName: color.colorName,
          hexValue: color.hexValue,
          r: color.r,
          g: color.g,
          b: color.b,
          defaultQty: const Value(1200),
        ));
      }
    });
  }

  /// 确保标准色数据完整（221色），缺失则补入
  Future<void> initializeColorStandards() async {
    final existingCount = await (select(colorStandards).map((row) => row.colorId)).get().then((rows) => rows.length);
    if (existingCount >= _defaultColors.length) return;

    final existingIds = await (select(colorStandards).map((row) => row.colorId)).get();
    final missing = _defaultColors.where((c) => !existingIds.contains(c.colorId));
    if (missing.isEmpty) return;

    await batch((batch) {
      for (final color in missing) {
        batch.insert(colorStandards, ColorStandardsCompanion.insert(
          colorId: Value(color.colorId),
          colorName: color.colorName,
          hexValue: color.hexValue,
          r: color.r,
          g: color.g,
          b: color.b,
          defaultQty: const Value(1200),
        ));
      }
    });
  }

  /// 初始化库存（所有色号设默认值）
  Future<void> initializeInventory({int defaultQty = 1200}) async {
    // 清空旧库存
    await delete(inventory).go();
    // 清空日志
    await delete(inventoryLogs).go();

    await batch((batch) {
      for (final color in _defaultColors) {
        batch.insert(inventory, InventoryCompanion.insert(
          colorId: Value(color.colorId),
          currentQty: Value(defaultQty),
        ));
      }
    });

    // 写入初始化日志
    final now = DateTime.now();
    await batch((batch) {
      for (final color in _defaultColors) {
        batch.insert(inventoryLogs, InventoryLogsCompanion.insert(
          colorId: color.colorId,
          changeType: 'init',
          quantity: defaultQty,
          resultQty: defaultQty,
          createdAt: Value(now),
        ));
      }
    });
  }
}

/// 数据库连接
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'idou.db'));
    return NativeDatabase(file);
  });
}

/// 221色标准色号数据
class StandardColorData {
  final int colorId;
  final String colorName;
  final String hexValue;
  final int r;
  final int g;
  final int b;

  const StandardColorData({
    required this.colorId,
    required this.colorName,
    required this.hexValue,
    required this.r,
    required this.g,
    required this.b,
  });
}

const List<StandardColorData> _defaultColors = [
  // A系列 (A1-A26)
  StandardColorData(colorId: 1, colorName: 'Mard_A1', hexValue: '#FAF4C8', r: 250, g: 244, b: 200),
  StandardColorData(colorId: 2, colorName: 'Mard_A2', hexValue: '#FFFFD5', r: 255, g: 255, b: 213),
  StandardColorData(colorId: 3, colorName: 'Mard_A3', hexValue: '#FEFF8B', r: 254, g: 255, b: 139),
  StandardColorData(colorId: 4, colorName: 'Mard_A4', hexValue: '#FBED56', r: 251, g: 237, b: 86),
  StandardColorData(colorId: 5, colorName: 'Mard_A5', hexValue: '#F4D738', r: 244, g: 215, b: 56),
  StandardColorData(colorId: 6, colorName: 'Mard_A6', hexValue: '#FEAC4C', r: 254, g: 172, b: 76),
  StandardColorData(colorId: 7, colorName: 'Mard_A7', hexValue: '#FE8B4C', r: 254, g: 139, b: 76),
  StandardColorData(colorId: 8, colorName: 'Mard_A8', hexValue: '#FFDA45', r: 255, g: 218, b: 69),
  StandardColorData(colorId: 9, colorName: 'Mard_A9', hexValue: '#FF995B', r: 255, g: 153, b: 91),
  StandardColorData(colorId: 10, colorName: 'Mard_A10', hexValue: '#F77C31', r: 247, g: 124, b: 49),
  StandardColorData(colorId: 11, colorName: 'Mard_A11', hexValue: '#FFDD99', r: 255, g: 221, b: 153),
  StandardColorData(colorId: 12, colorName: 'Mard_A12', hexValue: '#FE9F72', r: 254, g: 159, b: 114),
  StandardColorData(colorId: 13, colorName: 'Mard_A13', hexValue: '#FFC365', r: 255, g: 195, b: 101),
  StandardColorData(colorId: 14, colorName: 'Mard_A14', hexValue: '#FD543D', r: 253, g: 84, b: 61),
  StandardColorData(colorId: 15, colorName: 'Mard_A15', hexValue: '#FFF365', r: 255, g: 243, b: 101),
  StandardColorData(colorId: 16, colorName: 'Mard_A16', hexValue: '#FFFF9F', r: 255, g: 255, b: 159),
  StandardColorData(colorId: 17, colorName: 'Mard_A17', hexValue: '#FFE36E', r: 255, g: 227, b: 110),
  StandardColorData(colorId: 18, colorName: 'Mard_A18', hexValue: '#FEBE7D', r: 254, g: 190, b: 125),
  StandardColorData(colorId: 19, colorName: 'Mard_A19', hexValue: '#FD7C72', r: 253, g: 124, b: 114),
  StandardColorData(colorId: 20, colorName: 'Mard_A20', hexValue: '#FFD568', r: 255, g: 213, b: 104),
  StandardColorData(colorId: 21, colorName: 'Mard_A21', hexValue: '#FFE395', r: 255, g: 227, b: 149),
  StandardColorData(colorId: 22, colorName: 'Mard_A22', hexValue: '#F4F57D', r: 244, g: 245, b: 125),
  StandardColorData(colorId: 23, colorName: 'Mard_A23', hexValue: '#E6C9B7', r: 230, g: 201, b: 183),
  StandardColorData(colorId: 24, colorName: 'Mard_A24', hexValue: '#F7F8A2', r: 247, g: 248, b: 162),
  StandardColorData(colorId: 25, colorName: 'Mard_A25', hexValue: '#FFD67D', r: 255, g: 214, b: 125),
  StandardColorData(colorId: 26, colorName: 'Mard_A26', hexValue: '#FFC830', r: 255, g: 200, b: 48),
  // B系列 (B1-B32)
  StandardColorData(colorId: 27, colorName: 'Mard_B1', hexValue: '#E6EE31', r: 230, g: 238, b: 49),
  StandardColorData(colorId: 28, colorName: 'Mard_B2', hexValue: '#63F347', r: 99, g: 243, b: 71),
  StandardColorData(colorId: 29, colorName: 'Mard_B3', hexValue: '#9EF780', r: 158, g: 247, b: 128),
  StandardColorData(colorId: 30, colorName: 'Mard_B4', hexValue: '#5DE035', r: 93, g: 224, b: 53),
  StandardColorData(colorId: 31, colorName: 'Mard_B5', hexValue: '#35E352', r: 53, g: 227, b: 82),
  StandardColorData(colorId: 32, colorName: 'Mard_B6', hexValue: '#65E2A6', r: 101, g: 226, b: 166),
  StandardColorData(colorId: 33, colorName: 'Mard_B7', hexValue: '#3DAF80', r: 61, g: 175, b: 128),
  StandardColorData(colorId: 34, colorName: 'Mard_B8', hexValue: '#1C9C4F', r: 28, g: 156, b: 79),
  StandardColorData(colorId: 35, colorName: 'Mard_B9', hexValue: '#27523A', r: 39, g: 82, b: 58),
  StandardColorData(colorId: 36, colorName: 'Mard_B10', hexValue: '#95D3C2', r: 149, g: 211, b: 194),
  StandardColorData(colorId: 37, colorName: 'Mard_B11', hexValue: '#5D722A', r: 93, g: 114, b: 42),
  StandardColorData(colorId: 38, colorName: 'Mard_B12', hexValue: '#166F41', r: 22, g: 111, b: 65),
  StandardColorData(colorId: 39, colorName: 'Mard_B13', hexValue: '#CAEB7B', r: 202, g: 235, b: 123),
  StandardColorData(colorId: 40, colorName: 'Mard_B14', hexValue: '#ADE946', r: 173, g: 233, b: 70),
  StandardColorData(colorId: 41, colorName: 'Mard_B15', hexValue: '#2E5132', r: 46, g: 81, b: 50),
  StandardColorData(colorId: 42, colorName: 'Mard_B16', hexValue: '#C5ED9C', r: 197, g: 237, b: 156),
  StandardColorData(colorId: 43, colorName: 'Mard_B17', hexValue: '#9BB13A', r: 155, g: 177, b: 58),
  StandardColorData(colorId: 44, colorName: 'Mard_B18', hexValue: '#E6EE49', r: 230, g: 238, b: 73),
  StandardColorData(colorId: 45, colorName: 'Mard_B19', hexValue: '#24B88C', r: 36, g: 184, b: 140),
  StandardColorData(colorId: 46, colorName: 'Mard_B20', hexValue: '#C2F0CC', r: 194, g: 240, b: 204),
  StandardColorData(colorId: 47, colorName: 'Mard_B21', hexValue: '#156A6B', r: 21, g: 106, b: 107),
  StandardColorData(colorId: 48, colorName: 'Mard_B22', hexValue: '#0B3C43', r: 11, g: 60, b: 67),
  StandardColorData(colorId: 49, colorName: 'Mard_B23', hexValue: '#303A21', r: 48, g: 58, b: 33),
  StandardColorData(colorId: 50, colorName: 'Mard_B24', hexValue: '#EEFCA5', r: 238, g: 252, b: 165),
  StandardColorData(colorId: 51, colorName: 'Mard_B25', hexValue: '#4E846D', r: 78, g: 132, b: 109),
  StandardColorData(colorId: 52, colorName: 'Mard_B26', hexValue: '#8D7A35', r: 141, g: 122, b: 53),
  StandardColorData(colorId: 53, colorName: 'Mard_B27', hexValue: '#CCE1AF', r: 204, g: 225, b: 175),
  StandardColorData(colorId: 54, colorName: 'Mard_B28', hexValue: '#9EE5B9', r: 158, g: 229, b: 185),
  StandardColorData(colorId: 55, colorName: 'Mard_B29', hexValue: '#C5E254', r: 197, g: 226, b: 84),
  StandardColorData(colorId: 56, colorName: 'Mard_B30', hexValue: '#E2FCB1', r: 226, g: 252, b: 177),
  StandardColorData(colorId: 57, colorName: 'Mard_B31', hexValue: '#B0E792', r: 176, g: 231, b: 146),
  StandardColorData(colorId: 58, colorName: 'Mard_B32', hexValue: '#9CAB5A', r: 156, g: 171, b: 90),
  // C系列 (C1-C29)
  StandardColorData(colorId: 59, colorName: 'Mard_C1', hexValue: '#E8FFE7', r: 232, g: 255, b: 231),
  StandardColorData(colorId: 60, colorName: 'Mard_C2', hexValue: '#A9F9FC', r: 169, g: 249, b: 252),
  StandardColorData(colorId: 61, colorName: 'Mard_C3', hexValue: '#A0E2FB', r: 160, g: 226, b: 251),
  StandardColorData(colorId: 62, colorName: 'Mard_C4', hexValue: '#41CCFF', r: 65, g: 204, b: 255),
  StandardColorData(colorId: 63, colorName: 'Mard_C5', hexValue: '#01ACEB', r: 1, g: 172, b: 235),
  StandardColorData(colorId: 64, colorName: 'Mard_C6', hexValue: '#50AAF0', r: 80, g: 170, b: 240),
  StandardColorData(colorId: 65, colorName: 'Mard_C7', hexValue: '#3677D2', r: 54, g: 119, b: 210),
  StandardColorData(colorId: 66, colorName: 'Mard_C8', hexValue: '#0F54C0', r: 15, g: 84, b: 192),
  StandardColorData(colorId: 67, colorName: 'Mard_C9', hexValue: '#324BCA', r: 50, g: 75, b: 202),
  StandardColorData(colorId: 68, colorName: 'Mard_C10', hexValue: '#3EBCE2', r: 62, g: 188, b: 226),
  StandardColorData(colorId: 69, colorName: 'Mard_C11', hexValue: '#28DDDE', r: 40, g: 221, b: 222),
  StandardColorData(colorId: 70, colorName: 'Mard_C12', hexValue: '#1C334D', r: 28, g: 51, b: 77),
  StandardColorData(colorId: 71, colorName: 'Mard_C13', hexValue: '#CDE8FF', r: 205, g: 232, b: 255),
  StandardColorData(colorId: 72, colorName: 'Mard_C14', hexValue: '#D5FDFF', r: 213, g: 253, b: 255),
  StandardColorData(colorId: 73, colorName: 'Mard_C15', hexValue: '#22C4C6', r: 34, g: 196, b: 198),
  StandardColorData(colorId: 74, colorName: 'Mard_C16', hexValue: '#1557A8', r: 21, g: 87, b: 168),
  StandardColorData(colorId: 75, colorName: 'Mard_C17', hexValue: '#04D1F6', r: 4, g: 209, b: 246),
  StandardColorData(colorId: 76, colorName: 'Mard_C18', hexValue: '#1D3344', r: 29, g: 51, b: 68),
  StandardColorData(colorId: 77, colorName: 'Mard_C19', hexValue: '#1887A2', r: 24, g: 135, b: 162),
  StandardColorData(colorId: 78, colorName: 'Mard_C20', hexValue: '#176DAF', r: 23, g: 109, b: 175),
  StandardColorData(colorId: 79, colorName: 'Mard_C21', hexValue: '#BEDDFF', r: 190, g: 221, b: 255),
  StandardColorData(colorId: 80, colorName: 'Mard_C22', hexValue: '#67B4BE', r: 103, g: 180, b: 190),
  StandardColorData(colorId: 81, colorName: 'Mard_C23', hexValue: '#C8E2FF', r: 200, g: 226, b: 255),
  StandardColorData(colorId: 82, colorName: 'Mard_C24', hexValue: '#7CC4FF', r: 124, g: 196, b: 255),
  StandardColorData(colorId: 83, colorName: 'Mard_C25', hexValue: '#A9E5E5', r: 169, g: 229, b: 229),
  StandardColorData(colorId: 84, colorName: 'Mard_C26', hexValue: '#3CAED8', r: 60, g: 174, b: 216),
  StandardColorData(colorId: 85, colorName: 'Mard_C27', hexValue: '#D3DFFA', r: 211, g: 223, b: 250),
  StandardColorData(colorId: 86, colorName: 'Mard_C28', hexValue: '#BBCFED', r: 187, g: 207, b: 237),
  StandardColorData(colorId: 87, colorName: 'Mard_C29', hexValue: '#34488E', r: 52, g: 72, b: 142),
  // D系列 (D1-D26)
  StandardColorData(colorId: 88, colorName: 'Mard_D1', hexValue: '#AEB4F2', r: 174, g: 180, b: 242),
  StandardColorData(colorId: 89, colorName: 'Mard_D2', hexValue: '#858EDD', r: 133, g: 142, b: 221),
  StandardColorData(colorId: 90, colorName: 'Mard_D3', hexValue: '#2F54AF', r: 47, g: 84, b: 175),
  StandardColorData(colorId: 91, colorName: 'Mard_D4', hexValue: '#182A84', r: 24, g: 42, b: 132),
  StandardColorData(colorId: 92, colorName: 'Mard_D5', hexValue: '#B843C5', r: 184, g: 67, b: 197),
  StandardColorData(colorId: 93, colorName: 'Mard_D6', hexValue: '#AC7BDE', r: 172, g: 123, b: 222),
  StandardColorData(colorId: 94, colorName: 'Mard_D7', hexValue: '#8854B3', r: 136, g: 84, b: 179),
  StandardColorData(colorId: 95, colorName: 'Mard_D8', hexValue: '#E2D3FF', r: 226, g: 211, b: 255),
  StandardColorData(colorId: 96, colorName: 'Mard_D9', hexValue: '#D5B9F8', r: 213, g: 185, b: 248),
  StandardColorData(colorId: 97, colorName: 'Mard_D10', hexValue: '#361851', r: 54, g: 24, b: 81),
  StandardColorData(colorId: 98, colorName: 'Mard_D11', hexValue: '#B9BAE1', r: 185, g: 186, b: 225),
  StandardColorData(colorId: 99, colorName: 'Mard_D12', hexValue: '#DE9AD4', r: 222, g: 154, b: 212),
  StandardColorData(colorId: 100, colorName: 'Mard_D13', hexValue: '#B90095', r: 185, g: 0, b: 149),
  StandardColorData(colorId: 101, colorName: 'Mard_D14', hexValue: '#8B279B', r: 139, g: 39, b: 155),
  StandardColorData(colorId: 102, colorName: 'Mard_D15', hexValue: '#2F1F90', r: 47, g: 31, b: 144),
  StandardColorData(colorId: 103, colorName: 'Mard_D16', hexValue: '#E3E1EE', r: 227, g: 225, b: 238),
  StandardColorData(colorId: 104, colorName: 'Mard_D17', hexValue: '#C4D4F6', r: 196, g: 212, b: 246),
  StandardColorData(colorId: 105, colorName: 'Mard_D18', hexValue: '#A45EC7', r: 164, g: 94, b: 199),
  StandardColorData(colorId: 106, colorName: 'Mard_D19', hexValue: '#D8C3D7', r: 216, g: 195, b: 215),
  StandardColorData(colorId: 107, colorName: 'Mard_D20', hexValue: '#9C32B2', r: 156, g: 50, b: 178),
  StandardColorData(colorId: 108, colorName: 'Mard_D21', hexValue: '#9A009B', r: 154, g: 0, b: 155),
  StandardColorData(colorId: 109, colorName: 'Mard_D22', hexValue: '#333A95', r: 51, g: 58, b: 149),
  StandardColorData(colorId: 110, colorName: 'Mard_D23', hexValue: '#EBDAFC', r: 235, g: 218, b: 252),
  StandardColorData(colorId: 111, colorName: 'Mard_D24', hexValue: '#7786E5', r: 119, g: 134, b: 229),
  StandardColorData(colorId: 112, colorName: 'Mard_D25', hexValue: '#494FC7', r: 73, g: 79, b: 199),
  StandardColorData(colorId: 113, colorName: 'Mard_D26', hexValue: '#DFC2F8', r: 223, g: 194, b: 248),
  // E系列 (E1-E24)
  StandardColorData(colorId: 114, colorName: 'Mard_E1', hexValue: '#FDD3CC', r: 253, g: 211, b: 204),
  StandardColorData(colorId: 115, colorName: 'Mard_E2', hexValue: '#FEC0DF', r: 254, g: 192, b: 223),
  StandardColorData(colorId: 116, colorName: 'Mard_E3', hexValue: '#FFB7E7', r: 255, g: 183, b: 231),
  StandardColorData(colorId: 117, colorName: 'Mard_E4', hexValue: '#E8649E', r: 232, g: 100, b: 158),
  StandardColorData(colorId: 118, colorName: 'Mard_E5', hexValue: '#F551A2', r: 245, g: 81, b: 162),
  StandardColorData(colorId: 119, colorName: 'Mard_E6', hexValue: '#F13D74', r: 241, g: 61, b: 116),
  StandardColorData(colorId: 120, colorName: 'Mard_E7', hexValue: '#C63478', r: 198, g: 52, b: 120),
  StandardColorData(colorId: 121, colorName: 'Mard_E8', hexValue: '#FFDBE9', r: 255, g: 219, b: 233),
  StandardColorData(colorId: 122, colorName: 'Mard_E9', hexValue: '#E970CC', r: 233, g: 112, b: 204),
  StandardColorData(colorId: 123, colorName: 'Mard_E10', hexValue: '#D33793', r: 211, g: 55, b: 147),
  StandardColorData(colorId: 124, colorName: 'Mard_E11', hexValue: '#FCDDD2', r: 252, g: 221, b: 210),
  StandardColorData(colorId: 125, colorName: 'Mard_E12', hexValue: '#F78FC3', r: 247, g: 143, b: 195),
  StandardColorData(colorId: 126, colorName: 'Mard_E13', hexValue: '#B5006D', r: 181, g: 0, b: 109),
  StandardColorData(colorId: 127, colorName: 'Mard_E14', hexValue: '#FFD1BA', r: 255, g: 209, b: 186),
  StandardColorData(colorId: 128, colorName: 'Mard_E15', hexValue: '#F8C7C9', r: 248, g: 199, b: 201),
  StandardColorData(colorId: 129, colorName: 'Mard_E16', hexValue: '#FFF3EB', r: 255, g: 243, b: 235),
  StandardColorData(colorId: 130, colorName: 'Mard_E17', hexValue: '#FFE2EA', r: 255, g: 226, b: 234),
  StandardColorData(colorId: 131, colorName: 'Mard_E18', hexValue: '#FFC7DB', r: 255, g: 199, b: 219),
  StandardColorData(colorId: 132, colorName: 'Mard_E19', hexValue: '#FEBAD5', r: 254, g: 186, b: 213),
  StandardColorData(colorId: 133, colorName: 'Mard_E20', hexValue: '#D8C7D1', r: 216, g: 199, b: 209),
  StandardColorData(colorId: 134, colorName: 'Mard_E21', hexValue: '#BD9DA1', r: 189, g: 157, b: 161),
  StandardColorData(colorId: 135, colorName: 'Mard_E22', hexValue: '#B785A1', r: 183, g: 133, b: 161),
  StandardColorData(colorId: 136, colorName: 'Mard_E23', hexValue: '#937A8D', r: 147, g: 122, b: 141),
  StandardColorData(colorId: 137, colorName: 'Mard_E24', hexValue: '#E1BCE8', r: 225, g: 188, b: 232),
  // F系列 (F1-F25)
  StandardColorData(colorId: 138, colorName: 'Mard_F1', hexValue: '#FD957B', r: 253, g: 149, b: 123),
  StandardColorData(colorId: 139, colorName: 'Mard_F2', hexValue: '#FC3D46', r: 252, g: 61, b: 70),
  StandardColorData(colorId: 140, colorName: 'Mard_F3', hexValue: '#F74941', r: 247, g: 73, b: 65),
  StandardColorData(colorId: 141, colorName: 'Mard_F4', hexValue: '#FC283C', r: 252, g: 40, b: 60),
  StandardColorData(colorId: 142, colorName: 'Mard_F5', hexValue: '#E7002F', r: 231, g: 0, b: 47),
  StandardColorData(colorId: 143, colorName: 'Mard_F6', hexValue: '#943630', r: 148, g: 54, b: 48),
  StandardColorData(colorId: 144, colorName: 'Mard_F7', hexValue: '#971937', r: 151, g: 25, b: 55),
  StandardColorData(colorId: 145, colorName: 'Mard_F8', hexValue: '#BC0028', r: 188, g: 0, b: 40),
  StandardColorData(colorId: 146, colorName: 'Mard_F9', hexValue: '#E2677A', r: 226, g: 103, b: 122),
  StandardColorData(colorId: 147, colorName: 'Mard_F10', hexValue: '#8A4526', r: 138, g: 69, b: 38),
  StandardColorData(colorId: 148, colorName: 'Mard_F11', hexValue: '#5A2121', r: 90, g: 33, b: 33),
  StandardColorData(colorId: 149, colorName: 'Mard_F12', hexValue: '#FD4E6A', r: 253, g: 78, b: 106),
  StandardColorData(colorId: 150, colorName: 'Mard_F13', hexValue: '#F35744', r: 243, g: 87, b: 68),
  StandardColorData(colorId: 151, colorName: 'Mard_F14', hexValue: '#FFA9AD', r: 255, g: 169, b: 173),
  StandardColorData(colorId: 152, colorName: 'Mard_F15', hexValue: '#D30022', r: 211, g: 0, b: 34),
  StandardColorData(colorId: 153, colorName: 'Mard_F16', hexValue: '#FEC2A6', r: 254, g: 194, b: 166),
  StandardColorData(colorId: 154, colorName: 'Mard_F17', hexValue: '#E69C79', r: 230, g: 156, b: 121),
  StandardColorData(colorId: 155, colorName: 'Mard_F18', hexValue: '#D37C46', r: 211, g: 124, b: 70),
  StandardColorData(colorId: 156, colorName: 'Mard_F19', hexValue: '#C1444A', r: 193, g: 68, b: 74),
  StandardColorData(colorId: 157, colorName: 'Mard_F20', hexValue: '#CD9391', r: 205, g: 147, b: 145),
  StandardColorData(colorId: 158, colorName: 'Mard_F21', hexValue: '#F7B4C6', r: 247, g: 180, b: 198),
  StandardColorData(colorId: 159, colorName: 'Mard_F22', hexValue: '#FDC0D0', r: 253, g: 192, b: 208),
  StandardColorData(colorId: 160, colorName: 'Mard_F23', hexValue: '#F67E66', r: 246, g: 126, b: 102),
  StandardColorData(colorId: 161, colorName: 'Mard_F24', hexValue: '#E698AA', r: 230, g: 152, b: 170),
  StandardColorData(colorId: 162, colorName: 'Mard_F25', hexValue: '#E54B4F', r: 229, g: 75, b: 79),
  // G系列 (G1-G21)
  StandardColorData(colorId: 163, colorName: 'Mard_G1', hexValue: '#FFE2CE', r: 255, g: 226, b: 206),
  StandardColorData(colorId: 164, colorName: 'Mard_G2', hexValue: '#FFC4AA', r: 255, g: 196, b: 170),
  StandardColorData(colorId: 165, colorName: 'Mard_G3', hexValue: '#F4C3A5', r: 244, g: 195, b: 165),
  StandardColorData(colorId: 166, colorName: 'Mard_G4', hexValue: '#E1B383', r: 225, g: 179, b: 131),
  StandardColorData(colorId: 167, colorName: 'Mard_G5', hexValue: '#EDB045', r: 237, g: 176, b: 69),
  StandardColorData(colorId: 168, colorName: 'Mard_G6', hexValue: '#E99C17', r: 233, g: 156, b: 23),
  StandardColorData(colorId: 169, colorName: 'Mard_G7', hexValue: '#9D5B3E', r: 157, g: 91, b: 62),
  StandardColorData(colorId: 170, colorName: 'Mard_G8', hexValue: '#753832', r: 117, g: 56, b: 50),
  StandardColorData(colorId: 171, colorName: 'Mard_G9', hexValue: '#E6B483', r: 230, g: 180, b: 131),
  StandardColorData(colorId: 172, colorName: 'Mard_G10', hexValue: '#D98C39', r: 217, g: 140, b: 57),
  StandardColorData(colorId: 173, colorName: 'Mard_G11', hexValue: '#E0C593', r: 224, g: 197, b: 147),
  StandardColorData(colorId: 174, colorName: 'Mard_G12', hexValue: '#FFC890', r: 255, g: 200, b: 144),
  StandardColorData(colorId: 175, colorName: 'Mard_G13', hexValue: '#B7714A', r: 183, g: 113, b: 74),
  StandardColorData(colorId: 176, colorName: 'Mard_G14', hexValue: '#8D614C', r: 141, g: 97, b: 76),
  StandardColorData(colorId: 177, colorName: 'Mard_G15', hexValue: '#FCF9E0', r: 252, g: 249, b: 224),
  StandardColorData(colorId: 178, colorName: 'Mard_G16', hexValue: '#F2D9BA', r: 242, g: 217, b: 186),
  StandardColorData(colorId: 179, colorName: 'Mard_G17', hexValue: '#78524B', r: 120, g: 82, b: 75),
  StandardColorData(colorId: 180, colorName: 'Mard_G18', hexValue: '#FFE4CC', r: 255, g: 228, b: 204),
  StandardColorData(colorId: 181, colorName: 'Mard_G19', hexValue: '#E07935', r: 224, g: 121, b: 53),
  StandardColorData(colorId: 182, colorName: 'Mard_G20', hexValue: '#A94023', r: 169, g: 64, b: 35),
  StandardColorData(colorId: 183, colorName: 'Mard_G21', hexValue: '#B88558', r: 184, g: 133, b: 88),
  // H系列 (H1-H23)
  StandardColorData(colorId: 184, colorName: 'Mard_H1', hexValue: '#FDFBFF', r: 253, g: 251, b: 255),
  StandardColorData(colorId: 185, colorName: 'Mard_H2', hexValue: '#FEFFFF', r: 254, g: 255, b: 255),
  StandardColorData(colorId: 186, colorName: 'Mard_H3', hexValue: '#B6B1BA', r: 182, g: 177, b: 186),
  StandardColorData(colorId: 187, colorName: 'Mard_H4', hexValue: '#89858C', r: 137, g: 133, b: 140),
  StandardColorData(colorId: 188, colorName: 'Mard_H5', hexValue: '#48464E', r: 72, g: 70, b: 78),
  StandardColorData(colorId: 189, colorName: 'Mard_H6', hexValue: '#2F2B2F', r: 47, g: 43, b: 47),
  StandardColorData(colorId: 190, colorName: 'Mard_H7', hexValue: '#000000', r: 0, g: 0, b: 0),
  StandardColorData(colorId: 191, colorName: 'Mard_H8', hexValue: '#E7D6DB', r: 231, g: 214, b: 219),
  StandardColorData(colorId: 192, colorName: 'Mard_H9', hexValue: '#EDEDED', r: 237, g: 237, b: 237),
  StandardColorData(colorId: 193, colorName: 'Mard_H10', hexValue: '#EEE9EA', r: 238, g: 233, b: 234),
  StandardColorData(colorId: 194, colorName: 'Mard_H11', hexValue: '#CECDD5', r: 206, g: 205, b: 213),
  StandardColorData(colorId: 195, colorName: 'Mard_H12', hexValue: '#FFF5ED', r: 255, g: 245, b: 237),
  StandardColorData(colorId: 196, colorName: 'Mard_H13', hexValue: '#F5ECD2', r: 245, g: 236, b: 210),
  StandardColorData(colorId: 197, colorName: 'Mard_H14', hexValue: '#CFD7D3', r: 207, g: 215, b: 211),
  StandardColorData(colorId: 198, colorName: 'Mard_H15', hexValue: '#98A6A8', r: 152, g: 166, b: 168),
  StandardColorData(colorId: 199, colorName: 'Mard_H16', hexValue: '#1D1414', r: 29, g: 20, b: 20),
  StandardColorData(colorId: 200, colorName: 'Mard_H17', hexValue: '#F1EDED', r: 241, g: 237, b: 237),
  StandardColorData(colorId: 201, colorName: 'Mard_H18', hexValue: '#FFFDF0', r: 255, g: 253, b: 240),
  StandardColorData(colorId: 202, colorName: 'Mard_H19', hexValue: '#F6EFE2', r: 246, g: 239, b: 226),
  StandardColorData(colorId: 203, colorName: 'Mard_H20', hexValue: '#949FA3', r: 148, g: 159, b: 163),
  StandardColorData(colorId: 204, colorName: 'Mard_H21', hexValue: '#FFFBE1', r: 255, g: 251, b: 225),
  StandardColorData(colorId: 205, colorName: 'Mard_H22', hexValue: '#CACAD4', r: 202, g: 202, b: 212),
  StandardColorData(colorId: 206, colorName: 'Mard_H23', hexValue: '#9A9D94', r: 154, g: 157, b: 148),
  // M系列 (M1-M15)
  StandardColorData(colorId: 207, colorName: 'Mard_M1', hexValue: '#BCC6B8', r: 188, g: 198, b: 184),
  StandardColorData(colorId: 208, colorName: 'Mard_M2', hexValue: '#8AA386', r: 138, g: 163, b: 134),
  StandardColorData(colorId: 209, colorName: 'Mard_M3', hexValue: '#697D80', r: 105, g: 125, b: 128),
  StandardColorData(colorId: 210, colorName: 'Mard_M4', hexValue: '#E3D2BC', r: 227, g: 210, b: 188),
  StandardColorData(colorId: 211, colorName: 'Mard_M5', hexValue: '#D0CCAA', r: 208, g: 204, b: 170),
  StandardColorData(colorId: 212, colorName: 'Mard_M6', hexValue: '#B0A782', r: 176, g: 167, b: 130),
  StandardColorData(colorId: 213, colorName: 'Mard_M7', hexValue: '#B4A497', r: 180, g: 164, b: 151),
  StandardColorData(colorId: 214, colorName: 'Mard_M8', hexValue: '#B38281', r: 179, g: 130, b: 129),
  StandardColorData(colorId: 215, colorName: 'Mard_M9', hexValue: '#A58767', r: 165, g: 135, b: 103),
  StandardColorData(colorId: 216, colorName: 'Mard_M10', hexValue: '#C5B2BC', r: 197, g: 178, b: 188),
  StandardColorData(colorId: 217, colorName: 'Mard_M11', hexValue: '#9F7594', r: 159, g: 117, b: 148),
  StandardColorData(colorId: 218, colorName: 'Mard_M12', hexValue: '#644749', r: 100, g: 71, b: 73),
  StandardColorData(colorId: 219, colorName: 'Mard_M13', hexValue: '#D19066', r: 209, g: 144, b: 102),
  StandardColorData(colorId: 220, colorName: 'Mard_M14', hexValue: '#C77362', r: 199, g: 115, b: 98),
  StandardColorData(colorId: 221, colorName: 'Mard_M15', hexValue: '#757D78', r: 117, g: 125, b: 120),
];

/// Riverpod Provider - 数据库实例
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
