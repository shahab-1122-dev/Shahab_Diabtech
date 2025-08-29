import 'package:flutter/material.dart';

class LogHistoryScreen extends StatelessWidget {
  const LogHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy log data (replace with real data later)
    final List<Map<String, dynamic>> logData = [
      {
        "date": "Today, 26 Aug 2025",
        "entries": [
          {"time": "08:30 AM", "value": "120 mg/dL"},
          {"time": "01:15 PM", "value": "135 mg/dL"},
          {"time": "07:45 PM", "value": "142 mg/dL"},
        ],
      },
      {
        "date": "Yesterday, 25 Aug 2025",
        "entries": [
          {"time": "09:00 AM", "value": "118 mg/dL"},
          {"time": "02:10 PM", "value": "140 mg/dL"},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Log History"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logData.length,
        itemBuilder: (context, index) {
          final dayData = logData[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  dayData["date"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              // Entries under this date
              ...dayData["entries"].map<Widget>((entry) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.opacity,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      entry["value"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      entry["time"],
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}
