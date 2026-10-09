import 'dart:convert';

/// 즐겨찾기 등록된 버스 노선 모델 (양방향 방면 정보 포함)
class FavoriteRoute {
  final String id;
  final String routeId;
  final String routeName; // 예: 143, 7016, 9401, 420
  final String routeType; // 간선, 지선, 광역, 마을 등
  final String stationId;
  final String stationName; // 기준 정류장 (예: 강남역, 서현역.AK플라자)
  final String directionA; // A 방면 (예: 정릉 방면, 서울역 방면)
  final String directionB; // B 방면 (예: 개포동 방면, 분당 방면)
  final int orderIndex;

  const FavoriteRoute({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.routeType,
    required this.stationId,
    required this.stationName,
    this.directionA = '',
    this.directionB = '',
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeId': routeId,
      'routeName': routeName,
      'routeType': routeType,
      'stationId': stationId,
      'stationName': stationName,
      'directionA': directionA,
      'directionB': directionB,
      'orderIndex': orderIndex,
    };
  }

  factory FavoriteRoute.fromMap(Map<String, dynamic> map) {
    return FavoriteRoute(
      id: map['id'] ?? '',
      routeId: map['routeId'] ?? '',
      routeName: map['routeName'] ?? '',
      routeType: map['routeType'] ?? '간선',
      stationId: map['stationId'] ?? '',
      stationName: map['stationName'] ?? '',
      directionA: map['directionA'] ?? map['direction'] ?? '상행 방면',
      directionB: map['directionB'] ?? '하행 방면',
      orderIndex: map['orderIndex'] ?? 0,
    );
  }

  String toJson() => json.encode(toMap());
  factory FavoriteRoute.fromJson(String source) =>
      FavoriteRoute.fromMap(json.decode(source));
}
