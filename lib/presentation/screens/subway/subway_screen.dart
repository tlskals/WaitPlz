import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/subway_dashboard_provider.dart';
import '../../widgets/subway_station_card.dart';

/// 수도권 주요 역 및 호선 기본 데이터 (검색 자동완성용)
class SubwayStationSearchItem {
  final String name;
  final List<String> lines;

  const SubwayStationSearchItem({required this.name, required this.lines});
}

final List<SubwayStationSearchItem> _kSubwayStationDatabase = [
  const SubwayStationSearchItem(name: '강남', lines: ['2호선', '신분당선']),
  const SubwayStationSearchItem(name: '판교', lines: ['신분당선', '경강선']),
  const SubwayStationSearchItem(name: '여의도', lines: ['5호선', '9호선']),
  const SubwayStationSearchItem(name: '홍대입구', lines: ['2호선', '공항철도', '경의중앙선']),
  const SubwayStationSearchItem(name: '서울역', lines: ['1호선', '4호선', '공항철도', '경의중앙선']),
  const SubwayStationSearchItem(name: '신도림', lines: ['1호선', '2호선']),
  const SubwayStationSearchItem(name: '사당', lines: ['2호선', '4호선']),
  const SubwayStationSearchItem(name: '잠실', lines: ['2호선', '8호선']),
  const SubwayStationSearchItem(name: '고속터미널', lines: ['3호선', '7호선', '9호선']),
  const SubwayStationSearchItem(name: '교대', lines: ['2호선', '3호선']),
  const SubwayStationSearchItem(name: '왕십리', lines: ['2호선', '5호선', '수인분당선', '경의중앙선']),
  const SubwayStationSearchItem(name: '종로3가', lines: ['1호선', '3호선', '5호선']),
  const SubwayStationSearchItem(name: '동대문역사문화공원', lines: ['2호선', '4호선', '5호선']),
  const SubwayStationSearchItem(name: '시청', lines: ['1호선', '2호선']),
  const SubwayStationSearchItem(name: '광화문', lines: ['5호선']),
  const SubwayStationSearchItem(name: '을지로입구', lines: ['2호선']),
  const SubwayStationSearchItem(name: '을지로3가', lines: ['2호선', '3호선']),
  const SubwayStationSearchItem(name: '을지로4가', lines: ['2호선', '5호선']),
  const SubwayStationSearchItem(name: '충정로', lines: ['2호선', '5호선']),
  const SubwayStationSearchItem(name: '신촌', lines: ['2호선']),
  const SubwayStationSearchItem(name: '이대', lines: ['2호선']),
  const SubwayStationSearchItem(name: '합정', lines: ['2호선', '6호선']),
  const SubwayStationSearchItem(name: '당산', lines: ['2호선', '9호선']),
  const SubwayStationSearchItem(name: '영등포구청', lines: ['2호선', '5호선']),
  const SubwayStationSearchItem(name: '영등포', lines: ['1호선']),
  const SubwayStationSearchItem(name: '용산', lines: ['1호선', '경의중앙선']),
  const SubwayStationSearchItem(name: '노량진', lines: ['1호선', '9호선']),
  const SubwayStationSearchItem(name: '여의나루', lines: ['5호선']),
  const SubwayStationSearchItem(name: '국회의사당', lines: ['9호선']),
  const SubwayStationSearchItem(name: '삼각지', lines: ['4호선', '6호선']),
  const SubwayStationSearchItem(name: '신용산', lines: ['4호선']),
  const SubwayStationSearchItem(name: '이촌', lines: ['4호선', '경의중앙선']),
  const SubwayStationSearchItem(name: '옥수', lines: ['3호선', '경의중앙선']),
  const SubwayStationSearchItem(name: '압구정', lines: ['3호선']),
  const SubwayStationSearchItem(name: '신사', lines: ['3호선', '신분당선']),
  const SubwayStationSearchItem(name: '논현', lines: ['7호선', '신분당선']),
  const SubwayStationSearchItem(name: '신논현', lines: ['9호선', '신분당선']),
  const SubwayStationSearchItem(name: '양재', lines: ['3호선', '신분당선']),
  const SubwayStationSearchItem(name: '수서', lines: ['3호선', '수인분당선', 'GTX-A']),
  const SubwayStationSearchItem(name: '성수', lines: ['2호선']),
  const SubwayStationSearchItem(name: '건대입구', lines: ['2호선', '7호선']),
  const SubwayStationSearchItem(name: '삼성', lines: ['2호선']),
  const SubwayStationSearchItem(name: '선릉', lines: ['2호선', '수인분당선']),
  const SubwayStationSearchItem(name: '역삼', lines: ['2호선']),
  const SubwayStationSearchItem(name: '서초', lines: ['2호선']),
  const SubwayStationSearchItem(name: '방배', lines: ['2호선']),
  const SubwayStationSearchItem(name: '낙성대', lines: ['2호선']),
  const SubwayStationSearchItem(name: '서울대입구', lines: ['2호선']),
  const SubwayStationSearchItem(name: '봉천', lines: ['2호선']),
  const SubwayStationSearchItem(name: '신림', lines: ['2호선', '신림선']),
  const SubwayStationSearchItem(name: '대림', lines: ['2호선', '7호선']),
  const SubwayStationSearchItem(name: '구로디지털단지', lines: ['2호선']),
  const SubwayStationSearchItem(name: '가산디지털단지', lines: ['1호선', '7호선']),
  const SubwayStationSearchItem(name: '온수', lines: ['1호선', '7호선']),
  const SubwayStationSearchItem(name: '부천', lines: ['1호선']),
  const SubwayStationSearchItem(name: '부평', lines: ['1호선', '인천1호선']),
  const SubwayStationSearchItem(name: '노원', lines: ['4호선', '7호선']),
  const SubwayStationSearchItem(name: '창동', lines: ['1호선', '4호선']),
  const SubwayStationSearchItem(name: '수유', lines: ['4호선']),
  const SubwayStationSearchItem(name: '미아사거리', lines: ['4호선']),
  const SubwayStationSearchItem(name: '혜화', lines: ['4호선']),
  const SubwayStationSearchItem(name: '명동', lines: ['4호선']),
  const SubwayStationSearchItem(name: '청량리', lines: ['1호선', '수인분당선', '경의중앙선']),
  const SubwayStationSearchItem(name: '정자', lines: ['신분당선', '수인분당선']),
  const SubwayStationSearchItem(name: '미금', lines: ['신분당선', '수인분당선']),
  const SubwayStationSearchItem(name: '동천', lines: ['신분당선']),
  const SubwayStationSearchItem(name: '수지구청', lines: ['신분당선']),
  const SubwayStationSearchItem(name: '광교중앙', lines: ['신분당선']),
  const SubwayStationSearchItem(name: '서현', lines: ['수인분당선']),
  const SubwayStationSearchItem(name: '야탑', lines: ['수인분당선']),
  const SubwayStationSearchItem(name: '모란', lines: ['8호선', '수인분당선']),
  const SubwayStationSearchItem(name: '문정', lines: ['8호선']),
  const SubwayStationSearchItem(name: '천호', lines: ['5호선', '8호선']),
  const SubwayStationSearchItem(name: '군자', lines: ['5호선', '7호선']),
  const SubwayStationSearchItem(name: '상봉', lines: ['7호선', '경의중앙선']),
  const SubwayStationSearchItem(name: '공덕', lines: ['5호선', '6호선', '공항철도', '경의중앙선']),
  const SubwayStationSearchItem(name: '마포', lines: ['5호선']),
  const SubwayStationSearchItem(name: '마곡나루', lines: ['9호선', '공항철도']),
  const SubwayStationSearchItem(name: '김포공항', lines: ['5호선', '9호선', '공항철도', '서해선']),
];

