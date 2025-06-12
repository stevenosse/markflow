import 'dart:async';
import 'package:markflow/src/datasource/models/git_models.dart';
import 'package:markflow/src/core/services/git_service.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';

/// Repository for managing Git operations
class GitRepository {
  final GitService _gitService;
  final AppLogger _logger;
  
  GitRepository({
    GitService? gitService,
    AppLogger? logger,
  }) : _gitService = gitService ?? locator<GitService>(),
       _logger = logger ?? locator<AppLogger>();
  
  /// Initialize a new Git repository
  Future<bool> initRepository(String projectPath) async {
    try {
      final result = await _gitService.init(projectPath);
      if (result) {
        _logger.info('Git repository initialized: $projectPath');
      } else {
        _logger.error('Failed to initialize Git repository: $projectPath');
      }
      return result;
    } catch (e) {
      _logger.error('Error initializing Git repository: $e');
      return false;
    }
  }
  
  /// Clone a remote repository
  Future<bool> cloneRepository({
    required String remoteUrl,
    required String localPath,
    String? branch,
  }) async {
    try {
      final result = await _gitService.clone(
        remoteUrl: remoteUrl,
        localPath: localPath,
        branch: branch,
      );
      
      if (result) {
        _logger.info('Repository cloned: $remoteUrl to $localPath');
      } else {
        _logger.error('Failed to clone repository: $remoteUrl');
      }
      
      return result;
    } catch (e) {
      _logger.error('Error cloning repository: $e');
      return false;
    }
  }
  
  /// Get the current Git status
  Future<GitStatus?> getStatus(String projectPath) async {
    try {
      return await _gitService.getStatus(projectPath);
    } catch (e) {
      _logger.error('Error getting Git status: $e');
      return null;
    }
  }
  
  /// Stage files for commit
  Future<bool> stageFiles(String projectPath, List<String> filePaths) async {
    try {
      final result = await _gitService.addFiles(projectPath, filePaths);
      if (result) {
        _logger.info('Files staged: ${filePaths.join(", ")}');
      } else {
        _logger.error('Failed to stage files: ${filePaths.join(", ")}');
      }
      return result;
    } catch (e) {
      _logger.error('Error staging files: $e');
      return false;
    }
  }
  
  /// Stage all changes
  Future<bool> stageAllChanges(String projectPath) async {
    try {
      final result = await _gitService.addAll(projectPath);
      if (result) {
        _logger.info('All changes staged');
      } else {
        _logger.error('Failed to stage all changes');
      }
      return result;
    } catch (e) {
      _logger.error('Error staging all changes: $e');
      return false;
    }
  }
  
  /// Unstage files
  Future<bool> unstageFiles(String projectPath, List<String> filePaths) async {
    try {
      final result = await _gitService.resetFiles(projectPath, filePaths);
      if (result) {
        _logger.info('Files unstaged: ${filePaths.join(", ")}');
      } else {
        _logger.error('Failed to unstage files: ${filePaths.join(", ")}');
      }
      return result;
    } catch (e) {
      _logger.error('Error unstaging files: $e');
      return false;
    }
  }
  
  /// Create a commit
  Future<bool> commit(String projectPath, String message) async {
    try {
      if (message.trim().isEmpty) {
        _logger.error('Commit message cannot be empty');
        return false;
      }
      
      final result = await _gitService.commit(projectPath, message);
      if (result) {
        _logger.info('Commit created: $message');
      } else {
        _logger.error('Failed to create commit');
      }
      return result;
    } catch (e) {
      _logger.error('Error creating commit: $e');
      return false;
    }
  }
  
  /// Push changes to remote
  Future<bool> push(String projectPath, {String? remote, String? branch}) async {
    try {
      final result = await _gitService.push(
        projectPath,
        remote: remote,
        branch: branch,
      );
      
      if (result) {
        _logger.info('Changes pushed to remote');
      } else {
        _logger.error('Failed to push changes');
      }
      
      return result;
    } catch (e) {
      _logger.error('Error pushing changes: $e');
      return false;
    }
  }
  
  /// Pull changes from remote
  Future<bool> pull(String projectPath, {String? remote, String? branch}) async {
    try {
      final result = await _gitService.pull(
        projectPath,
        remote: remote,
        branch: branch,
      );
      
      if (result) {
        _logger.info('Changes pulled from remote');
      } else {
        _logger.error('Failed to pull changes');
      }
      
      return result;
    } catch (e) {
      _logger.error('Error pulling changes: $e');
      return false;
    }
  }
  
  /// Get commit history
  Future<List<GitCommit>> getCommitHistory(
    String projectPath, {
    int? limit,
    String? branch,
  }) async {
    try {
      return await _gitService.getCommitHistory(
        projectPath,
        limit: limit,
        branch: branch,
      );
    } catch (e) {
      _logger.error('Error getting commit history: $e');
      return [];
    }
  }
  
  /// Get all branches
  Future<List<GitBranch>> getBranches(String projectPath) async {
    try {
      return await _gitService.getBranches(projectPath);
    } catch (e) {
      _logger.error('Error getting branches: $e');
      return [];
    }
  }
  
  /// Get current branch
  Future<String?> getCurrentBranch(String projectPath) async {
    try {
      return await _gitService.getCurrentBranch(projectPath);
    } catch (e) {
      _logger.error('Error getting current branch: $e');
      return null;
    }
  }
  
