import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/expression.dart';

class HistoryEntry {
  const HistoryEntry(this.expression, this.result);
  final String expression;
  final String result;
}

/// App-wide preferences and calculation history, persisted on device.
class AppSettings extends ChangeNotifier {
  AppSettings(this._prefs) {
    final code = _prefs.getString(_kLanguage);
    _languageCode = code;
    _themeMode = ThemeMode.values[_prefs.getInt(_kTheme) ?? ThemeMode.system.index];
    _angleMode = AngleMode.values[_prefs.getInt(_kAngle) ?? AngleMode.degrees.index];
    _scientific = _prefs.getBool(_kScientific) ?? false;
    final raw = _prefs.getStringList(_kHistory) ?? const [];
    _history = [
      for (final line in raw)
        if (line.contains('\n')) HistoryEntry(line.split('\n')[0], line.split('\n')[1]),
    ];
  }

  static Future<AppSettings> load() async => AppSettings(await SharedPreferences.getInstance());

  static const _kLanguage = 'language';
  static const _kTheme = 'theme';
  static const _kAngle = 'angle';
  static const _kScientific = 'scientific';
  static const _kHistory = 'history';
  static const maxHistory = 100;

  final SharedPreferences _prefs;

  String? _languageCode;
  late ThemeMode _themeMode;
  late AngleMode _angleMode;
  late bool _scientific;
  late List<HistoryEntry> _history;

  /// null means "follow the device language".
  String? get languageCode => _languageCode;
  Locale? get locale => _languageCode == null ? null : Locale(_languageCode!);
  ThemeMode get themeMode => _themeMode;
  AngleMode get angleMode => _angleMode;
  bool get scientific => _scientific;
  List<HistoryEntry> get history => List.unmodifiable(_history);

  void setLanguage(String? code) {
    _languageCode = code;
    if (code == null) {
      _prefs.remove(_kLanguage);
    } else {
      _prefs.setString(_kLanguage, code);
    }
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _prefs.setInt(_kTheme, mode.index);
    notifyListeners();
  }

  void setAngleMode(AngleMode mode) {
    _angleMode = mode;
    _prefs.setInt(_kAngle, mode.index);
    notifyListeners();
  }

  void setScientific(bool value) {
    _scientific = value;
    _prefs.setBool(_kScientific, value);
    notifyListeners();
  }

  /// Stores raw (dot-decimal) expression and result, newest first.
  void addHistory(String expression, String result) {
    if (_history.isNotEmpty && _history.first.expression == expression) return;
    _history.insert(0, HistoryEntry(expression, result));
    if (_history.length > maxHistory) _history.removeLast();
    _saveHistory();
  }

  void clearHistory() {
    _history.clear();
    _saveHistory();
  }

  void _saveHistory() {
    _prefs.setStringList(_kHistory, [for (final e in _history) '${e.expression}\n${e.result}']);
    notifyListeners();
  }
}

/// Gives widgets access to [AppSettings] and rebuilds them when it changes.
class SettingsScope extends InheritedNotifier<AppSettings> {
  const SettingsScope({super.key, required AppSettings settings, required super.child})
      : super(notifier: settings);

  static AppSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SettingsScope>()!.notifier!;
}
