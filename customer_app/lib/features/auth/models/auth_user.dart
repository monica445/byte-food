enum AppLanguage {
  en,
  km;

  String get apiValue {
    switch (this) {
      case AppLanguage.en:
        return 'EN';
      case AppLanguage.km:
        return 'KH';
    }
  }

  static AppLanguage fromApi(String? value) {
    switch (value?.toUpperCase()) {
      case 'KH':
        return AppLanguage.km;
      case 'EN':
      default:
        return AppLanguage.en;
    }
  }
}

class AuthUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final AppLanguage preferredLanguage;

  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'CUSTOMER',
    this.preferredLanguage = AppLanguage.en,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: json['phone']?.toString(),
      role: (json['role'] ?? 'CUSTOMER').toString(),
      preferredLanguage: AppLanguage.fromApi(
        json['preferredLanguage']?.toString(),
      ),
    );
  }
}
