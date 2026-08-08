import 'package:dartz/dartz.dart';
import 'package:quran_app/core/errors/failures.dart';
import 'package:quran_app/features/quran/data/datasources/quran_local_data_source.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';
import 'package:quran_app/features/quran/domain/repositories/quran_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource localDataSource;
  final SharedPreferences sharedPreferences;

  static const String _lastReadSurahKey = 'last_read_surah_id';
  static const String _lastReadAyahKey = 'last_read_ayah_id';

  QuranRepositoryImpl({
    required this.localDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, List<Surah>>> getSurahs() async {
    try {
      final surahs = await localDataSource.getSurahs();
      return Right(surahs);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Surah?>> getLastReadSurah() async {
    try {
      final surahId = sharedPreferences.getInt(_lastReadSurahKey);
      if (surahId == null) return const Right(null);

      final surahs = await localDataSource.getSurahs();
      final surah = surahs.cast<Surah?>().firstWhere(
            (s) => s?.id == surahId,
            orElse: () => null,
          );
      return Right(surah);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLastReadSurah(
    int surahId,
    int ayahNumber,
  ) async {
    try {
      await sharedPreferences.setInt(_lastReadSurahKey, surahId);
      await sharedPreferences.setInt(_lastReadAyahKey, ayahNumber);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
