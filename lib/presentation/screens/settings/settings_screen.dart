import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/app_settings.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  LocationPermission? _locationPermission;
  bool _testingVibration = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    try {
      final perm = await Geolocator.checkPermission();
      if (mounted) {
        setState(() => _locationPermission = perm);
      }
    } catch (_) {}
  }

  String _getRadiusLabel(double meters) {
    if (meters <= 300) return '약 1정거장 전';
    if (meters <= 500) return '약 1~2정거장 전';
    if (meters <= 800) return '기본 권장 (약 2정거장)';
    if (meters <= 1000) return '추천 (광역·급행)';
    if (meters <= 1500) return '여유있는 알람';
    return '최대 반경 (고속 구간)';
  }

  String _getPermissionStatusText() {
    switch (_locationPermission) {
      case LocationPermission.always:
        return '항상 허용 (최적)';
      case LocationPermission.whileInUse:
        return '앱 사용 중에만 허용 (백그라운드 제한)';
      case LocationPermission.denied:
        return '권한 거부됨';
      case LocationPermission.deniedForever:
        return '영구 거부됨 (설정 필요)';
      case LocationPermission.unableToDetermine:
      default:
        return '확인 중...';
    }
  }

  Color _getPermissionStatusColor() {
    switch (_locationPermission) {
      case LocationPermission.always:
        return AppColors.neonLime;
      case LocationPermission.whileInUse:
        return Colors.orangeAccent;
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
        return Colors.redAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '⚙️ 환경설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. 앱 프로필 & 버전 카드
          _buildAppProfileCard(),
          const SizedBox(height: 20),

          // 2. 알람 및 하차 환경설정
          _buildSectionHeader('📳 하차 알람 환경설정'),
          _buildSettingsGroup([
            _buildSettingTile(
              icon: Icons.vibration,
              title: '진동 알람 세기',
              subtitle:
                  '${settings.vibrationIntensity.label} • ${settings.vibrationIntensity.description}',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    onPressed: _testingVibration
                        ? null
                        : () async {
                            setState(() => _testingVibration = true);
                            await settingsNotifier
                                .testVibration(settings.vibrationIntensity);
                            await Future.delayed(
                                const Duration(milliseconds: 600));
                            if (mounted) {
                              setState(() => _testingVibration = false);
                            }
                          },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neonLime,
                      side: const BorderSide(
                          color: AppColors.neonLime, width: 1.2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_testingVibration)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.neonLime,
                            ),
                          )
                        else
                          const Icon(Icons.play_arrow,
                              size: 14, color: AppColors.neonLime),
                        const SizedBox(width: 4),
                        const Text(
                          '테스트',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
              onTap: () => _showVibrationIntensitySheet(context),
            ),
            const Divider(
                height: 1, thickness: 1, color: AppColors.cardBorder),
            _buildSettingTile(
              icon: Icons.radar,
              title: '기본 하차 알람 반경',
              subtitle:
                  '${settings.defaultRadiusMeters.toInt()}m (${_getRadiusLabel(settings.defaultRadiusMeters)})',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textMuted),
              onTap: () => _showDefaultRadiusSheet(context),
            ),
            const Divider(
                height: 1, thickness: 1, color: AppColors.cardBorder),
            _buildSwitchTile(
              icon: Icons.volume_up_outlined,
              title: '소리 알람 기본 켜기',
              subtitle: '새 하차 알람 생성 시 소리 알림을 켠 상태로 시작',
              value: settings.defaultSoundEnabled,
              onChanged: (val) => settingsNotifier.updateDefaultSound(val),
            ),
            const Divider(
                height: 1, thickness: 1, color: AppColors.cardBorder),
            _buildSwitchTile(
              icon: Icons.stay_current_portrait_outlined,
              title: '진동 알람 기본 켜기',
              subtitle: '새 하차 알람 생성 시 진동 알림을 켠 상태로 시작',
              value: settings.defaultVibrationEnabled,
              onChanged: (val) =>
                  settingsNotifier.updateDefaultVibration(val),
            ),
          ]),
          const SizedBox(height: 20),

          // 3. GPS & 시스템 권한 센터
          _buildSectionHeader('📍 시스템 권한 및 백그라운드'),
          _buildSettingsGroup([
            _buildSettingTile(
              icon: Icons.location_on_outlined,
              title: 'GPS 위치 권한 상태',
              subtitle: _getPermissionStatusText(),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPermissionStatusColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getPermissionStatusColor().withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _locationPermission == LocationPermission.always
                          ? '정상'
                          : '설정 권장',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getPermissionStatusColor(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
              onTap: _showLocationPermissionDialog,
            ),
            const Divider(
                height: 1, thickness: 1, color: AppColors.cardBorder),
            _buildSettingTile(
              icon: Icons.battery_charging_full_outlined,
              title: '백그라운드 하차 알람 가이드',
              subtitle: '화면이 꺼지거나 절전 모드일 때 알람 누락 방지 팁',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textMuted),
              onTap: _showBatteryGuideDialog,
            ),
          ]),
          const SizedBox(height: 20),

          // 4. 실시간 갱신 & 데이터 관리
          _buildSectionHeader('🔄 실시간 갱신 & 데이터 관리'),
          _buildSettingsGroup([
            _buildSettingTile(
              icon: Icons.autorenew,
              title: '도착 정보 자동 새로고침 주기',
              subtitle: settings.refreshIntervalSeconds == 0
                  ? '수동 새로고침만 사용'
                  : '${settings.refreshIntervalSeconds}초마다 실시간 자동 갱신',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textMuted),
              onTap: () => _showRefreshIntervalSheet(context),
            ),
            const Divider(
                height: 1, thickness: 1, color: AppColors.cardBorder),
            _buildSettingTile(
              icon: Icons.restart_alt,
              title: '데이터 초기화 & 샘플 복원',
              subtitle: '즐겨찾기 버스·지하철 및 하차 알람을 초기 상태로 복원',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textMuted),
              onTap: _showResetConfirmDialog,
            ),
          ]),
          const SizedBox(height: 20),

          // 5. 공공데이터 & 라이선스 고지
          _buildSectionHeader('📜 데이터 제공처 및 정보'),
          _buildSettingsGroup([
            _buildSettingTile(
              icon: Icons.dataset_outlined,
              title: '공공데이터 라이선스',
              subtitle: '국토교통부(TAGO), 서울시(TOPIS), 서울교통공사',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textMuted),
              onTap: _showPublicDataLicenseDialog,
            ),
            const Divider(
                height: 1, thickness: 1, color: AppColors.cardBorder),
            _buildSettingTile(
              icon: Icons.map_outlined,
              title: '지도 서비스 라이선스',
              subtitle: 'NAVER Cloud Platform Mobile Dynamic Map SDK',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textMuted),
              onTap: _showNaverMapLicenseDialog,
            ),
            const Divider(
                height: 1, thickness: 1, color: AppColors.cardBorder),
            _buildSettingTile(
              icon: Icons.policy_outlined,
              title: '오픈소스 소프트웨어 라이선스',
              subtitle: 'Flutter, Riverpod 등 오픈소스 패키지 고지',
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textMuted),
              onTap: () => showLicensePage(
                context: context,
                applicationName: '기사님, 잠시만요!',
                applicationVersion: 'v1.0.0',
              ),
            ),
          ]),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  // --- 위젯 빌더들 ---

  Widget _buildAppProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonLime.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                  ),
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
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'v1.0.0 (출퇴근러 스마트 교통 비서)',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildBadge('📡 실시간 GPS 지오펜싱'),
              _buildBadge('🗺️ 네이버 지도 SDK'),
              _buildBadge('🚌 버스·지하철 통합'),
              _buildBadge('⚡ 상업적 라이선스 준수'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
          color: AppColors.neonLime,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: children),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, color: AppColors.neonLime, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Icon(icon, color: AppColors.neonLime, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: CupertinoSwitch(
          value: value,
          activeTrackColor: AppColors.neonLime,
          inactiveTrackColor: const Color(0xFF39393D),
          thumbColor: Colors.white,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // --- 모달 & 다이얼로그들 ---

  /// 진동 세기 선택 바텀 시트
  void _showVibrationIntensitySheet(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Row(
                      children: [
                        Icon(Icons.vibration,
                            color: AppColors.neonLime, size: 22),
                        SizedBox(width: 8),
                        Text(
                          '진동 세기 설정',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '목적지 반경 진입 시 잠을 깨워주는 진동 강도와 패턴을 선택하세요.',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    ...VibrationIntensity.values.map((intensity) {
                      final isSelected =
                          settings.vibrationIntensity == intensity;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.neonLime.withValues(alpha: 0.1)
                              : AppColors.surfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.neonLime
                                : AppColors.cardBorder,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          title: Row(
                            children: [
                              Text(
                                intensity.label,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? AppColors.neonLime
                                      : AppColors.textPrimary,
                                ),
                              ),
                              if (intensity == VibrationIntensity.strong) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonLime,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    '추천',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            intensity.description,
                            style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await notifier.testVibration(intensity);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.surface,
                              foregroundColor: AppColors.neonLime,
                              side: const BorderSide(
                                  color: AppColors.cardBorder),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              '체감하기',
                              style: TextStyle(
                                  fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () {
                            notifier.updateVibrationIntensity(intensity);
                            notifier.testVibration(intensity);
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 기본 하차 알람 반경 선택 바텀 시트
  void _showDefaultRadiusSheet(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final radiusOptions = [300.0, 500.0, 800.0, 1000.0, 1500.0, 2000.0];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(Icons.radar, color: AppColors.neonLime, size: 22),
                    SizedBox(width: 8),
                    Text(
                      '기본 하차 알람 반경 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '새 하차 알람을 등록할 때 기본으로 지정될 반경 거리를 선택하세요.',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ...radiusOptions.map((radius) {
                  final isSelected =
                      (settings.defaultRadiusMeters - radius).abs() < 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.neonLime.withValues(alpha: 0.1)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.neonLime
                            : AppColors.cardBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        '${radius.toInt()}m (${_getRadiusLabel(radius)})',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.neonLime
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.neonLime, size: 20)
                          : null,
                      onTap: () {
                        notifier.updateDefaultRadius(radius);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 도착 정보 새로고침 주기 선택 바텀 시트
  void _showRefreshIntervalSheet(BuildContext context) {
    final settings = ref.read(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final options = [
      {'seconds': 10, 'label': '10초마다 (가장 빠름)'},
      {'seconds': 15, 'label': '15초마다 (권장, 기본값)'},
      {'seconds': 30, 'label': '30초마다 (배터리 절약)'},
      {'seconds': 0, 'label': '수동 새로고침만 사용'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Icon(Icons.autorenew,
                        color: AppColors.neonLime, size: 22),
                    SizedBox(width: 8),
                    Text(
                      '실시간 갱신 주기 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  '1번 탭(버스) 및 2번 탭(지하철) 실시간 도착 정보의 자동 갱신 주기를 설정합니다.',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                ...options.map((opt) {
                  final sec = opt['seconds'] as int;
                  final label = opt['label'] as String;
                  final isSelected = settings.refreshIntervalSeconds == sec;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.neonLime.withValues(alpha: 0.1)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.neonLime
                            : AppColors.cardBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      dense: true,
                      title: Text(
                        label,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? AppColors.neonLime
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.neonLime, size: 20)
                          : null,
                      onTap: () {
                        notifier.updateRefreshInterval(sec);
                        Navigator.pop(ctx);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  /// GPS 위치 권한 안내 다이얼로그
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.location_on, color: AppColors.neonLime),
              SizedBox(width: 8),
              Text(
                '위치 권한 안내',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 권한: ${_getPermissionStatusText()}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getPermissionStatusColor(),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '스마트폰 화면이 꺼져 있거나 버스·지하철에서 잠들어 있을 때도 제때 하차 알람을 받으려면, 위치 권한을 "항상 허용"으로 설정하는 것을 권장합니다.\n\n"앱 사용 중에만 허용" 상태에서는 화면이 꺼질 경우 알람 수신이 지연될 수 있습니다.',
                style: TextStyle(
                    fontSize: 13.5, color: AppColors.textSecondary, height: 1.45),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('닫기',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await Geolocator.openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '시스템 설정 열기',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 배터리 절전 모드 예외 안내 다이얼로그
  void _showBatteryGuideDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.battery_charging_full, color: AppColors.neonLime),
              SizedBox(width: 8),
              Text(
                '백그라운드 알람 가이드',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '💡 졸음 하차를 확실히 방지하는 팁',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neonLime),
                ),
                SizedBox(height: 10),
                Text(
                  '1. 배터리 절전(저전력) 모드 해제\n'
                  '스마트폰이 저전력 모드일 때는 백그라운드 GPS 갱신 주기가 길어져 알람이 늦게 울릴 수 있습니다.\n\n'
                  '2. 백그라운드 앱 새로고침 켜기 (iOS)\n'
                  '설정 > 일반 > 백그라운드 앱 새로고침에서 본 앱이 허용되어 있는지 확인해 주세요.\n\n'
                  '3. 배터리 최적화 예외 등록 (Android)\n'
                  '기기 설정 > 배터리 > 배터리 최적화에서 본 앱을 "제한 없음"으로 지정하면 안정적인 알람을 받으실 수 있습니다.',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.45),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('확인',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// 데이터 초기화 확인 다이얼로그
  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent),
              SizedBox(width: 8),
              Text(
                '데이터 초기화',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          content: const Text(
            '등록된 모든 즐겨찾기 버스, 지하철역, 하차 알람 목록 및 환경설정이 초기 상태로 재설정됩니다.\n\n초기화 후 기본 직장인 샘플 데이터(강남역, 143번 버스 등)로 복원됩니다. 계속하시겠습니까?',
            style:
                TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(settingsProvider.notifier).resetAllData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('데이터가 초기화되고 기본 샘플이 복원되었습니다.'),
                      backgroundColor: AppColors.surfaceElevated,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('초기화',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// 공공데이터 라이선스 모달
  void _showPublicDataLicenseDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.dataset, color: AppColors.neonLime),
              SizedBox(width: 8),
              Text(
                '공공데이터 라이선스',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '본 앱은 대한민국 공공누리(제1유형: 출처표시) 조건에 따라 아래 공공기관의 데이터를 합법적으로 활용하고 있습니다.',
                  style: TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                      height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  '• 국토교통부 (TAGO)\n'
                  '  전국 버스 노선 및 실시간 버스 도착 정보\n\n'
                  '• 서울특별시 (TOPIS & 열린데이터광장)\n'
                  '  서울시 대중교통 도착 정보 및 실시간 지하철 열차 위치/도착 정보\n\n'
                  '• 서울교통공사 & 코레일\n'
                  '  수도권 지하철 운행 지연 및 장애 공지 데이터\n\n'
                  '공공누리 제1유형은 상업적 이용 및 변형 등이 100% 무료로 허용되며 출처 표시 의무를 준수합니다.',
                  style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.45),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('닫기',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  /// 네이버 지도 라이선스 모달
  void _showNaverMapLicenseDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.map, color: AppColors.neonLime),
              SizedBox(width: 8),
              Text(
                '네이버 지도 서비스',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary),
              ),
            ],
          ),
          content: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'NAVER Cloud Platform',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neonLime),
              ),
              SizedBox(height: 8),
              Text(
                '본 애플리케이션의 지도 뷰는 NAVER Cloud Platform Mobile Dynamic Map SDK를 공식 연동하여 제공됩니다.\n\n지도의 모든 저작권 및 지적재산권은 NAVER Corp.에 귀속되며, 월 3,000,000건 무료 쿼터를 기반으로 상업적 무료 배포 라이선스 정책을 준수합니다.',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.45),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonLime,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('닫기',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
