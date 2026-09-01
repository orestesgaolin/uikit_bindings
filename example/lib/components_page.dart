import 'package:flutter/foundation.dart';
import 'package:objective_c/objective_c.dart';
import 'package:uikit_bindings/uikit.dart';

UIKitComponentsSession? _activeComponentSession;

class UIKitComponentsSession {
  UIKitComponentsSession({
    required this.controller,
    required this.title,
    required this.textField,
    required this.slider,
    required this.progress,
    required this.pageControl,
    required this.indicator,
    required this.activityButton,
    required List<Object> references,
  }) : _references = references;

  final UIViewController controller;
  final UILabel title;
  final UITextField textField;
  final UISlider slider;
  final UIProgressView progress;
  final UIPageControl pageControl;
  final UIActivityIndicatorView indicator;
  final UIButton activityButton;
  final List<Object> _references;

  void dispose() {
    _references.clear();
  }
}

UIKitComponentsSession showUIKitComponents({required double screenWidth}) {
  _activeComponentSession?.dispose();
  final controller = UIViewController();
  final rootView = UIView();
  rootView.backgroundColor = UIColorSystemColors.getSystemBackgroundColor();
  controller.view = rootView;

  final title = UILabel();
  title.text = 'Native UIKit controls'.toNSString();
  title.textAlignment = NSTextAlignment.NSTextAlignmentCenter;
  title.textColor = UIColorSystemColors.getLabelColor();

  final image = UIImage.systemImageNamed('slider.horizontal.3'.toNSString());
  final imageView = UIImageView.alloc().initWithImage(image);
  imageView.contentMode = UIViewContentMode.UIViewContentModeScaleAspectFit;
  imageView.tintColor = UIColorSystemColors.getSystemBlueColor();

  final textField = UITextField();
  textField.borderStyle = UITextBorderStyle.UITextBorderStyleRoundedRect;
  textField.placeholder = 'Type into UITextField'.toNSString();

  final slider = UISlider();
  slider.minimumValue = 0;
  slider.maximumValue = 1;
  slider.value = 0.4;

  final progress = UIProgressView.alloc().initWithProgressViewStyle(
    UIProgressViewStyle.UIProgressViewStyleDefault,
  );
  progress.progress = slider.value;

  final pageControl = UIPageControl();
  pageControl.numberOfPages = 5;
  pageControl.currentPage = 2;
  pageControl.currentPageIndicatorTintColor = UIColorSystemColors.getSystemBlueColor();
  pageControl.pageIndicatorTintColor = UIColorSystemColors.getSystemGray4Color();

  final indicator = UIActivityIndicatorView.alloc().initWithActivityIndicatorStyle(
    UIActivityIndicatorViewStyle.UIActivityIndicatorViewStyleMedium,
  );
  indicator.startAnimating();

  late final UIButton activityButton;
  final activityAction = UIAction.actionWithHandler(
    ObjCBlock_ffiVoid_UIAction.listener((action) {
      final sender = action.sender;
      final source = sender == null ? activityButton : UIButton.as(sender);
      if (indicator.isAnimating) {
        indicator.stopAnimating();
        source.setTitle(
          'Start activity indicator'.toNSString(),
          forState: UIControlState.UIControlStateNormal,
        );
        debugPrint('UIKit components: activity=stopped');
      } else {
        indicator.startAnimating();
        source.setTitle(
          'Stop activity indicator'.toNSString(),
          forState: UIControlState.UIControlStateNormal,
        );
        debugPrint('UIKit components: activity=started');
      }
    }),
  );
  activityButton = UIButton.buttonWithType(
    UIButtonType.UIButtonTypeSystem,
  );
  activityButton.setTitle(
    'Stop activity indicator'.toNSString(),
    forState: UIControlState.UIControlStateNormal,
  );
  activityButton.addAction(
    activityAction,
    forControlEvents: UIControlEvents.UIControlEventTouchUpInside,
  );

  final stack = UIStackView();
  stack.axis = UILayoutConstraintAxis.UILayoutConstraintAxisVertical;
  stack.alignment = UIStackViewAlignment.UIStackViewAlignmentFill;
  stack.distribution = UIStackViewDistribution.UIStackViewDistributionEqualSpacing;
  stack.spacing = 14;
  for (final view in [
    title,
    imageView,
    textField,
    slider,
    progress,
    pageControl,
    indicator,
    activityButton,
  ]) {
    stack.addArrangedSubview(view);
  }
  rootView.addSubview(stack);
  UIViewGeometry(stack).frame$1 = createCGRect(
    24,
    48,
    screenWidth - 48,
    520,
  );

  final sliderAction = UIAction.actionWithHandler(
    ObjCBlock_ffiVoid_UIAction.listener((action) {
      final sender = action.sender;
      final source = sender == null ? slider : UISlider.as(sender);
      progress.setProgress(source.value, animated: true);
      pageControl.currentPage = (source.value * (pageControl.numberOfPages - 1)).round();
      debugPrint(
        'UIKit components: slider=${source.value.toStringAsFixed(2)} '
        'page=${pageControl.currentPage}',
      );
    }),
  );
  slider.addAction(
    sliderAction,
    forControlEvents: UIControlEvents.UIControlEventValueChanged,
  );

  final pageAction = UIAction.actionWithHandler(
    ObjCBlock_ffiVoid_UIAction.listener((action) {
      final sender = action.sender;
      final source = sender == null ? pageControl : UIPageControl.as(sender);
      final value = source.currentPage / (source.numberOfPages - 1);
      slider.setValue(value, animated: true);
      progress.setProgress(value, animated: true);
      debugPrint(
        'UIKit components: page=${source.currentPage} '
        'progress=${value.toStringAsFixed(2)}',
      );
    }),
  );
  pageControl.addAction(
    pageAction,
    forControlEvents: UIControlEvents.UIControlEventValueChanged,
  );

  final textAction = UIAction.actionWithHandler(
    ObjCBlock_ffiVoid_UIAction.listener((action) {
      final sender = action.sender;
      final source = sender == null ? textField : UITextField.as(sender);
      final value = source.text?.toDartString() ?? '';
      title.text = value.isEmpty ? 'Native UIKit controls'.toNSString() : value.toNSString();
      debugPrint('UIKit components: text=$value');
    }),
  );
  textField.addAction(
    textAction,
    forControlEvents: UIControlEvents.UIControlEventEditingChanged,
  );

  final completion = ObjCBlock_ffiVoid.listener(
    () => debugPrint('UIKit components: presented'),
  );
  final session = UIKitComponentsSession(
    controller: controller,
    title: title,
    textField: textField,
    slider: slider,
    progress: progress,
    pageControl: pageControl,
    indicator: indicator,
    activityButton: activityButton,
    references: [
      sliderAction,
      pageAction,
      textAction,
      activityAction,
      completion,
    ],
  );
  _activeComponentSession = session;
  UIApplication.getSharedApplication().keyWindow?.rootViewController?.presentViewController(
    controller,
    animated: true,
    completion: completion,
  );
  return session;
}
