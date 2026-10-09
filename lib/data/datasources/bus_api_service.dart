import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:xml/xml.dart';
import '../../core/constants/api_constants.dart';
import '../models/bus_arrival_info.dart';
import '../models/bus_route_detail.dart';

class BusApiService {
  final Dio _dio;

  BusApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  /// 국토교통부 TAGO 버스 노선 실시간 검색 (getRouteNoList)
  Future<List<BusRouteDetail>?> searchTagoRouteNo(String routeNo) async {
    try {
      final cleanNo = routeNo.trim().replaceAll('번', '');
      if (cleanNo.isEmpty) return null;

      final url = '${ApiConstants.tagoRouteBaseUrl}/getRouteNoList';
      final response = await _dio.get(
        url,
        queryParameters: {
          'serviceKey': ApiConstants.dataGoKrServiceKey,
          'routeNo': cleanNo,
          '_type': 'json',
          'numOfRows': 20,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        if (data is String) {
          data = json.decode(data);
        }

        final items = data['response']?['body']?['items']?['item'];
        if (items != null) {
          final List list = items is List ? items : [items];
          return list.map((item) {
            final routeId = item['routeid']?.toString() ?? '';
            final rName = item['routeno']?.toString() ?? cleanNo;
            final rType = item['routetp']?.toString() ?? '일반';
            final start = item['startnodenm']?.toString() ?? '기점';
            final end = item['endnodenm']?.toString() ?? '종점';

            return BusRouteDetail(
              routeId: routeId,
              routeName: rName,
              region: '수도권',
              routeType: rType,
              startStation: start,
              endStation: end,
              directionA: '$start 방면',
              directionB: '$end 방면',
            );
          }).toList();
        }
      }
    } catch (_) {
      // API 키 동기화 대기 중이거나 네트워크 오류 시 안전하게 fallback
    }
    return null;
  }

  /// 국토교통부 TAGO 노선별 경유 정류소 목록 조회 (getRouteInfoIitemList)
  Future<List<BusStopItem>?> fetchTagoRouteStations(
      String cityCode, String routeId) async {
    try {
      final url = '${ApiConstants.tagoRouteBaseUrl}/getRouteInfoIitemList';
      final response = await _dio.get(
        url,
        queryParameters: {
          'serviceKey': ApiConstants.dataGoKrServiceKey,
          'cityCode': cityCode.isNotEmpty ? cityCode : '31190',
          'routeId': routeId,
          '_type': 'json',
          'numOfRows': 150,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        if (data is String) {
          data = json.decode(data);
        }

        final items = data['response']?['body']?['items']?['item'];
        if (items != null) {
          final List list = items is List ? items : [items];
          return list.map((item) {
            final stationId = item['nodeid']?.toString() ?? '';
            final name = item['nodenm']?.toString() ?? '';
            final seq = int.tryParse(item['nodeord']?.toString() ?? '1') ?? 1;
            final nodeno = item['nodeno']?.toString() ?? '';
            final updown = item['updowncd']?.toString() == '1' ? '상행' : '하행';

            return BusStopItem(
              stationId: stationId,
              stationName: name,
              stationSeq: seq,
              arsId: nodeno,
              directionName: updown,
            );
          }).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// 국토교통부 TAGO 실시간 정류소별 도착예정정보 (getSttnAcctoArvlPrearngeInfoList)
  Future<List<SingleBusArrival>?> fetchTagoArrivals(
      String cityCode, String nodeId, String routeId) async {
    try {
      final url =
          '${ApiConstants.tagoArrivalBaseUrl}/getSttnAcctoArvlPrearngeInfoList';
      final response = await _dio.get(
        url,
        queryParameters: {
          'serviceKey': ApiConstants.dataGoKrServiceKey,
          'cityCode': cityCode.isNotEmpty ? cityCode : '31190',
          'nodeId': nodeId,
          '_type': 'json',
          'numOfRows': 50,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        if (data is String) {
          data = json.decode(data);
        }

        final items = data['response']?['body']?['items']?['item'];
        if (items != null) {
          final List list = items is List ? items : [items];
          final matching = list.where((item) {
            final id = item['routeid']?.toString() ?? '';
            return id == routeId || routeId.isEmpty;
          }).toList();

          return matching.map((item) {
            final arrSec = int.tryParse(item['arrtime']?.toString() ?? '0') ?? 0;
            final stops =
                int.tryParse(item['arrprevstationcnt']?.toString() ?? '0') ?? 0;
            return SingleBusArrival(
              predictTimeSec: arrSec,
              locationNo: stops,
            );
          }).toList();
        }
      }
    } catch (_) {}
    return null;
  }

  /// 경기도 버스도착정보 조회 서비스 (잔여 좌석 포함 XML 파싱)
  Future<List<SingleBusArrival>?> fetchGyeonggiArrivals(
      String stationId, String routeId) async {
    try {
      final url =
          '${ApiConstants.gyeonggiArrivalBaseUrl}/v2/getBusArrivalList';
      final response = await _dio.get(
        url,
        queryParameters: {
          'serviceKey': ApiConstants.dataGoKrServiceKey,
          'stationId': stationId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final xmlDoc = XmlDocument.parse(response.data.toString());
        final items = xmlDoc.findAllElements('busArrivalList');

        for (final item in items) {
          final rId = item.findElements('routeId').firstOrNull?.innerText ?? '';
          if (rId == routeId || routeId.isEmpty) {
            final pTime1 = int.tryParse(
                    item.findElements('predictTime1').firstOrNull?.innerText ??
                        '0') ??
                0;
            final loc1 = int.tryParse(
                    item.findElements('locationNo1').firstOrNull?.innerText ??
                        '0') ??
                0;
            final seat1 = int.tryParse(
                    item.findElements('remainSeatCnt1').firstOrNull?.innerText ??
                        '-1') ??
                -1;

            final pTime2 = int.tryParse(
                    item.findElements('predictTime2').firstOrNull?.innerText ??
                        '0') ??
                0;
            final loc2 = int.tryParse(
                    item.findElements('locationNo2').firstOrNull?.innerText ??
                        '0') ??
                0;
            final seat2 = int.tryParse(
                    item.findElements('remainSeatCnt2').firstOrNull?.innerText ??
                        '-1') ??
                -1;

            final results = <SingleBusArrival>[];
            if (pTime1 > 0 || loc1 > 0) {
              results.add(SingleBusArrival(
                predictTimeSec: pTime1 * 60,
                locationNo: loc1,
                remainSeatCnt: seat1,
              ));
            }
            if (pTime2 > 0 || loc2 > 0) {
              results.add(SingleBusArrival(
                predictTimeSec: pTime2 * 60,
                locationNo: loc2,
                remainSeatCnt: seat2,
              ));
            }
            if (results.isNotEmpty) return results;
          }
        }
      }
    } catch (_) {}
    return null;
  }
}
