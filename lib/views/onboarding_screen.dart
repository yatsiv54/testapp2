import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodels/settings_view_model.dart';
import '../theme/app_theme.dart';
import 'main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "title": "Welcome to Life Subscription Constructor",
      "description": "Manage all your subscriptions and life commitments in one place with a beautiful visual manager.",
      "icon": Icons.all_inclusive_rounded,
      "gradient": AppTheme.premiumGradient,
    },
    {
      "title": "Visual Tracking",
      "description": "Snap photos or snap logos using your device camera to easily recognize your subscriptions on cards.",
      "icon": Icons.camera_enhance_rounded,
      "gradient": AppTheme.primaryGradient,
    },
    {
      "title": "Stay on Top of Expenses",
      "description": "Get detailed, visually appealing analytics charts and personalized payment notifications.",
      "icon": Icons.insights_rounded,
      "gradient": AppTheme.accentGradient,
    }
  ];

  void _completeOnboarding() {
    Provider.of<SettingsViewModel>(context, listen: false).completeOnboarding();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFF9FAFB), const Color(0xFFF3F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: isDark ? Colors.white60 : Colors.black54,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    final item = onboardingData[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Glowing Icon Container
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              gradient: item["gradient"] as Gradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (item["gradient"] as LinearGradient).colors.first.withValues(alpha: 0.35),
                                  blurRadius: 30,
                                  offset: const Offset(0, 15),
                                )
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                item["icon"] as IconData,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          )
                          .animate(key: ValueKey(index))
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.7, 0.7), duration: 600.ms, curve: Curves.easeOutBack),
                          
                          const SizedBox(height: 48),
                          
                          // Slide Title
                          Text(
                            item["title"]!,
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate(key: ValueKey('title_$index'))
                          .fadeIn(delay: 150.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
                          
                          const SizedBox(height: 20),
                          
                          // Slide Description
                          Text(
                            item["description"]!,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[700],
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          )
                          .animate(key: ValueKey('desc_$index'))
                          .fadeIn(delay: 300.ms, duration: 600.ms)
                          .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOutQuad),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Custom Indicator & Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Expandable Indicators
                    Row(
                      children: List.generate(
                        onboardingData.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: _currentPage == index 
                              ? AppTheme.premiumGradient
                              : null,
                            color: _currentPage == index 
                              ? null 
                              : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    
                    // Next / Action Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ).copyWith(
                        backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
                      ),
                      onPressed: () {
                        if (_currentPage == onboardingData.length - 1) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOutCubic,
                          );
                        }
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: AppTheme.premiumGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == onboardingData.length - 1 ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
