import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../models/subway_arrival_info.dart';

class SubwayApiService {
  final Dio _dio;

  SubwayApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 5),
              ),
            );

  /// subwayId(코드)를 한글 호선명으로 변환
  static String mapSubwayIdToLineName(String? subwayId) {
    switch (subwayId) {
      case '1001':
        return '1호선';
      case '1002':
        return '2호선';
      case '1003':
        return '3호선';
      case '1004':
        return '4호선';
      case '1005':
        return '5호선';
      case '1006':
        return '6호선';
      case '1007':
        return '7호선';
      case '1008':
        return '8호선';
      case '1009':
        return '9호선';
      case '1063':
        return '경의중앙선';
      case '1065':
        return '공항철도';
      case '1067':
        return '경춘선';
      case '1075':
        return '수인분당선';
      case '1077':
        return '신분당선';
      case '1081':
        return '경강선';
      case '1092':
        return '우이신설선';
      case '1093':
        return '서해선';
      case '1094':
        return '신림선';
      case '1032':
        return 'GTX-A';
      default:
        return '지하철';
    }
  }

  /// 서울시 실시간 지하철 도착정보 조회 API 호출
  Future<List<SubwayArrivalInfo>> fetchRealtimeStationArrival(
      String stationName) async {
    try {
      final cleanName =
          stationName.trim().replaceAll('역', ''); // "서울역" -> "서울", "강남역" -> "강남"
      final encodedName = Uri.encodeComponent(cleanName);
      final url =
          '${ApiConstants.seoulOpenDataBaseUrl}/${ApiConstants.seoulApiKey}/json/realtimeStationArrival/0/16/$encodedName';

      final response = await _dio.get(url);

      if (response.statusCode == 200 && response.data != null) {
        dynamic data = response.data;
        if (data is String) {
          data = json.decode(data);
        }

        final arrivalList = data['realtimeArrivalList'];
        if (arrivalList != null && arrivalList is List) {
          final now = DateTime.now();
          return arrivalList.map((item) {
            final subwayId = item['subwayId']?.toString();
            final lineName = mapSubwayIdToLineName(subwayId);
            final trainLineNm = item['trainLineNm']?.toString() ?? '도착 예정';
            final updnLine = item['updnLine']?.toString() ?? '';
            final btrainSttus = item['btrainSttus']?.toString() ?? '일반';
            final barvlDt = int.tryParse(item['barvlDt']?.toString() ?? '0') ?? 0;
            final arvlMsg2 = item['arvlMsg2']?.toString() ?? '도착 정보 없음';
            final arvlMsg3 = item['arvlMsg3']?.toString() ?? '';

            final direction = updnLine.isNotEmpty
                ? '[$updnLine] $trainLineNm'
                : trainLineNm;

            return SubwayArrivalInfo(
              stationName: cleanName,
              lineName: lineName,
              direction: direction,
              arrivalTimeSec: barvlDt,
              arrivalMessage: arvlMsg2,
              currentStation: arvlMsg3.isNotEmpty ? arvlMsg3 : cleanName,
              isExpress: btrainSttus.contains('급행') || btrainSttus.contains('특급'),
              updatedAt: now,
            );
          }).toList();
        }
      }
    } catch (_) {
      // 오류 발생 시 빈 리스트 반환 (호출부에서 안전하게 처리)
    }
    return [];
  }
}
