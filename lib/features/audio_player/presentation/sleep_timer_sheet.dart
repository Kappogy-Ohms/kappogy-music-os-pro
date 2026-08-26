import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import 'audio_providers.dart';

class SleepTimerState {
  final bool isActive;
  final int remainingSeconds;
  final bool endOfTrack;
  final bool fadeOut;

  const SleepTimerState({
    this.isActive = false,
    this.remainingSeconds = 0,
    this.endOfTrack = false,
    this.fadeOut = true,
  });
}

class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  Timer? _timer;
  final PlaybackNotifier _playbackNotifier;

  SleepTimerNotifier(this._playbackNotifier) : super(const SleepTimerState());

  void startTimer(int minutes, {bool fadeOut = true}) {
    _timer?.cancel();
    final totalSec = minutes * 60;
    state = SleepTimerState(
      isActive: true,
      remainingSeconds: totalSec,
      fadeOut: fadeOut,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.remainingSeconds <= 1) {
        cancelTimer();
        _playbackNotifier.togglePlayPause();
      } else {
        state = SleepTimerState(
          isActive: true,
          remainingSeconds: state.remainingSeconds - 1,
          fadeOut: state.fadeOut,
        );
      }
    });
  }

  void setEndOfTrack({bool fadeOut = true}) {
    _timer?.cancel();
    state = SleepTimerState(
      isActive: true,
      endOfTrack: true,
      fadeOut: fadeOut,
    );
  }

  void cancelTimer() {
    _timer?.cancel();
    state = const SleepTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider = StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  final playback = ref.watch(playbackStateProvider.notifier);
  return SleepTimerNotifier(playback);
});

class SleepTimerSheet extends ConsumerStatefulWidget {
  const SleepTimerSheet({super.key});

  @override
  ConsumerState<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends ConsumerState<SleepTimerSheet> {
  double _customMinutes = 30.0;
  bool _fadeOut = true;

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(sleepTimerProvider);
    final notifier = ref.read(sleepTimerProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: SkeuoTokens.raisedLg,
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Bar
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
                      child: const Icon(Icons.bedtime_rounded, color: AppColors.ledCyan, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'STUDIO HARDWARE SLEEP TIMER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Active Countdown Display (if running)
            if (timerState.isActive) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.panelWell,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.ledCyan.withValues(alpha: 0.5), width: 1.2),
                  boxShadow: SkeuoTokens.sunkenWell,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SLEEP TIMER ACTIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.ledCyan)),
                        const SizedBox(height: 4),
                        Text(
                          timerState.endOfTrack
                              ? 'Stops at end of track'
                              : '${(timerState.remainingSeconds ~/ 60).toString().padLeft(2, "0")}:${(timerState.remainingSeconds % 60).toString().padLeft(2, "0")}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                    SkeuoButton(
                      size: 36,
                      isCircular: false,
                      activeColor: AppColors.kappogyRed,
                      onPressed: () => notifier.cancelTimer(),
                      child: const Text('CANCEL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.kappogyRed)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Preset Buttons Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _presetButton('15 MIN', 15),
                _presetButton('30 MIN', 30),
                _presetButton('45 MIN', 45),
                _presetButton('60 MIN', 60),
              ],
            ),

            const SizedBox(height: 16),

            // Custom Rotary Knob & Fade Out Switch Row
            SkeuoPanel(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  SkeuoKnob(
                    value: _customMinutes,
                    min: 5,
                    max: 120,
                    size: 76,
                    label: 'Custom Timer',
                    displayValue: '${_customMinutes.round()}m',
                    ledColor: AppColors.kappogyYellow,
                    onChanged: (val) => setState(() => _customMinutes = val),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('VOLUME FADE-OUT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          subtitle: const Text('30-second smooth logarithmic volume ramp-down', style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
                          value: _fadeOut,
                          activeThumbColor: AppColors.kappogyGreen,
                          onChanged: (v) => setState(() => _fadeOut = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Start Actions Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.panelRaised,
                        side: const BorderSide(color: AppColors.borderProminent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        notifier.setEndOfTrack(fadeOut: _fadeOut);
                        Navigator.of(context).pop();
                      },
                      child: const Text('STOP AT TRACK END', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kappogyGreen,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        notifier.startTimer(_customMinutes.round(), fadeOut: _fadeOut);
                        Navigator.of(context).pop();
                      },
                      child: const Text('START TIMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.black)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetButton(String label, int minutes) {
    return SkeuoButton(
      size: 40,
      isCircular: false,
      onPressed: () {
        ref.read(sleepTimerProvider.notifier).startTimer(minutes, fadeOut: _fadeOut);
        Navigator.of(context).pop();
      },
      child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }
}
