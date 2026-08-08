import 'package:dartz/dartz.dart';
import 'package:quran_app/core/errors/failures.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';

abstract class QuranRepository {
  Future<Either<Failure, List<Surah>>> getSurahs();
  Future<Either<Failure, Surah?>> getLastReadSurah();
  Future<Either<Failure, void>> saveLastReadSurah(int surahId, int ayahNumber);
}
