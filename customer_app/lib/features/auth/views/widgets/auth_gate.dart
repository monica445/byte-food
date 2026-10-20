import 'package:customer_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:customer_app/features/auth/views/screens/login_screen.dart';
import 'package:customer_app/features/home/view/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    switch (auth.status) {
      case AuthStatus.checking:
        return const Scaffold(body: Center(child: CircularProgressIndicator()));

      case AuthStatus.unauthenticated:
        return const LoginScreen();

      case AuthStatus.authenticated:
        return const HomeScreen();
    }
  }
}
