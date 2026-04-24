import 'package:diabtech/models/settings_model.dart';
import 'package:hive/hive.dart';


class SettingsService {
  static const String _boxName = 'settingsBox';
  static const String _key = 'settings';

  // Get the box
  static Box<SettingsModel> get _box =>
      Hive.box<SettingsModel>(_boxName);

  // Get current settings — creates defaults if first launch
  static SettingsModel getSettings() {
    final settings = _box.get(_key);
    if (settings == null) {
     final defaults = SettingsModel();
      _box.put(_key, defaults);
      return defaults;
    }
    return settings;
  }

  // Save entire settings object
  static Future<void> saveSettings(SettingsModel settings) async {
    await _box.put(_key, settings);
  }

  // Update individual fields
  static Future<void> setDarkMode(bool value) async {
    final s = getSettings();
    s.isDarkMode = value;
    await s.save();
  }

  static Future<void> setPushNotifications(bool value) async {
    final s = getSettings();
    s.pushNotifications = value;
    await s.save();
  }

  static Future<void> setEmailNotifications(bool value) async {
    final s = getSettings();
    s.emailNotifications = value;
    await s.save();
  }

  static Future<void> setPrivacyMode(bool value) async {
    final s = getSettings();
    s.privacyMode = value;
    await s.save();
  }

  static Future<void> setSecurityLock(bool value) async {
    final s = getSettings();
    s.securityLock = value;
    await s.save();
  }
}