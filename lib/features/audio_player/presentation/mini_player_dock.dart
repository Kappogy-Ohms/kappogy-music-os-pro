import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import 'audio_providers.dart';

class MiniPlayerDock extends ConsumerWidget {
  final VoidCallback onTap;

  const MiniPlayerDock({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackStateProvider);
    final notifier = ref.read(playbackStateProvider.notifier);
    final track = state.currentTrack;

    if (track == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.panelRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderProminent, width: 1.2),
          boxShadow: [
            ...SkeuoTokens.raisedLg,
            const BoxShadow(
              color: AppColors.highlightSharp,
              offset: Offset(-1, -1),
              blurRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              // Top Micro-Progress Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 2.5,
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: AppColors.panelWell,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kappogyRed),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Mini Platter / Album Art Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.panelSunken,
                        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                        boxShadow: SkeuoTokens.sunkenWell,
                      ),
                      child: Center(
                        child: Text(
                          'Ω',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: state.isPlaying ? AppColors.kappogyYellow : AppColors.textMuted,
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Artist
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              shadows: SkeuoTokens.debossedText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Play/Pause Button
                    SkeuoButton(
                      size: 42,
                      icon: state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      isActive: state.isPlaying,
                      activeColor: AppColors.kappogyRed,
                      onPressed: () => notifier.togglePlayPause(),
                    ),
                    const SizedBox(width: 8),

                    // Next Button
                    SkeuoButton(
                      size: 38,
                      icon: Icons.skip_next_rounded,
                      onPressed: () => notifier.next(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
