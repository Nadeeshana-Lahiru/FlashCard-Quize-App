import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _appVersion = "1.0.0";
  String _userName = "Flutter Student";
  String _userBio = "Eager to learn new topics!";
  String _userAvatar = "";
  bool _isLoading = true;
  int _currentStreak = 0;
  Map<String, int> _reviewHeatmap = {};

  ThemeMode get themeMode => _themeMode;
  String get appVersion => _appVersion;
  String get userName => _userName;
  String get userBio => _userBio;
  String get userAvatar => _userAvatar;
  bool get isLoading => _isLoading;
  int get currentStreak => _currentStreak;
  Map<String, int> get reviewHeatmap => _reviewHeatmap;

  SettingsProvider() {
    _initSettings();
  }

  Future<void> _initSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Theme
    final themeIndex = prefs.getInt('themeMode');
    if (themeIndex != null && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    }

    _userName = prefs.getString('userName') ?? "Flutter Student";
    _userBio = prefs.getString('userBio') ?? "Eager to learn new topics!";
    _userAvatar = prefs.getString('userAvatar') ?? "";

    // Analytics: Streaks Logic
    String todayString = DateTime.now().toIso8601String().split('T')[0];
    String? lastOpened = prefs.getString('lastOpenedDate');
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    
    if (lastOpened != null) {
      final lastDate = DateTime.parse(lastOpened);
      final todayDate = DateTime.parse(todayString);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 1) {
        _currentStreak++;
      } else if (diff > 1) {
        _currentStreak = 1;
      }
    } else {
      _currentStreak = 1;
    }
    
    await prefs.setString('lastOpenedDate', todayString);
    await prefs.setInt('currentStreak', _currentStreak);

    // Analytics: Heatmap Logic
    final heatmapString = prefs.getString('reviewHeatmap');
    if (heatmapString != null) {
      _reviewHeatmap = Map<String, int>.from(jsonDecode(heatmapString));
    }

    // Load App Version
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = "${packageInfo.version}+${packageInfo.buildNumber}";
    } catch (e) {
      // Fallback if platform fetch fails
      _appVersion = "1.0.0+1"; 
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  Future<void> updateProfile(String name, String bio) async {
    _userName = name;
    _userBio = bio;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userBio', bio);
    notifyListeners();
  }

  Future<void> updateUserAvatar(String avatarUrl) async {
    _userAvatar = avatarUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userAvatar', avatarUrl);
    notifyListeners();
  }

  Future<void> logCardReview() async {
    String todayString = DateTime.now().toIso8601String().split('T')[0];
    _reviewHeatmap[todayString] = (_reviewHeatmap[todayString] ?? 0) + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reviewHeatmap', jsonEncode(_reviewHeatmap));
    notifyListeners();
  }
}
