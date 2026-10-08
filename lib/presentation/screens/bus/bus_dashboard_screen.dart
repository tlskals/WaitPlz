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
    final selectedTag = ref.watch(selectedCommuteTagProvider);

    // 태그 필터링
    final filteredFavorites = selectedTag == CommuteTag.general
        ? dashboardState.allFavorites
        : dashboardState.allFavorites.where((f) => f.tag == selectedTag).toList();

    // 연속 배차 감지 여부
    final hasClusteredBuses = dashboardState.arrivals.any((a) => a.isClusteredBus);

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
            // 상단: 출근/퇴근 필터 탭 & 갱신 시간
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Column(
                  children: [
                    // 루틴 선택 세그먼트
                    Row(
                      children: [
                        _buildRoutineChip(
                          context,
                          ref,
                          label: '☀️ 출근길',
                          tag: CommuteTag.commuteToWork,
                          isSelected: selectedTag == CommuteTag.commuteToWork,
                        ),
                        const SizedBox(width: 8),
                        _buildRoutineChip(
                          context,
                          ref,
                          label: '🌙 퇴근길',
                          tag: CommuteTag.commuteHome,
                          isSelected: selectedTag == CommuteTag.commuteHome,
                        ),
                        const SizedBox(width: 8),
                        _buildRoutineChip(
                          context,
                          ref,
                          label: '전체',
                          tag: CommuteTag.general,
                          isSelected: selectedTag == CommuteTag.general,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
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
                            const SizedBox(width: 6),
                            const Text(
                              '15초 주기 실시간 자동 갱신 중',
                              style: TextStyle(
                                fontSize: 12,
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
                  ],
                ),
              ),
            ),

            // 연속 배차 경고 배너
            if (hasClusteredBuses)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF33170B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF7C2D12)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.directions_bus_filled, color: AppColors.imminentArrival, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '현재 일부 버스가 1~2개 정류장 간격으로 연속 운행 중입니다. 뒤차 탑승을 추천합니다.',
                          style: TextStyle(fontSize: 13, color: Color(0xFFFDBA74), fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 버스 리스트 또는 빈 상태
            if (filteredFavorites.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_bus_outlined, size: 60, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      const Text(
                        '등록된 출퇴근 버스가 없습니다.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '우측 하단 + 버튼을 눌러 자주 타는 버스를 등록하세요.',
                        style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final fav = filteredFavorites[index];
                    final arrival = dashboardState.arrivals.firstWhere(
                      (a) => a.routeName == fav.routeName && a.stationName == fav.stationName,
                      orElse: () => dashboardState.arrivals.firstWhere(
                        (a) => a.routeName == fav.routeName,
                        orElse: () => dashboardState.arrivals.isNotEmpty
                            ? dashboardState.arrivals.first
                            : BusArrivalInfo(
                                routeId: fav.routeId,
                                routeName: fav.routeName,
                                routeType: fav.routeType,
                                stationId: fav.stationId,
                                stationName: fav.stationName,
                                stationSeq: '1',
                                predictTimeSec1: 300,
                                locationNo1: 3,
                                predictTimeSec2: 900,
                                locationNo2: 7,
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
                  childCount: filteredFavorites.length,
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

  Widget _buildRoutineChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required CommuteTag tag,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedCommuteTagProvider.notifier).setTag(tag);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.neonLime : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.neonLime : AppColors.cardBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, FavoriteRoute fav) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text('${fav.routeName}번 삭제', style: const TextStyle(color: AppColors.textPrimary)),
        content: Text('[${fav.stationName}] 정류장을 즐겨찾기에서 삭제하시겠습니까?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.urgentWarning,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ref.read(busDashboardProvider.notifier).deleteFavoriteRoute(fav.id);
              Navigator.of(ctx).pop();
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
