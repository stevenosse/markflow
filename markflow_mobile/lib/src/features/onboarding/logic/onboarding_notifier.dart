import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:markflow/src/core/services/git_service.dart';
import 'package:markflow/src/core/services/path_config_service.dart';
import 'package:markflow/src/features/onboarding/logic/onboarding_state.dart';
import 'package:markflow/src/shared/locator.dart';

class OnboardingNotifier extends ValueNotifier<OnboardingState> {
  final GitService _gitService;
  final PathConfigService _pathConfigService;

  OnboardingNotifier({
    GitService? gitService,
    PathConfigService? pathConfigService,
  })  : _gitService = gitService ?? locator<GitService>(),
        _pathConfigService = pathConfigService ?? locator<PathConfigService>(),
        super(const OnboardingState()) {
    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    try {
      // Load existing Git config if available
      final gitConfig = await _gitService.getGlobalConfig();
      final basePath = await _pathConfigService.getBasePath();

      value = value.copyWith(
        gitUserName: gitConfig['user.name'] ?? '',
        gitUserEmail: gitConfig['user.email'] ?? '',
        projectPath: basePath,
      );
    } catch (e) {
        // Error handled silently
      }
  }

  void setCurrentStep(int step) {
    value = value.copyWith(currentStep: step);
  }

  void setGitUserName(String name) {
    value = value.copyWith(gitUserName: name);
  }

  void setGitUserEmail(String email) {
    value = value.copyWith(gitUserEmail: email);
  }

  Future<void> selectProjectPath() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Select Projects Folder',
        initialDirectory:
            value.projectPath.isNotEmpty ? value.projectPath : null,
      );

      if (result != null) {
        value = value.copyWith(projectPath: result);
      }
    } catch (e) {
      value = value.copyWith(error: 'Failed to select folder: $e');
    }
  }

  Future<void> completeOnboarding() async {
    value = value.copyWith(isLoading: true, error: null);

    try {
      // Save Git configuration
      if (value.gitUserName.isNotEmpty && value.gitUserEmail.isNotEmpty) {
        await _gitService.setGlobalConfig({
          'user.name': value.gitUserName,
          'user.email': value.gitUserEmail,
        });
      }

      // Save project path
      if (value.projectPath.isNotEmpty) {
        await _pathConfigService.setBasePath(value.projectPath);
      }

      // Mark onboarding as completed
      await _pathConfigService.setOnboardingCompleted();

      value = value.copyWith(
        isLoading: false,
        isCompleted: true,
      );
    } catch (e) {
      value = value.copyWith(
        isLoading: false,
        error: 'Failed to complete onboarding: $e',
      );
    }
  }

  void clearError() {
    value = value.copyWith(error: null);
  }
}
