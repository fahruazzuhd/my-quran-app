import 'package:equatable/equatable.dart';
import 'package:my_quran/domain/entities/ayah_audio.dart';
import 'package:my_quran/domain/entities/reciter.dart';
import 'package:my_quran/domain/entities/surah.dart';

class SurahRecitation extends Equatable {
  const SurahRecitation({
    required this.surah,
    required this.reciter,
    required this.ayahs,
  });

  final Surah surah;
  final Reciter reciter;
  final List<AyahAudio> ayahs;

  String get title => surah.englishName;

  String get artist => reciter.englishName;

  String get subtitle => surah.englishNameTranslation;

  @override
  List<Object?> get props => [surah, reciter, ayahs];
}
