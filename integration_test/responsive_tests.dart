import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:findpet/app.dart';
import 'package:findpet/core/app_state.dart';
import 'package:findpet/data/local_repository.dart';

void responsiveTests() {
  testWidgets('intro remains scrollable at 320 x 640', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await LocalRepository.open());
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(FindpetApp(state: state));
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    for (int i = 0; i < 3; i++) {
      final button = find.text(i == 2 ? 'Let’s get started' : 'Next');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    expect(find.text('Login'), findsNWidgets(2));
  });
  testWidgets(
    'demo entry, tab navigation, and search work on a compact screen',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState(await LocalRepository.open());
      state.finishOnboarding();
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(FindpetApp(state: state));
      await tester.tap(find.text('Try the demo'));
      await tester.pumpAndSettle();
      expect(find.text('Hello Anam'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-Messages')));
      await tester.pumpAndSettle();
      expect(find.text('Monika'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('nav-Home')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'no-match');
      await tester.tap(find.byTooltip('Search pets'));
      await tester.pumpAndSettle();
      expect(find.text('No matching friends'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
