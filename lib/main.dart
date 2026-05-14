import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    /// 🔥 FIREBASE
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    /// 🔥 АНОНИМНАЯ АВТОРИЗАЦИЯ
    final auth = FirebaseAuth.instance;

    if (auth.currentUser == null) {
      
    }
  } catch (e) {
    debugPrint("🔥 Firebase init error: $e");
  }

  runApp(const BalkhashTasteApp());
}

class BalkhashTasteApp extends StatefulWidget {
  const BalkhashTasteApp({super.key});

  /// 👉 доступ к смене языка из любого места
  static void setLocale(BuildContext context, Locale locale) {
    final state =
        context.findAncestorStateOfType<_BalkhashTasteAppState>();
    state?.setLocale(locale);
  }

  @override
  State<BalkhashTasteApp> createState() =>
      _BalkhashTasteAppState();
}

class _BalkhashTasteAppState
    extends State<BalkhashTasteApp> {
  Locale _locale = const Locale('ru');

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BALKHASH TASTE',

      /// 🌍 язык
      locale: _locale,

      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('ru'),
        Locale('kk'),
      ],

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const EcoTasteSplash(),
    );
  }
}