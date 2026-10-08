/// 지하철 실시간 도착 정보 및 연착/지연 사유 모델
class SubwayArrivalInfo {
  final String stationName; // 역 이름 (예: 강남, 판교, 사당)
  final String lineName; // 호선 이름 (예: 2호선, 신분당선, 4호선)
  final String direction; // 행선지 (예: 잠실방면, 양재방면)
  final int arrivalTimeSec; // 도착 예정 시간 (초)
  final String arrivalMessage; // 도착 메시지 (예: [3]번째 전역, 전역 도착, 진입)
  final String currentStation; // 열차 현재 위치 역
  final bool isExpress; // 급행 여부
  final int delayMinutes; // 지연 시간(분) (0이면 정시 운행)
  final String? delayReason; // 지연 사유 (예: 시위, 신호 고장, 시설물 점검 등)
  final DateTime updatedAt;

  const SubwayArrivalInfo({
    required this.stationName,
    required this.lineName,
    required this.direction,
    required this.arrivalTimeSec,
    required this.arrivalMessage,
    required this.currentStation,
    this.isExpress = false,
    this.delayMinutes = 0,
    this.delayReason,
    required this.updatedAt,
  });

  /// 도착 시간 표기 텍스트
  String get arrivalTimeText {
    if (arrivalTimeSec <= 0) {
      if (arrivalMessage.contains('진입') || arrivalMessage.contains('도착')) {
        return '곧 도착';
      }
      return arrivalMessage;
    }
    final minutes = (arrivalTimeSec / 60).ceil();
    return '$minutes분 후';
  }

  /// 지연 여부
  bool get isDelayed => delayMinutes > 0 || (delayReason != null && delayReason!.isNotEmpty);
}

/// 지하철 긴급 공지 / 운행 장애 사유 알림 모델
class SubwayAlertNotice {
  final String id;
  final String title; // 예: "[4호선] 전국장애인차별철폐연대 시위 관련 안내"
  final String content; // 상세 내용
  final String lineName; // 영향받는 호선
  final DateTime publishedAt;
  final bool isEmergency; // 심각한 지연/무정차 통과 여부

  const SubwayAlertNotice({
    required this.id,
    required this.title,
    required this.content,
    required this.lineName,
    required this.publishedAt,
    this.isEmergency = false,
  });
}
