import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.numberOfAyahs,
    required this.revelationType,
  });

  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final int numberOfAyahs;
  final String revelationType;

  @override
  List<Object?> get props => [
        number,
        name,
        englishName,
        englishNameTranslation,
        numberOfAyahs,
        revelationType,
      ];
}
