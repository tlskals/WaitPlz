import '../models/subway_arrival_info.dart';

class SubwayRepository {
  /// 선택된 주요 지하철역의 실시간 도착 및 연착/지연 정보 조회
  Future<List<SubwayArrivalInfo>> fetchSubwayArrivals(String stationName) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final now = DateTime.now();

    if (stationName.contains('강남')) {
      return [
        SubwayArrivalInfo(
          stationName: '강남',
          lineName: '2호선',
          direction: '역삼·잠실 방면 (내선순환)',
          arrivalTimeSec: 150, // 2분 30초
          arrivalMessage: '[2]번째 전역 (서초)',
          currentStation: '서초',
          updatedAt: now,
        ),
        SubwayArrivalInfo(
          stationName: '강남',
          lineName: '2호선',
          direction: '교대·사당 방면 (외선순환)',
          arrivalTimeSec: 280,
          arrivalMessage: '[3]번째 전역 (선릉)',
          currentStation: '선릉',
          updatedAt: now,
        ),
        SubwayArrivalInfo(
          stationName: '강남',
          lineName: '신분당선',
          direction: '양재시민의숲·판교·광교 방면',
          arrivalTimeSec: 360,
          arrivalMessage: '[2]번째 전역 (신논현)',
          currentStation: '신논현',
          updatedAt: now,
        ),
      ];
    } else if (stationName.contains('사당')) {
      return [
        SubwayArrivalInfo(
          stationName: '사당',
          lineName: '4호선',
          direction: '서울역·당고개 방면',
          arrivalTimeSec: 540,
          arrivalMessage: '[4]번째 전역 (남태령)',
          currentStation: '남태령',
          delayMinutes: 8,
          delayReason: '앞차 간격 조정 및 출근길 혼잡 지연',
          updatedAt: now,
        ),
        SubwayArrivalInfo(
          stationName: '사당',
          lineName: '2호선',
          direction: '방배·강남 방면 (내선)',
          arrivalTimeSec: 180,
          arrivalMessage: '[1]번째 전역 (낙성대)',
          currentStation: '낙성대',
          updatedAt: now,
        ),
      ];
    } else {
      return [
        SubwayArrivalInfo(
          stationName: stationName,
          lineName: '신분당선',
          direction: '강남 방면',
          arrivalTimeSec: 240,
          arrivalMessage: '[2]번째 전역 (정자)',
          currentStation: '정자',
          updatedAt: now,
        ),
        SubwayArrivalInfo(
          stationName: stationName,
          lineName: '경강선',
          direction: '여주 방면',
          arrivalTimeSec: 720,
          arrivalMessage: '[5]번째 전역 (이매)',
          currentStation: '이매',
          updatedAt: now,
        ),
      ];
    }
  }

  /// 실시간 지하철 긴급 공지 & 시위/운행 지연 피드
  Future<List<SubwayAlertNotice>> fetchSubwayAlerts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      SubwayAlertNotice(
        id: 'notice_1',
        title: '🚨 [4호선] 삼각지역~혜화역 구간 시위 관련 열차 운행 안내',
        content: '현재 4호선 일부 구간에서 집회 시위로 인해 상/하행선 열차가 5~15분 가량 지연 운행 중입니다. 열차 이용에 참고하시기 바랍니다.',
        lineName: '4호선',
        publishedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        isEmergency: true,
      ),
      SubwayAlertNotice(
        id: 'notice_2',
        title: '📢 [1호선] 구로역 신호 점검 완료 (정상 운행 재개)',
        content: '구로역 인근 신호 설비 점검이 완료되어 전 구간 정상 운행 중입니다.',
        lineName: '1호선',
        publishedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
        isEmergency: false,
      ),
    ];
  }
}
