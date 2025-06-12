import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:markflow/src/datasource/models/git_models.dart';
import 'package:markflow/src/shared/locator.dart';
import 'package:markflow/src/shared/services/app_logger.dart';

/// Service for handling Git operations using command line interface
class GitService {
  final AppLogger _logger;
  
  GitService({
    AppLogger? logger,
  }) : _logger = logger ?? locator<AppLogger>();
  
  /// Initialize a new Git repository in the given directory
  /// Returns true if successful or if gracefully handled sandbox restrictions
  Future<bool> init(String path) async {
    try {
      // Check if directory exists
      final directory = Directory(path);
      if (!await directory.exists()) {
        _logger.error('Directory does not exist: $path');
        return false;
      }
      
      // Attempt to initialize Git repository
      final result = await Process.run(
        'git',
        ['init'],
        workingDirectory: path,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Git repository initialized at $path');
        return true;
      } else {
        // Handle sandbox restrictions gracefully
        if (result.stderr.toString().contains('Operation not permitted')) {
          _logger.info('Git initialization skipped due to sandbox restrictions at $path');
          // Return true to allow project creation to continue without Git
          return true;
        } else {
          _logger.error('Failed to initialize Git repository: ${result.stderr}');
          return false;
        }
      }
    } catch (e) {
      // Handle ProcessException gracefully
      if (e is ProcessException && e.message.contains('Operation not permitted')) {
        _logger.info('Git initialization skipped due to sandbox restrictions at $path');
        // Return true to allow project creation to continue without Git
        return true;
      }
      _logger.error('Error initializing Git repository: $e');
      return false;
    }
  }
  
