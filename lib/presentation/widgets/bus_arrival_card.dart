import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/bus_arrival_info.dart';
import '../../data/models/favorite_route.dart';

class BusArrivalCard extends StatefulWidget {
  final FavoriteRoute favorite;
  final BusArrivalInfo? arrivalInfo;
  final VoidCallback onDelete;

  const BusArrivalCard({
    super.key,
    required this.favorite,
    this.arrivalInfo,
    required this.onDelete,
  });

  @override
  State<BusArrivalCard> createState() => _BusArrivalCardState();
}

class _BusArrivalCardState extends State<BusArrivalCard> {
  bool _isExpanded = false;

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
    final routeColor = _getRouteColor(widget.favorite.routeType);
    final directionA = widget.arrivalInfo?.directionA;
    final directionB = widget.arrivalInfo?.directionB;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isExpanded
              ? AppColors.neonLime.withValues(alpha: 0.5)
              : AppColors.cardBorder,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 헤더: [버스 번호] + [정류장 이름] + [삭제 메뉴 & 펼침 아이콘]
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: routeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.favorite.routeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.favorite.stationName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz,
                        color: AppColors.textMuted, size: 20),
                    onPressed: widget.onDelete,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    duration: const Duration(milliseconds: 200),
                    turns: _isExpanded ? 0.5 : 0.0,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 10),

              // 2. 메인 양방향 (A방면 | B방면) 50:50 분할 영역
              if (widget.arrivalInfo == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
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
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 좌측: A 방면
                      Expanded(
                        child: _buildDirectionColumn(
                          direction: directionA,
                          fallbackName: widget.favorite.directionA.isNotEmpty
                              ? widget.favorite.directionA
                              : '상행 방면',
                          isLeft: true,
                        ),
                      ),
                      // 중앙 세로 구분선
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: AppColors.cardBorder,
                      ),
                      // 우측: B 방면
                      Expanded(
                        child: _buildDirectionColumn(
                          direction: directionB,
                          fallbackName: widget.favorite.directionB.isNotEmpty
                              ? widget.favorite.directionB
                              : '하행 방면',
                          isLeft: false,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 단일 방면 (A 또는 B) 컬럼 렌더링
  Widget _buildDirectionColumn({
    required DirectionArrival? direction,
    required String fallbackName,
    required bool isLeft,
  }) {
    final title = direction?.directionName ?? fallbackName;
    final first = direction?.firstArrival;
    final subsequent = direction?.subsequentArrivals ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 방면 라벨
        Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: AppColors.neonLime,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // 1번째 버스 (항상 노출되는 컴팩트 메인 정보)
        if (first == null)
          const Text(
            '도착 정보 없음',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          )
        else ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                first.arrivalTimeText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: first.predictTimeSec <= 180
                      ? AppColors.urgentWarning
                      : AppColors.neonLime,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  first.remainingStopsText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // 광역버스인 경우 잔여석 뱃지 표시
          if (first.hasRemainingSeats) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: first.remainSeatCnt <= 5
                    ? AppColors.urgentWarning.withValues(alpha: 0.15)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: first.remainSeatCnt <= 5
                      ? AppColors.urgentWarning
                      : AppColors.cardBorder,
                  width: 0.8,
                ),
              ),
              child: Text(
                '잔여 ${first.remainSeatCnt}석',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: first.remainSeatCnt <= 5
                      ? AppColors.urgentWarning
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ],

        // 3. 확장 시 노출되는 후속 버스(2차, 3차) 목록
        if (_isExpanded && subsequent.isNotEmpty) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: subsequent.asMap().entries.map((entry) {
                final idx = entry.key + 2; // 2번째 차, 3번째 차
                final bus = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.5),
                  child: Row(
                    children: [
                      Text(
                        '$idx차',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonLime,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${bus.arrivalTimeText} (${bus.locationNo}전)',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (bus.hasRemainingSeats) ...[
                        const Spacer(),
                        Text(
                          '${bus.remainSeatCnt}석',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}
