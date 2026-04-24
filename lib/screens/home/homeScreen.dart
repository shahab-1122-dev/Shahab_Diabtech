// ignore: file_names
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:diabtech/models/glucose_model.dart';
import 'package:diabtech/screens/profile/profile_screen.dart';
import 'package:diabtech/screens/progress/progressScreen.dart' hide SizedBox;
import 'package:diabtech/screens/suggestion/suggestions.dart';
import 'package:flutter/material.dart' hide SizedBox;
import 'package:diabtech/screens/glucose_input_screen/inputGlocoseLevel.dart';
import 'package:diabtech/screens/glucose_input_screen/logHistoryScreen.dart';
import 'package:diabtech/screens/utils/constant.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Tabs (screens) for bottom navigation
  final List<Widget> _screens = [
    const _DashboardTab(),
    Inputglocoselevel(),
    LogHistoryScreen(),
    Progressscreen(),
    Suggestions(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textGrey,
          backgroundColor: Colors.white,
          elevation: 0,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_rounded),
              label: "Add",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: "History",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: "Progress",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.tips_and_updates_rounded),
              label: "Tips",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}

/* ---------------- Dashboard Tab (your old Home content) ---------------- */
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  String _getUserName() {
    final userBox = Hive.box('userBox');
    return userBox.get('name', defaultValue: 'there');
  }

  String _getGlucoseStatus(double value) {
    if (value < 70) {
      return "Low";
    } else if (value <= 180) {
      return "Normal";
    } else {
      return "High";
    }
  }

  Color _getStatusColor(double value) {
    if (value < 70) {
      return Colors.blue;
    } else if (value <= 180) {
      return AppColors.success;
    } else {
      return Colors.red;
    }
  }

  String _getTrend(Box<GlucoseModel> box) {
    if (box.length < 2) return "No trend";

    final latest = box.getAt(box.length - 1)!;
    final previous = box.getAt(box.length - 2)!;

    if (latest.value > previous.value) {
      return "Rising ↑";
    } else if (latest.value < previous.value) {
      return "Falling ↓";
    } else {
      return "Stable";
    }
  }

  String _getInsight(Box<GlucoseModel> box) {
    if (box.isEmpty) return "Add readings to see insights";

    final today = DateTime.now();

    final todayReadings = box.values.where((g) {
      return g.dateTime.year == today.year &&
          g.dateTime.month == today.month &&
          g.dateTime.day == today.day;
    }).toList();

    if (todayReadings.isEmpty) return "No readings today";

    int high = todayReadings.where((g) => g.value > 180).length;
    int low = todayReadings.where((g) => g.value < 70).length;

    if (high >= 2) {
      return "High glucose detected today";
    } else if (low >= 2) {
      return "Low glucose detected today";
    } else {
      return "Your glucose levels look stable";
    }
  }

  late Box<GlucoseModel> glucoseBox;

  List<FlSpot> _getTodayChartSpots(Box<GlucoseModel> box) {
    final today = DateTime.now();

    final todayReadings = box.values.where((g) {
      return g.dateTime.year == today.year &&
          g.dateTime.month == today.month &&
          g.dateTime.day == today.day;
    }).toList();

    if (todayReadings.isEmpty) return [];

    // sort by time
    todayReadings.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    List<FlSpot> spots = [];

    for (int i = 0; i < todayReadings.length; i++) {
      spots.add(FlSpot(i.toDouble(), todayReadings[i].value));
    }

    return spots;
  }

  @override
  void initState() {
    
    super.initState();
    glucoseBox = Hive.box<GlucoseModel>('glucoseBox');
  }

  double _calculateDailyAverage(Box<GlucoseModel> box) {
    final today = DateTime.now();

    final todayReadings = box.values.where((g) {
      return g.dateTime.year == today.year &&
          g.dateTime.month == today.month &&
          g.dateTime.day == today.day;
    }).toList();

    if (todayReadings.isEmpty) return 0;

    final sum = todayReadings.fold<double>(0, (s, g) => s + g.value);

    return sum / todayReadings.length;
  }

  int _calculateTimeInRange(Box<GlucoseModel> box) {
    if (box.isEmpty) return 0;

    final inRange = box.values.where((g) {
      return g.value >= 70 && g.value <= 180;
    }).length;

    return ((inRange / box.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              name: "${getGreeting()}, ${_getUserName()} 👋",
              dateText: DateFormat('EEEE, MMMM d').format(DateTime.now()),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: glucoseBox.listenable(),
              builder: (context, Box<GlucoseModel> box, _) {
                if (box.isEmpty) {
                  return _GlucoseCard(
                    valueMgDl: 0,
                    status: "No data",
                    statusColor: Colors.grey, // ✅ ADD THIS
                    lastUpdated: "Add your first reading",
                    onAddPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Inputglocoselevel()),
                      );
                    },
                  );
                }

                final latest = box.getAt(box.length - 1)!;

                final statusText = _getGlucoseStatus(latest.value);
                final statusColor = _getStatusColor(latest.value);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  child: _GlucoseCard(
                    valueMgDl: latest.value.toInt(),
                    status: "$statusText • ${_getTrend(box)}",
                    statusColor: statusColor,
                    lastUpdated: _timeAgo(latest.dateTime),
                    onAddPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => Inputglocoselevel()),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionTitle("Glucose Trend"),
                Text("Today", style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: glucoseBox.listenable(),
              builder: (context, Box<GlucoseModel> box, _) {
                final spots = _getTodayChartSpots(box);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _MiniChart(spots: spots),
                );
              },
            ),

            const SizedBox(height: 16),
            _SectionTitle("Quick Stats"),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: glucoseBox.listenable(),
              builder: (context, Box<GlucoseModel> box, _) {
                final avg = _calculateDailyAverage(box);
                final range = _calculateTimeInRange(box);

                return GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _StatCard(
                      icon: Icons.show_chart,
                      value: avg == 0 ? "—" : "${avg.toStringAsFixed(1)} mg/dL",
                      title: "Daily Average",
                    ),
                    _StatCard(
                      icon: Icons.timeline_outlined,
                      value: "$range%",
                      title: "Time in Range",
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            _SectionTitle("Coming Up"),
            const SizedBox(height: 8),
            const _UpcomingItem(
              icon: Icons.add_box_outlined,
              title: "Insulin Shot",
              time: "12:30 PM",
            ),
            const SizedBox(height: 10),
            const _UpcomingItem(
              icon: Icons.lunch_dining_outlined,
              title: "Lunch",
              time: "1:00 PM",
            ),
            const SizedBox(height: 20),
            _SectionTitle("Your Insights"),
            const SizedBox(height: 8),
            ValueListenableBuilder(
              valueListenable: glucoseBox.listenable(),
              builder: (context, Box<GlucoseModel> box, _) {
                return Row(
                  children: [
                    Expanded(
                      child: _InsightCard(
                        icon: Icons.show_chart_outlined,
                        title: "Glucose Pattern",
                        subtitle: _getInsight(box),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: _InsightCard(
                        icon: Icons.access_time,
                        title: "Time Analysis",
                        subtitle: "Check before meals",
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------- Small reusable widgets (unchanged) ----------------- */

class _Header extends StatelessWidget {
  final String name;
  final String dateText;
  const _Header({required this.name, required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text(dateText, style: AppTextStyles.caption),
      ],
    );
  }
}

class _GlucoseCard extends StatelessWidget {
  final Color statusColor;
  final int valueMgDl;
  final String status;
  final String lastUpdated;
  final VoidCallback onAddPressed;

  const _GlucoseCard({
    required this.valueMgDl,
    required this.status,
    required this.statusColor, // ✅ ADD THIS
    required this.lastUpdated,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(.15), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border.withOpacity(.4)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1 — big number + add button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    valueMgDl == 0 ? "--" : "$valueMgDl",
                    style: AppTextStyles.display.copyWith(
                      fontSize: 48,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text("mg/dL", style: AppTextStyles.body),
                  ),
                ],
              ),
              InkWell(
                onTap: onAddPressed,
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: AppColors.primary),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Row 2 — status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: AppTextStyles.caption.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Row 3 — range bar
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Stack(
              children: [
                Container(height: 6, color: Colors.grey.withOpacity(0.15)),
                FractionallySizedBox(
                  widthFactor: valueMgDl == 0
                      ? 0.0
                      : (valueMgDl.clamp(0, 300) / 300).toDouble(),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 4),

          // Row 4 — range labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("70", style: AppTextStyles.caption),
              Text("Normal range", style: AppTextStyles.caption),
              Text("180", style: AppTextStyles.caption),
            ],
          ),

          const SizedBox(height: 6),

          // Row 5 — last updated
          Text("Last updated $lastUpdated", style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 5),
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _UpcomingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  const _UpcomingItem({
    required this.icon,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  final List<FlSpot> spots;

  const _MiniChart({required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text("No data for chart")),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      child: SizedBox(
        height: 120,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppColors.border.withOpacity(0.5),
                strokeWidth: 0.5,
              ),
            ),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: false),

            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                curveSmoothness: 0.4,
                barWidth: 4,
                isStrokeCapRound: true,

                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.6),
                  ],
                ),

                dotData: FlDotData(show: false),

                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],

            extraLinesData: ExtraLinesData(
              extraLinesOnTop: false,
              horizontalLines: [
                HorizontalLine(
                  y: 70,
                  color: Colors.blue.withOpacity(0.5),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    labelResolver: (_) => "  Low",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                HorizontalLine(
                  y: 180,
                  color: Colors.red.withOpacity(0.5),
                  strokeWidth: 1.5,
                  dashArray: [6, 4],
                  label: HorizontalLineLabel(
                    show: true,
                    alignment: Alignment.topRight,
                    labelResolver: (_) => "  High",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.heading3);
  }
}

String _timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);

  if (diff.inMinutes < 1) return "just now";
  if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
  if (diff.inHours < 24) return "${diff.inHours} hrs ago";
  return "${diff.inDays} days ago";
}
