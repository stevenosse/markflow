import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/datasource/models/git_models.dart';

class GitPanel extends StatefulWidget {
  final GitStatus? gitStatus;
  final List<GitCommit> recentCommits;
  final String? currentBranch;
  final Function(String) onStageFile;
  final Function(String) onUnstageFile;
  final Function(String) onCommit;
  final VoidCallback onPush;
  final VoidCallback onPull;
  final VoidCallback onRefresh;

  const GitPanel({
    super.key,
    required this.gitStatus,
    required this.recentCommits,
    required this.currentBranch,
    required this.onStageFile,
    required this.onUnstageFile,
    required this.onCommit,
    required this.onPush,
    required this.onPull,
    required this.onRefresh,
  });

  @override
  State<GitPanel> createState() => _GitPanelState();
}

class _GitPanelState extends State<GitPanel> with TickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _commitMessageController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commitMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          _buildHeader(context),
          const Divider(height: 1),
          _buildTabBar(context),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChangesTab(context),
                _buildHistoryTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Row(
        children: [
          Icon(
            Icons.source,
            size: Dimens.iconSizeS,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: Dimens.halfSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Git',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                if (widget.currentBranch != null)
                  Text(
                    'Branch: ${widget.currentBranch}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                  ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: widget.onPull,
                icon: const Icon(Icons.cloud_download),
                iconSize: Dimens.iconSizeS,
                tooltip: 'Pull',
              ),
              IconButton(
                onPressed: widget.onPush,
                icon: const Icon(Icons.cloud_upload),
                iconSize: Dimens.iconSizeS,
                tooltip: 'Push',
              ),
              IconButton(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh),
                iconSize: Dimens.iconSizeS,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, size: Dimens.iconSizeS),
              const SizedBox(width: Dimens.halfSpacing),
              const Text('Changes'),
              if (widget.gitStatus != null && widget.gitStatus!.hasChanges)
                Container(
                  margin: const EdgeInsets.only(left: Dimens.halfSpacing),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.halfSpacing,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(Dimens.fullRadius),
                  ),
                  child: Text(
                    '${widget.gitStatus!.changes.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
        ),
        Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.history, size: Dimens.iconSizeS),
              const SizedBox(width: Dimens.halfSpacing),
              const Text('History'),
              if (widget.recentCommits.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(left: Dimens.halfSpacing),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimens.halfSpacing,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Dimens.fullRadius),
                  ),
                  child: Text(
                    '${widget.recentCommits.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChangesTab(BuildContext context) {
    if (widget.gitStatus == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!widget.gitStatus!.hasChanges) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: Dimens.iconSizeXL,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'No changes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: Dimens.halfSpacing),
            Text(
              'Your working directory is clean',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (widget.gitStatus!.staged.isNotEmpty) ...[
          _buildSectionHeader(
              context, 'Staged Changes', widget.gitStatus!.staged.length),
          ...widget.gitStatus!.staged.map((change) => _buildFileChangeItem(
                context,
                change,
                isStaged: true,
              )),
          const Divider(),
        ],
        if (widget.gitStatus!.unstaged.isNotEmpty) ...[
          _buildSectionHeader(
              context, 'Unstaged Changes', widget.gitStatus!.unstaged.length),
          ...widget.gitStatus!.unstaged.map((change) => _buildFileChangeItem(
                context,
                change,
                isStaged: false,
              )),
          const Divider(),
        ],
        if (widget.gitStatus!.staged.isNotEmpty) _buildCommitSection(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: Dimens.halfSpacing),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimens.halfSpacing,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(Dimens.fullRadius),
            ),
            child: Text(
              count.toString(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileChangeItem(BuildContext context, GitFileChange change,
      {required bool isStaged}) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: _getStatusColor(context, change.status),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            _getStatusLabel(change.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      title: Text(
        change.filePath,
        style: Theme.of(context).textTheme.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: () {
          if (isStaged) {
            widget.onUnstageFile(change.filePath);
          } else {
            widget.onStageFile(change.filePath);
          }
        },
        icon: Icon(
          isStaged ? Icons.remove : Icons.add,
          size: Dimens.iconSizeS,
        ),
        tooltip: isStaged ? 'Unstage' : 'Stage',
      ),
    );
  }

  Widget _buildCommitSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commit Message',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: Dimens.halfSpacing),
          TextField(
            controller: _commitMessageController,
            decoration: const InputDecoration(
              hintText: 'Enter commit message...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            minLines: 2,
          ),
          const SizedBox(height: Dimens.spacing),
          ListenableBuilder(
            listenable: _commitMessageController,
            builder: (context, child) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _commitMessageController.text.isNotEmpty
                      ? () => widget.onCommit(_commitMessageController.text)
                      : null,
                  child: const Text('Commit'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    if (widget.recentCommits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: Dimens.iconSizeXL,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'No commit history',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: Dimens.halfSpacing),
            Text(
              'Make your first commit to see history',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(Dimens.spacing),
      itemCount: widget.recentCommits.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final commit = widget.recentCommits[index];
        return _buildCommitItem(context, commit);
      },
    );
  }

  Widget _buildCommitItem(BuildContext context, GitCommit commit) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Dimens.halfSpacing),
              Expanded(
                child: Text(
                  commit.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.halfSpacing),
          Row(
            children: [
              const SizedBox(width: 16), // Align with commit dot
              Text(
                commit.author,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
              const SizedBox(width: Dimens.spacing),
              Text(
                _formatDate(commit.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.5),
                    ),
              ),
            ],
          ),
          const SizedBox(height: Dimens.halfSpacing),
          Row(
            children: [
              const SizedBox(width: 16), // Align with commit dot
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimens.halfSpacing,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  commit.hash.substring(0, 7),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontFamily: 'monospace',
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BuildContext context, GitFileStatus status) {
    switch (status) {
      case GitFileStatus.added:
        return Colors.green;
      case GitFileStatus.modified:
        return Colors.orange;
      case GitFileStatus.deleted:
        return Colors.red;
      case GitFileStatus.renamed:
        return Colors.blue;
      case GitFileStatus.copied:
        return Colors.purple;
      case GitFileStatus.untracked || GitFileStatus.unmodified:
        return Colors.grey;
    }
  }

  String _getStatusLabel(GitFileStatus status) {
    switch (status) {
      case GitFileStatus.added:
        return 'A';
      case GitFileStatus.modified:
        return 'M';
      case GitFileStatus.deleted:
        return 'D';
      case GitFileStatus.renamed:
        return 'R';
      case GitFileStatus.copied:
        return 'C';
      case GitFileStatus.untracked || GitFileStatus.unmodified:
        return 'U';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
