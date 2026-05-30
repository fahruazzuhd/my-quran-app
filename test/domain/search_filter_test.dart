import 'package:flutter_test/flutter_test.dart';
import 'package:my_quran/domain/entities/reciter.dart';
import 'package:my_quran/domain/entities/surah.dart';

List<Surah> filterSurahs({
  required List<Surah> all,
  required String query,
  required Reciter? reciter,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return all;

  final reciterName = reciter?.englishName.toLowerCase() ?? '';

  return all.where((s) {
    final matchTitle = s.englishName.toLowerCase().contains(q) ||
        s.englishNameTranslation.toLowerCase().contains(q) ||
        s.name.contains(q) ||
        s.number.toString() == q;
    final matchArtist = reciterName.contains(q);
    return matchTitle || matchArtist;
  }).toList();
}

void main() {
  const surahs = [
    Surah(
      number: 1,
      name: 'Fatiha',
      englishName: 'Al-Faatiha',
      englishNameTranslation: 'The Opening',
      numberOfAyahs: 7,
      revelationType: 'Meccan',
    ),
    Surah(
      number: 2,
      name: 'Baqara',
      englishName: 'Al-Baqara',
      englishNameTranslation: 'The Cow',
      numberOfAyahs: 286,
      revelationType: 'Medinan',
    ),
  ];

  const reciter = Reciter(
    id: 'ar.alafasy',
    name: 'Alafasy',
    englishName: 'Alafasy',
  );

  test('empty query returns all surahs', () {
    expect(filterSurahs(all: surahs, query: '', reciter: reciter), surahs);
  });

  test('filters by surah english name', () {
    final result = filterSurahs(all: surahs, query: 'baqara', reciter: reciter);
    expect(result.length, 1);
    expect(result.first.number, 2);
  });

  test('filters by reciter name', () {
    final result = filterSurahs(all: surahs, query: 'alafasy', reciter: reciter);
    expect(result, surahs);
  });
}
