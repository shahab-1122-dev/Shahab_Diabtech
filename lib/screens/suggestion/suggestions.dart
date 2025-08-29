import 'package:diabtech/screens/utils/constant.dart';
import 'package:flutter/material.dart';

class Suggestions extends StatelessWidget {
  Suggestions({super.key});

  final List<Map<String, dynamic>> suggestions = [
    {
      "icons": Icons.restaurant,
      "title": "Balanced Breakfast Impact",
      "subtitle":
          "Your glucose levels are most stable when you eat protein with carbs. Consider adding eggs or Greek yogurt to your morning meal.",
    },
    {
      "icons": Icons.directions_run,
      "title": "Optimal Exercise Time",
      "subtitle":
          "Morning walks between 7–9 AM show better glucose response. Try a 15-minute walk after breakfast.",
    },
    {
      "icons": Icons.nightlight_round,
      "title": "Evening Routine",
      "subtitle":
          "Your glucose is more stable when you sleep before 11 PM. Consider earlier dinner times to support better sleep.",
    },
    {
      "icons": Icons.access_time,
      "title": "Optimal Meal Spacing",
      "subtitle":
          "Spacing your meals 4–5 hours apart shows better glucose control. Try planning your meals at regular intervals.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Smart Insights", style: AppTextStyles.heading2),
                const SizedBox(height: 10),
                Text(
                  "Based on your glucose patterns",
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: 20),

                // ✅ FIXED ListView
                ListView.builder(
                  shrinkWrap: true, // makes it fit inside Column
                  physics:
                      NeverScrollableScrollPhysics(), // disable inner scroll
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue[50],
                          child: Icon(
                            suggestions[index]["icons"],
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(
                          suggestions[index]["title"],
                          style: AppTextStyles.heading3,
                        ),
                        subtitle: Text(
                          suggestions[index]["subtitle"],
                          style: AppTextStyles.body,
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: AppButtons.primaryButton("View All Insights"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
