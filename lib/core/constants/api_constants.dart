/// 공공데이터 및 외부 서비스 API 설정 상수
class ApiConstants {
  /// 공공데이터포털(data.go.kr) 일반 인증키 (Decoding)
  static const String dataGoKrServiceKey =
      '5321dba2bcd2e33d3add1d2a40718702dd0235e8d35728bbaa5a2406de588b67';

  /// 국토교통부(TAGO) 버스노선정보조회 서비스 Base URL
  static const String tagoRouteBaseUrl =
      'http://apis.data.go.kr/1613000/BusRouteInfoInqireService';

  /// 국토교통부(TAGO) 버스도착정보조회 서비스 Base URL
  static const String tagoArrivalBaseUrl =
      'http://apis.data.go.kr/1613000/ArvlInfoInqireService';

  /// 경기도 버스도착정보조회 서비스 Base URL
  static const String gyeonggiArrivalBaseUrl =
      'http://apis.data.go.kr/6410000/busarrivalservice';

  /// 서울 열린데이터광장 Base URL (지하철 실시간 도착 등)
  static const String seoulOpenDataBaseUrl =
      'http://swopenapi.seoul.go.kr/api/subway';

  /// 서울 열린데이터광장 인증키
  static const String seoulApiKey = '4c48774845746c7339314a4c6c567a';

  /// 네이버 지도 Client ID & Secret
  static const String naverMapClientId = 'ithd2c5slo';
  static const String naverMapClientSecret =
      'aq9sL2HUiZ5SVIzL9KCSEd6zcXIMkOj15li9MXiF';
}
