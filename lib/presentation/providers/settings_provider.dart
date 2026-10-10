import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/app_settings.dart';
import 'alarm_provider.dart';
import 'bus_dashboard_provider.dart';
import 'subway_dashboard_provider.dart';

class SettingsNotifier extends Notifier<AppSettings> {
  late final LocalStorageService _storage;
  final NotificationService _notificationService = NotificationService();

  @override
  AppSettings build() {
    _storage = ref.watch(localStorageServiceProvider);
    return _storage.getSettings();
  }

  Future<void> updateVibrationIntensity(VibrationIntensity intensity) async {
    final updated = state.copyWith(vibrationIntensity: intensity);
    await _storage.saveSettings(updated);
    state = updated;
  }

  Future<void> updateDefaultRadius(double radius) async {
    final updated = state.copyWith(defaultRadiusMeters: radius);
    await _storage.saveSettings(updated);
    state = updated;
  }

  Future<void> updateDefaultSound(bool enabled) async {
    final updated = state.copyWith(defaultSoundEnabled: enabled);
    await _storage.saveSettings(updated);
    state = updated;
  }

  Future<void> updateDefaultVibration(bool enabled) async {
    final updated = state.copyWith(defaultVibrationEnabled: enabled);
    await _storage.saveSettings(updated);
    state = updated;
  }

  Future<void> updateRefreshInterval(int seconds) async {
    final updated = state.copyWith(refreshIntervalSeconds: seconds);
    await _storage.saveSettings(updated);
    state = updated;
  }

  /// 진동 세기 즉시 테스트 (미리보기)
  Future<void> testVibration(VibrationIntensity intensity) async {
    await _notificationService.testVibration(intensity);
  }

  /// 데이터 전체 초기화 및 직장인 기본 샘플 데이터 복원
  Future<void> resetAllData() async {
    await _storage.resetToDefaultData();
    state = _storage.getSettings();
    // 타 프로바이더 상태도 갱신
    ref.invalidate(alarmProvider);
    ref.read(busDashboardProvider.notifier).loadDashboardData();
    ref.read(subwayDashboardProvider.notifier).loadDashboardData();
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
