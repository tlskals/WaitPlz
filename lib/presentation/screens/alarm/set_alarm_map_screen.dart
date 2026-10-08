import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _stationController.dispose();
    _busRouteController.dispose();
    super.dispose();
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
      targetLatitude: 37.3849, // 서현역/판교 등 기본 좌표
      targetLongitude: 127.1232,
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
      const SnackBar(
        content: Text('🔔 "기사님, 잠시만요!" 하차 알람이 등록 및 활성화되었습니다.'),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('하차 알람 추가'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 설명 카드
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                children: [
                  Icon(Icons.radar, color: AppColors.neonLime, size: 28),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      '목적지 반경에 들어오면 화면이 꺼져 있어도 강력한 진동과 소리로 깨워드립니다.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('알람 별칭 (예: 퇴근길 서현역, 집 앞 정류장)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 퇴근길 분당 서현역 하차',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 18),

            const Text('하차할 정류장 / 지하철역 이름',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _stationController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 서현역.AK플라자, 판교역 1번출구',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 18),

            const Text('탑승 버스 번호 (선택)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            TextField(
              controller: _busRouteController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 9401번, M5107번',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 알람 발동 반경 슬라이더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('알람 울릴 거리 (도착 전 반경)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text(
                  '${_radiusMeters.toInt()}m 전',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.neonLime,
                  ),
                ),
              ],
            ),
            Slider(
              value: _radiusMeters,
              min: 300,
              max: 2000,
              divisions: 17,
              label: '${_radiusMeters.toInt()}m',
              activeColor: AppColors.neonLime,
              inactiveColor: AppColors.surfaceElevated,
              onChanged: (val) => setState(() => _radiusMeters = val),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('300m (약 1정거장)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text('1,000m (광역버스 추천)', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                  Text('2,000m', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text('소리 알람', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              value: _soundEnabled,
              onChanged: (v) => setState(() => _soundEnabled = v),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('강력 진동 알람', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              value: _vibrationEnabled,
              onChanged: (v) => setState(() => _vibrationEnabled = v),
              contentPadding: EdgeInsets.zero,
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveAlarm,
                child: const Text('하차 알람 설정 완료', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
