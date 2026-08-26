import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/utils/audio_math.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../domain/dj_deck_model.dart';

class DeckWidget extends StatelessWidget {
  final DjDeckState deck;
  final VoidCallback onSelectTrack;
  final VoidCallback onTogglePlay;
  final VoidCallback onCue;
  final VoidCallback onSync;
  final Function(int) onHotCue;
  final ValueChanged<double> onPitchChanged;
  final ValueChanged<Duration> onSeek;
  final Color accentColor;

  const DeckWidget({
    super.key,
    required this.deck,
    required this.onSelectTrack,
    required this.onTogglePlay,
    required this.onCue,
    required this.onSync,
    required this.onHotCue,
    required this.onPitchChanged,
    required this.onSeek,
    this.accentColor = AppColors.ledCyan,
  });

  @override
  Widget build(BuildContext context) {
    final waveformPoints = AudioMath.generateSimulatedWaveform(
      deck.loadedTrack?.id ?? deck.deckName,
      points: 64,
    );

    return SkeuoPanel(
      showCornerScrews: true,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Deck Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.panelSunken,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accentColor.withValues(alpha: 0.5), width: 1.2),
                      boxShadow: SkeuoTokens.sunkenWell,
                    ),
                    child: Text(
                      deck.deckName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        letterSpacing: 1.0,
                        shadows: [
                          Shadow(color: accentColor.withValues(alpha: 0.6), blurRadius: 6),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (deck.loadedTrack != null)
                    Text(
                      AudioMath.formatCamelotKey(deck.loadedTrack!.musicalKey),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.kappogyYellow,
                      ),
                    ),
                ],
              ),
              SkeuoButton(
                size: 34,
                isCircular: false,
                icon: Icons.folder_open_rounded,
                tooltip: 'Load Track to ${deck.deckName}',
                onPressed: onSelectTrack,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Track Title & Artist Readout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.panelWell,
              borderRadius: BorderRadius.circular(8),
              boxShadow: SkeuoTokens.sunkenWell,
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deck.loadedTrack?.title ?? 'EMPTY DECK — TAP FOLDER TO LOAD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: deck.loadedTrack != null ? AppColors.textPrimary : AppColors.textMuted,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (deck.loadedTrack != null)
                  Text(
                    deck.loadedTrack!.artist,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Interactive Scratchable Waveform Display
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              if (deck.duration.inMilliseconds > 0) {
                final deltaRatio = details.primaryDelta! / 300.0;
                final newPosMs = deck.position.inMilliseconds + (deltaRatio * deck.duration.inMilliseconds).toInt();
                onSeek(Duration(milliseconds: newPosMs.clamp(0, deck.duration.inMilliseconds)));
              }
            },
            child: Container(
              height: 52,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.panelWell,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                boxShadow: SkeuoTokens.sunkenWell,
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Simulated Waveform Bars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(waveformPoints.length, (idx) {
                      final point = waveformPoints[idx];
                      final isPassed = (idx / waveformPoints.length) <= deck.progress;
                      return Container(
                        width: 2.5,
                        height: 44 * point,
                        decoration: BoxDecoration(
                          color: isPassed ? accentColor : AppColors.textMuted.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(1.0),
                          boxShadow: isPassed
                              ? [BoxShadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 3)]
                              : null,
                        ),
                      );
                    }),
                  ),

                  // Center Playhead Needle
                  Positioned(
                    left: (deck.progress * 260).clamp(0.0, 260.0),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 2.0,
                      decoration: BoxDecoration(
                        color: AppColors.kappogyRed,
                        boxShadow: SkeuoTokens.ledGlow(AppColors.kappogyRed),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // BPM Readout & Pitch Slider Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // BPM LCD Counter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.panelSunken,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: SkeuoTokens.sunkenWell,
                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      deck.bpm.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: accentColor,
                        fontFamily: 'monospace',
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'PITCH: ${deck.pitchPercent >= 0 ? "+" : ""}${deck.pitchPercent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Time Elapsed
              Text(
                DurationFormatter.format(deck.position),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  fontFamily: 'monospace',
                ),
              ),

              // Tempo Pitch Fader
              SizedBox(
                height: 70,
                width: 90,
                child: SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: accentColor,
                    inactiveTrackColor: AppColors.panelWell,
                    thumbColor: AppColors.textPrimary,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    value: deck.pitchPercent,
                    min: -8.0,
                    max: 8.0,
                    onChanged: onPitchChanged,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Hot Cue Performance Pads (1, 2, 3, 4)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (idx) {
              final isSet = deck.hotCues[idx] != null;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: SkeuoButton(
                  size: 38,
                  isCircular: false,
                  isActive: isSet,
                  activeColor: AppColors.kappogyYellow,
                  onPressed: () => onHotCue(idx),
                  child: Text(
                    'CUE ${idx + 1}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: isSet ? AppColors.kappogyYellow : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Master Deck Transport (SYNC, CUE, PLAY/PAUSE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // SYNC Button
              SkeuoButton(
                size: 46,
                isCircular: false,
                activeColor: AppColors.ledCyan,
                onPressed: onSync,
                child: const Text(
                  'SYNC',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // CUE Button
              SkeuoButton(
                size: 46,
                isCircular: false,
                activeColor: AppColors.kappogyYellow,
                onPressed: onCue,
                child: const Text(
                  'CUE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              // PLAY/PAUSE Master Button
              SkeuoButton(
                size: 52,
                icon: deck.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                isActive: deck.isPlaying,
                activeColor: AppColors.kappogyGreen,
                onPressed: onTogglePlay,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
