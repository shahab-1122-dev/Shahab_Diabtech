import 'package:diabtech/screens/auth/login_screen.dart';
import 'package:diabtech/screens/auth/signup_screen.dart';
import 'package:diabtech/screens/home/homeScreen.dart';
import 'package:diabtech/screens/onboarding/onboarding_Screen.dart';
import 'package:diabtech/screens/splashScreen/splash_Screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diabetech',
      debugShowCheckedModeBanner: false,
      initialRoute: 'spalsh',
      routes: {
        'spalsh': (context) => const SplashScreen(),
        'onboarding': (context) => const OnboardingScreen(),
        'login': (context) => const LoginScreen(),
        'signupscreen': (context) => const SignupScreen(),
        'homescreen': (context) => const HomeScreen(),
      },
    );
  }
}

// lib/
// │── main.dart
// │
// ├── screens/                  # All app screens
// │   ├── onboarding/           # Intro screens for first-time users
// │   │   ├── onboarding_screen.dart
// │   │
// │   ├── auth/                 # Login & Signup
// │   │   ├── login_screen.dart
// │   │   ├── signup_screen.dart
// │   │
// │   ├── home/                 # Dashboard
// │   │   ├── home_screen.dart
// │   │
// │   ├── input/                # User input screens
// │   │   ├── glucose_input_screen.dart
// │   │   ├── daily_log_screen.dart
// │   │
// │   ├── progress/             # Graphs & charts
// │   │   ├── progress_screen.dart
// │   │
// │   ├── suggestions/          # AI tips & diet suggestions
// │   │   ├── suggestions_screen.dart
// │   │
// │   ├── profile/              # User profile & settings
// │   │   ├── profile_screen.dart
// │
// ├── widgets/                  # Reusable widgets
// │   ├── custom_card.dart
// │   ├── chart_widget.dart
// │   ├── input_field.dart
// │
// ├── services/                 # Logic & APIs
// │   ├── auth_service.dart     # Firebase auth / login system
// │   ├── ai_service.dart       # AI tips (dummy or API)
// │   ├── db_service.dart       # Firebase / local database
// │
// ├── models/                   # Data models
// │   ├── user_model.dart
// │   ├── glucose_entry.dart
// │   ├── daily_log.dart
// │
// ├── utils/                    # Helpers
// │   ├── constants.dart        # App colors, strings
// │   ├── validators.dart       # Input validation functions
// │
// ├── assets/                   # Images, icons, fonts
// │   ├── images/
// │   │   ├── logo.png
// │   ├── icons/


// How many screens?
// Core (12 screens)

// Splash

// Onboarding (single screen with 3 slides)

// Login

// Signup

// Home / Dashboard

// Add Glucose Reading

// History (Logs List + Filters)

// Trends / Charts

// Reminders (List)

// Create / Edit Reminder

// Diet & Meal Planner (suggestions + daily tracking)

// Profile & Settings (includes export/share reports)

// Optional (+3 if you have time)

// Weekly/Monthly Report Preview (PDF-style with share/export)

// Activity Tracker (steps/exercise log; can be merged into Diet screen as a tab)

// Doctor Share / Connected Care (pick range → share via email/whatsapp)

// You can complete the course project strongly with the core 12. Add the optional ones only if time permits.

// Step-by-step UI design plan

// Below I list each screen with: purpose → layout → key widgets → states/validations → navigation.

// 1) Splash

// Purpose: brief brand intro then route to Onboarding or Login.
// Layout: Center logo + app name + subtle fade.
// Widgets: Image, Text, fade animation.
// State: none; 2–3s timer.
// Nav: Splash → Onboarding (first run) or Login (if seen before).

// 2) Onboarding (3 slides in one screen)

// Purpose: explain value props.
// Layout: PageView (image, title, subtitle), dots, Next/Get Started button.
// Widgets: PageView, dots indicator, CTA button.
// State: current page index.
// Nav: Onboarding → Login.

// 3) Login

// Purpose: authenticate user.
// Layout: Logo, title, Email, Password, Login btn, “Forgot password?”, “Create account”.
// Widgets: TextFormField(email/password), visibility toggle, primary button.
// Validation: email format, min password length.
// Nav: Login → Home on success; link to Signup.

// 4) Signup

// Purpose: create account.
// Layout: Name, Email, Password, Confirm, Create Account button.
// Validation: required fields, email format, password match.
// Nav: Signup → Home.

// 5) Home / Dashboard (you’ve designed this ✅)

// Purpose: at-a-glance health snapshot.
// Layout:

// Header: greeting + date

// Glucose card: current reading + status chip + add button

// Quick Stats grid: average, time-in-range, insulin units, carbs

// Coming Up: next reminder/lunch

