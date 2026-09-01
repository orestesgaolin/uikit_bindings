import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:objective_c/objective_c.dart';
import 'package:uikit_bindings/uikit.dart';
import 'package:uikit_example/components_page.dart';
import 'package:uikit_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UIKit control actions update related native controls', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final session = showUIKitComponents(screenWidth: 390);
    await tester.pumpAndSettle();

    expect(session.indicator.isAnimating, isTrue);
    session.activityButton.sendActionsForControlEvents(
      UIControlEvents.UIControlEventTouchUpInside,
    );
    await _waitForNativeCallback(tester);
    expect(session.indicator.isAnimating, isFalse);

    session.slider.value = 0.8;
    session.slider.sendActionsForControlEvents(
      UIControlEvents.UIControlEventValueChanged,
    );
    await _waitForNativeCallback(tester);
    expect(session.progress.progress, closeTo(0.8, 0.001));
    expect(session.pageControl.currentPage, 3);

    session.pageControl.currentPage = 4;
    session.pageControl.sendActionsForControlEvents(
      UIControlEvents.UIControlEventValueChanged,
    );
    await _waitForNativeCallback(tester);
    expect(session.slider.value, closeTo(1, 0.001));
    expect(session.progress.progress, closeTo(1, 0.001));

    session.textField.text = 'Bindings work'.toNSString();
    session.textField.sendActionsForControlEvents(
      UIControlEvents.UIControlEventEditingChanged,
    );
    await _waitForNativeCallback(tester);
    expect(session.title.text?.toDartString(), 'Bindings work');
  });
}

Future<void> _waitForNativeCallback(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump();
}
