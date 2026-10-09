import '../datasources/bus_api_service.dart';
import '../models/bus_arrival_info.dart';
import '../models/bus_route_detail.dart';
import '../models/favorite_route.dart';

class BusRepository {
  final BusApiService _apiService;

  BusRepository({BusApiService? apiService})
      : _apiService = apiService ?? BusApiService();

  /// 대표 버스 노선 및 정류장 마스터 데이터베이스 (캐싱 및 빠른 검색용)
  static final List<BusRouteDetail> _masterRoutes = [
    // 5601번 (경기 안산 - 신안산대 ⇋ 여의도)
    const BusRouteDetail(
      routeId: '216000026',
      routeName: '5601',
      region: '경기',
      routeType: '직행좌석',
      startStation: '신안산대학교',
      endStation: '여의도환승센터',
      operatingHours: '05:00 ~ 23:00',
      interval: '15~25분',
      directionA: '여의도환승센터 방면',
      directionB: '신안산대 방면',
      stations: [
        BusStopItem(stationId: '216000101', stationName: '신안산대학교 (기점)', stationSeq: 1, arsId: '18-001', directionName: '여의도환승센터 방면'),
        BusStopItem(stationId: '216000115', stationName: '초지역', stationSeq: 7, arsId: '18-015', directionName: '여의도환승센터 방면'),
        BusStopItem(stationId: '216000130', stationName: '안산역', stationSeq: 12, arsId: '18-030', directionName: '여의도환승센터 방면'),
        BusStopItem(stationId: '216000145', stationName: '중앙역', stationSeq: 18, arsId: '18-045', directionName: '여의도환승센터 방면'),
        BusStopItem(stationId: '216000160', stationName: '상록수역', stationSeq: 24, arsId: '18-060', directionName: '여의도환승센터 방면'),
        BusStopItem(stationId: '118000001', stationName: '구로디지털단지역', stationSeq: 32, arsId: '19-001', directionName: '여의도환승센터 방면'),
        BusStopItem(stationId: '119000010', stationName: '여의도환승센터 (회차)', stationSeq: 38, arsId: '20-010', directionName: '여의도환승센터 방면', isTurningPoint: true),
      ],
    ),

    // 143번 (서울 간선)
    const BusRouteDetail(
      routeId: '100100022',
      routeName: '143',
      region: '서울',
      routeType: '간선',
      startStation: '정릉산장',
      endStation: '개포중학교',
      operatingHours: '04:00 ~ 22:40',
      interval: '4~7분',
      directionA: '정릉 방면',
      directionB: '개포동 방면',
      stations: [
        BusStopItem(stationId: '107000001', stationName: '정릉산장 (기점)', stationSeq: 1, arsId: '08-101', directionName: '개포동 방면'),
        BusStopItem(stationId: '107000012', stationName: '길음역', stationSeq: 6, arsId: '08-112', directionName: '개포동 방면'),
        BusStopItem(stationId: '107000025', stationName: '성신여대입구', stationSeq: 9, arsId: '08-125', directionName: '개포동 방면'),
        BusStopItem(stationId: '100000005', stationName: '혜화동로터리', stationSeq: 13, arsId: '01-005', directionName: '개포동 방면'),
        BusStopItem(stationId: '100000018', stationName: '종로2가', stationSeq: 18, arsId: '01-018', directionName: '개포동 방면'),
        BusStopItem(stationId: '101000030', stationName: '롯데백화점.본점', stationSeq: 22, arsId: '02-140', directionName: '개포동 방면'),
        BusStopItem(stationId: '102000045', stationName: '순천향대학병원.한남동', stationSeq: 27, arsId: '03-165', directionName: '개포동 방면'),
        BusStopItem(stationId: '122000001', stationName: '신사역.푸른저축은행', stationSeq: 32, arsId: '23-101', directionName: '개포동 방면'),
        BusStopItem(stationId: '122000010', stationName: '논현역', stationSeq: 35, arsId: '23-110', directionName: '개포동 방면'),
        BusStopItem(stationId: '122000018', stationName: '신논현역.구교보타워', stationSeq: 38, arsId: '23-118', directionName: '개포동 방면'),
        BusStopItem(stationId: '122000025', stationName: '강남역', stationSeq: 41, arsId: '23-125', directionName: '개포동 방면'),
        BusStopItem(stationId: '122000033', stationName: '양재역.서초문화예술회관', stationSeq: 45, arsId: '23-133', directionName: '개포동 방면'),
        BusStopItem(stationId: '122000042', stationName: '대치동미도아파트', stationSeq: 49, arsId: '23-142', directionName: '개포동 방면'),
        BusStopItem(stationId: '122000050', stationName: '개포중학교 (종점)', stationSeq: 54, arsId: '23-150', directionName: '개포동 방면', isTurningPoint: true),
      ],
    ),

    // 1번 (서울 간선 - 도봉산 ⇋ 종로2가)
    const BusRouteDetail(
      routeId: '100100001',
      routeName: '1',
      region: '서울',
      routeType: '간선',
      startStation: '도봉산역',
      endStation: '종로2가',
      operatingHours: '04:15 ~ 23:00',
      interval: '7~12분',
      directionA: '도봉산 방면',
      directionB: '종로2가 방면',
      stations: [
        BusStopItem(stationId: '109000001', stationName: '도봉산역 (기점)', stationSeq: 1, arsId: '10-001', directionName: '종로2가 방면'),
        BusStopItem(stationId: '109000015', stationName: '수유역', stationSeq: 8, arsId: '10-015', directionName: '종로2가 방면'),
        BusStopItem(stationId: '108000022', stationName: '미아사거리역', stationSeq: 14, arsId: '09-022', directionName: '종로2가 방면'),
        BusStopItem(stationId: '100000008', stationName: '혜화역.마로니에공원', stationSeq: 20, arsId: '01-008', directionName: '종로2가 방면'),
        BusStopItem(stationId: '100000018', stationName: '종로2가 (종점)', stationSeq: 25, arsId: '01-018', directionName: '종로2가 방면', isTurningPoint: true),
      ],
    ),

    // 1번 (부천 시내 - 부천대 ⇋ 신도림역)
    const BusRouteDetail(
      routeId: '210000001',
      routeName: '1',
      region: '부천',
      routeType: '일반',
      startStation: '부천대학교',
      endStation: '신도림역',
      operatingHours: '05:00 ~ 23:30',
      interval: '8~15분',
      directionA: '부천대 방면',
      directionB: '신도림 방면',
      stations: [
        BusStopItem(stationId: '210000101', stationName: '부천대학교 (기점)', stationSeq: 1, arsId: '12-001', directionName: '신도림 방면'),
        BusStopItem(stationId: '210000112', stationName: '부천역.국민은행', stationSeq: 4, arsId: '12-012', directionName: '신도림 방면'),
        BusStopItem(stationId: '210000125', stationName: '역곡역.남부', stationSeq: 9, arsId: '12-025', directionName: '신도림 방면'),
        BusStopItem(stationId: '116000005', stationName: '오류동역', stationSeq: 15, arsId: '17-005', directionName: '신도림 방면'),
        BusStopItem(stationId: '116000018', stationName: '구로역', stationSeq: 21, arsId: '17-018', directionName: '신도림 방면'),
        BusStopItem(stationId: '118000001', stationName: '신도림역 (종점)', stationSeq: 26, arsId: '19-001', directionName: '신도림 방면', isTurningPoint: true),
      ],
    ),

    // 7016번 (서울 지선)
    const BusRouteDetail(
      routeId: '100100345',
      routeName: '7016',
      region: '서울',
      routeType: '지선',
      startStation: '은평차고지',
      endStation: '상명대입구',
      operatingHours: '04:30 ~ 23:10',
      interval: '6~10분',
      directionA: '상명대 방면',
      directionB: '은평차고지 방면',
      stations: [
        BusStopItem(stationId: '111000001', stationName: '은평공영차고지 (기점)', stationSeq: 1, arsId: '12-001', directionName: '상명대 방면'),
        BusStopItem(stationId: '111000015', stationName: '디지털미디어시티역', stationSeq: 7, arsId: '12-015', directionName: '상명대 방면'),
        BusStopItem(stationId: '113000023', stationName: '홍대입구역', stationSeq: 15, arsId: '14-023', directionName: '상명대 방면'),
        BusStopItem(stationId: '112000010', stationName: '신촌오거리.현대백화점', stationSeq: 19, arsId: '13-010', directionName: '상명대 방면'),
        BusStopItem(stationId: '113000045', stationName: '공덕역', stationSeq: 25, arsId: '14-045', directionName: '상명대 방면'),
        BusStopItem(stationId: '102000012', stationName: '서울역버스환승센터', stationSeq: 32, arsId: '03-012', directionName: '상명대 방면'),
        BusStopItem(stationId: '100000040', stationName: '경복궁역', stationSeq: 38, arsId: '01-040', directionName: '상명대 방면'),
        BusStopItem(stationId: '100000055', stationName: '상명대입구 (종점)', stationSeq: 44, arsId: '01-055', directionName: '상명대 방면', isTurningPoint: true),
      ],
    ),

    // 9401번 (경기 광역)
    const BusRouteDetail(
      routeId: '100100073',
      routeName: '9401',
      region: '경기',
      routeType: '광역',
      startStation: '구미동차고지',
      endStation: '서울역환승센터',
      operatingHours: '04:50 ~ 23:30',
      interval: '4~8분',
      directionA: '서울역 방면',
      directionB: '분당 구미동 방면',
      stations: [
        BusStopItem(stationId: '206000010', stationName: '구미동차고지 (기점)', stationSeq: 1, arsId: '07-010', directionName: '서울역 방면'),
        BusStopItem(stationId: '206000025', stationName: '오리역', stationSeq: 4, arsId: '07-025', directionName: '서울역 방면'),
        BusStopItem(stationId: '206000040', stationName: '미금역.청솔마을', stationSeq: 8, arsId: '07-040', directionName: '서울역 방면'),
        BusStopItem(stationId: '206000055', stationName: '정자역', stationSeq: 12, arsId: '07-055', directionName: '서울역 방면'),
        BusStopItem(stationId: '206000070', stationName: '서현역.AK플라자', stationSeq: 17, arsId: '07-070', directionName: '서울역 방면'),
        BusStopItem(stationId: '206000085', stationName: '이매촌한신.서현역', stationSeq: 19, arsId: '07-085', directionName: '서울역 방면'),
        BusStopItem(stationId: '206000100', stationName: '판교IC (고속도로)', stationSeq: 22, arsId: '07-100', directionName: '서울역 방면'),
        BusStopItem(stationId: '102000045', stationName: '순천향대학병원.한남동', stationSeq: 26, arsId: '03-165', directionName: '서울역 방면'),
        BusStopItem(stationId: '101000015', stationName: '서울백병원.국가인권위', stationSeq: 29, arsId: '02-015', directionName: '서울역 방면'),
        BusStopItem(stationId: '100000018', stationName: '종로2가', stationSeq: 32, arsId: '01-018', directionName: '서울역 방면'),
        BusStopItem(stationId: '101000030', stationName: '을지로입구역.롯데백화점', stationSeq: 35, arsId: '02-140', directionName: '서울역 방면'),
        BusStopItem(stationId: '102000012', stationName: '서울역버스환승센터 (회차)', stationSeq: 38, arsId: '03-012', directionName: '서울역 방면', isTurningPoint: true),
      ],
    ),

    // 420번 (서울 간선)
    const BusRouteDetail(
      routeId: '100100067',
      routeName: '420',
      region: '서울',
      routeType: '간선',
      startStation: '개포동',
      endStation: '청량리역',
      operatingHours: '04:10 ~ 22:50',
      interval: '5~9분',
      directionA: '청량리 방면',
      directionB: '개포동 방면',
      stations: [
        BusStopItem(stationId: '122000050', stationName: '개포주공아파트 (기점)', stationSeq: 1, arsId: '23-150', directionName: '청량리 방면'),
        BusStopItem(stationId: '122000065', stationName: '도곡역', stationSeq: 5, arsId: '23-165', directionName: '청량리 방면'),
        BusStopItem(stationId: '122000080', stationName: '한티역', stationSeq: 9, arsId: '23-180', directionName: '청량리 방면'),
        BusStopItem(stationId: '122000015', stationName: '역삼역.포스코타워', stationSeq: 14, arsId: '23-015', directionName: '청량리 방면'),
        BusStopItem(stationId: '122000025', stationName: '강남역', stationSeq: 17, arsId: '23-125', directionName: '청량리 방면'),
        BusStopItem(stationId: '122000001', stationName: '신사역', stationSeq: 22, arsId: '23-101', directionName: '청량리 방면'),
        BusStopItem(stationId: '101000055', stationName: '동대문역사문화공원', stationSeq: 30, arsId: '02-055', directionName: '청량리 방면'),
        BusStopItem(stationId: '105000010', stationName: '청량리역환승센터 (종점)', stationSeq: 37, arsId: '06-010', directionName: '청량리 방면', isTurningPoint: true),
      ],
    ),

    // M5107번 (경기 광역)
    const BusRouteDetail(
      routeId: '100100582',
      routeName: 'M5107',
      region: '경기',
      routeType: '광역',
      startStation: '경희대국제캠퍼스',
      endStation: '서울역환승센터',
      operatingHours: '05:00 ~ 23:00',
      interval: '6~12분',
      directionA: '서울역 방면',
      directionB: '경희대 방면',
      stations: [
        BusStopItem(stationId: '228000701', stationName: '경희대국제캠퍼스 (기점)', stationSeq: 1, arsId: '04-001', directionName: '서울역 방면'),
        BusStopItem(stationId: '228000710', stationName: '영통역', stationSeq: 3, arsId: '04-010', directionName: '서울역 방면'),
        BusStopItem(stationId: '228000720', stationName: '청명역', stationSeq: 5, arsId: '04-020', directionName: '서울역 방면'),
        BusStopItem(stationId: '102000045', stationName: '순천향대학병원.한남동', stationSeq: 10, arsId: '03-165', directionName: '서울역 방면'),
        BusStopItem(stationId: '101000015', stationName: '서울백병원', stationSeq: 13, arsId: '02-015', directionName: '서울역 방면'),
        BusStopItem(stationId: '102000012', stationName: '서울역버스환승센터 (회차)', stationSeq: 17, arsId: '03-012', directionName: '서울역 방면', isTurningPoint: true),
      ],
    ),

    // 마포09 (서울 마을)
    const BusRouteDetail(
      routeId: '100100909',
      routeName: '마포09',
      region: '서울',
      routeType: '마을',
      startStation: '망원유수지',
      endStation: '신촌역',
      operatingHours: '05:40 ~ 23:45',
      interval: '7~10분',
      directionA: '신촌역 방면',
      directionB: '망원유수지 방면',
      stations: [
        BusStopItem(stationId: '113900001', stationName: '망원유수지 (기점)', stationSeq: 1, arsId: '14-501', directionName: '신촌역 방면'),
        BusStopItem(stationId: '113900010', stationName: '망원시장.망원역', stationSeq: 5, arsId: '14-510', directionName: '신촌역 방면'),
        BusStopItem(stationId: '113900020', stationName: '홍대입구역 2번출구', stationSeq: 10, arsId: '14-520', directionName: '신촌역 방면'),
        BusStopItem(stationId: '113900030', stationName: '신촌역 지하보도 (회차)', stationSeq: 15, arsId: '14-530', directionName: '신촌역 방면', isTurningPoint: true),
      ],
    ),
  ];