// Insights: small tip cards
// Widgets: Cards with shadow, chips, primary accent for actions.
// State: none yet (dummy data ok).
// Nav: Add (+) → Add Glucose; tabs → History/Trends/Reminders/Profile.

// 6) Add Glucose Reading

// Purpose: log a reading quickly.
// Layout: Value (mg/dL) numeric field, Date/Time pickers, optional note, Save.
// Widgets: TextFormField(number), DatePicker, TimePicker, Save button.
// Validation: value required & within reasonable range (e.g., 40–500).
// Nav: Save → back to Home; maybe snackbar “Saved”.

// 7) History (Logs List + Filters)

// Purpose: browse past readings.
// Layout:

// Top filter row (Date range, Type: fasting/post-meal/all)

// List of entries (value, time, tag, note dot)

// Bulk actions (optional)
// Widgets: segmented filter chips, list tiles, empty state.
// State: active filters, fetched list.
// Nav: Tap item → edit entry (optional small bottom sheet).

// 8) Trends / Charts

// Purpose: visualize progress.
// Layout: range selector (7/14/30 days), line chart (glucose), cards (avg, min, max, time-in-range).
// Widgets: chart (use fl_chart/syncfusion_flutter_charts), stat chips.
// State: selected range.
// Nav: none; back to Home via bottom nav.

// 9) Reminders (List)

// Purpose: manage insulin/meds/meal reminders.
// Layout: top “+ New Reminder”, list with time + type + toggle enable.
// Widgets: list tiles, switch/toggle, FAB or header button.
// State: reminder on/off.
// Nav: New Reminder → Create/Edit Reminder.

// 10) Create / Edit Reminder

// Purpose: schedule alerts.
// Layout: Type (insulin/meds/meal), Time picker, Frequency (once/daily/custom), optional dosage/notes, Save.
// Widgets: dropdown/segmented control, pickers, save.
// Validation: time & type required.
// Nav: Save → Reminders list.

// 11) Diet & Meal Planner

// Purpose: diabetic-friendly suggestions + daily tracking.
// Layout:

// Tabs: Suggestions | My Meals

// Suggestions: cards (breakfast/lunch/dinner/snacks) with carb counts

// My Meals: add meal (name, carbs, photo optional), today’s list with totals
// Widgets: tabs, cards, add meal bottom sheet.
// State: selected tab, meals of today.
// Nav: none, back via bottom nav.

// 12) Profile & Settings

// Purpose: user info + app preferences + data export.
// Layout: avatar & name/email, sections: Account, Notifications, Data & Reports (Export/Share), About.
// Widgets: list tiles, toggles, export button.
// State: none.
// Nav: Export → (optional) Report Preview.

// (Optional) 13) Report Preview

// Purpose: see weekly/monthly report before sharing.
// Layout: header stats, mini charts, recent logs; Share/Export buttons.
// Widgets: static preview, share sheet.
// Nav: back to Profile.

// Design system (to match your current style)

// Grid: 8-pt spacing; common gaps 8/12/16/20.

// Corner radius: 12–16 for cards & inputs.

// Shadows: soft single shadow (the one you already use in AppShadows.card).

// Colors: from your AppColors (primary green, light backgrounds, subtle borders).

// Type scale:

// Display: 28/bold (dashboard big number)

// H1: 24/bold

// H2: 20/semibold

// H3: 18/semibold

// Body: 14/regular

// Caption: 12/regular

// Chips: rounded 20, tinted backgrounds (success/primary with 15% opacity).

// Buttons: solid primary for CTAs; outlined for secondary.

// Navigation map (named routes suggestion)
// 'splash'           → SplashScreen
// 'onboarding'       → OnboardingScreen
// 'login'            → LoginScreen
// 'signup'           → SignupScreen
// 'homescreen'       → HomeScreen (bottom nav)

// -- bottom nav destinations --
// 'history'          → HistoryScreen
// 'trends'           → TrendsScreen
// 'reminders'        → RemindersScreen
// 'profile'          → ProfileScreen

// -- flows --
// 'add-reading'      → AddReadingScreen
// 'reminder-edit'    → ReminderEditScreen
// 'diet'             → DietPlannerScreen
// 'report-preview'   → ReportPreviewScreen (optional)

// What to design/build next (recommended order)

// Add Glucose Reading (quick win, ties to Home).

// History (so new entries are visible).

// Trends (line chart, basic stats).

// Reminders List + Create/Edit (notifications).

// Diet & Meal Planner (basic suggestions + daily log).

// Profile/Settings (export/share stub).

// If you want, I can now draft the AddReadingScreen UI (clean card layout with numeric input, date/time pickers, tags for “Fasting / Before Meal / After Meal”) in Flutter so you can plug it in.