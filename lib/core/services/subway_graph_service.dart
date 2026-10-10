import 'dart:collection';

/// 지하철 노선 역 노드 모델
class SubwayStationNode {
  final String name;
  final List<String> lines;
  final double x; // 노선도 상의 상대 좌표 X (0 ~ 1000)
  final double y; // 노선도 상의 상대 좌표 Y (0 ~ 1000)

  const SubwayStationNode({
    required this.name,
    required this.lines,
    required this.x,
    required this.y,
  });

  bool get isTransfer => lines.length > 1;
}

/// 경로 이동 세그먼트 (환승 단위 구간)
class SubwayPathSegment {
  final String lineName;
  final String fromStation;
  final String toStation;
  final List<String> stations; // 경유 역 목록
  final int durationMinutes;
  final String? transferStation;
  final String? fastTransferDoor; // 빠른 환승 문 (예: "3-4번")

  const SubwayPathSegment({
    required this.lineName,
    required this.fromStation,
    required this.toStation,
    required this.stations,
    required this.durationMinutes,
    this.transferStation,
    this.fastTransferDoor,
  });
}

/// 최종 경로 탐색 결과 모델
class SubwayRoutePlan {
  final String fromStation;
  final String toStation;
  final int totalMinutes;
  final int stationCount;
  final int transferCount;
  final List<SubwayPathSegment> segments;

  const SubwayRoutePlan({
    required this.fromStation,
    required this.toStation,
    required this.totalMinutes,
    required this.stationCount,
    required this.transferCount,
    required this.segments,
  });
}

/// 지하철 연결망 및 최적 경로(다익스트라/BFS) 엔진
class SubwayGraphService {
  static final SubwayGraphService _instance = SubwayGraphService._internal();
  factory SubwayGraphService() => _instance;
  SubwayGraphService._internal();

