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

### 🗓️ 2026-10-10 - 3번 탭 지도 UX 전면 개편 & 실시간 GPS 수신 및 자동 하차 알람 고도화

#### 💬 주요 논의 및 기획 의사결정
1. **장소/도로명 자유 검색 및 지도 중심 알람 설정 UX 개편**
   - 기존의 "정류장/역"에 한정된 알람 설정 한계를 극복하고, 지하철, 택시, 카풀, 도보 등 범용 목적지에서도 자유롭게 활용할 수 있도록 개선.
   - 좁은 고정 맵 뷰에서 벗어나 **풀스크린 네이버 지도 + 상단 플로팅 검색창(장소, 지명, 역, 도로명, 빌딩 검색)** 구조로 전면 전환.
   - OSM Nominatim 및 주요 거점 캐시를 연동하여 빠른 자동완성 검색 및 카메라 부드러운 이동 지원.
   - 지도 자유 터치 시 원하는 지점에 즉시 핀을 꽂고 역 지오코딩으로 주소/장소명을 자동 완성.
   - 드래그 가능한 하단 설정 시트를 통해 알람 별칭, 반경 슬라이더(300m~2,000m), 소리/진동 옵션을 손쉽게 설정.
2. **실시간 GPS 수신 및 지오펜싱 거리 계산 파이프라인 구축**
   - `LocationService`를 신규 구축하여 iOS/Android 위치 권한 체크 및 실시간 위치 스트림(`getPositionStream`) 연동.
   - 사용자의 현재 GPS 좌표와 등록된 활성 목적지 간 직선 거리(`Geolocator.distanceBetween`)를 실시간 연산.
   - 3번 탭 상단에 실시간 GPS 연결 상태 바(인디케이터) 및 수동 갱신 버튼 제공.
   - 동작 중인 하차 알람 카드에 목적지까지의 **실시간 남은 거리 뱃지(`▲ 1.4km 남음` / `🚨 곧 하차!`)** 동적 렌더링.
   - 목적지 반경 이내 진입 시 로컬 푸시 알림 + 긴급 진동 알람 자동 트리거 로직 구현.

