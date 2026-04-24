class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return "Enter your email";
    if (!value.contains("@")) return "Invalid email";
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 6)
      return "Password must be at least 6 chars";
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return "Enter your name";
    return null;
  }

  static String? validateDate(String? value) {
    if (value == null || value.isEmpty) return "Enter Date";
    return null;
  }

  static String? validateTime(String? value) {
    if (value == null || value.isEmpty) return "Enter Time";
    return null;
  }

  static String? validateGlucose(String? value) {
    if (value == null || value.isEmpty) return "Enter glucose level";
    final num? glucose = num.tryParse(value);
    if (glucose == null) return "Must be a number";
    if (glucose < 1 || glucose > 500) return "Out of range (50–400)";
    return null;
  }
}
