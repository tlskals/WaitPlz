import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/subway_arrival_info.dart';

class SubwayStationCard extends StatefulWidget {
  final String stationName;
  final List<SubwayArrivalInfo> arrivals;
  final VoidCallback onToggleFavorite;

  const SubwayStationCard({
    super.key,
    required this.stationName,
    required this.arrivals,
    required this.onToggleFavorite,
  });

  @override
  State<SubwayStationCard> createState() => _SubwayStationCardState();
}

class _SubwayStationCardState extends State<SubwayStationCard> {
  bool _isExpanded = false;

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
    if (lineName.contains('공항철도')) return const Color(0xFF0090D2);
    if (lineName.contains('경의중앙')) return const Color(0xFF77C4A3);
    return const Color(0xFF6B7280);
  }

  /// 역에 정차하는 고유 호선 목록 추출
  List<String> get _distinctLines {
    final lines = widget.arrivals.map((a) => a.lineName).toSet().toList();
    if (lines.isEmpty) return ['지하철'];
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.stationName.endsWith('역')
        ? widget.stationName
        : '${widget.stationName}역';

    // 대표 상/하행 도착 정보 분리
    final firstArrival = widget.arrivals.isNotEmpty ? widget.arrivals[0] : null;
    final secondArrival = widget.arrivals.length > 1 ? widget.arrivals[1] : null;

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
              // 1. 헤더: [호선 뱃지들] + [역 이름] + [별 즐겨찾기 버튼] + [접힘/펼침]
              Row(
                children: [
                  // 호선 뱃지들
                  Row(
                    children: _distinctLines.take(3).map((line) {
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: _getLineColor(line),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          line,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 4),
                  // 역 이름
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // 즐겨찾기 별 버튼 (★ 누르면 즐겨찾기 해제)
                  IconButton(
                    icon: const Icon(Icons.star,
                        color: AppColors.neonLime, size: 24),
                    tooltip: '즐겨찾기 해제',
                    onPressed: widget.onToggleFavorite,
                  ),

                  // 펼침/접힘 화살표 아이콘
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppColors.textMuted,
                    size: 22,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. 카드 본문: 도착 정보 (1번 탭 버스 스타일 2열 그리드)
              if (widget.arrivals.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: const Text(
                    '현재 실시간 운행 중인 열차가 없거나 운행 종료되었습니다.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
              else if (!_isExpanded)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 첫 번째 방면 도착 정보
                    Expanded(
                      child: _buildArrivalColumn(
                        arrival: firstArrival,
                        fallbackLabel: '상행 / 내선',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      color: AppColors.cardBorder,
                    ),
                    // 두 번째 방면 도착 정보
                    Expanded(
                      child: _buildArrivalColumn(
                        arrival: secondArrival,
                        fallbackLabel: '하행 / 외선',
                      ),
                    ),
                  ],
                )
              else
                // 펼쳤을 때: 모든 열차 도착 현황 전체 리스트
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: AppColors.cardBorder, height: 16),
                    ...widget.arrivals.map((item) {
                      final lineColor = _getLineColor(item.lineName);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: lineColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: lineColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.lineName,
                                style: TextStyle(
                                  color: lineColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${item.direction}행',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              item.arrivalMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.neonLime,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2열 분할 도착 정보 컬럼 빌더 (1번 탭 버스 스타일 일관성)
  Widget _buildArrivalColumn({
    required SubwayArrivalInfo? arrival,
    required String fallbackLabel,
  }) {
    if (arrival == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                fallbackLabel,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            '도착 정보 없음',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    final isSoon = arrival.arrivalMessage.contains('곧') ||
        arrival.arrivalMessage.contains('진입') ||
        arrival.arrivalMessage.contains('도착');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 방향 안내
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.neonLime,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                arrival.direction,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),

        // 도착 시간 / 상태 (예: 3분 2번째 전역 or 곧 도착)
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: isSoon ? '곧 도착 ' : arrival.arrivalTimeText,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: isSoon ? AppColors.urgentWarning : AppColors.neonLime,
                  letterSpacing: -0.5,
                ),
              ),
              if (!isSoon && arrival.arrivalMessage.isNotEmpty)
                TextSpan(
                  text: ' ${arrival.arrivalMessage.replaceAll(arrival.arrivalTimeText, '').trim()}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
