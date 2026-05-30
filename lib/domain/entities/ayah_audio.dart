import 'package:equatable/equatable.dart';

class AyahAudio extends Equatable {
  const AyahAudio({
    required this.number,
    required this.numberInSurah,
    required this.audioUrl,
  });

  final int number;
  final int numberInSurah;
  final String audioUrl;

  @override
  List<Object?> get props => [number, numberInSurah, audioUrl];
}
