import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/location_service.dart';
import '../../../data/models/transit_alarm_item.dart';
import '../../providers/alarm_provider.dart';

/// 장소/도로명 자유 검색 및 핀 위치 지정 스마트 하차 알람 설정 화면
class SetAlarmMapScreen extends ConsumerStatefulWidget {
  const SetAlarmMapScreen({super.key});

  @override
  ConsumerState<SetAlarmMapScreen> createState() => _SetAlarmMapScreenState();
}

class _SetAlarmMapScreenState extends ConsumerState<SetAlarmMapScreen> {
  final _searchController = TextEditingController();
  final _titleController = TextEditingController();
  final _stationController = TextEditingController();
  final _busRouteController = TextEditingController();

  double _radiusMeters = 800.0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // 기본 좌표: 테헤란로 (강남 중심)
  NLatLng _targetPosition = const NLatLng(37.5024, 127.0426);
  NaverMapController? _mapController;

  // 장소 검색 관련 상태
  List<PlaceSearchResult> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;
  Timer? _debounceTimer;

  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _titleController.text = '테헤란로 도착 알람';
    _stationController.text = '테헤란로';

    // 화면 진입 시 현재 GPS 위치가 있으면 해당 위치로 초기화 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initToUserCurrentLocation();
    });
  }

  Future<void> _initToUserCurrentLocation() async {
    final pos = await _locationService.getCurrentPosition();
    if (pos != null && mounted) {
      final currentLatLng = NLatLng(pos.latitude, pos.longitude);
      setState(() {
        _targetPosition = currentLatLng;
      });
      _mapController?.updateCamera(
        NCameraUpdate.scrollAndZoomTo(target: currentLatLng, zoom: 15.0),
      );
      _updateMapOverlays();
      final address = await _locationService.reverseGeocode(
        currentLatLng.latitude,
        currentLatLng.longitude,
      );
      if (mounted) {
        setState(() {
          _stationController.text = address;
          _titleController.text = '$address 도착 알람';
        });
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _titleController.dispose();
    _stationController.dispose();
    _busRouteController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _executeSearch(query);
    });
  }

  Future<void> _executeSearch(String query) async {
    setState(() => _isSearching = true);
    final results = await _locationService.searchPlaces(query);
    if (!mounted) return;

    setState(() {
      _searchResults = results;
      _showSearchResults = true;
      _isSearching = false;
    });
  }

  void _selectSearchResult(PlaceSearchResult item) {
    final latLng = NLatLng(item.latitude, item.longitude);
    setState(() {
      _targetPosition = latLng;
      _stationController.text = item.title;
      _titleController.text = '${item.title} 도착';
      _showSearchResults = false;
      _searchController.text = item.title;
    });

    FocusScope.of(context).unfocus();
    _mapController?.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: latLng, zoom: 15.5),
    );
    _updateMapOverlays();
  }

  Future<void> _moveToCurrentLocation() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📍 현재 GPS 위치를 확인하고 있습니다...'),
        duration: Duration(milliseconds: 900),
      ),
    );

    final pos = await _locationService.getCurrentPosition();
    if (pos == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('현재 위치 정보를 가져올 수 없습니다. 위치 권한을 확인해주세요.')),
      );
      return;
    }

    final latLng = NLatLng(pos.latitude, pos.longitude);
    setState(() {
      _targetPosition = latLng;
    });

    _mapController?.updateCamera(
      NCameraUpdate.scrollAndZoomTo(target: latLng, zoom: 15.5),
    );
    _updateMapOverlays();

    final address = await _locationService.reverseGeocode(
      latLng.latitude,
      latLng.longitude,
    );
    if (mounted) {
      setState(() {
        _stationController.text = address;
        _titleController.text = '$address 도착 알람';
      });
    }
  }

  void _updateMapOverlays() {
    if (_mapController == null) return;
    try {
      _mapController!.clearOverlays();

      final marker = NMarker(
        id: 'target_station_marker',
        position: _targetPosition,
      );

      final circle = NCircleOverlay(
        id: 'alarm_radius_circle',
        center: _targetPosition,
        radius: _radiusMeters,
        color: AppColors.neonLime.withValues(alpha: 0.18),
        outlineColor: AppColors.neonLime,
        outlineWidth: 2.2,
      );

      _mapController!.addOverlayAll({marker, circle});
    } catch (_) {}
  }

  void _saveAlarm() {
    final title = _titleController.text.trim();
    final station = _stationController.text.trim();

    if (title.isEmpty || station.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알람 별칭과 목적지 명칭을 입력해 주세요.')),
      );
      return;
    }

    final newAlarm = TransitAlarmItem(
      id: 'alarm_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      targetStationName: station,
      targetLatitude: _targetPosition.latitude,
      targetLongitude: _targetPosition.longitude,
      radiusMeters: _radiusMeters,
      isEnabled: true, // 등록 즉시 활성화
      soundEnabled: _soundEnabled,
      vibrationEnabled: _vibrationEnabled,
      busRouteName: _busRouteController.text.trim().isNotEmpty
          ? _busRouteController.text.trim()
          : null,
      createdAt: DateTime.now(),
    );

    ref.read(alarmProvider.notifier).addAlarm(newAlarm);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.neonLime, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🔔 [$station] 도착 알람(반경 ${_radiusMeters.toInt()}m)이 활성화되었습니다!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. 전체 화면 네이버 지도
          Positioned.fill(
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: _targetPosition,
                  zoom: 15.0,
                ),
                nightModeEnable: true,
                mapType: NMapType.navi,
              ),
              onMapReady: (controller) {
                _mapController = controller;
                _updateMapOverlays();
              },
              onMapTapped: (point, latLng) async {
                setState(() {
                  _targetPosition = latLng;
                  _showSearchResults = false;
                });
                _updateMapOverlays();
                FocusScope.of(context).unfocus();

                // 탭한 지점 역지오코딩 주소 획득
                final placeName = await _locationService.reverseGeocode(
                  latLng.latitude,
                  latLng.longitude,
                );
                if (mounted) {
                  setState(() {
                    _stationController.text = placeName;
                    _titleController.text = '$placeName 도착';
                  });
                }
              },
            ),
          ),

          // 2. 상단 네비게이션 & 플로팅 장소 검색창
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // 뒤로가기 버튼
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: AppColors.textPrimary, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // 통합 장소 검색창
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _showSearchResults
                                  ? AppColors.neonLime
                                  : AppColors.cardBorder,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              const Icon(Icons.search,
                                  color: AppColors.neonLime, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: '장소, 역, 도로명 검색 (예: 테헤란로, 강남역)',
                                    hintStyle: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 13,
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  onChanged: _onSearchChanged,
                                  onSubmitted: _executeSearch,
                                ),
                              ),
                              if (_isSearching)
                                const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          AppColors.neonLime),
                                    ),
                                  ),
                                )
                              else if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchResults = [];
                                      _showSearchResults = false;
                                    });
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(right: 12),
                                    child: Icon(Icons.close,
                                        color: AppColors.textSecondary,
                                        size: 18),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 검색 결과 오버레이 리스트
                  if (_showSearchResults && _searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemCount: _searchResults.length,
                        separatorBuilder: (context, index) =>
                            const Divider(color: AppColors.cardBorder, height: 1),
                        itemBuilder: (context, index) {
                          final item = _searchResults[index];
                          return ListTile(
                            dense: true,
                            leading: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.category == '지하철역'
                                    ? Icons.subway
                                    : item.category == '정류장'
                                        ? Icons.directions_bus
                                        : item.category == '도로'
                                            ? Icons.alt_route
                                            : Icons.place,
                                color: AppColors.neonLime,
                                size: 18,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    item.category,
                                    style: const TextStyle(
                                      color: AppColors.neonLime,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Text(
                              item.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () => _selectSearchResult(item),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. 지도 조작 안내 툴팁 & GPS 현재 위치 버튼
          Positioned(
            top: 110,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // GPS 내 위치 바로가기 FAB
                FloatingActionButton.small(
                  heroTag: 'gps_fab',
                  onPressed: _moveToCurrentLocation,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.cardBorder),
                  ),
                  child: const Icon(Icons.my_location,
                      color: AppColors.neonLime, size: 20),
                ),
                const SizedBox(height: 8),

                // 지도 터치 안내 뱃지
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.touch_app,
                          color: AppColors.neonLime, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '지도 터치로 자유 핀 지정',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonLime.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 4. 하단 슬라이딩 설정 시트
          DraggableScrollableSheet(
            initialChildSize: 0.48,
            minChildSize: 0.22,
            maxChildSize: 0.52,
            builder: (context, scrollController) {
              final bottomPadding = MediaQuery.of(context).padding.bottom;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 20,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottomPadding),
                  children: [
                    // 드래그 핸들바
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 목적지 명칭 & 알람 별칭
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(Icons.pin_drop,
                              color: AppColors.neonLime, size: 22),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('도착 목적지 (지명 / 도로명 / 역)',
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 3),
                              TextField(
                                controller: _stationController,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                ),
                                decoration: InputDecoration(
                                  hintText: '예: 테헤란로, 강남역, 판교 테크노밸리',
                                  hintStyle: const TextStyle(
                                      color: AppColors.textMuted, fontSize: 13.5),
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 7, horizontal: 10),
                                  filled: true,
                                  fillColor: AppColors.surfaceElevated,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // 알람 별칭
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('알람 별칭',
                            style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 3),
                        TextField(
                          controller: _titleController,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontSize: 13.5),
                          decoration: InputDecoration(
                            hintText: '예: 퇴근길 도착 알림, 약속 장소',
                            hintStyle: const TextStyle(
                                color: AppColors.textMuted, fontSize: 12.5),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 7, horizontal: 10),
                            filled: true,
                            fillColor: AppColors.surfaceElevated,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 반경 슬라이더 & 프리셋
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('알람 울릴 거리 (도착 전 반경)',
                            style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.neonLime),
                          ),
                          child: Text(
                            '${_radiusMeters.toInt()}m 전',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.neonLime,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _radiusMeters,
                      min: 300,
                      max: 2000,
                      divisions: 17,
                      activeColor: AppColors.neonLime,
                      inactiveColor: AppColors.surfaceElevated,
                      onChanged: (val) {
                        setState(() => _radiusMeters = val);
                        _updateMapOverlays();
                      },
                    ),

                    // 퀵 반경 프리셋 칩
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [300, 500, 1000, 2000].map((r) {
                        final isSelected = (_radiusMeters.toInt() == r);
                        return GestureDetector(
                          onTap: () {
                            setState(() => _radiusMeters = r.toDouble());
                            _updateMapOverlays();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.neonLime
                                  : AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              r == 300
                                  ? '300m (1정거장)'
                                  : r == 1000
                                      ? '1km (추천)'
                                      : '${r}m',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.black : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),

                    // 소리 & 진동 토글
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('소리',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            value: _soundEnabled,
                            onChanged: (v) => setState(() => _soundEnabled = v),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('강력 진동',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary)),
                            value: _vibrationEnabled,
                            onChanged: (v) =>
                                setState(() => _vibrationEnabled = v),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // 저장 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveAlarm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonLime,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('🔔 이 위치로 하차 알람 설정 완료',
                            style: TextStyle(
                                fontSize: 15.5, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