  /// 노선도 상의 모든 주요 역 좌표 및 소속 호선
  final Map<String, SubwayStationNode> stations = {
    // 2호선 (순환 중심축)
    '시청': const SubwayStationNode(name: '시청', lines: ['1호선', '2호선'], x: 420, y: 310),
    '을지로입구': const SubwayStationNode(name: '을지로입구', lines: ['2호선'], x: 470, y: 310),
    '을지로3가': const SubwayStationNode(name: '을지로3가', lines: ['2호선', '3호선'], x: 520, y: 310),
    '동대문역사문화공원': const SubwayStationNode(name: '동대문역사문화공원', lines: ['2호선', '4호선', '5호선'], x: 580, y: 330),
    '신당': const SubwayStationNode(name: '신당', lines: ['2호선', '6호선'], x: 640, y: 350),
    '왕십리': const SubwayStationNode(name: '왕십리', lines: ['2호선', '5호선', '수인분당선', '경의중앙선'], x: 690, y: 370),
    '성수': const SubwayStationNode(name: '성수', lines: ['2호선'], x: 730, y: 410),
    '건대입구': const SubwayStationNode(name: '건대입구', lines: ['2호선', '7호선'], x: 740, y: 460),
    '잠실': const SubwayStationNode(name: '잠실', lines: ['2호선', '8호선'], x: 730, y: 550),
    '삼성': const SubwayStationNode(name: '삼성', lines: ['2호선'], x: 670, y: 580),
    '선릉': const SubwayStationNode(name: '선릉', lines: ['2호선', '수인분당선'], x: 620, y: 590),
    '역삼': const SubwayStationNode(name: '역삼', lines: ['2호선'], x: 570, y: 590),
    '강남': const SubwayStationNode(name: '강남', lines: ['2호선', '신분당선'], x: 520, y: 590),
    '교대': const SubwayStationNode(name: '교대', lines: ['2호선', '3호선'], x: 460, y: 590),
    '서초': const SubwayStationNode(name: '서초', lines: ['2호선'], x: 410, y: 590),
    '사당': const SubwayStationNode(name: '사당', lines: ['2호선', '4호선'], x: 370, y: 620),
    '신림': const SubwayStationNode(name: '신림', lines: ['2호선', '신림선'], x: 300, y: 620),
    '대림': const SubwayStationNode(name: '대림', lines: ['2호선', '7호선'], x: 240, y: 580),
    '신도림': const SubwayStationNode(name: '신도림', lines: ['1호선', '2호선'], x: 220, y: 520),
    '영등포구청': const SubwayStationNode(name: '영등포구청', lines: ['2호선', '5호선'], x: 220, y: 450),
    '당산': const SubwayStationNode(name: '당산', lines: ['2호선', '9호선'], x: 240, y: 390),
    '합정': const SubwayStationNode(name: '합정', lines: ['2호선', '6호선'], x: 280, y: 340),
    '홍대입구': const SubwayStationNode(name: '홍대입구', lines: ['2호선', '공항철도', '경의중앙선'], x: 320, y: 310),
    '신촌': const SubwayStationNode(name: '신촌', lines: ['2호선'], x: 360, y: 310),
    '충정로': const SubwayStationNode(name: '충정로', lines: ['2호선', '5호선'], x: 390, y: 310),

    // 1호선
    '종로3가': const SubwayStationNode(name: '종로3가', lines: ['1호선', '3호선', '5호선'], x: 510, y: 270),
    '종로5가': const SubwayStationNode(name: '종로5가', lines: ['1호선'], x: 560, y: 270),
    '동대문': const SubwayStationNode(name: '동대문', lines: ['1호선', '4호선'], x: 610, y: 270),
    '청량리': const SubwayStationNode(name: '청량리', lines: ['1호선', '수인분당선', '경의중앙선'], x: 700, y: 250),
    '서울역': const SubwayStationNode(name: '서울역', lines: ['1호선', '4호선', '공항철도', '경의중앙선'], x: 420, y: 370),
    '남영': const SubwayStationNode(name: '남영', lines: ['1호선'], x: 420, y: 410),
    '용산': const SubwayStationNode(name: '용산', lines: ['1호선', '경의중앙선'], x: 420, y: 450),
    '노량진': const SubwayStationNode(name: '노량진', lines: ['1호선', '9호선'], x: 370, y: 490),
    '대방': const SubwayStationNode(name: '대방', lines: ['1호선', '신림선'], x: 320, y: 500),
    '영등포': const SubwayStationNode(name: '영등포', lines: ['1호선'], x: 260, y: 510),
    '구로': const SubwayStationNode(name: '구로', lines: ['1호선'], x: 190, y: 540),
    '가산디지털단지': const SubwayStationNode(name: '가산디지털단지', lines: ['1호선', '7호선'], x: 190, y: 610),
    '수원': const SubwayStationNode(name: '수원', lines: ['1호선', '수인분당선'], x: 190, y: 850),

    // 3호선
    '경복궁': const SubwayStationNode(name: '경복궁', lines: ['3호선'], x: 460, y: 220),
    '안국': const SubwayStationNode(name: '안국', lines: ['3호선'], x: 490, y: 240),
    '충무로': const SubwayStationNode(name: '충무로', lines: ['3호선', '4호선'], x: 550, y: 360),
    '동대입구': const SubwayStationNode(name: '동대입구', lines: ['3호선'], x: 550, y: 400),
    '약수': const SubwayStationNode(name: '약수', lines: ['3호선', '6호선'], x: 560, y: 440),
    '옥수': const SubwayStationNode(name: '옥수', lines: ['3호선', '경의중앙선'], x: 560, y: 480),
    '압구정': const SubwayStationNode(name: '압구정', lines: ['3호선'], x: 530, y: 510),
    '신사': const SubwayStationNode(name: '신사', lines: ['3호선', '신분당선'], x: 490, y: 530),
    '고속터미널': const SubwayStationNode(name: '고속터미널', lines: ['3호선', '7호선', '9호선'], x: 440, y: 550),
    '남부터미널': const SubwayStationNode(name: '남부터미널', lines: ['3호선'], x: 460, y: 640),
    '양재': const SubwayStationNode(name: '양재', lines: ['3호선', '신분당선'], x: 520, y: 660),
    '수서': const SubwayStationNode(name: '수서', lines: ['3호선', '수인분당선', 'GTX-A'], x: 730, y: 690),

    // 4호선
    '혜화': const SubwayStationNode(name: '혜화', lines: ['4호선'], x: 610, y: 220),
    '명동': const SubwayStationNode(name: '명동', lines: ['4호선'], x: 480, y: 360),
    '삼각지': const SubwayStationNode(name: '삼각지', lines: ['4호선', '6호선'], x: 420, y: 430),
    '이촌': const SubwayStationNode(name: '이촌', lines: ['4호선', '경의중앙선'], x: 440, y: 490),
    '동작': const SubwayStationNode(name: '동작', lines: ['4호선', '9호선'], x: 400, y: 550),
    '총신대입구': const SubwayStationNode(name: '총신대입구', lines: ['4호선', '7호선'], x: 380, y: 590),
    '정부과천청사': const SubwayStationNode(name: '정부과천청사', lines: ['4호선'], x: 370, y: 740),
    '금정': const SubwayStationNode(name: '금정', lines: ['1호선', '4호선'], x: 370, y: 810),

    // 5호선
    '김포공항': const SubwayStationNode(name: '김포공항', lines: ['5호선', '9호선', '공항철도', '서해선'], x: 120, y: 350),
    '여의도': const SubwayStationNode(name: '여의도', lines: ['5호선', '9호선'], x: 300, y: 450),
    '여의나루': const SubwayStationNode(name: '여의나루', lines: ['5호선'], x: 330, y: 430),
    '공덕': const SubwayStationNode(name: '공덕', lines: ['5호선', '6호선', '공항철도', '경의중앙선'], x: 370, y: 390),
    '광화문': const SubwayStationNode(name: '광화문', lines: ['5호선'], x: 470, y: 260),
    '군자': const SubwayStationNode(name: '군자', lines: ['5호선', '7호선'], x: 770, y: 390),
    '천호': const SubwayStationNode(name: '천호', lines: ['5호선', '8호선'], x: 820, y: 500),

    // 7호선
    '논현': const SubwayStationNode(name: '논현', lines: ['7호선', '신분당선'], x: 480, y: 560),
    '학동': const SubwayStationNode(name: '학동', lines: ['7호선'], x: 530, y: 550),
    '강남구청': const SubwayStationNode(name: '강남구청', lines: ['7호선', '수인분당선'], x: 580, y: 540),
    '청담': const SubwayStationNode(name: '청담', lines: ['7호선'], x: 640, y: 520),

    // 9호선
    '국회의사당': const SubwayStationNode(name: '국회의사당', lines: ['9호선'], x: 270, y: 430),
    '샛강': const SubwayStationNode(name: '샛강', lines: ['9호선', '신림선'], x: 320, y: 470),
    '신논현': const SubwayStationNode(name: '신논현', lines: ['9호선', '신분당선'], x: 510, y: 570),
    '선정릉': const SubwayStationNode(name: '선정릉', lines: ['9호선', '수인분당선'], x: 620, y: 560),
    '봉은사': const SubwayStationNode(name: '봉은사', lines: ['9호선'], x: 670, y: 550),
    '종합운동장': const SubwayStationNode(name: '종합운동장', lines: ['2호선', '9호선'], x: 700, y: 560),
    '올림픽공원': const SubwayStationNode(name: '올림픽공원', lines: ['5호선', '9호선'], x: 800, y: 570),

    // 신분당선 (강남-판교-광교 축)
    '양재시민의숲': const SubwayStationNode(name: '양재시민의숲', lines: ['신분당선'], x: 540, y: 700),
    '청계산입구': const SubwayStationNode(name: '청계산입구', lines: ['신분당선'], x: 560, y: 740),
    '판교': const SubwayStationNode(name: '판교', lines: ['신분당선', '경강선'], x: 580, y: 780),
    '정자': const SubwayStationNode(name: '정자', lines: ['신분당선', '수인분당선'], x: 590, y: 820),
    '미금': const SubwayStationNode(name: '미금', lines: ['신분당선', '수인분당선'], x: 600, y: 850),
    '광교': const SubwayStationNode(name: '광교', lines: ['신분당선'], x: 600, y: 920),

    // 수인분당선 (분당-용인-수원 축)
    '야탑': const SubwayStationNode(name: '야탑', lines: ['수인분당선'], x: 660, y: 750),
    '이매': const SubwayStationNode(name: '이매', lines: ['수인분당선', '경강선'], x: 660, y: 770),
    '서현': const SubwayStationNode(name: '서현', lines: ['수인분당선'], x: 650, y: 790),
    '수내': const SubwayStationNode(name: '수내', lines: ['수인분당선'], x: 640, y: 810),
    '복정': const SubwayStationNode(name: '복정', lines: ['8호선', '수인분당선'], x: 740, y: 660),
  };

