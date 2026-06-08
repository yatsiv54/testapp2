import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';
import 'dart:convert';

class StorageService {
  static const String _subscriptionsKey = 'subscriptions_data';
  static const String _userProfileKey = 'user_profile_data';
  static const String _settingsKey = 'app_settings_data';

  Future<List<Subscription>> getSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_subscriptionsKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    return jsonList.map((e) => Subscription.fromJson(e)).toList();
  }

  Future<void> saveSubscriptions(List<Subscription> subscriptions) async {
    final prefs = await SharedPreferences.getInstance();
    final String data = json.encode(subscriptions.map((e) => e.toJson()).toList());
    await prefs.setString(_subscriptionsKey, data);
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_userProfileKey);
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, profile.toJson());
  }

  Future<AppSettings> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_settingsKey);
    if (data == null) return AppSettings();
    return AppSettings.fromJson(data);
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, settings.toJson());
  }
  
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
