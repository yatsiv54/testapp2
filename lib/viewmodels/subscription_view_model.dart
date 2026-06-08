import 'package:flutter/material.dart';
import '../models/subscription.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class SubscriptionViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;
  String? _error;

  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _notifySafely() {
    notifyListeners();
  }

  Future<void> loadSubscriptions() async {
    _isLoading = true;
    _error = null;
    _notifySafely();
    try {
      _subscriptions = await _storageService.getSubscriptions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _notifySafely();
    }
  }

  Future<void> addSubscription(Subscription sub) async {
    _subscriptions.add(sub);
    await _storageService.saveSubscriptions(_subscriptions);
    if (sub.hasReminder) {
      await _notificationService.schedulePaymentReminder(sub);
    }
    _notifySafely();
  }

  Future<void> updateSubscription(Subscription sub) async {
    final index = _subscriptions.indexWhere((s) => s.id == sub.id);
    if (index != -1) {
      final oldSub = _subscriptions[index];
      _subscriptions[index] = sub;
      await _storageService.saveSubscriptions(_subscriptions);
      
      if (oldSub.hasReminder) {
        await _notificationService.cancelReminder(oldSub.id);
      }
      if (sub.hasReminder) {
        await _notificationService.schedulePaymentReminder(sub);
      }
      
      if (oldSub.status != sub.status) {
        await _notificationService.showStatusChangeNotification(sub);
      }
      
      notifyListeners();
    }
  }

  Future<void> changeSubscriptionStatus(String id, String newStatus) async {
    final index = _subscriptions.indexWhere((s) => s.id == id);
    if (index != -1) {
      final sub = _subscriptions[index].copyWith(status: newStatus);
      await updateSubscription(sub);
    }
  }

  Future<void> deleteSubscription(String id) async {
    _subscriptions.removeWhere((s) => s.id == id);
    await _storageService.saveSubscriptions(_subscriptions);
    await _notificationService.cancelReminder(id);
    _notifySafely();
  }
}
