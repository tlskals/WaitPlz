import 'dart:convert';

/// 스마트 하차 알람 아이템 모델 ("기사님, 잠시만요!" 핵심 기능)
class TransitAlarmItem {
  final String id;
  final String title; // 예: "퇴근길 판교역 하차", "우리집 앞 정류장"
  final String targetStationName; // 목적지 정류장/역 이름
  final double targetLatitude; // 목적지 위도
  final double targetLongitude; // 목적지 경도
  final double radiusMeters; // 알람 발동 반경 (기본 500m ~ 1500m)
  final bool isEnabled; // 알람 활성화 토글 (ON/OFF)
  final bool soundEnabled; // 소리 알람 여부
  final bool vibrationEnabled; // 진동 알람 여부
  final String? busRouteName; // 탑승 중인 버스 번호 (선택)
  final DateTime createdAt;

  const TransitAlarmItem({
    required this.id,
    required this.title,
    required this.targetStationName,
    required this.targetLatitude,
    required this.targetLongitude,
    this.radiusMeters = 700.0,
    this.isEnabled = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.busRouteName,
    required this.createdAt,
  });

  TransitAlarmItem copyWith({
    String? id,
    String? title,
    String? targetStationName,
    double? targetLatitude,
    double? targetLongitude,
    double? radiusMeters,
    bool? isEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    String? busRouteName,
    DateTime? createdAt,
  }) {
    return TransitAlarmItem(
      id: id ?? this.id,
      title: title ?? this.title,
      targetStationName: targetStationName ?? this.targetStationName,
      targetLatitude: targetLatitude ?? this.targetLatitude,
      targetLongitude: targetLongitude ?? this.targetLongitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      isEnabled: isEnabled ?? this.isEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      busRouteName: busRouteName ?? this.busRouteName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetStationName': targetStationName,
      'targetLatitude': targetLatitude,
      'targetLongitude': targetLongitude,
      'radiusMeters': radiusMeters,
      'isEnabled': isEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'busRouteName': busRouteName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransitAlarmItem.fromMap(Map<String, dynamic> map) {
    return TransitAlarmItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      targetStationName: map['targetStationName'] ?? '',
      targetLatitude: (map['targetLatitude'] as num?)?.toDouble() ?? 0.0,
      targetLongitude: (map['targetLongitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (map['radiusMeters'] as num?)?.toDouble() ?? 700.0,
      isEnabled: map['isEnabled'] ?? false,
      soundEnabled: map['soundEnabled'] ?? true,
      vibrationEnabled: map['vibrationEnabled'] ?? true,
      busRouteName: map['busRouteName'],
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());
  factory TransitAlarmItem.fromJson(String source) =>
      TransitAlarmItem.fromMap(json.decode(source));
}
