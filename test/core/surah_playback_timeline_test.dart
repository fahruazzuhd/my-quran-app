import 'package:flutter_test/flutter_test.dart';
import 'package:my_quran/core/audio/surah_playback_timeline.dart';

void main() {
  test('global position and seek mapping across segments', () {
    final timeline = SurahPlaybackTimeline()
      ..setSegmentDurations([
        const Duration(seconds: 6),
        const Duration(seconds: 8),
        const Duration(seconds: 5),
      ]);

    expect(timeline.totalDuration, const Duration(seconds: 19));
    expect(
      timeline.globalPosition(currentIndex: 1, localPosition: const Duration(seconds: 3)),
      const Duration(seconds: 9),
    );

    final located = timeline.locateGlobal(const Duration(seconds: 10));
    expect(located.index, 1);
    expect(located.localPosition, const Duration(seconds: 4));
  });
}
