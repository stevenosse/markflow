import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markflow/src/core/theme/dimens.dart';
import 'package:markflow/src/shared/extensions/context_extensions.dart';

class MarkdownPreview extends StatelessWidget {
  final String content;
  final String fileName;

  const MarkdownPreview({
    super.key,
    required this.content,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPreviewHeader(context),
          const Divider(height: 1),
          Expanded(
            child: _buildPreview(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimens.spacing),
      child: Row(
        children: [
          Icon(
            Icons.visibility,
            size: Dimens.iconSizeS,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: Dimens.halfSpacing),
          Expanded(
            child: Text(
              'Preview - $fileName',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (content.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.preview,
              size: Dimens.iconSizeXL,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: Dimens.spacing),
            Text(
              'Nothing to preview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: Dimens.halfSpacing),
            Text(
              'Start typing in the editor to see the preview',
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

    return Padding(
      padding: const EdgeInsets.all(Dimens.editorPadding),
      child: Markdown(
        data: content,
        styleSheet: MarkdownStyleSheet(
          h1: context.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
          h2: context.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
          h3: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.2,
          ),
          p: context.textTheme.bodyLarge?.copyWith(
            height: 1.6,
            letterSpacing: 0.2,
          ),
          listBullet: context.textTheme.bodyLarge?.copyWith(
            height: 1.6,
          ),
          blockquote: context.textTheme.bodyLarge?.copyWith(
            fontStyle: FontStyle.italic,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          code: context.textTheme.bodyMedium?.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
    );
  }
}
