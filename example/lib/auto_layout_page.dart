import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objective_c/objective_c.dart' as objc;
import 'package:uikit_bindings/uikit.dart';

void showAutoLayoutViewController() {
  try {
    final completion = ObjCBlock_ffiVoid.listener(() {
      if (kDebugMode) {
        print('Auto layout view controller presented');
      }
    });

    // Create the main view controller
    final viewController = UIViewController();
    if (kDebugMode) {
      print('viewController.viewLoaded: ${viewController.isViewLoaded}');
    }
    final mainView = viewController.view;

    // Set background color using available methods
    mainView.backgroundColor = Color.fromARGB(255, 238, 222, 222).toUIColor();

    // Create UI elements
    final titleLabel = UILabel();
    final subtitleLabel = UILabel();
    final containerView = UIView();

    // Configure title label
    titleLabel.text = 'Auto Layout Demo'.toNSString();
    titleLabel.font = UIFont.boldSystemFontOfSize(24);
    titleLabel.textAlignment = NSTextAlignment.NSTextAlignmentCenter;
    titleLabel.textColor = Color.fromARGB(255, 34, 30, 50).toUIColor();

    // Configure subtitle label
    subtitleLabel.text = 'This view uses UIKit constraints and frame-based positioning'.toNSString();
    subtitleLabel.font = UIFont.systemFontOfSize(16);
    subtitleLabel.textAlignment = NSTextAlignment.NSTextAlignmentCenter;
    subtitleLabel.textColor = Color.fromARGB(255, 51, 51, 51).toUIColor();
    subtitleLabel.numberOfLines = 0;

    // Configure container view
    containerView.backgroundColor = Color.fromARGB(255, 31, 209, 60).toUIColor();

    // Add subviews
    mainView.addSubview(titleLabel);
    mainView.addSubview(subtitleLabel);
    mainView.addSubview(containerView);

    // Disable autoresizing masks to use Auto Layout concepts
    titleLabel.translatesAutoresizingMaskIntoConstraints = false;
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = false;
    containerView.translatesAutoresizingMaskIntoConstraints = false;
    if (kDebugMode) {
      print('viewController.viewLoaded after loadView: ${viewController.isViewLoaded}');
    }

    // Setup layout using frame-based positioning and constraints
    _createConstraintExamples(
      mainView: mainView,
      titleLabel: titleLabel,
      subtitleLabel: subtitleLabel,
      containerView: containerView,
    );

    // Add navigation controller
    final navController = UINavigationController();
    navController.viewControllers = objc.NSArray.arrayWithObject(viewController);
    viewController.title = 'Auto Layout'.toNSString();

    // Present the view controller
    UIApplication.getSharedApplication().keyWindow?.rootViewController?.presentViewController(
      navController,
      animated: true,
      completion: completion,
    );
  } catch (e, s) {
    if (kDebugMode) {
      print('Error presenting auto layout view controller: $e');
      print(s);
    }
  }
}

void _createConstraintExamples({
  required UIView mainView,
  required UILabel titleLabel,
  required UILabel subtitleLabel,
  required UIView containerView,
}) {
  try {
    // Title label constraints
    final titleCenterX = NSLayoutConstraint.constraintWithItem(
      titleLabel,
      attribute: NSLayoutAttribute.NSLayoutAttributeCenterX,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: mainView,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeCenterX,
      multiplier: 1.0,
      constant: 0,
    );

    final titleTop = NSLayoutConstraint.constraintWithItem(
      titleLabel,
      attribute: NSLayoutAttribute.NSLayoutAttributeTop,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: mainView,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeTop,
      multiplier: 1.0,
      constant: 100,
    );

    // Subtitle label constraints (below title)
    final subtitleCenterX = NSLayoutConstraint.constraintWithItem(
      subtitleLabel,
      attribute: NSLayoutAttribute.NSLayoutAttributeCenterX,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: mainView,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeCenterX,
      multiplier: 1.0,
      constant: 0,
    );

    final subtitleTop = NSLayoutConstraint.constraintWithItem(
      subtitleLabel,
      attribute: NSLayoutAttribute.NSLayoutAttributeTop,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: titleLabel,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeBottom,
      multiplier: 1.0,
      constant: 10,
    );

    final subtitleWidth = NSLayoutConstraint.constraintWithItem(
      subtitleLabel,
      attribute: NSLayoutAttribute.NSLayoutAttributeWidth,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: mainView,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeWidth,
      multiplier: 0.8,
      constant: 0,
    );

    // Container view constraints (below subtitle)
    final containerCenterX = NSLayoutConstraint.constraintWithItem(
      containerView,
      attribute: NSLayoutAttribute.NSLayoutAttributeCenterX,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: mainView,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeCenterX,
      multiplier: 1.0,
      constant: 0,
    );

    final containerTop = NSLayoutConstraint.constraintWithItem(
      containerView,
      attribute: NSLayoutAttribute.NSLayoutAttributeTop,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: subtitleLabel,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeBottom,
      multiplier: 1.0,
      constant: 30,
    );

    final containerWidth = NSLayoutConstraint.constraintWithItem(
      containerView,
      attribute: NSLayoutAttribute.NSLayoutAttributeWidth,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: mainView,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeWidth,
      multiplier: 0.8,
      constant: 0,
    );

    final containerHeight = NSLayoutConstraint.constraintWithItem(
      containerView,
      attribute: NSLayoutAttribute.NSLayoutAttributeHeight,
      relatedBy: NSLayoutRelation.NSLayoutRelationEqual,
      toItem: null,
      attribute$1: NSLayoutAttribute.NSLayoutAttributeNotAnAttribute,
      multiplier: 1.0,
      constant: 400,
    );

    // Add all constraints
    mainView.addConstraint(titleCenterX);
    mainView.addConstraint(titleTop);
    mainView.addConstraint(subtitleCenterX);
    mainView.addConstraint(subtitleTop);
    mainView.addConstraint(subtitleWidth);
    mainView.addConstraint(containerCenterX);
    mainView.addConstraint(containerTop);
    mainView.addConstraint(containerWidth);
    mainView.addConstraint(containerHeight);

    if (kDebugMode) {
      print('Successfully added constraint examples');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Constraint creation example (expected to have limited functionality): $e');
    }
  }
}
