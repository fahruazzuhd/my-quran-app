import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_quran/core/audio/audio_player_service.dart';
import 'package:my_quran/core/theme/app_theme.dart';
import 'package:my_quran/core/utils/format_utils.dart';
import 'package:my_quran/presentation/controllers/home_controller.dart';
import 'package:my_quran/presentation/controllers/player_controller.dart';
import 'package:my_quran/presentation/routes/app_routes.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key, required this.audioService});

  final AudioPlayerService audioService;

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final playerController = Get.find<PlayerController>();

    return Obx(() {
      final activeNumber = homeController.activeSurahNumber.value;
      final rec = audioService.currentRecitation;

      if (activeNumber == null || rec == null) {
        return const SizedBox.shrink();
      }

      final position = playerController.position.value;
      final isPlaying =
          homeController.playbackState.value == PlaybackState.playing;

      return Material(
        color: AppTheme.cardDark,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.player),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.menu_book, color: AppTheme.accentGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rec.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${rec.artist} · ${FormatUtils.duration(position)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.accentGold,
                  ),
                  onPressed: () => playerController.togglePlayPause(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
