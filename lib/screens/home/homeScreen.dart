// ignore: file_names
import 'package:diabtech/screens/profile/profile_screen.dart';
import 'package:diabtech/screens/progress/progressScreen.dart';
import 'package:diabtech/screens/suggestion/suggestions.dart';
import 'package:flutter/material.dart';
import 'package:diabtech/screens/glucose_input_screen/inputGlocoseLevel.dart';
import 'package:diabtech/screens/glucose_input_screen/logHistoryScreen.dart';
import 'package:diabtech/screens/utils/constant.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Tabs (screens) for bottom navigation
  final List<Widget> _screens = [
    const _DashboardTab(),
    Inputglocoselevel(),
    LogHistoryScreen(),
    Progressscreen(),
    Suggestions(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDark,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "Add"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            label: "Charts",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tips_and_updates),
            label: "Tips",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

/* ---------------- Dashboard Tab (your old Home content) ---------------- */
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(name: "Sarah", dateText: "Monday, February 12"),
            const SizedBox(height: 16),
            _GlucoseCard(
              valueMgDl: 112,
              status: "Normal Range",
              lastUpdated: "5 mins ago",
              onAddPressed: () {
                // If you want, you can jump to Add tab:
                // DefaultTabController.of(context).animateTo(1);
              },
            ),
            const SizedBox(height: 16),
            _SectionTitle("Quick Stats"),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _StatCard(
                  icon: Icons.show_chart,
                  value: "120 mg/dL",
                  title: "Daily Average",
                ),
                _StatCard(
                  icon: Icons.timeline_outlined,
                  value: "75%",
                  title: "Time in Range",
                ),
                _StatCard(
                  icon: Icons.water_drop_outlined,
                  value: "12.5 U",
                  title: "Insulin Units",
                ),
                _StatCard(
                  icon: Icons.rice_bowl_outlined,
                  value: "180 g",
                  title: "Carbs Tracked",
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SectionTitle("Coming Up"),
            const SizedBox(height: 8),
            const _UpcomingItem(
              icon: Icons.add_box_outlined,
              title: "Insulin Shot",
              time: "12:30 PM",
            ),
            const SizedBox(height: 10),
            const _UpcomingItem(
              icon: Icons.lunch_dining_outlined,
              title: "Lunch",
              time: "1:00 PM",
            ),
            const SizedBox(height: 20),
            _SectionTitle("Your Insights"),
            const SizedBox(height: 8),
            Row(
              children: const [
                Expanded(
                  child: _InsightCard(
                    icon: Icons.show_chart_outlined,
                    title: "Glucose Pattern",
                    subtitle: "Your levels are stable",
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _InsightCard(
                    icon: Icons.access_time,
                    title: "Time Analysis",
                    subtitle: "Check before meals",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ----------------- Small reusable widgets (unchanged) ----------------- */

class _Header extends StatelessWidget {
  final String name;
  final String dateText;
  const _Header({required this.name, required this.dateText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome back, $name", style: AppTextStyles.heading2),
        const SizedBox(height: 4),
        Text(dateText, style: AppTextStyles.caption),
      ],
    );
  }
}

class _GlucoseCard extends StatelessWidget {
  final int valueMgDl;
  final String status;
  final String lastUpdated;
  final VoidCallback onAddPressed;

  const _GlucoseCard({
    required this.valueMgDl,
    required this.status,
    required this.lastUpdated,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(.15), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.card,
        border: Border.all(color: AppColors.border.withOpacity(.4)),
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$valueMgDl",
                style: AppTextStyles.display.copyWith(
                  color: AppColors.textDark,
                  fontSize: 44,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text("mg/dL", style: AppTextStyles.body),
              ),
            ],
          ),
          Positioned(
            top: 8,
            right: 8,
            child: InkWell(
              onTap: onAddPressed,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add, color: AppColors.primary),
              ),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                status,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 0,
            child: Text(
              "Last updated $lastUpdated",
              style: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String title;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(height: 5),
          Text(value, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _UpcomingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String time;
  const _UpcomingItem({
    required this.icon,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            height: 36,
            width: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.cardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.heading3);
  }
}

// class _BottomNav extends StatelessWidget {
//   final int currentIndex;
//   const _BottomNav({required this.currentIndex});

//   @override
//   Widget build(BuildContext context) {
//     return BottomNavigationBar(
//       currentIndex: currentIndex,
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: AppColors.textDark,
//       items: const [
//         BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
//         BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.bar_chart_outlined),
//           label: "Charts",
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.tips_and_updates),
//           label: "tips",
//         ),
//         BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//       ],
//       onTap: (i) {
//         // TODO: handle navigation (e.g., with a bottom-nav controller)
//       },
//     );
//   }
// }

// import 'package:diabtech/screens/utils/constant.dart';
// import 'package:flutter/material.dart';

// class Homescreen extends StatefulWidget {
//   const Homescreen({super.key});

//   @override
//   State<Homescreen> createState() => _HomescreenState();
// }

// class _HomescreenState extends State<Homescreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Welcome back, Sarah",
//                   style: AppTextStyles.heading1.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 Text("Monday, February 12", style: AppTextStyles.body),
//                 Image.asset('assets/images/BP.png'),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
