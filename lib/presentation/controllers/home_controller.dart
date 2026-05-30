import 'dart:async';

import 'package:get/get.dart';
import 'package:my_quran/core/audio/audio_player_service.dart';
import 'package:my_quran/core/constants/api_constants.dart';
import 'package:my_quran/domain/entities/reciter.dart';
import 'package:my_quran/domain/entities/surah.dart';
import 'package:my_quran/domain/usecases/get_audio_reciters.dart';
import 'package:my_quran/domain/usecases/get_surah_list.dart';
import 'package:my_quran/domain/usecases/get_surah_recitation.dart';
import 'package:my_quran/presentation/routes/app_routes.dart';

class HomeController extends GetxController {
  HomeController({
    required GetSurahList getSurahList,
    required GetAudioReciters getAudioReciters,
    required GetSurahRecitation getSurahRecitation,
    required AudioPlayerService audioPlayerService,
  })  : _getSurahList = getSurahList,
        _getAudioReciters = getAudioReciters,
        _getSurahRecitation = getSurahRecitation,
        _audioPlayerService = audioPlayerService;

  final GetSurahList _getSurahList;
  final GetAudioReciters _getAudioReciters;
  final GetSurahRecitation _getSurahRecitation;
  final AudioPlayerService _audioPlayerService;

  final isLoading = true.obs;
  final loadingSurahNumber = RxnInt();
  final activeSurahNumber = RxnInt();
  final playbackState = PlaybackState.idle.obs;
  final errorMessage = RxnString();
  final searchQuery = ''.obs;
  final selectedReciterId = ApiConstants.defaultReciterId.obs;

  final _allSurahs = <Surah>[].obs;
  final reciters = <Reciter>[].obs;

  StreamSubscription<PlaybackState>? _playbackSub;
  bool _isAdvancingSurah = false;
  int _playbackGeneration = 0;

  static const int minSurahNumber = 1;
  static const int maxSurahNumber = 114;

  List<Surah> get filteredSurahs {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return _allSurahs;

    final selectedReciter = reciters.firstWhereOrNull(
      (r) => r.id == selectedReciterId.value,
    );
    final reciterName = selectedReciter?.englishName.toLowerCase() ?? '';

    return _allSurahs.where((s) {
      final matchTitle = s.englishName.toLowerCase().contains(q) ||
          s.englishNameTranslation.toLowerCase().contains(q) ||
          s.name.contains(q) ||
          s.number.toString() == q;
      final matchArtist = reciterName.contains(q);
      return matchTitle || matchArtist;
    }).toList();
  }

  Reciter? get selectedReciter =>
      reciters.firstWhereOrNull((r) => r.id == selectedReciterId.value);

  bool isSurahPlaying(int surahNumber) =>
      activeSurahNumber.value == surahNumber &&
      playbackState.value == PlaybackState.playing;

  bool isSurahActive(int surahNumber) => activeSurahNumber.value == surahNumber;

  int? get currentSurahNumber =>
      _audioPlayerService.currentRecitation?.surah.number ??
      activeSurahNumber.value;

  bool get canPlayPreviousSurah =>
      (currentSurahNumber ?? minSurahNumber) > minSurahNumber;

  bool get canPlayNextSurah =>
      (currentSurahNumber ?? maxSurahNumber) < maxSurahNumber;

  @override
  void onInit() {
    super.onInit();
    _syncFromAudioService();
    _playbackSub = _audioPlayerService.playbackStateStream.listen((state) {
      if (state == PlaybackState.completed) {
        _handleSurahCompleted();
      }
      _syncFromAudioService();
    });
    loadData();
  }

  void _syncFromAudioService() {
    playbackState.value = _audioPlayerService.state;
    final rec = _audioPlayerService.currentRecitation;
    final state = _audioPlayerService.state;

    if (rec == null || state == PlaybackState.idle) {
      activeSurahNumber.value = null;
      return;
    }

    activeSurahNumber.value = rec.surah.number;
  }

