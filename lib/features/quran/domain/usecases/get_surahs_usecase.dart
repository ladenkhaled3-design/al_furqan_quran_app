import 'package:dartz/dartz.dart';
import 'package:quran_app/core/errors/failures.dart';
import 'package:quran_app/features/quran/domain/entities/surah.dart';
import 'package:quran_app/features/quran/domain/repositories/quran_repository.dart';

class GetSurahsUseCase {
  final QuranRepository repository;

  const GetSurahsUseCase(this.repository);

  Future<Either<Failure, List<Surah>>> execute() async {
    return await repository.getSurahs();
  }
}
