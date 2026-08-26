import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../audio_player/presentation/audio_providers.dart';
import '../data/lrc_parser.dart';
import 'vocal_remover_sheet.dart';

class KaraokeHudScreen extends ConsumerStatefulWidget {
  const KaraokeHudScreen({super.key});

  @override
  ConsumerState<KaraokeHudScreen> createState() => _KaraokeHudScreenState();
}

class _KaraokeHudScreenState extends ConsumerState<KaraokeHudScreen> {
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 24.0;
  bool _glowEffect = true;

  @override
  Widget build(BuildContext context) {
    final playbackState = ref.watch(playbackStateProvider);
    final notifier = ref.read(playbackStateProvider.notifier);
    final currentTrack = playbackState.currentTrack;

    final lyrics = LrcParser.generateSampleLyrics(
      currentTrack?.title ?? 'Studio Master',
      currentTrack?.artist ?? 'Kappogy',
    );

    final activeIndex = lyrics.getActiveLineIndex(playbackState.position);

    // Auto-scroll to active line
    if (_scrollController.hasClients && activeIndex >= 0) {
      _scrollController.animateTo(
        (activeIndex * 80.0).clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07080A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background Visualizer Glow
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.kappogyRed.withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(color: AppColors.kappogyRed.withValues(alpha: 0.2), blurRadius: 100),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.ledCyan.withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(color: AppColors.ledCyan.withValues(alpha: 0.2), blurRadius: 100),
                  ],
                ),
              ),
            ),

            // Main Lyrics HUD Content
            Column(
              children: [
                // Top HUD Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.fullscreen_exit_rounded, color: AppColors.textPrimary, size: 28),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTrack?.title ?? 'Kappogy Studio',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                '${currentTrack?.artist ?? "Artist"} • KARAOKE HUD',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.kappogyYellow,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Vocal Remover & Stem Extractor
                          IconButton(
                            icon: const Icon(Icons.mic_off_rounded, color: AppColors.ledPurple, size: 22),
                            tooltip: 'Vocal Remover & Stem Extractor',
                            onPressed: () => VocalRemoverSheet.show(context),
                          ),
                          // Font Size Switcher
                          IconButton(
                            icon: const Icon(Icons.text_fields_rounded, color: AppColors.ledCyan, size: 22),
                            tooltip: 'Adjust Font Size',
                            onPressed: () {
                              setState(() {
                                if (_fontSize == 20.0) {
                                  _fontSize = 26.0;
                                } else if (_fontSize == 26.0) {
                                  _fontSize = 32.0;
                                } else {
                                  _fontSize = 20.0;
                                }
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              _glowEffect ? Icons.lightbulb_rounded : Icons.lightbulb_outline_rounded,
                              color: _glowEffect ? AppColors.kappogyYellow : AppColors.textMuted,
                              size: 22,
                            ),
                            tooltip: 'Toggle Neon Glow',
                            onPressed: () => setState(() => _glowEffect = !_glowEffect),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Center Lyrics Scrolling Stream
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 120),
                    itemCount: lyrics.lines.length,
                    itemBuilder: (context, idx) {
                      final line = lyrics.lines[idx];
                      final isActive = idx == activeIndex;

                      return GestureDetector(
                        onTap: () => notifier.seek(line.timestamp),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          alignment: Alignment.center,
                          child: Text(
                            line.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: isActive ? _fontSize : _fontSize * 0.75,
                              fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                              color: isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary.withValues(alpha: 0.4),
                              shadows: isActive && _glowEffect
                                  ? [
                                      const Shadow(color: AppColors.kappogyYellow, blurRadius: 16),
                                      const Shadow(color: AppColors.kappogyRed, blurRadius: 28),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Bottom HUD Player Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.panelRaised.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                    boxShadow: SkeuoTokens.raisedMd,
                  ),
                  child: Column(
                    children: [
                      // Scrubber Progress Bar
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          activeTrackColor: AppColors.kappogyYellow,
                          inactiveTrackColor: AppColors.panelSunken,
                          thumbColor: AppColors.kappogyYellow,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: playbackState.progress,
                          onChanged: (val) {
                            final seekMs = (val * playbackState.duration.inMilliseconds).toInt();
                            notifier.seek(Duration(milliseconds: seekMs));
                          },
                        ),
                      ),

                      // Time Display & Transport Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DurationFormatter.format(playbackState.position),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontFamily: 'monospace'),
                          ),
                          Row(
                            children: [
                              SkeuoButton(
                                size: 40,
                                icon: Icons.skip_previous_rounded,
                                onPressed: () => notifier.previous(),
                              ),
                              const SizedBox(width: 10),
                              SkeuoButton(
                                size: 48,
                                icon: playbackState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                isActive: playbackState.isPlaying,
                                activeColor: AppColors.kappogyGreen,
                                onPressed: () => notifier.togglePlayPause(),
                              ),
                              const SizedBox(width: 10),
                              SkeuoButton(
                                size: 40,
                                icon: Icons.skip_next_rounded,
                                onPressed: () => notifier.next(),
                              ),
                            ],
                          ),
                          Text(
                            DurationFormatter.format(playbackState.duration),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textSecondary, fontFamily: 'monospace'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
