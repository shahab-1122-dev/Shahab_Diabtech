import 'package:diabtech/models/glucose_model.dart';
import 'package:diabtech/screens/glucose_input_screen/inputGlocoseLevel.dart';
import 'package:diabtech/screens/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class LogHistoryScreen extends StatefulWidget {
  const LogHistoryScreen({super.key});

  @override
  State<LogHistoryScreen> createState() => _LogHistoryScreenState();
}

class _LogHistoryScreenState extends State<LogHistoryScreen> {
  late Box<GlucoseModel> glucoseBox;

  @override
  void initState() {
    super.initState();
    glucoseBox = Hive.box<GlucoseModel>('glucoseBox');
  }

  Color _getStatusColor(double value) {
    if (value < 70) return Colors.blue;
    if (value <= 180) return AppColors.success;
    return Colors.red;
  }

  String _getStatus(double value) {
    if (value < 70) return "Low";
    if (value <= 180) return "Normal";
    return "High";
  }

  // Groups entries by date — returns a map of "Today", "Yesterday",
  // or "Apr 10" → list of {key, data}
  Map<String, List<Map<String, dynamic>>> _groupByDate(
    List<Map<String, dynamic>> entries,
  ) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final entry in entries) {
      final dt = (entry['data'] as GlucoseModel).dateTime;
      final entryDate = DateTime(dt.year, dt.month, dt.day);

      String label;
      if (entryDate == today) {
        label = "Today";
      } else if (entryDate == yesterday) {
        label = "Yesterday";
      } else {
        label = DateFormat('MMM d, yyyy').format(dt);
      }

      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(entry);
    }

    return grouped;
  }

  void _showActionSheet(BuildContext context, int key, GlucoseModel glucose) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 20),
              Text("Actions", style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: AppColors.background,
                leading: Icon(Icons.edit_rounded, color: AppColors.primary),
                title: Text("Edit Reading", style: AppTextStyles.bodyBold),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Inputglocoselevel(
                        existingRecord: glucose,
                        recordKey: key,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                tileColor: Colors.red.withOpacity(0.05),
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text(
                  "Delete Reading",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _confirmDelete(context, key),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, int key) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("Delete Reading"),
          content: const Text(
            "Are you sure you want to delete this reading?\nThis cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: TextStyle(color: AppColors.textGrey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                await glucoseBox.delete(key);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    content: const Text("Reading deleted successfully"),
                  ),
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Log History", style: AppTextStyles.heading2),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: glucoseBox.listenable(),
        builder: (context, Box<GlucoseModel> box, _) {
          // Empty state
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.monitor_heart_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text("No readings yet", style: AppTextStyles.heading3),
                  const SizedBox(height: 8),
                  Text(
                    "Your glucose history will appear here.",
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Build entries list — newest first
          final entries = box.keys
              .map((key) => {"key": key, "data": box.get(key)})
              .toList()
              .reversed
              .toList();

          final grouped = _groupByDate(entries.cast<Map<String, dynamic>>());

          // Build a flat list of section headers + items
          final List<Widget> listItems = [];

          grouped.forEach((dateLabel, dayEntries) {
            // Date header
            listItems.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                child: Row(
                  children: [
                    Text(dateLabel, style: AppTextStyles.heading3),
                    const SizedBox(width: 8),
                    Text(
                      "${dayEntries.length} reading${dayEntries.length > 1 ? 's' : ''}",
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            );

            // Entries under this date
            for (final entry in dayEntries) {
              final glucose = entry['data'] as GlucoseModel;
              final key = entry['key'] as int;
              final color = _getStatusColor(glucose.value);
              final status = _getStatus(glucose.value);

              listItems.add(
                GestureDetector(
                  onTap: () => _showActionSheet(context, key, glucose),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border(left: BorderSide(color: color, width: 4)),
                      boxShadow: AppShadows.card,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          // Icon circle
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.water_drop_rounded,
                              color: color,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),

                          // Middle — value + reading type
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${glucose.value.toStringAsFixed(1)} mg/dL",
                                  style: AppTextStyles.heading3,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (glucose.readingType.isNotEmpty) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            99,
                                          ),
                                        ),
                                        child: Text(
                                          glucose.readingType,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      DateFormat(
                                        'hh:mm a',
                                      ).format(glucose.dateTime),
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Right — status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              status,
                              style: AppTextStyles.caption.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
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
          });

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: listItems,
          );
        },
      ),
    );
  }
}
