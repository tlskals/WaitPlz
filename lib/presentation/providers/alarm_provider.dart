import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/services/location_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/transit_alarm_item.dart';
import 'bus_dashboard_provider.dart';
import 'settings_provider.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// 사용자 실시간 위치 상태 모델
class UserLocationState {
  final Position? position;
  final bool isTracking;
  final bool hasPermission;
  final String? errorMessage;

  const UserLocationState({
    this.position,
    this.isTracking = false,
    this.hasPermission = true,
    this.errorMessage,
  });

  UserLocationState copyWith({
    Position? position,
    bool? isTracking,
    bool? hasPermission,
    String? errorMessage,
  }) {
    return UserLocationState(
      position: position ?? this.position,
      isTracking: isTracking ?? this.isTracking,
      hasPermission: hasPermission ?? this.hasPermission,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 사용자 위치 추적 Notifier
class UserLocationNotifier extends Notifier<UserLocationState> {
  late final LocationService _locationService;
  StreamSubscription<Position>? _positionSubscription;

  @override
  UserLocationState build() {
    _locationService = ref.watch(locationServiceProvider);
    _initLocation();
    ref.onDispose(() {
      _positionSubscription?.cancel();
    });
    return const UserLocationState(isTracking: false);
  }

  Future<void> _initLocation() async {
    final hasPerm = await _locationService.checkAndRequestPermission();
    if (!hasPerm) {
      state = state.copyWith(
        hasPermission: false,
        errorMessage: '위치 권한이 필요합니다.',
      );
      return;
    }

    // 1. 초기 위치 즉시 획득
    final initialPos = await _locationService.getCurrentPosition();
    state = state.copyWith(
      position: initialPos,
      isTracking: true,
      hasPermission: true,
    );

    // 2. 실시간 위치 스트림 구독 (10m 간격)
    await _positionSubscription?.cancel();
    _positionSubscription = _locationService.getPositionStream().listen(
      (pos) {
        state = state.copyWith(position: pos, isTracking: true);
        // 위치 갱신 시 알람 매니저에게 위치 업데이트 알림
        ref.read(alarmProvider.notifier).onUserPositionUpdated(pos);
      },
      onError: (err) {
        state = state.copyWith(errorMessage: err.toString());
      },
    );
  }

  /// 사용자가 수동으로 '현재 위치' 갱신 요청 시
  Future<Position?> refreshCurrentPosition() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null) {
      state = state.copyWith(position: pos, isTracking: true);
      ref.read(alarmProvider.notifier).onUserPositionUpdated(pos);
    }
    return pos;
  }
}

final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocationState>(
        UserLocationNotifier.new);

/// 활성화된 알람별 목적지까지 남은 거리(미터) Map Provider
final alarmDistancesProvider = Provider<Map<String, double>>((ref) {
  final alarms = ref.watch(alarmProvider);
  final locationState = ref.watch(userLocationProvider);
  final pos = locationState.position;
  final locationService = ref.watch(locationServiceProvider);

  if (pos == null) return {};

  final Map<String, double> distanceMap = {};
  for (final alarm in alarms) {
    if (alarm.isEnabled) {
      final distance = locationService.calculateDistance(
        pos.latitude,
        pos.longitude,
        alarm.targetLatitude,
        alarm.targetLongitude,
      );
      distanceMap[alarm.id] = distance;
    }
  }
  return distanceMap;
});

/// 스마트 하차 알람 관리 Notifier
class AlarmNotifier extends Notifier<List<TransitAlarmItem>> {
  LocalStorageService get _storage => ref.read(localStorageServiceProvider);
  LocationService get _locationService => ref.read(locationServiceProvider);
  final NotificationService _notificationService = NotificationService();
  final Set<String> _triggeredAlarmIds = {};

  @override
  List<TransitAlarmItem> build() {
    ref.watch(localStorageServiceProvider);
    ref.watch(locationServiceProvider);
    return _storage.getTransitAlarms();
  }

  Future<void> toggleAlarm(String id, bool isEnabled) async {
    await _storage.toggleTransitAlarm(id, isEnabled);
    if (!isEnabled) {
      _triggeredAlarmIds.remove(id);
    }
    state = _storage.getTransitAlarms();
  }

  Future<void> addAlarm(TransitAlarmItem alarm) async {
    await _storage.addTransitAlarm(alarm);
    state = _storage.getTransitAlarms();
  }

  Future<void> deleteAlarm(String id) async {
    await _storage.deleteTransitAlarm(id);
    _triggeredAlarmIds.remove(id);
    state = _storage.getTransitAlarms();
  }

  /// 위치 스트림에서 실시간 위치 수신 시 지오펜싱 판정
  void onUserPositionUpdated(Position pos) {
    for (final alarm in state) {
      if (!alarm.isEnabled) continue;

      final distance = _locationService.calculateDistance(
        pos.latitude,
        pos.longitude,
        alarm.targetLatitude,
        alarm.targetLongitude,
      );

      // 설정 반경 이내 진입 시 알람 트리거
      if (distance <= alarm.radiusMeters) {
        if (!_triggeredAlarmIds.contains(alarm.id)) {
          _triggeredAlarmIds.add(alarm.id);
          final settings = ref.read(settingsProvider);
          _notificationService.triggerGetOffAlarm(
            stationName: alarm.targetStationName,
            busRouteName: alarm.busRouteName,
            vibrationIntensity: settings.vibrationIntensity,
          );
        }
      } else if (distance > alarm.radiusMeters * 1.5) {
        // 반경 1.5배 이상 벗어나면 다음 여정을 위해 트리거 상태 초기화
        _triggeredAlarmIds.remove(alarm.id);
      }
    }
  }

  /// 테스트 알람 울리기 (실제 진동 및 헤드업 푸시 알림 발송)
  Future<void> testAlarm(TransitAlarmItem alarm) async {
    final settings = ref.read(settingsProvider);
    await _notificationService.triggerGetOffAlarm(
      stationName: alarm.targetStationName,
      busRouteName: alarm.busRouteName,
      vibrationIntensity: settings.vibrationIntensity,
    );
  }
}

final alarmProvider =
    NotifierProvider<AlarmNotifier, List<TransitAlarmItem>>(AlarmNotifier.new);
