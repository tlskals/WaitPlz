import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/subway_graph_service.dart';

/// 인터랙티브 벡터 지하철 노선도 뷰어
class SubwayMapViewer extends StatefulWidget {
  final Function(String stationName) onStationSelected;
  final String? startStation;
  final String? endStation;
  final SubwayRoutePlan? activeRoutePlan;

  const SubwayMapViewer({
    super.key,
    required this.onStationSelected,
    this.startStation,
    this.endStation,
    this.activeRoutePlan,
  });

  @override
  State<SubwayMapViewer> createState() => _SubwayMapViewerState();
}

class _SubwayMapViewerState extends State<SubwayMapViewer> {
  final TransformationController _transformController =
      TransformationController();
  final SubwayGraphService _graphService = SubwayGraphService();

  static const double _canvasWidth = 1000.0;
  static const double _canvasHeight = 1000.0;

  @override
  void initState() {
    super.initState();
    // 초기 중심 화면을 강남/서울 중심(약 480, 480)으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerMap();
    });
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _centerMap() {
    final matrix = Matrix4.identity();
    matrix.setTranslationRaw(-200.0, -200.0, 0.0);
    matrix.storage[0] = 1.2;
    matrix.storage[5] = 1.2;
    _transformController.value = matrix;
  }

  void _zoomBy(double factor) {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final newScale = (currentScale * factor).clamp(0.6, 3.5);
    final scaleChange = newScale / currentScale;

    final matrix = _transformController.value.clone();
    matrix.storage[0] *= scaleChange;
    matrix.storage[5] *= scaleChange;
    _transformController.value = matrix;
  }

  void _handleTap(TapUpDetails details) {
    // 탭한 좌표를 캔버스 좌표계(1000 x 1000)로 역변환
    final localPos = details.localPosition;
    final invertedMatrix = Matrix4.inverted(_transformController.value);
    final canvasPos = MatrixUtils.transformPoint(invertedMatrix, localPos);

    // 가장 가까운 역 노드 탐색 (반경 30px 이내)
    String? closestStation;
    double minDistance = 32.0;

    _graphService.stations.forEach((name, node) {
      final dx = node.x - canvasPos.dx;
      final dy = node.y - canvasPos.dy;
      final dist = (dx * dx + dy * dy);
      if (dist < minDistance * minDistance) {
        minDistance = dist;
        closestStation = name;
      }
    });

    if (closestStation != null) {
      widget.onStationSelected(closestStation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeStations = <String>{};
    if (widget.activeRoutePlan != null) {
      for (final seg in widget.activeRoutePlan!.segments) {
        routeStations.addAll(seg.stations);
      }
    }

    return Stack(
      children: [
        // 1. InteractiveViewer 기반 핀치 줌 & 팬 노선도
        Positioned.fill(
          child: GestureDetector(
            onTapUp: _handleTap,
            child: InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.6,
              maxScale: 3.5,
              boundaryMargin: const EdgeInsets.all(350),
              child: SizedBox(
                width: _canvasWidth,
                height: _canvasHeight,
                child: CustomPaint(
                  size: const Size(_canvasWidth, _canvasHeight),
                  painter: _SubwayMapPainter(
                    graphService: _graphService,
                    startStation: widget.startStation,
                    endStation: widget.endStation,
                    routeStations: routeStations,
                  ),
                ),
              ),
            ),
          ),
        ),

        // 2. 우상단 줌 컨트롤 버튼 (+, -, 초기화)
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControlBtn(
                icon: Icons.add,
                onTap: () => _zoomBy(1.3),
                tooltip: '확대',
              ),
              const SizedBox(height: 6),
              _buildMapControlBtn(
                icon: Icons.remove,
                onTap: () => _zoomBy(0.7),
                tooltip: '축소',
              ),
              const SizedBox(height: 6),
              _buildMapControlBtn(
                icon: Icons.center_focus_strong,
                onTap: _centerMap,
                tooltip: '중심 위치',
              ),
            ],
          ),
        ),

        // 3. 좌하단 조작 안내 뱃지
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.touch_app, color: AppColors.neonLime, size: 14),
                const SizedBox(width: 5),
                Text(
                  '역 터치 시 실시간 도착 / 경로 지정',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neonLime.withValues(alpha: 0.95),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControlBtn({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.neonLime, size: 19),
      ),
    );
  }
}

/// 노선도 커스텀 페인터
class _SubwayMapPainter extends CustomPainter {
  final SubwayGraphService graphService;
  final String? startStation;
  final String? endStation;
  final Set<String> routeStations;