#### 🛠️ 작업 내용
- [x] [`location_service.dart`](file:///Users/tlskals/ProjectW/lib/core/services/location_service.dart): 실시간 GPS 수신, 거리 계산, 장소/도로명 검색 및 역 지오코딩 서비스 신규 구현
- [x] [`transit_alarm_item.dart`](file:///Users/tlskals/ProjectW/lib/data/models/transit_alarm_item.dart): 범용 목적지 대응을 위한 `targetAddress` 필드 추가 및 직렬화 하위 호환성 유지
- [x] [`alarm_provider.dart`](file:///Users/tlskals/ProjectW/lib/presentation/providers/alarm_provider.dart): `userLocationProvider`, `alarmDistancesProvider`, 실시간 지오펜싱 진입 감지 로직 적용
- [x] [`set_alarm_map_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/alarm/set_alarm_map_screen.dart): 풀스크린 네이버 지도, 플로팅 장소 검색창, 터치 핀 지정, GPS 바로가기, 드래그 설정 시트 구현
- [x] 하단 바텀 시트 UX 정밀 튜닝: Safe Area 여백 반영으로 완료 버튼 텍스트 잘림 해결, `maxChildSize: 0.52`로 상한선을 제한하여 지도를 가리지 않고 내용이 한눈에 들어오도록 최적화
- [x] [`transit_alarm_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/alarm/transit_alarm_screen.dart): 실시간 GPS 연결 상태 바, 실시간 남은 거리 동적 뱃지, 레이더 지도 뷰 연동
- [x] 정적 분석(`flutter analyze` No issues) 및 테스트 100% 통과 검증 완료

---

### 🗓️ 2026-10-09 - 네이버 지도 SDK 연동 및 스마트 하차 알람(3번 탭) 지도 레이더 뷰 구축

#### 💬 주요 논의 및 기획 의사결정
1. **네이버 클라우드 플랫폼(Ncloud) Maps SDK 연동**
   - 발급받은 네이버 지도 Client ID(`ithd2c5slo`)를 iOS `Info.plist`(`NMFClientId`), Android `AndroidManifest.xml` 및 [`api_constants.dart`](file:///Users/tlskals/ProjectW/lib/core/constants/api_constants.dart)에 등록.
   - 앱 구동 시점([`main.dart`](file:///Users/tlskals/ProjectW/lib/main.dart))에서 `FlutterNaverMap.init` 초기화 파이프라인 구축.
2. **스마트 하차 알람 카드 내 실시간 네이버 지도 레이더 뷰 적용**
   - 활성화된 하차 알람 카드에 목적지 마커 + 네온 라임 반경 서클(`NCircleOverlay`) 오버레이 및 `((•)) 반경 1km` 뱃지 렌더링.
3. **하차 알람 위치 설정 화면 인터랙티브 맵 연동**
   - 지도 터치 시 원하는 위치로 핀 이동(`onMapTapped`), 실시간 반경 슬라이더(300m~2,000m) 조작에 따른 네온 라임 서클 오버레이 실시간 갱신.

#### 🛠️ 작업 내용
- [x] [`api_constants.dart`](file:///Users/tlskals/ProjectW/lib/core/constants/api_constants.dart): 네이버 지도 Client ID 및 Secret 등록
- [x] `ios/Runner/Info.plist` & `android/app/src/main/AndroidManifest.xml`: Native Naver Map SDK Client ID 설정
- [x] [`main.dart`](file:///Users/tlskals/ProjectW/lib/main.dart): `FlutterNaverMap.init` 초기화 적용
- [x] [`transit_alarm_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/alarm/transit_alarm_screen.dart): 네이버 지도 임베딩 및 반경 오버레이 뷰 구현
- [x] [`set_alarm_map_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/alarm/set_alarm_map_screen.dart): 인터랙티브 네이버 지도 터치/슬라이더 위치 설정 구현
- [x] 정적 분석(`flutter analyze` 0 issues) 검증 완료

---

### 🗓️ 2026-10-09 - 서울시 지하철 실시간 열차 도착 REST API 연동 완료 (2번 탭)

#### 💬 주요 논의 및 기획 의사결정
1. **서울 열린데이터광장 공식 지하철 API 연동**
   - 발급받은 서울시 오픈데이터 인증키(`4c487748...`)를 기반으로 수도권 전 노선(1~9호선, 신분당선, 수인분당선, 경의중앙선, 공항철도, 경강선, GTX-A 등)의 실시간 열차 위치 및 도착 정보(`realtimeStationArrival`) 연동.
2. **호선별 공식 색상 배지 & 급행 열차 구분**
   - 각 호선별 고유 색상 및 급행 뱃지, 종착역 방면명(`[상행] 광운대행 - 시청방면`), 도착 예정 시간(`전역 출발`, `2분 후`)을 실시간 렌더링.
3. **역 검색 및 주요 환승역 퀵 선택**
   - 상단 검색창에서 원하는 역을 검색하거나 빠른 칩(서울역, 강남, 사당, 판교, 신도림, 홍대입구, 여의도, 고속터미널 등)을 눌러 실시간 정보 즉시 조회.

#### 🛠️ 작업 내용
- [x] [`api_constants.dart`](file:///Users/tlskals/ProjectW/lib/core/constants/api_constants.dart): 서울 열린데이터광장 지하철 API 키 등록
- [x] [`subway_api_service.dart`](file:///Users/tlskals/ProjectW/lib/data/datasources/subway_api_service.dart): 서울시 실시간 지하철 도착 API 클라이언트 및 호선 매핑 구축
- [x] [`subway_repository.dart`](file:///Users/tlskals/ProjectW/lib/data/repositories/subway_repository.dart): `SubwayApiService` 실시간 연동 및 Fallback 처리
- [x] [`subway_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/subway/subway_screen.dart): 역 검색창, 주요 역 칩, 공식 실시간 피드 뱃지, 당김 새로고침 UI 적용
- [x] 정적 분석(`flutter analyze` 0 issues) 및 시뮬레이터 Hot Restart 반영 완료

---

### 🗓️ 2026-10-09 - 버스 등록 UX 전면 개편 (동명 버스 검증 & 노선도 타임라인 정류장 선택)

#### 💬 주요 논의 및 기획 의사결정
1. **수동 텍스트 입력 제거 & 자동화**
   - 버스 유형(간선/지선/마을 등) 수동 선택 칩 및 A/B 방면 텍스트 수동 입력창 제거.
2. **동명 버스 검증 & 실시간 노선 검색 지원**
   - 버스 번호(예: `1`, `143`, `9401`, `마포09`) 입력 시 지역(서울, 경기, 부천, 수원 등) 및 기종점(`도봉산 ⇋ 종로2가`, `부천대 ⇋ 신도림`)을 함께 노출하여 동일 번호의 다른 버스를 명확히 구분.
3. **버스 노선도(정류장 리스트) 시각화 & 원터치 정류장 선택**
   - 버스 선택 시 해당 노선의 경유 정류장을 세로 타임라인 노선도로 표시.
   - 정류장 내부 검색 또는 스크롤을 통해 내가 타는 정류장을 탭(Click)하면 기종점 기반 양방향(A/B) 도착 정보가 자동 연동되어 대시보드에 즉시 등록.

#### 🛠️ 작업 내용
- [x] [`bus_route_detail.dart`](file:///Users/tlskals/ProjectW/lib/data/models/bus_route_detail.dart): `BusRouteDetail` 및 `BusStopItem` 노선도 데이터 모델 신설
- [x] [`bus_repository.dart`](file:///Users/tlskals/ProjectW/lib/data/repositories/bus_repository.dart): 서울/경기 주요 노선(`143`, `1(서울)`, `1(부천)`, `1(수원)`, `7016`, `9401`, `420`, `M5107`, `마포09`, `5601`) 노선도 데이터셋 구축 및 실시간 검색 API(`searchBusRoutes`) 구현
- [x] [`add_bus_route_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/bus/add_bus_route_screen.dart):
  - [1단계] 실시간 버스 번호 검색 및 지역/기종점 카드 리스트
  - [2단계] 노선도 타임라인 뷰 및 정류장 간이 검색 & 원터치 선택 바 구현
- [x] `flutter analyze` (0 issues) 및 `flutter test` 검증 완료 및 시뮬레이터 Hot Restart 반영

---

### 🗓️ 2026-10-09 - 버스 대시보드(1번 탭) 양방향 50:50 분할 & 접이식(Expandable) UI 전면 개편

#### 💬 주요 논의 및 기획 의사결정
1. **출퇴근 탭 분리 제거 & 상단 헤더 슬림화**
   - 출근길/퇴근길을 굳이 나눌 필요 없이, 등록된 버스의 **상행(A방면)과 하행(B방면)** 양방향 정보를 한 카드 안에서 한눈에 파악할 수 있도록 탭 구조를 간소화.
2. **양방향(A방면 | B방면) 50:50 분할 카드 & 컴팩트 레이아웃**
   - 카드 내부를 좌/우 절반으로 나누어 양쪽 방면의 가장 빠른 버스 정보를 직관적으로 비교/확인할 수 있도록 개선.
3. **접이식(Expandable Accordion) 인터랙션 도입**
   - 기본 상태: 한 화면에 많은 버스가 들어오도록 컴팩트한 높이로 **가장 빠른 1차 버스**만 노출.
   - 클릭 시: 부드럽게 펼쳐지며 **2차, 3차 뒤차 도착 예정 시간 및 잔여석/차량 정보** 노출.
4. **연속 배차 감지 배너 및 경고 문구 전면 제거**
   - 시각적 노이즈를 줄이고 가독성을 극대화하기 위해 연속 배차 알림 제거.
5. **일반 시내버스(간선/지선) 데이터 다양화 & 잔여석 구분**
   - `143`(간선 파랑), `7016`(지선 초록), `9401`(광역 빨강), `420`(간선 파랑) 등 다양한 버스 노선 샘플 구성.
   - 일반버스는 잔여석 배지를 표시하지 않고, 광역버스에만 좌석 정보를 노출하도록 차별화.

#### 🛠️ 작업 내용
- [x] [`bus_arrival_info.dart`](file:///Users/tlskals/ProjectW/lib/data/models/bus_arrival_info.dart): 양방향(`directionA`, `directionB`) 및 단일 도착 정보(`SingleBusArrival`, `DirectionArrival`) 데이터 모델 정의
- [x] [`favorite_route.dart`](file:///Users/tlskals/ProjectW/lib/data/models/favorite_route.dart): 양방향 방면(`directionA`, `directionB`) 필드 추가
- [x] [`bus_repository.dart`](file:///Users/tlskals/ProjectW/lib/data/repositories/bus_repository.dart): 간선(143), 지선(7016), 광역(9401), 간선(420) 등 다채로운 양방향 실시간 도착 데이터 연동
- [x] [`bus_arrival_card.dart`](file:///Users/tlskals/ProjectW/lib/presentation/widgets/bus_arrival_card.dart): 좌우 50:50 분할 및 탭 확장(Accordion) 애니메이션 위젯 구현
- [x] [`bus_dashboard_screen.dart`](file:///Users/tlskals/ProjectW/lib/presentation/screens/bus/bus_dashboard_screen.dart): 상단 출퇴근 탭 및 연속배차 배너 제거, 슬림 실시간 헤더 적용
- [x] iOS 시뮬레이터(iPhone 16 Plus) 구동 및 UI 렌더링 검증 완료

---

### 🗓️ 2026-10-08 ~ 10-09 - 프로젝트 킥오프, 기획 수립, 핵심 4개 탭 및 다크/네온 테마 구현

#### 💬 주요 논의 및 기획 의사결정
1. **기획 의도 및 3대 핵심 킬러 기능 정의**
   * **기능 1 (🚍 출퇴근 0클릭 버스 대시보드)**: 집/회사에서 출발 전, 현재 위치와 무관하게 내가 탈 버스와 승차 정류장을 미리 등록하여 앱을 켜자마자 잔여 시간/정류장/좌석 정보를 즉시 확인.
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
- [x] 메인 네비게이션 4개 탭 화면 구축
- [x] `flutter analyze` (0 issues) 및 `flutter test` (위젯 스모크 테스트 통과) 정적 분석/테스트 검증 완료
