import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../library/presentation/library_providers.dart';
import 'audio_providers.dart';

class QueueBottomSheet extends ConsumerWidget {
  const QueueBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackStateProvider);
    final notifier = ref.read(playbackStateProvider.notifier);
    final queue = playbackState.queue;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: SkeuoTokens.raisedLg,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.panelSunken,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: SkeuoTokens.sunkenWell,
                      ),
                      child: const Icon(Icons.queue_music_rounded, color: AppColors.kappogyYellow, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'PLAYBACK QUEUE (${queue.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    // Save as Playlist Button
                    SkeuoButton(
                      size: 32,
                      isCircular: false,
                      icon: Icons.playlist_add_rounded,
                      activeColor: AppColors.kappogyGreen,
                      tooltip: 'Save as Playlist',
                      onPressed: () => _saveQueueAsPlaylist(context, ref),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Reorderable Queue List
            Expanded(
              child: queue.isEmpty
                  ? const Center(
                      child: Text(
                        'Queue is empty',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  : ReorderableListView.builder(
                      itemCount: queue.length,
                      onReorderItem: (oldIndex, newIndex) {
                        final updated = List.of(queue);
                        final item = updated.removeAt(oldIndex);
                        updated.insert(newIndex, item);
                        // Re-load queue with current track maintained
                        notifier.playTrack(playbackState.currentTrack ?? updated.first, updated);
                      },
                      itemBuilder: (context, idx) {
                        final track = queue[idx];
                        final isCurrent = playbackState.currentTrack?.id == track.id;

                        return Container(
                          key: ValueKey(track.id),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: isCurrent ? AppColors.panelRaised : AppColors.panelWell,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isCurrent ? AppColors.kappogyYellow.withValues(alpha: 0.6) : AppColors.borderSubtle,
                              width: 1.0,
                            ),
                            boxShadow: isCurrent ? SkeuoTokens.raisedSm : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                            leading: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrent ? AppColors.kappogyYellow : AppColors.panelSunken,
                                boxShadow: isCurrent ? SkeuoTokens.ledGlow(AppColors.kappogyYellow) : SkeuoTokens.sunkenWell,
                              ),
                              child: Center(
                                child: isCurrent
                                    ? const Icon(Icons.volume_up_rounded, size: 16, color: Colors.black)
                                    : Text(
                                        '${idx + 1}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                                      ),
                              ),
                            ),
                            title: Text(
                              track.title,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: isCurrent ? AppColors.kappogyYellow : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                            ),
                            subtitle: Text(
                              track.artist,
                              style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                              maxLines: 1,
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.textMuted, size: 18),
                                  onPressed: () {
                                    final updated = List.of(queue)..removeAt(idx);
                                    if (updated.isNotEmpty) {
                                      notifier.playTrack(playbackState.currentTrack ?? updated.first, updated);
                                    }
                                  },
                                ),
                                const Icon(Icons.drag_handle_rounded, color: AppColors.textMuted, size: 20),
                              ],
                            ),
                            onTap: () {
                              notifier.playTrack(track, queue);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveQueueAsPlaylist(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController(text: 'Saved Queue ${DateTime.now().hour}:${DateTime.now().minute}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.chassisBg,
        title: const Text('SAVE QUEUE AS PLAYLIST', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(hintText: 'Playlist Title...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kappogyGreen),
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                final queue = ref.read(playbackStateProvider).queue;
                final pl = await ref.read(playlistsNotifierProvider.notifier).createPlaylist(ctrl.text.trim());
                for (final track in queue) {
                  await ref.read(playlistsNotifierProvider.notifier).addTrackToPlaylist(pl.id, track.id);
                }
                if (context.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved playlist "${ctrl.text.trim()}"!'), backgroundColor: AppColors.kappogyGreen),
                  );
                }
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}
