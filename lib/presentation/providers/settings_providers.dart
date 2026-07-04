import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/user_settings_service.dart';

final userSettingsServiceProvider = Provider<UserSettingsService>((ref) {
  return UserSettingsService();
});

final settingsLoadedProvider = FutureProvider<void>((ref) {
  return ref.watch(userSettingsServiceProvider).load();
});

final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  final service = ref.watch(userSettingsServiceProvider);
  ref.watch(settingsLoadedProvider);
  return UserSettingsNotifier(service);
});

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  final UserSettingsService _service;

  UserSettingsNotifier(this._service) : super(_service.settings) {
    state = _service.settings;
  }

  Future<void> setLowStockThreshold(int value) async {
    state = state.copyWith(lowStockThreshold: value);
    await _service.save(state);
  }

  Future<void> setDefaultRestockQty(int value) async {
    state = state.copyWith(defaultRestockQty: value);
    await _service.save(state);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _service.save(state);
  }
}

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(userSettingsProvider).themeMode;
});
