import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    Future.microtask(() => _loadProfile());
    return UserProfile(name: 'User FreshTrack', email: 'user@freshtrack.com');
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('profile_name') ?? 'User FreshTrack';
      final email = prefs.getString('profile_email') ?? 'user@freshtrack.com';
      final imagePath = prefs.getString('profile_image_path');
      state = UserProfile(name: name, email: email, imagePath: imagePath);
    } catch (e) {
      // Ignore or log error
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? imagePath,
  }) async {
    final updatedName = name ?? state.name;
    final updatedEmail = email ?? state.email;
    final updatedImagePath = imagePath ?? state.imagePath;

    state = state.copyWith(
      name: updatedName,
      email: updatedEmail,
      imagePath: updatedImagePath,
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_name', updatedName);
      await prefs.setString('profile_email', updatedEmail);
      if (updatedImagePath != null) {
        await prefs.setString('profile_image_path', updatedImagePath);
      } else {
        await prefs.remove('profile_image_path');
      }
    } catch (e) {
      // Ignore or log error
    }
  }

  Future<void> clearProfile() async {
    state = UserProfile(name: 'User FreshTrack', email: 'user@freshtrack.com');
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('profile_name');
      await prefs.remove('profile_email');
      await prefs.remove('profile_image_path');
    } catch (e) {
      // Ignore or log error
    }
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);
