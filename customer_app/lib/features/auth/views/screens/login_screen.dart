import 'package:customer_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import 'package:customer_app/features/auth/views/screens/register_screen.dart';
import 'package:customer_app/features/auth/views/widgets/app_button.dart';
import 'package:customer_app/widgets/language_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_auth_form.dart';
import '../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _hidePassword = true;
  bool _showValidationErrors = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) return 'Email is required.';
    if (email.length > 254 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() => _showValidationErrors = true);
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();

    final success = await auth.login(
      email: _email.text,
      password: _password.text,
    );

    if (!mounted) return;

    if (!success && auth.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Align(
                    alignment: Alignment.centerRight,
                    child: LanguageSwitcher(),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 90,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.restaurant_menu,
                      size: 76,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.welcomeBack,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(l10n.loginSubtitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 28),
                  AppAuthForm(
                    autovalidateMode: _showValidationErrors
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    formKey: _formKey,
                    children: [
                      AppTextField(
                        controller: _email,
                        label: l10n.email,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _password,
                        label: l10n.password,
                        prefixIcon: Icons.lock_outline,
                        obscureText: _hidePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? l10n.enterPassword
                            : null,
                      ),
                      const SizedBox(height: 22),
                      AppButton(
                        label: l10n.login,
                        isLoading: auth.isLoading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.noAccount),
                      TextButton(
                        onPressed: auth.isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: Text(l10n.registerHere),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
