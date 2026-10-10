import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/favorite_route.dart';
import '../../data/models/transit_alarm_item.dart';

class LocalStorageService {
  static const String _keyFavoriteRoutes = 'favorite_routes_v2';
  static const String _keyTransitAlarms = 'transit_alarms_v1';
  static const String _keyFavoriteSubwayStations = 'favorite_subway_stations_v1';
  static const String _keyAppSettings = 'app_settings_v1';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    await service._initSampleDataIfEmpty();
    return service;
  }

  /// 최초 실행 시 직장인/통학생 맞춤형 다양한 버스 샘플 데이터 세팅 (간선, 지선, 광역)
  Future<void> _initSampleDataIfEmpty() async {
    if (!_prefs.containsKey(_keyFavoriteRoutes)) {
      final defaultRoutes = [
        const FavoriteRoute(
          id: 'sample_route_143',
          routeId: '100100022',
          routeName: '143',
          routeType: '간선',
          stationId: '101000001',
          stationName: '강남역',
          directionA: '정릉 방면',
          directionB: '개포동 방면',
          orderIndex: 0,
        ),
        const FavoriteRoute(
          id: 'sample_route_7016',
          routeId: '100100345',
          routeName: '7016',
          routeType: '지선',
          stationId: '113000023',
          stationName: '홍대입구역',
          directionA: '상명대 방면',
          directionB: '은평차고지 방면',
          orderIndex: 1,
        ),
        const FavoriteRoute(
          id: 'sample_route_9401',
          routeId: '100100073',
          routeName: '9401',
          routeType: '광역',
          stationId: '206000001',
          stationName: '서현역.AK플라자',
          directionA: '서울역 방면',
          directionB: '분당 구미동 방면',
          orderIndex: 2,
        ),
        const FavoriteRoute(
          id: 'sample_route_420',
          routeId: '100100067',
          routeName: '420',
          routeType: '간선',
          stationId: '122000015',
          stationName: '역삼역',
          directionA: '청량리 방면',
          directionB: '개포동 방면',
          orderIndex: 3,
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

    if (!_prefs.containsKey(_keyFavoriteSubwayStations)) {
      await _prefs.setStringList(_keyFavoriteSubwayStations, ['강남', '판교', '여의도']);
    }
  }

  // --- 지하철 즐겨찾기 역 관리 ---
  List<String> getFavoriteSubwayStations() {
    return _prefs.getStringList(_keyFavoriteSubwayStations) ?? ['강남', '판교', '여의도'];
  }

  Future<void> saveFavoriteSubwayStations(List<String> stations) async {
    await _prefs.setStringList(_keyFavoriteSubwayStations, stations);
  }

  Future<void> addFavoriteSubwayStation(String station) async {
    final list = getFavoriteSubwayStations();
    final clean = station.replaceAll('역', '').trim();
    if (!list.contains(clean)) {
      list.insert(0, clean);
      await saveFavoriteSubwayStations(list);
    }
  }

  Future<void> removeFavoriteSubwayStation(String station) async {
    final clean = station.replaceAll('역', '').trim();
    final list = getFavoriteSubwayStations()..remove(clean);
    await saveFavoriteSubwayStations(list);
  }

  Future<bool> toggleFavoriteSubwayStation(String station) async {
    final clean = station.replaceAll('역', '').trim();
    final list = getFavoriteSubwayStations();
    final isFav = list.contains(clean);
    if (isFav) {
      list.remove(clean);
    } else {
      list.insert(0, clean);
    }
    await saveFavoriteSubwayStations(list);
    return !isFav;
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

  // --- 앱 환경설정 관리 ---
  AppSettings getSettings() {
    final jsonStr = _prefs.getString(_keyAppSettings);
    if (jsonStr == null) {
      return const AppSettings();
    }
    try {
      return AppSettings.fromJson(jsonStr);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _prefs.setString(_keyAppSettings, settings.toJson());
  }

  /// 전체 데이터 초기화 및 기본 직장인 샘플 데이터 복원
  Future<void> resetToDefaultData() async {
    await _prefs.remove(_keyFavoriteRoutes);
    await _prefs.remove(_keyTransitAlarms);
    await _prefs.remove(_keyFavoriteSubwayStations);
    await _prefs.remove(_keyAppSettings);
    await _initSampleDataIfEmpty();
  }
}
