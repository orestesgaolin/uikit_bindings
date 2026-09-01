import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/widgets.dart';
import 'package:objective_c/objective_c.dart' as objc;
import 'package:uikit_bindings/uikit_bindings.g.dart';

extension UIKitColorExtension on Color {
  UIColor toUIColor() {
    return UIColor.colorWithRed(
      r,
      green: g,
      blue: b,
      alpha: a,
    );
  }
}

/// Helper to create CGRect.
objc.CGRect createCGRect(double x, double y, double width, double height) {
  final ptr = calloc<objc.CGRect>();
  ptr.ref.origin.x = x;
  ptr.ref.origin.y = y;
  ptr.ref.size.width = width;
  ptr.ref.size.height = height;

  return ptr.ref;
}

objc.CGSize createCGSize(double width, double height) {
  final ptr = calloc<objc.CGSize>();
  ptr.ref.width = width;
  ptr.ref.height = height;
  return ptr.ref;
}

/// Returns the key window for [scene], or a best-effort key window from the
/// most relevant foreground window scene when [scene] is omitted.
UIWindow? getKeyWindow([UIWindowScene? scene]) {
  if (scene != null) return _keyWindowInScene(scene);

  final windowScenes = UIApplication.getSharedApplication().connectedScenes
      .asDart()
      .where(UIWindowScene.isA)
      .map(UIWindowScene.as)
      .toList();

  UIWindow? inactiveWindow;
  for (final windowScene in windowScenes) {
    final window = _keyWindowInScene(windowScene);
    if (window == null) continue;
    if (windowScene.activationState == UISceneActivationState.UISceneActivationStateForegroundActive) {
      return window;
    }
    if (windowScene.activationState == UISceneActivationState.UISceneActivationStateForegroundInactive) {
      inactiveWindow ??= window;
    }
  }
  return inactiveWindow;
}

UIWindow? _keyWindowInScene(UIWindowScene scene) {
  for (final object in scene.windows.asDart()) {
    if (!UIWindow.isA(object)) continue;
    final window = UIWindow.as(object);
    if (window.isKeyWindow) return window;
  }
  return null;
}
