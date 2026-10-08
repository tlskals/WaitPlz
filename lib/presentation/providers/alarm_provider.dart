import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/transit_alarm_item.dart';
import 'bus_dashboard_provider.dart';

class AlarmNotifier extends Notifier<List<TransitAlarmItem>> {
  late final LocalStorageService _storage;
  final NotificationService _notificationService = NotificationService();

  @override
  List<TransitAlarmItem> build() {
    _storage = ref.watch(localStorageServiceProvider);
    return _storage.getTransitAlarms();
  }

  Future<void> toggleAlarm(String id, bool isEnabled) async {
    await _storage.toggleTransitAlarm(id, isEnabled);
    state = _storage.getTransitAlarms();
  }

  Future<void> addAlarm(TransitAlarmItem alarm) async {
    await _storage.addTransitAlarm(alarm);
    state = _storage.getTransitAlarms();
  }

  Future<void> deleteAlarm(String id) async {
    await _storage.deleteTransitAlarm(id);
    state = _storage.getTransitAlarms();
  }

  /// 테스트 알람 울리기 (실제 진동 및 헤드업 푸시 알림 발송)
  Future<void> testAlarm(TransitAlarmItem alarm) async {
    await _notificationService.triggerGetOffAlarm(
      stationName: alarm.targetStationName,
      busRouteName: alarm.busRouteName,
    );
  }
}

final alarmProvider =
    NotifierProvider<AlarmNotifier, List<TransitAlarmItem>>(AlarmNotifier.new);
