import 'package:flutter/material.dart';

/// 앱 전반에서 사용되는 다크 & 네온 라임 프리미엄 컬러 팔레트
class AppColors {
  AppColors._();

  // Primary: 시그니처 네온 라임 & 차콜 블랙 테마
  static const Color neonLime = Color(0xFFD4F843); // #D4F843 (메인 포인트 액센트)
  static const Color neonLimeLight = Color(0xFFE5FF66);
  static const Color neonLimeDark = Color(0xFFA6C922);

  // 배경 & 다크 서피스
  static const Color background = Color(0xFF121212); // 메인 배경 (Pitch Black)
  static const Color surface = Color(0xFF1C1C1E); // 카드/모달 배경 (Dark Charcoal)
  static const Color surfaceElevated = Color(0xFF2C2C2E); // 칩/버튼 서브 배경
  static const Color cardBorder = Color(0xFF38383A); // 카드 테두리

  // 텍스트 컬러
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9EA4);
  static const Color textMuted = Color(0xFF636366);

  // 버스 노선 유형별 테마 컬러 (다크모드용 가독성 최적화)
  static const Color busBlue = Color(0xFF3B82F6); // 간선버스 (파랑)
  static const Color busGreen = Color(0xFF22C55E); // 지선버스 (초록)
  static const Color busRed = Color(0xFFEF4444); // 광역버스 (빨강)
  static const Color busYellow = Color(0xFFFBBF24); // 순환/마을버스 (노랑)

  // 지하철 호선별 대표 컬러
  static const Color subwayLine1 = Color(0xFF1E60B8);
  static const Color subwayLine2 = Color(0xFF22C55E);
  static const Color subwayLine3 = Color(0xFFF97316);
  static const Color subwayLine4 = Color(0xFF0EA5E9);
  static const Color subwayLine5 = Color(0xFFA855F7);
  static const Color subwayLine9 = Color(0xFFCA8A04);
  static const Color subwayShinbundang = Color(0xFFE11D48);
  static const Color subwaySuinBundang = Color(0xFFF59E0B);

  // 알람 & 상태 인디케이터
  static const Color alarmActive = Color(0xFFD4F843); // 알람 활성 (Neon Lime)
  static const Color alarmInactive = Color(0xFF636366); // 알람 비활성 (Gray)
  static const Color urgentWarning = Color(0xFFEF4444); // 지연/시위/긴급 (Red)
  static const Color imminentArrival = Color(0xFFF97316); // 곧 도착/임박 (Orange)
}