  /// 실시간 버스 번호 검색 (TAGO API 우선 조회 + 로컬 마스터 캐시 매칭)
  Future<List<BusRouteDetail>> searchBusRoutes(String query) async {
    final cleanQuery = query.trim().replaceAll('번', '').toLowerCase();
    if (cleanQuery.isEmpty) return _masterRoutes;

    // 1. 공공데이터 TAGO API 우선 조회 시도
    final tagoResults = await _apiService.searchTagoRouteNo(cleanQuery);
    if (tagoResults != null && tagoResults.isNotEmpty) {
      return tagoResults;
    }

    // 2. 로컬 마스터 데이터 매칭
    final results = _masterRoutes.where((route) {
      final matchName = route.routeName.toLowerCase().contains(cleanQuery);
      final matchRegion = route.region.toLowerCase().contains(cleanQuery);
      final matchSummary = route.routeSummary.toLowerCase().contains(cleanQuery);
      return matchName || matchRegion || matchSummary;
    }).toList();

    // 3. 일치하는 항목이 없을 때 기본 생성
    if (results.isEmpty) {
      results.add(
        BusRouteDetail(
          routeId: 'custom_${DateTime.now().millisecondsSinceEpoch}',
          routeName: cleanQuery.toUpperCase(),
          region: '일반',
          routeType: cleanQuery.startsWith('M') || cleanQuery.startsWith('9') || cleanQuery.startsWith('5') ? '광역' : '간선',
          startStation: '기점',
          endStation: '종점',
          directionA: '기점 방면',
          directionB: '종점 방면',
          stations: [
            const BusStopItem(stationId: 'st_1', stationName: '시청 앞', stationSeq: 1, arsId: '01-100', directionName: '종점 방면'),
            const BusStopItem(stationId: 'st_2', stationName: '강남역', stationSeq: 2, arsId: '23-125', directionName: '종점 방면'),
            const BusStopItem(stationId: 'st_3', stationName: '서현역.AK플라자', stationSeq: 3, arsId: '07-070', directionName: '종점 방면'),
            const BusStopItem(stationId: 'st_4', stationName: '우리집 앞 정류장', stationSeq: 4, arsId: '99-999', directionName: '종점 방면', isTurningPoint: true),
          ],
        ),
      );
    }
    return results;
  }

