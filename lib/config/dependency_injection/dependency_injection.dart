// dependency_injection.dart
//
// Riverpod provider graph for the quran feature.
// All dependencies are declared here as Providers and composed top-down.
// No GetIt / service-locator is used.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quran_app/features/quran/data/datasources/quran_local_data_source.dart';
import 'package:quran_app/features/quran/data/repositories/quran_repository_impl.dart';
import 'package:quran_app/features/quran/domain/repositories/quran_repository.dart';
import 'package:quran_app/features/quran/domain/usecases/get_last_read_usecase.dart';
import 'package:quran_app/features/quran/domain/usecases/get_surahs_usecase.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── External ────────────────────────────────────────────────────────────────

/// Asynchronously provides the SharedPreferences instance.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

// ─── Data Sources ─────────────────────────────────────────────────────────────

final quranLocalDataSourceProvider = Provider<QuranLocalDataSource>(
  (ref) => QuranLocalDataSourceImpl(),
);

// ─── Repositories ─────────────────────────────────────────────────────────────

final quranRepositoryProvider = FutureProvider<QuranRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final localDataSource = ref.watch(quranLocalDataSourceProvider);
  return QuranRepositoryImpl(
    localDataSource: localDataSource,
    sharedPreferences: prefs,
  );
});

// ─── Use Cases ────────────────────────────────────────────────────────────────

final getSurahsUseCaseProvider = FutureProvider<GetSurahsUseCase>((ref) async {
  final repository = await ref.watch(quranRepositoryProvider.future);
  return GetSurahsUseCase(repository);
});

final getLastReadUseCaseProvider =
    FutureProvider<GetLastReadUseCase>((ref) async {
  final repository = await ref.watch(quranRepositoryProvider.future);
  return GetLastReadUseCase(repository);
});
