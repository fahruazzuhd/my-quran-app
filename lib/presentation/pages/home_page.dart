import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_quran/core/audio/audio_player_service.dart';
import 'package:my_quran/core/di/injection.dart';
import 'package:my_quran/core/theme/app_theme.dart';
import 'package:my_quran/presentation/controllers/home_controller.dart';
import 'package:my_quran/presentation/widgets/mini_player_bar.dart';
import 'package:my_quran/presentation/widgets/surah_list_tile.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Quran'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadData,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search surah or reciter...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: controller.updateSearch,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Obx(_buildReciterDropdown),
          ),
          Expanded(child: Obx(_buildBody)),
        ],
      ),
      bottomNavigationBar: MiniPlayerBar(audioService: sl()),
    );
  }

  Widget _buildReciterDropdown() {
    final reciterList = controller.reciters;
    final selectedId = controller.selectedReciterId.value;

    if (reciterList.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        const Icon(Icons.mic, size: 20, color: AppTheme.accentGold),
        const SizedBox(width: 8),
        const Text('Reciter:', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedId,
              items: reciterList
                  .map(
                    (r) => DropdownMenuItem(
                      value: r.id,
                      child: Text(
                        r.englishName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                if (id != null) controller.selectReciter(id);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (controller.isLoading.value) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.errorMessage.value != null &&
        controller.filteredSurahs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(controller.errorMessage.value!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final surahs = controller.filteredSurahs;
    if (surahs.isEmpty) {
      return const Center(child: Text('No surahs match your search.'));
    }

    final reciterName =
        controller.selectedReciter?.englishName ?? 'Reciter';
    final loadingNumber = controller.loadingSurahNumber.value;
    final playback = controller.playbackState.value;
    final activeNumber = controller.activeSurahNumber.value;

    return RefreshIndicator(
      onRefresh: controller.loadData,
      child: ListView.builder(
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          final surah = surahs[index];
          final isActive = activeNumber == surah.number;
          final isPlaying =
              isActive && playback == PlaybackState.playing;

          return SurahListTile(
            surah: surah,
            reciterName: reciterName,
            isActive: isActive,
            isPlaying: isPlaying,
            isLoading: loadingNumber == surah.number,
            onRowTap: () => controller.onSurahRowTap(surah),
            onPlayTap: () => controller.onPlayIconTap(surah),
          );
        },
      ),
    );
  }
}
