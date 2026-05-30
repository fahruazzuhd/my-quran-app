import 'dart:async';
import 'dart:math';

import 'package:just_audio/just_audio.dart';
import 'package:my_quran/core/audio/surah_playback_timeline.dart';
import 'package:my_quran/domain/entities/surah_recitation.dart';

enum PlaybackState { idle, loading, playing, paused, completed, error }

class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  static const _maxAyahsToProbeUpfront = 40;
  static const _probeBatchSize = 4;

  final AudioPlayer _player;
  final SurahPlaybackTimeline _timeline = SurahPlaybackTimeline();
  SurahRecitation? _currentRecitation;

  final _playbackStateController = StreamController<PlaybackState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _currentAyahIndexController = StreamController<int>.broadcast();

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<int?>? _indexSub;
  StreamSubscription<SequenceState?>? _sequenceSub;

  Stream<PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;

  Stream<Duration> get positionStream => _positionController.stream;

  Stream<Duration> get durationStream => _durationController.stream;

  Stream<int> get currentAyahIndexStream => _currentAyahIndexController.stream;

  PlaybackState _state = PlaybackState.idle;
  PlaybackState get state => _state;

  Duration get position => _timeline.globalPosition(
        currentIndex: _player.currentIndex,
        localPosition: _player.position,
      );

  Duration get duration => _timeline.totalDuration;

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
      final urls = recitation.ayahs.map((a) => a.audioUrl).toList();
      final knownDurations = urls.length <= _maxAyahsToProbeUpfront
          ? await _probeDurations(urls)
          : List<Duration>.filled(urls.length, Duration.zero);

      _timeline.setSegmentDurations(knownDurations);
      _emitTimelineDuration();

      final sources = recitation.ayahs
          .map((a) => AudioSource.uri(Uri.parse(a.audioUrl)))
          .toList();

      await _player.setAudioSource(
        ConcatenatingAudioSource(
          children: sources,
          useLazyPreparation: false,
        ),
      );
      _listenToPlayer();
      _refreshTimelineFromSequence();
      _emitGlobalPosition();
      await _player.play();
      _setState(PlaybackState.playing);
    } catch (_) {
      _setState(PlaybackState.error);
      rethrow;
    }
  }

  Future<List<Duration>> _probeDurations(List<String> urls) async {
    final durations = List<Duration>.filled(urls.length, Duration.zero);

    for (var start = 0; start < urls.length; start += _probeBatchSize) {
      final end = min(start + _probeBatchSize, urls.length);
      await Future.wait([
        for (var i = start; i < end; i++) _probeSingleDuration(i, urls[i], durations),
      ]);
    }

    return durations;
  }

  Future<void> _probeSingleDuration(
    int index,
    String url,
    List<Duration> durations,
  ) async {
    final probe = AudioPlayer();
    try {
      final duration = await probe.setAudioSource(
        AudioSource.uri(Uri.parse(url)),
      );
      durations[index] = duration ?? Duration.zero;
    } catch (_) {
      durations[index] = Duration.zero;
    } finally {
      await probe.dispose();
    }
  }

  void _listenToPlayer() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _indexSub?.cancel();
    _sequenceSub?.cancel();

    _positionSub = _player.positionStream.listen((_) {
      _emitGlobalPosition();
    });

    _sequenceSub = _player.sequenceStateStream.listen((_) {
      _refreshTimelineFromSequence();
    });

    _indexSub = _player.currentIndexStream.listen((index) {
      if (index != null && !_currentAyahIndexController.isClosed) {
        _currentAyahIndexController.add(index);
      }
      _emitGlobalPosition();
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

  void _refreshTimelineFromSequence() {
    final state = _player.sequenceState;
    if (state == null) return;

    final sequence = state.sequence;
    if (sequence.isEmpty) return;

    final before = _timeline.totalDuration;
    _timeline.updateFromSequence(sequence);

    if (_timeline.totalDuration != before) {
      _emitTimelineDuration();
    }
    _emitGlobalPosition();
  }

  void _emitGlobalPosition() {
    if (_positionController.isClosed) return;
    _positionController.add(position);
  }

  void _emitTimelineDuration() {
    final total = _timeline.totalDuration;
    if (total <= Duration.zero || _durationController.isClosed) return;
    _durationController.add(total);
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

  Future<void> resume() async => play();

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> seek(Duration globalPosition) async {
    final target = _timeline.locateGlobal(globalPosition);
    await _player.seek(target.localPosition, index: target.index);
    _emitGlobalPosition();
  }

  Future<void> seekToFraction(double fraction) async {
    final total = _timeline.totalDuration;
    if (total.inMilliseconds <= 0) return;
    final clamped = fraction.clamp(0.0, 1.0);
    final global = Duration(
      milliseconds: (total.inMilliseconds * clamped).round(),
    );
    await seek(global);
  }

  Future<void> stop() async {
    await _player.stop();
    _timeline.setSegmentDurations([]);
    _setState(PlaybackState.idle);
  }

  Future<void> dispose() async {
    await _positionSub?.cancel();
    await _playerStateSub?.cancel();
    await _indexSub?.cancel();
    await _sequenceSub?.cancel();
    await _playbackStateController.close();
    await _positionController.close();
    await _durationController.close();
    await _currentAyahIndexController.close();
    await _player.dispose();
  }
}
