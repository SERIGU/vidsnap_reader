import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <- correcto
import 'src/i18n/l10n.dart';
import 'src/ui/home_screen.dart';
import 'src/services/ad_service.dart';

const String kAppTitle = 'VidSnap Reader'; // <- const top-level

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.instance.init(); // STUB sin AdMob
  runApp(const ProviderScope(child: VidSnapReaderApp()));
}

class VidSnapReaderApp extends StatelessWidget {
  const VidSnapReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      supportedLocales: const [Locale('en'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6C2BD9),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
