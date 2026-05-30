import 'package:flutter/material.dart';
import 'package:my_quran/core/theme/app_theme.dart';
import 'package:my_quran/domain/entities/surah.dart';

class SurahListTile extends StatelessWidget {
  const SurahListTile({
    super.key,
    required this.surah,
    required this.reciterName,
    required this.onRowTap,
    required this.onPlayTap,
    this.isLoading = false,
    this.isPlaying = false,
    this.isActive = false,
  });

  final Surah surah;
  final String reciterName;
  final VoidCallback onRowTap;
  final VoidCallback onPlayTap;
  final bool isLoading;
  final bool isPlaying;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isActive ? AppTheme.primaryGreen.withValues(alpha: 0.25) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen,
          child: Text(
            '${surah.number}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          surah.englishName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${surah.englishNameTranslation} · $reciterName · ${surah.numberOfAyahs} ayahs',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.accentGold,
                ),
              )
            : IconButton(
                icon: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                  color: AppTheme.accentGold,
                  size: 36,
                ),
                onPressed: onPlayTap,
              ),
        onTap: isLoading ? null : onRowTap,
      ),
    );
  }
}
