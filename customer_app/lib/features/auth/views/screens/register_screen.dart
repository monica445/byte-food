import 'package:customer_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import 'package:customer_app/widgets/language_switcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/app_auth_form.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;

  bool _showValidationErrors = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';

    if (email.isEmpty) {
      return l10n.emailRequired;
    }

    if (email.length > 254 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return l10n.invalidEmail;
    }

    return null;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() => _showValidationErrors = true);
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();

    final success = await auth.register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );

    if (!mounted) return;

    if (success) {
      // AuthGate will show HomeScreen once this route is popped.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
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
                  Text(
                    l10n.register,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.registerSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  AppAuthForm(
                    autovalidateMode: _showValidationErrors
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    formKey: _formKey,
                    children: [
                      AppTextField(
                        controller: _name,
                        label: l10n.fullName,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.length < 2) {
                            return l10n.enterName;
                          }
                          if (name.length > 100) {
                            return l10n.nameTooLong;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _email,
                        label: l10n.email,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => _validateEmail(value, l10n),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _password,
                        label: l10n.password,
                        prefixIcon: Icons.lock_outline,
                        obscureText: _hidePassword,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          final password = value ?? '';
                          if (password.length < 8) {
                            return l10n.passwordTooShort;
                          }
                          if (password.length > 72) {
                            return l10n.passwordTooLong;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _confirmPassword,
                        label: l10n.confirmPassword,
                        prefixIcon: Icons.lock_outline,
                        obscureText: _hideConfirmPassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _hideConfirmPassword = !_hideConfirmPassword,
                          ),
                          icon: Icon(
                            _hideConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) => value != _password.text
                            ? l10n.passwordsDoNotMatch
                            : null,
                      ),
                      const SizedBox(height: 22),
                      AppButton(
                        label: l10n.register,
                        isLoading: auth.isLoading,
                        onPressed: _submit,
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
