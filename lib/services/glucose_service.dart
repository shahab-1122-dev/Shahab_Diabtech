import 'package:hive/hive.dart';
import '../models/glucose_model.dart';

class GlucoseService {
  static final Box<GlucoseModel> _box = Hive.box<GlucoseModel>('glucoseBox');

  // Save glucose reading
  static Future<void> addGlucose(
    double value, {
    required String readingType,
  }) async {
    final entry = GlucoseModel(
      value: value,
      dateTime: DateTime.now(),
      readingType: readingType,
    );
    await _box.add(entry);
  }

  // Get all glucose readings
  static List<GlucoseModel> getAllReadings() {
    return _box.values.toList();
  }

  // Delete a reading
  static Future<void> deleteReading(int index) async {
    await _box.deleteAt(index);
  }
}
