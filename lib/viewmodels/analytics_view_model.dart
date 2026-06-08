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

  double getTotalMonthlyExpense() {
    double total = 0;
    for (var sub in _subscriptions) {
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

  Map<String, double> getExpenseByCategory() {
    Map<String, double> categoryExpense = {};
    for (var sub in _subscriptions) {
      double amountMonthly = sub.amount;
      if (sub.periodicity == 'Yearly') {
        amountMonthly = sub.amount / 12;
      } else if (sub.periodicity == 'Weekly') {
        amountMonthly = sub.amount * 4.33;
      } else if (sub.periodicity == 'Daily') {
        amountMonthly = sub.amount * 30;
      }
      
      categoryExpense[sub.category] = (categoryExpense[sub.category] ?? 0) + amountMonthly;
    }
    return categoryExpense;
  }
}
