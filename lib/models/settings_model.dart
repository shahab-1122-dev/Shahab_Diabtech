import 'package:hive/hive.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 1)
class SettingsModel extends HiveObject {
  @HiveField(0)
  bool isDarkMode;

  @HiveField(1)
  bool pushNotifications;

  @HiveField(2)
  bool emailNotifications;

  @HiveField(3)
  bool privacyMode;

  @HiveField(4)
  bool securityLock;

  SettingsModel({
    this.isDarkMode = false,
    this.pushNotifications = true,
    this.emailNotifications = false,
    this.privacyMode = false,
    this.securityLock = false,
  });
}
