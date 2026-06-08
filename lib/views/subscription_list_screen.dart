import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../viewmodels/subscription_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../models/subscription.dart';
import '../theme/app_theme.dart';
import 'subscription_detail_screen.dart';
import 'create_edit_subscription_screen.dart';

class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';
  String _searchQuery = '';
  String _sortBy = 'Date'; // 'Date', 'Amount', 'Name'
  bool _sortAscending = true;

  final List<String> _categories = ['All', 'General', 'Entertainment', 'Work', 'Health', 'Education'];
  final List<String> _statuses = ['All', 'Active', 'Paused', 'Archived'];

  List<Subscription> _getProcessedSubscriptions(List<Subscription> subs) {
    // 1. Filter by category
    var filtered = subs.where((sub) {
      final categoryMatch = _selectedCategory == 'All' || sub.category == _selectedCategory;
      final statusMatch = _selectedStatus == 'All' || sub.status == _selectedStatus;
      final searchMatch = sub.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return categoryMatch && statusMatch && searchMatch;
    }).toList();

    // 2. Sort
    filtered.sort((a, b) {
      int comparison = 0;
      if (_sortBy == 'Date') {
        comparison = a.nextPaymentDate.compareTo(b.nextPaymentDate);
      } else if (_sortBy == 'Amount') {
        comparison = a.amount.compareTo(b.amount);
      } else if (_sortBy == 'Name') {
        comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Subscriptions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEditSubscriptionScreen()),
              );
            },
          )
        ],
      ),
      body: Consumer2<SubscriptionViewModel, SettingsViewModel>(
        builder: (context, vm, settingsVm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final processed = _getProcessedSubscriptions(vm.subscriptions);
          final currencySymbol = _getCurrencySymbol(settingsVm.settings.currency);

          return Column(
            children: [
              // Search & Sort Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Search Field
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search_rounded, size: 20),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                            labelStyle: Theme.of(context).inputDecorationTheme.labelStyle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Sort Menu Button
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: const Icon(Icons.sort_rounded, color: AppTheme.primaryAccent),
                        tooltip: 'Sort list',
                        onSelected: (String val) {
                          setState(() {
                            if (_sortBy == val) {
                              _sortAscending = !_sortAscending;
                            } else {
                              _sortBy = val;
                              _sortAscending = true;
                            }
                          });
                        },
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem(
                            value: 'Date',
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 16, color: _sortBy == 'Date' ? AppTheme.primaryAccent : Colors.grey),
                                const SizedBox(width: 8),
                                const Text('By Date'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Amount',
                            child: Row(
                              children: [
                                Icon(Icons.attach_money_rounded, size: 16, color: _sortBy == 'Amount' ? AppTheme.primaryAccent : Colors.grey),
                                const SizedBox(width: 8),
                                const Text('By Amount'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'Name',
                            child: Row(
                              children: [
                                Icon(Icons.title_rounded, size: 16, color: _sortBy == 'Name' ? AppTheme.primaryAccent : Colors.grey),
                                const SizedBox(width: 8),
                                const Text('By Name'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Horizontal Category Chips
              Container(
                height: 44,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                        selectedColor: AppTheme.primaryAccent,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        side: BorderSide(
                          color: isSelected 
                            ? Colors.transparent 
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),

              // Horizontal Status Chips
              Container(
                height: 36,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _statuses.length,
                  itemBuilder: (context, index) {
                    final status = _statuses[index];
                    final isSelected = _selectedStatus == status;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                          status,
                          style: TextStyle(
                            color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          }
                        },
                        selectedColor: AppTheme.secondaryAccent,
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        side: BorderSide(
                          color: isSelected 
                            ? Colors.transparent 
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  },
                ),
              ),

              // List View
              Expanded(
                child: processed.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.find_in_page_rounded,
                              size: 70,
                              color: AppTheme.secondaryAccent,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subscriptions match filters',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text('Try changing search or category'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96), // 96 bottom padding to avoid overlapping floating navbar
                        itemCount: processed.length,
                        itemBuilder: (context, index) {
                          final sub = processed[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                              ),
                              boxShadow: AppTheme.premiumShadow,
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
                                  image: sub.logoPath != null
                                    ? DecorationImage(image: FileImage(File(sub.logoPath!)), fit: BoxFit.cover)
                                    : null,
                                ),
                                child: sub.logoPath == null
                                  ? CircleAvatar(
                                      backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.25),
                                      child: Text(
                                        sub.name[0].toUpperCase(),
                                        style: const TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : null,
                              ),
                              title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Row(
                                children: [
                                  Text(sub.category, style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 13)),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: sub.status == 'Active' ? AppTheme.success.withValues(alpha: 0.1) : (sub.status == 'Paused' ? AppTheme.warning.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1)),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      sub.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: sub.status == 'Active' ? AppTheme.success : (sub.status == 'Paused' ? AppTheme.warning : Colors.grey),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '$currencySymbol${sub.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    sub.periodicity,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => SubscriptionDetailScreen(subscriptionId: sub.id)),
                                );
                              },
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (40 * index).ms, duration: 350.ms)
                          .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