  _SubwayMapPainter({
    required this.graphService,
    this.startStation,
    this.endStation,
    required this.routeStations,
  });

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
    if (lineName.contains('경의중앙')) return const Color(0xFF77C4A3);
    if (lineName.contains('공항철도')) return const Color(0xFF0090D2);
    if (lineName.contains('경강선')) return const Color(0xFF003DA5);
    return AppColors.neonLime;
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 0. 다크 배경 및 은은한 그리드
    final bgPaint = Paint()..color = const Color(0xFF141416);
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 1. 노선 선로 그리기 (라인 트랙)
    graphService.lineRoutes.forEach((lineName, stationsList) {
      final lineColor = _getLineColor(lineName);
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: 0.85)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      bool first = true;

      for (final stName in stationsList) {
        final node = graphService.stations[stName];
        if (node == null) continue;
        if (first) {
          path.moveTo(node.x, node.y);
          first = false;
        } else {
          path.lineTo(node.x, node.y);
        }
      }

      canvas.drawPath(path, linePaint);
    });

    // 2. 경로 탐색 활성화 시 해당 경로 네온 라임 하이라이트
    if (routeStations.isNotEmpty) {
      final highlightPaint = Paint()
        ..color = AppColors.neonLime
        ..strokeWidth = 8.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);

      // 경유하는 역들 연결선 하이라이트
      final sortedRouteList = routeStations.toList();
      for (int i = 0; i < sortedRouteList.length - 1; i++) {
        final n1 = graphService.stations[sortedRouteList[i]];
        final n2 = graphService.stations[sortedRouteList[i + 1]];
        if (n1 != null && n2 != null) {
          canvas.drawLine(Offset(n1.x, n1.y), Offset(n2.x, n2.y), highlightPaint);
        }
      }
    }

    // 3. 역 노드 (서클) 및 텍스트 라벨 렌더링
    graphService.stations.forEach((name, node) {
      final isStart = (name == startStation);
      final isEnd = (name == endStation);
      final isRoute = routeStations.contains(name);
      final isTransfer = node.isTransfer;

      final center = Offset(node.x, node.y);

      // 노드 바깥 원 (환승역은 더 큰 흰색 원)
      if (isStart || isEnd) {
        final pinPaint = Paint()
          ..color = isStart ? AppColors.neonLime : const Color(0xFFFF5252)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 12.0, pinPaint);

        final pinBorder = Paint()
          ..color = Colors.black
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, 12.0, pinBorder);
      } else if (isRoute) {
        final routePaint = Paint()
          ..color = AppColors.neonLime
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 8.5, routePaint);
        canvas.drawCircle(
            center, 8.5, Paint()..color = Colors.black..strokeWidth = 2..style = PaintingStyle.stroke);
      } else if (isTransfer) {
        // 환승역: 이중 동심원
        final outerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 9.0, outerPaint);

        final borderPaint = Paint()
          ..color = Colors.black
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, 9.0, borderPaint);

        final innerPaint = Paint()
          ..color = const Color(0xFF222222)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 4.5, innerPaint);
      } else {
        // 일반역: 노선 대표 색상 원
        final color = _getLineColor(node.lines.first);
        final normalPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;
        canvas.drawCircle(center, 5.5, normalPaint);

        final normalBorder = Paint()
          ..color = color
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke;
        canvas.drawCircle(center, 5.5, normalBorder);
      }

      // 4. 역 이름 라벨 텍스트
      final textSpan = TextSpan(
        text: isStart
            ? '🚩 $name'
            : isEnd
                ? '🏁 $name'
                : name,
        style: TextStyle(
          color: (isStart || isEnd)
              ? (isStart ? AppColors.neonLime : const Color(0xFFFF5252))
              : isRoute
                  ? AppColors.neonLime
                  : Colors.white,
          fontSize: (isStart || isEnd || isTransfer) ? 12.0 : 10.5,
          fontWeight: (isStart || isEnd || isTransfer)
              ? FontWeight.w900
              : FontWeight.w600,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(-1, -1)),
          ],
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      // 라벨 위치: 노드 바로 아래
      textPainter.paint(
        canvas,
        Offset(center.dx - (textPainter.width / 2), center.dy + 10.0),
      );
    });
  }

  @override
  bool shouldRepaint(covariant _SubwayMapPainter oldDelegate) {
    return oldDelegate.startStation != startStation ||
        oldDelegate.endStation != endStation ||
        oldDelegate.routeStations != routeStations;
  }
}
