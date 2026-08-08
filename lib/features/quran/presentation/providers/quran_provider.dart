// quran_provider.dart
//
// Presentation-layer Riverpod providers for the quran feature.
// These sit above the DI provider graph defined in dependency_injection.dart.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/config/dependency_injection/dependency_injection.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';

// ─── Surah list ───────────────────────────────────────────────────────────────

/// Loads and caches the full surah list (without ayahs for list screen).
/// Backed by Isolate.run parse in QuranLocalDataSourceImpl.
final quranDataProvider = FutureProvider<List<Surah>>((ref) async {
  final useCase = await ref.watch(getSurahsUseCaseProvider.future);
  final result = await useCase.execute();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (surahs) => surahs,
  );
});

// ─── Surah detail (reader) ────────────────────────────────────────────────────

/// Loads a single surah by id, including its ayahs.
/// Uses the full surah list cache — no extra I/O.
final surahDetailProvider = FutureProvider.family<Surah, int>((ref, id) async {
  final surahs = await ref.watch(quranDataProvider.future);
  return surahs.firstWhere(
    (s) => s.id == id,
    orElse: () => throw Exception('السورة رقم $id غير موجودة'),
  );
});

// ─── Last read ────────────────────────────────────────────────────────────────

/// Returns the last-read surah, or null if none saved.
final lastReadProvider = FutureProvider<Surah?>((ref) async {
  final useCase = await ref.watch(getLastReadUseCaseProvider.future);
  final result = await useCase.execute();
  return result.fold(
    (failure) => null, // non-fatal: treat as no last-read
    (surah) => surah,
  );
});

// ─── Save last read (action) ──────────────────────────────────────────────────

/// Call this to save the last-read position.
/// Usage: ref.read(saveLastReadProvider)(surahId, ayahNumber);
final saveLastReadProvider = Provider<Future<void> Function(int, int)>((ref) {
  return (surahId, ayahNumber) async {
    final repository = await ref.read(quranRepositoryProvider.future);
    await repository.saveLastReadSurah(surahId, ayahNumber);
    ref.invalidate(lastReadProvider);
  };
});

// ─── Search ───────────────────────────────────────────────────────────────────

class SearchResultItem {
  final Surah surah;
  final Ayah? ayah;
  final String matchType; // 'surah' or 'ayah'

  const SearchResultItem({
    required this.surah,
    this.ayah,
    required this.matchType,
  });
}

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final searchResultsProvider = FutureProvider<List<SearchResultItem>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return [];

  final surahs = await ref.watch(quranDataProvider.future);
  final List<SearchResultItem> results = [];

  // Plain query for diacritic-insensitive search
  final plainQuery = query.replaceAll(
    RegExp(
      r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7\u06E8\u06EA-\u06ED\uFC5E-\uFC62]',
    ),
    '',
  );

  for (final surah in surahs) {
    // Check surah names
    if (surah.nameArabic.contains(query) ||
        surah.nameEnglish.toLowerCase().contains(query.toLowerCase()) ||
        surah.id.toString() == query) {
      results.add(SearchResultItem(surah: surah, matchType: 'surah'));
    }

    // Check ayahs using textPlain
    if (surah.ayahs != null) {
      for (final ayah in surah.ayahs!) {
        if (ayah.textPlain.contains(plainQuery) || ayah.text.contains(query)) {
          results.add(
            SearchResultItem(
              surah: surah,
              ayah: ayah,
              matchType: 'ayah',
            ),
          );
        }
      }
    }
  }

  return results;
});

// ─── Bookmarks ────────────────────────────────────────────────────────────────

class BookmarkItem {
  final int surahId;
  final int ayahNumber;
  final String surahNameArabic;
  final String ayahText;

  const BookmarkItem({
    required this.surahId,
    required this.ayahNumber,
    required this.surahNameArabic,
    required this.ayahText,
  });

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'ayahNumber': ayahNumber,
        'surahNameArabic': surahNameArabic,
        'ayahText': ayahText,
      };

  factory BookmarkItem.fromJson(Map<String, dynamic> json) => BookmarkItem(
        surahId: json['surahId'] as int,
        ayahNumber: json['ayahNumber'] as int,
        surahNameArabic: json['surahNameArabic'] as String,
        ayahText: json['ayahText'] as String,
      );
}

class BookmarksNotifier extends Notifier<List<BookmarkItem>> {
  static const String _key = 'quran_bookmarks';

  @override
  List<BookmarkItem> build() {
    _loadFromPrefs();
    return [];
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final String? raw = prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      final List<dynamic> list = json.decode(raw);
      state = list.map((e) => BookmarkItem.fromJson(e)).toList();
    }
  }

  Future<void> toggleBookmark(BookmarkItem item) async {
    final exists = isBookmarked(item.surahId, item.ayahNumber);
    if (exists) {
      state = state
          .where(
            (b) => !(b.surahId == item.surahId && b.ayahNumber == item.ayahNumber),
          )
          .toList();
    } else {
      state = [...state, item];
    }
    await _saveToPrefs();
  }

  bool isBookmarked(int surahId, int ayahNumber) {
    return state.any((b) => b.surahId == surahId && b.ayahNumber == ayahNumber);
  }

  Future<void> _saveToPrefs() async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    final encoded = json.encode(state.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }
}

final bookmarksProvider =
    NotifierProvider<BookmarksNotifier, List<BookmarkItem>>(
  BookmarksNotifier.new,
);

// ─── Settings ─────────────────────────────────────────────────────────────────

class AppSettings {
  final double fontSize;
  final ThemeMode themeMode;

  const AppSettings({
    required this.fontSize,
    required this.themeMode,
  });

  AppSettings copyWith({
    double? fontSize,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      fontSize: fontSize ?? this.fontSize,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends Notifier<AppSettings> {
  static const String _fontSizeKey = 'app_font_size';
  static const String _themeModeKey = 'app_theme_mode';

  @override
  AppSettings build() {
    _loadFromPrefs();
    return const AppSettings(fontSize: 24.0, themeMode: ThemeMode.system);
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    final fontSize = prefs.getDouble(_fontSizeKey) ?? 24.0;
    final themeStr = prefs.getString(_themeModeKey) ?? 'system';
    final themeMode = _themeModeFromString(themeStr);
    state = AppSettings(fontSize: fontSize, themeMode: themeMode);
  }

  Future<void> updateFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setDouble(_fontSizeKey, size);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setString(_themeModeKey, mode.name);
  }

  ThemeMode _themeModeFromString(String str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
