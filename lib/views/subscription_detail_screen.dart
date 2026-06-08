import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../viewmodels/subscription_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../theme/app_theme.dart';
import 'create_edit_subscription_screen.dart';

class SubscriptionDetailScreen extends StatelessWidget {
  final String subscriptionId;

  const SubscriptionDetailScreen({super.key, required this.subscriptionId});

  double _calculateYearlyCost(double amount, String periodicity) {
    if (periodicity == 'Monthly') return amount * 12;
    if (periodicity == 'Yearly') return amount;
    if (periodicity == 'Weekly') return amount * 52;
    if (periodicity == 'Daily') return amount * 365;
    return amount;
  }

  String _getCurrencySymbol(String code) {
    switch (code) {
      case 'EUR': return '€';
      case 'UAH': return '₴';
      case 'GBP': return '£';
      default: return '\$';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<SubscriptionViewModel, SettingsViewModel>(
      builder: (context, vm, settingsVm, child) {
        final subIndex = vm.subscriptions.indexWhere((s) => s.id == subscriptionId);
        if (subIndex == -1) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('Subscription not found')),
          );
        }
        
        final sub = vm.subscriptions[subIndex];
        final yearlyCost = _calculateYearlyCost(sub.amount, sub.periodicity);
        final currencySymbol = _getCurrencySymbol(settingsVm.settings.currency);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Subscription Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateEditSubscriptionScreen(existingSubscription: sub),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Delete Subscription?'),
                      content: Text('Are you sure you want to delete "${sub.name}"? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await vm.deleteSubscription(sub.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Premium Service Photo Container
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.premiumGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.25),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        )
                      ],
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : Colors.white,
                        width: 4,
                      ),
                      image: sub.logoPath != null
                        ? DecorationImage(
                            image: FileImage(File(sub.logoPath!)), 
                            fit: BoxFit.cover,
                          )
                        : null,
                    ),
                    child: sub.logoPath == null
                      ? const Center(
                          child: Icon(
                            Icons.all_inclusive_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        )
                      : null,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 24),

                // Name & Category Badge
                Text(
                  sub.name,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryAccent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    sub.category.toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.secondaryAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 1.0,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 32),

                // Expense Simulator Card
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.query_stats_rounded, color: Colors.white70, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'ANNUAL COST SIMULATION',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$currencySymbol${yearlyCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Based on $currencySymbol${sub.amount.toStringAsFixed(2)} ${sub.periodicity.toLowerCase()} rate',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 550.ms).scale(begin: const Offset(0.95, 0.95)),

                const SizedBox(height: 24),

                // Details Card
                Container(
                  padding: const EdgeInsets.all(20.0),
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
                      _buildDetailRow(context, 'Billing Amount', '$currencySymbol${sub.amount.toStringAsFixed(2)}', Icons.attach_money_rounded, currencySymbol),
                      const Divider(height: 24),
                      _buildDetailRow(context, 'Billing Period', sub.periodicity, Icons.repeat_rounded, currencySymbol),
                      const Divider(height: 24),
                      _buildDetailRow(
                        context, 
                        'Next Payment Date', 
                        '${sub.nextPaymentDate.day}/${sub.nextPaymentDate.month}/${sub.nextPaymentDate.year}', 
                        Icons.calendar_month_rounded,
                        currencySymbol,
                      ),
                      const Divider(height: 24),
                      // Status Change Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: (sub.status == 'Active' ? AppTheme.success : (sub.status == 'Paused' ? AppTheme.warning : Colors.grey)).withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.info_outline_rounded, 
                                  color: sub.status == 'Active' ? AppTheme.success : (sub.status == 'Paused' ? AppTheme.warning : Colors.grey), 
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Status', 
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ],
                          ),
                          DropdownButton<String>(
                            value: sub.status,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.arrow_drop_down_rounded),
                            items: ['Active', 'Paused', 'Archived'].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontWeight: FontWeight.bold)))).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                vm.changeSubscriptionStatus(sub.id, val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Status changed to $val'),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      // Reminder Toggle Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryAccent.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.notifications_active_rounded, 
                                  color: AppTheme.primaryAccent, 
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Payment Reminder', 
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                            ],
                          ),
                          Switch(
                            value: sub.hasReminder,
                            activeThumbColor: AppTheme.primaryAccent,
                            onChanged: (val) {
                              vm.updateSubscription(sub.copyWith(hasReminder: val));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(val ? 'Reminder enabled!' : 'Reminder disabled.'),
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, IconData icon, String currencySymbol) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.secondaryAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.secondaryAccent, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              label, 
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey[800], 
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
        Text(
          value, 
          style: const TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
