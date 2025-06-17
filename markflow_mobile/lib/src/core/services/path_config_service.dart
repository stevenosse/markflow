import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider_ffi/path_provider_ffi.dart';
import 'package:markflow/src/shared/services/app_logger.dart';
import 'package:markflow/src/shared/services/storage/storage.dart';
import 'package:markflow/src/shared/locator.dart';

/// Service for handling platform-specific path configuration
class PathConfigService {
  static const String _basePathKey = 'markflow_base_path';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final AppLogger _logger;
  final Storage _storage;

  String? _cachedBasePath;

  PathConfigService({
    AppLogger? logger,
    Storage? storage,
  })  : _logger = logger ?? locator<AppLogger>(),
        _storage = storage ?? locator<Storage>();

  /// Get the base directory for all projects
  Future<String> getProjectsBasePath() async {
    // Return cached path if available
    if (_cachedBasePath != null) {
      return _cachedBasePath!;
    }

    // Try to get saved path from storage
    final savedPath = await _storage.read<String>(key: _basePathKey);
    if (savedPath != null && savedPath.isNotEmpty) {
      _cachedBasePath = savedPath;
      return savedPath;
    }

    // Default to documents directory
    final documentsPath = await _getDefaultDocumentsPath();
    final defaultPath = path.join(documentsPath, 'MarkFlow');

    // Save the default path
    await setProjectsBasePath(defaultPath);

    return defaultPath;
  }

  /// Set the base directory for all projects
  Future<bool> setProjectsBasePath(String basePath) async {
    try {
      // Ensure the directory exists
      final directory = Directory(basePath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Save to storage
      await _storage.write(key: _basePathKey, value: basePath);

      // Update cache
      _cachedBasePath = basePath;

      _logger.info('Projects base path set to: $basePath');
      return true;
    } catch (e) {
      _logger.error('Error setting projects base path: $e');
      return false;
    }
  }

  /// Get path for a specific project
  Future<String> getProjectPath(String projectName) async {
    final basePath = await getProjectsBasePath();
    return path.join(basePath, projectName);
  }

  /// Check if onboarding has been completed
  Future<bool> isOnboardingCompleted() async {
    try {
      final completed = await _storage.read<bool>(key: _onboardingCompletedKey);
      return completed ?? false;
    } catch (e) {
      _logger.error('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Mark onboarding as completed
  Future<bool> setOnboardingCompleted() async {
    try {
      await _storage.write(key: _onboardingCompletedKey, value: true);
      _logger.info('Onboarding marked as completed');
      return true;
    } catch (e) {
      _logger.error('Error setting onboarding completed: $e');
      return false;
    }
  }

  /// Get base path (alias for getProjectsBasePath for onboarding)
  Future<String> getBasePath() async {
    return getProjectsBasePath();
  }

  /// Set base path (alias for setProjectsBasePath for onboarding)
  Future<bool> setBasePath(String basePath) async {
    return setProjectsBasePath(basePath);
  }

  /// Get the default documents directory based on platform
  Future<String> _getDefaultDocumentsPath() async {
    try {
      if (Platform.isMacOS) {
        final documentsDir = getApplicationDocumentsDirectory();

        return documentsDir.path;
      }

      // Fallback to the current directory
      return Directory.current.path;
    } catch (e) {
      _logger.error('Error getting documents path: $e');
      return Directory.current.path;
    }
  }
}
