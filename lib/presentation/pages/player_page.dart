import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_quran/core/audio/audio_player_service.dart';
import 'package:my_quran/core/theme/app_theme.dart';
import 'package:my_quran/core/utils/format_utils.dart';
import 'package:my_quran/presentation/controllers/home_controller.dart';
import 'package:my_quran/presentation/controllers/player_controller.dart';

class PlayerPage extends GetView<PlayerController> {
  const PlayerPage({super.key});

  HomeController get _home => Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      _home.activeSurahNumber.value;
      controller.playbackState.value;
      final rec = controller.recitation;
      if (rec == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Player')),
          body: const Center(child: Text('Nothing is playing.')),
        );
      }

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            onPressed: () => Get.back(),
          ),
          title: const Text('Now Playing'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.accentGold, width: 2),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 100,
                    color: AppTheme.accentGold,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  rec.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  rec.subtitle,
                  style: TextStyle(color: Colors.grey.shade400),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  rec.artist,
                  style: const TextStyle(
                    color: AppTheme.accentGold,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Full surah · ${controller.currentAyahLabel}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const Spacer(),
                _buildProgressSection(),
                const SizedBox(height: 24),
                _buildPlaybackControls(rec.surah.number),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProgressSection() {
    final pos = controller.position.value;
    final dur = controller.duration.value;
    final fraction = controller.seekPosition.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Slider(
          value: fraction.clamp(0.0, 1.0),
          onChanged: controller.onSeekStart,
          onChangeEnd: controller.onSeekEnd,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                FormatUtils.duration(pos),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
              Text(
                FormatUtils.duration(dur),
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybackControls(int surahNumber) {
    final state = controller.playbackState.value;
    final isPlaying = state == PlaybackState.playing;
    final isLoading = state == PlaybackState.loading;

    final canPrev = _home.canPlayPreviousSurah;
    final canNext = _home.canPlayNextSurah;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.skip_previous),
              color: canPrev && !isLoading
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              onPressed: canPrev && !isLoading
                  ? _home.playPreviousSurah
                  : null,
            ),
            const SizedBox(width: 8),
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.replay_10),
              onPressed: isLoading
                  ? null
                  : () async {
                      final newPos =
                          controller.position.value - const Duration(seconds: 10);
                      final durMs =
                          controller.duration.value.inMilliseconds.clamp(1, 1 << 31);
                      await controller.onSeekEnd(
                        (newPos.inMilliseconds / durMs).clamp(0.0, 1.0),
                      );
                    },
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isLoading ? null : controller.togglePlayPause,
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              iconSize: 40,
              icon: const Icon(Icons.forward_10),
              onPressed: isLoading
                  ? null
                  : () async {
                      final newPos =
                          controller.position.value + const Duration(seconds: 10);
                      final durMs = controller.duration.value.inMilliseconds;
                      if (durMs <= 0) return;
                      await controller.onSeekEnd(
                        (newPos.inMilliseconds / durMs).clamp(0.0, 1.0),
                      );
                    },
            ),
            const SizedBox(width: 8),
            IconButton(
              iconSize: 36,
              icon: const Icon(Icons.skip_next),
              color: canNext && !isLoading
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.3),
              onPressed:
                  canNext && !isLoading ? _home.playNextSurah : null,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Surah $surahNumber of 114',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }
}
