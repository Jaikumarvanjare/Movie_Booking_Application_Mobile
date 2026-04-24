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

  Future<void> signOut() async {
    await _authRepository.signOut();
    _session = null;
    _status = SessionStatus.unauthenticated;
    _lastErrorMessage = null;
    notifyListeners();
  }
}

String _errorMessageFor(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  return 'Something went wrong. Please try again.';
}
