
import 'package:diabtech/screens/setting_screen/SettingsScreen.dart';
import 'package:diabtech/models/glucose_model.dart';

import 'package:diabtech/screens/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late Box<GlucoseModel> glucoseBox;
  late Box userBox;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _diabetesType = 'Type 2';

  @override
  void initState() {
    super.initState();
    glucoseBox = Hive.box<GlucoseModel>('glucoseBox');
    userBox = Hive.box('userBox');
    _nameController.text = userBox.get('name', defaultValue: 'Your Name');
    _ageController.text = userBox.get('age', defaultValue: '');
    _diabetesType = userBox.get('diabetesType', defaultValue: 'Type 2');

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Real computed stats ────────────────────────────────────────
  int get _totalReadings => glucoseBox.length;

  double get _avgGlucose {
    if (glucoseBox.isEmpty) return 0;
    final sum = glucoseBox.values.fold<double>(0, (p, e) => p + e.value);
    return sum / glucoseBox.length;
  }

  int get _timeInRange {
    if (glucoseBox.isEmpty) return 0;
    final inRange = glucoseBox.values
        .where((e) => e.value >= 70 && e.value <= 180)
        .length;
    return ((inRange / glucoseBox.length) * 100).round();
  }

  int get _readingStreak {
    if (glucoseBox.isEmpty) return 0;
    final now = DateTime.now();
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final has = glucoseBox.values.any((e) {
        final d = e.dateTime;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      });
      if (has) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  String get _lastUpdated {
    if (glucoseBox.isEmpty) return 'No readings yet';
    final last = glucoseBox.values.last.dateTime;
    final diff = DateTime.now().difference(last);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(last);
  }

  String get _glucoseStatus {
    if (glucoseBox.isEmpty) return 'No data';
    final last = glucoseBox.values.last.value;
    if (last < 70) return 'Low';
    if (last <= 180) return 'Stable';
    return 'High';
  }

  Color get _glucoseStatusColor {
    if (glucoseBox.isEmpty) return AppColors.textGrey;
    final last = glucoseBox.values.last.value;
    if (last < 70) return Colors.blue;
    if (last <= 180) return AppColors.success;
    return Colors.red;
  }

  // ── Edit profile bottom sheet ──────────────────────────────────
  void _showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Edit Profile', style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Text(
              'Your info is stored locally on your device.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 24),

            _sheetLabel('Full Name'),
            const SizedBox(height: 8),
            _sheetField(
              controller: _nameController,
              hint: 'Enter your name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),

            _sheetLabel('Age'),
            const SizedBox(height: 8),
            _sheetField(
              controller: _ageController,
              hint: 'Enter your age',
              icon: Icons.cake_outlined,
              keyboard: TextInputType.number,
            ),

            const SizedBox(height: 16),

            _sheetLabel('Diabetes Type'),
            const SizedBox(height: 10),
            StatefulBuilder(
              builder: (context, setLocal) => Wrap(
                spacing: 8,
                children: ['Type 1', 'Type 2', 'Pre-Diabetes'].map((type) {
                  final selected = _diabetesType == type;
                  return GestureDetector(
                    onTap: () => setLocal(() => _diabetesType = type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        type,
                        style: AppTextStyles.caption.copyWith(
                          color: selected ? Colors.white : AppColors.textGrey,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Save Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  await userBox.put('name', _nameController.text);
                  await userBox.put('age', _ageController.text);
                  await userBox.put('diabetesType', _diabetesType);
                  setState(() {});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      content: const Text('Profile saved ✅'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final name = userBox.get('name', defaultValue: 'Your Name') as String;
    final age = userBox.get('age', defaultValue: '') as String;
    final diabetesType =
        userBox.get('diabetesType', defaultValue: 'Type 2') as String;
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : 'YN';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profile', style: AppTextStyles.heading2),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _showEditProfile,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: glucoseBox.listenable(),
        builder: (context, Box<GlucoseModel> box, _) {
          return FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero profile card ──────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.18),
                          Colors.white,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary.withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Name + info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: AppTextStyles.heading2),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _infoPill(diabetesType, AppColors.primary),
                                  if (age.isNotEmpty)
                                    _infoPill('Age $age', AppColors.textGrey),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _glucoseStatusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '$_glucoseStatus · Updated $_lastUpdated',
                                    style: AppTextStyles.caption.copyWith(
                                      color: _glucoseStatusColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Stats grid ────────────────────────────────
                  Text('Your Stats', style: AppTextStyles.heading3),
                  const SizedBox(height: 12),

                  // Avg glucose — hero stat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.show_chart_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Average Glucose',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _avgGlucose == 0
                                  ? '-- mg/dL'
                                  : '${_avgGlucose.toStringAsFixed(0)} mg/dL',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 3 supporting stats
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.water_drop_rounded,
                          label: 'Readings',
                          value: '$_totalReadings',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.track_changes_rounded,
                          label: 'In Range',
                          value: '$_timeInRange%',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Streak',
                          value: '${_readingStreak}d',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Recent readings ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Readings', style: AppTextStyles.heading3),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'View All',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  glucoseBox.isEmpty
                      ? Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.water_drop_outlined,
                                size: 40,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'No readings yet',
                                style: AppTextStyles.bodyBold,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add your first glucose reading to see history here.',
                                style: AppTextStyles.caption,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            children: () {
                              final recent = glucoseBox.values
                                  .toList()
                                  .reversed
                                  .take(3)
                                  .toList();
                              return recent.asMap().entries.map((e) {
                                final g = e.value;
                                final isLast = e.key == recent.length - 1;
                                final color = g.value < 70
                                    ? Colors.blue
                                    : g.value <= 180
                                    ? AppColors.success
                                    : Colors.red;
                                final status = g.value < 70
                                    ? 'Low'
                                    : g.value <= 180
                                    ? 'Normal'
                                    : 'High';
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 14,
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 42,
                                            height: 42,
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.water_drop_rounded,
                                              color: color,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${g.value.toStringAsFixed(1)} mg/dL',
                                                  style: AppTextStyles.bodyBold,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  g.readingType.isNotEmpty
                                                      ? g.readingType
                                                      : 'Reading',
                                                  style: AppTextStyles.caption,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 3,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: color.withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(99),
                                                ),
                                                child: Text(
                                                  status,
                                                  style: AppTextStyles.caption
                                                      .copyWith(
                                                        color: color,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                DateFormat(
                                                  'hh:mm a',
                                                ).format(g.dateTime),
                                                style: AppTextStyles.caption,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        indent: 16,
                                        endIndent: 16,
                                        color: AppColors.border,
                                      ),
                                  ],
                                );
                              }).toList();
                            }(),
                          ),
                        ),

                  const SizedBox(height: 28),

                  const SizedBox(height: 24),

                  // ── More options ──────────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'More',
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.border.withOpacity(0.6),
                      ),
                      boxShadow: AppShadows.card,
                    ),
                    child: Column(
                      children: [
                        _menuTile(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          subtitle: 'Notifications, appearance & more',
                          isFirst: true,
                          isLast: true, // ← change this from false to true
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Edit profile button ───────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _showEditProfile,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Version info
                  Center(
                    child: Text(
                      'DiabTech v1.0.0 · All data stored locally',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Helper widgets ─────────────────────────────────────────────
  Widget _infoPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sheetLabel(String text) {
    return Text(text, style: AppTextStyles.bodyBold.copyWith(fontSize: 14));
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.caption,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

// ── Mini stat card ─────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 16),
          ),
          const SizedBox(height: 10),
          Text(value, style: AppTextStyles.heading2.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

Widget _menuTile({
  required IconData icon,
  required String label,
  required String subtitle,
  required VoidCallback onTap,
  required bool isFirst,
  required bool isLast,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(20) : Radius.zero,
        bottom: isLast ? const Radius.circular(20) : Radius.zero,
      ),
      splashColor: AppColors.primary.withOpacity(0.06),
      highlightColor: AppColors.primary.withOpacity(0.04),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Icon circle
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

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyBold.copyWith(
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow
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
