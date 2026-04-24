import '../../../core/storage/token_storage.dart';
import 'auth_api_service.dart';
import 'auth_repository.dart';
import 'auth_session.dart';

class RemoteAuthRepository implements AuthRepository {
  const RemoteAuthRepository({
    required AuthApiService authApiService,
    required TokenStorage tokenStorage,
  }) : _authApiService = authApiService,
       _tokenStorage = tokenStorage;

  final AuthApiService _authApiService;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession?> restoreSession() async {
    final storedSession = await _tokenStorage.readSession();
    if (storedSession == null) {
      return null;
    }

    return AuthSession(
      token: storedSession.token,
      user: AppUser(
        id: storedSession.userId,
        email: storedSession.email,
        name: storedSession.name,
        role: appUserRoleFromString(storedSession.role),
        status: storedSession.status,
      ),
    );
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    final session = await _authApiService.signIn(
      email: email,
      password: password,
    );
    await _tokenStorage.saveSession(
      StoredSession(
        token: session.token,
        userId: session.user.id,
        email: session.user.email,
        name: session.user.name,
        role: session.user.role.name.toUpperCase(),
        status: session.user.status,
      ),
    );
    return session;
  }

  @override
  Future<String> signUp({
    required String name,
    required String email,
    required String password,
  }) {
    return _authApiService.signUp(name: name, email: email, password: password);
  }

  @override
  Future<String> resetPassword({
    required String email,
    required String password,
  }) {
    return _authApiService.resetPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() {
    return _tokenStorage.clearSession();
  }
}
