import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';

class OnboardingStepWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget content;
  final VoidCallback? onNext;
  final VoidCallback? onBack;
  final String? nextButtonText;
  final String? backButtonText;

  const OnboardingStepWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.content,
    this.onNext,
    this.onBack,
    this.nextButtonText,
    this.backButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimens.spacing),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Dimens.doubleSpacing),
                    content,
                  ],
                ),
              ),
            ),
          ),
          _buildNavigationButtons(context),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (onBack != null)
          TextButton(
            onPressed: onBack,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.arrow_back, size: Dimens.iconSizeS),
                const SizedBox(width: Dimens.spacing),
                Text(backButtonText ?? 'Back'),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
        if (onNext != null)
          FilledButton(
            onPressed: onNext,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(nextButtonText ?? 'Next'),
                const SizedBox(width: Dimens.halfSpacing),
                const Icon(Icons.arrow_forward, size: Dimens.iconSizeS),
              ],
            ),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}