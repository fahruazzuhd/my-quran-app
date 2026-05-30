import 'dart:async';

import 'package:get/get.dart';
import 'package:my_quran/core/audio/audio_player_service.dart';
import 'package:my_quran/domain/entities/surah_recitation.dart';

class PlayerController extends GetxController {
  PlayerController({required AudioPlayerService audioPlayerService})
      : _audio = audioPlayerService;

  final AudioPlayerService _audio;

  final playbackState = PlaybackState.idle.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final currentAyahIndex = 0.obs;
  final isSeeking = false.obs;
  final seekPosition = 0.0.obs;

  StreamSubscription<PlaybackState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<int>? _ayahSub;

  SurahRecitation? get recitation => _audio.currentRecitation;

  String get currentAyahLabel {
    final r = recitation;
    if (r == null) return '';
    final idx = currentAyahIndex.value + 1;
    return 'Ayah $idx / ${r.ayahs.length}';
  }

  @override
  void onInit() {
    super.onInit();
    _bindStreams();
    position.value = _audio.position;
    duration.value = _audio.duration;
    playbackState.value = _audio.state;
    currentAyahIndex.value = _audio.currentAyahIndex;
  }

  void _bindStreams() {
    _stateSub = _audio.playbackStateStream.listen((s) {
      playbackState.value = s;
    });
    _positionSub = _audio.positionStream.listen((p) {
      if (!isSeeking.value) {
        position.value = p;
        final dur = duration.value;
        if (dur.inMilliseconds > 0) {
          seekPosition.value = p.inMilliseconds / dur.inMilliseconds;
        }
      }
    });
    _durationSub = _audio.durationStream.listen((d) {
      duration.value = d;
    });
    _ayahSub = _audio.currentAyahIndexStream.listen((i) {
      currentAyahIndex.value = i;
    });
  }

  String formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:$m:$s';
    }
    return '$m:$s';
  }

  Future<void> togglePlayPause() => _audio.togglePlayPause();

  Future<void> play() => _audio.play();

  Future<void> pause() => _audio.pause();

  Future<void> resume() => _audio.resume();

  void onSeekStart(double value) {
    isSeeking.value = true;
    seekPosition.value = value;
    final dur = duration.value;
    position.value = Duration(
      milliseconds: (dur.inMilliseconds * value).round(),
    );
  }

  Future<void> onSeekEnd(double value) async {
    isSeeking.value = false;
    await _audio.seekToFraction(value);
  }

  @override
  void onClose() {
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _ayahSub?.cancel();
    super.onClose();
  }
}
