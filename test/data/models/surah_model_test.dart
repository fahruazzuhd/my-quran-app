import 'package:flutter_test/flutter_test.dart';
import 'package:my_quran/data/models/surah_model.dart';

void main() {
  group('SurahModel', () {
    test('fromJson parses surah metadata', () {
      final model = SurahModel.fromJson({
        'number': 1,
        'name': 'سُورَةُ ٱلْفَاتِحَةِ',
        'englishName': 'Al-Faatiha',
        'englishNameTranslation': 'The Opening',
        'numberOfAyahs': 7,
        'revelationType': 'Meccan',
      });

      expect(model.number, 1);
      expect(model.englishName, 'Al-Faatiha');
      expect(model.englishNameTranslation, 'The Opening');
      expect(model.numberOfAyahs, 7);
    });
  });
}
