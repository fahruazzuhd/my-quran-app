import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_quran/core/theme/app_theme.dart';
import 'package:my_quran/domain/entities/surah.dart';
import 'package:my_quran/presentation/widgets/surah_list_tile.dart';

void main() {
  testWidgets('SurahListTile shows surah title and play icon', (tester) async {
    const surah = Surah(
      number: 1,
      name: 'Fatiha',
      englishName: 'Al-Faatiha',
      englishNameTranslation: 'The Opening',
      numberOfAyahs: 7,
      revelationType: 'Meccan',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: SurahListTile(
            surah: surah,
            reciterName: 'Alafasy',
            onRowTap: () {},
            onPlayTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Al-Faatiha'), findsOneWidget);
    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);
  });
}
