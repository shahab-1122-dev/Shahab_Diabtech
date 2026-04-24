import 'dart:convert';
import 'package:http/http.dart' as http;

class AIService {
  // Use your key from the screenshot
  static const String _apiKey = "AIzaSyBYErYIyoIagxkWyJWN4aHr6IjryvH5zio";

  static Future<List<Map<String, String>>> getInsights(
    List<double> values,
  ) async {
    try {
      // 🟢 CHANGE: Switched 'v1beta' to 'v1' and used 'gemini-1.5-flash'
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=$_apiKey',
      );
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              "contents": [
                {
                  "parts": [
                    {
                      "text":
                          "Analyze these blood glucose readings: $values. "
                          "You are a diabetes health assistant. Provide exactly 3 short actionable tips. "
                          "Respond ONLY with a valid JSON array: [{\"title\": \"...\", \"tip\": \"...\"}]",
                    },
                  ],
                },
              ],
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String textResponse =
            data['candidates'][0]['content']['parts'][0]['text'];

        final startIndex = textResponse.indexOf('[');
        final endIndex = textResponse.lastIndexOf(']');

        if (startIndex == -1 || endIndex == -1) {
          return [
            {"title": "General Tip", "tip": "Keep monitoring your levels."},
          ];
        }

        final cleanJson = textResponse.substring(startIndex, endIndex + 1);
        final List<dynamic> decoded = jsonDecode(cleanJson);

        return decoded
            .map<Map<String, String>>(
              (item) => {
                "title": item["title"]?.toString() ?? "Tip",
                "tip": item["tip"]?.toString() ?? "Keep monitoring.",
              },
            )
            .toList();
      } else {
        // 💡 This will help you see if there's a new error
        print("HTTP Error ${response.statusCode}: ${response.body}");
        return [
          {
            "title": "Error",
            "tip": "Server responded with status ${response.statusCode}.",
          },
        ];
      }
    } catch (e) {
      print("AI Error: $e");
      return [
        {"title": "Connection Error", "tip": "Unable to reach AI."},
      ];
    }
  }
}

