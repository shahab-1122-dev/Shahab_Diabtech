import 'package:diabtech/main.dart';
import 'package:diabtech/screens/about_screen/AboutScreen.dart';
import 'package:diabtech/models/settings_model.dart';
import 'package:diabtech/services/settings_service.dart';
import 'package:diabtech/screens/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsModel _settings;

  @override
  void initState() {
    super.initState();
    _settings = SettingsService.getSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.heading2),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          // ── Notifications ──────────────────────────
          _sectionHeader('Notifications'),
          _settingsCard(
            children: [
              _switchTile(
                icon: Icons.notifications_rounded,
                label: 'Push Notifications',
                subtitle: 'Glucose alerts and reminders',
                value: _settings.pushNotifications,
                onChanged: (v) async {
                  await SettingsService.setPushNotifications(v);
                  setState(() => _settings.pushNotifications = v);
                },
                isFirst: true,
                isLast: false,
              ),
              _divider(),
              _switchTile(
                icon: Icons.email_rounded,
                label: 'Email Notifications',
                subtitle: 'Weekly health summary reports',
                value: _settings.emailNotifications,
                onChanged: (v) async {
                  await SettingsService.setEmailNotifications(v);
                  setState(() => _settings.emailNotifications = v);
                },
                isFirst: false,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Appearance ─────────────────────────────
          _sectionHeader('Appearance'),
          _settingsCard(
            children: [
              _switchTile(
                icon: _settings.isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                label: 'Dark Mode',
                subtitle: 'Switch app appearance',
                value: _settings.isDarkMode,
                onChanged: (v) async {
                  await SettingsService.setDarkMode(v);
                  setState(() => _settings.isDarkMode = v);
                  themeNotifier.value = v ? ThemeMode.dark : ThemeMode.light;
                },
                isFirst: true,
                isLast: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Data & Privacy ─────────────────────────
          _sectionHeader('Data & Privacy'),
          _settingsCard(
            children: [
              _navTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Settings',
                subtitle: 'Manage your data preferences',
                isFirst: true,
                isLast: false,
                onTap: () {},
              ),
              _divider(),
              _navTile(
                icon: Icons.security_rounded,
                label: 'Security',
                subtitle: 'App lock and authentication',
                isFirst: false,
                isLast: false,
                onTap: () {},
              ),
              _divider(),
              _navTile(
                icon: Icons.delete_forever_rounded,
                label: 'Clear All Data',
                subtitle: 'Delete all glucose readings',
                isFirst: false,
                isLast: true,
                onTap: () => _showClearDataDialog(),
                isDestructive: true,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── About ──────────────────────────────────
          _sectionHeader('About'),
          _settingsCard(
            children: [
              _navTile(
                icon: Icons.info_outline_rounded,
                label: 'About DiabTech',
                subtitle: 'Version 1.0.0 · Developer info',
                isFirst: true,
                isLast: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                ),
              ),
              _divider(),
              _navTile(
                icon: Icons.star_outline_rounded,
                label: 'Rate the App',
                subtitle: 'Share your feedback',
                isFirst: false,
                isLast: true,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Version footer
          Center(
            child: Text(
              'DiabTech v1.0.0 · Made with Flutter',
              style: AppTextStyles.caption.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────
  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card wrapper ───────────────────────────────────────────────
  Widget _settingsCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.6)),
        boxShadow: AppShadows.card,
      ),
      child: Column(children: children),
    );
  }

  // ── Subtle divider ─────────────────────────────────────────────
  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.border.withOpacity(0.5),
      ),
    );
  }

  // ── Switch tile ────────────────────────────────────────────────
  Widget _switchTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isFirst,
    required bool isLast,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        onTap: () => onChanged(!value),
        splashColor: AppColors.primary.withOpacity(0.06),
        highlightColor: AppColors.primary.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Nav tile ───────────────────────────────────────────────────
  Widget _navTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required bool isFirst,
    required bool isLast,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : AppColors.primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
        splashColor: color.withOpacity(0.06),
        highlightColor: color.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.09),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodyBold.copyWith(
                        fontSize: 14,
                        color: isDestructive ? Colors.red : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textGrey,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Clear data dialog ──────────────────────────────────────────
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your glucose readings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
