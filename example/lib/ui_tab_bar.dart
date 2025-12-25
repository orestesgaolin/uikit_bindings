import 'package:flutter/foundation.dart';
import 'package:objective_c/objective_c.dart';
import 'package:uikit_bindings/uikit_bindings.g.dart';

class TabBarItem {
  TabBarItem({
    required this.title,
    required this.onTap,
    required this.iconName,
  });
  final String title;
  final void Function() onTap;
  final String iconName;
}

UITabBar? addUiTabBar(List<TabBarItem> options) {
  final items = <UITabBarItem>[];
  for (final v in options) {
    final item = UITabBarItem();
    item.title = v.title.toNSString();
    item.image = UIImage.systemImageNamed(v.iconName.toNSString());

    items.add(item);
  }

  final uiTabBar = UITabBar();
  uiTabBar.items = items.toNSArray();
  final rootController = UIApplication.getSharedApplication().keyWindow?.rootViewController;

  if (rootController == null) {
    if (kDebugMode) {
      print('No root view controller found, cannot add UITabBar');
    }
    return null;
  }

  rootController.view.addSubview(uiTabBar);
  // constrain it to the bottom
  uiTabBar.translatesAutoresizingMaskIntoConstraints = false;
  final bottomConstraint = NSLayoutConstraint.constraintWithItem(
    uiTabBar,
    attribute: NSLayoutAttribute.NSLayoutAttributeBottom,
    relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
    toItem: rootController.view,
    attribute$1: NSLayoutAttribute.NSLayoutAttributeBottom,
    multiplier: 1.0,
    constant: 0,
  );
  final leadingConstraint = NSLayoutConstraint.constraintWithItem(
    uiTabBar,
    attribute: NSLayoutAttribute.NSLayoutAttributeLeading,
    relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
    toItem: rootController.view,
    attribute$1: NSLayoutAttribute.NSLayoutAttributeLeading,
    multiplier: 1.0,
    constant: 0,
  );
  final trailingConstraint = NSLayoutConstraint.constraintWithItem(
    uiTabBar,
    attribute: NSLayoutAttribute.NSLayoutAttributeTrailing,
    relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
    toItem: rootController.view,
    attribute$1: NSLayoutAttribute.NSLayoutAttributeTrailing,
    multiplier: 1.0,
    constant: 0,
  );
  rootController.view.addConstraint(bottomConstraint);
  rootController.view.addConstraint(leadingConstraint);
  rootController.view.addConstraint(trailingConstraint);
  return uiTabBar;
}
