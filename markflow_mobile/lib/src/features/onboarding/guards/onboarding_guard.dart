import 'package:auto_route/auto_route.dart';
import 'package:markflow/src/core/services/path_config_service.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/core/routing/app_router.dart';

class OnboardingGuard extends AutoRouteGuard {
  @override
  Future<void> onNavigation(NavigationResolver resolver, StackRouter router) async {
    final pathConfigService = locator<PathConfigService>();
    final isOnboardingCompleted = await pathConfigService.isOnboardingCompleted();
    
    if (isOnboardingCompleted) {
      // If onboarding is completed, redirect to projects
      router.replaceAll([const ProjectsRoute()]);
    } else {
      // If onboarding is not completed, allow navigation to onboarding
      resolver.next();
    }
  }
}
