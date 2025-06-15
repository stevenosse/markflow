import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';

class ProjectSearchBar extends StatefulWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  
  const ProjectSearchBar({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });
  
  @override
  State<ProjectSearchBar> createState() => _ProjectSearchBarState();
}

class _ProjectSearchBarState extends State<ProjectSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  
  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchQuery);
    _focusNode = FocusNode();
  }
  
  @override
  void didUpdateWidget(ProjectSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery && 
        widget.searchQuery != _controller.text) {
      final cursorPosition = _controller.selection.baseOffset;
      _controller.text = widget.searchQuery;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: cursorPosition.clamp(0, widget.searchQuery.length)),
      );
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimens.desktopSearchBarHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Dimens.desktopRadius),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search projects...',
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            size: Dimens.desktopIconSize,
          ),
          suffixIcon: widget.searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSearchChanged('');
                    _focusNode.unfocus();
                  },
                  icon: Icon(
                    Icons.clear,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    size: Dimens.desktopIconSize,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Dimens.spacing,
            vertical: Dimens.halfSpacing,
          ),
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}