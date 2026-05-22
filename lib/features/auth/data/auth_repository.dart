import 'auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<AuthSession> signIn({required String email, required String password});

  Future<AppUser> fetchProfile();

  Future<AppUser> updateProfile({
    required String name,
    String? about,
    String? profilePhotoUrl,
  });

  Future<List<AppUser>> fetchUsers({String? search});

  Future<AppUser> updateUser(String id, {AppUserRole? role, String? status});

  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<String> forgotPassword({required String email});

  Future<String> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  });

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOut();
}
