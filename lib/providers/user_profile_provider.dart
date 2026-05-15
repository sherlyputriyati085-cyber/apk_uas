import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';

class UserProfileNotifier extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    return UserProfile(name: 'User FreshTrack', email: 'user@freshtrack.com');
  }

  void updateProfile({String? name, String? email, String? imagePath}) {
    state = state.copyWith(name: name, email: email, imagePath: imagePath);
  }

  void clearProfile() {
    state = UserProfile(name: 'User FreshTrack', email: 'user@freshtrack.com');
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);
