import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../viewmodels/subscription_view_model.dart';
import '../viewmodels/profile_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../theme/app_theme.dart';
import 'create_edit_subscription_screen.dart';
import 'subscription_detail_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _getDaysRemainingText(DateTime nextPayment) {
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final payment = DateTime(
      nextPayment.year,
      nextPayment.month,
      nextPayment.day,
    );
    final difference = payment.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference < 0) return 'Overdue';
    return 'In $difference days';
  }

  Color _getDaysRemainingColor(DateTime nextPayment, BuildContext context) {
    final now = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final payment = DateTime(
      nextPayment.year,
      nextPayment.month,
      nextPayment.day,
    );
    final difference = payment.difference(now).inDays;

    if (difference == 0) return AppTheme.error;
    if (difference == 1) return AppTheme.warning;
    if (difference < 0) return Colors.grey;
    return Theme.of(context).primaryColor;
  }

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

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'EUR':
        return '€';
      case 'UAH':
        return '₴';
      case 'GBP':
        return '£';
      default:
        return '\$';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Consumer3<SubscriptionViewModel, ProfileViewModel, SettingsViewModel>(
        builder: (context, subVm, profileVm, settingsVm, child) {
          final profile = profileVm.profile;
          final userName = profile?.name ?? 'Guest';
          final avatarPath = profile?.avatarPath;
          final currencySymbol = _getCurrencySymbol(
            settingsVm.settings.currency,
          );

          // Compute total monthly spending
          final totalSpending = _calculateTotalMonthly(subVm.subscriptions);

          final upcoming = subVm.subscriptions.toList()
            ..sort((a, b) => a.nextPaymentDate.compareTo(b.nextPaymentDate));

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Premium Custom AppBar with Welcome
              SliverAppBar(
                expandedHeight: 100.0,
                floating: false,
                pinned: true,
                stretch: true,
                backgroundColor: isDark
                    ? const Color(0xFF0F172A)
                    : AppTheme.lightBg,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  'Hello, $userName 👋',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(fontSize: 24),
                                )
                                .animate()
                                .fadeIn(duration: 500.ms)
                                .slideX(begin: -0.1, end: 0),
                            const SizedBox(height: 4),
                            Text(
                              'Control your expenses in real-time',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                          ],
                        ),
                        // Profile Avatar
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserProfileScreen(),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryAccent,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryAccent.withValues(alpha: 
                                    0.2,
                                  ),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundImage: avatarPath != null
                                  ? FileImage(File(avatarPath))
                                  : null,
                              child: avatarPath == null
                                  ? const Icon(Icons.person, size: 24)
                                  : null,
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms).scale(),
                      ],
                    ),
                  ),
                ),
              ),

              // Total Expense Overview Card
              SliverToBoxAdapter(
                child:
                    Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 10.0,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              gradient: AppTheme.premiumGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryAccent.withValues(alpha: 
                                    0.35,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Estimated Monthly Spend',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${subVm.subscriptions.length} Active',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '$currencySymbol${totalSpending.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Life Subscription Constructor',
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const CreateEditSubscriptionScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.add_rounded,
                                              size: 16,
                                              color: AppTheme.primaryAccent,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Add New',
                                              style: TextStyle(
                                                color: AppTheme.primaryAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(delay: 200.ms, duration: 600.ms)
                        .scale(begin: const Offset(0.95, 0.95)),
              ),

              // Title: Upcoming Payments
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Payments',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // Subscriptions List
              if (subVm.isLoading)
                const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (subVm.subscriptions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 80,
                          color: AppTheme.secondaryAccent,
                        ).animate().scale(
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No subscriptions added yet',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the button above or below to construct your first subscription reminder!',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const CreateEditSubscriptionScreen(),
                              ),
                            );
                          },
                          child: const Text('Add subscription'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    140,
                  ), // 140 bottom padding to avoid overlapping floating navbar
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final sub = upcoming[index];
                      final daysText = _getDaysRemainingText(
                        sub.nextPaymentDate,
                      );
                      final daysColor = _getDaysRemainingColor(
                        sub.nextPaymentDate,
                        context,
                      );

                      return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E293B)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                              boxShadow: AppTheme.premiumShadow,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            SubscriptionDetailScreen(
                                              subscriptionId: sub.id,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        // Service Logo/Photo
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isDark
                                                  ? const Color(0xFF334155)
                                                  : const Color(0xFFE5E7EB),
                                            ),
                                            image: sub.logoPath != null
                                                ? DecorationImage(
                                                    image: FileImage(
                                                      File(sub.logoPath!),
                                                    ),
                                                    fit: BoxFit.cover,
                                                  )
                                                : null,
                                          ),
                                          child: sub.logoPath == null
                                              ? CircleAvatar(
                                                  backgroundColor: AppTheme
                                                      .primaryAccent
                                                      .withValues(alpha: 0.25),
                                                  child: Text(
                                                    sub.name[0].toUpperCase(),
                                                    style: const TextStyle(
                                                      color: AppTheme
                                                          .primaryAccent,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),

                                        // Middle Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                sub.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              // Category Tag Chip
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme
                                                      .secondaryAccent
                                                      .withValues(alpha: 0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  sub.category,
                                                  style: const TextStyle(
                                                    color: AppTheme
                                                        .secondaryAccent,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Right Cost & Days Badge
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '$currencySymbol${sub.amount.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: daysColor.withValues(alpha: 
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                daysText,
                                                style: TextStyle(
                                                  color: daysColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (50 * index).ms, duration: 400.ms)
                          .slideY(
                            begin: 0.1,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          );
                    }, childCount: upcoming.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
