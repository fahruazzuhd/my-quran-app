import 'package:just_audio/just_audio.dart';

class SurahPlaybackTimeline {
  List<Duration> _segments = [];
  List<Duration> _starts = [];
  Duration _total = Duration.zero;

  Duration get totalDuration => _total;

  bool get isReady =>
      _segments.isNotEmpty &&
      _segments.every((d) => d > Duration.zero) &&
      _total > Duration.zero;

  void setSegmentDurations(List<Duration> durations) {
    _segments = List.from(durations);
    _rebuild();
  }

  void updateFromSequence(List<IndexedAudioSource> sequence) {
    if (sequence.isEmpty) return;

    final updated = List<Duration>.generate(sequence.length, (i) {
      final fromPlayer = sequence[i].duration;
      if (fromPlayer != null && fromPlayer > Duration.zero) {
        return fromPlayer;
      }
      if (i < _segments.length && _segments[i] > Duration.zero) {
        return _segments[i];
      }
      return Duration.zero;
    });

    _segments = updated;
    _rebuild();
  }

  void _rebuild() {
    _starts = [];
    var elapsed = Duration.zero;
    for (final segment in _segments) {
      _starts.add(elapsed);
      elapsed += segment;
    }
    _total = elapsed;
  }

  Duration globalPosition({
    required int? currentIndex,
    required Duration localPosition,
  }) {
    if (_segments.isEmpty) return localPosition;
    final index = currentIndex ?? 0;
    if (index < 0 || index >= _starts.length) return localPosition;
    return _starts[index] + localPosition;
  }

  ({int index, Duration localPosition}) locateGlobal(Duration global) {
    if (_segments.isEmpty) {
      return (index: 0, localPosition: global);
    }

    final clamped = global < Duration.zero
        ? Duration.zero
        : (global > _total ? _total : global);

    for (var i = _segments.length - 1; i >= 0; i--) {
      if (clamped >= _starts[i]) {
        return (index: i, localPosition: clamped - _starts[i]);
      }
    }

    return (index: 0, localPosition: Duration.zero);
  }
}
