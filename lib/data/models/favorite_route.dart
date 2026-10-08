import 'dart:convert';

/// 즐겨찾기 버스 + 정류장 프리셋 모델
enum CommuteTag {
  commuteToWork, // 출근길
  commuteHome, // 퇴근길
  general, // 일반
}

class FavoriteRoute {
  final String id;
  final String routeId;
  final String routeName; // 예: 9401, 7727
  final String routeType; // 간선, 지선, 광역 등
  final String stationId;
  final String stationName; // 예: 한남동, 광화문
  final String direction; // 방면 (예: 서울역 방면, 분당 방면)
  final String stationSeq;
  final CommuteTag tag;
  final int orderIndex;
  final bool isDefault;

  const FavoriteRoute({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.routeType,
    required this.stationId,
    required this.stationName,
    this.direction = '',
    this.stationSeq = '1',
    this.tag = CommuteTag.commuteToWork,
    this.orderIndex = 0,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'routeId': routeId,
      'routeName': routeName,
      'routeType': routeType,
      'stationId': stationId,
      'stationName': stationName,
      'direction': direction,
      'stationSeq': stationSeq,
      'tag': tag.name,
      'orderIndex': orderIndex,
      'isDefault': isDefault,
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
      direction: map['direction'] ?? '',
      stationSeq: map['stationSeq'] ?? '1',
      tag: CommuteTag.values.firstWhere(
        (e) => e.name == map['tag'],
        orElse: () => CommuteTag.commuteToWork,
      ),
      orderIndex: map['orderIndex'] ?? 0,
      isDefault: map['isDefault'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());
  factory FavoriteRoute.fromJson(String source) =>
      FavoriteRoute.fromMap(json.decode(source));
}
