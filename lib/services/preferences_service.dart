import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> darkMode() async => (await _prefs).getBool('darkMode') ?? false;
  Future<void> setDarkMode(bool value) async =>
      (await _prefs).setBool('darkMode', value);

  Future<String> language() async =>
      (await _prefs).getString('language') ?? 'English';
  Future<void> setLanguage(String value) async =>
      (await _prefs).setString('language', value);

  Future<String> school() async =>
      (await _prefs).getString('school') ?? 'Hanafi';
  Future<void> setSchool(String value) async =>
      (await _prefs).setString('school', value);

  Future<int> lastSurah() async => (await _prefs).getInt('lastSurah') ?? 1;
  Future<void> setLastSurah(int value) async =>
      (await _prefs).setInt('lastSurah', value);

  Future<Set<String>> bookmarks() async =>
      ((await _prefs).getStringList('bookmarks') ?? []).toSet();
  Future<void> toggleBookmark(String key) async {
    final prefs = await _prefs;
    final values = (prefs.getStringList('bookmarks') ?? []).toSet();
    values.contains(key) ? values.remove(key) : values.add(key);
    await prefs.setStringList('bookmarks', values.toList());
  }
}

