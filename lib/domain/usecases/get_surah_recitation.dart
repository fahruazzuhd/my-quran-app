import 'package:my_quran/core/utils/failure.dart';
import 'package:my_quran/domain/entities/surah_recitation.dart';
import 'package:my_quran/domain/repositories/quran_repository.dart';

class GetSurahRecitation {
  GetSurahRecitation(this._repository);

  final QuranRepository _repository;

  Future<({SurahRecitation? data, Failure? failure})> call({
    required int surahNumber,
    required String reciterId,
  }) =>
      _repository.getSurahRecitation(
        surahNumber: surahNumber,
        reciterId: reciterId,
      );
}
