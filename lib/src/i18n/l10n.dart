import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, String> _strings;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate = _L10nDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  Future<bool> load() async {
    final data = await rootBundle.loadString('assets/i18n/${locale.languageCode}.arb');
    final map = json.decode(data) as Map<String, dynamic>;
    _strings = map.map((k, v) => MapEntry(k, v.toString()));
    return true;
  }

  String t(String key, {Map<String, String> params = const {}}) {
    var v = _strings[key] ?? key;
    params.forEach((k, val) => v = v.replaceAll('{$k}', val));
    return v;
  }
}

class _L10nDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _L10nDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async {
    final l10n = AppLocalizations(locale);
    await l10n.load();
    return l10n;
  }
  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
