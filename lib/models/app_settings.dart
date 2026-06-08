import 'dart:convert';

class AppSettings {
  final bool notificationsEnabled;
  final bool isDarkMode;
  final String currency;
  final bool onboardingCompleted;
  final bool analyticsEnabled;

  AppSettings({
    this.notificationsEnabled = true,
    this.isDarkMode = false,
    this.currency = 'USD',
    this.onboardingCompleted = false,
    this.analyticsEnabled = true,
  });

  AppSettings copyWith({
    bool? notificationsEnabled,
    bool? isDarkMode,
    String? currency,
    bool? onboardingCompleted,
    bool? analyticsEnabled,
  }) {
    return AppSettings(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      currency: currency ?? this.currency,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'isDarkMode': isDarkMode,
      'currency': currency,
      'onboardingCompleted': onboardingCompleted,
      'analyticsEnabled': analyticsEnabled,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      notificationsEnabled: map['notificationsEnabled'] ?? true,
      isDarkMode: map['isDarkMode'] ?? false,
      currency: map['currency'] ?? 'USD',
      onboardingCompleted: map['onboardingCompleted'] ?? false,
      analyticsEnabled: map['analyticsEnabled'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppSettings.fromJson(String source) => AppSettings.fromMap(json.decode(source));
}
