import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/bus_dashboard_provider.dart';
import 'presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 로컬 저장소 및 알림 서비스 초기화
  final storageService = await LocalStorageService.create();
  await NotificationService().init();

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
