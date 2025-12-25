import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:objective_c/objective_c.dart';

import 'package:uikit_bindings/uikit.dart';
import 'package:uikit_example/auto_layout_page.dart';
import 'package:uikit_example/ui_tab_bar.dart';

void main() {
  runApp(MaterialApp(home: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UITabBar? uiTabBar;

  void showAlert() {
    try {
      final handler = ObjCBlock_ffiVoid_UIAlertAction.listener((action) {
        if (kDebugMode) {
          print('done: ${action.title?.toDartString()}');
        }
      });
      final completion = ObjCBlock_ffiVoid.listener(() {
        if (kDebugMode) {
          print('completed');
        }
      });
      final controller = UIAlertController.alertControllerWithTitle(
        'Title'.toNSString(),
        message: 'Message'.toNSString(),
        preferredStyle: UIAlertControllerStyle.UIAlertControllerStyleAlert,
      );
      controller.title = 'Dialog Title'.toNSString();
      controller.message = 'This is a dialog message.'.toNSString();
      controller.addAction(
        UIAlertAction.actionWithTitle(
          'OK'.toNSString(),
          style: UIAlertActionStyle.UIAlertActionStyleDefault,
          handler: handler,
        ),
      );
      controller.addAction(
        UIAlertAction.actionWithTitle(
          'Cancel'.toNSString(),
          style: UIAlertActionStyle.UIAlertActionStyleCancel,
          handler: handler,
        ),
      );

      UIApplication.getSharedApplication().keyWindow?.rootViewController?.presentViewController(
        controller,
        animated: true,
        completion: completion,
      );
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
        print(s);
      }
    }
  }

  void showViewController() {
    try {
      final completion = ObjCBlock_ffiVoid.listener(() {
        if (kDebugMode) {
          print('completed');
        }
      });

      final newViewController = UIViewController();
      final view = UIView();
      final size = MediaQuery.of(context).size;
      final screenWidth = size.width;
      final label = UILabel();
      label.text = 'This is a custom view controller'.toNSString();
      view.addSubview(label);
      label.textAlignment = NSTextAlignment.NSTextAlignmentCenter;
      final labelWidth = label.intrinsicContentSize.width;

      UIViewGeometry(label).frame$1 = createCGRect(
        screenWidth / 2 - labelWidth / 2,
        100,
        labelWidth,
        label.intrinsicContentSize.height,
      );
      label.sizeToFit();
      newViewController.view = view;
      newViewController.view.backgroundColor = Colors.amber.toUIColor();
      UIApplication.getSharedApplication().keyWindow?.rootViewController?.presentViewController(
        newViewController,
        animated: true,
        completion: completion,
      );
    } catch (e, s) {
      if (kDebugMode) {
        print(e);
        print(s);
      }
    }
  }

  void addTabBar() {
    uiTabBar = addUiTabBar([
      TabBarItem(
        title: 'Home',
        iconName: SfSymbols.folder,
        onTap: () {
          if (kDebugMode) {
            print('Home tapped');
          }
        },
      ),
      TabBarItem(
        title: 'Settings',
        iconName: SfSymbols.gear,
        onTap: () {
          if (kDebugMode) {
            print('Settings tapped');
          }
        },
      ),
    ]);
    setState(() {});
  }

  void removeTabBar() {
    if (uiTabBar != null) {
      uiTabBar?.removeFromSuperview();
      uiTabBar = null;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UIKit Bindings Example')),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: showAlert,
                child: const Text('Show Alert Dialog'),
              ),
              ElevatedButton(
                onPressed: showViewController,
                child: const Text('Show View Controller'),
              ),
              ElevatedButton(
                onPressed: () {
                  showAutoLayoutViewController();
                },
                child: const Text('Show Auto Layout Example'),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: addTabBar,
                    child: const Text('Add Tab Bar'),
                  ),
                  ElevatedButton(
                    onPressed: removeTabBar,
                    child: const Text('Remove Tab Bar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
