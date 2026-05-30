import 'package:my_quran/core/utils/failure.dart';
import 'package:my_quran/domain/entities/surah.dart';
import 'package:my_quran/domain/repositories/quran_repository.dart';

class GetSurahList {
  GetSurahList(this._repository);

  final QuranRepository _repository;

  Future<({List<Surah>? data, Failure? failure})> call() =>
      _repository.getSurahList();
}