  /// 노선별 연속된 역 연결 리스트 (순서대로 연결된 역)
  late final Map<String, List<String>> lineRoutes = {
    '1호선': [
      '청량리', '동대문', '종로5가', '종로3가', '시청', '서울역', '남영', '용산', '노량진', '대방', '영등포', '신도림', '구로', '가산디지털단지', '수원'
    ],
    '2호선': [
      '시청', '을지로입구', '을지로3가', '동대문역사문화공원', '신당', '왕십리', '성수', '건대입구',
      '잠실', '종합운동장', '삼성', '선릉', '역삼', '강남', '교대', '서초', '사당', '신림',
      '대림', '신도림', '영등포구청', '당산', '합정', '홍대입구', '신촌', '충정로', '시청' // 순환선
    ],
    '3호선': [
      '경복궁', '안국', '종로3가', '을지로3가', '충무로', '동대입구', '약수', '옥수',
      '압구정', '신사', '고속터미널', '교대', '남부터미널', '양재', '수서'
    ],
    '4호선': [
      '혜화', '동대문', '동대문역사문화공원', '충무로', '명동', '서울역', '삼각지', '이촌',
      '동작', '총신대입구', '사당', '정부과천청사', '금정'
    ],
    '5호선': [
      '김포공항', '영등포구청', '여의도', '여의나루', '공덕', '충정로', '광화문', '종로3가',
      '동대문역사문화공원', '왕십리', '군자', '천호'
    ],
    '7호선': [
      '군자', '건대입구', '청담', '강남구청', '학동', '논현', '반포', '고속터미널',
      '총신대입구', '대림', '가산디지털단지'
    ],
    '9호선': [
      '김포공항', '당산', '국회의사당', '여의도', '샛강', '노량진', '동작',
      '고속터미널', '신논현', '선정릉', '봉은사', '종합운동장', '올림픽공원'
    ],
    '신분당선': [
      '신사', '논현', '신논현', '강남', '양재', '양재시민의숲', '청계산입구', '판교', '정자', '미금', '광교'
    ],
    '수인분당선': [
      '청량리', '왕십리', '강남구청', '선정릉', '선릉', '수서', '복정',
      '야탑', '이매', '서현', '수내', '정자', '미금', '수원'
    ],
  };

