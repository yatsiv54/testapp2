import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import '../viewmodels/profile_view_model.dart';
import '../models/user_profile.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _avatarPath;
  bool _isFirstTime = false;

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<ProfileViewModel>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile?.name ?? '');
    _avatarPath = profile?.avatarPath;
    _isFirstTime = (profile == null);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newProfile = UserProfile(
        name: _nameController.text.trim(),
        avatarPath: _avatarPath,
      );
      Provider.of<ProfileViewModel>(context, listen: false).saveProfile(newProfile);
      Navigator.pop(context);
    }
  }

  void _skip() {
    // Save a default profile to skip mandatory input
    final newProfile = UserProfile(
      name: 'User',
      avatarPath: _avatarPath,
    );
    Provider.of<ProfileViewModel>(context, listen: false).saveProfile(newProfile);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isFirstTime ? 'Create Profile' : 'Edit Profile'),
        actions: [
          if (_isFirstTime)
            TextButton(
              onPressed: _skip,
              child: Text(
                'Skip',
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            const SizedBox(height: 20),
            
            // Camera Avatar Picker
            Center(
              child: GestureDetector(
                onTap: () async {
                  final ImagePicker picker = ImagePicker();
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt_rounded),
                            title: const Text('Take a photo'),
                            onTap: () async {
                              Navigator.pop(context);
                              try {
                                final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                                if (photo != null) {
                                  setState(() {
                                    _avatarPath = photo.path;
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Camera access denied. Please enable in settings.')),
                                  );
                                }
                              }
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_library_rounded),
                            title: const Text('Choose from gallery'),
                            onTap: () async {
                              Navigator.pop(context);
                              try {
                                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  setState(() {
                                    _avatarPath = image.path;
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Gallery access denied. Please enable in settings.')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                          width: 3,
                        ),
                        boxShadow: AppTheme.premiumShadow,
                        image: _avatarPath != null 
                          ? DecorationImage(image: FileImage(File(_avatarPath!)), fit: BoxFit.cover) 
                          : null,
                      ),
                      child: _avatarPath == null 
                        ? Icon(Icons.person_rounded, size: 60, color: isDark ? Colors.white24 : Colors.grey[300]) 
                        : null,
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          gradient: AppTheme.premiumGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            // Text Input Form Card
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                ),
                boxShadow: AppTheme.premiumShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile Info',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name',
                      hintText: 'Enter your name',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) return 'Please enter a name';
                      if (val.length < 2 || val.length > 30) return 'Name must be between 2 and 30 characters';
                      return null;
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 32),

            // Large Action Save Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ).copyWith(
                backgroundColor: WidgetStateProperty.resolveWith((states) => Colors.transparent),
              ),
              onPressed: _save,
              child: Ink(
                decoration: BoxDecoration(
                  gradient: AppTheme.premiumGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 54,
                  alignment: Alignment.center,
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}
