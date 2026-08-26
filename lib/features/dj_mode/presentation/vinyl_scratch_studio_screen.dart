import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../domain/dj_deck_model.dart';
import 'dj_providers.dart';

class VinylScratchStudioScreen extends ConsumerStatefulWidget {
  const VinylScratchStudioScreen({super.key});

  @override
  ConsumerState<VinylScratchStudioScreen> createState() => _VinylScratchStudioScreenState();
}

class _VinylScratchStudioScreenState extends ConsumerState<VinylScratchStudioScreen> with SingleTickerProviderStateMixin {
  bool _motorPowerDeckA = true;
  bool _motorPowerDeckB = true;
  double _vinylBrakeSpeed = 0.5; // seconds
  double _scratchAngleA = 0.0;
  double _scratchAngleB = 0.0;
  double _lastTouchAngleA = 0.0;
  double _lastTouchAngleB = 0.0;
  bool _isDeckAMuted = false;
  bool _isDeckBMuted = false;

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800), // 33.33 RPM
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final djState = ref.watch(djConsoleNotifierProvider);
    final djNotifier = ref.read(djConsoleNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkeuoButton(
          size: 40,
          isCircular: false,
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'LIVE VINYL SCRATCH & JUGGLING STUDIO',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            shadows: SkeuoTokens.debossedText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Master Turntable Battle Console
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildDeckPanel(isDeckA: true, deck: djState.deckA, notifier: djNotifier)),
                        const SizedBox(width: 14),
                        Expanded(child: _buildDeckPanel(isDeckA: false, deck: djState.deckB, notifier: djNotifier)),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildDeckPanel(isDeckA: true, deck: djState.deckA, notifier: djNotifier),
                        const SizedBox(height: 14),
                        _buildDeckPanel(isDeckA: false, deck: djState.deckB, notifier: djNotifier),
                      ],
                    ),

                  const SizedBox(height: 14),

                  // Center Battle Crossfader & Transform Scratch Rack
                  SkeuoPanel(
                    padding: const EdgeInsets.all(14),
                    showCornerScrews: true,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Transform Mute Deck A
                            GestureDetector(
                              onTapDown: (_) => setState(() => _isDeckAMuted = true),
                              onTapUp: (_) => setState(() => _isDeckAMuted = false),
                              onTapCancel: () => setState(() => _isDeckAMuted = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isDeckAMuted ? AppColors.kappogyRed : AppColors.panelRaised,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.kappogyRed, width: 1.2),
                                  boxShadow: _isDeckAMuted ? SkeuoTokens.sunkenWell : SkeuoTokens.raisedSm,
                                ),
                                child: Text(
                                  'CUT A (TRANSFORM)',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: _isDeckAMuted ? Colors.white : AppColors.kappogyRed,
                                  ),
                                ),
                              ),
                            ),

                            // Vinyl Brake Dial
                            SkeuoKnob(
                              label: 'VINYL BRAKE',
                              value: _vinylBrakeSpeed,
                              min: 0.1,
                              max: 5.0,
                              size: 56,
                              ledColor: AppColors.kappogyYellow,
                              onChanged: (v) => setState(() => _vinylBrakeSpeed = v),
                              displayValue: '${_vinylBrakeSpeed.toStringAsFixed(1)}s',
                            ),

                            // Transform Mute Deck B
                            GestureDetector(
                              onTapDown: (_) => setState(() => _isDeckBMuted = true),
                              onTapUp: (_) => setState(() => _isDeckBMuted = false),
                              onTapCancel: () => setState(() => _isDeckBMuted = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _isDeckBMuted ? AppColors.ledCyan : AppColors.panelRaised,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.ledCyan, width: 1.2),
                                  boxShadow: _isDeckBMuted ? SkeuoTokens.sunkenWell : SkeuoTokens.raisedSm,
                                ),
                                child: Text(
                                  'CUT B (TRANSFORM)',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: _isDeckBMuted ? Colors.white : AppColors.ledCyan,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Scratch Crossfader Slider
                        Row(
                          children: [
                            const Text('DECK A', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.kappogyRed)),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.kappogyGreen,
                                  inactiveTrackColor: AppColors.panelWell,
                                  thumbColor: Colors.white,
                                  trackHeight: 6,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                                ),
                                child: Slider(
                                  value: djState.crossfaderPosition,
                                  min: -1.0,
                                  max: 1.0,
                                  onChanged: djNotifier.setCrossfader,
                                ),
                              ),
                            ),
                            const Text('DECK B', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.ledCyan)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Scratch Patterns Guide
                  SkeuoPanel(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.sports_esports_rounded, color: AppColors.kappogyYellow, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'TURNTABLIST SCRATCH RHYTHMS',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow, letterSpacing: 0.8),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          '• Baby Scratch: Forward-backward continuous drag across cue marker without crossfader.\n• Chirp: Push forward, cut crossfader at peak, drag backward, open crossfader.\n• Transformer: Move vinyl smoothly while rapidly clicking Transform Cut button.',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.4),
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

  Widget _buildDeckPanel({required bool isDeckA, required DjDeckState deck, required DjConsoleNotifier notifier}) {
    final isMotorOn = isDeckA ? _motorPowerDeckA : _motorPowerDeckB;
    final accent = isDeckA ? AppColors.kappogyRed : AppColors.ledCyan;

    return SkeuoPanel(
      padding: const EdgeInsets.all(12),
      showCornerScrews: true,
      child: Column(
        children: [
          // Deck Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isDeckA ? 'DECK A (MASTER)' : 'DECK B (SLAVE)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accent),
              ),
              // Motor Power Switch
              Row(
                children: [
                  const Text('MOTOR: ', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isDeckA) {
                          _motorPowerDeckA = !_motorPowerDeckA;
                        } else {
                          _motorPowerDeckB = !_motorPowerDeckB;
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isMotorOn ? AppColors.kappogyGreen : AppColors.panelWell,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isMotorOn ? 'POWER ON' : 'MOTOR OFF',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: isMotorOn ? Colors.black : AppColors.kappogyRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Direct Drive Scratch Platter
          GestureDetector(
            onPanStart: (details) {
              final center = const Offset(85, 85);
              final touchOffset = details.localPosition - center;
              if (isDeckA) {
                _lastTouchAngleA = atan2(touchOffset.dy, touchOffset.dx);
              } else {
                _lastTouchAngleB = atan2(touchOffset.dy, touchOffset.dx);
              }
            },
            onPanUpdate: (details) {
              final center = const Offset(85, 85);
              final touchOffset = details.localPosition - center;
              final currentAngle = atan2(touchOffset.dy, touchOffset.dx);

              setState(() {
                if (isDeckA) {
                  final delta = currentAngle - _lastTouchAngleA;
                  _scratchAngleA += delta;
                  _lastTouchAngleA = currentAngle;
                } else {
                  final delta = currentAngle - _lastTouchAngleB;
                  _scratchAngleB += delta;
                  _lastTouchAngleB = currentAngle;
                }
              });
            },
            child: AnimatedBuilder(
              animation: _rotationController,
              builder: (context, _) {
                final angle = (isMotorOn && deck.isPlaying ? _rotationController.value * 2 * pi : 0.0) +
                    (isDeckA ? _scratchAngleA : _scratchAngleB);

                return Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF101216),
                    boxShadow: SkeuoTokens.sunkenWell,
                    border: Border.all(color: accent.withValues(alpha: 0.6), width: 2.0),
                  ),
                  child: Center(
                    child: Transform.rotate(
                      angle: angle,
                      child: Container(
                        width: 155,
                        height: 155,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF181A1F),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Vinyl Grooves
                            Container(
                              width: 130,
                              height: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white10, width: 1.0),
                              ),
                            ),
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white12, width: 1.0),
                              ),
                            ),
                            // Center Scratch Marker / Label
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accent,
                              ),
                              child: const Center(
                                child: Icon(Icons.album_rounded, size: 24, color: Colors.black87),
                              ),
                            ),
                            // Cue Position Scratch Tape Indicator
                            Positioned(
                              top: 6,
                              child: Container(
                                width: 5,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: [
                                    BoxShadow(color: Colors.white.withValues(alpha: 0.8), blurRadius: 4),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Mini VU Meter & Transport Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SkeuoButton(
                size: 34,
                isCircular: true,
                icon: deck.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                isActive: deck.isPlaying,
                activeColor: accent,
                onPressed: () => notifier.togglePlay(isDeckA ? 'DECK A' : 'DECK B'),
              ),
              SkeuoButton(
                size: 34,
                isCircular: false,
                icon: Icons.flag_rounded,
                tooltip: 'CUE Point',
                onPressed: () => notifier.cue(isDeckA ? 'DECK A' : 'DECK B'),
              ),
              SkeuoButton(
                size: 34,
                isCircular: false,
                icon: Icons.sync_rounded,
                tooltip: 'BPM Sync',
                onPressed: () => notifier.syncBpm(isDeckA ? 'DECK A' : 'DECK B'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
