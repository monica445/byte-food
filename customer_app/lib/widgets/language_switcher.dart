import 'package:customer_app/core/localization/locale_provider.dart';
import 'package:customer_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale;
    final l10n = AppLocalizations.of(context)!;

    return DropdownButton<String>(
      value: locale.languageCode,
      underline: const SizedBox.shrink(),
      borderRadius: BorderRadius.circular(12),
      items: [
        DropdownMenuItem(value: 'en', child: Text(l10n.english)),
        DropdownMenuItem(value: 'km', child: Text(l10n.khmer)),
      ],
      onChanged: (value) {
        if (value != null) {
          context.read<LocaleProvider>().setLanguage(value);
        }
      },
    );
  }
}
