import 'package:diabtech/screens/utils/constant.dart';
import 'package:diabtech/services/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:diabtech/models/glucose_model.dart';

class Suggestions extends StatefulWidget {
  const Suggestions({super.key});

  @override
  State<Suggestions> createState() => _SuggestionsState();
}

class _SuggestionsState extends State<Suggestions> {
  List<Map<String, String>> insights = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadAI();
  }

  Future<void> loadAI() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    final box = Hive.box<GlucoseModel>('glucoseBox');
    final readings = box.values.toList();

    if (readings.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final values = readings.map((e) => e.value).toList();
    final result = await AIService.getInsights(values);

    if (mounted) {
      // If the first result title is an error message, show error state
      final isError =
          result.length == 1 &&
          (result[0]['title'] == 'Something went wrong' ||
              result[0]['title'] == 'Could not load insights');

      setState(() {
        insights = result;
        isLoading = false;
        hasError = isError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text("Smart Insights", style: AppTextStyles.heading2),
              const SizedBox(height: 8),
              Text("Based on your glucose patterns", style: AppTextStyles.body),
              const SizedBox(height: 24),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Couldn't load insights",
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Check your internet connection\nand try again.",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            AppButtons.primaryButton(
                              "Try Again",
                              onPressed: loadAI,
                            ),
                          ],
                        ),
                      )
                    : insights.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.monitor_heart_outlined,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No readings yet",
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add some glucose readings first\nto get AI insights.",
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textGrey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: insights.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = insights[index];
                          return _buildInsightCard(
                            item['title']!,
                            item['tip']!,
                          );
                        },
                      ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: AppButtons.primaryButton(
                  isLoading ? "Loading..." : "Refresh Insights",
                  onPressed: isLoading ? null : loadAI,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String tip) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.green,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
