import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/transit_alarm_item.dart';
import '../../providers/alarm_provider.dart';

class SetAlarmMapScreen extends ConsumerStatefulWidget {
  const SetAlarmMapScreen({super.key});

  @override
  ConsumerState<SetAlarmMapScreen> createState() => _SetAlarmMapScreenState();
}

class _SetAlarmMapScreenState extends ConsumerState<SetAlarmMapScreen> {
  final _titleController = TextEditingController();
  final _stationController = TextEditingController();
  final _busRouteController = TextEditingController();

  double _radiusMeters = 800.0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  NLatLng _targetPosition = const NLatLng(37.3849, 127.1232); // 기본: 서현역
  NaverMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _titleController.text = '퇴근길 서현역 하차';
    _stationController.text = '서현역.AK플라자';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _stationController.dispose();
    _busRouteController.dispose();
    super.dispose();
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
        outlineWidth: 2,
      );

      _mapController!.addOverlayAll({marker, circle});
    } catch (_) {}
  }

  void _saveAlarm() {
    final title = _titleController.text.trim();
    final station = _stationController.text.trim();

    if (title.isEmpty || station.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('알람 별칭과 하차할 목적지(정류장/역)를 입력해 주세요.')),
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
            Text('🔔 [$station] 하차 알람(반경 ${_radiusMeters.toInt()}m)이 등록되었습니다!'),
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
      appBar: AppBar(
        title: const Text('하차 알람 위치 설정',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 네이버 지도 인터랙티브 뷰
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  NaverMap(
                    options: NaverMapViewOptions(
                      initialCameraPosition: NCameraPosition(
                        target: _targetPosition,
                        zoom: 14.5,
                      ),
                      nightModeEnable: true,
                      mapType: NMapType.navi,
                    ),
                    onMapReady: (controller) {
                      _mapController = controller;
                      _updateMapOverlays();
                    },
                    onMapTapped: (point, latLng) {
                      setState(() {
                        _targetPosition = latLng;
                      });
                      _updateMapOverlays();
                    },
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.touch_app,
                              color: AppColors.neonLime, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            '지도를 터치하여 하차 위치 지정',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neonLime.withValues(alpha: 0.95),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('알람 별칭',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '예: 퇴근길 서현역 하차, 집 앞 정류장',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text('하차할 목적지 정류장/역',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _stationController,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: '예: 서현역.AK플라자, 판교역, 강남역',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide:
                            const BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 알람 발동 반경 슬라이더
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('알람 울릴 거리 (도착 전 반경)',
                          style: TextStyle(
                              fontSize: 15,
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
                            fontSize: 14,
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('300m (약 1정거장)',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                        Text('1,000m (광역버스 추천)',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                        Text('2,000m',
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textMuted)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  SwitchListTile(
                    title: const Text('소리 알람',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    value: _soundEnabled,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('강력 진동 알람',
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    value: _vibrationEnabled,
                    onChanged: (v) => setState(() => _vibrationEnabled = v),
                    contentPadding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _saveAlarm,
                      child: const Text('하차 알람 설정 완료',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
