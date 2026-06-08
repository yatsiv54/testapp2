import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../viewmodels/profile_view_model.dart';
import '../viewmodels/subscription_view_model.dart';
import '../theme/app_theme.dart';
import 'edit_profile_screen.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  double _calculateTotalMonthly(dynamic subscriptions) {
    double total = 0;
    for (var sub in subscriptions) {
      if (sub.periodicity == 'Monthly') {
        total += sub.amount;
      } else if (sub.periodicity == 'Yearly') {
        total += sub.amount / 12;
      } else if (sub.periodicity == 'Weekly') {
        total += sub.amount * 4.33;
      } else if (sub.periodicity == 'Daily') {
        total += sub.amount * 30;
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          )
        ],
      ),
      body: Consumer2<ProfileViewModel, SubscriptionViewModel>(
        builder: (context, profileVm, subVm, child) {
          if (profileVm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final profile = profileVm.profile;
          final totalSpend = _calculateTotalMonthly(subVm.subscriptions);

          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryAccent.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.account_circle_outlined, size: 80, color: AppTheme.secondaryAccent),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    Text(
                      'No profile setup yet',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Setup your profile to personalize the dashboard and analytics cards!',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                        );
                      },
                      child: const Text('Create Profile'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                // Glowing Avatar Circle
                Center(
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.premiumGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : Colors.white,
                        width: 4,
                      ),
                      image: profile.avatarPath != null 
                        ? DecorationImage(
                            image: FileImage(File(profile.avatarPath!)), 
                            fit: BoxFit.cover,
                          ) 
                        : null,
                    ),
                    child: profile.avatarPath == null
                      ? const Center(
                          child: Icon(
                            Icons.person_rounded, 
                            size: 64, 
                            color: Colors.white,
                          ),
                        )
                      : null,
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 24),

                // User Name
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 4),

                Text(
                  'Premium Member',
                  style: TextStyle(
                    color: AppTheme.primaryAccent,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 13,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 36),

                // Grid Stats Card
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: AppTheme.premiumShadow,
                  ),
                  child: Row(
                    children: [
                      // Stat item 1
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.secondaryAccent.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.list_alt_rounded, color: AppTheme.secondaryAccent, size: 24),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Tracked Items',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${subVm.subscriptions.length}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider
                      Container(
                        height: 60,
                        width: 1,
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                      ),

                      // Stat item 2
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryAccent.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.wallet_rounded, color: AppTheme.primaryAccent, size: 24),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Monthly Outflow',
                              style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${totalSpend.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Action buttons or list items
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: AppTheme.premiumShadow,
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit_rounded, color: AppTheme.primaryAccent),
                        title: const Text('Update Profile Details', style: TextStyle(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.security_rounded, color: AppTheme.secondaryAccent),
                        title: const Text('Account Status', style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text('Local storage secure'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 400.ms),
              ],
            ),
          );
        },
      ),
    );
  }
}
