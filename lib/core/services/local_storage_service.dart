import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/favorite_route.dart';
import '../../data/models/transit_alarm_item.dart';

class LocalStorageService {
  static const String _keyFavoriteRoutes = 'favorite_routes_v1';
  static const String _keyTransitAlarms = 'transit_alarms_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    await service._initSampleDataIfEmpty();
    return service;
  }

  /// 최초 실행 시 직장인 맞춤형 샘플 데이터 세팅 (출근/퇴근 프리셋)
  Future<void> _initSampleDataIfEmpty() async {
    if (!_prefs.containsKey(_keyFavoriteRoutes)) {
      final defaultRoutes = [
        const FavoriteRoute(
          id: 'sample_route_1',
          routeId: '100100073',
          routeName: '9401',
          routeType: '광역',
          stationId: '206000001',
          stationName: '서현역.AK플라자',
          direction: '서울역버스환승센터 방면',
          stationSeq: '15',
          tag: CommuteTag.commuteToWork,
          orderIndex: 0,
          isDefault: true,
        ),
        const FavoriteRoute(
          id: 'sample_route_2',
          routeId: '100100582',
          routeName: 'M5107',
          routeType: '광역',
          stationId: '228000710',
          stationName: '영통역',
          direction: '서울역 방면',
          stationSeq: '5',
          tag: CommuteTag.commuteToWork,
          orderIndex: 1,
        ),
        const FavoriteRoute(
          id: 'sample_route_3',
          routeId: '100100073',
          routeName: '9401',
          routeType: '광역',
          stationId: '101000001',
          stationName: '순천향대학병원',
          direction: '분당 구미동 방면',
          stationSeq: '32',
          tag: CommuteTag.commuteHome,
          orderIndex: 0,
        ),
      ];
      await saveFavoriteRoutes(defaultRoutes);
    }

    if (!_prefs.containsKey(_keyTransitAlarms)) {
      final defaultAlarms = [
        TransitAlarmItem(
          id: 'sample_alarm_1',
          title: '퇴근길 서현역 하차',
          targetStationName: '서현역.AK플라자 (분당)',
          targetLatitude: 37.3849,
          targetLongitude: 127.1232,
          radiusMeters: 800.0,
          isEnabled: true,
          busRouteName: '9401번',
          createdAt: DateTime.now(),
        ),
        TransitAlarmItem(
          id: 'sample_alarm_2',
          title: '출근길 순천향대병원 하차',
          targetStationName: '순천향대학병원.한남동',
          targetLatitude: 37.5345,
          targetLongitude: 127.0062,
          radiusMeters: 600.0,
          isEnabled: false,
          busRouteName: '9401번',
          createdAt: DateTime.now(),
        ),
      ];
      await saveTransitAlarms(defaultAlarms);
    }
  }

  // --- 즐겨찾기 버스 노선 관리 ---
  List<FavoriteRoute> getFavoriteRoutes() {
    final jsonList = _prefs.getStringList(_keyFavoriteRoutes) ?? [];
    return jsonList.map((e) => FavoriteRoute.fromJson(e)).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  }

  Future<void> saveFavoriteRoutes(List<FavoriteRoute> routes) async {
    final jsonList = routes.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_keyFavoriteRoutes, jsonList);
  }

  Future<void> addFavoriteRoute(FavoriteRoute route) async {
    final routes = getFavoriteRoutes();
    routes.add(route);
    await saveFavoriteRoutes(routes);
  }

  Future<void> deleteFavoriteRoute(String id) async {
    final routes = getFavoriteRoutes()..removeWhere((e) => e.id == id);
    await saveFavoriteRoutes(routes);
  }

  // --- 하차 알람 관리 ---
  List<TransitAlarmItem> getTransitAlarms() {
    final jsonList = _prefs.getStringList(_keyTransitAlarms) ?? [];
    return jsonList.map((e) => TransitAlarmItem.fromJson(e)).toList();
  }

  Future<void> saveTransitAlarms(List<TransitAlarmItem> alarms) async {
    final jsonList = alarms.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_keyTransitAlarms, jsonList);
  }

  Future<void> addTransitAlarm(TransitAlarmItem alarm) async {
    final alarms = getTransitAlarms();
    alarms.insert(0, alarm);
    await saveTransitAlarms(alarms);
  }

  Future<void> toggleTransitAlarm(String id, bool isEnabled) async {
    final alarms = getTransitAlarms();
    final index = alarms.indexWhere((e) => e.id == id);
    if (index != -1) {
      alarms[index] = alarms[index].copyWith(isEnabled: isEnabled);
      await saveTransitAlarms(alarms);
    }
  }

  Future<void> deleteTransitAlarm(String id) async {
    final alarms = getTransitAlarms()..removeWhere((e) => e.id == id);
    await saveTransitAlarms(alarms);
  }
}
