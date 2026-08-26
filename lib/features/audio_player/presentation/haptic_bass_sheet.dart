import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum HapticBeatPattern {
  quarterBeat('4/4 Straight Kick', 1),
  eighthShuffle('8th Note Groove', 2),
  tripletTrap('Triplet Roll', 3),
  transientDynamic('Sub-Bass Transients', 0);

  final String label;
  final int multiplier;
  const HapticBeatPattern(this.label, this.multiplier);
}

class HapticBassSettings {
  final bool isEnabled;
  final HapticBeatPattern pattern;
  final double intensityPercent; // 0.0 to 100.0%
  final double cutoffFrequencyHz; // 40.0 to 120.0 Hz
  final bool isMetronomeAudible;

  const HapticBassSettings({
    this.isEnabled = true,
    this.pattern = HapticBeatPattern.transientDynamic,
    this.intensityPercent = 80.0,
    this.cutoffFrequencyHz = 80.0,
    this.isMetronomeAudible = false,
  });

  HapticBassSettings copyWith({
    bool? isEnabled,
    HapticBeatPattern? pattern,
    double? intensityPercent,
    double? cutoffFrequencyHz,
    bool? isMetronomeAudible,
  }) {
    return HapticBassSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      pattern: pattern ?? this.pattern,
      intensityPercent: intensityPercent ?? this.intensityPercent,
      cutoffFrequencyHz: cutoffFrequencyHz ?? this.cutoffFrequencyHz,
      isMetronomeAudible: isMetronomeAudible ?? this.isMetronomeAudible,
    );
  }
}

class HapticBassNotifier extends StateNotifier<HapticBassSettings> {
  HapticBassNotifier() : super(const HapticBassSettings());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  void setPattern(HapticBeatPattern p) => state = state.copyWith(pattern: p);
  void setIntensity(double val) => state = state.copyWith(intensityPercent: val.clamp(0.0, 100.0));
  void setCutoff(double hz) => state = state.copyWith(cutoffFrequencyHz: hz.clamp(40.0, 120.0));
  void toggleAudible() => state = state.copyWith(isMetronomeAudible: !state.isMetronomeAudible);

  void triggerHapticPulse() {
    if (!state.isEnabled) return;
    if (state.intensityPercent > 66) {
      HapticFeedback.heavyImpact();
    } else if (state.intensityPercent > 33) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }
}

final hapticBassProvider = StateNotifierProvider<HapticBassNotifier, HapticBassSettings>((ref) {
  return HapticBassNotifier();
});

class HapticBassSheet extends ConsumerWidget {
  const HapticBassSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const HapticBassSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(hapticBassProvider);
    final notifier = ref.read(hapticBassProvider.notifier);

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
                  Icon(Icons.vibration_rounded, color: AppColors.kappogyRed, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'TACTILE HAPTIC SUB-BASS & BEAT SHAKER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle Haptic Subwoofer Engine',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.kappogyRed,
                  isActive: settings.isEnabled,
                  onPressed: notifier.toggleEnabled,
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 16,
                    color: settings.isEnabled ? AppColors.kappogyRed : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Haptic Feedback Status & Test Trigger
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.panelSunken,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: settings.isEnabled
                        ? [
                            BoxShadow(
                              color: AppColors.kappogyRed.withValues(alpha: 0.35),
                              blurRadius: 14,
                            ),
                          ]
                        : SkeuoTokens.sunkenWell,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.surround_sound_rounded,
                      color: settings.isEnabled ? AppColors.kappogyRed : AppColors.textMuted,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.isEnabled ? 'SUBWOOFER HAPTIC VIBRATION ACTIVE' : 'HAPTIC ENGINE STANDBY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: settings.isEnabled ? AppColors.kappogyRed : AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Translates low-end bass kicks (< 80Hz) into physical device vibrations',
                        style: TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Tooltip(
                  message: 'Test pulse vibration motor',
                  child: SkeuoButton(
                    size: 36,
                    activeColor: AppColors.kappogyRed,
                    onPressed: notifier.triggerHapticPulse,
                    child: const Icon(Icons.touch_app_rounded, size: 16, color: AppColors.kappogyRed),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Rhythm & Pattern Rocker
          const Text('RHYTHMIC HAPTIC BEAT PATTERN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<HapticBeatPattern>(
              options: const [
                RockerOption(value: HapticBeatPattern.transientDynamic, label: '📳 Dynamic Bass'),
                RockerOption(value: HapticBeatPattern.quarterBeat, label: '🥁 4/4 Kick'),
                RockerOption(value: HapticBeatPattern.eighthShuffle, label: '⚡ 8th Groove'),
                RockerOption(value: HapticBeatPattern.tripletTrap, label: '🔥 Triplet'),
              ],
              selectedValue: settings.pattern,
              activeColor: AppColors.kappogyRed,
              onSelected: notifier.setPattern,
            ),
          ),

          const SizedBox(height: 18),

          // Rotary Potentiometers (Intensity & Cutoff)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'Vibration motor punch intensity',
                child: SkeuoKnob(
                  label: 'INTENSITY',
                  value: settings.intensityPercent,
                  min: 0.0,
                  max: 100.0,
                  size: 64,
                  ledColor: AppColors.kappogyRed,
                  onChanged: settings.isEnabled ? notifier.setIntensity : (_) {},
                  displayValue: '${settings.intensityPercent.toInt()}%',
                ),
              ),
              Tooltip(
                message: 'Sub-bass low-pass transient trigger frequency',
                child: SkeuoKnob(
                  label: 'SUB CUTOFF',
                  value: settings.cutoffFrequencyHz,
                  min: 40.0,
                  max: 120.0,
                  size: 64,
                  ledColor: AppColors.kappogyYellow,
                  onChanged: settings.isEnabled ? notifier.setCutoff : (_) {},
                  displayValue: '${settings.cutoffFrequencyHz.toInt()}Hz',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Audible Metronome Tick Option
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AUDIBLE ACOUSTIC CLICK', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Adds subtle studio rimshot sound alongside haptic pulse', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                  ],
                ),
                Tooltip(
                  message: 'Toggle audible rimshot click',
                  child: SkeuoButton(
                    size: 34,
                    activeColor: AppColors.kappogyYellow,
                    isActive: settings.isMetronomeAudible,
                    onPressed: notifier.toggleAudible,
                    child: Icon(
                      Icons.volume_up_rounded,
                      size: 16,
                      color: settings.isMetronomeAudible ? AppColors.kappogyYellow : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