  /// Clone a repository from the given URL to the specified path
  /// Returns true if successful or if gracefully handled sandbox restrictions
  Future<bool> clone({
    required String remoteUrl,
    required String localPath,
    String? branch,
  }) async {
    try {
      // Ensure parent directory exists
      final parentDir = Directory(path.dirname(localPath));
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }
      
      final args = ['clone'];
      if (branch != null) {
        args.addAll(['-b', branch]);
      }
      args.addAll([remoteUrl, localPath]);
      
      final result = await Process.run('git', args);
      
      if (result.exitCode == 0) {
        _logger.info('Repository cloned from $remoteUrl to $localPath');
        return true;
      } else {
        // Handle sandbox restrictions gracefully
        if (result.stderr.toString().contains('Operation not permitted')) {
          _logger.info('Git clone skipped due to sandbox restrictions. Creating empty directory at $localPath');
          // Create the directory manually since clone failed
          final directory = Directory(localPath);
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
          return true;
        } else {
          _logger.error('Failed to clone repository: ${result.stderr}');
          return false;
        }
      }
    } catch (e) {
      // Handle ProcessException gracefully
      if (e is ProcessException && e.message.contains('Operation not permitted')) {
        _logger.info('Git clone skipped due to sandbox restrictions. Creating empty directory at $localPath');
        // Create the directory manually since clone failed
        final directory = Directory(localPath);
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        return true;
      }
      _logger.error('Error cloning repository: $e');
      return false;
    }
  }
  
  /// Get the current status of the repository
  Future<GitStatus?> getStatus(String repositoryPath) async {
    try {
      // Get current branch
      final branchResult = await Process.run(
        'git',
        ['branch', '--show-current'],
        workingDirectory: repositoryPath,
      );
      
      if (branchResult.exitCode != 0) {
        _logger.error('Failed to get current branch: ${branchResult.stderr}');
        return null;
      }
      
      final currentBranch = (branchResult.stdout as String).trim();
      
      // Get status
      final statusResult = await Process.run(
        'git',
        ['status', '--porcelain'],
        workingDirectory: repositoryPath,
      );
      
      if (statusResult.exitCode != 0) {
        _logger.error('Failed to get git status: ${statusResult.stderr}');
        return null;
      }
      
      final statusOutput = statusResult.stdout as String;
      final changes = _parseStatusOutput(statusOutput);
      
      return GitStatus(
        currentBranch: currentBranch,
        changes: changes,
        hasUncommittedChanges: changes.isNotEmpty,
        isClean: changes.isEmpty,
      );
    } catch (e) {
      _logger.error('Error getting git status: $e');
      return null;
    }
  }
  
  /// Stage all changes
  Future<bool> addAll(String repositoryPath) async {
    try {
      final result = await Process.run(
        'git',
        ['add', '.'],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('All changes staged successfully');
        return true;
      } else {
        _logger.error('Failed to stage changes: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error staging changes: $e');
      return false;
    }
  }
  
  /// Stage specific files
  Future<bool> addFiles(String repositoryPath, List<String> filePaths) async {
    try {
      final result = await Process.run(
        'git',
        ['add', ...filePaths],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Files staged successfully: ${filePaths.join(", ")}');
        return true;
      } else {
        _logger.error('Failed to stage files: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error staging files: $e');
      return false;
    }
  }
  
  /// Commit staged changes with a message
  Future<bool> commit(String repositoryPath, String message) async {
    try {
      final result = await Process.run(
        'git',
        ['commit', '-m', message],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Commit created successfully: $message');
        return true;
      } else {
        _logger.error('Failed to commit: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error creating commit: $e');
      return false;
    }
  }
  
  /// Push changes to remote repository
  Future<bool> push(String repositoryPath, {String? remote, String? branch}) async {
    try {
      final args = ['push'];
      if (remote != null) args.add(remote);
      if (branch != null) args.add(branch);
      
      final result = await Process.run(
        'git',
        args,
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Push completed successfully');
        return true;
      } else {
        _logger.error('Failed to push: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error pushing changes: $e');
      return false;
    }
  }
  
  /// Pull changes from remote repository
  Future<bool> pull(String repositoryPath, {String? remote, String? branch}) async {
    try {
      final args = ['pull'];
      if (remote != null) args.add(remote);
      if (branch != null) args.add(branch);
      
      final result = await Process.run(
        'git',
        args,
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Pull completed successfully');
        return true;
      } else {
        _logger.error('Failed to pull: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error pulling changes: $e');
      return false;
    }
  }
  
  /// Get commit history
  Future<List<GitCommit>> getCommitHistory(String repositoryPath, {int? limit, String? branch}) async {
    try {
      final result = await Process.run(
        'git',
        [
          'log',
          '--pretty=format:%H|%h|%s|%an|%ae|%at',
          '-n',
          (limit ?? 50).toString(),
        ],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode != 0) {
        _logger.error('Failed to get commit history: ${result.stderr}');
        return [];
      }
      
      final output = result.stdout as String;
      return _parseCommitHistory(output);
    } catch (e) {
      _logger.error('Error getting commit history: $e');
      return [];
    }
  }
  
  /// Get list of branches
  Future<List<GitBranch>> getBranches(String repositoryPath) async {
    try {
      final result = await Process.run(
        'git',
        ['branch', '-a'],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode != 0) {
        _logger.error('Failed to get branches: ${result.stderr}');
        return [];
      }
      
      final output = result.stdout as String;
      return _parseBranches(output);
    } catch (e) {
      _logger.error('Error getting branches: $e');
      return [];
    }
  }
  
  /// Switch to a different branch
  Future<bool> switchBranch(String repositoryPath, String branchName) async {
    try {
      final result = await Process.run(
        'git',
        ['checkout', branchName],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Switched to branch $branchName');
        return true;
      } else {
        _logger.error('Failed to switch branch: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error switching branch: $e');
      return false;
    }
  }
  
  /// Parse git status output into GitFileChange objects
  List<GitFileChange> _parseStatusOutput(String output) {
    final changes = <GitFileChange>[];
    final lines = output.split('\n').where((line) => line.isNotEmpty);
    
    for (final line in lines) {
      if (line.length < 3) continue;
      
      final statusCode = line.substring(0, 2);
      final filePath = line.substring(3);
      
      GitFileStatus status;
      bool isStaged = false;
      
      switch (statusCode[0]) {
        case 'A':
          status = GitFileStatus.added;
          isStaged = true;
          break;
        case 'M':
          status = GitFileStatus.modified;
          isStaged = true;
          break;
        case 'D':
          status = GitFileStatus.deleted;
          isStaged = true;
          break;
        case 'R':
          status = GitFileStatus.renamed;
          isStaged = true;
          break;
        case 'C':
          status = GitFileStatus.copied;
          isStaged = true;
          break;
        case '?':
          status = GitFileStatus.untracked;
          break;
        default:
          if (statusCode[1] == 'M') {
            status = GitFileStatus.modified;
          } else if (statusCode[1] == 'D') {
            status = GitFileStatus.deleted;
          } else {
            status = GitFileStatus.unmodified;
          }
      }
      
      changes.add(GitFileChange(
        filePath: filePath,
        status: status,
        isStaged: isStaged,
      ));
    }
    
    return changes;
  }
  
  /// Parse git log output into GitCommit objects
  List<GitCommit> _parseCommitHistory(String output) {
    final commits = <GitCommit>[];
    final lines = output.split('\n').where((line) => line.isNotEmpty);
    
    for (final line in lines) {
      final parts = line.split('|');
      if (parts.length != 6) continue;
      
      final timestamp = DateTime.fromMillisecondsSinceEpoch(
        int.parse(parts[5]) * 1000,
      );
      
      commits.add(GitCommit(
        hash: parts[0],
        shortHash: parts[1],
        message: parts[2],
        author: parts[3],
        authorEmail: parts[4],
        timestamp: timestamp,
        changedFiles: [], // TODO: Get changed files if needed
      ));
    }
    
    return commits;
  }
  
  /// Parse git branch output into GitBranch objects
  List<GitBranch> _parseBranches(String output) {
    final branches = <GitBranch>[];
    final lines = output.split('\n').where((line) => line.isNotEmpty);
    
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      
      final isCurrent = trimmed.startsWith('*');
      final isRemote = trimmed.contains('remotes/');
      
      String name = trimmed;
      if (isCurrent) {
        name = name.substring(1).trim();
      }
      if (isRemote) {
        name = name.replaceFirst('remotes/', '');
      }
      
      branches.add(GitBranch(
        name: name,
        isCurrent: isCurrent && !isRemote,
        isRemote: isRemote,
      ));
    }
    
    return branches;
  }
  
  /// Reset files (unstage)
  Future<bool> resetFiles(String repositoryPath, List<String> filePaths) async {
    try {
      final result = await Process.run(
        'git',
        ['reset', 'HEAD', ...filePaths],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Files unstaged successfully');
        return true;
      } else {
        _logger.error('Failed to unstage files: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error unstaging files: $e');
      return false;
    }
  }
  
  /// Get current branch
  Future<String?> getCurrentBranch(String repositoryPath) async {
    try {
      final result = await Process.run(
        'git',
        ['branch', '--show-current'],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode != 0) {
        _logger.error('Failed to get current branch: ${result.stderr}');
        return null;
      }
      
      return (result.stdout as String).trim();
    } catch (e) {
      _logger.error('Error getting current branch: $e');
      return null;
    }
  }
  
  /// Create a new branch
  Future<bool> createBranch(String repositoryPath, String branchName) async {
    try {
      final result = await Process.run(
        'git',
        ['branch', branchName],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Branch created: $branchName');
        return true;
      } else {
        _logger.error('Failed to create branch: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error creating branch: $e');
      return false;
    }
  }
  
  /// Delete a branch
  Future<bool> deleteBranch(String repositoryPath, String branchName) async {
    try {
      final result = await Process.run(
        'git',
        ['branch', '-d', branchName],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Branch deleted: $branchName');
        return true;
      } else {
        _logger.error('Failed to delete branch: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error deleting branch: $e');
      return false;
    }
  }
  
  /// Get remote repositories
  Future<List<GitRemote>> getRemotes(String repositoryPath) async {
    try {
      final result = await Process.run(
        'git',
        ['remote', '-v'],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode != 0) {
        _logger.error('Failed to get remotes: ${result.stderr}');
        return [];
      }
      
      final output = result.stdout as String;
      final remotes = <GitRemote>[];
      final lines = output.split('\n').where((line) => line.isNotEmpty);
      final processedNames = <String>{};
      
      for (final line in lines) {
        final parts = line.trim().split('\t');
        if (parts.length != 2) continue;
        
        final name = parts[0];
        if (processedNames.contains(name)) continue;
        
        final urlParts = parts[1].split(' ');
        if (urlParts.isEmpty) continue;
        
        final url = urlParts[0];
        remotes.add(GitRemote(name: name, url: url));
        processedNames.add(name);
      }
      
      return remotes;
    } catch (e) {
      _logger.error('Error getting remotes: $e');
      return [];
    }
  }
  
  /// Add a remote repository
  Future<bool> addRemote(String repositoryPath, String name, String url) async {
    try {
      final result = await Process.run(
        'git',
        ['remote', 'add', name, url],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Remote added: $name -> $url');
        return true;
      } else {
        _logger.error('Failed to add remote: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error adding remote: $e');
      return false;
    }
  }
  
  /// Remove a remote repository
  Future<bool> removeRemote(String repositoryPath, String name) async {
    try {
      final result = await Process.run(
        'git',
        ['remote', 'remove', name],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Remote removed: $name');
        return true;
      } else {
        _logger.error('Failed to remove remote: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error removing remote: $e');
      return false;
    }
  }
  
  /// Check if directory is a Git repository
  Future<bool> isGitRepository(String repositoryPath) async {
    try {
      final result = await Process.run(
        'git',
        ['rev-parse', '--is-inside-work-tree'],
        workingDirectory: repositoryPath,
      );
      
      return result.exitCode == 0 && (result.stdout as String).trim() == 'true';
    } catch (e) {
      _logger.error('Error checking if Git repository: $e');
      return false;
    }
  }
  
  /// Get file diff
  Future<String?> getFileDiff(
    String repositoryPath,
    String filePath, {
    String? fromCommit,
    String? toCommit,
  }) async {
    try {
      final args = ['diff'];
      
      if (fromCommit != null && toCommit != null) {
        args.add('$fromCommit..$toCommit');
      }
      
      args.add('--');
      args.add(filePath);
      
      final result = await Process.run(
        'git',
        args,
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode != 0) {
        _logger.error('Failed to get file diff: ${result.stderr}');
        return null;
      }
      
      return result.stdout as String;
    } catch (e) {
      _logger.error('Error getting file diff: $e');
      return null;
    }
  }
  
  /// Discard changes in working directory
  Future<bool> discardChanges(String repositoryPath, List<String> filePaths) async {
    try {
      final result = await Process.run(
        'git',
        ['checkout', '--', ...filePaths],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Changes discarded successfully');
        return true;
      } else {
        _logger.error('Failed to discard changes: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error discarding changes: $e');
      return false;
    }
  }
  
  /// Get repository configuration
  Future<Map<String, String>> getConfig(String repositoryPath) async {
    try {
      final result = await Process.run(
        'git',
        ['config', '--list'],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode != 0) {
        _logger.error('Failed to get Git config: ${result.stderr}');
        return {};
      }
      
      final output = result.stdout as String;
      final config = <String, String>{};
      final lines = output.split('\n').where((line) => line.isNotEmpty);
      
      for (final line in lines) {
        final parts = line.split('=');
        if (parts.length != 2) continue;
        
        config[parts[0]] = parts[1];
      }
      
      return config;
    } catch (e) {
      _logger.error('Error getting Git config: $e');
      return {};
    }
  }
  
  /// Set repository configuration
  Future<bool> setConfig(String repositoryPath, String key, String value) async {
    try {
      final result = await Process.run(
        'git',
        ['config', key, value],
        workingDirectory: repositoryPath,
      );
      
      if (result.exitCode == 0) {
        _logger.info('Git config set: $key = $value');
        return true;
      } else {
        _logger.error('Failed to set Git config: ${result.stderr}');
        return false;
      }
    } catch (e) {
      _logger.error('Error setting Git config: $e');
      return false;
    }
  }
}