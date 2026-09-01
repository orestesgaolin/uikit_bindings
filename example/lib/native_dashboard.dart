import 'package:flutter/foundation.dart';
import 'package:objective_c/objective_c.dart';
import 'package:uikit_bindings/uikit.dart';

enum DashboardMode {
  focus('Focus'),
  review('Review'),
  breakTime('Break');

  const DashboardMode(this.label);
  final String label;
}

class DashboardModel extends ChangeNotifier {
  String task = 'Ship the next UIKit bindings';
  bool isLive = true;
  bool isRunning = true;
  double progress = 0.4;
  DashboardMode mode = DashboardMode.focus;

  void setTask(String value) {
    if (task == value) return;
    task = value;
    _changed('task=$task');
  }

  void setLive(bool value) {
    if (isLive == value) return;
    isLive = value;
    _changed('live=$isLive');
  }

  void setProgress(double value) {
    final normalized = value.clamp(0.0, 1.0);
    if (progress == normalized) return;
    progress = normalized;
    _changed('progress=${progress.toStringAsFixed(2)}');
  }

  void selectMode(DashboardMode value) {
    if (mode == value) return;
    mode = value;
    _changed('mode=${mode.label}');
  }

  void toggleRunning() {
    isRunning = !isRunning;
    _changed('running=$isRunning');
  }

  void reset() {
    task = 'Ship the next UIKit bindings';
    isLive = true;
    isRunning = false;
    progress = 0;
    mode = DashboardMode.focus;
    _changed('reset');
  }

  void _changed(String change) {
    debugPrint('DashboardModel: $change');
    notifyListeners();
  }
}

class NativeDashboardSession {
  NativeDashboardSession({
    required this.model,
    required this.controller,
    required this.navigationBar,
    required this.navigationItem,
    required this.toolbar,
    required this.taskField,
    required this.liveSwitch,
    required this.slider,
    required this.progressView,
    required this.pageControl,
    required this.indicator,
    required this.summaryLabel,
    required this.startPauseItem,
    required this.modeItem,
    required this.modeActions,
    required this.registrations,
    required this.references,
  }) {
    model.addListener(render);
    render();
  }

  final DashboardModel model;
  final UIViewController controller;
  final UINavigationBar navigationBar;
  final UINavigationItem navigationItem;
  final UIToolbar toolbar;
  final UITextField taskField;
  final UISwitch liveSwitch;
  final UISlider slider;
  final UIProgressView progressView;
  final UIPageControl pageControl;
  final UIActivityIndicatorView indicator;
  final UILabel summaryLabel;
  final UIBarButtonItem startPauseItem;
  final UIBarButtonItem modeItem;
  final Map<DashboardMode, UIAction> modeActions;
  final List<(UIControl, UIAction, int)> registrations;
  final List<Object> references;
  bool _disposed = false;

  void render() {
    if (_disposed) return;
    final percentage = (model.progress * 100).round();
    navigationItem.title = '${model.mode.label} Dashboard'.toNSString();
    navigationItem.prompt = model.task.toNSString();
    summaryLabel.text = '$percentage% • ${model.isLive ? 'Live' : 'Manual'} • ${model.isRunning ? 'Running' : 'Paused'}'
        .toNSString();
    final currentTask = taskField.text?.toDartString() ?? '';
    if (currentTask != model.task) taskField.text = model.task.toNSString();
    liveSwitch.setOn(model.isLive, animated: true);
    slider.setValue(model.progress, animated: true);
    progressView.setProgress(model.progress, animated: true);
    pageControl.currentPage = (model.progress * (pageControl.numberOfPages - 1)).round();
    if (model.isRunning) {
      indicator.startAnimating();
    } else {
      indicator.stopAnimating();
    }
    startPauseItem.title = (model.isRunning ? 'Pause' : 'Start').toNSString();
    for (final entry in modeActions.entries) {
      entry.value.state = entry.key == model.mode
          ? UIMenuElementState.UIMenuElementStateOn
          : UIMenuElementState.UIMenuElementStateOff;
    }
    modeItem.menu = UIMenu.menuWithTitle(
      'Dashboard mode'.toNSString(),
      children: modeActions.values.toList().toNSArray(),
    );
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    model.removeListener(render);
    for (final registration in registrations) {
      registration.$1.removeAction(
        registration.$2,
        forControlEvents: registration.$3,
      );
    }
    navigationItem.leftBarButtonItem = null;
    navigationItem.rightBarButtonItem = null;
    toolbar.items = null;
    registrations.clear();
    references.clear();
  }
}

