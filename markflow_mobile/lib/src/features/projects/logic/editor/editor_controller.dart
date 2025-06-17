import 'package:flutter/material.dart';
import 'package:markflow/src/shared/components/dialogs/replace_dialog.dart';

class EditorController extends ChangeNotifier {
  TextEditingController? _textController;
  FocusNode? _focusNode;
  ScrollController? _scrollController;
  
  String _searchQuery = '';
  List<TextSelection> _searchMatches = [];
  int _currentMatchIndex = -1;
  
  // Getters
  TextEditingController? get textController => _textController;
  FocusNode? get focusNode => _focusNode;
  ScrollController? get scrollController => _scrollController;
  String get searchQuery => _searchQuery;
  List<TextSelection> get searchMatches => _searchMatches;
  int get currentMatchIndex => _currentMatchIndex;
  bool get hasMatches => _searchMatches.isNotEmpty;
  int get totalMatches => _searchMatches.length;
  
  void attachControllers({
    required TextEditingController textController,
    required FocusNode focusNode,
    required ScrollController scrollController,
  }) {
    _textController = textController;
    _focusNode = focusNode;
    _scrollController = scrollController;
  }
  
  void detachControllers() {
    _textController = null;
    _focusNode = null;
    _scrollController = null;
    clearSearch();
  }
  
