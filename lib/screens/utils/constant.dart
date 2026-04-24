import 'package:flutter/material.dart';

/// 🎨 App-wide color palette
class AppColors {
  static const Color primary = Color(0xFF81C784); // green accent
  static const Color secondary = Color(0xFFFF9800); // orange accent
  static const Color background = Color(0xFFF5F5F5); // light grey background
  static const Color card = Colors.white; // default card background
  static const Color cardAlt = Color(0xFFF0F2F5); // alternate card bg
  static const Color textDark = Color(0xFF212121); // dark text
  static const Color textLight = Color(0xFFFFFFFF); // white text
  static const Color textGrey = Color(0xFF757575); // secondary text
  static const Color border = Color(0xFFBDBDBD); // light border
  static const Color success = Color(0xFF2ECC71); // Green
}

class AppConstants {
  static const String appName = "DiabTech";
  static const String onboarding1Title = "Track Glucose Easily";
  static const String onboarding2Title = "AI Smart Suggestions";
  static const String onboarding3Title = "Stay on Top of Health";
}

/// 🧊 Shadow styles for cards & containers
class AppShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];
}

/// ✍️ Text styles for headings, body, captions
class AppTextStyles {
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    letterSpacing: -0.5,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textGrey,
  );
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}

//Ready-to-use buttons
class AppButtons {
  static Widget primaryButton(String text, {VoidCallback? onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(text, style: AppTextStyles.button),
    );
  }

  static Widget outlinedButton(String text, {VoidCallback? onPressed}) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(color: AppColors.primary),
      ),
    );
  }
}
