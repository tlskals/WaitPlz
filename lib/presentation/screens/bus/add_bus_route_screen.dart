import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/favorite_route.dart';
import '../../providers/bus_dashboard_provider.dart';

class AddBusRouteScreen extends ConsumerStatefulWidget {
  const AddBusRouteScreen({super.key});

  @override
  ConsumerState<AddBusRouteScreen> createState() => _AddBusRouteScreenState();
}

class _AddBusRouteScreenState extends ConsumerState<AddBusRouteScreen> {
  final _busNumberController = TextEditingController();
  final _stationNameController = TextEditingController();
  final _directionController = TextEditingController();
  String _selectedRouteType = '광역';
  CommuteTag _selectedTag = CommuteTag.commuteToWork;

  @override
  void dispose() {
    _busNumberController.dispose();
    _stationNameController.dispose();
    _directionController.dispose();
    super.dispose();
  }

  void _saveRoute() {
    final busName = _busNumberController.text.trim();
    final stationName = _stationNameController.text.trim();
    final direction = _directionController.text.trim();

    if (busName.isEmpty || stationName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('버스 번호와 승차 정류장 이름을 입력해 주세요.')),
      );
      return;
    }

    final newRoute = FavoriteRoute(
      id: 'route_${DateTime.now().millisecondsSinceEpoch}',
      routeId: 'user_route_${DateTime.now().millisecondsSinceEpoch}',
      routeName: busName,
      routeType: _selectedRouteType,
      stationId: 'user_st_${DateTime.now().millisecondsSinceEpoch}',
      stationName: stationName,
      direction: direction,
      tag: _selectedTag,
    );

    ref.read(busDashboardProvider.notifier).addFavoriteRoute(newRoute);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 타는 버스 등록'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '출퇴근 루틴 태그 선택',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTagChip('☀️ 출근길', CommuteTag.commuteToWork),
                const SizedBox(width: 8),
                _buildTagChip('🌙 퇴근길', CommuteTag.commuteHome),
                const SizedBox(width: 8),
                _buildTagChip('📍 일반', CommuteTag.general),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              '버스 번호',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _busNumberController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 9401, M5107, 7727',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '버스 유형',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['광역', '간선', '지선', '마을', '직행좌석'].map((type) {
                final isSelected = _selectedRouteType == type;
                return ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  selectedColor: AppColors.neonLime,
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.black : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedRouteType = type);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            const Text(
              '내가 탈 승차 정류장',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _stationNameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 서현역.AK플라자, 순천향대학병원',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              '행선지/방면 (선택)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _directionController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: '예: 서울역 방면, 분당 방면',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saveRoute,
                child: const Text('등록 완료 (대시보드에 즉시 추가)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label, CommuteTag tag) {
    final isSelected = _selectedTag == tag;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.neonLime,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
      ),
      onSelected: (selected) {
        if (selected) setState(() => _selectedTag = tag);
      },
    );
  }
}
