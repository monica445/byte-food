import '../../../core/network/api_client.dart';
import '../models/auth_user.dart';

class AuthResult {
  final AuthUser user;
  final String token;

  const AuthResult({required this.user, required this.token});
}

class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;

    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }

    return {};
  }

  AuthResult _parseResponse(dynamic response) {
    final root = _asMap(response);
    final data = _asMap(root['data'] ?? root);

    final token = (data['accessToken'] ?? data['token'] ?? '').toString();

    final userData = _asMap(data['user'] ?? data['customer']);

    if (token.isEmpty || userData.isEmpty) {
      throw const FormatException(
        'Invalid authentication response from server.',
      );
    }

    return AuthResult(user: AuthUser.fromJson(userData), token: token);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      '/auth/register',
      data: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    return _parseResponse(response.data);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(
      '/auth/login',
      data: {'email': email.trim().toLowerCase(), 'password': password},
    );

    return _parseResponse(response.data);
  }

  Future<AuthUser> getCurrentUser() async {
    final response = await _client.dio.get('/auth/me');

    final root = _asMap(response.data);
    final data = _asMap(root['data'] ?? root);
    final userData = _asMap(data['user'] ?? data);

    if (userData.isEmpty || userData['id'] == null) {
      throw const FormatException('Invalid current-user response.');
    }

    return AuthUser.fromJson(userData);
  }
}
