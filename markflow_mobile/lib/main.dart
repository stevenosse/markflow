import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:markflow/src/core/app_initializer.dart';
import 'package:markflow/src/core/application.dart';

void main() {
  final AppInitializer appInitializer = AppInitializer();

  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await appInitializer.preAppRun();

      runApp(Application());

      // Configure window for desktop platforms
      doWhenWindowReady(() {
        const initialSize = Size(1200, 800);
        appWindow.minSize = const Size(800, 600);
        appWindow.size = initialSize;
        appWindow.alignment = Alignment.center;
        appWindow.title = 'MarkFlow';
        appWindow.show();
      });

      appInitializer.postAppRun();
    },
    (error, stack) {},
  );
}