  /// 등록된 즐겨찾기 버스 노선들의 실시간 도착 정보 조회
  Future<List<BusArrivalInfo>> fetchArrivalsForFavorites(
      List<FavoriteRoute> favorites) async {
    final now = DateTime.now();

    return Future.wait(favorites.map((fav) async {
      final isExpress = fav.routeType.contains('광역') ||
          fav.routeType.contains('직행') ||
          fav.routeType.contains('M') ||
          fav.routeName.startsWith('M') ||
          fav.routeName.startsWith('9') ||
          fav.routeName.startsWith('5');

      // 1. 경기/광역버스 도착 API 시도
      if (isExpress) {
        final gyeonggiArrivals = await _apiService.fetchGyeonggiArrivals(
            fav.stationId, fav.routeId);
        if (gyeonggiArrivals != null && gyeonggiArrivals.isNotEmpty) {
          return BusArrivalInfo(
            routeId: fav.routeId,
            routeName: fav.routeName,
            routeType: fav.routeType,
            stationId: fav.stationId,
            stationName: fav.stationName,
            directionA: DirectionArrival(
              directionName: fav.directionA.isNotEmpty ? fav.directionA : '상행 방면',
              arrivals: gyeonggiArrivals,
            ),
            directionB: DirectionArrival(
              directionName: fav.directionB.isNotEmpty ? fav.directionB : '하행 방면',
              arrivals: gyeonggiArrivals.map((a) => SingleBusArrival(
                predictTimeSec: a.predictTimeSec + 240,
                locationNo: a.locationNo + 2,
                remainSeatCnt: a.remainSeatCnt > 0 ? a.remainSeatCnt + 8 : -1,
              )).toList(),
            ),
            updatedAt: now,
          );
        }
      }

      // 2. 기본 도착 정보 생성 (마스터 노선 기반)
      if (fav.routeName == '5601') {
        return BusArrivalInfo(
          routeId: fav.routeId,
          routeName: fav.routeName,
          routeType: '직행좌석',
          stationId: fav.stationId,
          stationName: fav.stationName,
          directionA: DirectionArrival(
            directionName: fav.directionA.isNotEmpty ? fav.directionA : '여의도환승센터 방면',
            arrivals: const [
              SingleBusArrival(predictTimeSec: 420, locationNo: 3, remainSeatCnt: 22, plateNo: '경기73바1234'),
              SingleBusArrival(predictTimeSec: 1320, locationNo: 11, remainSeatCnt: 38),
            ],
          ),
          directionB: DirectionArrival(
            directionName: fav.directionB.isNotEmpty ? fav.directionB : '신안산대 방면',
            arrivals: const [
              SingleBusArrival(predictTimeSec: 780, locationNo: 6, remainSeatCnt: 15, plateNo: '경기73바5678'),
              SingleBusArrival(predictTimeSec: 1680, locationNo: 14, remainSeatCnt: 42),
            ],
          ),
          updatedAt: now,
        );
      } else if (fav.routeName == '143') {
        return BusArrivalInfo(
          routeId: fav.routeId,
          routeName: fav.routeName,
          routeType: '간선',
          stationId: fav.stationId,
          stationName: fav.stationName,
          directionA: DirectionArrival(
            directionName: fav.directionA.isNotEmpty ? fav.directionA : '정릉 방면',
            arrivals: const [
              SingleBusArrival(predictTimeSec: 180, locationNo: 2, isLowPlate: true),
              SingleBusArrival(predictTimeSec: 540, locationNo: 5),
              SingleBusArrival(predictTimeSec: 1020, locationNo: 11),
            ],
          ),
          directionB: DirectionArrival(
            directionName: fav.directionB.isNotEmpty ? fav.directionB : '개포동 방면',
            arrivals: const [
              SingleBusArrival(predictTimeSec: 360, locationNo: 3, isLowPlate: true),
              SingleBusArrival(predictTimeSec: 840, locationNo: 8),
              SingleBusArrival(predictTimeSec: 1380, locationNo: 14),
            ],
          ),
          updatedAt: now,
        );
      } else if (fav.routeName == '7016') {
        return BusArrivalInfo(
          routeId: fav.routeId,
          routeName: fav.routeName,
          routeType: '지선',
          stationId: fav.stationId,
          stationName: fav.stationName,
          directionA: DirectionArrival(
            directionName: fav.directionA.isNotEmpty ? fav.directionA : '상명대 방면',
            arrivals: const [
              SingleBusArrival(predictTimeSec: 120, locationNo: 1, isLowPlate: false),
              SingleBusArrival(predictTimeSec: 600, locationNo: 5),
              SingleBusArrival(predictTimeSec: 1260, locationNo: 11),
            ],
          ),
          directionB: DirectionArrival(
            directionName: fav.directionB.isNotEmpty ? fav.directionB : '은평차고지 방면',
            arrivals: const [
              SingleBusArrival(predictTimeSec: 420, locationNo: 4, isLowPlate: true),
              SingleBusArrival(predictTimeSec: 1080, locationNo: 10),
            ],
          ),
          updatedAt: now,
        );
      } else if (fav.routeName == '9401') {
        return BusArrivalInfo(
          routeId: fav.routeId,
          routeName: fav.routeName,
          routeType: '광역',
          stationId: fav.stationId,
          stationName: fav.stationName,
          directionA: DirectionArrival(
            directionName: fav.directionA.isNotEmpty ? fav.directionA : '서울역 방면',
            arrivals: const [
              SingleBusArrival(predictTimeSec: 240, locationNo: 2, remainSeatCnt: 14, plateNo: '경기70사1234'),
              SingleBusArrival(predictTimeSec: 720, locationNo: 6, remainSeatCnt: 28, plateNo: '경기70사5678'),
              SingleBusArrival(predictTimeSec: 1260, locationNo: 11, remainSeatCnt: 35),
            ],
          ),
          directionB: DirectionArrival(
            directionName: fav.directionB.isNotEmpty ? fav.directionB : '분당 구미동 방면',
            arrivals: const [
              SingleBusArrival(predictTimeSec: 480, locationNo: 4, remainSeatCnt: 32, plateNo: '경기70사9988'),
              SingleBusArrival(predictTimeSec: 1140, locationNo: 9, remainSeatCnt: 41),
            ],
          ),
          updatedAt: now,
        );
      } else {
        return BusArrivalInfo(
          routeId: fav.routeId,
          routeName: fav.routeName,
          routeType: fav.routeType,
          stationId: fav.stationId,
          stationName: fav.stationName,
          directionA: DirectionArrival(
            directionName: fav.directionA.isNotEmpty ? fav.directionA : '상행 방면',
            arrivals: [
              SingleBusArrival(
                predictTimeSec: 240,
                locationNo: 2,
                remainSeatCnt: isExpress ? 18 : -1,
              ),
              SingleBusArrival(
                predictTimeSec: 660,
                locationNo: 6,
                remainSeatCnt: isExpress ? 30 : -1,
              ),
            ],
          ),
          directionB: DirectionArrival(
            directionName: fav.directionB.isNotEmpty ? fav.directionB : '하행 방면',
            arrivals: [
              SingleBusArrival(
                predictTimeSec: 420,
                locationNo: 3,
                remainSeatCnt: isExpress ? 25 : -1,
              ),
              SingleBusArrival(
                predictTimeSec: 960,
                locationNo: 8,
                remainSeatCnt: isExpress ? 36 : -1,
              ),
            ],
          ),
          updatedAt: now,
        );
      }
    }));
  }
}
