import 'package:diabtech/screens/utils/constant.dart';
import 'package:diabtech/screens/widgets/custome_buttons.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Track Your Glucose",
      "desc": "Easily log and monitor your blood glucose levels daily.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Get AI Suggestions",
      "desc": "Receive smart health tips tailored for diabetes management.",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Stay on Top of Health",
      "desc": "Follow diet plans and track your overall progress.",
    },
  ];

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to Login Screen
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(_pages[index]["image"]!, height: 250),
                    const SizedBox(height: 30),
                    Text(
                      _pages[index]["title"]!,
                      style: AppTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        _pages[index]["desc"]!,
                        style: AppTextStyles.body.copyWith(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.all(4),
                width: _currentIndex == index ? 12 : 8,
                height: _currentIndex == index ? 12 : 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? AppColors.primary
                      : AppColors.textLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Next / Get Started Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: CustomButton(
              text: _currentIndex == _pages.length - 1 ? "Get Started" : "Next",
              onPressed: _nextPage,
            ),
          ),
        ],
      ),
    );
  }
}
