import 'dart:async';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

/// 장소/주소 검색 결과 모델
class PlaceSearchResult {
  final String title;
  final String address;
  final double latitude;
  final double longitude;
  final String category;

  const PlaceSearchResult({
    required this.title,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.category = '장소',
  });
}

/// 위치 정보 및 장소 검색 서비스
class LocationService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 4),
    headers: {
      'User-Agent': 'WaitPlz-App/1.0 (transit-alarm; contact: dev@waitplz.app)',
    },
  ));

  /// 위치 권한 확인 및 요청
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// 현재 GPS 위치 획득 (실패 시 서울 중심 기본 좌표 반환)
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// 실시간 위치 스트림 (거리 5m 이상 이동 시 갱신)
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터 이동 시마다 스트림 발생
      ),
    );
  }

  /// 두 좌표 간의 직선 거리(미터) 계산
  double calculateDistance(
      double startLat, double startLon, double endLat, double endLon) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  /// 장소/도로명/역/건물 검색 (OSM Nominatim + 오프라인 주요 거점 캐시 결합)
  Future<List<PlaceSearchResult>> searchPlaces(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final results = <PlaceSearchResult>[];
    final addedKeys = <String>{};

    // 1. 주요 랜드마크 및 거점 즉시 검색 (0ms 지연 및 오프라인 안전장치)
    final localMatches = _findLocalLandmarks(trimmed);
    for (final item in localMatches) {
      final key = '${item.latitude.toStringAsFixed(4)}_${item.longitude.toStringAsFixed(4)}';
      if (!addedKeys.contains(key)) {
        addedKeys.add(key);
        results.add(item);
      }
    }

    // 2. OpenStreetMap Nominatim 한국 장소 검색 API 호출
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': trimmed,
          'format': 'json',
          'countrycodes': 'kr',
          'addressdetails': '1',
          'limit': '10',
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List;
        for (final item in list) {
          final lat = double.tryParse(item['lat']?.toString() ?? '') ?? 0.0;
          final lon = double.tryParse(item['lon']?.toString() ?? '') ?? 0.0;
          if (lat == 0.0 || lon == 0.0) continue;

          final key = '${lat.toStringAsFixed(4)}_${lon.toStringAsFixed(4)}';
          if (addedKeys.contains(key)) continue;
          addedKeys.add(key);

          final name = (item['name']?.toString() ?? '').isNotEmpty
              ? item['name'].toString()
              : (item['display_name']?.toString().split(',').first ?? trimmed);

          final displayName = item['display_name']?.toString() ?? '';
          final type = item['type']?.toString() ?? '장소';

          results.add(PlaceSearchResult(
            title: name,
            address: displayName,
            latitude: lat,
            longitude: lon,
            category: _mapCategory(type),
          ));
        }
      }
    } catch (_) {
      // 네트워크 지연 시 로컬 결과 그대로 활용
    }

    return results;
  }

  /// 좌표를 바탕으로 대략적인 주소/지명 반환 (Reverse Geocode)
  Future<String> reverseGeocode(double lat, double lon) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lon,
          'format': 'json',
          'zoom': 18,
          'addressdetails': 1,
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final address = response.data['address'] as Map<String, dynamic>?;
        if (address != null) {
          final road = address['road'] ?? '';
          final suburb = address['suburb'] ?? address['quarter'] ?? '';
          final city = address['city'] ?? address['province'] ?? '';
          if (road.isNotEmpty) return '$road 인근 ($suburb)';
          if (suburb.isNotEmpty) return '$city $suburb 인근';
        }
        final name = response.data['name']?.toString();
        if (name != null && name.isNotEmpty) return name;
      }
    } catch (_) {}

    return '위도 ${lat.toStringAsFixed(4)}, 경도 ${lon.toStringAsFixed(4)}';
  }

  String _mapCategory(String type) {
    switch (type) {
      case 'bus_stop':
        return '정류장';
      case 'station':
      case 'subway':
        return '지하철역';
      case 'primary':
      case 'secondary':
      case 'highway':
        return '도로';
      case 'commercial':
      case 'retail':
        return '상업지구';
      default:
        return '장소';
    }
  }

  /// 주요 한국 랜드마크 / 도로 / 역 사전
  List<PlaceSearchResult> _findLocalLandmarks(String query) {
    final q = query.replaceAll(' ', '').toLowerCase();
    final all = [
      const PlaceSearchResult(
        title: '테헤란로',
        address: '서울특별시 강남구 테헤란로 (강남역-삼성역 구간)',
        latitude: 37.5024,
        longitude: 127.0426,
        category: '도로',
      ),
      const PlaceSearchResult(
        title: '강남역',
        address: '서울특별시 강남구 테헤란로 101 (2호선/신분당선)',
        latitude: 37.4979,
        longitude: 127.0276,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '판교역',
        address: '경기도 성남시 분당구 판교역로 160 (신분당선/경강선)',
        latitude: 37.3947,
        longitude: 127.1112,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '판교 테크노밸리',
        address: '경기도 성남시 분당구 삼평동 판교테크노밸리',
        latitude: 37.4018,
        longitude: 127.1068,
        category: '업무지구',
      ),
      const PlaceSearchResult(
        title: '서현역.AK플라자',
        address: '경기도 성남시 분당구 황새울로360번길 42 (수인분당선)',
        latitude: 37.3849,
        longitude: 127.1232,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '여의도 환승센터',
        address: '서울특별시 영등포구 여의대로 108',
        latitude: 37.5255,
        longitude: 126.9248,
        category: '환승센터',
      ),
      const PlaceSearchResult(
        title: '사당역',
        address: '서울특별시 동작구 동작대로 3 (2호선/4호선)',
        latitude: 37.4765,
        longitude: 126.9816,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '광화문역',
        address: '서울특별시 종로구 세종대로 172 (5호선)',
        latitude: 37.5715,
        longitude: 126.9768,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '서울역 환승센터',
        address: '서울특별시 중구 한강대로 405 (1호선/4호선/공항철도/KTX)',
        latitude: 37.5562,
        longitude: 126.9723,
        category: '환승센터',
      ),
      const PlaceSearchResult(
        title: '잠실역',
        address: '서울특별시 송파구 올림픽로 265 (2호선/8호선)',
        latitude: 37.5133,
        longitude: 127.1001,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '코엑스 (COEX)',
        address: '서울특별시 강남구 영동대로 513',
        latitude: 37.5118,
        longitude: 127.0592,
        category: '복합문화시설',
      ),
      const PlaceSearchResult(
        title: '홍대입구역',
        address: '서울특별시 마포구 양화로 160 (2호선/경의중앙선/공항철도)',
        latitude: 37.5575,
        longitude: 126.9245,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '신도림역',
        address: '서울특별시 구로구 경인로 688 (1호선/2호선)',
        latitude: 37.5088,
        longitude: 126.8913,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '고속터미널역',
        address: '서울특별시 서초구 신반포로 188 (3호선/7호선/9호선)',
        latitude: 37.5049,
        longitude: 127.0049,
        category: '지하철역',
      ),
      const PlaceSearchResult(
        title: '수원역',
        address: '경기도 수원시 팔달구 덕영대로 924 (1호선/수인분당선/KTX)',
        latitude: 37.2657,
        longitude: 127.0000,
        category: '지하철역',
      ),
    ];

    return all
        .where((item) =>
            item.title.replaceAll(' ', '').toLowerCase().contains(q) ||
            item.address.replaceAll(' ', '').toLowerCase().contains(q))
        .toList();
  }
}
