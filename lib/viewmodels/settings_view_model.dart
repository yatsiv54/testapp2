import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../services/storage_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  AppSettings _settings = AppSettings();
  bool _isLoading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  void _notifySafely() {
    notifyListeners();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    _notifySafely();
    _settings = await _storageService.getSettings();
    _isLoading = false;
    _notifySafely();
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    await _storageService.saveSettings(newSettings);
    _notifySafely();
  }

  Future<void> completeOnboarding() async {
    _settings = _settings.copyWith(onboardingCompleted: true);
    await _storageService.saveSettings(_settings);
    _notifySafely();
  }
}
