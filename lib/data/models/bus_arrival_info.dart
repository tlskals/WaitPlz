/// 실시간 버스 도착 정보 모델 (첫 번째 도착 예정 버스 & 다음 도착 예정 버스)
class BusArrivalInfo {
  final String routeId;
  final String routeName; // 버스 번호 (예: 9401, 7727, M5107 등)
  final String routeType; // 간선, 지선, 광역, 마을 등
  final String stationId;
  final String stationName; // 정류장 이름
  final String stationSeq; // 정류장 순번

  // 1번째 도착 예정 버스
  final int predictTimeSec1; // 도착 예정 시간 (초)
  final int locationNo1; // 남은 정류장 수
  final int remainSeatCnt1; // 남은 좌석 수 (-1이면 비지원)
  final String plateNo1; // 차량 번호
  final bool isLowPlate1; // 저상버스 여부

  // 2번째 도착 예정 버스 (연속 배차 여부 파악용)
  final int predictTimeSec2; // 2번째 버스 도착 예정 시간 (초)
  final int locationNo2; // 2번째 버스 남은 정류장 수
  final int remainSeatCnt2;
  final String plateNo2;

  final DateTime updatedAt;

  const BusArrivalInfo({
    required this.routeId,
    required this.routeName,
    required this.routeType,
    required this.stationId,
    required this.stationName,
    required this.stationSeq,
    required this.predictTimeSec1,
    required this.locationNo1,
    this.remainSeatCnt1 = -1,
    this.plateNo1 = '',
    this.isLowPlate1 = false,
    required this.predictTimeSec2,
    required this.locationNo2,
    this.remainSeatCnt2 = -1,
    this.plateNo2 = '',
    required this.updatedAt,
  });

  /// 도착 예정 시간 (분 단위 텍스트)
  String get arrivalTimeText1 {
    if (predictTimeSec1 <= 0) {
      if (locationNo1 == 1) return '곧 도착';
      return '운행 종료 또는 정보 없음';
    }
    final minutes = (predictTimeSec1 / 60).ceil();
    return '$minutes분';
  }

  /// 남은 정류장 텍스트
  String get remainingStopsText1 {
    if (locationNo1 <= 0) return '';
    if (locationNo1 == 1) return '1번째 전 (진입 중)';
    return '$locationNo1번째 전';
  }

  /// 2번째 버스 정보 텍스트 (배차 간격 체감용)
  String get nextBusSummary {
    if (predictTimeSec2 <= 0 && locationNo2 <= 0) {
      return '다음 차 정보 없음';
    }
    final minutes = (predictTimeSec2 / 60).ceil();
    return '다음 차: $minutes분 후 ($locationNo2번째 전)';
  }

  /// 연속 배차 여부 (앞뒤 버스가 1~2개 정류장 차이로 붙어서 오는지 감지)
  bool get isClusteredBus {
    if (locationNo1 > 0 && locationNo2 > 0) {
      return (locationNo2 - locationNo1) <= 2;
    }
    return false;
  }
}
