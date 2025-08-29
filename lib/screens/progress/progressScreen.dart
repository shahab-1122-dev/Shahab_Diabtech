import 'package:diabtech/screens/utils/constant.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class Progressscreen extends StatefulWidget {
  const Progressscreen({super.key});

  @override
  State<Progressscreen> createState() => _ProgressscreenState();
}

class _ProgressscreenState extends State<Progressscreen> {
  String selectedReadingType = "Daily";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Glucose Monitor", style: AppTextStyles.heading2),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("Your Health Dashboard", style: AppTextStyles.body),
              ),
              const SizedBox(height: 30),

              // Toggle Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var type in ["Daily", "Weekly", "Monthly"])
                    GestureDetector(
                      onTap: () => setState(() => selectedReadingType = type),
                      child: Container(
                        height: 45,
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: selectedReadingType == type
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedReadingType == type
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: AppTextStyles.bodyBold.copyWith(
                              color: selectedReadingType == type
                                  ? AppColors.primary
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),

              // Avg/Max/Min Panel
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _statColumn("Average", "120", AppColors.primary),
                    _divider(),
                    _statColumn("Maximum", "180", Colors.red),
                    _divider(),
                    _statColumn("Minimum", "90", Colors.green),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text("Today's Readings", style: AppTextStyles.heading3),

              const SizedBox(height: 40),
              const GlucoseLineChart(),
              //const SizedBox(height: 20),
              // Summary Panel
              const GlucoseSummaryPanel(),
            ],
          ),
        ),
      ),
    );
  }
                                        
  Widget _statColumn(String title, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 40, color: Colors.grey.shade300);
}

class GlucoseLineChart extends StatelessWidget {
  const GlucoseLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, horizontalInterval: 30),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text("6");
                    case 1:
                      return const Text("9");
                    case 2:
                      return const Text("12");
                    case 3:
                      return const Text("3");
                    case 4:
                      return const Text("6");
                    case 5:
                      return const Text("9");
                    default:
                      return const Text("");
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 70,
          maxY: 200,
          lineBarsData: [
            LineChartBarData(
              spots: const [
                FlSpot(0, 110),
                FlSpot(1, 125),
                FlSpot(2, 140),
                FlSpot(3, 135),
                FlSpot(4, 150),
                FlSpot(5, 145),
                FlSpot(6, 160),
              ],
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlucoseSummaryPanel extends StatelessWidget {
  const GlucoseSummaryPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = [
      {
        "icon": Icons.show_chart_rounded,
        "title": "Daily Average",
        "value": "156 mg/dL",
        "subtitle": "+2.3%",
      },
      {
        "icon": Icons.stacked_bar_chart_rounded,
        "title": "Time in Range",
        "value": "75%",
        "subtitle": "Good",
      },
      {
        "icon": Icons.calendar_today_rounded,
        "title": "Readings Today",
        "value": "6",
        "subtitle": "On Track",
      },
      {
        "icon": Icons.access_time_rounded,
        "title": "Last Reading",
        "value": "2h ago",
        "subtitle": "Normal",
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EDF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: stats.length,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 15,
          crossAxisSpacing: 15,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (_, i) {
          final s = stats[i];
          return _InfoTile(
            icon: s["icon"] as IconData,
            title: s["title"] as String,
            value: s["value"] as String,
            subtitle: s["subtitle"] as String,
          );
        },
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
