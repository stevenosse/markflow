import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:markflow/src/core/environment.dart';
import 'package:markflow/src/core/i18n/l10n.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'package:markflow/src/core/theme/app_theme.dart';
import 'package:markflow/src/core/services/keyboard_shortcuts_service.dart';
import 'package:markflow/src/core/services/keyboard_actions.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/components/window_frame.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class Application extends StatelessWidget {
  final AppRouter _appRouter;

  Application({
    super.key,
    AppRouter? appRouter,
  }) : _appRouter = appRouter ?? locator<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: KeyboardShortcutsService.instance.globalShortcuts,
      child: Actions(
        actions: KeyboardActions.globalActions,
        child: MaterialApp.router(
          title: Environment.appName,
          routerConfig: _appRouter.config(
            navigatorObservers: () => [
              AutoRouteObserver(),
            ],
          ),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            I18n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: I18n.delegate.supportedLocales,
          builder: (context, child) => WindowFrame(child: child!),
        ),
      ),
    );
  }
}
