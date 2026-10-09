/// 단일 버스 차량 도착 정보 (도착 시간, 남은 정류장, 잔여석 등)
class SingleBusArrival {
  final int predictTimeSec; // 도착 예정 시간 (초)
  final int locationNo; // 남은 정류장 수
  final int remainSeatCnt; // 남은 좌석 수 (광역버스만 양수, 일반버스는 -1)
  final String plateNo; // 차량 번호 (예: 경기70사1234)
  final bool isLowPlate; // 저상버스 여부

  const SingleBusArrival({
    required this.predictTimeSec,
    required this.locationNo,
    this.remainSeatCnt = -1,
    this.plateNo = '',
    this.isLowPlate = false,
  });

  /// 도착 예정 시간 (분 단위 텍스트)
  String get arrivalTimeText {
    if (predictTimeSec <= 0) {
      if (locationNo == 1) return '곧 도착';
      return '도착 정보 없음';
    }
    final minutes = (predictTimeSec / 60).ceil();
    return '$minutes분';
  }

  /// 남은 정류장 텍스트
  String get remainingStopsText {
    if (locationNo <= 0) return '';
    if (locationNo == 1) return '1번째 전';
    return '$locationNo번째 전';
  }

  /// 잔여 좌석 표시 가능 여부 (광역/직행 버스만 해당)
  bool get hasRemainingSeats => remainSeatCnt >= 0;
}

/// 특정 방면(상행 또는 하행)의 도착 예정 버스 목록
class DirectionArrival {
  final String directionName; // 방면 이름 (예: "정릉 방면", "개포동 방면")
  final List<SingleBusArrival> arrivals; // 1차, 2차, 3차 등 도착 예정 목록

  const DirectionArrival({
    required this.directionName,
    this.arrivals = const [],
  });

  SingleBusArrival? get firstArrival =>
      arrivals.isNotEmpty ? arrivals[0] : null;

  List<SingleBusArrival> get subsequentArrivals =>
      arrivals.length > 1 ? arrivals.sublist(1) : const [];
}

/// 양방향(A방면 / B방면) 통합 버스 도착 정보 모델
class BusArrivalInfo {
  final String routeId;
  final String routeName; // 버스 번호 (예: 143, 7016, 9401)
  final String routeType; // 간선, 지선, 광역, 마을 등
  final String stationId;
  final String stationName; // 기준 정류장 이름
  final DirectionArrival directionA; // A 방면 (예: 상행/서울역 방면)
  final DirectionArrival directionB; // B 방면 (예: 하행/분당 방면)
  final DateTime updatedAt;

  const BusArrivalInfo({
    required this.routeId,
    required this.routeName,
    required this.routeType,
    required this.stationId,
    required this.stationName,
    required this.directionA,
    required this.directionB,
    required this.updatedAt,
  });
}
