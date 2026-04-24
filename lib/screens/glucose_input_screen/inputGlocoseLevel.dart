import 'package:diabtech/models/glucose_model.dart';
import 'package:diabtech/screens/home/homeScreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:diabtech/screens/utils/constant.dart';
import 'package:diabtech/screens/utils/validator.dart';
import 'package:diabtech/services/glucose_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Inputglocoselevel extends StatefulWidget {
  final GlucoseModel? existingRecord;
  final int? recordKey;

  const Inputglocoselevel({super.key, this.existingRecord, this.recordKey});

  @override
  State<Inputglocoselevel> createState() => _InputglocoselevelState();
}

class _InputglocoselevelState extends State<Inputglocoselevel> {
  final TextEditingController glucoseController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    if (widget.existingRecord != null) {
      glucoseController.text = widget.existingRecord!.value.toString();

      dateController.text = DateFormat(
        'yyyy-MM-dd',
      ).format(widget.existingRecord!.dateTime);

      timeController.text = DateFormat(
        'HH:mm',
      ).format(widget.existingRecord!.dateTime);
    } else {
      //  SET CURRENT DATE & TIME FOR NEW ENTRY
      final now = DateTime.now();

      dateController.text = DateFormat('yyyy-MM-dd').format(now);
      timeController.text = DateFormat('HH:mm').format(now);
    }
  }

  String selectedReadingType = "Before Meal";

  final List<String> readingTypes = [
    "Before Meal",
    "After Meal",
    "Fasting",
    "Bedtime",
    "Random",
  ];
  double? currentGlucose;
  bool isSaving = false;

  Color getGlucoseColor(double value) {
    if (value < 70) {
      return Colors.blue;
    } else if (value <= 180) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  String getGlucoseStatus(double value) {
    if (value < 70) {
      return "Low";
    } else if (value <= 180) {
      return "Normal";
    } else {
      return "High";
    }
  }

  String getGlucoseAdvice(double value) {
    if (value < 70) {
      return "Low glucose. Consider eating something sweet.";
    } else if (value <= 180) {
      return "Glucose level is within the normal range.";
    } else if (value <= 250) {
      return "Glucose is high. Light activity may help lower it.";
    } else {
      return "Very high glucose! Monitor carefully or consult a doctor.";
    }
  }

  Widget _buildReadingTypeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Reading Type", style: AppTextStyles.bodyBold),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: readingTypes.map((type) {
              final bool isSelected = selectedReadingType == type;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedReadingType = type;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                    boxShadow: isSelected ? AppShadows.card : [],
                  ),
                  child: Text(
                    type,
                    style: AppTextStyles.caption.copyWith(
                      color: isSelected ? Colors.white : AppColors.textGrey,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Add Blood Glucose", style: AppTextStyles.heading2),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Glucose Level
                  _buildLabel("Blood Glucose Level"),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: glucoseController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        currentGlucose = double.tryParse(value);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Enter Value (mg/dL)",
                      hintStyle: AppTextStyles.body,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: Validators.validateGlucose,
                  ),

                  const SizedBox(height: 10),

                  if (currentGlucose != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: getGlucoseColor(
                          currentGlucose!,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: getGlucoseColor(currentGlucose!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: getGlucoseColor(currentGlucose!),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${getGlucoseStatus(currentGlucose!)} (${currentGlucose!.toInt()} mg/dL)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: getGlucoseColor(currentGlucose!),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  getGlucoseAdvice(currentGlucose!),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // Date + Time row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Date"),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: dateController,
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: const Icon(Icons.date_range),
                                hintText: "Select Date",
                                hintStyle: AppTextStyles.body,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: Validators.validateDate,
                              onTap: () async {
                                final pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );

                                if (pickedDate != null) {
                                  dateController.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(pickedDate);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel("Time"),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: timeController,
                              readOnly: true,
                              decoration: InputDecoration(
                                suffixIcon: const Icon(Icons.access_time),
                                hintText: "Select Time",
                                hintStyle: AppTextStyles.body,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              validator: Validators.validateTime,
                              onTap: () async {
                                final pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );

                                if (pickedTime != null) {
                                  final now = DateTime.now();
                                  final time = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );

                                  timeController.text = DateFormat(
                                    'HH:mm',
                                  ).format(time);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Reading type
                  _buildLabel("Reading Type"),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        for (var type in [
                          "Before Meal",
                          "After Meal",
                          "Fasting",
                          "Bedtime",
                          "Random",
                        ])
                          GestureDetector(
                            onTap: () =>
                                setState(() => selectedReadingType = type),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
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
                                  width: 1.5,
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
                  ),

                  const SizedBox(height: 20),

                  // Notes
                  _buildLabel("Notes (optional)"),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.topRight,
                    children: [
                      TextFormField(
                        controller: notesController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Add any additional notes here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          notesController.clear();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Save button
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: AppButtons.primaryButton(
                      isSaving
                          ? "Saving..."
                          : (widget.recordKey != null
                                ? "Update Reading"
                                : "Save Reading"),
                      onPressed: () async {
                        if (isSaving) return;

                        if (_formKey.currentState!.validate()) {
                          setState(() => isSaving = true);

                          try {
                            final value = double.parse(glucoseController.text);

                            if (value >= 300 || value <= 50) {
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Critical Glucose Level"),
                                    content: Text(
                                      value >= 300
                                          ? "Your glucose level is extremely high ($value mg/dL). Please monitor carefully."
                                          : "Your glucose level is dangerously low ($value mg/dL). Consider taking glucose immediately.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("OK"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }

                            final dateTime = DateFormat("yyyy-MM-dd HH:mm").parse(
                              "${dateController.text} ${timeController.text}",
                            );

                            final glucose = GlucoseModel(
                              value: value,
                              dateTime: dateTime,
                              readingType: selectedReadingType,
                            );

                            final box = Hive.box<GlucoseModel>('glucoseBox');

                            if (widget.recordKey != null) {
                              await box.put(widget.recordKey, glucose);
                            } else {
                              await box.add(glucose);
                            }

                            // RESET
                            glucoseController.clear();
                            notesController.clear();

                            setState(() {
                              isSaving = false;
                              currentGlucose = null;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Saved successfully ✅")),
                            );

                            Navigator.pop(context); // ✅ IMPORTANT (go back)
                          } catch (e) {
                            print("ERROR: $e");

                            setState(() => isSaving = false);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error saving data")),
                            );
                          }
                        } else {
                          setState(() => isSaving = false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.bodyBold.copyWith(fontSize: 16));
  }
}