  Surah? _surahByNumber(int number) =>
      _allSurahs.firstWhereOrNull((s) => s.number == number);

  Future<void> playNextSurah() => playAdjacentSurah(1);

  Future<void> playPreviousSurah() => playAdjacentSurah(-1);

  Future<void> playAdjacentSurah(int delta) async {
    final base = currentSurahNumber;
    if (base == null) return;

    final target = base + delta;
    if (target < minSurahNumber || target > maxSurahNumber) return;

    final surah = _surahByNumber(target);
    if (surah == null) return;

    await _startSurahPlayback(surah, openPlayer: false);
  }

  Future<void> _handleSurahCompleted() async {
    if (_isAdvancingSurah) return;

    final current = _audioPlayerService.currentRecitation;
    if (current == null) return;

    final nextNumber = current.surah.number + 1;
    if (nextNumber > maxSurahNumber) return;

    final nextSurah = _surahByNumber(nextNumber);
    if (nextSurah == null) return;

    await _startSurahPlayback(nextSurah, openPlayer: false);
  }

  @override
  void onClose() {
    _playbackSub?.cancel();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = null;

    final surahResult = await _getSurahList();
    final reciterResult = await _getAudioReciters();

    if (surahResult.failure != null) {
      errorMessage.value = surahResult.failure!.message;
    } else {
      _allSurahs.assignAll(surahResult.data ?? []);
    }

    if (reciterResult.failure != null && errorMessage.value == null) {
      errorMessage.value = reciterResult.failure!.message;
    } else {
      reciters.assignAll(reciterResult.data ?? []);
    }

    isLoading.value = false;
  }

  void updateSearch(String value) => searchQuery.value = value;

  void selectReciter(String reciterId) => selectedReciterId.value = reciterId;

  bool _isSameTrack(Surah surah) {
    final current = _audioPlayerService.currentRecitation;
    return current != null &&
        current.surah.number == surah.number &&
        current.reciter.id == selectedReciterId.value;
  }

  Future<void> onPlayIconTap(Surah surah) async {
    if (_isSameTrack(surah)) {
      if (playbackState.value == PlaybackState.playing) {
        await _audioPlayerService.pause();
        return;
      }
      if (playbackState.value == PlaybackState.paused) {
        await _audioPlayerService.resume();
        return;
      }
    }

    await _startSurahPlayback(surah, openPlayer: false);
  }

  Future<void> onSurahRowTap(Surah surah) async {
    if (_isSameTrack(surah)) {
      if (playbackState.value == PlaybackState.paused) {
        await _audioPlayerService.resume();
      }
      await Get.toNamed(AppRoutes.player);
      return;
    }

    await _startSurahPlayback(surah, openPlayer: true);
  }

  Future<void> _startSurahPlayback(
    Surah surah, {
    required bool openPlayer,
  }) async {
    final generation = ++_playbackGeneration;
    _isAdvancingSurah = true;
    loadingSurahNumber.value = surah.number;
    errorMessage.value = null;

    await _audioPlayerService.prepareForNewSurah();

    final result = await _getSurahRecitation(
      surahNumber: surah.number,
      reciterId: selectedReciterId.value,
    );

    if (generation != _playbackGeneration) {
      _isAdvancingSurah = false;
      loadingSurahNumber.value = null;
      return;
    }

    loadingSurahNumber.value = null;

    if (result.failure != null) {
      _isAdvancingSurah = false;
      errorMessage.value = result.failure!.message;
      Get.snackbar('Error', result.failure!.message);
      return;
    }

    final recitation = result.data!;
    try {
      await _audioPlayerService.loadAndPlay(recitation);
      if (generation != _playbackGeneration) return;

      _syncFromAudioService();
      if (openPlayer) {
        await Get.toNamed(AppRoutes.player);
      }
    } catch (e) {
      if (generation == _playbackGeneration) {
        Get.snackbar('Playback Error', e.toString());
      }
    } finally {
      if (generation == _playbackGeneration) {
        _isAdvancingSurah = false;
      }
    }
  }
}
