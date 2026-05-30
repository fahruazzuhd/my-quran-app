import 'package:my_quran/data/models/ayah_audio_model.dart';
import 'package:my_quran/data/models/reciter_model.dart';
import 'package:my_quran/data/models/surah_model.dart';
import 'package:my_quran/domain/entities/surah_recitation.dart';

class SurahDetailModel {
  SurahDetailModel({
    required this.surah,
    required this.ayahs,
  });

  final SurahModel surah;
  final List<AyahAudioModel> ayahs;

  factory SurahDetailModel.fromJson(Map<String, dynamic> json) {
    final ayahList = (json['ayahs'] as List<dynamic>? ?? [])
        .map((e) => AyahAudioModel.fromJson(e as Map<String, dynamic>))
        .where((a) => a.audioUrl.isNotEmpty)
        .toList();

    return SurahDetailModel(
      surah: SurahModel.fromJson(json),
      ayahs: ayahList,
    );
  }

  SurahRecitation toEntity(ReciterModel reciter) {
    return SurahRecitation(
      surah: surah,
      reciter: reciter,
      ayahs: ayahs,
    );
  }
}
