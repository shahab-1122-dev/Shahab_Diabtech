import 'package:diabtech/models/glucose_model.dart';

import '../models/glucose_model.dart';

class GlucoseAggregator {
  /// DAILY → return today readings
  static List<GlucoseModel> daily(List<GlucoseModel> all) {
    final now = DateTime.now();
    return all.where((e) =>
        e.dateTime.year == now.year &&
        e.dateTime.month == now.month &&
        e.dateTime.day == now.day).toList();
  }

  /// WEEKLY → average per day (last 7 days)
  static List<GlucoseModel> weekly(List<GlucoseModel> all) {
    final now = DateTime.now();
    final Map<String, List<GlucoseModel>> grouped = {};

    for (var e in all) {
      if (now.difference(e.dateTime).inDays <= 7) {
        final key =
            "${e.dateTime.year}-${e.dateTime.month}-${e.dateTime.day}";
        grouped.putIfAbsent(key, () => []).add(e);
      }
    }

    return grouped.values.map(_averageModel).toList();
  }

  /// MONTHLY → average per week (last 30 days)
  static List<GlucoseModel> monthly(List<GlucoseModel> all) {
    final now = DateTime.now();
    final Map<int, List<GlucoseModel>> grouped = {};

    for (var e in all) {
      if (now.difference(e.dateTime).inDays <= 30) {
        final week = _weekOfYear(e.dateTime);
        grouped.putIfAbsent(week, () => []).add(e);
      }
    }

    return grouped.values.map(_averageModel).toList();
  }

  /// Helper → create avg glucose model
  static GlucoseModel _averageModel(List<GlucoseModel> list) {
    final avg =
        list.fold<double>(0, (p, e) => p + e.value) / list.length;

    return GlucoseModel(
      value: avg,
      dateTime: list.first.dateTime, readingType: '',
    );
  }

  /// Week number calculator
  static int _weekOfYear(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    return ((date.difference(firstDay).inDays) / 7).ceil();
  }
}
