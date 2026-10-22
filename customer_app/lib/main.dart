import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/features/auth/services/auth_service.dart';
import 'package:customer_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:customer_app/features/auth/views/widgets/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';

void main() {
  final apiClient = ApiClient();
  final authService = AuthService(apiClient);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(create: (_) => AuthViewModel(authService)),
      ],
      child: const ByteFoodApp(),
    ),
  );
}

class ByteFoodApp extends StatelessWidget {
  const ByteFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByteFood',
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}