  // Search functionality
  void setSearchQuery(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      clearSearch();
    } else {
      _findMatches();
    }
    notifyListeners();
  }
  
  void _findMatches() {
    if (_textController == null || _searchQuery.isEmpty) {
      _searchMatches.clear();
      _currentMatchIndex = -1;
      return;
    }
    
    final text = _textController!.text;
    final query = _searchQuery.toLowerCase();
    final matches = <TextSelection>[];
    
    int startIndex = 0;
    while (true) {
      final index = text.toLowerCase().indexOf(query, startIndex);
      if (index == -1) break;
      
      matches.add(TextSelection(
        baseOffset: index,
        extentOffset: index + query.length,
      ));
      
      startIndex = index + 1;
    }
    
    _searchMatches = matches;
    _currentMatchIndex = matches.isNotEmpty ? 0 : -1;
    
    if (_currentMatchIndex >= 0) {
      _highlightCurrentMatch();
    }
  }
  
  void nextMatch() {
    if (_searchMatches.isEmpty) return;
    
    _currentMatchIndex = (_currentMatchIndex + 1) % _searchMatches.length;
    _highlightCurrentMatch();
    notifyListeners();
  }
  
  void previousMatch() {
    if (_searchMatches.isEmpty) return;
    
    _currentMatchIndex = (_currentMatchIndex - 1 + _searchMatches.length) % _searchMatches.length;
    _highlightCurrentMatch();
    notifyListeners();
  }
  
  void _highlightCurrentMatch() {
    if (_textController == null || _currentMatchIndex < 0 || _currentMatchIndex >= _searchMatches.length) {
      return;
    }
    
    final match = _searchMatches[_currentMatchIndex];
    _textController!.selection = match;
    _focusNode?.requestFocus();
    
    // Scroll to the match if possible
    _scrollToSelection(match);
  }
  
  void _scrollToSelection(TextSelection selection) {
    // Basic scroll to selection - could be enhanced with more precise positioning
    if (_scrollController != null && _textController != null) {
      final text = _textController!.text;
      final beforeSelection = text.substring(0, selection.start);
      final lineCount = '\n'.allMatches(beforeSelection).length;
      
      // Rough estimation of line height (could be made more precise)
      const estimatedLineHeight = 24.0;
      final targetOffset = lineCount * estimatedLineHeight;
      
      if (_scrollController!.hasClients) {
        _scrollController!.animateTo(
          targetOffset.clamp(0.0, _scrollController!.position.maxScrollExtent),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    }
  }
  
  void clearSearch() {
    _searchQuery = '';
    _searchMatches.clear();
    _currentMatchIndex = -1;
    notifyListeners();
  }
  
  // Find and Replace functionality
  Future<void> showFindReplaceDialog(BuildContext context) async {
    final result = await ReplaceDialog.show(
      context: context,
      initialFindText: _searchQuery,
    );
    
    if (result != null) {
      await replaceInCurrentFile(result.findText, result.replaceText);
    }
  }
  
  Future<void> replaceInCurrentFile(String findText, String replaceText) async {
    if (_textController == null || findText.isEmpty) return;
    
    final text = _textController!.text;
    final newText = text.replaceAll(findText, replaceText);
    
    if (newText != text) {
      _textController!.text = newText;
      // Clear search after replace
      clearSearch();
      notifyListeners();
    }
  }
  
  // Go to line functionality
  void goToLine(int lineNumber) {
    if (_textController == null || _scrollController == null) return;
    
    final text = _textController!.text;
    final lines = text.split('\n');
    
    if (lineNumber < 1 || lineNumber > lines.length) return;
    
    // Calculate the character offset for the target line
    int offset = 0;
    for (int i = 0; i < lineNumber - 1; i++) {
      offset += lines[i].length + 1; // +1 for the newline character
    }
    
    // Set cursor to the beginning of the target line
    _textController!.selection = TextSelection.collapsed(offset: offset);
    _focusNode?.requestFocus();
    
    // Scroll to the line
    const estimatedLineHeight = 24.0;
    final targetOffset = (lineNumber - 1) * estimatedLineHeight;
    
    if (_scrollController!.hasClients) {
      _scrollController!.animateTo(
        targetOffset.clamp(0.0, _scrollController!.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  int getCurrentLineCount() {
    if (_textController == null) return 0;
    return _textController!.text.split('\n').length;
  }
  
  // Line manipulation
  void duplicateCurrentLine() {
    if (_textController == null) return;
    
    final text = _textController!.text;
    final selection = _textController!.selection;
    
    if (!selection.isValid) return;
    
    final lines = text.split('\n');
    int currentLineIndex = 0;
    int charCount = 0;
    
    // Find which line the cursor is on
    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length >= selection.start) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1; // +1 for newline
    }
    
    if (currentLineIndex < lines.length) {
      final currentLine = lines[currentLineIndex];
      lines.insert(currentLineIndex + 1, currentLine);
      
      final newText = lines.join('\n');
      _textController!.text = newText;
      
      // Move cursor to the duplicated line
      final newOffset = charCount + currentLine.length + 1;
      _textController!.selection = TextSelection.collapsed(offset: newOffset);
      
      notifyListeners();
    }
  }
  
  void toggleCommentOnCurrentLine() {
    if (_textController == null) return;
    
    final text = _textController!.text;
    final selection = _textController!.selection;
    
    if (!selection.isValid) return;
    
    final lines = text.split('\n');
    int currentLineIndex = 0;
    int charCount = 0;
    
    // Find which line the cursor is on
    for (int i = 0; i < lines.length; i++) {
      if (charCount + lines[i].length >= selection.start) {
        currentLineIndex = i;
        break;
      }
      charCount += lines[i].length + 1; // +1 for newline
    }
    
    if (currentLineIndex < lines.length) {
      final currentLine = lines[currentLineIndex];
      final trimmedLine = currentLine.trimLeft();
      
      String newLine;
      int cursorOffset = 0;
      
      if (trimmedLine.startsWith('<!-- ') && trimmedLine.endsWith(' -->')) {
        // Remove comment
        newLine = currentLine.replaceFirst('<!-- ', '').replaceFirst(' -->', '');
        cursorOffset = -7; // Adjust cursor position
      } else {
        // Add comment
        final leadingSpaces = currentLine.length - trimmedLine.length;
        final spaces = ' ' * leadingSpaces;
        newLine = '$spaces<!-- ${trimmedLine.isEmpty ? '' : trimmedLine} -->';
        cursorOffset = 5; // Adjust cursor position
      }
      
      lines[currentLineIndex] = newLine;
      final newText = lines.join('\n');
      _textController!.text = newText;
      
      // Adjust cursor position
      final newCursorPos = (selection.start + cursorOffset).clamp(0, newText.length);
      _textController!.selection = TextSelection.collapsed(offset: newCursorPos);
      
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    detachControllers();
    super.dispose();
  }
}