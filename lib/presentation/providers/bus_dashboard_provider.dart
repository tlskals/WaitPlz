import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/models/bus_arrival_info.dart';
import '../../data/models/favorite_route.dart';
import '../../data/repositories/bus_repository.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main()');
});

final busRepositoryProvider = Provider<BusRepository>((ref) {
  return BusRepository();
});

/// 현재 선택된 출퇴근 탭 상태 (출근길 / 퇴근길 / 전체)
class CommuteTagNotifier extends Notifier<CommuteTag> {
  @override
  CommuteTag build() {
    final hour = DateTime.now().hour;
    // 오전 0시~13시는 기본 [출근길], 오후 13시~24시는 기본 [퇴근길]로 스마트 전환
    return hour < 13 ? CommuteTag.commuteToWork : CommuteTag.commuteHome;
  }

  void setTag(CommuteTag tag) => state = tag;
}

final selectedCommuteTagProvider =
    NotifierProvider<CommuteTagNotifier, CommuteTag>(CommuteTagNotifier.new);

class BusDashboardState {
  final bool isLoading;
  final List<FavoriteRoute> allFavorites;
  final List<BusArrivalInfo> arrivals;
  final DateTime lastUpdated;
  final String? errorMessage;

  const BusDashboardState({
    this.isLoading = false,
    this.allFavorites = const [],
    this.arrivals = const [],
    required this.lastUpdated,
    this.errorMessage,
  });

  BusDashboardState copyWith({
    bool? isLoading,
    List<FavoriteRoute>? allFavorites,
    List<BusArrivalInfo>? arrivals,
    DateTime? lastUpdated,
    String? errorMessage,
  }) {
    return BusDashboardState(
      isLoading: isLoading ?? this.isLoading,
      allFavorites: allFavorites ?? this.allFavorites,
      arrivals: arrivals ?? this.arrivals,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: errorMessage,
    );
  }
}

class BusDashboardNotifier extends Notifier<BusDashboardState> {
  late final LocalStorageService _storage;
  late final BusRepository _busRepo;
  Timer? _autoRefreshTimer;

  @override
  BusDashboardState build() {
    _storage = ref.watch(localStorageServiceProvider);
    _busRepo = ref.watch(busRepositoryProvider);

    ref.onDispose(() {
      _autoRefreshTimer?.cancel();
    });

    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      refreshArrivalsOnly();
    });

    Future.microtask(() => loadDashboardData());
    return BusDashboardState(lastUpdated: DateTime.now());
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final favorites = _storage.getFavoriteRoutes();
      final arrivals = await _busRepo.fetchArrivalsForFavorites(favorites);
      state = state.copyWith(
        isLoading: false,
        allFavorites: favorites,
        arrivals: arrivals,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '버스 도착 정보를 불러오지 못했습니다: $e',
      );
    }
  }

  Future<void> refreshArrivalsOnly() async {
    if (state.allFavorites.isEmpty) return;
    try {
      final arrivals =
          await _busRepo.fetchArrivalsForFavorites(state.allFavorites);
      state = state.copyWith(
        arrivals: arrivals,
        lastUpdated: DateTime.now(),
      );
    } catch (_) {}
  }

  Future<void> addFavoriteRoute(FavoriteRoute route) async {
    await _storage.addFavoriteRoute(route);
    await loadDashboardData();
  }

  Future<void> deleteFavoriteRoute(String id) async {
    await _storage.deleteFavoriteRoute(id);
    await loadDashboardData();
  }
}

final busDashboardProvider =
    NotifierProvider<BusDashboardNotifier, BusDashboardState>(
        BusDashboardNotifier.new);
