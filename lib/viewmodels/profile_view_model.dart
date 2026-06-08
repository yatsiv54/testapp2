import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/storage_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  UserProfile? _profile;
  bool _isLoading = true;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  void _notifySafely() {
    notifyListeners();
  }

  Future<void> loadProfile() async {
    _isLoading = true;
    _notifySafely();
    _profile = await _storageService.getUserProfile();
    _isLoading = false;
    _notifySafely();
  }

  Future<void> saveProfile(UserProfile profile) async {
    _profile = profile;
    await _storageService.saveUserProfile(profile);
    _notifySafely();
  }
}
