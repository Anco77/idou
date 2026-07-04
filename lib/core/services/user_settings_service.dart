import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class UserSettings {
  final int lowStockThreshold;
  final int defaultRestockQty;
  final ThemeMode themeMode;

  const UserSettings({
    this.lowStockThreshold = 500,
    this.defaultRestockQty = 100,
    this.themeMode = ThemeMode.light,
  });

  UserSettings copyWith({
    int? lowStockThreshold,
    int? defaultRestockQty,
    ThemeMode? themeMode,
  }) => UserSettings(
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    defaultRestockQty: defaultRestockQty ?? this.defaultRestockQty,
    themeMode: themeMode ?? this.themeMode,
  );

  Map<String, dynamic> toJson() => {
    'lowStockThreshold': lowStockThreshold,
    'defaultRestockQty': defaultRestockQty,
    'themeMode': themeMode.index,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    lowStockThreshold: json['lowStockThreshold'] as int? ?? 500,
    defaultRestockQty: json['defaultRestockQty'] as int? ?? 100,
    themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
  );
}

class UserSettingsService {
  static const _fileName = 'user_settings.json';
  UserSettings _settings = const UserSettings();

  UserSettings get settings => _settings;

  Future<void> load() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, _fileName));
      if (!file.existsSync()) return;
      final content = await file.readAsString();
      _settings = UserSettings.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } catch (_) {}
  }

  Future<void> save(UserSettings settings) async {
    _settings = settings;
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, _fileName));
      await file.writeAsString(jsonEncode(settings.toJson()));
    } catch (_) {}
  }

}
