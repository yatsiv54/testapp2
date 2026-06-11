import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/subscription_view_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'preloader_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showCurrencyPicker(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption(context, vm, 'USD', 'US Dollar (\$)'),
            _buildCurrencyOption(context, vm, 'EUR', 'Euro (€)'),
            _buildCurrencyOption(context, vm, 'UAH', 'Ukrainian Hryvnia (₴)'),
            _buildCurrencyOption(context, vm, 'GBP', 'British Pound (£)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOption(BuildContext context, SettingsViewModel vm, String code, String label) {
    final isSelected = vm.settings.currency == code;
    return ListTile(
      title: Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryAccent) : null,
      onTap: () {
        vm.updateSettings(vm.settings.copyWith(currency: code));
        Navigator.pop(context);
      },
    );
  }

  Future<void> _showPrivacyPolicy(BuildContext context) async {
    final Uri url = Uri.parse('https://google.com');
    if (!await launchUrl(url)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch Privacy Policy')),
        );
      }
    }
  }

  void _shareApp(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    // ignore: deprecated_member_use
    Share.share(
      'Try this app! :) {APPSTORE_LINK}',
      sharePositionOrigin: box != null ? box.localToGlobal(Offset.zero) & box.size : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Consumer<SettingsViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final settings = vm.settings;
          
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 140), // 140 bottom padding to avoid overlapping floating navbar
            children: [
              // System configuration card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: AppTheme.premiumShadow,
                ),
                child: Material(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Receive payment alerts'),
                      secondary: const Icon(Icons.notifications_active_rounded, color: AppTheme.primaryAccent),
                      value: settings.notificationsEnabled,
                      activeThumbColor: AppTheme.primaryAccent,
                      onChanged: (val) async {
                        if (val) {
                          var status = await Permission.notification.request();
                          if (status.isPermanentlyDenied) {
                            await openAppSettings();
                            return;
                          }
                          if (!status.isGranted) return;
                        }
                        await vm.updateSettings(settings.copyWith(notificationsEnabled: val));
                        final notificationService = NotificationService();
                        if (!val) {
                          await notificationService.cancelAllNotifications();
                        } else {
                          if (!context.mounted) return;
                          final subVm = Provider.of<SubscriptionViewModel>(context, listen: false);
                          try {
                            for (var sub in subVm.subscriptions) {
                              if (sub.hasReminder) {
                                await notificationService.schedulePaymentReminder(sub);
                              }
                            }
                            await notificationService.scheduleOptimizationTip();
                          } catch (e) {
                            if (e.toString().contains('exact_alarms_not_permitted')) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please allow exact alarms in settings')),
                                );
                              }
                              await openAppSettings();
                            }
                          }
                        }
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Dark Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Saves battery & eye strain'),
                      secondary: const Icon(Icons.dark_mode_rounded, color: AppTheme.secondaryAccent),
                      value: settings.isDarkMode,
                      activeThumbColor: AppTheme.primaryAccent,
                      onChanged: (val) {
                        vm.updateSettings(settings.copyWith(isDarkMode: val));
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Manage Analytics', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Allow anonymous usage tracking'),
                      secondary: const Icon(Icons.query_stats_rounded, color: Colors.indigoAccent),
                      value: settings.analyticsEnabled,
                      activeThumbColor: AppTheme.primaryAccent,
                      onChanged: (val) {
                        vm.updateSettings(settings.copyWith(analyticsEnabled: val));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Currency Symbol', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: const Text('Used for displaying sums'),
                      leading: const Icon(Icons.monetization_on_rounded, color: Colors.amber),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            settings.currency, 
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryAccent, fontSize: 16),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ],
                      ),
                      onTap: () => _showCurrencyPicker(context, vm),
                    ),
                  ],
                ),
                ),
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // Engagement and About card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: AppTheme.premiumShadow,
                ),
                child: Material(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('Share App', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Send app to friends'),
                        leading: const Icon(Icons.share_rounded, color: Colors.blue),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _shareApp(context),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('How we secure your data'),
                        leading: const Icon(Icons.privacy_tip_rounded, color: Colors.teal),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _showPrivacyPolicy(context),
                      ),
                      const Divider(height: 1),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final version = snapshot.hasData ? 'v${snapshot.data!.version}' : 'v...';
                          return ListTile(
                            title: const Text('App Version', style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: const Text('Check currently installed version'),
                            leading: const Icon(Icons.info_outline_rounded, color: Colors.purple),
                            trailing: Text(
                              version, 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('You are on the latest version ($version).'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

              const SizedBox(height: 20),

              // Danger Zone card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                  ),
                  boxShadow: AppTheme.premiumShadow,
                ),
                child: Material(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                  title: const Text('Reset All Local Data', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Permanently delete all tracking histories'),
                  leading: const Icon(Icons.delete_forever_rounded, color: AppTheme.error),
                  textColor: AppTheme.error,
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.error),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Confirm Full Reset?'),
                        content: const Text('This will delete all saved subscriptions, notification schedules, settings, and profile details. This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Text('Reset', style: TextStyle(color: AppTheme.error)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await StorageService().clearAll();
                      if (context.mounted) {
                        Provider.of<SubscriptionViewModel>(context, listen: false).loadSubscriptions();
                        Provider.of<SubscriptionViewModel>(context, listen: false).loadSubscriptions();
                        Provider.of<ProfileViewModel>(context, listen: false).loadProfile();
                        Navigator.of(context, rootNavigator: true).pushReplacement(
                          MaterialPageRoute(builder: (_) => const PreloaderScreen())
                        );
                      }
                    }
                  },
                ),
                ),
              ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
            ],
          );
        },
      ),
    );
  }
}
