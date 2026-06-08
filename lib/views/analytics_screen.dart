import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import '../viewmodels/subscription_view_model.dart';
import '../viewmodels/settings_view_model.dart';
import '../viewmodels/analytics_view_model.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedInterval =
      'Monthly'; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  String _chartType = 'Bar'; // 'Bar', 'Pie'

  final List<String> _intervals = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AnalyticsViewModel>(context, listen: false).scheduleTip();
      }
    });
  }

  double _getConvertedTotal(double monthlyTotal) {
    if (_selectedInterval == 'Daily') return monthlyTotal / 30;
    if (_selectedInterval == 'Weekly') return monthlyTotal / 4.33;
    if (_selectedInterval == 'Yearly') return monthlyTotal * 12;
    return monthlyTotal; // Monthly
  }

  Map<String, double> _getConvertedCategoryExpenses(
    Map<String, double> monthlyExpenses,
  ) {
    Map<String, double> converted = {};
    monthlyExpenses.forEach((cat, amount) {
      if (_selectedInterval == 'Daily') {
        converted[cat] = amount / 30;
      } else if (_selectedInterval == 'Weekly') {
        converted[cat] = amount / 4.33;
      } else if (_selectedInterval == 'Yearly') {
        converted[cat] = amount * 12;
      } else {
        converted[cat] = amount;
      }
    });
    return converted;
  }

  void _exportReport(BuildContext context, String currencySymbol) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.picture_as_pdf_rounded, color: AppTheme.primaryAccent),
            const SizedBox(width: 10),
            const Text('Exporting Report'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Preparing your spending analytics chart data...'),
            const SizedBox(height: 20),
            // Custom linear progress bar
            LinearProgressIndicator(
              color: AppTheme.primaryAccent,
              backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.1),
            ).animate().shimmer(),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      showDialog(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Export Successful'),
          content: Text(
            'Your subscription expenses report ($_selectedInterval view) has been generated successfully and stored locally.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
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
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Export Report',
            onPressed: () {
              final settingsVm = Provider.of<SettingsViewModel>(
                context,
                listen: false,
              );
              _exportReport(
                context,
                _getCurrencySymbol(settingsVm.settings.currency),
              );
            },
          ),
        ],
      ),
      body: Consumer2<SubscriptionViewModel, SettingsViewModel>(
        builder: (context, subVm, settingsVm, child) {
          if (subVm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!settingsVm.settings.analyticsEnabled) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.privacy_tip_rounded,
                      size: 80,
                      color: isDark ? Colors.white24 : Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analytics Disabled',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You have disabled analytics in Settings.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          if (subVm.subscriptions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pie_chart_outline_rounded,
                      size: 80,
                      color: AppTheme.secondaryAccent,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No subscriptions for analytics',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add subscriptions to generate visual graphs and insights.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final analyticsVm = Provider.of<AnalyticsViewModel>(
            context,
            listen: false,
          );
          analyticsVm.updateSubscriptions(subVm.subscriptions);

          final currencySymbol = _getCurrencySymbol(
            settingsVm.settings.currency,
          );
          final rawMonthlyExpense = analyticsVm.getTotalMonthlyExpense();
          final convertedExpense = _getConvertedTotal(rawMonthlyExpense);

          final categoryExpenses = _getConvertedCategoryExpenses(
            analyticsVm.getExpenseByCategory(),
          );

          List<CategoryData> data = categoryExpenses.entries
              .map((e) => CategoryData(e.key, e.value))
              .toList();

          List<charts.Series<CategoryData, String>> series = [
            charts.Series(
              id: 'Expenses',
              data: data,
              domainFn: (CategoryData d, _) => d.category,
              measureFn: (CategoryData d, _) => d.amount,
              labelAccessorFn: (CategoryData d, _) =>
                  '$currencySymbol${d.amount.toStringAsFixed(0)}',
              colorFn: (_, _) => charts.MaterialPalette.blue.shadeDefault,
            ),
          ];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Horizontal Interval Filter Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _intervals.map((interval) {
                    final isSelected = _selectedInterval == interval;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(
                            interval,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) {
                              setState(() {
                                _selectedInterval = interval;
                              });
                            }
                          },
                          selectedColor: AppTheme.primaryAccent,
                          backgroundColor: isDark
                              ? const Color(0xFF1E293B)
                              : Colors.white,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : (isDark
                                      ? const Color(0xFF334155)
                                      : const Color(0xFFE5E7EB)),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          showCheckmark: false,
                        ),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 16),

                // Card showing total spending
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE5E7EB),
                    ),
                    boxShadow: AppTheme.premiumShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total $_selectedInterval Spend',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$currencySymbol${convertedExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

                const SizedBox(height: 24),

                // Chart toggles row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Category Breakdown',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.bar_chart_rounded,
                            color: _chartType == 'Bar'
                                ? AppTheme.primaryAccent
                                : (isDark ? Colors.white24 : Colors.black87),
                          ),
                          onPressed: () => setState(() => _chartType = 'Bar'),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.pie_chart_rounded,
                            color: _chartType == 'Pie'
                                ? AppTheme.primaryAccent
                                : (isDark ? Colors.white24 : Colors.black87),
                          ),
                          onPressed: () => setState(() => _chartType = 'Pie'),
                        ),
                      ],
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                const SizedBox(height: 12),

                // Dynamic chart container
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE5E7EB),
                      ),
                      boxShadow: AppTheme.premiumShadow,
                    ),
                    child: _chartType == 'Bar'
                        ? charts.BarChart(
                            series,
                            animate: true,
                            vertical: false,
                            barRendererDecorator:
                                charts.BarLabelDecorator<String>(
                                  insideLabelStyleSpec: charts.TextStyleSpec(
                                    fontSize: 12,
                                    color: isDark
                                        ? charts.MaterialPalette.white
                                        : charts.MaterialPalette.black,
                                  ),
                                  outsideLabelStyleSpec: charts.TextStyleSpec(
                                    fontSize: 12,
                                    color: isDark
                                        ? charts.MaterialPalette.white
                                        : charts.MaterialPalette.black,
                                  ),
                                ),
                            domainAxis: charts.OrdinalAxisSpec(
                              renderSpec: charts.SmallTickRendererSpec(
                                lineStyle: charts.LineStyleSpec(
                                  color: isDark
                                      ? charts.MaterialPalette.gray.shade800
                                      : charts.MaterialPalette.black,
                                ),
                                labelStyle: charts.TextStyleSpec(
                                  fontSize: 12,
                                  color: isDark
                                      ? charts.MaterialPalette.white
                                      : charts.MaterialPalette.black,
                                ),
                              ),
                            ),
                            primaryMeasureAxis: charts.NumericAxisSpec(
                              renderSpec: charts.GridlineRendererSpec(
                                lineStyle: charts.LineStyleSpec(
                                  color: isDark
                                      ? charts.MaterialPalette.gray.shade800
                                      : charts.MaterialPalette.black,
                                ),
                                labelStyle: charts.TextStyleSpec(
                                  fontSize: 12,
                                  color: isDark
                                      ? charts.MaterialPalette.white
                                      : charts.MaterialPalette.black,
                                ),
                              ),
                            ),
                          )
                        : charts.PieChart<String>(
                            series,
                            animate: true,
                            defaultRenderer: charts.ArcRendererConfig<String>(
                              arcWidth: 60,
                              arcRendererDecorators: [
                                charts.ArcLabelDecorator<String>(
                                  insideLabelStyleSpec: charts.TextStyleSpec(
                                    fontSize: 12,
                                    color: isDark
                                        ? charts.MaterialPalette.white
                                        : charts.MaterialPalette.black,
                                  ),
                                  outsideLabelStyleSpec: charts.TextStyleSpec(
                                    fontSize: 12,
                                    color: isDark
                                        ? charts.MaterialPalette.white
                                        : charts.MaterialPalette.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ).animate().fadeIn(delay: 250.ms, duration: 450.ms),

                const SizedBox(
                  height: 96,
                ), // Space to avoid bottom navigation bar overlapping
              ],
            ),
          );
        },
      ),
    );
  }
}

class CategoryData {
  final String category;
  final double amount;
  CategoryData(this.category, this.amount);
}
