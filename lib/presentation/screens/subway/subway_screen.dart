import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/subway_provider.dart';

class SubwayScreen extends ConsumerStatefulWidget {
  const SubwayScreen({super.key});

  @override
  ConsumerState<SubwayScreen> createState() => _SubwayScreenState();
}

class _SubwayScreenState extends ConsumerState<SubwayScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getLineColor(String lineName) {
    if (lineName.contains('1호선')) return const Color(0xFF0052A4);
    if (lineName.contains('2호선')) return const Color(0xFF00A84D);
    if (lineName.contains('3호선')) return const Color(0xFFEF7C1C);
    if (lineName.contains('4호선')) return const Color(0xFF00A5DE);
    if (lineName.contains('5호선')) return const Color(0xFF996CAC);
    if (lineName.contains('6호선')) return const Color(0xFFCD7C2F);
    if (lineName.contains('7호선')) return const Color(0xFF747F00);
    if (lineName.contains('8호선')) return const Color(0xFFEA545D);
    if (lineName.contains('9호선')) return const Color(0xFFBDB092);
    if (lineName.contains('신분당')) return const Color(0xFFD4003B);
    if (lineName.contains('수인분당')) return const Color(0xFFF5A200);
    if (lineName.contains('경의중앙')) return const Color(0xFF77C4A3);
    if (lineName.contains('공항철도')) return const Color(0xFF0090D2);
    if (lineName.contains('경강선')) return const Color(0xFF003DA5);
    if (lineName.contains('경춘선')) return const Color(0xFF0C8E72);
    if (lineName.contains('우이신설')) return const Color(0xFFB7C452);
    if (lineName.contains('신림선')) return const Color(0xFF6789CA);
    if (lineName.contains('GTX')) return const Color(0xFF9A6292);
    return AppColors.neonLime;
  }

  void _searchStation(String query) {
    final clean = query.trim().replaceAll('역', '');
    if (clean.isNotEmpty) {
      ref.read(selectedSubwayStationProvider.notifier).setStation(clean);
      _searchController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedStation = ref.watch(selectedSubwayStationProvider);
    final arrivalsAsync = ref.watch(subwayArrivalsProvider);
    final alertsAsync = ref.watch(subwayAlertsProvider);

    final popularStations = [
      '서울',
      '강남',
      '사당',
      '판교',
      '신도림',
      '홍대입구',
      '여의도',
      '고속터미널',
      '잠실',
      '수원',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🚇 지하철 & 지연알림',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neonLime),
            tooltip: '실시간 새로고침',
            onPressed: () {
              ref.invalidate(subwayArrivalsProvider);
              ref.invalidate(subwayAlertsProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonLime,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          ref.invalidate(subwayArrivalsProvider);
          ref.invalidate(subwayAlertsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // 1. 역 검색창
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  textInputAction: TextInputAction.search,
                  onSubmitted: _searchStation,
                  decoration: InputDecoration(
                    hintText: '지하철 역 검색 (예: 서울역, 강남, 판교, 신촌)',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: const Icon(Icons.search, color: AppColors.neonLime),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: AppColors.neonLime),
                      onPressed: () => _searchStation(_searchController.text),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.neonLime, width: 1.5),
                    ),
                  ),
                ),
              ),
            ),

            // 2. 주요 환승역 퀵 선택 칩 리스트
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: popularStations.map((st) {
                      final isSelected = selectedStation == st;
                      final displayName = st == '서울' ? '서울역' : st;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(displayName),
                          selected: isSelected,
                          selectedColor: AppColors.neonLime,
                          backgroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.neonLime
                                : AppColors.cardBorder,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 13,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              ref
                                  .read(selectedSubwayStationProvider.notifier)
                                  .setStation(st);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // 3. 긴급 공지 / 시위 / 연착 사유 배너 섹션
            alertsAsync.when(
              data: (alerts) {
                if (alerts.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...alerts.map((alert) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(13),
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
                                  Row(
                                    children: [
                                      Icon(
                                        alert.isEmergency
                                            ? Icons.warning_amber_rounded
                                            : Icons.campaign,
                                        size: 17,
                                        color: alert.isEmergency
                                            ? AppColors.urgentWarning
                                            : AppColors.neonLime,
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          alert.title,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w800,
                                            color: alert.isEmergency
                                                ? const Color(0xFFFCA5A5)
                                                : AppColors.neonLime,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    alert.content,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary,
                                      height: 1.35,
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
              error: (err, stack) =>
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),

            // 4. 실시간 도착 정보 헤더
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '📍 [${selectedStation == '서울' ? '서울역' : '$selectedStation역'}] 실시간 열차 도착',
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.neonLime,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          '서울시 공식 실시간',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.neonLime,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 5. 실시간 도착 목록 리스트
            arrivalsAsync.when(
              data: (arrivals) {
                if (arrivals.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        '현재 운행 중인 열차 도착 정보가 없습니다.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = arrivals[index];
                      final lineColor = _getLineColor(item.lineName);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 5),
                        padding: const EdgeInsets.all(15),
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
                                // 호선 뱃지
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: lineColor,
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    item.lineName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (item.isExpress) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.urgentWarning,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      '급행',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.direction,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  item.arrivalTimeText,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: item.arrivalTimeSec <= 180 ||
                                            item.arrivalMessage.contains('도착') ||
                                            item.arrivalMessage.contains('진입')
                                        ? AppColors.neonLime
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.train_outlined,
                                    size: 15, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text(
                                  '현재 상태: ${item.arrivalMessage}',
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
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
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      '실시간 도착 정보를 불러오지 못했습니다.',
                      style: const TextStyle(color: AppColors.urgentWarning),
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
