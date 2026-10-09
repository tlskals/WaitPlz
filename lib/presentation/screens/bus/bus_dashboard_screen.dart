import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/bus_arrival_info.dart';
import '../../../data/models/favorite_route.dart';
import '../../providers/bus_dashboard_provider.dart';
import '../../widgets/bus_arrival_card.dart';
import 'add_bus_route_screen.dart';

class BusDashboardScreen extends ConsumerWidget {
  const BusDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(busDashboardProvider);
    final favorites = dashboardState.allFavorites;

    final hour = dashboardState.lastUpdated.hour.toString().padLeft(2, '0');
    final minute = dashboardState.lastUpdated.minute.toString().padLeft(2, '0');
    final second = dashboardState.lastUpdated.second.toString().padLeft(2, '0');
    final formattedTime = '$hour:$minute:$second';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🚍 출퇴근 버스',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neonLime),
            tooltip: '실시간 새로고침',
            onPressed: () {
              ref.read(busDashboardProvider.notifier).loadDashboardData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonLime,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await ref.read(busDashboardProvider.notifier).loadDashboardData();
        },
        child: CustomScrollView(
          slivers: [
            // 상단: 15초 주기 실시간 자동 갱신 & 시간 표시
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.neonLime,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 7),
                        const Text(
                          '15초 주기 실시간 자동 갱신',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '$formattedTime 기준',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 버스 리스트 또는 빈 상태
            if (favorites.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_bus_outlined,
                          size: 60, color: AppColors.textMuted),
                      const SizedBox(height: 14),
                      const Text(
                        '등록된 버스가 없습니다.',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '우측 하단 + 버튼을 눌러 자주 타는 버스를 등록하세요.',
                        style:
                            TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final fav = favorites[index];
                    final arrival = dashboardState.arrivals.firstWhere(
                      (a) =>
                          a.routeName == fav.routeName &&
                          a.stationName == fav.stationName,
                      orElse: () => dashboardState.arrivals.firstWhere(
                        (a) => a.routeName == fav.routeName,
                        orElse: () => BusArrivalInfo(
                          routeId: fav.routeId,
                          routeName: fav.routeName,
                          routeType: fav.routeType,
                          stationId: fav.stationId,
                          stationName: fav.stationName,
                          directionA: DirectionArrival(
                            directionName: fav.directionA.isNotEmpty
                                ? fav.directionA
                                : '상행 방면',
                            arrivals: const [
                              SingleBusArrival(
                                  predictTimeSec: 240, locationNo: 2),
                            ],
                          ),
                          directionB: DirectionArrival(
                            directionName: fav.directionB.isNotEmpty
                                ? fav.directionB
                                : '하행 방면',
                            arrivals: const [
                              SingleBusArrival(
                                  predictTimeSec: 480, locationNo: 4),
                            ],
                          ),
                          updatedAt: DateTime.now(),
                        ),
                      ),
                    );

                    return BusArrivalCard(
                      favorite: fav,
                      arrivalInfo: arrival,
                      onDelete: () => _confirmDelete(context, ref, fav),
                    );
                  },
                  childCount: favorites.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddBusRouteScreen()),
          );
        },
        backgroundColor: AppColors.neonLime,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, FavoriteRoute fav) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('${fav.routeName}번 삭제',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Text('[${fav.stationName}] 정류장을 즐겨찾기에서 삭제하시겠습니까?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.urgentWarning,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(busDashboardProvider.notifier)
                  .deleteFavoriteRoute(fav.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