  /// 주요 환승역 빠른 환승 위치 매핑
  final Map<String, String> fastTransferMap = {
    '강남': '2호선↔신분당선 빠른 환승: 4-2번 문 (계단 바로 앞)',
    '신논현': '9호선↔신분당선 빠른 환승: 1-1번 문',
    '신사': '3호선↔신분당선 빠른 환승: 6-3번 문',
    '고속터미널': '3호선↔7호선↔9호선 빠른 환승: 7-2번 문 (에스컬레이터)',
    '교대': '2호선↔3호선 빠른 환승: 3-4번 문',
    '사당': '2호선↔4호선 빠른 환승: 10-4번 문 (최단 환승 통로)',
    '서울역': '1호선↔4호선↔공항철도 빠른 환승: 8-1번 문',
    '신도림': '1호선↔2호선 빠른 환승: 1-4번 문',
    '당산': '2호선↔9호선 빠른 환승: 6-4번 문',
    '여의도': '5호선↔9호선 빠른 환승: 3-1번 문',
    '공덕': '5호선↔6호선↔공항철도 빠른 환승: 4-3번 문',
    '동대문역사문화공원': '2호선↔4호선↔5호선 빠른 환승: 8-3번 문',
    '종로3가': '1호선↔3호선↔5호선 빠른 환승: 5-2번 문',
    '을지로3가': '2호선↔3호선 빠른 환승: 2-3번 문',
    '왕십리': '2호선↔5호선↔수인분당선 빠른 환승: 6-1번 문',
    '건대입구': '2호선↔7호선 빠른 환승: 1-1번 문',
    '잠실': '2호선↔8호선 빠른 환승: 2-4번 문',
    '판교': '신분당선↔경강선 빠른 환승: 3-2번 문',
    '정자': '신분당선↔수인분당선 빠른 환승: 2-2번 문',
    '수서': '3호선↔수인분당선↔GTX 빠른 환승: 4-1번 문',
  };

  /// 그래프 인접 리스트: `Map<String, Map<String, String>>` (Station -> Map of Neighbor to Line)
  late final Map<String, Map<String, String>> _graph = _buildGraph();

