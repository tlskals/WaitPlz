import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ 설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. 앱 프로필 & 버전 카드
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.neonLime,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Icon(Icons.alarm_on, color: Colors.black, size: 28),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '기사님, 잠시만요!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'v1.0.0 (출퇴근러 스마트 교통 비서)',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 2. 알람 및 출퇴근 설정 섹션
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              '알람 및 출퇴근 환경설정',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.neonLime),
            ),
          ),
          _buildSettingsGroup([
            _buildSettingTile(
              icon: Icons.vibration,
              title: '진동 알람 세기',
              subtitle: '강력 진동 (잠든 사람 깨우기 모드)',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.radar,
              title: '기본 하차 알람 반경',
              subtitle: '기본 800m (약 1~2개 정류장 전)',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.schedule,
              title: '출퇴근 자동 전환 시간',
              subtitle: '오전 00:00~13:00 (출근) / 오후 13:00~24:00 (퇴근)',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () {},
            ),
          ]),
          const SizedBox(height: 20),

          // 3. 데이터 출처 및 정보 섹션
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              '데이터 제공처 및 정보',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.neonLime),
            ),
          ),
          _buildSettingsGroup([
            _buildSettingTile(
              icon: Icons.dataset,
              title: '공공데이터 라이선스',
              subtitle: '국토교통부(TAGO), 서울특별시(TOPIS), 서울교통공사',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.map,
              title: '지도 서비스',
              subtitle: 'NAVER Cloud Platform Mobile Dynamic Map',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () {},
            ),
            _buildSettingTile(
              icon: Icons.policy,
              title: '오픈소스 라이선스',
              subtitle: 'MIT / BSD-3 / Apache 2.0',
              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
              onTap: () {
                showLicensePage(context: context);
              },
            ),
          ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.neonLime, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