  /// Create a new branch
  Future<bool> createBranch(String projectPath, String branchName) async {
    try {
      final result = await _gitService.createBranch(projectPath, branchName);
      if (result) {
        _logger.info('Branch created: $branchName');
      } else {
        _logger.error('Failed to create branch: $branchName');
      }
      return result;
    } catch (e) {
      _logger.error('Error creating branch: $e');
      return false;
    }
  }
  
  /// Switch to a branch
  Future<bool> switchBranch(String projectPath, String branchName) async {
    try {
      final result = await _gitService.switchBranch(projectPath, branchName);
      if (result) {
        _logger.info('Switched to branch: $branchName');
      } else {
        _logger.error('Failed to switch to branch: $branchName');
      }
      return result;
    } catch (e) {
      _logger.error('Error switching branch: $e');
      return false;
    }
  }
  
  /// Delete a branch
  Future<bool> deleteBranch(String projectPath, String branchName) async {
    try {
      final result = await _gitService.deleteBranch(projectPath, branchName);
      if (result) {
        _logger.info('Branch deleted: $branchName');
      } else {
        _logger.error('Failed to delete branch: $branchName');
      }
      return result;
    } catch (e) {
      _logger.error('Error deleting branch: $e');
      return false;
    }
  }
  
  /// Get remote repositories
  Future<List<GitRemote>> getRemotes(String projectPath) async {
    try {
      return await _gitService.getRemotes(projectPath);
    } catch (e) {
      _logger.error('Error getting remotes: $e');
      return [];
    }
  }
  
  /// Add a remote repository
  Future<bool> addRemote(
    String projectPath,
    String name,
    String url,
  ) async {
    try {
      final result = await _gitService.addRemote(projectPath, name, url);
      if (result) {
        _logger.info('Remote added: $name -> $url');
      } else {
        _logger.error('Failed to add remote: $name');
      }
      return result;
    } catch (e) {
      _logger.error('Error adding remote: $e');
      return false;
    }
  }
  
  /// Remove a remote repository
  Future<bool> removeRemote(String projectPath, String name) async {
    try {
      final result = await _gitService.removeRemote(projectPath, name);
      if (result) {
        _logger.info('Remote removed: $name');
      } else {
        _logger.error('Failed to remove remote: $name');
      }
      return result;
    } catch (e) {
      _logger.error('Error removing remote: $e');
      return false;
    }
  }
  
  /// Check if directory is a Git repository
  Future<bool> isGitRepository(String projectPath) async {
    try {
      return await _gitService.isGitRepository(projectPath);
    } catch (e) {
      _logger.error('Error checking if Git repository: $e');
      return false;
    }
  }
  
  /// Get file diff
  Future<String?> getFileDiff(
    String projectPath,
    String filePath, {
    String? fromCommit,
    String? toCommit,
  }) async {
    try {
      return await _gitService.getFileDiff(
        projectPath,
        filePath,
        fromCommit: fromCommit,
        toCommit: toCommit,
      );
    } catch (e) {
      _logger.error('Error getting file diff: $e');
      return null;
    }
  }
  
  /// Discard changes in working directory
  Future<bool> discardChanges(
    String projectPath,
    List<String> filePaths,
  ) async {
    try {
      final result = await _gitService.discardChanges(projectPath, filePaths);
      if (result) {
        _logger.info('Changes discarded for: ${filePaths.join(", ")}');
      } else {
        _logger.error('Failed to discard changes');
      }
      return result;
    } catch (e) {
      _logger.error('Error discarding changes: $e');
      return false;
    }
  }
  
  /// Get repository configuration
  Future<Map<String, String>> getConfig(String projectPath) async {
    try {
      return await _gitService.getConfig(projectPath);
    } catch (e) {
      _logger.error('Error getting Git config: $e');
      return {};
    }
  }
  
  /// Set repository configuration
  Future<bool> setConfig(
    String projectPath,
    String key,
    String value,
  ) async {
    try {
      final result = await _gitService.setConfig(projectPath, key, value);
      if (result) {
        _logger.info('Git config set: $key = $value');
      } else {
        _logger.error('Failed to set Git config: $key');
      }
      return result;
    } catch (e) {
      _logger.error('Error setting Git config: $e');
      return false;
    }
  }
  
  /// Check if there are uncommitted changes
  Future<bool> hasUncommittedChanges(String projectPath) async {
    try {
      final status = await getStatus(projectPath);
      if (status == null) return false;
      
      return status.hasChanges;
    } catch (e) {
      _logger.error('Error checking uncommitted changes: $e');
      return false;
    }
  }
  
  /// Check if repository is ahead/behind remote
  Future<Map<String, int>> getAheadBehindCount(
    String projectPath, {
    String? remote = 'origin',
    String? branch,
  }) async {
    try {
      final currentBranch = branch ?? await getCurrentBranch(projectPath);
      if (currentBranch == null) {
        return {'ahead': 0, 'behind': 0};
      }
      
      // This would require additional Git commands to implement
      // For now, return default values
      return {'ahead': 0, 'behind': 0};
    } catch (e) {
      _logger.error('Error getting ahead/behind count: $e');
      return {'ahead': 0, 'behind': 0};
    }
  }
  
  /// Validate Git repository state
  Future<bool> validateRepository(String projectPath) async {
    try {
      // Check if it's a Git repository
      if (!await isGitRepository(projectPath)) {
        return false;
      }
      
      // Check if we can get status (basic Git operations work)
      final status = await getStatus(projectPath);
      return status != null;
    } catch (e) {
      _logger.error('Error validating repository: $e');
      return false;
    }
  }
}