  Map<String, Map<String, String>> _buildGraph() {
    final graph = <String, Map<String, String>>{};

    lineRoutes.forEach((lineName, stationsList) {
      for (int i = 0; i < stationsList.length - 1; i++) {
        final st1 = stationsList[i];
        final st2 = stationsList[i + 1];

        graph.putIfAbsent(st1, () => {})[st2] = lineName;
        graph.putIfAbsent(st2, () => {})[st1] = lineName;
      }
    });

    return graph;
  }

  /// 다익스트라 최적 경로 탐색 (최소 정차역 & 최소 환승 가중치)
  SubwayRoutePlan? findOptimalRoute(String fromStation, String toStation) {
    final start = fromStation.trim().replaceAll('역', '');
    final end = toStation.trim().replaceAll('역', '');

    if (start == end) return null;
    if (!_graph.containsKey(start) || !_graph.containsKey(end)) return null;

    // 우선순위 큐 대체 (비용, 현재역, 경로 리스트, 탑승중인 호선)
    final queue = Queue<_QueueItem>();
    final minCostMap = <String, int>{};

    queue.add(_QueueItem(
      station: start,
      cost: 0,
      path: [start],
      linesUsed: [],
    ));

    _QueueItem? bestResult;

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();

      if (current.station == end) {
        if (bestResult == null || current.cost < bestResult.cost) {
          bestResult = current;
        }
        continue;
      }

      final neighbors = _graph[current.station] ?? {};
      for (final entry in neighbors.entries) {
        final nextStation = entry.key;
        final edgeLine = entry.value;

        if (current.path.contains(nextStation)) continue; // 루프 방지

        // 환승 패널티 비용: 호선이 변경되면 +4분 가중치, 일반 1정거장 이동 +2분
        final isTransfer = current.linesUsed.isNotEmpty && current.linesUsed.last != edgeLine;
        final stepCost = isTransfer ? 5 : 2;
        final nextCost = current.cost + stepCost;

        if (minCostMap.containsKey(nextStation) && minCostMap[nextStation]! <= nextCost) {
          continue;
        }
        minCostMap[nextStation] = nextCost;

        queue.add(_QueueItem(
          station: nextStation,
          cost: nextCost,
          path: [...current.path, nextStation],
          linesUsed: [...current.linesUsed, edgeLine],
        ));
      }
    }

    if (bestResult == null) return null;

    // 경로 세그먼트(환승 단위 구간) 분할
    return _buildRoutePlan(bestResult.path, bestResult.linesUsed, start, end);
  }

  SubwayRoutePlan _buildRoutePlan(
      List<String> path, List<String> linesUsed, String fromStation, String toStation) {
    final segments = <SubwayPathSegment>[];
    if (path.length < 2) {
      return SubwayRoutePlan(
        fromStation: fromStation,
        toStation: toStation,
        totalMinutes: 0,
        stationCount: 0,
        transferCount: 0,
        segments: [],
      );
    }

    int segStart = 0;
    int transferCount = 0;

    for (int i = 0; i < linesUsed.length; i++) {
      final isLast = (i == linesUsed.length - 1);
      final isLineChange = !isLast && (linesUsed[i] != linesUsed[i + 1]);

      if (isLineChange || isLast) {
        final lineName = linesUsed[i];
        final subPath = path.sublist(segStart, i + 2);
        final from = path[segStart];
        final to = path[i + 1];
        final duration = (subPath.length - 1) * 2 + 1;

        String? fastDoor;
        if (isLineChange) {
          transferCount++;
          fastDoor = fastTransferMap[to] ?? '가운데 칸(3-4번) 환승 권장';
        }

        segments.add(SubwayPathSegment(
          lineName: lineName,
          fromStation: from,
          toStation: to,
          stations: subPath,
          durationMinutes: duration,
          transferStation: isLineChange ? to : null,
          fastTransferDoor: fastDoor,
        ));

        segStart = i + 1;
      }
    }

    final totalMinutes = segments.fold<int>(0, (sum, s) => sum + s.durationMinutes) + (transferCount * 4);
    final totalStations = path.length - 1;

    return SubwayRoutePlan(
      fromStation: fromStation,
      toStation: toStation,
      totalMinutes: totalMinutes,
      stationCount: totalStations,
      transferCount: transferCount,
      segments: segments,
    );
  }
}

class _QueueItem {
  final String station;
  final int cost;
  final List<String> path;
  final List<String> linesUsed;

  _QueueItem({
    required this.station,
    required this.cost,
    required this.path,
    required this.linesUsed,
  });
}
