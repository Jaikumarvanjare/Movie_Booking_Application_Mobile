import 'auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession?> restoreSession();

  Future<AuthSession> signIn({required String email, required String password});

  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<String> resetPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}
