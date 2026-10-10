import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vibration/vibration.dart';
import '../../data/models/app_settings.dart';

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

  /// 진동 세기 테스트 (미리보기)
  Future<void> testVibration(VibrationIntensity intensity) async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      await Vibration.cancel();
      await Vibration.vibrate(
        pattern: intensity.pattern,
        intensities: intensity.intensities,
      );
    }
  }

  /// "기사님, 잠시만요!" 도착 전 하차 알람 발송
  Future<void> triggerGetOffAlarm({
    required String stationName,
    String? busRouteName,
    VibrationIntensity vibrationIntensity = VibrationIntensity.strong,
    bool soundEnabled = true,
    bool vibrationEnabled = true,
  }) async {
    // 1. 설정된 진동 모드 발생
    if (vibrationEnabled) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.cancel();
        await Vibration.vibrate(
          pattern: vibrationIntensity.pattern,
          intensities: vibrationIntensity.intensities,
        );
      }
    }

    final androidDetails = AndroidNotificationDetails(
      'transit_get_off_alarm_channel',
      '하차 알람 (기사님, 잠시만요!)',
      channelDescription: '목적지 도착 전 잠을 깨워주는 긴급 알람',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      enableVibration: vibrationEnabled,
      playSound: soundEnabled,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: soundEnabled,
      interruptionLevel: InterruptionLevel.timeSensitive,
    );

    final details = NotificationDetails(
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
