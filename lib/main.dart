import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'viewmodels/subscription_view_model.dart';
import 'viewmodels/profile_view_model.dart';
import 'viewmodels/settings_view_model.dart';
import 'viewmodels/analytics_view_model.dart';
import 'views/preloader_screen.dart';
import 'services/notification_service.dart';

import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SubscriptionViewModel()),
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
        ChangeNotifierProvider(create: (_) => AnalyticsViewModel()),
      ],
      child: const LifeSubscriptionApp(),
    ),
  );
}

class LifeSubscriptionApp extends StatelessWidget {
  const LifeSubscriptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = Provider.of<SettingsViewModel>(context);
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: MaterialApp(
        title: 'Life Subscription Constructor',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: settingsVM.settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
        home: const PreloaderScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
