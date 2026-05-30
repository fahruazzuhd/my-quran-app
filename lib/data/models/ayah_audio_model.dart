import 'package:my_quran/domain/entities/ayah_audio.dart';

class AyahAudioModel extends AyahAudio {
  const AyahAudioModel({
    required super.number,
    required super.numberInSurah,
    required super.audioUrl,
  });

  factory AyahAudioModel.fromJson(Map<String, dynamic> json) {
    return AyahAudioModel(
      number: json['number'] as int,
      numberInSurah: json['numberInSurah'] as int,
      audioUrl: json['audio'] as String? ?? '',
    );
  }
}
