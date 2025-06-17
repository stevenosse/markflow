import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:markflow/gen/assets.gen.dart';
import 'package:markflow/src/core/routing/app_router.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/features/onboarding/logic/onboarding_notifier.dart';
import 'package:markflow/src/features/onboarding/logic/onboarding_state.dart';
import 'package:markflow/src/features/onboarding/ui/widgets/onboarding_step_widget.dart';
import 'package:provider/provider.dart';

@RoutePage()
class OnboardingScreen extends StatefulWidget implements AutoRouteWrapper {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingNotifier(),
      child: this,
    );
  }
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late final OnboardingNotifier _notifier;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier = context.read<OnboardingNotifier>();
      _notifier.addListener(_onStateChanged);
    });
  }

  @override
  void dispose() {
    _notifier.removeListener(_onStateChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    final state = _notifier.value;
    if (state.isCompleted) {
      context.router.replaceAll([const ProjectsRoute()]);
    }
  }

  void _nextStep() {
    final currentStep = _notifier.value.currentStep;
    if (currentStep < 3) {
      _notifier.setCurrentStep(currentStep + 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    final currentStep = _notifier.value.currentStep;
    if (currentStep > 0) {
      _notifier.setCurrentStep(currentStep - 1);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<OnboardingNotifier>();
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: notifier,
        builder: (context, state, child) {
          return Column(
            children: [
              const OnboardingHeader(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    OnboardingStepWidget(
                      title: 'Welcome to MarkFlow',
                      subtitle: 'Your markdown editor with Git integration',
                      content: const WelcomeContent(),
                      onNext: () => _nextStep(),
                    ),
                    OnboardingStepWidget(
                      title: 'Git Configuration',
                      subtitle: 'Set up your Git identity',
                      content: GitConfigContent(state: state),
                      onNext: state.canProceedFromGitConfig
                          ? () => _nextStep()
                          : null,
                      onBack: () => _previousStep(),
                    ),
                    OnboardingStepWidget(
                      title: 'Project Location',
                      subtitle: 'Choose where to store your projects',
                      content: ProjectPathContent(state: state),
                      onNext: state.canProceedFromProjectPath
                          ? () => _nextStep()
                          : null,
                      onBack: () => _previousStep(),
                    ),
                    OnboardingStepWidget(
                      title: 'All Set!',
                      subtitle: 'You\'re ready to start using MarkFlow',
                      content: const CompletionContent(),
                      onNext: () => notifier.completeOnboarding(),
                      onBack: () => _previousStep(),
                      nextButtonText: 'Get Started',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OnboardingNotifier>().value;

    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Assets.images.mflogo.image(
            width: 64,
            height: 64,
          ),
          const SizedBox(width: Dimens.spacing),
          Text(
            'MarkFlow',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const Spacer(),
          OnboardingProgressIndicator(currentStep: state.currentStep),
        ],
      ),
    );
  }
}

class OnboardingProgressIndicator extends StatelessWidget {
  final int currentStep;

  const OnboardingProgressIndicator({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (index) {
        final isActive = index <= currentStep;
        final isCompleted = index < currentStep;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: Dimens.minSpacing),
          width: Dimens.doubleSpacing,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isCompleted
                ? Theme.of(context).colorScheme.primary
                : isActive
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5)
                    : Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
          ),
        );
      }),
    );
  }
}

class WelcomeContent extends StatelessWidget {
  const WelcomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.article_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: Dimens.doubleSpacing),
        Text(
          'MarkFlow combines the simplicity of markdown editing with powerful Git version control.',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimens.spacing),
        Text(
          'Let\'s get you set up in just a few steps.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class GitConfigContent extends StatelessWidget {
  final OnboardingState state;

  const GitConfigContent({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<OnboardingNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configure your Git identity for commits:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: Dimens.doubleSpacing),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Your name',
            hintText: 'John Doe',
            border: OutlineInputBorder(),
          ),
          onChanged: notifier.setGitUserName,
          controller: TextEditingController(text: state.gitUserName),
        ),
        const SizedBox(height: Dimens.spacing),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Email address',
            hintText: 'john.doe@example.com',
            border: OutlineInputBorder(),
          ),
          onChanged: notifier.setGitUserEmail,
          controller: TextEditingController(text: state.gitUserEmail),
        ),
        const SizedBox(height: Dimens.spacing),
        Text(
          'This information will be used to identify your commits.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }
}

class ProjectPathContent extends StatelessWidget {
  final OnboardingState state;

  const ProjectPathContent({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final notifier = context.read<OnboardingNotifier>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a folder where your MarkFlow projects will be stored:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: Dimens.doubleSpacing),
        Container(
          padding: const EdgeInsets.all(Dimens.spacing),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(Dimens.radius),
          ),
          child: Row(
            children: [
              Icon(
                Icons.folder_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: Dimens.spacing),
              Expanded(
                child: Text(
                  state.projectPath.isEmpty
                      ? 'No folder selected'
                      : state.projectPath,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextButton(
                onPressed: notifier.selectProjectPath,
                child: const Text('Browse'),
              ),
            ],
          ),
        ),
        const SizedBox(height: Dimens.spacing),
        Text(
          'You can change this later in Settings.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
        ),
      ],
    );
  }
}

class CompletionContent extends StatelessWidget {
  const CompletionContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: Dimens.doubleSpacing),
        Text(
          'MarkFlow is now configured and ready to use!',
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimens.spacing),
        Text(
          'You can create your first project or clone an existing repository.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
