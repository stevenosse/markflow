import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _editorFontSizeKey = 'editor_font_size';
  static const String _editorLineHeightKey = 'editor_line_height';
  static const String _editorThemeKey = 'editor_theme';
  static const String _autoSaveKey = 'auto_save';
  static const String _wordWrapKey = 'word_wrap';
  static const String _showLineNumbersKey = 'show_line_numbers';
  
  // Default values
  static const double _defaultFontSize = 14.0;
  static const double _defaultLineHeight = 1.5;
  static const double _minFontSize = 8.0;
  static const double _maxFontSize = 32.0;
  static const double _fontSizeStep = 1.0;
  
  SharedPreferences? _prefs;
  
  // Editor settings
  double _editorFontSize = _defaultFontSize;
  double _editorLineHeight = _defaultLineHeight;
  String _editorTheme = 'default';
  bool _autoSave = true;
  bool _wordWrap = true;
  bool _showLineNumbers = false;
  
  // Getters
  double get editorFontSize => _editorFontSize;
  double get editorLineHeight => _editorLineHeight;
  String get editorTheme => _editorTheme;
  bool get autoSave => _autoSave;
  bool get wordWrap => _wordWrap;
  bool get showLineNumbers => _showLineNumbers;
  
  double get minFontSize => _minFontSize;
  double get maxFontSize => _maxFontSize;
  double get fontSizeStep => _fontSizeStep;
  
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    if (_prefs == null) return;
    
    _editorFontSize = _prefs!.getDouble(_editorFontSizeKey) ?? _defaultFontSize;
    _editorLineHeight = _prefs!.getDouble(_editorLineHeightKey) ?? _defaultLineHeight;
    _editorTheme = _prefs!.getString(_editorThemeKey) ?? 'default';
    _autoSave = _prefs!.getBool(_autoSaveKey) ?? true;
    _wordWrap = _prefs!.getBool(_wordWrapKey) ?? true;
    _showLineNumbers = _prefs!.getBool(_showLineNumbersKey) ?? false;
    
    notifyListeners();
  }
  
  Future<void> setEditorFontSize(double fontSize) async {
    if (fontSize < _minFontSize || fontSize > _maxFontSize) return;
    
    _editorFontSize = fontSize;
    await _prefs?.setDouble(_editorFontSizeKey, fontSize);
    notifyListeners();
  }
  
  Future<void> increaseFontSize() async {
    final newSize = (_editorFontSize + _fontSizeStep).clamp(_minFontSize, _maxFontSize);
    await setEditorFontSize(newSize);
  }
  
  Future<void> decreaseFontSize() async {
    final newSize = (_editorFontSize - _fontSizeStep).clamp(_minFontSize, _maxFontSize);
    await setEditorFontSize(newSize);
  }
  
  Future<void> resetFontSize() async {
    await setEditorFontSize(_defaultFontSize);
  }
  
  Future<void> setEditorLineHeight(double lineHeight) async {
    _editorLineHeight = lineHeight;
    await _prefs?.setDouble(_editorLineHeightKey, lineHeight);
    notifyListeners();
  }
  
  Future<void> setEditorTheme(String theme) async {
    _editorTheme = theme;
    await _prefs?.setString(_editorThemeKey, theme);
    notifyListeners();
  }
  
  Future<void> setAutoSave(bool enabled) async {
    _autoSave = enabled;
    await _prefs?.setBool(_autoSaveKey, enabled);
    notifyListeners();
  }
  
  Future<void> setWordWrap(bool enabled) async {
    _wordWrap = enabled;
    await _prefs?.setBool(_wordWrapKey, enabled);
    notifyListeners();
  }
  
  Future<void> setShowLineNumbers(bool enabled) async {
    _showLineNumbers = enabled;
    await _prefs?.setBool(_showLineNumbersKey, enabled);
    notifyListeners();
  }
  
  Future<void> resetToDefaults() async {
    await setEditorFontSize(_defaultFontSize);
    await setEditorLineHeight(_defaultLineHeight);
    await setEditorTheme('default');
    await setAutoSave(true);
    await setWordWrap(true);
    await setShowLineNumbers(false);
  }
}