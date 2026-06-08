import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/notification_service.dart';

class AnalyticsViewModel extends ChangeNotifier {
  List<Subscription> _subscriptions = [];
  
  void updateSubscriptions(List<Subscription> subs) {
    _subscriptions = subs;
  }

  void scheduleTip() {
    NotificationService().scheduleOptimizationTip();
  }

  double _getMonthlyAmount(Subscription sub) {
    if (sub.periodicity == 'Monthly') return sub.amount;
    if (sub.periodicity == 'Yearly') return sub.amount / 12;
    if (sub.periodicity == 'Weekly') return (sub.amount * 52) / 12;
    if (sub.periodicity == 'Daily') return (sub.amount * 365) / 12;
    return sub.amount;
  }

  double getTotalMonthlyExpense() {
    double total = 0;
    for (var sub in _subscriptions) {
      total += _getMonthlyAmount(sub);
    }
    return total;
  }

  Map<String, double> getExpenseByCategory() {
    Map<String, double> categoryExpense = {};
    for (var sub in _subscriptions) {
      double amountMonthly = _getMonthlyAmount(sub);
      categoryExpense[sub.category] = (categoryExpense[sub.category] ?? 0) + amountMonthly;
    }
    return categoryExpense;
  }
}
