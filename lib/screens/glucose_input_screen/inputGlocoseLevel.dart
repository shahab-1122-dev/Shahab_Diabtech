import 'package:diabtech/screens/utils/constant.dart';
import 'package:diabtech/screens/utils/validator.dart';
import 'package:flutter/material.dart';

class Inputglocoselevel extends StatefulWidget {
  const Inputglocoselevel({super.key});

  @override
  State<Inputglocoselevel> createState() => _InputglocoselevelState();
}

class _InputglocoselevelState extends State<Inputglocoselevel> {
  final TextEditingController glucoseController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String selectedReadingType = "Before Meal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Add Blood Glucose", style: AppTextStyles.heading2),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 236, 232, 232),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glucose Level
                _buildLabel("Blood Glucose Level"),
                const SizedBox(height: 10),
                TextFormField(
                  controller: glucoseController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: "Enter Value (mg/dL)",
                    hintStyle: AppTextStyles.body,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: Validators.validateGlucose,
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
                              suffixIcon: const Icon(
                                Icons.access_time,
                              ), // ⏰ clock
                              hintText: "Select Time",
                              hintStyle: AppTextStyles.body,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: Validators.validateTime,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var type in ["Before Meal", "After Meal", "Fasting"])
                      GestureDetector(
                        onTap: () {
                          setState(() => selectedReadingType = type);
                        },
                        child: Container(
                          height: 50,
                          width: 110,
                          decoration: BoxDecoration(
                            color: selectedReadingType == type
                                ? AppColors.primary
                                : AppColors.textLight,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(type, style: AppTextStyles.bodyBold),
                          ),
                        ),
                      ),
                  ],
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
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: AppButtons.primaryButton("Save Reading"),
                ),
              ],
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
