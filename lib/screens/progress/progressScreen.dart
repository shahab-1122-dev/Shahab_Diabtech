import 'package:diabtech/screens/progress/glucose_aggregator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:diabtech/models/glucose_model.dart';
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
  late Box<GlucoseModel> glucoseBox;

  @override
  void initState() {
    super.initState();
    glucoseBox = Hive.box<GlucoseModel>('glucoseBox');
  }

  List<GlucoseModel> getFiltered(List<GlucoseModel> all) {
    switch (selectedReadingType) {
      case "Daily":
        return GlucoseAggregator.daily(all);
      case "Weekly":
        return GlucoseAggregator.weekly(all);
      case "Monthly":
        return GlucoseAggregator.monthly(all);
      default:
        return all;
    }
  }

  String generateInsight(List<GlucoseModel> readings) {
    if (readings.isEmpty) {
      return "Add readings to see insights.";
    }

    final avg =
        readings.map((e) => e.value).reduce((a, b) => a + b) / readings.length;

    if (avg < 120) {
      return "Great control! Your average glucose is in a healthy range.";
    } else if (avg < 160) {
      return "Moderate control. Keep monitoring your levels.";
    } else {
      return "High average detected. Consider reviewing your diet or medication.";
    }
  }

  String compareWithPrevious(
    List<GlucoseModel> current,
    List<GlucoseModel> allReadings,
  ) {
    if (current.isEmpty || allReadings.isEmpty) {
      return "";
    }

    // Current average
    final currentAvg =
        current.map((e) => e.value).reduce((a, b) => a + b) / current.length;

    // Previous readings (excluding current ones)
    final previous = allReadings.where((e) => !current.contains(e)).toList();

    if (previous.isEmpty) return "";

    final previousAvg =
        previous.map((e) => e.value).reduce((a, b) => a + b) / previous.length;

    final difference = currentAvg - previousAvg;

    if (difference > 5) {
      return "Your average increased by ${difference.toStringAsFixed(1)} mg/dL compared to previous period.";
    } else if (difference < -5) {
      return "Great! Your average decreased by ${difference.abs().toStringAsFixed(1)} mg/dL.";
    } else {
      return "Your glucose level is stable compared to previous period.";
    }
  }

  Map<String, double> calculateTimeInRange(List<GlucoseModel> readings) {
    if (readings.isEmpty) {
      return {"inRange": 0, "high": 0, "low": 0};
    }

    int inRange = 0;
    int high = 0;
    int low = 0;

    for (var reading in readings) {
      if (reading.value < 70) {
        low++;
      } else if (reading.value > 180) {
        high++;
      } else {
        inRange++;
      }
    }

    final total = readings.length;

    return {
      "inRange": (inRange / total) * 100,
      "high": (high / total) * 100,
      "low": (low / total) * 100,
    };
  }

  String detectSpikes(List<GlucoseModel> readings) {
    if (readings.length < 2) return "";

    int spikeCount = 0;

    for (int i = 1; i < readings.length; i++) {
      final difference = readings[i].value - readings[i - 1].value;

      if (difference >= 40) {
        spikeCount++;
      }
    }

    if (spikeCount == 0) {
      return "No major glucose spikes detected.";
    } else if (spikeCount == 1) {
      return "1 glucose spike detected. Monitor closely.";
    } else {
      return "$spikeCount glucose spikes detected. Consider reviewing meals or insulin timing.";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (glucoseBox.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Progress")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.show_chart, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "No glucose data yet",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Add your first reading to see progress",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Add Reading"),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Glucose Monitor", style: AppTextStyles.heading2),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,

      body: ValueListenableBuilder(
        valueListenable: glucoseBox.listenable(),
        builder: (context, Box<GlucoseModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No glucose data yet"));
          }

          final readings = box.values.toList();
          final filtered = getFiltered(readings);
          final insight = generateInsight(filtered);
          final comparison = compareWithPrevious(filtered, readings);
          final rangeData = calculateTimeInRange(filtered);
          final spikeMessage = detectSpikes(filtered);

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Your Health Dashboard",
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Toggle Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var type in ["Daily", "Weekly", "Monthly"])
                        GestureDetector(
                          onTap: () {
                            if (selectedReadingType != type) {
                              setState(() => selectedReadingType = type);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selectedReadingType == type
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(
                                color: selectedReadingType == type
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                              boxShadow: selectedReadingType == type
                                  ? AppShadows.card
                                  : [],
                            ),
                            child: Text(
                              type,
                              style: AppTextStyles.caption.copyWith(
                                color: selectedReadingType == type
                                    ? Colors.white
                                    : AppColors.textGrey,
                                fontWeight: selectedReadingType == type
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Avg/Max/Min Panel
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(
                      children: [
                        _statColumn(
                          "Average",
                          "${getAverage(filtered).toStringAsFixed(0)} mg/dL",
                          AppColors.primary,
                        ),
                        _divider(),
                        _statColumn(
                          "Highest",
                          "${getMax(filtered).toStringAsFixed(0)} mg/dL",
                          Colors.red,
                        ),
                        _divider(),
                        _statColumn(
                          "Lowest",
                          "${getMin(filtered).toStringAsFixed(0)} mg/dL",
                          Colors.blue,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$selectedReadingType Readings",
                        style: AppTextStyles.heading3,
                      ),
                      _trendChip(filtered),
                    ],
                  ),

                  const SizedBox(height: 40),
                  filtered.isEmpty
                      ? Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: Text(
                            "No data available for $selectedReadingType",
                            style: AppTextStyles.body.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          insight,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),

                                        if (comparison.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            comparison,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (spikeMessage.isNotEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        spikeMessage,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            GlucoseLineChart(readings: filtered),
                            _buildChartLegend(), //
                          ],
                        ),

                  GlucoseSummaryPanel(readings: filtered),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Time In Range",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _rangeItem(
                              "In Range",
                              rangeData["inRange"]!,
                              Colors.green,
                            ),
                            _rangeItem("High", rangeData["high"]!, Colors.red),
                            _rangeItem("Low", rangeData["low"]!, Colors.orange),
                          ],
                        ),
                      ],
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
}

Widget _rangeItem(String label, double value, Color color) {
  return Column(
    children: [
      Text(
        "${value.toStringAsFixed(1)}%",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 12)),
    ],
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

Widget _trendChip(List<GlucoseModel> list) {
  final trend = getTrend(list);

  Color color;
  IconData icon;

  if (trend == "Rising") {
    color = Colors.red;
    icon = Icons.trending_up;
  } else if (trend == "Falling") {
    color = Colors.green;
    icon = Icons.trending_down;
  } else {
    color = Colors.orange;
    icon = Icons.trending_flat;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          trend,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget _divider() =>
    Container(width: 1, height: 40, color: Colors.grey.shade300);

class GlucoseLineChart extends StatelessWidget {
  final List<GlucoseModel> readings;

  const GlucoseLineChart({super.key, required this.readings});

  List<FlSpot> _toSpots() {
    return readings.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.value.toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 30,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.15),
                strokeWidth: 1,
              );
            },
          ),
          rangeAnnotations: RangeAnnotations(
            horizontalRangeAnnotations: [
              HorizontalRangeAnnotation(
                y1: 70,
                y2: 200,
                color: Colors.green.withOpacity(0.12),
              ),
            ],
          ),

          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: readings.length > 10
                    ? (readings.length / 6).ceilToDouble()
                    : 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();

                  if (index < 0 || index >= readings.length) {
                    return const SizedBox();
                  }

                  if (readings.length > 10 &&
                      index %
                              (readings.length ~/ 6 == 0
                                  ? 1
                                  : readings.length ~/ 6) !=
                          0) {
                    return const SizedBox();
                  }

                  final date = readings[index].dateTime;

                  final time =
                      "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(time, style: const TextStyle(fontSize: 10)),
                  );
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
          maxX: (readings.length - 1).toDouble(),
          minY: getDynamicMinY(readings) < 60 ? getDynamicMinY(readings) : 60,
          maxY: getDynamicMaxY(readings) > 200 ? getDynamicMaxY(readings) : 200,
          lineBarsData: [
            LineChartBarData(
              spots: _toSpots(),
              isCurved: true,
              color: AppColors.primary,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.primary.withOpacity(0.1),
              ),
            ),
          ],
          betweenBarsData: [
            BetweenBarsData(
              fromIndex: 0,
              toIndex: 0,
              color: AppColors.primary.withOpacity(0.08),
            ),
          ],

          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBorder: BorderSide(color: Colors.grey.shade300, width: 1),
              fitInsideHorizontally: true,
              fitInsideVertically: true,

              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((LineBarSpot spot) {
                  final reading = readings[spot.x.toInt()];
                  final time =
                      "${reading.dateTime.hour.toString().padLeft(2, '0')}:${reading.dateTime.minute.toString().padLeft(2, '0')}";

                  return LineTooltipItem(
                    "${reading.value} mg/dL\n$time",
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildChartLegend() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Readings legend
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text("Readings"),
          ],
        ),

        const SizedBox(width: 20),

        // Target range legend
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text("Target Range"),
          ],
        ),
      ],
    ),
  );
}

