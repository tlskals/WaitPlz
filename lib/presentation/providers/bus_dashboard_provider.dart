import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/local_storage_service.dart';
import '../../data/models/bus_arrival_info.dart';
import '../../data/models/favorite_route.dart';
import '../../data/repositories/bus_repository.dart';
import 'settings_provider.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main()');
});

final busRepositoryProvider = Provider<BusRepository>((ref) {
  return BusRepository();
});

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
