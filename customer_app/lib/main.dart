import 'package:customer_app/core/localization/locale_provider.dart';
import 'package:customer_app/core/theme/app_theme.dart';
import 'package:customer_app/features/auth/services/auth_service.dart';
import 'package:customer_app/features/auth/viewmodels/auth_view_model.dart';
import 'package:customer_app/features/auth/views/widgets/auth_gate.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: const ByteFoodApp(),
    ),
  );
}

class ByteFoodApp extends StatelessWidget {
  const ByteFoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ByteFood',
      theme: AppTheme.light,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('km')],
      home: const AuthGate(),
    );
  }
}
