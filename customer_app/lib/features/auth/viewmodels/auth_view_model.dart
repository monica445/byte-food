import 'package:customer_app/core/state/async_state.dart';
import 'package:flutter/foundation.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel(this._authService);

  final AuthService _authService;

  AsyncState<AuthUser> _state = const AsyncState.idle();

  AuthUser? get user => _state.data;
  bool get isAuthenticated => _state.hasData;
  bool get isLoading => _state.isLoading;
  String? get errorMessage => _state.error;

  Future<bool> login({required String email, required String password}) async {
    _setState(const AsyncState.loading());

    try {
      final result = await _authService.login(email: email, password: password);

      _setState(AsyncState.success(result.user));
      return true;
    } catch (error) {
      _setState(AsyncState.failure(_getErrorMessage(error)));
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setState(const AsyncState.loading());

    try {
      final result = await _authService.register(
        name: name,
        email: email,
        password: password,
      );

      _setState(AsyncState.success(result.user));
      return true;
    } catch (error) {
      _setState(AsyncState.failure(_getErrorMessage(error)));
      return false;
    }
  }

  void clearError() {
    if (_state.hasError) {
      _setState(const AsyncState.idle());
    }
  }

  String _getErrorMessage(Object error) {
    if (error is FormatException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }

  void _setState(AsyncState<AuthUser> state) {
    _state = state;
    notifyListeners();
  }
}
