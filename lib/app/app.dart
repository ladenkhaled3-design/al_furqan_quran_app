import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/app/router/app_router.dart';
import 'package:quran_app/app/theme/app_theme.dart';

import 'package:quran_app/core/constants/app_constants.dart';

import 'package:quran_app/features/quran/presentation/providers/quran_provider.dart';

class QuranApp extends ConsumerWidget {
  const QuranApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: AppConstants.appName,

      // ─── Themes ─────────────────────────────────────────────────────────
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,

      // ─── RTL & Localization ─────────────────────────────────────────────
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── Router ─────────────────────────────────────────────────────────
      routerConfig: AppRouter.router,

      debugShowCheckedModeBanner: false,
    );
  }
}
