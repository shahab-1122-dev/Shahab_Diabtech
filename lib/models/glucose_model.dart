import 'package:hive/hive.dart';

part 'glucose_model.g.dart';

@HiveType(typeId: 0)
class GlucoseModel {
  @HiveField(0)
  final double value;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final String readingType; // NEW

  GlucoseModel({
    required this.value,
    required this.dateTime,
    required this.readingType,
  });
}
