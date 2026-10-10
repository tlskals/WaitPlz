import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/subway_graph_service.dart';
import '../../providers/subway_provider.dart';
import 'subway_map_viewer.dart';

class SubwayScreen extends ConsumerStatefulWidget {
  const SubwayScreen({super.key});

  @override
  ConsumerState<SubwayScreen> createState() => _SubwayScreenState();
}

class _SubwayScreenState extends ConsumerState<SubwayScreen> {
  final _searchController = TextEditingController();
  final _startStationController = TextEditingController();
  final _endStationController = TextEditingController();

  int _selectedTabMode = 0; // 0: 노선도 & 환승 경로, 1: 실시간 역 도착

  String? _startStation = '판교';
  String? _endStation = '광화문';
  SubwayRoutePlan? _activeRoutePlan;

  final SubwayGraphService _graphService = SubwayGraphService();

  @override
  void initState() {
    super.initState();
    _startStationController.text = _startStation ?? '';
    _endStationController.text = _endStation ?? '';
    // 초기 추천 경로 자동 계산
    _calculateRoute();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _startStationController.dispose();
    _endStationController.dispose();
    super.dispose();
  }

  void _calculateRoute() {
    if (_startStation == null || _endStation == null) return;
    final plan = _graphService.findOptimalRoute(_startStation!, _endStation!);
    setState(() {
      _activeRoutePlan = plan;
    });
  }

  void _swapStations() {
    setState(() {
      final temp = _startStation;
      _startStation = _endStation;
      _endStation = temp;

      _startStationController.text = _startStation ?? '';
      _endStationController.text = _endStation ?? '';
    });
    _calculateRoute();
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

  /// 노선도에서 특정 역 탭 시 바텀 모달 오픈
  void _onStationTappedOnMap(String stationName) {
    ref.read(selectedSubwayStationProvider.notifier).setStation(stationName);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _buildStationDetailModal(ctx, stationName),
    );
  }

