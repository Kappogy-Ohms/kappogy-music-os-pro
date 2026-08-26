import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../audio_player/domain/playback_state.dart';
import '../../audio_player/presentation/audio_providers.dart';
import '../../recorder/presentation/studio_recorder_sheet.dart';

class CarModeScreen extends ConsumerWidget {
  const CarModeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(playbackStateProvider);
    final notifier = ref.read(playbackStateProvider.notifier);
    final track = playbackState.currentTrack;

    return Scaffold(
      backgroundColor: const Color(0xFF0C0E12), // High contrast deep matte black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: SkeuoButton(
            size: 48,
            isCircular: false,
            icon: Icons.close_rounded,
            tooltip: 'Exit Car Mode',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.directions_car_filled_rounded, color: AppColors.ledCyan, size: 22),
            SizedBox(width: 8),
            Text(
              'CAR MEDIA DASHBOARD',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.0,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SkeuoButton(
              size: 48,
              isCircular: true,
              icon: Icons.mic_rounded,
              tooltip: 'Voice Search / Mic',
              activeColor: AppColors.kappogyRed,
              onPressed: () => StudioRecorderSheet.show(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              // Track Information Card (Oversized for Distraction-Free Visibility)
              SkeuoPanel(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                showCornerScrews: true,
                child: Row(
                  children: [
                    // Analog Speedometer Progress Gauge
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.panelSunken,
                        border: Border.all(color: AppColors.ledCyan, width: 2.0),
                        boxShadow: SkeuoTokens.sunkenWell,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              playbackState.duration.inSeconds > 0
                                  ? '${((playbackState.position.inMilliseconds / playbackState.duration.inMilliseconds) * 100).toInt()}%'
                                  : '0%',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.ledCyan),
                            ),
                            const Text('PROGRESS', style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Track Title & Artist
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track?.title ?? 'No Track Playing',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track?.artist ?? 'Select a Driving Playlist below',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.kappogyGreen,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${DurationFormatter.format(playbackState.position)} / ${DurationFormatter.format(playbackState.duration)}',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Big Tactile Transport Console (Oversized Touch Targets)
              SkeuoPanel(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                showCornerScrews: true,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // 15s Skip Back
                        SkeuoButton(
                          size: 56,
                          isCircular: false,
                          icon: Icons.replay_10_rounded,
                          tooltip: 'Skip Back 10s',
                          onPressed: () {
                            final newPos = playbackState.position - const Duration(seconds: 10);
                            notifier.seek(newPos >= Duration.zero ? newPos : Duration.zero);
                          },
                        ),

                        // Previous Track
                        SkeuoButton(
                          size: 56,
                          isCircular: false,
                          icon: Icons.skip_previous_rounded,
                          tooltip: 'Previous Track',
                          onPressed: notifier.previous,
                        ),

                        // Huge Center Play/Pause Button
                        SkeuoButton(
                          size: 78,
                          isCircular: true,
                          icon: playbackState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          isActive: playbackState.isPlaying,
                          activeColor: AppColors.kappogyGreen,
                          tooltip: playbackState.isPlaying ? 'Pause' : 'Play',
                          onPressed: notifier.togglePlayPause,
                        ),

                        // Next Track
                        SkeuoButton(
                          size: 56,
                          isCircular: false,
                          icon: Icons.skip_next_rounded,
                          tooltip: 'Next Track',
                          onPressed: notifier.next,
                        ),

                        // 15s Skip Forward
                        SkeuoButton(
                          size: 56,
                          isCircular: false,
                          icon: Icons.forward_10_rounded,
                          tooltip: 'Skip Forward 10s',
                          onPressed: () {
                            final newPos = playbackState.position + const Duration(seconds: 10);
                            if (newPos <= playbackState.duration) notifier.seek(newPos);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Volume Knob & Shuffle/Repeat Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SkeuoButton(
                          size: 48,
                          isCircular: false,
                          icon: Icons.shuffle_rounded,
                          isActive: playbackState.isShuffle,
                          activeColor: AppColors.ledCyan,
                          tooltip: 'Shuffle',
                          onPressed: notifier.toggleShuffle,
                        ),

                        SkeuoKnob(
                          label: 'CAR VOLUME',
                          value: playbackState.volume,
                          min: 0.0,
                          max: 1.0,
                          size: 68,
                          ledColor: AppColors.kappogyGreen,
                          onChanged: notifier.setVolume,
                          displayValue: '${(playbackState.volume * 100).toInt()}%',
                        ),

                        SkeuoButton(
                          size: 48,
                          isCircular: false,
                          icon: Icons.repeat_rounded,
                          isActive: playbackState.repeatMode != AudioRepeatMode.off,
                          activeColor: AppColors.kappogyYellow,
                          tooltip: 'Repeat',
                          onPressed: notifier.toggleRepeat,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Quick Smart Driving Playlists
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SMART DRIVING PLAYLISTS (OFFLINE)',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  _buildCarPlaylistTile(context, 'HIGHWAY CRUISE', Icons.speed_rounded, const Color(0xFFFF5252)),
                  const SizedBox(width: 8),
                  _buildCarPlaylistTile(context, 'CHILL COMMUTE', Icons.nightlife_rounded, const Color(0xFF00E5FF)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildCarPlaylistTile(context, 'UPBEAT ENERGY', Icons.bolt_rounded, const Color(0xFFFFD700)),
                  const SizedBox(width: 8),
                  _buildCarPlaylistTile(context, 'ALL FAVORITES', Icons.favorite_rounded, const Color(0xFFD500F9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarPlaylistTile(BuildContext context, String title, IconData icon, Color accent) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded Driving Playlist: $title'),
              backgroundColor: accent,
            ),
          );
        },
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.panelRaised,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: accent.withValues(alpha: 0.6), width: 1.2),
            boxShadow: SkeuoTokens.raisedSm,
          ),
          child: Row(
            children: [
              Icon(icon, color: accent, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
