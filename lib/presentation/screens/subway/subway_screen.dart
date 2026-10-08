import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/subway_provider.dart';

class SubwayScreen extends ConsumerWidget {
  const SubwayScreen({super.key});

  Color _getLineColor(String lineName) {
    if (lineName.contains('1호선')) return AppColors.subwayLine1;
    if (lineName.contains('2호선')) return AppColors.subwayLine2;
    if (lineName.contains('3호선')) return AppColors.subwayLine3;
    if (lineName.contains('4호선')) return AppColors.subwayLine4;
    if (lineName.contains('5호선')) return AppColors.subwayLine5;
    if (lineName.contains('9호선')) return AppColors.subwayLine9;
    if (lineName.contains('신분당선')) return AppColors.subwayShinbundang;
    if (lineName.contains('수인분당')) return AppColors.subwaySuinBundang;
    return AppColors.neonLime;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStation = ref.watch(selectedSubwayStationProvider);
    final arrivalsAsync = ref.watch(subwayArrivalsProvider);
    final alertsAsync = ref.watch(subwayAlertsProvider);

    final popularStations = ['강남', '사당', '판교', '서울역', '신도림', '잠실', '여의도'];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🚇 지하철 & 지연알림',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neonLime),
            onPressed: () {
              ref.invalidate(subwayArrivalsProvider);
              ref.invalidate(subwayAlertsProvider);
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. 긴급 공지 / 시위 / 연착 사유 배너 섹션
          alertsAsync.when(
            data: (alerts) {
              if (alerts.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.campaign, color: AppColors.urgentWarning, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '실시간 지하철 지연 및 운행 공지',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ...alerts.map((alert) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: alert.isEmergency
                                  ? const Color(0xFF331414)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: alert.isEmergency
                                    ? AppColors.urgentWarning.withValues(alpha: 0.6)
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alert.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: alert.isEmergency
                                        ? const Color(0xFFFCA5A5)
                                        : AppColors.neonLime,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  alert.content,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // 2. 주요 역 선택 가로 칩 리스트
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '자주 찾는 역 바로보기',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: popularStations.map((st) {
                        final isSelected = selectedStation == st;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(st),
                            selected: isSelected,
                            selectedColor: AppColors.neonLime,
                            backgroundColor: AppColors.surface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                ref.read(selectedSubwayStationProvider.notifier).setStation(st);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. 실시간 도착 정보 목록
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                '📍 [$selectedStation역] 실시간 열차 도착',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ),
          ),

          arrivalsAsync.when(
            data: (arrivals) {
              if (arrivals.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text('도착 정보가 없습니다.', style: TextStyle(color: AppColors.textSecondary))),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = arrivals[index];
                    final lineColor = _getLineColor(item.lineName);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: lineColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.lineName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.direction,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                item.arrivalTimeText,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.neonLime,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.train, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '현재 위치: ${item.arrivalMessage}',
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          if (item.isDelayed) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF331414),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, size: 14, color: AppColors.urgentWarning),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${item.delayMinutes}분 지연 예상: ${item.delayReason ?? '혼잡 지연'}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFFCA5A5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  childCount: arrivals.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.neonLime),
                ),
              ),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Center(child: Text('에러 발생: $err', style: const TextStyle(color: AppColors.urgentWarning))),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