NativeDashboardSession showNativeDashboard({
  required DashboardModel model,
  required double screenWidth,
  required double screenHeight,
  required VoidCallback onDismissed,
}) {
  final controller = UIViewController();
  controller.modalPresentationStyle = UIModalPresentationStyle.UIModalPresentationFullScreen;
  controller.isModalInPresentation = true;
  final rootView = UIView();
  rootView.backgroundColor = UIColorSystemColors.getSystemBackgroundColor();
  controller.view = rootView;

  final navigationBar = UINavigationBar();
  UIViewGeometry(navigationBar).frame$1 = createCGRect(0, 48, screenWidth, 52);
  rootView.addSubview(navigationBar);
  final navigationItem = UINavigationItem();
  navigationBar.pushNavigationItem(navigationItem, animated: false);

  final header = UILabel();
  header.text = 'Flutter logic → native UIKit'.toNSString();
  header.textAlignment = NSTextAlignment.NSTextAlignmentCenter;
  header.textColor = UIColorSystemColors.getLabelColor();

  final symbol = UIImage.systemImageNamed('rectangle.3.group'.toNSString());
  final imageView = UIImageView.alloc().initWithImage(symbol);
  imageView.contentMode = UIViewContentMode.UIViewContentModeScaleAspectFit;
  imageView.tintColor = UIColorSystemColors.getSystemBlueColor();

  final taskField = UITextField();
  taskField.borderStyle = UITextBorderStyle.UITextBorderStyleRoundedRect;
  taskField.placeholder = 'Dashboard task'.toNSString();

  final liveLabel = UILabel();
  liveLabel.text = 'Live updates'.toNSString();
  final liveSwitch = UISwitch();
  final switchRow = UIStackView();
  switchRow.axis = UILayoutConstraintAxis.UILayoutConstraintAxisHorizontal;
  switchRow.alignment = UIStackViewAlignment.UIStackViewAlignmentCenter;
  switchRow.distribution = UIStackViewDistribution.UIStackViewDistributionEqualSpacing;
  switchRow.addArrangedSubview(liveLabel);
  switchRow.addArrangedSubview(liveSwitch);

  final summaryLabel = UILabel();
  summaryLabel.textAlignment = NSTextAlignment.NSTextAlignmentCenter;

  final slider = UISlider();
  slider.minimumValue = 0;
  slider.maximumValue = 1;
  final progressView = UIProgressView.alloc().initWithProgressViewStyle(
    UIProgressViewStyle.UIProgressViewStyleDefault,
  );
  final pageControl = UIPageControl();
  pageControl.numberOfPages = 5;
  pageControl.currentPageIndicatorTintColor = UIColorSystemColors.getSystemBlueColor();
  pageControl.pageIndicatorTintColor = UIColorSystemColors.getSystemGray4Color();
  final indicator = UIActivityIndicatorView.alloc().initWithActivityIndicatorStyle(
    UIActivityIndicatorViewStyle.UIActivityIndicatorViewStyleMedium,
  );

  final content = UIStackView();
  content.axis = UILayoutConstraintAxis.UILayoutConstraintAxisVertical;
  content.alignment = UIStackViewAlignment.UIStackViewAlignmentFill;
  content.distribution = UIStackViewDistribution.UIStackViewDistributionEqualSpacing;
  content.spacing = 12;
  for (final view in [
    header,
    imageView,
    taskField,
    switchRow,
    summaryLabel,
    slider,
    progressView,
    pageControl,
    indicator,
  ]) {
    content.addArrangedSubview(view);
  }
  UIViewGeometry(content).frame$1 = createCGRect(
    24,
    120,
    screenWidth - 48,
    screenHeight - 230,
  );
  rootView.addSubview(content);

  final toolbar = UIToolbar();
  UIViewGeometry(toolbar).frame$1 = createCGRect(0, screenHeight - 84, screenWidth, 50);
  rootView.addSubview(toolbar);

  final modeActions = <DashboardMode, UIAction>{};
  for (final mode in DashboardMode.values) {
    modeActions[mode] = UIAction.actionWithTitle(
      mode.label.toNSString(),
      image: null,
      identifier: null,
      handler: ObjCBlock_ffiVoid_UIAction.listener((_) => model.selectMode(mode)),
    );
  }
  final modeMenu = UIMenu.menuWithTitle(
    'Dashboard mode'.toNSString(),
    children: modeActions.values.toList().toNSArray(),
  );
  final modeItem = UIBarButtonItem.alloc().initWithTitle(
    'Mode'.toNSString(),
    menu: modeMenu,
  );
  navigationItem.rightBarButtonItem = modeItem;

  final closeAction = UIAction.actionWithHandler(
    ObjCBlock_ffiVoid_UIAction.listener((_) {
      final presented = getKeyWindow()?.rootViewController?.presentedViewController;
      presented?.dismissViewControllerAnimated(
        true,
        completion: ObjCBlock_ffiVoid.listener(onDismissed),
      );
    }),
  );
  navigationItem.leftBarButtonItem = UIBarButtonItem.alloc().initWithBarButtonSystemItem$1(
    UIBarButtonSystemItem.UIBarButtonSystemItemClose,
    primaryAction: closeAction,
  );

  final resetAction = UIAction.actionWithTitle(
    'Reset'.toNSString(),
    image: null,
    identifier: null,
    handler: ObjCBlock_ffiVoid_UIAction.listener((_) => model.reset()),
  );
  final startPauseAction = UIAction.actionWithTitle(
    'Pause'.toNSString(),
    image: null,
    identifier: null,
    handler: ObjCBlock_ffiVoid_UIAction.listener((_) => model.toggleRunning()),
  );
  final resetItem = UIBarButtonItem.alloc().initWithPrimaryAction(resetAction);
  final startPauseItem = UIBarButtonItem.alloc().initWithPrimaryAction(startPauseAction);
  toolbar.items = [
    resetItem,
    UIBarButtonItem.flexibleSpaceItem(),
    startPauseItem,
  ].toNSArray();

  final registrations = <(UIControl, UIAction, int)>[];
  void register(UIControl control, UIAction action, int events) {
    control.addAction(action, forControlEvents: events);
    registrations.add((control, action, events));
  }

  late final UISwitch retainedSwitch = liveSwitch;
  final switchAction = UIAction.actionWithHandler(
    ObjCBlock_ffiVoid_UIAction.listener((action) {
      final sender = action.sender;
      final source = sender == null ? retainedSwitch : UISwitch.as(sender);
      model.setLive(source.isOn);
    }),
  );
  register(
    UIControl.as(liveSwitch),
    switchAction,
    UIControlEvents.UIControlEventValueChanged,
  );

  final sliderAction = UIAction.actionWithHandler(
    ObjCBlock_ffiVoid_UIAction.listener((action) {
      final sender = action.sender;
      final source = sender == null ? slider : UISlider.as(sender);
      model.setProgress(source.value);
    }),
  );
  register(
    UIControl.as(slider),
    sliderAction,
    UIControlEvents.UIControlEventValueChanged,
  );

  final textAction = UIAction.actionWithHandler(
    ObjCBlock_ffiVoid_UIAction.listener((action) {
      final sender = action.sender;
      final source = sender == null ? taskField : UITextField.as(sender);
      model.setTask(source.text?.toDartString() ?? '');
    }),
  );
  register(
    UIControl.as(taskField),
    textAction,
    UIControlEvents.UIControlEventEditingChanged,
  );

  final session = NativeDashboardSession(
    model: model,
    controller: controller,
    navigationBar: navigationBar,
    navigationItem: navigationItem,
    toolbar: toolbar,
    taskField: taskField,
    liveSwitch: liveSwitch,
    slider: slider,
    progressView: progressView,
    pageControl: pageControl,
    indicator: indicator,
    summaryLabel: summaryLabel,
    startPauseItem: startPauseItem,
    modeItem: modeItem,
    modeActions: modeActions,
    registrations: registrations,
    references: [
      closeAction,
      resetAction,
      startPauseAction,
      switchAction,
      sliderAction,
      textAction,
      ...modeActions.values,
    ],
  );
  getKeyWindow()?.rootViewController?.presentViewController(
    controller,
    animated: true,
    completion: null,
  );
  return session;
}
