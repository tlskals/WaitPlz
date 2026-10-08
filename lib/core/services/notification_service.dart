import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
    );
  }

  /// "기사님, 잠시만요!" 도착 전 강력 하차 알람 발송
  Future<void> triggerGetOffAlarm({
    required String stationName,
    String? busRouteName,
  }) async {
    // 1. 강력한 진동 패턴 발생 (잠든 사람 깨우기용 긴 진동)
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000, 500, 2000],
        intensities: [128, 255, 128, 255, 128, 255],
      );
    }

    // 2. 포그라운드/백그라운드 헤드업 알림 띄우기
    const androidDetails = AndroidNotificationDetails(
      'transit_get_off_alarm_channel',
      '하차 알람 (기사님, 잠시만요!)',
      channelDescription: '목적지 도착 전 잠을 깨워주는 긴급 알람',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final title = busRouteName != null
        ? '🔔 [$busRouteName] 곧 $stationName 하차입니다!'
        : '🔔 곧 $stationName 하차입니다!';

    await _notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: '목적지 반경에 진입했습니다. 소지품을 챙기고 하차 준비를 해주세요! 🏃‍♂️',
      notificationDetails: details,
    );
  }
}
