import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/app_update_service.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>((ref) {
  return AppUpdateService();
});

final currentVersionProvider = FutureProvider<String>((ref) {
  return ref.watch(appUpdateServiceProvider).getCurrentVersion();
});

final updateCheckProvider = FutureProvider.autoDispose<UpdateCheckResult>((ref) {
  return ref.watch(appUpdateServiceProvider).checkForUpdate();
});

final updateDownloadProvider = StateProvider<double?>((ref) => null);
