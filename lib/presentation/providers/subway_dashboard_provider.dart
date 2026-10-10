import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/models/subway_arrival_info.dart';
import '../../data/repositories/subway_repository.dart';
import 'bus_dashboard_provider.dart';
import 'settings_provider.dart';

final subwayRepositoryProvider = Provider<SubwayRepository>((ref) {
  return SubwayRepository();
});

class SubwayDashboardState {
  final bool isLoading;
  final List<String> favoriteStations;
  final Map<String, List<SubwayArrivalInfo>> arrivalsMap;
  final DateTime lastUpdated;
  final String? errorMessage;

  const SubwayDashboardState({
    this.isLoading = false,
    this.favoriteStations = const [],
    this.arrivalsMap = const {},
    required this.lastUpdated,
    this.errorMessage,
  });

  SubwayDashboardState copyWith({
    bool? isLoading,
    List<String>? favoriteStations,
    Map<String, List<SubwayArrivalInfo>>? arrivalsMap,
    DateTime? lastUpdated,
    String? errorMessage,
  }) {
    return SubwayDashboardState(
      isLoading: isLoading ?? this.isLoading,
      favoriteStations: favoriteStations ?? this.favoriteStations,
      arrivalsMap: arrivalsMap ?? this.arrivalsMap,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage,
    );
  }
}

class SubwayDashboardNotifier extends Notifier<SubwayDashboardState> {
  late final LocalStorageService _storage;
  late final SubwayRepository _subwayRepo;
  Timer? _autoRefreshTimer;

  @override
  SubwayDashboardState build() {
    _storage = ref.watch(localStorageServiceProvider);
    _subwayRepo = ref.watch(subwayRepositoryProvider);

    ref.onDispose(() {
      _autoRefreshTimer?.cancel();
    });

    final refreshSeconds =
        ref.watch(settingsProvider.select((s) => s.refreshIntervalSeconds));
    _autoRefreshTimer?.cancel();
    if (refreshSeconds > 0) {
      _autoRefreshTimer =
          Timer.periodic(Duration(seconds: refreshSeconds), (_) {
        refreshArrivalsOnly();
      });
    }

    Future.microtask(() => loadDashboardData());
    return SubwayDashboardState(lastUpdated: DateTime.now());
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final stations = _storage.getFavoriteSubwayStations();
      final arrivalsMap = await _subwayRepo.fetchArrivalsForStations(stations);
      state = state.copyWith(
        isLoading: false,
        favoriteStations: stations,
        arrivalsMap: arrivalsMap,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '지하철 도착 정보를 불러오지 못했습니다: $e',
      );
    }
  }

  Future<void> refreshArrivalsOnly() async {
    if (state.favoriteStations.isEmpty) return;
    try {
      final arrivalsMap =
          await _subwayRepo.fetchArrivalsForStations(state.favoriteStations);
      state = state.copyWith(
        arrivalsMap: arrivalsMap,
        lastUpdated: DateTime.now(),
      );
    } catch (_) {}
  }

  /// 별(★) 버튼 클릭 시 호출: 즐겨찾기 즉시 토글
  Future<bool> toggleFavoriteStation(String stationName) async {
    final clean = stationName.replaceAll('역', '').trim();
    final isAdded = await _storage.toggleFavoriteSubwayStation(clean);
    final updatedList = _storage.getFavoriteSubwayStations();

    // 즐겨찾기 상태 갱신
    state = state.copyWith(favoriteStations: updatedList);

    if (isAdded) {
      // 새로 추가된 역의 도착 정보 가져오기
      try {
        final newArrivals = await _subwayRepo.fetchSubwayArrivals(clean);
        final newMap = Map<String, List<SubwayArrivalInfo>>.from(state.arrivalsMap);
        newMap[clean] = newArrivals;
        state = state.copyWith(arrivalsMap: newMap);
      } catch (_) {}
    } else {
      // 삭제된 역 제거
      final newMap = Map<String, List<SubwayArrivalInfo>>.from(state.arrivalsMap);
      newMap.remove(clean);
      state = state.copyWith(arrivalsMap: newMap);
    }

    return isAdded;
  }

  bool isFavorite(String stationName) {
    final clean = stationName.replaceAll('역', '').trim();
    return state.favoriteStations.contains(clean);
  }
}

final subwayDashboardProvider =
    NotifierProvider<SubwayDashboardNotifier, SubwayDashboardState>(
        SubwayDashboardNotifier.new);
