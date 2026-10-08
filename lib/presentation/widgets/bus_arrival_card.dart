import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/bus_arrival_info.dart';
import '../../data/models/favorite_route.dart';

class BusArrivalCard extends StatelessWidget {
  final FavoriteRoute favorite;
  final BusArrivalInfo? arrivalInfo;
  final VoidCallback onDelete;

  const BusArrivalCard({
    super.key,
    required this.favorite,
    this.arrivalInfo,
    required this.onDelete,
  });

  Color _getRouteColor(String type) {
    if (type.contains('광역') || type.contains('직행') || type.contains('M')) {
      return AppColors.busRed;
    } else if (type.contains('지선') || type.contains('마을')) {
      return AppColors.busGreen;
    } else {
      return AppColors.busBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeColor = _getRouteColor(favorite.routeType);
    final isClustered = arrivalInfo?.isClusteredBus ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isClustered
              ? AppColors.urgentWarning.withValues(alpha: 0.6)
              : AppColors.cardBorder,
          width: isClustered ? 1.5 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 버스 번호 + 태그 + 정류장 & 방면
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: routeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    favorite.routeName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        favorite.stationName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        favorite.direction.isNotEmpty
                            ? favorite.direction
                            : '${favorite.routeType}버스',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: AppColors.textMuted, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.cardBorder),
            const SizedBox(height: 14),

            // 도착 정보 메인 영역
            if (arrivalInfo == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.neonLime,
                    ),
                  ),
                ),
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    arrivalInfo!.arrivalTimeText1,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: arrivalInfo!.predictTimeSec1 <= 180
                          ? AppColors.urgentWarning
                          : AppColors.neonLime,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    arrivalInfo!.remainingStopsText1,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (arrivalInfo!.remainSeatCnt1 >= 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: arrivalInfo!.remainSeatCnt1 <= 5
                            ? AppColors.urgentWarning.withValues(alpha: 0.15)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: arrivalInfo!.remainSeatCnt1 <= 5
                              ? AppColors.urgentWarning
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        '잔여 ${arrivalInfo!.remainSeatCnt1}석',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: arrivalInfo!.remainSeatCnt1 <= 5
                              ? AppColors.urgentWarning
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // 2번째 차 도착 정보 및 연속 배차 경고
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isClustered
                      ? const Color(0xFF331414)
                      : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isClustered ? AppColors.urgentWarning : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isClustered ? Icons.warning_amber_rounded : Icons.schedule,
                      size: 16,
                      color: isClustered ? AppColors.urgentWarning : AppColors.neonLime,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        isClustered
                            ? '⚠️ [연속 배차 감지] 뒤차(${arrivalInfo!.nextBusSummary})가 붙어서 오고 있습니다!'
                            : arrivalInfo!.nextBusSummary,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isClustered ? FontWeight.w700 : FontWeight.w500,
                          color: isClustered ? AppColors.urgentWarning : AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
