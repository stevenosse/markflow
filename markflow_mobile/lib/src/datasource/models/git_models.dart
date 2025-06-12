import 'package:equatable/equatable.dart';

/// Represents a Git commit
class GitCommit extends Equatable {
  /// Commit hash (SHA)
  final String hash;
  
  /// Short commit hash (first 7 characters)
  final String shortHash;
  
  /// Commit message
  final String message;
  
  /// Author name
  final String author;
  
  /// Author email
  final String authorEmail;
  
  /// Commit timestamp
  final DateTime timestamp;
  
  /// List of files changed in this commit
  final List<String> changedFiles;

  const GitCommit({
    required this.hash,
    required this.shortHash,
    required this.message,
    required this.author,
    required this.authorEmail,
    required this.timestamp,
    required this.changedFiles,
  });
  
  @override
  List<Object?> get props => [
    hash, 
    shortHash, 
    message, 
    author, 
    authorEmail, 
    timestamp, 
    changedFiles
  ];
}

/// Represents a Git branch
class GitBranch extends Equatable {
  /// Branch name
  final String name;
  
  /// Whether this is the current branch
  final bool isCurrent;
  
  /// Whether this is a remote branch
  final bool isRemote;
  
  /// Last commit on this branch
  final GitCommit? lastCommit;

  const GitBranch({
    required this.name,
    required this.isCurrent,
    this.isRemote = false,
    this.lastCommit,
  });
  
  @override
  List<Object?> get props => [name, isCurrent, isRemote, lastCommit];
}

/// Represents the status of a file in Git
enum GitFileStatus {
  /// File is untracked
  untracked,
  
  /// File is modified
  modified,
  
  /// File is added/staged
  added,
  
  /// File is deleted
  deleted,
  
  /// File is renamed
  renamed,
  
  /// File is copied
  copied,
  
  /// File is unmodified
  unmodified,
}

/// Represents a file change in Git
class GitFileChange extends Equatable {
  /// File path relative to repository root
  final String filePath;
  
  /// Status of the file
  final GitFileStatus status;
  
  /// Whether the file is staged
  final bool isStaged;
  
  /// Old file path (for renames)
  final String? oldFilePath;

  const GitFileChange({
    required this.filePath,
    required this.status,
    required this.isStaged,
    this.oldFilePath,
  });
  
  @override
  List<Object?> get props => [filePath, status, isStaged, oldFilePath];
}

/// Represents the current Git repository status
class GitStatus extends Equatable {
  /// Current branch name
  final String currentBranch;
  
  /// List of file changes
  final List<GitFileChange> changes;
  
  /// Number of commits ahead of remote
  final int aheadCount;
  
  /// Number of commits behind remote
  final int behindCount;
  
  /// Whether there are uncommitted changes
  final bool hasUncommittedChanges;
  
  /// Whether the repository is clean (no changes)
  final bool isClean;

  const GitStatus({
    required this.currentBranch,
    required this.changes,
    this.aheadCount = 0,
    this.behindCount = 0,
    required this.hasUncommittedChanges,
    required this.isClean,
  });
  
  /// List of staged changes
  List<GitFileChange> get staged => changes.where((c) => c.isStaged).toList();

  /// List of unstaged changes
  List<GitFileChange> get unstaged => changes.where((c) => !c.isStaged).toList();

  /// Whether there are any changes (staged or unstaged)
  bool get hasChanges => changes.isNotEmpty;

  @override
  List<Object?> get props => [
    currentBranch, 
    changes, 
    aheadCount, 
    behindCount, 
    hasUncommittedChanges, 
    isClean
  ];
}

/// Represents a Git remote
class GitRemote extends Equatable {
  /// Remote name (e.g., 'origin')
  final String name;
  
  /// Remote URL
  final String url;
  
  /// Whether this is the default remote
  final bool isDefault;

  const GitRemote({
    required this.name,
    required this.url,
    this.isDefault = false,
  });
  
  @override
  List<Object?> get props => [name, url, isDefault];
}