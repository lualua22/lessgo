import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lessgo_app/onboarding/onboarding_view.dart';
import 'package:lessgo_app/onboarding/onboarding_spec.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(320, 568), const Size(844, 390)]) {
    testWidgets('Onboarding fits $size and start completes', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var starts = 0;
      await tester.pumpWidget(MaterialApp(home: MediaQuery(
        data: MediaQueryData(size: size, disableAnimations: true, textScaler: TextScaler.linear(size.width == 320 ? 1.6 : 1)),
        child: OnboardingView(onStart: () async { starts++; }),
      )));
      await tester.pumpAndSettle();
      expect(find.text(OnboardingSpec.title), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text(OnboardingSpec.button));
      await tester.tap(find.text(OnboardingSpec.button));
      await tester.pumpAndSettle();
      expect(starts, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
