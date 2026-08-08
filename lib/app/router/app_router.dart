import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:quran_app/features/quran/presentation/screens/home_screen.dart';
import 'package:quran_app/features/quran/presentation/screens/surah_list_screen.dart';
import 'package:quran_app/features/quran/presentation/screens/quran_reader_screen.dart';
import 'package:quran_app/features/quran/presentation/screens/search_screen.dart';
import 'package:quran_app/features/quran/presentation/screens/bookmarks_screen.dart';
import 'package:quran_app/features/quran/presentation/screens/settings_screen.dart';

class AppRouter {
  // ─── Route paths ──────────────────────────────────────────────────────────
  static const String home = '/';
  static const String surahs = '/surahs';
  static const String reader = '/surah/:id';
  static const String search = '/search';
  static const String bookmarks = '/bookmarks';
  static const String settings = '/settings';

  // ─── Router ───────────────────────────────────────────────────────────────
  static final GoRouter router = GoRouter(
    initialLocation: home,
    errorBuilder: (context, state) => const _NotFoundScreen(),
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: surahs,
        name: 'surahs',
        builder: (context, state) => const SurahListScreen(),
      ),
      GoRoute(
        path: reader,
        name: 'reader',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
          return QuranReaderScreen(surahId: id);
        },
      ),
      GoRoute(
        path: search,
        name: 'search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: bookmarks,
        name: 'bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

// ─── 404 screen ───────────────────────────────────────────────────────────────

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: const Center(
        child: Text('الصفحة غير موجودة', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