class GlucoseSummaryPanel extends StatelessWidget {
  final List<GlucoseModel> readings;

  const GlucoseSummaryPanel({super.key, required this.readings});

  @override
  Widget build(BuildContext context) {
    final avg = getAverage(readings).toStringAsFixed(0);

    final inRangeCount = readings
        .where((e) => e.value >= 70 && e.value <= 180)
        .length;

    final inRangePercent = readings.isEmpty
        ? "0%"
        : "${((inRangeCount / readings.length) * 100).toStringAsFixed(0)}%";

    final lastTime = readings.isNotEmpty ? readings.last.dateTime : null;

    String lastReadingText = "N/A";
    if (lastTime != null) {
      final diff = DateTime.now().difference(lastTime);
      lastReadingText = diff.inMinutes < 60
          ? "${diff.inMinutes}m ago"
          : "${diff.inHours}h ago";
    }

    final stats = [
      {
        "icon": Icons.show_chart_rounded,
        "title": "Daily Average",
        "value": "$avg mg/dL",
        "subtitle": "Based on readings",
      },
      {
        "icon": Icons.stacked_bar_chart_rounded,
        "title": "Time in Range",
        "value": inRangePercent,
        "subtitle": "70–180 mg/dL",
      },
      {
        "icon": Icons.calendar_today_rounded,
        "title": "Readings Today",
        "value": readings.length.toString(),
        "subtitle": "Logged",
      },
      {
        "icon": Icons.access_time_rounded,
        "title": "Last Reading",
        "value": lastReadingText,
        "subtitle": "Updated",
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

double getAverage(List<GlucoseModel> list) {
  if (list.isEmpty) return 0;
  final sum = list.fold<double>(0, (p, e) => p + e.value);
  return sum / list.length;
}

double getMax(List<GlucoseModel> list) {
  if (list.isEmpty) return 0;
  return list.map((e) => e.value).reduce((a, b) => a > b ? a : b);
}

double getMin(List<GlucoseModel> list) {
  if (list.isEmpty) return 0;
  return list.map((e) => e.value).reduce((a, b) => a < b ? a : b);
}

List<FlSpot> glucoseToSpots(List<GlucoseModel> list) {
  return list.asMap().entries.map((e) {
    return FlSpot(e.key.toDouble(), e.value.value.toDouble());
  }).toList();
}

String getTrend(List<GlucoseModel> list) {
  if (list.length < 2) return "Stable";

  final last = list[list.length - 1].value;
  final prev = list[list.length - 2].value;

  if (last > prev) return "Rising";
  if (last < prev) return "Falling";
  return "Stable";
}

double getDynamicMinY(List<GlucoseModel> list) {
  if (list.isEmpty) return 0;
  final min = list.map((e) => e.value).reduce((a, b) => a < b ? a : b);
  return (min - 20).clamp(0, double.infinity); // padding
}

double getDynamicMaxY(List<GlucoseModel> list) {
  if (list.isEmpty) return 200;
  final max = list.map((e) => e.value).reduce((a, b) => a > b ? a : b);
  return max + 20; // padding
}
