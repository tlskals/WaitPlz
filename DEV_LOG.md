# 📓 ProjectW 개발 일지 (Development Log)

이 문서는 프로젝트의 일자별 진행 상황, 주요 의사결정, 기획 및 구현 사항을 기록하는 개발 일지입니다.  
매일 작업 종료 시 ("오늘은 여기까지 작업할게 금일 작업내용 정리해줘") 해당 일자의 작업 내용이 누적 기록됩니다.

---

## 📌 프로젝트 기본 정보
- **앱 이름**: 기사님, 잠시만요! (`project_w`)
- **타겟 사용자**: 매일 장거리(편도 1~2시간) 버스/지하철로 출퇴근하며 불규칙한 배차와 환승, 졸음으로 인한 하차역 놓침을 겪는 직장인
- **타겟 플랫폼**: iOS / Android (Cross-Platform)
- **프레임워크 / 언어**: Flutter 3.38.5 / Dart 3.10.4
- **디자인 테마**: 다크 챠콜/블랙 (`#121212`, `#1C1C1E`) + 시그니처 네온 라임 (`#D4F843`)
- **아키텍처**: Clean Layered Architecture + Riverpod 3.x (Notifier Pattern)

---

## 📅 일자별 개발 일지

### 🗓️ 2026-10-08 ~ 10-09 - 프로젝트 킥오프, 기획 수립, 핵심 4개 탭 및 다크/네온 테마 구현

#### 💬 주요 논의 및 기획 의사결정
1. **기획 의도 및 3대 핵심 킬러 기능 정의**
   * **기능 1 (🚍 출퇴근 0클릭 버스 대시보드)**: 집/회사에서 출발 전, 현재 위치와 무관하게 내가 탈 버스와 승차 정류장을 미리 등록하여 앱을 켜자마자 잔여 시간/정류장/좌석 정보를 즉시 확인. 연속 배차(1~2정거장 차이로 겹쳐 오는 버스) 감지 알림.
   * **기능 2 (🚇 지하철 도착 & 지연/시위 공지)**: 실시간 열차 도착 정보와 함께 시위, 사고, 단전, 신호장애 등으로 인한 지연 소식 및 운행 사유 제공.
   * **기능 3 (⏰ 스마트 하차 알람 - "기사님, 잠시만요!")**: 광역버스나 지하철에서 잠들어도 목적지 반경(300m~2,000m) 진입 시 화면이 꺼져 있어도 강력한 진동과 소리로 깨워주는 루틴 토글 알람.
   * **기능 4 (⚙️ 설정 & 환경설정)**: 기본 하차 반경, 진동 세기, 공공데이터 출처 표기.

2. **상업적 이용 라이선스 & 광고(AdMob) 탑재 적합성 검토**
   * **네이버 지도 SDK (NCP Maps)**: 월 300만 건 무료 제공, 상업용/광고 탑재 앱 합법 사용 확인.
   * **공공데이터 (TAGO, TOPIS, 코레일)**: 공공누리 제1유형에 따라 광고 수익 모델 100% 무료 허용 확인.
   * **오픈소스 패키지**: MIT / BSD-3 / Apache 2.0 상용 무료 라이선스 검증 완료.

3. **피그마 디자인 시스템 적용**
   * 피그마 디자인 에셋(`asset/design/`) 분석을 기반으로 **다크모드 + 네온 라임(`#D4F843`)** 테마 시스템 구축.
   * 카드 내 지도 레이더 뷰 + `((•)) 반경 1km` 뱃지 + 원터치 토글스위치 인터페이스 구현.

4. **협업 및 작업 원칙 확립**
   * **사전 컨펌 원칙**: 모든 작업 전 변경 계획 안내 및 승인 후 실행.
   * **데일리 개발 일지 및 깃허브 백업 관리**.

---

#### 🛠️ 작업 내용
- [x] 기본 Flutter 프로젝트 초기화 및 Android/iOS 패키지 설정 (`com.projectw.project_w`)
- [x] Android 및 iOS 권한 설정 (GPS 위치, 백그라운드 위치, 포그라운드 서비스, 로컬 알림, 진동, Cleartext HTTP 허용)
- [x] 핵심 의존성 패키지 설치 (`flutter_riverpod 3.x`, `flutter_naver_map`, `flutter_local_notifications`, `vibration`, `geolocator`, `shared_preferences`, `dio`, `xml`)
- [x] 핵심 데이터 모델 구현 (`BusArrivalInfo`, `FavoriteRoute`, `TransitAlarmItem`, `SubwayArrivalInfo`, `SubwayAlertNotice`)
- [x] 로컬 저장소(`LocalStorageService`) 및 로컬 푸시 알람/진동 매니저(`NotificationService`) 구축 (직장인 샘플 데이터 자동 세팅)
- [x] Riverpod 3.x Notifier 기반 상태 관리 (`BusDashboardNotifier`, `SubwayProvider`, `AlarmNotifier`)
- [x] 메인 네비게이션 4개 탭 화면 구축:
  1. [`bus_dashboard_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/bus/bus_dashboard_screen.dart) (출근/퇴근 자동 전환, 연속 배차 감지 배너, 15초 자동 갱신)
  2. [`subway_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/subway/subway_screen.dart) (실시간 도착 + 시위/지연 긴급 공지 피드)
  3. [`transit_alarm_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/alarm/transit_alarm_screen.dart) (즐겨찾는/일반 도착지 토글, 레이더 맵 뷰, 반경 뱃지, 즉시 테스트)
  4. [`settings_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/settings/settings_screen.dart) (환경설정, 데이터 출처, 라이선스)
- [x] 버스/정류장 등록 화면([`add_bus_route_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/bus/add_bus_route_screen.dart)) & 하차 알람 추가 화면([`set_alarm_map_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/alarm/set_alarm_map_screen.dart)) 구현
- [x] `flutter analyze` (0 issues) 및 `flutter test` (위젯 스모크 테스트 통과) 정적 분석/테스트 검증 완료

---

#### 🔜 다음 작업 계획
- [ ] 시뮬레이터 구동 및 실제 기기 화면 인터랙션/디자인 디테일 튜닝
- [ ] 공공데이터포털(TAGO) 및 서울시 TOPIS 실제 REST API 키 연동 모듈 작성
- [ ] 네이버 지도 Native SDK 활성화 및 백그라운드 GPS 위치 추적 워커 고도화
