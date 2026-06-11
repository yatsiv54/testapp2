import 'package:shared_preferences/shared_preferences.dart';
import '../models/subscription.dart';
import '../models/user_profile.dart';
import '../models/app_settings.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static const String _subscriptionsKey = 'subscriptions_data';
  static const String _userProfileKey = 'user_profile_data';
  static const String _settingsKey = 'app_settings_data';

  Future<String?> fixStaleImagePath(String? path) async {
    if (path == null || path.isEmpty) return path;
    final File file = File(path);
    if (await file.exists()) return path;
    
    // File doesn't exist, it might be a stale iOS absolute path.
    // Reconstruct it using the current documents directory.
    final Directory appDocsDir = await getApplicationDocumentsDirectory();
    final String fileName = path.split('/').last;
    final String newPath = '${appDocsDir.path}/$fileName';
    if (await File(newPath).exists()) {
      return newPath;
    }
    return path;
  }

  Future<List<Subscription>> getSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_subscriptionsKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    final subs = jsonList.map((e) => Subscription.fromJson(e)).toList();
    
    bool needsSave = false;
    for (int i = 0; i < subs.length; i++) {
      final newPath = await fixStaleImagePath(subs[i].logoPath);
      if (newPath != subs[i].logoPath) {
        subs[i] = subs[i].copyWith(logoPath: newPath);
        needsSave = true;
      }
    }
    
    if (needsSave) {
      await saveSubscriptions(subs);
    }
    return subs;
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
    
    UserProfile profile = UserProfile.fromJson(data);
    final newPath = await fixStaleImagePath(profile.avatarPath);
    if (newPath != profile.avatarPath) {
      profile = profile.copyWith(avatarPath: newPath);
      await saveUserProfile(profile);
    }
    return profile;
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

  Future<String> saveImagePermanently(String temporaryPath) async {
    final File tempFile = File(temporaryPath);
    if (!await tempFile.exists()) return temporaryPath;

    final Directory appDocsDir = await getApplicationDocumentsDirectory();
    final String fileName = DateTime.now().millisecondsSinceEpoch.toString() + '_' + tempFile.uri.pathSegments.last;
    final String newPath = '${appDocsDir.path}/$fileName';

    final File newFile = await tempFile.copy(newPath);
    return newFile.path;
  }
}