  Widget _buildStationDetailModal(BuildContext ctx, String stationName) {
    final arrivalsAsync = ref.watch(subwayArrivalsProvider);
    final stationNode = _graphService.stations[stationName];
    final lines = stationNode?.lines ?? ['수도권 전철'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들바
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 역 이름 및 호선 뱃지
          Row(
            children: [
              Text(
                '$stationName역',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              ...lines.map((l) => Container(
                    margin: const EdgeInsets.only(right: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getLineColor(l).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getLineColor(l), width: 1.2),
                    ),
                    child: Text(
                      l,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _getLineColor(l),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 14),

          // 출발역 / 도착역 지정 액션 버튼
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _startStation = stationName;
                      _startStationController.text = stationName;
                    });
                    _calculateRoute();
                  },
                  icon: const Icon(Icons.flag, color: Colors.black, size: 16),
                  label: const Text('출발역 지정',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonLime,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _endStation = stationName;
                      _endStationController.text = stationName;
                    });
                    _calculateRoute();
                  },
                  icon: const Icon(Icons.sports_score,
                      color: Colors.white, size: 16),
                  label: const Text('도착역 지정',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 실시간 도착 정보 미리보기
          const Text(
            '⚡ 실시간 열차 도착 현황 (서울시 공식)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),

          arrivalsAsync.when(
            data: (arrivals) {
              if (arrivals.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('현재 운행 중인 열차 도착 정보가 없습니다.',
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                );
              }
              return Column(
                children: arrivals.take(3).map((a) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${a.lineName} • ${a.direction}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          a.arrivalMessage,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.neonLime,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(strokeWidth: 2),
            )),
            error: (error, stack) => const Text('도착 정보 로드 실패',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '🚇 수도권 지하철 & 환승',
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neonLime),
            tooltip: '새로고침',
            onPressed: () {
              ref.invalidate(subwayArrivalsProvider);
              ref.invalidate(subwayAlertsProvider);
              _calculateRoute();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 0. 모드 선택 세그먼트 (노선도 & 환승 경로 vs 실시간 역 도착)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabMode = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _selectedTabMode == 0
                            ? AppColors.neonLime
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '🗺️ 노선도 & 환승 경로',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _selectedTabMode == 0
                                ? Colors.black
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTabMode = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _selectedTabMode == 1
                            ? AppColors.neonLime
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '⚡ 실시간 역 도착',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: _selectedTabMode == 1
                                ? Colors.black
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 모드에 따른 화면 전환
          Expanded(
            child: _selectedTabMode == 0
                ? _buildSubwayMapAndRouteView()
                : _buildStationArrivalListView(),
          ),
        ],
      ),
    );
  }

  /// 1. 노선도 & 환승 경로 모드 뷰
  Widget _buildSubwayMapAndRouteView() {
    return Stack(
      children: [
        // 전체 화면 인터랙티브 노선도 캔버스
        Positioned.fill(
          child: SubwayMapViewer(
            startStation: _startStation,
            endStation: _endStation,
            activeRoutePlan: _activeRoutePlan,
            onStationSelected: _onStationTappedOnMap,
          ),
        ),

        // 상단 출발/도착 경로 지정 플로팅 바
        Positioned(
          top: 10,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // 출발역 인풋
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.neonLime.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        const Text('🚩', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _startStation != null
                                ? '${_startStation!}역'
                                : '출발역 선택',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _startStation != null
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 출발/도착 반전 버튼
                IconButton(
                  onPressed: _swapStations,
                  icon: const Icon(Icons.swap_horiz,
                      color: AppColors.neonLime, size: 22),
                  tooltip: '출발/도착 반전',
                ),

                // 도착역 인풋
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        const Text('🏁', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _endStation != null
                                ? '${_endStation!}역'
                                : '도착역 선택',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: _endStation != null
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 하단 경로 탐색 결과 요약 & 빠른 환승 안내 카드
        if (_activeRoutePlan != null)
          Positioned(
            bottom: 12,
            left: 14,
            right: 14,
            child: _buildRouteResultCard(_activeRoutePlan!),
          ),
      ],
    );
  }

  /// 경로 탐색 결과 카드
  Widget _buildRouteResultCard(SubwayRoutePlan plan) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.neonLime.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 요약 헤더 (총 소요 시간, 경유 역 수, 환승 횟수)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonLime,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '약 ${plan.totalMinutes}분 소요',
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${plan.stationCount}개 역 이동 • 환승 ${plan.transferCount}회',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _activeRoutePlan = null;
                  });
                },
                child: const Icon(Icons.close,
                    color: AppColors.textSecondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 구간별 환승 안내 리스트
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: plan.segments.length,
              separatorBuilder: (context, index) =>
                  const Divider(color: AppColors.cardBorder, height: 12),
              itemBuilder: (context, index) {
                final seg = plan.segments[index];
                final lineColor = _getLineColor(seg.lineName);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: lineColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            seg.lineName,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${seg.fromStation}역 승차 ➡️ ${seg.toStation}역 (${seg.stations.length - 1}개 역, ${seg.durationMinutes}분)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (seg.fastTransferDoor != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_walk,
                                color: AppColors.neonLime, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '💡 ${seg.fastTransferDoor!}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      AppColors.neonLime.withValues(alpha: 0.95),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 2. 실시간 역 도착 & 지연 알림 리스트 뷰 (기존 뷰)
  Widget _buildStationArrivalListView() {
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

    return RefreshIndicator(
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
                style:
                    const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                textInputAction: TextInputAction.search,
                onSubmitted: _searchStation,
                decoration: InputDecoration(
                  hintText: '지하철 역 검색 (예: 서울역, 강남, 판교, 신촌)',
                  hintStyle:
                      const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.neonLime),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward,
                        color: AppColors.neonLime),
                    onPressed: () => _searchStation(_searchController.text),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AppColors.neonLime, width: 1.5),
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
                          color: isSelected
                              ? Colors.black
                              : AppColors.textSecondary,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w600,
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

          // 3. 긴급 공지 / 시위 / 연착 사유 배너
          alertsAsync.when(
            data: (alerts) {
              if (alerts.isEmpty) {
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              }
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: Column(
                    children: alerts.map((alert) {
                      return Container(
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
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            error: (err, stack) => const SliverToBoxAdapter(child: SizedBox.shrink()),
          ),

          // 4. 선택된 역 실시간 도착 현황 리스트 헤더
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: AppColors.urgentWarning, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        '[$selectedStation역] 실시간 열차 도착',
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const Row(
                    children: [
                      Icon(Icons.circle, color: AppColors.neonLime, size: 8),
                      SizedBox(width: 5),
                      Text(
                        '서울시 공식 실시간',
                        style: TextStyle(
                          fontSize: 12,
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

          // 도착 정보 리스트 바디
          arrivalsAsync.when(
            data: (arrivals) {
              if (arrivals.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.subway_outlined,
                            size: 54, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          '현재 $selectedStation역 도착 예정 열차가 없습니다.',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '첫차/막차 시간이거나 공공 API 데이터 집계 중입니다.',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12.5),
                        ),
                      ],
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
                          horizontal: 16, vertical: 6),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: lineColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.lineName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item.direction}행 (${item.arrivalMessage})',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '현재 위치: ${item.currentStation} • 상태: ${item.arrivalMessage}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: arrivals.length,
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.neonLime),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text('도착 정보 로드 실패: $err',
                    style: const TextStyle(color: AppColors.urgentWarning)),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}
