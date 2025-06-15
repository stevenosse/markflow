import 'package:flutter/material.dart';
import 'package:markflow/src/core/theme/dimens.dart';

class RenamePopover extends StatefulWidget {
  final String initialValue;
  final String title;
  final String hintText;
  final Function(String) onRename;
  final VoidCallback onCancel;
  final Widget child;

  const RenamePopover({
    super.key,
    required this.initialValue,
    required this.title,
    required this.hintText,
    required this.onRename,
    required this.onCancel,
    required this.child,
  });

  @override
  State<RenamePopover> createState() => _RenamePopoverState();
}

class _RenamePopoverState extends State<RenamePopover> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _buttonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialValue;
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showPopover() {
    _overlayController.show();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    });
  }

  void _hidePopover() {
    _overlayController.hide();
  }

  void _handleRename() {
    final newName = _textController.text.trim();
    if (newName.isNotEmpty && newName != widget.initialValue) {
      widget.onRename(newName);
    }
    _hidePopover();
  }

  void _handleCancel() {
    _textController.text = widget.initialValue;
    widget.onCancel();
    _hidePopover();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (context) {
        return _PopoverContent(
          buttonKey: _buttonKey,
          title: widget.title,
          hintText: widget.hintText,
          textController: _textController,
          focusNode: _focusNode,
          onRename: _handleRename,
          onCancel: _handleCancel,
        );
      },
      child: GestureDetector(
        key: _buttonKey,
        onTap: _showPopover,
        child: widget.child,
      ),
    );
  }
}

class _PopoverContent extends StatelessWidget {
  final GlobalKey buttonKey;
  final String title;
  final String hintText;
  final TextEditingController textController;
  final FocusNode focusNode;
  final VoidCallback onRename;
  final VoidCallback onCancel;

  const _PopoverContent({
    required this.buttonKey,
    required this.title,
    required this.hintText,
    required this.textController,
    required this.focusNode,
    required this.onRename,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox =
        buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final buttonPosition = renderBox.localToGlobal(Offset.zero);
    final buttonSize = renderBox.size;
    final screenSize = MediaQuery.of(context).size;

    // Calculate popover position
    const popoverWidth = 280.0;
    const popoverHeight = 120.0;

    double left = buttonPosition.dx;
    double top = buttonPosition.dy + buttonSize.height + Dimens.quarterSpacing;

    // Adjust horizontal position if popover would go off screen
    if (left + popoverWidth > screenSize.width) {
      left = screenSize.width - popoverWidth - Dimens.spacing;
    }
    if (left < Dimens.spacing) {
      left = Dimens.spacing;
    }

    // Adjust vertical position if popover would go off screen
    if (top + popoverHeight > screenSize.height) {
      top = buttonPosition.dy - popoverHeight - Dimens.quarterSpacing;
    }

    return Stack(
      children: [
        // Backdrop to capture taps outside
        Positioned.fill(
          child: GestureDetector(
            onTap: onCancel,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // Popover content
        Positioned(
          left: left,
          top: top,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(Dimens.radius),
            color: Theme.of(context).colorScheme.surface,
            child: Container(
              width: popoverWidth,
              padding: const EdgeInsets.all(Dimens.spacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: Dimens.halfSpacing),
                  TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: hintText,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    style: Theme.of(context).textTheme.bodyMedium,
                    onSubmitted: (_) => onRename(),
                    onTapOutside: (_) => onCancel(),
                  ),
                  const SizedBox(height: Dimens.halfSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: onCancel,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: Dimens.halfSpacing),
                      ElevatedButton(
                        onPressed: onRename,
                        child: Text('Rename'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
