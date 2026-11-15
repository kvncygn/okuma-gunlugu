import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:okuma_gunlugu/core/providers/firebase_providers.dart';
import 'package:okuma_gunlugu/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('OkumaGunluguApp ana sayfa ve alt bar ile açılır', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_completed_v1': true,
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const OkumaGunluguApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana Sayfa'), findsOneWidget);
    expect(find.text('Seans'), findsOneWidget);
    expect(find.text('Alıntılar'), findsOneWidget);
    expect(find.text('Keşfet'), findsOneWidget);
  });
}
