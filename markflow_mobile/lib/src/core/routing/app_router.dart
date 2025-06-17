import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:markflow/src/core/routing/wrappers/main_wrapper.dart';
import 'package:markflow/src/datasource/models/project.dart';
import 'package:markflow/src/features/onboarding/guards/onboarding_guard.dart';
import 'package:markflow/src/features/onboarding/ui/onboarding_screen.dart';
import 'package:markflow/src/features/projects/ui/projects_screen.dart';
import 'package:markflow/src/features/projects/ui/project_editor_screen.dart';
import 'package:markflow/src/features/settings/ui/settings_screen.dart';
import 'package:markflow/src/features/shortcuts/ui/shortcuts_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> routes = [
    AutoRoute(
      initial: true,
      page: MainRouter.page,
      children: [
        AutoRoute(
          page: OnboardingRoute.page,
          initial: true,
          guards: [OnboardingGuard()],
        ),
        AutoRoute(page: ProjectsRoute.page),
        AutoRoute(page: ProjectEditorRoute.page),
        AutoRoute(page: SettingsRoute.page),
        AutoRoute(page: ShortcutsRoute.page),
      ],
    )
  ];
}
