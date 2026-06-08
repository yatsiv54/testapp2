import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/subscription_view_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../services/camera_service.dart';
import '../theme/app_theme.dart';
import 'onboarding_screen.dart';
import 'main_navigation.dart';

class PreloaderScreen extends StatefulWidget {
  const PreloaderScreen({super.key});

  @override
  State<PreloaderScreen> createState() => _PreloaderScreenState();
}

class _PreloaderScreenState extends State<PreloaderScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final settingsVM = Provider.of<SettingsViewModel>(context, listen: false);
    final subsVM = Provider.of<SubscriptionViewModel>(context, listen: false);
    final profileVM = Provider.of<ProfileViewModel>(context, listen: false);

    // Initialize dependencies
    await Future.wait([
      settingsVM.loadSettings(),
      subsVM.loadSubscriptions(),
      profileVM.loadProfile(),
      CameraService().init(),
    ]);

    // Give a little time for onboarding/shimmer/launch feel
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    
    if (settingsVM.settings.onboardingCompleted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    }
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
              : [const Color(0xFFFFFFFF), const Color(0xFFF3F4F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Widget
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.all_inclusive_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1800.ms, color: Colors.white.withValues(alpha: 0.3))
              .scale(
                begin: const Offset(0.9, 0.9), 
                end: const Offset(1.1, 1.1), 
                duration: 1200.ms, 
                curve: Curves.easeInOut,
              ),
              
              const SizedBox(height: 32),
              
              // App Title
              Text(
                'LIFE SUBSCRIPTION',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                  fontSize: 22,
                ),
              )
              .animate()
              .fadeIn(duration: 800.ms)
              .slideY(begin: 0.3, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),
              
              const SizedBox(height: 6),
              
              // App Subtitle
              Text(
                'CONSTRUCTOR',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6.0,
                  fontSize: 13,
                ),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 800.ms)
              .slideY(begin: 0.4, end: 0, duration: 800.ms, curve: Curves.easeOutCubic),

              const SizedBox(height: 60),

              // Elegant Custom Shimmer Line Indicator
              Container(
                width: 140,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.premiumGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 1500.ms),
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}
