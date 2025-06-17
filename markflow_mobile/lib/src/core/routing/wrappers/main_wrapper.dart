import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:markflow/src/shared/components/shortcuts/global_shortcuts.dart';

@RoutePage(name: 'MainRouter')
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  @override
  Widget build(BuildContext context) {
    return GlobalShortcuts(child: AutoRouter());
  }
}