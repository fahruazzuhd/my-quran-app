import 'package:my_quran/core/utils/failure.dart';
import 'package:my_quran/domain/entities/reciter.dart';
import 'package:my_quran/domain/entities/surah.dart';
import 'package:my_quran/domain/entities/surah_recitation.dart';

abstract class QuranRepository {
  Future<({List<Surah>? data, Failure? failure})> getSurahList();

  Future<({List<Reciter>? data, Failure? failure})> getAudioReciters();

  Future<({SurahRecitation? data, Failure? failure})> getSurahRecitation({
    required int surahNumber,
    required String reciterId,
  });
}
