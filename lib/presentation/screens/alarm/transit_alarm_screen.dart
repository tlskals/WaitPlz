import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/transit_alarm_item.dart';
import '../../providers/alarm_provider.dart';
import 'set_alarm_map_screen.dart';

class TransitAlarmScreen extends ConsumerWidget {
  const TransitAlarmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms = ref.watch(alarmProvider);

    final favoriteAlarms = alarms.where((a) => a.isEnabled).toList();
    final generalAlarms = alarms.where((a) => !a.isEnabled).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '⏰ 스마트 하차 알람',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: AppColors.neonLime, size: 26),
            tooltip: '하차 알람 추가',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SetAlarmMapScreen()),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // 1. [활성화된 하차 알람] 헤더
          if (favoriteAlarms.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Icon(Icons.radar, color: AppColors.neonLime, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '동작 중인 하차 알람',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final alarm = favoriteAlarms[index];
                  return _buildActiveAlarmCard(context, ref, alarm);
                },
                childCount: favoriteAlarms.length,
              ),
            ),
          ],

          // 2. [저장된 알람 목록] 헤더
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                '저장된 알람 목록',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),

          if (generalAlarms.isEmpty && favoriteAlarms.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off_outlined,
                        size: 60, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      '등록된 하차 알람이 없습니다.',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '우측 상단 + 버튼을 눌러 자주 내리는 곳을 등록하세요.',
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
                  final alarm = generalAlarms[index];
                  return _buildInactiveAlarmCard(context, ref, alarm);
                },
                childCount: generalAlarms.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SetAlarmMapScreen()),
          );
        },
        backgroundColor: AppColors.neonLime,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),
    );
  }

  /// 활성화된 하차 알람 카드 (네이버 지도 레이더 뷰 + 반경 뱃지)
  Widget _buildActiveAlarmCard(
      BuildContext context, WidgetRef ref, TransitAlarmItem alarm) {
    final pos = NLatLng(alarm.targetLatitude, alarm.targetLongitude);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: AppColors.neonLime.withValues(alpha: 0.5), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 스위치 + 핀 아이콘 + 타이틀 + 주소 + 더보기
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Switch(
                  value: alarm.isEnabled,
                  onChanged: (val) {
                    ref.read(alarmProvider.notifier).toggleAlarm(alarm.id, val);
                  },
                ),
                const SizedBox(width: 10),
                const Icon(Icons.push_pin,
                    color: AppColors.neonLime, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alarm.title,
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        alarm.targetStationName,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz,
                      color: AppColors.textSecondary),
                  onPressed: () => _showAlarmOptions(context, ref, alarm),
                ),
              ],
            ),
          ),

          // 지도 레이더 뷰 컨테이너
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                NaverMap(
                  options: NaverMapViewOptions(
                    initialCameraPosition: NCameraPosition(
                      target: pos,
                      zoom: 14.5,
                    ),
                    nightModeEnable: true,
                    mapType: NMapType.navi,
                    scrollGesturesEnable: false,
                    zoomGesturesEnable: false,
                    tiltGesturesEnable: false,
                    rotationGesturesEnable: false,
                  ),
                  onMapReady: (controller) {
                    final marker = NMarker(
                      id: 'alarm_marker_${alarm.id}',
                      position: pos,
                    );
                    final circle = NCircleOverlay(
                      id: 'alarm_circle_${alarm.id}',
                      center: pos,
                      radius: alarm.radiusMeters,
                      color: AppColors.neonLime.withValues(alpha: 0.18),
                      outlineColor: AppColors.neonLime,
                      outlineWidth: 2,
                    );
                    controller.addOverlayAll({marker, circle});
                  },
                ),
                // 좌상단 반경 뱃지 pill (`((•)) 반경 1km`)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.radar,
                            color: AppColors.neonLime, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          '반경 ${(alarm.radiusMeters / 1000).toStringAsFixed(1)}km',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.neonLime,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 우하단 테스트 버튼
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(alarmProvider.notifier).testAlarm(alarm);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              '🔔 [${alarm.targetStationName}] 하차 알람(진동/소리) 테스트 발송!'),
                          backgroundColor: AppColors.surfaceElevated,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up,
                              color: AppColors.neonLime, size: 14),
                          SizedBox(width: 4),
                          Text(
                            '테스트 울리기',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 비활성화된 알람 카드 (콤팩트 단일 행)
  Widget _buildInactiveAlarmCard(
      BuildContext context, WidgetRef ref, TransitAlarmItem alarm) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Switch(
            value: alarm.isEnabled,
            onChanged: (val) {
              ref.read(alarmProvider.notifier).toggleAlarm(alarm.id, val);
            },
          ),
          const SizedBox(width: 12),
          const Icon(Icons.push_pin_outlined,
              color: AppColors.textMuted, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alarm.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  alarm.targetStationName,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textMuted),
            onPressed: () => _showAlarmOptions(context, ref, alarm),
          ),
        ],
      ),
    );
  }

  void _showAlarmOptions(
      BuildContext context, WidgetRef ref, TransitAlarmItem alarm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.volume_up, color: AppColors.neonLime),
              title: const Text('알람 테스트 울리기',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(alarmProvider.notifier).testAlarm(alarm);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline,
                  color: AppColors.urgentWarning),
              title: const Text('도착지 삭제',
                  style: TextStyle(
                      color: AppColors.urgentWarning,
                      fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.of(ctx).pop();
                ref.read(alarmProvider.notifier).deleteAlarm(alarm.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
