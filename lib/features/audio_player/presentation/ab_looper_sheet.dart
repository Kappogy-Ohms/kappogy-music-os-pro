import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';
import 'audio_providers.dart';

class AbLoopSettings {
  final int? pointAms;
  final int? pointBms;
  final bool isLoopActive;
  final double practiceSpeed;

  const AbLoopSettings({
    this.pointAms,
    this.pointBms,
    this.isLoopActive = false,
    this.practiceSpeed = 1.0,
  });

  AbLoopSettings copyWith({
    int? pointAms,
    int? pointBms,
    bool? isLoopActive,
    double? practiceSpeed,
    bool clearA = false,
    bool clearB = false,
  }) {
    return AbLoopSettings(
      pointAms: clearA ? null : (pointAms ?? this.pointAms),
      pointBms: clearB ? null : (pointBms ?? this.pointBms),
      isLoopActive: isLoopActive ?? this.isLoopActive,
      practiceSpeed: practiceSpeed ?? this.practiceSpeed,
    );
  }
}

class AbLoopNotifier extends StateNotifier<AbLoopSettings> {
  AbLoopNotifier() : super(const AbLoopSettings());

  void setPointA(int posMs) {
    state = state.copyWith(pointAms: posMs, isLoopActive: state.pointBms != null && state.pointBms! > posMs);
  }

  void setPointB(int posMs) {
    if (state.pointAms != null && posMs > state.pointAms!) {
      state = state.copyWith(pointBms: posMs, isLoopActive: true);
    } else {
      state = state.copyWith(pointBms: posMs);
    }
  }

  void nudgePointA(int deltaMs, int maxMs) {
    if (state.pointAms != null) {
      final newPos = (state.pointAms! + deltaMs).clamp(0, maxMs);
      state = state.copyWith(pointAms: newPos);
    }
  }

  void nudgePointB(int deltaMs, int maxMs) {
    if (state.pointBms != null) {
      final newPos = (state.pointBms! + deltaMs).clamp(0, maxMs);
      state = state.copyWith(pointBms: newPos);
    }
  }

  void toggleLoop() => state = state.copyWith(isLoopActive: !state.isLoopActive);

  void setSpeed(double speed) => state = state.copyWith(practiceSpeed: speed);

  void clearLoop() => state = const AbLoopSettings();
}

final abLoopProvider = StateNotifierProvider<AbLoopNotifier, AbLoopSettings>((ref) {
  return AbLoopNotifier();
});

