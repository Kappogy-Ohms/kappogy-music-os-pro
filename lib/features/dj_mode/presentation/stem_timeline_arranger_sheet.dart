import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';
import '../../audio_player/presentation/audio_providers.dart';
import 'stem_mixer_sheet.dart';

enum LoopQuantizeBar {
  oneBar('1 BAR (4 Beats)', 4),
  twoBars('2 BARS (8 Beats)', 8),
  fourBars('4 BARS (16 Beats)', 16),
  eightBars('8 BARS (32 Beats)', 32),
  fullTrack('FULL TRACK', 0);

  final String label;
  final int beats;
  const LoopQuantizeBar(this.label, this.beats);
}

class StemTimelineArrangerSheet extends ConsumerStatefulWidget {
  const StemTimelineArrangerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StemTimelineArrangerSheet(),
    );
  }

  @override
  ConsumerState<StemTimelineArrangerSheet> createState() => _StemTimelineArrangerSheetState();
}

class _StemTimelineArrangerSheetState extends ConsumerState<StemTimelineArrangerSheet> {
  LoopQuantizeBar _loopBars = LoopQuantizeBar.fourBars;
  double _playheadRatio = 0.25; // 0.0 to 1.0 position in timeline
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    final stemState = ref.watch(stemMixerProvider);
    final stemNotifier = ref.read(stemMixerProvider.notifier);
    final playbackState = ref.watch(playbackStateProvider);
    final currentTrack = playbackState.currentTrack;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: SkeuoTokens.raisedLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.view_timeline_rounded, color: AppColors.kappogyYellow, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'MULTI-STEM TIMELINE & SLICE ARRANGER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SkeuoButton(
                  size: 32,
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Arrangement Control Bar
                  SkeuoPanel(
                    padding: const EdgeInsets.all(12),
                    showCornerScrews: true,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('ARRANGEMENT TRACK:', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              currentTrack?.title ?? 'Studio Master Stems',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        // Loop Bar Selector
                        Row(
                          children: [
                            const Text('LOOP: ', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
                            SkeuoRockerSwitch<LoopQuantizeBar>(
                              options: const [
                                RockerOption(label: '1 BAR', value: LoopQuantizeBar.oneBar),
                                RockerOption(label: '2 BARS', value: LoopQuantizeBar.twoBars),
                                RockerOption(label: '4 BARS', value: LoopQuantizeBar.fourBars),
                                RockerOption(label: '8 BARS', value: LoopQuantizeBar.eightBars),
                              ],
                              selectedValue: _loopBars,
                              onSelected: (v) => setState(() => _loopBars = v),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // DAW Multi-Track Timeline View
                  SkeuoPanel(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        // Time ruler header
                        Container(
                          height: 22,
                          padding: const EdgeInsets.only(left: 70, right: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('0:00', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                              Text('BAR 4', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                              Text('BAR 8', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                              Text('BAR 16', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                              Text('BAR 32', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                              Text('END', style: TextStyle(fontSize: 8, color: AppColors.textMuted)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Draggable Timeline Stack with 4 Stem Lanes
                        GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            final box = context.findRenderObject() as RenderBox?;
                            if (box != null) {
                              final localX = details.localPosition.dx - 80;
                              final availableWidth = box.size.width - 120;
                              if (availableWidth > 0) {
                                setState(() {
                                  _playheadRatio = (localX / availableWidth).clamp(0.0, 1.0);
                                });
                              }
                            }
                          },
                          child: Stack(
                            children: [
                              Column(
                                children: [
                                  _buildStemLane(
                                    name: 'VOCALS',
                                    accent: const Color(0xFF00E5FF),
                                    isMuted: stemState.vocals.isMuted,
                                    isSolo: stemState.vocals.isSolo,
                                    volume: stemState.vocals.volume,
                                    onMuteToggle: () => stemNotifier.toggleMute('VOCALS'),
                                    onSoloToggle: () => stemNotifier.toggleSolo('VOCALS'),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildStemLane(
                                    name: 'DRUMS',
                                    accent: const Color(0xFFFF5252),
                                    isMuted: stemState.drums.isMuted,
                                    isSolo: stemState.drums.isSolo,
                                    volume: stemState.drums.volume,
                                    onMuteToggle: () => stemNotifier.toggleMute('DRUMS'),
                                    onSoloToggle: () => stemNotifier.toggleSolo('DRUMS'),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildStemLane(
                                    name: 'BASS',
                                    accent: const Color(0xFFFFD700),
                                    isMuted: stemState.bass.isMuted,
                                    isSolo: stemState.bass.isSolo,
                                    volume: stemState.bass.volume,
                                    onMuteToggle: () => stemNotifier.toggleMute('BASS'),
                                    onSoloToggle: () => stemNotifier.toggleSolo('BASS'),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildStemLane(
                                    name: 'MELODY',
                                    accent: const Color(0xFFD500F9),
                                    isMuted: stemState.melody.isMuted,
                                    isSolo: stemState.melody.isSolo,
                                    volume: stemState.melody.volume,
                                    onMuteToggle: () => stemNotifier.toggleMute('MELODY'),
                                    onSoloToggle: () => stemNotifier.toggleSolo('MELODY'),
                                  ),
                                ],
                              ),

                              // Playhead Vertical Needle Line
                              Positioned(
                                top: 0,
                                bottom: 0,
                                left: 80 + (_playheadRatio * (MediaQuery.of(context).size.width - 140)),
                                child: Container(
                                  width: 2.5,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF1744),
                                    boxShadow: [
                                      BoxShadow(color: const Color(0xFFFF1744).withValues(alpha: 0.8), blurRadius: 4),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Transport & Export Row
                  Row(
                    children: [
                      // Play / Loop Slice button
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isPlaying ? AppColors.kappogyGreen : AppColors.panelRaised,
                              side: BorderSide(
                                color: _isPlaying ? AppColors.kappogyGreen : AppColors.borderSubtle,
                                width: 1.0,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: Icon(
                              _isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                              color: _isPlaying ? Colors.black : AppColors.kappogyGreen,
                              size: 20,
                            ),
                            label: Text(
                              _isPlaying ? 'STOP LOOP' : 'PLAY ${_loopBars.label}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: _isPlaying ? Colors.black : AppColors.textPrimary,
                              ),
                            ),
                            onPressed: () => setState(() => _isPlaying = !_isPlaying),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bounce & Export Stems Mixdown
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.panelRaised,
                              side: const BorderSide(color: AppColors.ledCyan, width: 1.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.album_rounded, color: AppColors.ledCyan, size: 18),
                            label: const Text(
                              'BOUNCE & SAVE MIX',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bounced 4-Track Stem Mixdown to local music library!'),
                                  backgroundColor: AppColors.ledCyan,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStemLane({
    required String name,
    required Color accent,
    required bool isMuted,
    required bool isSolo,
    required double volume,
    required VoidCallback onMuteToggle,
    required VoidCallback onSoloToggle,
  }) {
    return Row(
      children: [
        // Left Channel Controls Strip
        Container(
          width: 92,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.panelRaised,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: accent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mute
                  GestureDetector(
                    onTap: onMuteToggle,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isMuted ? AppColors.kappogyRed : AppColors.panelWell,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Text(
                          'M',
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: isMuted ? Colors.white : AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 3),
                  // Solo
                  GestureDetector(
                    onTap: onSoloToggle,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isSolo ? AppColors.kappogyYellow : AppColors.panelWell,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Text(
                          'S',
                          style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: isSolo ? Colors.black : AppColors.textMuted),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        // Waveform Strip Container
        Expanded(
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.panelWell,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSolo ? AppColors.kappogyYellow : (isMuted ? Colors.white10 : accent.withValues(alpha: 0.3)),
                width: 0.8,
              ),
            ),
            child: Opacity(
              opacity: isMuted ? 0.25 : (volume <= 0.0 ? 0.2 : 1.0),
              child: CustomPaint(
                painter: _StemWaveformStripPainter(color: accent, seed: name.hashCode),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StemWaveformStripPainter extends CustomPainter {
  final Color color;
  final int seed;
  _StemWaveformStripPainter({required this.color, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(seed);
    final midY = size.height / 2;
    final paint = Paint()
      ..color = color.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    const int bars = 48;
    final step = size.width / bars;

    for (int i = 0; i < bars; i++) {
      final amp = (0.2 + (rand.nextDouble() * 0.8)) * (size.height * 0.42);
      final x = (i * step) + 2;
      canvas.drawLine(Offset(x, midY - amp), Offset(x, midY + amp), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StemWaveformStripPainter oldDelegate) => false;
}
