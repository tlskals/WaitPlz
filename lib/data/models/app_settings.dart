import 'dart:convert';

/// 진동 알람 세기 단계
enum VibrationIntensity {
  weak(
    '약함',
    '부드러운 햅틱 (도서관·조용한 장소용)',
    [200, 300, 200, 300],
    [80, 120, 80, 120],
  ),
  normal(
    '보통',
    '일반 알람 진동 (표준 진동 패턴)',
    [500, 500, 500, 500],
    [180, 180, 180, 180],
  ),
  strong(
    '강력 진동 (추천)',
    '잠든 사람 깨우기 모드 (연속 롱 진동)',
    [500, 1000, 500, 1000, 500, 2000],
    [128, 255, 128, 255, 128, 255],
  );

  final String label;
  final String description;
  final List<int> pattern;
  final List<int> intensities;

  const VibrationIntensity(
    this.label,
    this.description,
    this.pattern,
    this.intensities,
  );
}

/// 앱 전역 환경설정 모델
class AppSettings {
  final VibrationIntensity vibrationIntensity;
  final double defaultRadiusMeters;
  final bool defaultSoundEnabled;
  final bool defaultVibrationEnabled;
  final int refreshIntervalSeconds; // 10, 15, 30, 0(수동)

  const AppSettings({
    this.vibrationIntensity = VibrationIntensity.strong,
    this.defaultRadiusMeters = 800.0,
    this.defaultSoundEnabled = true,
    this.defaultVibrationEnabled = true,
    this.refreshIntervalSeconds = 15,
  });

  Map<String, dynamic> toMap() {
    return {
      'vibrationIntensity': vibrationIntensity.name,
      'defaultRadiusMeters': defaultRadiusMeters,
      'defaultSoundEnabled': defaultSoundEnabled,
      'defaultVibrationEnabled': defaultVibrationEnabled,
      'refreshIntervalSeconds': refreshIntervalSeconds,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      vibrationIntensity: VibrationIntensity.values.firstWhere(
        (e) => e.name == map['vibrationIntensity'],
        orElse: () => VibrationIntensity.strong,
      ),
      defaultRadiusMeters:
          (map['defaultRadiusMeters'] as num?)?.toDouble() ?? 800.0,
      defaultSoundEnabled: map['defaultSoundEnabled'] as bool? ?? true,
      defaultVibrationEnabled: map['defaultVibrationEnabled'] as bool? ?? true,
      refreshIntervalSeconds: map['refreshIntervalSeconds'] as int? ?? 15,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory AppSettings.fromJson(String source) =>
      AppSettings.fromMap(jsonDecode(source) as Map<String, dynamic>);

  AppSettings copyWith({
    VibrationIntensity? vibrationIntensity,
    double? defaultRadiusMeters,
    bool? defaultSoundEnabled,
    bool? defaultVibrationEnabled,
    int? refreshIntervalSeconds,
  }) {
    return AppSettings(
      vibrationIntensity: vibrationIntensity ?? this.vibrationIntensity,
      defaultRadiusMeters: defaultRadiusMeters ?? this.defaultRadiusMeters,
      defaultSoundEnabled: defaultSoundEnabled ?? this.defaultSoundEnabled,
      defaultVibrationEnabled:
          defaultVibrationEnabled ?? this.defaultVibrationEnabled,
      refreshIntervalSeconds:
          refreshIntervalSeconds ?? this.refreshIntervalSeconds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.vibrationIntensity == vibrationIntensity &&
        other.defaultRadiusMeters == defaultRadiusMeters &&
        other.defaultSoundEnabled == defaultSoundEnabled &&
        other.defaultVibrationEnabled == defaultVibrationEnabled &&
        other.refreshIntervalSeconds == refreshIntervalSeconds;
  }

  @override
  int get hashCode => Object.hash(
        vibrationIntensity,
        defaultRadiusMeters,
        defaultSoundEnabled,
        defaultVibrationEnabled,
        refreshIntervalSeconds,
      );
}
