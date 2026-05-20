import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../data/auth_repository.dart';
import '../data/auth_session.dart';

enum SessionStatus { checking, unauthenticated, authenticated }

class SessionController extends ChangeNotifier {
  SessionController({required AuthRepository authRepository})
    : _authRepository = authRepository;

  final AuthRepository _authRepository;

  SessionStatus _status = SessionStatus.unauthenticated;
  AuthSession? _session;
  bool _isSubmitting = false;
  String? _lastErrorMessage;

  SessionStatus get status => _status;
  AuthSession? get session => _session;
  AppUser? get user => _session?.user;
  bool get isSubmitting => _isSubmitting;
  String? get lastErrorMessage => _lastErrorMessage;

  Future<void> restoreSession() async {
    _status = SessionStatus.checking;
    notifyListeners();

    try {
      final session = await _authRepository.restoreSession();
      _session = session;
      _status = session == null
          ? SessionStatus.unauthenticated
          : SessionStatus.authenticated;
      _lastErrorMessage = null;
    } catch (error) {
      _session = null;
      _status = SessionStatus.unauthenticated;
      _lastErrorMessage = _errorMessageFor(error);
    }
    notifyListeners();
  }

  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    _isSubmitting = true;
    _lastErrorMessage = null;
    notifyListeners();

    try {
      final session = await _authRepository.signIn(
        email: email,
        password: password,
      );
      _session = session;
      _status = SessionStatus.authenticated;
      return session;
    } catch (error) {
      _session = null;
      _status = SessionStatus.unauthenticated;
      _lastErrorMessage = _errorMessageFor(error);
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    if (!await _ensureActiveSession()) {
      return;
    }

    try {
      final user = await _authRepository.fetchProfile();
      _session = _session?.copyWith(user: user);
      _lastErrorMessage = null;
      notifyListeners();
    } catch (error) {
      _lastErrorMessage = _errorMessageFor(error);
      rethrow;
    }
  }

  Future<AppUser> updateProfile({required String name}) async {
    final currentSession = _session;
    if (currentSession == null || !await _ensureActiveSession()) {
      throw const ApiException(message: 'You need to sign in again.');
    }

    try {
      final user = await _authRepository.updateProfile(name: name);
      _session = currentSession.copyWith(user: user);
      _lastErrorMessage = null;
      notifyListeners();
      return user;
    } catch (error) {
      _lastErrorMessage = _errorMessageFor(error);
      rethrow;
    }
  }

  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_session == null || !await _ensureActiveSession()) {
      throw const ApiException(message: 'You need to sign in again.');
    }

    try {
      final message = await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _lastErrorMessage = null;
      return message;
    } catch (error) {
      _lastErrorMessage = _errorMessageFor(error);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
    _session = null;
    _status = SessionStatus.unauthenticated;
    _lastErrorMessage = null;
    notifyListeners();
  }

  Future<bool> _ensureActiveSession() async {
    final currentSession = _session;
    if (currentSession == null) {
      return false;
    }
    if (!currentSession.isExpired) {
      return true;
    }

    await signOut();
    _lastErrorMessage = 'Your session expired. Please sign in again.';
    notifyListeners();
    return false;
  }
}

String _errorMessageFor(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  return 'Something went wrong. Please try again.';
}
