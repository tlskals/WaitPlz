import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'alarm/transit_alarm_screen.dart';
import 'bus/bus_dashboard_screen.dart';
import 'settings/settings_screen.dart';
import 'subway/subway_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BusDashboardScreen(),
    SubwayScreen(),
    TransitAlarmScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: AppColors.background,
          indicatorColor: AppColors.neonLime,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.directions_bus_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.directions_bus, color: Colors.black),
              label: '출퇴근 버스',
            ),
            NavigationDestination(
              icon: Icon(Icons.subway_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.subway, color: Colors.black),
              label: '지하철 & 지연',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_active_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.notifications_active, color: Colors.black),
              label: '하차 알람',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.settings, color: Colors.black),
              label: '설정',
            ),
          ],
        ),
      ),
    );
  }
}
