import 'auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<AuthSession> signIn({required String email, required String password});

  Future<AppUser> fetchProfile();

  Future<AppUser> updateProfile({required String name});

  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<String> resetPassword({
    required String email,
    required String password,
  });

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> signOut();
}
