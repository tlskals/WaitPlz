/// 버스 노선 경유 정류장 모델
class BusStopItem {
  final String stationId;
  final String stationName; // 정류장 이름
  final int stationSeq; // 정류장 순번
  final String arsId; // 정류소 번호 (예: 23-285, 03-120)
  final String directionName; // 방면
  final bool isTurningPoint; // 회차지 여부

  const BusStopItem({
    required this.stationId,
    required this.stationName,
    required this.stationSeq,
    this.arsId = '',
    this.directionName = '',
    this.isTurningPoint = false,
  });
}

/// 버스 노선 상세 및 검색 결과 모델
class BusRouteDetail {
  final String routeId;
  final String routeName; // 버스 번호 (예: 143, 9401, 7016, 1)
  final String region; // 지역 (예: 서울, 경기, 부천, 수원, 성남)
  final String routeType; // 간선, 지선, 광역, 마을 등
  final String startStation; // 기점
  final String endStation; // 종점
  final String operatingHours; // 운행 시간 (예: 04:00 ~ 22:30)
  final String interval; // 배차 간격 (예: 4~8분)
  final String directionA; // A 방면 (상행)
  final String directionB; // B 방면 (하행)
  final List<BusStopItem> stations; // 전체 경유 정류장 목록

  const BusRouteDetail({
    required this.routeId,
    required this.routeName,
    required this.region,
    required this.routeType,
    required this.startStation,
    required this.endStation,
    this.operatingHours = '04:30 ~ 23:30',
    this.interval = '5~10분',
    required this.directionA,
    required this.directionB,
    this.stations = const [],
  });

  /// 기점 ⇋ 종점 포맷 텍스트
  String get routeSummary => '$startStation ⇋ $endStation';
}
