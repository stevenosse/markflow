class OnboardingState {
  final int currentStep;
  final String gitUserName;
  final String gitUserEmail;
  final String projectPath;
  final bool isCompleted;
  final bool isLoading;
  final String? error;

  const OnboardingState({
    this.currentStep = 0,
    this.gitUserName = '',
    this.gitUserEmail = '',
    this.projectPath = '',
    this.isCompleted = false,
    this.isLoading = false,
    this.error,
  });

  bool get canProceedFromGitConfig {
    return gitUserName.trim().isNotEmpty && 
           gitUserEmail.trim().isNotEmpty &&
           _isValidEmail(gitUserEmail.trim());
  }

  bool get canProceedFromProjectPath {
    return projectPath.trim().isNotEmpty;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  OnboardingState copyWith({
    int? currentStep,
    String? gitUserName,
    String? gitUserEmail,
    String? projectPath,
    bool? isCompleted,
    bool? isLoading,
    String? error,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      gitUserName: gitUserName ?? this.gitUserName,
      gitUserEmail: gitUserEmail ?? this.gitUserEmail,
      projectPath: projectPath ?? this.projectPath,
      isCompleted: isCompleted ?? this.isCompleted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OnboardingState &&
        other.currentStep == currentStep &&
        other.gitUserName == gitUserName &&
        other.gitUserEmail == gitUserEmail &&
        other.projectPath == projectPath &&
        other.isCompleted == isCompleted &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentStep,
      gitUserName,
      gitUserEmail,
      projectPath,
      isCompleted,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'OnboardingState('
        'currentStep: $currentStep, '
        'gitUserName: $gitUserName, '
        'gitUserEmail: $gitUserEmail, '
        'projectPath: $projectPath, '
        'isCompleted: $isCompleted, '
        'isLoading: $isLoading, '
        'error: $error'
        ')';
  }
}