class AbLooperSheet extends ConsumerWidget {
  const AbLooperSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AbLooperSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playbackStateProvider);
    final loop = ref.watch(abLoopProvider);
    final loopNotifier = ref.read(abLoopProvider.notifier);

    final currentPosMs = player.position.inMilliseconds;
    final totalDurationMs = player.duration.inMilliseconds > 0 ? player.duration.inMilliseconds : 180000;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 30, spreadRadius: 5, offset: Offset(0, -10)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.repeat_rounded, color: AppColors.kappogyYellow, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'PRECISION A-B STUDIO LOOPER & PRACTICE DECK',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Clear all A-B loop points',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.kappogyRed,
                  onPressed: loopNotifier.clearLoop,
                  child: const Icon(Icons.delete_sweep_rounded, size: 16, color: AppColors.kappogyRed),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Loop Visual Progress Display
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'POINT A: ${loop.pointAms != null ? DurationFormatter.formatSeconds(loop.pointAms! ~/ 1000) : '--:--'}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: loop.pointAms != null ? AppColors.ledCyan : AppColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: loop.isLoopActive ? AppColors.kappogyGreen.withValues(alpha: 0.2) : AppColors.panelSunken,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: loop.isLoopActive ? AppColors.kappogyGreen : AppColors.borderSubtle,
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        loop.isLoopActive ? 'ACTIVE LOOP CYCLE' : 'STANDBY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: loop.isLoopActive ? AppColors.kappogyGreen : AppColors.textMuted,
                        ),
                      ),
                    ),
                    Text(
                      'POINT B: ${loop.pointBms != null ? DurationFormatter.formatSeconds(loop.pointBms! ~/ 1000) : '--:--'}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: loop.pointBms != null ? AppColors.kappogyRed : AppColors.textMuted,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Timeline bar with Point A and Point B indicators
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final posNorm = (currentPosMs / totalDurationMs).clamp(0.0, 1.0);
                    final aNorm = loop.pointAms != null ? (loop.pointAms! / totalDurationMs).clamp(0.0, 1.0) : null;
                    final bNorm = loop.pointBms != null ? (loop.pointBms! / totalDurationMs).clamp(0.0, 1.0) : null;

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Track Background
                        Container(
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.panelSunken,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: SkeuoTokens.sunkenWell,
                          ),
                        ),
                        // Loop highlight area
                        if (aNorm != null && bNorm != null && bNorm > aNorm)
                          Positioned(
                            left: aNorm * width,
                            width: (bNorm - aNorm) * width,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.kappogyYellow.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        // Current position marker
                        Positioned(
                          left: (posNorm * width) - 2,
                          top: -2,
                          bottom: -2,
                          child: Container(
                            width: 4,
                            decoration: BoxDecoration(
                              color: AppColors.textPrimary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // A Marker
                        if (aNorm != null)
                          Positioned(
                            left: (aNorm * width) - 5,
                            top: -4,
                            child: const Icon(Icons.arrow_drop_down, color: AppColors.ledCyan, size: 14),
                          ),
                        // B Marker
                        if (bNorm != null)
                          Positioned(
                            left: (bNorm * width) - 5,
                            top: -4,
                            child: const Icon(Icons.arrow_drop_down, color: AppColors.kappogyRed, size: 14),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Primary A-B Action Buttons
          Row(
            children: [
              Expanded(
                child: Tooltip(
                  message: 'Set Point A at current playback position',
                  child: SkeuoButton(
                    size: 42,
                    isCircular: false,
                    activeColor: AppColors.ledCyan,
                    isActive: loop.pointAms != null,
                    onPressed: () => loopNotifier.setPointA(currentPosMs),
                    child: const Center(
                      child: Text('SET POINT A [IN]', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.ledCyan)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Tooltip(
                  message: 'Set Point B at current playback position',
                  child: SkeuoButton(
                    size: 42,
                    isCircular: false,
                    activeColor: AppColors.kappogyRed,
                    isActive: loop.pointBms != null,
                    onPressed: () => loopNotifier.setPointB(currentPosMs),
                    child: const Center(
                      child: Text('SET POINT B [OUT]', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.kappogyRed)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Tooltip(
                message: 'Toggle A-B loop cycle engagement',
                child: SkeuoButton(
                  size: 42,
                  isCircular: false,
                  activeColor: AppColors.kappogyGreen,
                  isActive: loop.isLoopActive,
                  onPressed: (loop.pointAms != null && loop.pointBms != null) ? loopNotifier.toggleLoop : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      child: Text('LOOP ON', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.kappogyGreen)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Micro-Nudge Adjusters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('NUDGE A: ', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                  _nudgeBtn('-50ms', () => loopNotifier.nudgePointA(-50, totalDurationMs)),
                  const SizedBox(width: 4),
                  _nudgeBtn('+50ms', () => loopNotifier.nudgePointA(50, totalDurationMs)),
                ],
              ),
              Row(
                children: [
                  const Text('NUDGE B: ', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                  _nudgeBtn('-50ms', () => loopNotifier.nudgePointB(-50, totalDurationMs)),
                  const SizedBox(width: 4),
                  _nudgeBtn('+50ms', () => loopNotifier.nudgePointB(50, totalDurationMs)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Practice Slow-Motion Speed Selector
          const Text('PRACTICE TEMPO (PITCH-PRESERVED)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<double>(
              options: const [
                RockerOption(value: 0.5, label: '0.5x Slow'),
                RockerOption(value: 0.75, label: '0.75x Practice'),
                RockerOption(value: 1.0, label: '1.0x Normal'),
                RockerOption(value: 1.25, label: '1.25x Fast'),
                RockerOption(value: 1.5, label: '1.5x Up-Tempo'),
              ],
              selectedValue: loop.practiceSpeed,
              activeColor: AppColors.kappogyYellow,
              onSelected: (spd) {
                loopNotifier.setSpeed(spd);
                ref.read(playbackStateProvider.notifier).setSpeed(spd);
              },
            ),
          ),

          const SizedBox(height: 14),

          // Quick Export Sample / Assign Action
          SizedBox(
            width: double.infinity,
            height: 42,
            child: Tooltip(
              message: 'Save this loop clip and assign to DJ Pro Sampler Pad',
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.panelRaised,
                  side: const BorderSide(color: AppColors.ledPurple, width: 1.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.music_note_rounded, color: AppColors.ledPurple, size: 18),
                label: const Text(
                  'ASSIGN LOOP CLIP TO DJ SAMPLER PAD',
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                ),
                onPressed: (loop.pointAms != null && loop.pointBms != null)
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('A-B Loop assigned to DJ Pro Sampler Slot #1!'),
                            backgroundColor: AppColors.ledPurple,
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nudgeBtn(String label, VoidCallback onPressed) {
    return SizedBox(
      height: 26,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.panelSunken,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 9, color: AppColors.textSecondary, fontWeight: FontWeight.w800)),
      ),
    );
  }
}
