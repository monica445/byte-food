import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../services/auth_service.dart';
import '../models/auth_user.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class AuthViewModel extends ChangeNotifier {
  final AuthService _service;
  final ApiClient _client;

  AuthViewModel(this._service, this._client);

  AuthStatus _status = AuthStatus.checking;
  AuthUser? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> restoreSession() async {
    try {
      final token = await _client.readToken();

      if (token == null || token.isEmpty) {
        _status = AuthStatus.unauthenticated;
      } else {
        // Validate the saved token through the backend.
        _user = await _service.getCurrentUser();
        _status = AuthStatus.authenticated;
      }
    } catch (_) {
      await _client.clearToken();
      _user = null;
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    return _authenticate(
      () => _service.login(email: email, password: password),
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return _authenticate(
      () => _service.register(name: name, email: email, password: password),
    );
  }

  Future<bool> _authenticate(Future<AuthResult> Function() request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await request();

      // Save token before changing the app to authenticated state.
      await _client.saveToken(result.token);

      _user = result.user;
      _status = AuthStatus.authenticated;
      return true;
    } catch (error) {
      _errorMessage = _friendlyError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _client.clearToken();

    _user = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;

    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is DioException) {
      final response = error.response;
      final body = response?.data;

      if (body is Map && body['message'] is String) {
        return body['message'] as String;
      }

      if (response?.statusCode == 401) {
        return 'Email or password is incorrect.';
      }

      if (response?.statusCode == 409) {
        return 'An account with this email already exists.';
      }

      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Cannot connect to ByteMe. Please try again.';
      }
    }

    if (error is FormatException) {
      return error.message;
    }

    return 'Something went wrong. Please try again.';
  }
}
