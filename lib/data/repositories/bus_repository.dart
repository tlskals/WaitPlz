import '../models/bus_arrival_info.dart';
import '../models/favorite_route.dart';

class BusRepository {
  /// 등록된 즐겨찾기 버스 노선들의 실시간 도착 정보 조회
  Future<List<BusArrivalInfo>> fetchArrivalsForFavorites(
      List<FavoriteRoute> favorites) async {
    // 공공데이터 API 연동 뼈대 및 시뮬레이션 데이터 제공
    // (실제 API 키 입력 시 공공데이터포털 REST API로 즉시 전환 가능한 구조)
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    return favorites.map((fav) {
      if (fav.routeName == '9401') {
        return BusArrivalInfo(
          routeId: fav.routeId,
          routeName: fav.routeName,
          routeType: fav.routeType,
          stationId: fav.stationId,
          stationName: fav.stationName,
          stationSeq: fav.stationSeq,
          predictTimeSec1: 240, // 4분 후
          locationNo1: 2, // 2번째 전
          remainSeatCnt1: 14, // 잔여 14석
          plateNo1: '경기70사1234',
          predictTimeSec2: 360, // 6분 후 (연속 배차 발생!)
          locationNo2: 3, // 바로 뒤 3번째 전
          remainSeatCnt2: 28,
          plateNo2: '경기70사5678',
          updatedAt: now,
        );
      } else if (fav.routeName == 'M5107') {
        return BusArrivalInfo(
          routeId: fav.routeId,
          routeName: fav.routeName,
          routeType: fav.routeType,
          stationId: fav.stationId,
          stationName: fav.stationName,
          stationSeq: fav.stationSeq,
          predictTimeSec1: 720, // 12분 후
          locationNo1: 5, // 5번째 전
          remainSeatCnt1: 3, // 잔여 3석 (혼잡)
          plateNo1: '경기77바9988',
          predictTimeSec2: 1560, // 26분 후
          locationNo2: 12,
          remainSeatCnt2: 35,
          plateNo2: '경기77바1122',
          updatedAt: now,
        );
      } else {
        return BusArrivalInfo(
          routeId: fav.routeId,
          routeName: fav.routeName,
          routeType: fav.routeType,
          stationId: fav.stationId,
          stationName: fav.stationName,
          stationSeq: fav.stationSeq,
          predictTimeSec1: 480,
          locationNo1: 4,
          remainSeatCnt1: 22,
          plateNo1: '서울74사4321',
          predictTimeSec2: 1200,
          locationNo2: 9,
          remainSeatCnt2: 40,
          plateNo2: '서울74사8765',
          updatedAt: now,
        );
      }
    }).toList();
  }
}
