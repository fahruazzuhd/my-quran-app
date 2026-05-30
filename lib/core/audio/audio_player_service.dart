import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:my_quran/domain/entities/surah_recitation.dart';

enum PlaybackState { idle, loading, playing, paused, completed, error }

class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;
  SurahRecitation? _currentRecitation;

  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _currentAyahIndexController = StreamController<int>.broadcast();

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<int?>? _indexSub;

  Stream<PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;

  Stream<Duration> get positionStream => _positionController.stream;

  Stream<Duration> get durationStream => _durationController.stream;

  Stream<int> get currentAyahIndexStream => _currentAyahIndexController.stream;

  PlaybackState _state = PlaybackState.idle;
  PlaybackState get state => _state;

  Duration get position => _player.position;

  Duration get duration => _player.duration ?? Duration.zero;

  bool get isPlaying => _player.playing;

  SurahRecitation? get currentRecitation => _currentRecitation;

  int get currentAyahIndex => _player.currentIndex ?? 0;

  void _setState(PlaybackState s) {
    _state = s;
    if (!_playbackStateController.isClosed) {
      _playbackStateController.add(s);
    }
  }

  Future<void> loadAndPlay(SurahRecitation recitation) async {
    _currentRecitation = recitation;
    _setState(PlaybackState.loading);
    await _player.stop();

    try {
      final sources = recitation.ayahs
          .map((a) => AudioSource.uri(Uri.parse(a.audioUrl)))
          .toList();

      await _player.setAudioSource(
        ConcatenatingAudioSource(children: sources),
      );
      _listenToPlayer();
      await _player.play();
      _setState(PlaybackState.playing);
    } catch (_) {
      _setState(PlaybackState.error);
      rethrow;
    }
  }

  void _listenToPlayer() {
    _positionSub?.cancel();
    _durationSub?.cancel();
    _playerStateSub?.cancel();
    _indexSub?.cancel();

    _positionSub = _player.positionStream.listen((pos) {
      if (!_positionController.isClosed) _positionController.add(pos);
    });

    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null && !_durationController.isClosed) {
        _durationController.add(dur);
      }
    });

    _indexSub = _player.currentIndexStream.listen((index) {
      if (index != null && !_currentAyahIndexController.isClosed) {
        _currentAyahIndexController.add(index);
      }
    });

    _playerStateSub = _player.playerStateStream.listen((ps) {
      if (ps.processingState == ProcessingState.completed) {
        _setState(PlaybackState.completed);
      } else if (ps.playing) {
        _setState(PlaybackState.playing);
      } else if (_state != PlaybackState.loading &&
          _state != PlaybackState.idle) {
        _setState(PlaybackState.paused);
      }
    });
  }

  Future<void> play() async {
    if (_currentRecitation == null) return;
    await _player.play();
    _setState(PlaybackState.playing);
  }

  Future<void> pause() async {
    await _player.pause();
    _setState(PlaybackState.paused);
  }

  Future<void> resume() async {
    await play();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekToFraction(double fraction) async {
    final dur = _player.duration;
    if (dur == null || dur.inMilliseconds == 0) return;
    final clamped = fraction.clamp(0.0, 1.0);
    await seek(Duration(milliseconds: (dur.inMilliseconds * clamped).round()));
  }

  Future<void> stop() async {
    await _player.stop();
    _setState(PlaybackState.idle);
  }

  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _durationSub?.cancel();
    await _playerStateSub?.cancel();
    await _indexSub?.cancel();
    await _playbackStateController.close();
    await _positionController.close();
    await _durationController.close();
    await _currentAyahIndexController.close();
    await _player.dispose();
  }
}
