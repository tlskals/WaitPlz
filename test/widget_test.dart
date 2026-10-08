import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_w/core/services/local_storage_service.dart';
import 'package:project_w/main.dart';
import 'package:project_w/presentation/providers/bus_dashboard_provider.dart';

void main() {
  testWidgets('GisanimApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storageService),
        ],
        child: const GisanimApp(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('출퇴근 버스'), findsOneWidget);
    expect(find.text('지하철 & 지연'), findsOneWidget);
    expect(find.text('하차 알람'), findsOneWidget);
  });
}