class SubwayScreen extends ConsumerStatefulWidget {
  const SubwayScreen({super.key});

  @override
  ConsumerState<SubwayScreen> createState() => _SubwayScreenState();
}

class _SubwayScreenState extends ConsumerState<SubwayScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getLineBadgeColor(String lineName) {
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
    if (lineName.contains('공항철도')) return const Color(0xFF0090D2);
    if (lineName.contains('경의중앙')) return const Color(0xFF77C4A3);
    return const Color(0xFF6B7280);
  }

  List<SubwayStationSearchItem> _getFilteredStations(String query) {
    final clean = query.trim().replaceAll('역', '');
    if (clean.isEmpty) return [];

    final list = _kSubwayStationDatabase
        .where((item) =>
            item.name.contains(clean) ||
            item.lines.any((l) => l.contains(clean)))
        .toList();

    // 만약 DB에 정확히 일치하지 않는 역이라도 직접 입력한 역을 맨 앞에 옵션으로 제공
    if (list.every((item) => item.name != clean) && clean.length >= 2) {
      list.insert(
        0,
        SubwayStationSearchItem(name: clean, lines: ['지하철']),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(subwayDashboardProvider);
    final notifier = ref.read(subwayDashboardProvider.notifier);
    final favoriteStations = dashboardState.favoriteStations;

    final hour = dashboardState.lastUpdated.hour.toString().padLeft(2, '0');
    final minute = dashboardState.lastUpdated.minute.toString().padLeft(2, '0');
    final second = dashboardState.lastUpdated.second.toString().padLeft(2, '0');
    final formattedTime = '$hour:$minute:$second';

    final searchResults = _getFilteredStations(_searchQuery);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '🚇 출퇴근 지하철',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.neonLime),
            tooltip: '실시간 새로고침',
            onPressed: () {
              notifier.loadDashboardData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.neonLime,
        backgroundColor: AppColors.surface,
        onRefresh: () async {
          await notifier.loadDashboardData();
        },
        child: CustomScrollView(
          slivers: [
            // 1. 상단: 15초 주기 실시간 자동 갱신 상태 바 (1번 탭과 동일)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
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

            // 2. 상단: 역 검색창 (검색 결과에서 별(★)을 눌러 즉시 추가/해제하는 직관적인 UX)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isSearching
                          ? AppColors.neonLime
                          : AppColors.cardBorder,
                      width: 1.2,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _isSearching = val.trim().isNotEmpty;
                      });
                    },
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: '지하철역 검색 (예: 강남, 판교, 홍대입구)',
                      hintStyle: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.neonLime,
                        size: 22,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  color: AppColors.textMuted, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _isSearching = false;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
              ),
            ),

            // 3. 검색 중일 때: 실시간 검색 결과 & [별(★/☆) 버튼] 리스트
            if (_isSearching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '검색 결과 (${searchResults.length}개)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Text(
                        '별(★)을 눌러 바로 즐겨찾기 추가',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.neonLime,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (searchResults.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        '일치하는 지하철역이 없습니다.',
                        style:
                            TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = searchResults[index];
                      final isFav = notifier.isFavorite(item.name);

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isFav
                                ? AppColors.neonLime.withValues(alpha: 0.4)
                                : AppColors.cardBorder,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: item.lines.take(2).map((l) {
                              return Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _getLineBadgeColor(l),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          title: Text(
                            '${item.name}역',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isFav ? Icons.star : Icons.star_border,
                              color: isFav
                                  ? AppColors.neonLime
                                  : AppColors.textMuted,
                              size: 26,
                            ),
                            tooltip: isFav ? '즐겨찾기 해제' : '즐겨찾기 추가',
                            onPressed: () async {
                              final added = await notifier
                                  .toggleFavoriteStation(item.name);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      added
                                          ? '★ ${item.name}역이 즐겨찾기에 추가되었습니다.'
                                          : '${item.name}역이 즐겨찾기에서 제거되었습니다.',
                                      style: TextStyle(
                                        color: added
                                            ? Colors.black
                                            : Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    backgroundColor: added
                                        ? AppColors.neonLime
                                        : AppColors.surfaceElevated,
                                    duration:
                                        const Duration(milliseconds: 1400),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                    childCount: searchResults.length,
                  ),
                ),
            ]
            // 4. 검색 중이 아닐 때: 메인 즐겨찾기 역 카드 리스트 (1번 탭과 동일한 룩앤필)
            else ...[
              if (favoriteStations.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.subway_outlined,
                            size: 60, color: AppColors.textMuted),
                        const SizedBox(height: 14),
                        const Text(
                          '즐겨찾는 지하철역이 없습니다.',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          '상단 검색창에서 역을 검색하고 별(★)을 눌러 등록하세요.',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final station = favoriteStations[index];
                      final arrivals =
                          dashboardState.arrivalsMap[station] ?? [];

                      return SubwayStationCard(
                        stationName: station,
                        arrivals: arrivals,
                        onToggleFavorite: () async {
                          await notifier.toggleFavoriteStation(station);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '$station역이 즐겨찾기에서 제거되었습니다.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: AppColors.surfaceElevated,
                                duration: const Duration(milliseconds: 1200),
                              ),
                            );
                          }
                        },
                      );
                    },
                    childCount: favoriteStations.length,
                  ),
                ),
            ],

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}
