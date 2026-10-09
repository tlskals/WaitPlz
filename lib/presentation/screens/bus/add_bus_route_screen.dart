import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/bus_route_detail.dart';
import '../../../data/models/favorite_route.dart';
import '../../providers/bus_dashboard_provider.dart';

class AddBusRouteScreen extends ConsumerStatefulWidget {
  const AddBusRouteScreen({super.key});

  @override
  ConsumerState<AddBusRouteScreen> createState() => _AddBusRouteScreenState();
}

class _AddBusRouteScreenState extends ConsumerState<AddBusRouteScreen> {
  final _searchController = TextEditingController();
  final _stationSearchController = TextEditingController();

  List<BusRouteDetail> _searchResults = [];
  BusRouteDetail? _selectedRoute;
  BusStopItem? _selectedStop;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _stationSearchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final repo = ref.read(busRepositoryProvider);
    final results = await repo.searchBusRoutes(query);
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Color _getRouteColor(String type) {
    if (type.contains('광역') || type.contains('직행') || type.contains('M')) {
      return AppColors.busRed;
    } else if (type.contains('지선')) {
      return AppColors.busGreen;
    } else if (type.contains('마을')) {
      return const Color(0xFF84CC16);
    } else {
      return AppColors.busBlue;
    }
  }

  void _confirmAndAddRoute() {
    if (_selectedRoute == null || _selectedStop == null) return;

    final newFavorite = FavoriteRoute(
      id: 'fav_${DateTime.now().millisecondsSinceEpoch}',
      routeId: _selectedRoute!.routeId,
      routeName: _selectedRoute!.routeName,
      routeType: _selectedRoute!.routeType,
      stationId: _selectedStop!.stationId,
      stationName: _selectedStop!.stationName,
      directionA: _selectedRoute!.directionA,
      directionB: _selectedRoute!.directionB,
    );

    ref.read(busDashboardProvider.notifier).addFavoriteRoute(newFavorite);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.neonLime, size: 20),
            const SizedBox(width: 8),
            Text(
              '[${_selectedRoute!.routeName}번 - ${_selectedStop!.stationName}] 등록 완료!',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedRoute == null ? '자주 타는 버스 찾기' : '${_selectedRoute!.routeName}번 노선도',
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {
            if (_selectedRoute != null) {
              setState(() {
                _selectedRoute = null;
                _selectedStop = null;
                _stationSearchController.clear();
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _selectedRoute == null
          ? _buildBusSearchStep()
          : _buildRouteStopSelectionStep(),
      bottomNavigationBar: _selectedRoute != null && _selectedStop != null
          ? _buildBottomConfirmBar()
          : null,
    );
  }

  // ==========================================
  // 1단계: 버스 번호 검색 및 노선 목록 화면
  // ==========================================
  Widget _buildBusSearchStep() {
    return Column(
      children: [
        // 1. 버스 번호 검색창
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
            onChanged: (val) => _performSearch(val),
            decoration: InputDecoration(
              hintText: '버스 번호 입력 (예: 143, 1, 7016, 9401)',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14.5),
              prefixIcon: const Icon(Icons.search, color: AppColors.neonLime),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textMuted, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

        // 2. 빠른 검색 칩
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['143', '1', '7016', '9401', '420', '마포09', 'M5107'].map((busNum) {
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ActionChip(
                    label: Text(busNum),
                    backgroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: const BorderSide(color: AppColors.cardBorder),
                    labelStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                    onPressed: () {
                      _searchController.text = busNum;
                      _performSearch(busNum);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // 3. 검색 결과 목록
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.neonLime),
                )
              : _searchResults.isEmpty
                  ? const Center(
                      child: Text(
                        '검색된 버스가 없습니다.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final bus = _searchResults[index];
                        final color = _getRouteColor(bus.routeType);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedRoute = bus;
                                _selectedStop = null;
                              });
                            },
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // 버스 번호 뱃지
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: color,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      bus.routeName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // 노선 정보 & 기종점
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 5, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: AppColors.surfaceElevated,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                bus.region,
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.neonLime,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                bus.routeSummary,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w800,
                                                  color: AppColors.textPrimary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '배차 ${bus.interval} | ${bus.operatingHours}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: AppColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // 2단계: 버스 노선도(정류장 리스트) 및 정류장 선택 화면
  // ==========================================
  Widget _buildRouteStopSelectionStep() {
    final route = _selectedRoute!;
    final routeColor = _getRouteColor(route.routeType);
    final filterText = _stationSearchController.text.trim().toLowerCase();

    final filteredStations = filterText.isEmpty
        ? route.stations
        : route.stations.where((s) => s.stationName.toLowerCase().contains(filterText)).toList();

    return Column(
      children: [
        // 상단: 선택된 노선 정보 헤더 카드
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: routeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  route.routeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${route.region} · ${route.routeSummary}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '내가 탈 정류장을 아래 노선도에서 탭하세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.neonLime.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 정류장 검색창
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: _stationSearchController,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: '정류장 이름 검색 (예: 강남, 아파트, 서현)',
              hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13.5),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
          ),
        ),

        const SizedBox(height: 6),

        // 노선도 타임라인 정류장 리스트
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 90),
            itemCount: filteredStations.length,
            itemBuilder: (context, index) {
              final stop = filteredStations[index];
              final isSelected = _selectedStop?.stationId == stop.stationId;
              final isFirst = index == 0;
              final isLast = index == filteredStations.length - 1;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedStop = stop;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: isSelected
                      ? AppColors.neonLime.withValues(alpha: 0.12)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Row(
                    children: [
                      // 세로 타임라인 노선 그래픽
                      SizedBox(
                        width: 30,
                        height: 52,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // 수직 연결선
                            Positioned(
                              top: isFirst ? 26 : 0,
                              bottom: isLast ? 26 : 0,
                              child: Container(
                                width: 3,
                                color: isSelected
                                    ? AppColors.neonLime
                                    : AppColors.cardBorder,
                              ),
                            ),
                            // 정류장 노드 원
                            Container(
                              width: isSelected ? 16 : 10,
                              height: isSelected ? 16 : 10,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.neonLime
                                    : (stop.isTurningPoint ? AppColors.urgentWarning : AppColors.surfaceElevated),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.black : AppColors.cardBorder,
                                  width: 2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      // 정류장 정보
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  stop.stationName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                    color: isSelected ? AppColors.neonLime : AppColors.textPrimary,
                                  ),
                                ),
                                if (stop.isTurningPoint) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.urgentWarning.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '회차/종점',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.urgentWarning,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${stop.arsId.isNotEmpty ? '[${stop.arsId}] ' : ''}${stop.directionName}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 선택 라디오/체크 아이콘
                      Icon(
                        isSelected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: isSelected ? AppColors.neonLime : AppColors.textMuted,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 하단 플로팅 확인 & 등록 바
  // ==========================================
  Widget _buildBottomConfirmBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.neonLime, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '선택: [${_selectedStop!.stationName}]',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _confirmAndAddRoute,
              child: Text(
                '${_selectedRoute!.routeName}번 등록 완료 (대시보드 추가)',
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
