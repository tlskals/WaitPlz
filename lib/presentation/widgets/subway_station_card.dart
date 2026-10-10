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

  /// 도착 정보 문자열을 상/하행, 방면, 행선지, 상태로 정밀 파싱
  List<_ParsedArrivalItem> _parseArrivals() {
    final list = <_ParsedArrivalItem>[];

    for (int i = 0; i < widget.arrivals.length; i++) {
      final a = widget.arrivals[i];
      final raw = a.direction;

      // 1. 상행(내선) vs 하행(외선) 판별
      bool isUp;
      if (raw.contains('상행') || raw.contains('내선')) {
        isUp = true;
      } else if (raw.contains('하행') || raw.contains('외선')) {
        isUp = false;
      } else {
        // 태그가 없는 경우 번갈아가며 분리
        isUp = (i % 2 == 0);
      }

      // 2. 태그 제거 및 행선지, 방면 분리
      // 예: "[상행] 광운대행 - 금천구청방면행" -> destination: "광운대행", heading: "금천구청방면"
      String clean = raw
          .replaceAll('[상행]', '')
          .replaceAll('[하행]', '')
          .replaceAll('[내선]', '')
          .replaceAll('[외선]', '')
          .trim();

      String destination = clean;
      String heading = isUp ? '상행 방면' : '하행 방면';

      if (clean.contains('-')) {
        final parts = clean.split('-');
        destination = parts[0].trim();
        String h = parts[1].trim();
        h = h.replaceAll('방면행', ' 방면').replaceAll('방면', ' 방면').trim();
        heading = h;
      } else if (clean.contains('방면')) {
        heading = clean;
      }

      // 3. 도착 상태 메시지
      String status = a.arrivalMessage.isNotEmpty
          ? a.arrivalMessage
          : a.arrivalTimeText;

      list.add(_ParsedArrivalItem(
        lineName: a.lineName,
        destination: destination,
        heading: heading,
        status: status,
        isUp: isUp,
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.stationName.endsWith('역')
        ? widget.stationName
        : '${widget.stationName}역';

    final parsedList = _parseArrivals();
    final upList = parsedList.where((p) => p.isUp).toList();
    final downList = parsedList.where((p) => !p.isUp).toList();

    // 상/하행 대표 방면 타이틀
    final upHeadingTitle = upList.isNotEmpty
        ? upList.first.heading
        : '상행 / 내선 방면';
    final downHeadingTitle = downList.isNotEmpty
        ? downList.first.heading
        : '하행 / 외선 방면';

    // 접힘/펼침 상태에 따른 노출 열차 개수 제어 (접혔을 때는 최신 1개만, 펼쳤을 때는 전체)
    final visibleUpList = _isExpanded ? upList : upList.take(1).toList();
    final visibleDownList = _isExpanded ? downList : downList.take(1).toList();

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

                  // 즐겨찾기 별 버튼 (★)
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

              const SizedBox(height: 10),

              // 2. 카드 본문: 1번 탭 스타일 완벽한 좌/우 2열 분할 레이아웃
              if (parsedList.isEmpty)
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
              else
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ◀ 왼쪽: 상행 / 내선 열차 리스트
                      Expanded(
                        child: _buildDirectionColumn(
                          headingTitle: upHeadingTitle,
                          items: visibleUpList,
                          fallbackText: '상행 운행 열차 없음',
                        ),
                      ),

                      // 가운데 세로 구분선
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        color: AppColors.cardBorder,
                      ),

                      // ▶ 오른쪽: 하행 / 외선 열차 리스트
                      Expanded(
                        child: _buildDirectionColumn(
                          headingTitle: downHeadingTitle,
                          items: visibleDownList,
                          fallbackText: '하행 운행 열차 없음',
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

  /// 좌/우 방면별 열차 컬럼 빌더 (상단 방면명 헤더 + 열차 행선지 및 도착 상태 리스트)
  Widget _buildDirectionColumn({
    required String headingTitle,
    required List<_ParsedArrivalItem> items,
    required String fallbackText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 상단 방면명 헤더 (예: "금천구청 방면" | "관악 방면")
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
                headingTitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              fallbackText,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        else
          ...items.map((item) {
            final isUrgent = item.status.contains('곧') ||
                item.status.contains('진입') ||
                item.status.contains('도착');

            return Padding(
              padding: EdgeInsets.only(bottom: _isExpanded ? 8 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1행: 행선지 (예: "광운대행", "청량리행")
                  Text(
                    item.destination,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // 2행: 도착 상태 (예: "2번째 전역 (안양)", "전역 도착")
                  Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isUrgent
                          ? AppColors.urgentWarning
                          : AppColors.neonLime,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _ParsedArrivalItem {
  final String lineName;
  final String destination;
  final String heading;
  final String status;
  final bool isUp;

  _ParsedArrivalItem({
    required this.lineName,
    required this.destination,
    required this.heading,
    required this.status,
    required this.isUp,
  });
}
