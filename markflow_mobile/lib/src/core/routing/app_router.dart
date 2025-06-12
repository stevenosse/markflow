import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/features/projects/ui/projects_screen.dart';
import 'package:markflow/src/features/projects/ui/project_editor_screen.dart';
import 'package:markflow/src/features/settings/ui/settings_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> routes = [
    AutoRoute(page: ProjectsRoute.page, path: '/', initial: true),
    AutoRoute(page: ProjectEditorRoute.page, path: '/editor'),
    AutoRoute(page: SettingsRoute.page, path: '/settings'),
  ];
}
