import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/api_constants.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/bus_dashboard_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 로컬 저장소 및 알림 서비스 초기화
  final storageService = await LocalStorageService.create();
  await NotificationService().init();

  // 2. 네이버 지도 SDK 초기화 (NCP Client ID)
  try {
    await FlutterNaverMap().init(
      clientId: ApiConstants.naverMapClientId,
      onAuthFailed: (ex) {
        debugPrint('네이버 지도 인증 실패: $ex');
      },
    );
  } catch (e) {
    debugPrint('네이버 지도 초기화 예외: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const GisanimApp(),
    ),
  );
}

class GisanimApp extends StatelessWidget {
  const GisanimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '기사님, 잠시만요!',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.darkTheme,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
