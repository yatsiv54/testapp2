import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/subscription.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // Handle deep link
      },
    );
  }

  Future<void> schedulePaymentReminder(Subscription subscription) async {
    if (!subscription.hasReminder) return;

    final scheduledDate = subscription.nextPaymentDate.subtract(const Duration(days: 1));
    if (scheduledDate.isBefore(DateTime.now())) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: subscription.id.hashCode,
      title: 'Upcoming Subscription Payment',
      body: 'Your payment for ${subscription.name} is due soon.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'payment_reminders',
          'Payment Reminders',
          channelDescription: 'Reminders for upcoming subscription payments',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'SubscriptionDetailScreen_${subscription.id}',
    );
  }

  Future<void> cancelReminder(String subscriptionId) async {
    await flutterLocalNotificationsPlugin.cancel(id: subscriptionId.hashCode);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> showStatusChangeNotification(Subscription subscription) async {
    await flutterLocalNotificationsPlugin.show(
      id: subscription.id.hashCode ^ 1, // Unique ID for status change
      title: 'Subscription Status Updated',
      body: 'Status for ${subscription.name} has changed to ${subscription.status}.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'status_changes',
          'Status Changes',
          channelDescription: 'Notifications for subscription status updates',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'SubscriptionDetailScreen_${subscription.id}',
    );
  }

  Future<void> scheduleOptimizationTip() async {
    // Schedule optimization tip monthly
    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month + 1, 1, 10, 0); // 1st of next month, 10 AM

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: 0, // Fixed ID for monthly tip
      title: 'Optimize Your Subscriptions',
      body: 'Check analytics for ways to save on subscriptions.',
      scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'optimization_tips',
          'Optimization Tips',
          channelDescription: 'Monthly tips to optimize subscription spending',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      payload: 'AnalyticsScreen',
    );
  }
}
