import 'package:dartz/dartz.dart';
import 'package:quran_app/core/errors/failures.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';
import 'package:quran_app/features/quran/domain/repositories/quran_repository.dart';

class GetLastReadUseCase {
  final QuranRepository repository;

  const GetLastReadUseCase(this.repository);

  Future<Either<Failure, Surah?>> execute() async {
    return await repository.getLastReadSurah();
  }
}
