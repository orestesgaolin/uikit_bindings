import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:objective_c/objective_c.dart';
import 'package:uikit_bindings/uikit.dart';
import 'package:uikit_example/main.dart' as app;
import 'package:uikit_example/native_dashboard.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Flutter model and native dashboard stay synchronized', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    final model = DashboardModel();
    final session = showNativeDashboard(
      model: model,
      screenWidth: 390,
      screenHeight: 844,
      onDismissed: () {},
    );
    await tester.pumpAndSettle();

    expect(session.navigationBar.topItem?.title?.toDartString(), 'Focus Dashboard');
    expect(session.toolbar.items?.asDart(), hasLength(3));
    expect(session.modeItem.menu?.children.asDart(), hasLength(3));
    expect(session.liveSwitch.isOn, isTrue);
    expect(session.indicator.isAnimating, isTrue);

    model.selectMode(DashboardMode.review);
    model.setLive(false);
    model.setProgress(0.75);
    await tester.pump();

    expect(session.navigationItem.title?.toDartString(), 'Review Dashboard');
    expect(session.modeActions[DashboardMode.review]!.state, UIMenuElementState.UIMenuElementStateOn);
    expect(session.liveSwitch.isOn, isFalse);
    expect(session.slider.value, closeTo(0.75, 0.001));
    expect(session.progressView.progress, closeTo(0.75, 0.001));
    expect(session.pageControl.currentPage, 3);

    session.liveSwitch.isOn = true;
    session.liveSwitch.sendActionsForControlEvents(
      UIControlEvents.UIControlEventValueChanged,
    );
    await _waitForNativeCallback(tester);
    expect(model.isLive, isTrue);
    expect(session.summaryLabel.text?.toDartString(), contains('Live'));

    session.slider.value = 0.25;
    session.slider.sendActionsForControlEvents(
      UIControlEvents.UIControlEventValueChanged,
    );
    await _waitForNativeCallback(tester);
    expect(model.progress, closeTo(0.25, 0.001));
    expect(session.progressView.progress, closeTo(0.25, 0.001));
    expect(session.pageControl.currentPage, 1);

    session.taskField.text = 'Driven from UIKit'.toNSString();
    session.taskField.sendActionsForControlEvents(
      UIControlEvents.UIControlEventEditingChanged,
    );
    await _waitForNativeCallback(tester);
    expect(model.task, 'Driven from UIKit');
    expect(session.navigationItem.prompt?.toDartString(), 'Driven from UIKit');

    session.dispose();
    model.setProgress(0.9);
    await tester.pump();
    expect(session.progressView.progress, closeTo(0.25, 0.001));

    session.slider.value = 0.5;
    session.slider.sendActionsForControlEvents(
      UIControlEvents.UIControlEventValueChanged,
    );
    await _waitForNativeCallback(tester);
    expect(model.progress, closeTo(0.9, 0.001));
    model.dispose();
  });
}

Future<void> _waitForNativeCallback(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump();
}
