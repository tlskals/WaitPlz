import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/subway_arrival_info.dart';
import '../../data/repositories/subway_repository.dart';

final subwayRepositoryProvider = Provider<SubwayRepository>((ref) {
  return SubwayRepository();
});

class SubwayStationNotifier extends Notifier<String> {
  @override
  String build() => '강남';

  void setStation(String station) => state = station;
}

final selectedSubwayStationProvider =
    NotifierProvider<SubwayStationNotifier, String>(SubwayStationNotifier.new);

final subwayArrivalsProvider =
    FutureProvider.autoDispose<List<SubwayArrivalInfo>>((ref) async {
  final repo = ref.watch(subwayRepositoryProvider);
  final station = ref.watch(selectedSubwayStationProvider);
  return repo.fetchSubwayArrivals(station);
});

final subwayAlertsProvider =
    FutureProvider.autoDispose<List<SubwayAlertNotice>>((ref) async {
  final repo = ref.watch(subwayRepositoryProvider);
  return repo.fetchSubwayAlerts();
});
