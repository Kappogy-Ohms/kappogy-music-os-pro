import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/services/intent_handler_service.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_vu_meter.dart';
import '../domain/playback_state.dart';
import 'ab_looper_sheet.dart';
import 'audio_providers.dart';
import 'audiophile_dac_sheet.dart';
import 'haptic_bass_sheet.dart';
import 'pitch_formant_lab_sheet.dart';
import 'queue_bottom_sheet.dart';
import 'ringtone_trimmer_dialog.dart';
import 'sleep_timer_sheet.dart';
import 'spectral_analyzer_dialog.dart';
import 'studio_synth_sheet.dart';
import 'turntable_visualizer.dart';
import '../../intelligence/presentation/ear_training_game_dialog.dart';
import '../../library/presentation/library_providers.dart';

class NowPlayingScreen extends ConsumerWidget {
  final VoidCallback? onOpenEqualizer;
  final VoidCallback? onOpenDJMode;
  final VoidCallback? onOpenLyrics;
  final VoidCallback? onOpenTagEditor;

  const NowPlayingScreen({
    super.key,
    this.onOpenEqualizer,
    this.onOpenDJMode,
    this.onOpenLyrics,
    this.onOpenTagEditor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playbackStateProvider);
    final notifier = ref.read(playbackStateProvider.notifier);
    final track = state.currentTrack;

    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkeuoButton(
          size: 40,
          isCircular: false,
          icon: Icons.keyboard_arrow_down_rounded,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'STUDIO PLAYBACK CONSOLE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            shadows: SkeuoTokens.debossedText,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: SkeuoButton(
              size: 40,
              icon: Icons.bedtime_rounded,
              tooltip: 'Sleep Timer',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const SleepTimerSheet(),
                );
              },
            ),
          ),
          if (track != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SkeuoButton(
                size: 40,
                icon: Icons.share_rounded,
                tooltip: 'Share Audio Track (Intent)',
                activeColor: AppColors.ledCyan,
                onPressed: () => IntentHandlerService.shareAudioFile(track, context: context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SkeuoButton(
                size: 40,
                icon: track.isFavorite ? Icons.favorite : Icons.favorite_border,
                isActive: track.isFavorite,
                activeColor: AppColors.kappogyRed,
                onPressed: () {
                  ref.read(libraryNotifierProvider.notifier).toggleFavorite(track.id);
                },
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  // Center Turntable Deck & Audio Spectrum
                  SkeuoPanel(
                    showCornerScrews: true,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Turntable Platter
                        Center(
                          child: TurntableVisualizer(
                            track: track,
                            isPlaying: state.isPlaying,
                            size: isWide ? 260 : 210,
                            onScratch: (delta) {
                              final newPos = state.position + Duration(milliseconds: (delta * 1200).toInt());
                              if (newPos >= Duration.zero && newPos <= state.duration) {
                                notifier.seek(newPos);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tri-Color LED VU Meter
                        SkeuoVUMeter(
                          isPlaying: state.isPlaying,
                          level: state.volume,
                          bands: isWide ? 32 : 20,
                          height: 48,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Track Metadata & Quality Badges
                  SkeuoPanel(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track?.title ?? 'No Track Loaded',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.3,
                                      shadows: SkeuoTokens.debossedText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${track?.artist ?? "Studio"} • ${track?.album ?? "Console"}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Hi-Res Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.panelSunken,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                                boxShadow: SkeuoTokens.sunkenWell,
                              ),
                              child: Text(
                                '${track?.codec ?? "MP3"} • ${track?.bitrate ?? 320}K',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ledCyan,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Time Scrubber Trench
                        Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6.0,
                                activeTrackColor: AppColors.kappogyRed,
                                inactiveTrackColor: AppColors.panelWell,
                                thumbColor: AppColors.textPrimary,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                                overlayColor: AppColors.kappogyRed.withValues(alpha: 0.2),
                              ),
                              child: Slider(
                                value: state.progress,
                                onChanged: (val) {
                                  final targetMs = (val * state.duration.inMilliseconds).toInt();
                                  notifier.seek(Duration(milliseconds: targetMs));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DurationFormatter.format(state.position),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMuted,
                                      shadows: SkeuoTokens.debossedText,
                                    ),
                                  ),
                                  Text(
                                    DurationFormatter.format(state.duration),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textMuted,
                                      shadows: SkeuoTokens.debossedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Transport Cluster & Rotary Volume Master
                  SkeuoPanel(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle Toggle
                        SkeuoButton(
                          size: 44,
                          icon: Icons.shuffle_rounded,
                          isActive: state.isShuffle,
                          activeColor: AppColors.ledPurple,
                          onPressed: () => notifier.toggleShuffle(),
                        ),

                        // Prev
                        SkeuoButton(
                          size: 50,
                          icon: Icons.skip_previous_rounded,
                          onPressed: () => notifier.previous(),
                        ),

                        // Master Play/Pause
                        SkeuoButton(
                          size: 68,
                          icon: state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          isActive: state.isPlaying,
                          activeColor: AppColors.kappogyRed,
                          onPressed: () => notifier.togglePlayPause(),
                        ),

                        // Next
                        SkeuoButton(
                          size: 50,
                          icon: Icons.skip_next_rounded,
                          onPressed: () => notifier.next(),
                        ),

                        // Repeat Mode
                        SkeuoButton(
                          size: 44,
                          icon: state.repeatMode == AudioRepeatMode.one
                              ? Icons.repeat_one_rounded
                              : Icons.repeat_rounded,
                          isActive: state.repeatMode != AudioRepeatMode.off,
                          activeColor: AppColors.kappogyYellow,
                          onPressed: () => notifier.toggleRepeat(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Studio Mode Quick Links (EQ, DJ, Lyrics, Metadata) & Volume Knob
                  SkeuoPanel(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Rotary Volume Knob
                        SkeuoKnob(
                          value: state.volume * 100,
                          min: 0,
                          max: 100,
                          size: 90,
                          label: 'Volume',
                          displayValue: '${(state.volume * 100).round()}%',
                          ledColor: AppColors.ledCyan,
                          onChanged: (val) {
                            notifier.setVolume(val / 100.0);
                          },
                        ),

                        // Quick Studio Action Buttons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SkeuoButton(
                                  size: 42,
                                  isCircular: false,
                                  icon: Icons.equalizer_rounded,
                                  tooltip: 'Equalizer Rack',
                                  onPressed: onOpenEqualizer,
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 42,
                                  isCircular: false,
                                  icon: Icons.album_rounded,
                                  tooltip: 'DJ Mixing Console',
                                  activeColor: AppColors.kappogyYellow,
                                  onPressed: onOpenDJMode,
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 42,
                                  isCircular: false,
                                  icon: Icons.lyrics_rounded,
                                  tooltip: 'Synchronized Lyrics',
                                  activeColor: AppColors.ledPurple,
                                  onPressed: onOpenLyrics,
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 42,
                                  isCircular: false,
                                  icon: Icons.edit_note_rounded,
                                  tooltip: 'Edit Metadata Tags',
                                  activeColor: AppColors.kappogyGreen,
                                  onPressed: onOpenTagEditor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.queue_music_rounded,
                                  tooltip: 'Playback Queue',
                                  activeColor: AppColors.kappogyYellow,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => const QueueBottomSheet(),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.album_rounded,
                                  tooltip: 'Audiophile DAC Stats',
                                  activeColor: AppColors.ledCyan,
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => const AudiophileDacSheet(),
                                    );
                                  },
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.repeat_rounded,
                                  tooltip: 'A-B Precision Looper & Practice Deck',
                                  activeColor: AppColors.kappogyGreen,
                                  onPressed: () => AbLooperSheet.show(context),
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.graphic_eq_rounded,
                                  tooltip: 'True Lossless Spectral Analyzer',
                                  activeColor: AppColors.ledCyan,
                                  onPressed: () {
                                    if (state.currentTrack != null) {
                                      SpectralAnalyzerDialog.show(context, state.currentTrack!);
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.cut_rounded,
                                  tooltip: 'Ringtone & Audio Trimmer',
                                  activeColor: AppColors.kappogyYellow,
                                  onPressed: () {
                                    if (state.currentTrack != null) {
                                      RingtoneTrimmerDialog.show(context, state.currentTrack!);
                                    }
                                  },
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.vibration_rounded,
                                  tooltip: 'Tactile Haptic Sub-Bass Shaker',
                                  activeColor: AppColors.kappogyRed,
                                  onPressed: () => HapticBassSheet.show(context),
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.piano_rounded,
                                  tooltip: 'Studio Tone Generator & Tuner Synth',
                                  activeColor: AppColors.kappogyGreen,
                                  onPressed: () => StudioSynthSheet.show(context),
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.speed_rounded,
                                  tooltip: 'Pitch & Formant Shifting Lab',
                                  activeColor: AppColors.ledPurple,
                                  onPressed: () => PitchFormantLabSheet.show(context),
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.psychology_rounded,
                                  tooltip: 'Musician Ear Training Pitch Game',
                                  activeColor: AppColors.kappogyYellow,
                                  onPressed: () => EarTrainingGameDialog.show(context),
                                ),
                                const SizedBox(width: 8),
                                SkeuoButton(
                                  size: 34,
                                  isCircular: false,
                                  icon: Icons.file_open_rounded,
                                  tooltip: 'Play With... (Open External Audio File)',
                                  activeColor: AppColors.ledCyan,
                                  onPressed: () => IntentHandlerService.openExternalAudioPicker(context, ref),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
