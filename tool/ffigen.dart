// ignore_for_file: avoid_print

import 'dart:io';

import 'package:ffigen/ffigen.dart';
import 'package:logging/logging.dart';

void main() {
  final packageRoot = Platform.script.resolve('../');
  final generator = FfiGenerator(
    headers: Headers(
      entryPoints: [
        packageRoot.resolve("Headers/NSLayoutAnchor.h"),
        packageRoot.resolve("Headers/NSLayoutConstraint.h"),
        packageRoot.resolve("Headers/NSToolbar+UIKitAdditions.h"),
        packageRoot.resolve("Headers/UIAlertController.h"),
        packageRoot.resolve("Headers/UIApplication.h"),
        packageRoot.resolve("Headers/UIBarButtonItem.h"),
        packageRoot.resolve("Headers/UIBarButtonItemAppearance.h"),
        packageRoot.resolve("Headers/UIBarButtonItemGroup.h"),
        packageRoot.resolve("Headers/UIColor.h"),
        packageRoot.resolve("Headers/UICommand.h"),
        packageRoot.resolve("Headers/UIFont.h"),
        packageRoot.resolve("Headers/UIGeometry.h"),
        packageRoot.resolve("Headers/UIImage.h"),
        packageRoot.resolve("Headers/UIInterface.h"),
        packageRoot.resolve("Headers/UIKitDefines.h"),
        packageRoot.resolve("Headers/UILabel.h"),
        packageRoot.resolve("Headers/UIMenu.h"),
        packageRoot.resolve("Headers/UINavigationController.h"),
        packageRoot.resolve("Headers/UINavigationItem.h"),
        packageRoot.resolve("Headers/UIResponder.h"),
        packageRoot.resolve("Headers/UIScrollView.h"),
        packageRoot.resolve("Headers/UISpringLoadedInteractionSupporting.h"),
        packageRoot.resolve("Headers/UISwitch.h"),
        packageRoot.resolve("Headers/UITabBar.h"),
        packageRoot.resolve("Headers/UITabBarAppearance.h"),
        packageRoot.resolve("Headers/UITabBarController.h"),
        packageRoot.resolve("Headers/UITabBarItem.h"),
        packageRoot.resolve("Headers/UIView.h"),
        packageRoot.resolve("Headers/UIViewController.h"),
        packageRoot.resolve("Headers/UIWindow.h"),
      ],
    ),
    objectiveC: ObjectiveC(
      interfaces: Interfaces(
        include: (decl) {
          return [
            "NSLayoutConstraint",
            "UIAlertAction",
            "UIAlertController",
            "UIApplication",
            "UIBarButtonItem",
            "UIBarButtonItemAppearance",
            "UIBarButtonItemGroup",
            "UIBarButtonItemStyle",
            "UIBarButtonSystemItem",
            "UIColor",
            "UIFont",
            "UIImage",
            "UILabel",
            "UIMenu",
            "UINavigationBarAppearance",
            "UINavigationController",
            "UINavigationItem",
            "UIScreen",
            "UIScrollView",
            "UISearchTextField",
            "UISwitch",
            "UITabBar",
            "UITabBarAppearance",
            "UITabBarController",
            "UITabBarItem",
            "UITitlebar",
            "UIViewController",
            "UIWindow",
          ].contains(decl.originalName);
        },
        // renameMember: (declaration, member) {
        //   // Manually handle duplicate method names.
        //   if (member == 'initWithFrame:primaryAction:') {
        //     print('Renaming ${declaration.originalName}.$member');
        //     return 'initWithFramePrimaryAction';
        //   }
        //   return member;
        // },
      ),
    ),
    output: Output(
      dartFile: packageRoot.resolve('lib/uikit_bindings.g.dart'),
      objectiveCFile: packageRoot.resolve('ios/Classes/uikit_bindings.m'),
      format: true,
      preamble: '''
// ignore_for_file: unused_element, unused_field, return_of_invalid_type

''',
    ),
  );

  generator.generate(
    logger: Logger('')..onRecord.listen((record) => print(record.message)),
  );

  // replace relative header imports with one #import <UIKit/UIKit.h>
  final objcFile = packageRoot.resolve('ios/Classes/uikit_bindings.m');
  var content = File(objcFile.toFilePath()).readAsStringSync();
  content = content.replaceAllMapped(
    RegExp(r'#import "(.*\.h)"\n'),
    (match) => '',
  );
  content = '#import <UIKit/UIKit.h>\n$content';
  File(objcFile.toFilePath()).writeAsStringSync(content);
}
