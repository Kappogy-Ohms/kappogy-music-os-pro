import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum PitchPresetMode {
  normal('Natural Master', 0.0, 1.0, 0.0),
  nightcore('Nightcore (+4st / 125%)', 4.0, 1.25, 2.0),
  vaporwave('Vaporwave (-4st / 80%)', -4.0, 0.80, -2.0),
  chipmunk('High Formant (+8st)', 8.0, 1.0, 6.0),
  deepVoice('Bass Vocal (-6st)', -6.0, 1.0, -5.0);

  final String label;
  final double semitones;
  final double speed;
  final double formant;
  const PitchPresetMode(this.label, this.semitones, this.speed, this.formant);
}

class PitchFormantState {
  final bool isEnabled;
  final double pitchSemitones; // -24.0 to +24.0 st
  final double speedMultiplier; // 0.25 to 4.0 x
  final double formantShift; // -12.0 to +12.0 st
  final bool isFormantPreserved;
  final PitchPresetMode activePreset;

  const PitchFormantState({
    this.isEnabled = true,
    this.pitchSemitones = 0.0,
    this.speedMultiplier = 1.0,
    this.formantShift = 0.0,
    this.isFormantPreserved = true,
    this.activePreset = PitchPresetMode.normal,
  });

  PitchFormantState copyWith({
    bool? isEnabled,
    double? pitchSemitones,
    double? speedMultiplier,
    double? formantShift,
    bool? isFormantPreserved,
    PitchPresetMode? activePreset,
  }) {
    return PitchFormantState(
      isEnabled: isEnabled ?? this.isEnabled,
      pitchSemitones: pitchSemitones ?? this.pitchSemitones,
      speedMultiplier: speedMultiplier ?? this.speedMultiplier,
      formantShift: formantShift ?? this.formantShift,
      isFormantPreserved: isFormantPreserved ?? this.isFormantPreserved,
      activePreset: activePreset ?? this.activePreset,
    );
  }
}

class PitchFormantLabNotifier extends StateNotifier<PitchFormantState> {
  PitchFormantLabNotifier() : super(const PitchFormantState());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);

  void setPitch(double st) {
    state = state.copyWith(pitchSemitones: st.clamp(-24.0, 24.0));
  }

  void setSpeed(double spd) {
    state = state.copyWith(speedMultiplier: spd.clamp(0.25, 4.0));
  }

  void setFormant(double f) {
    state = state.copyWith(formantShift: f.clamp(-12.0, 12.0));
  }

  void toggleFormantPreservation() {
    state = state.copyWith(isFormantPreserved: !state.isFormantPreserved);
  }

  void applyPreset(PitchPresetMode preset) {
    state = state.copyWith(
      activePreset: preset,
      pitchSemitones: preset.semitones,
      speedMultiplier: preset.speed,
      formantShift: preset.formant,
    );
  }

  void reset() {
    applyPreset(PitchPresetMode.normal);
  }
}

final pitchFormantLabProvider = StateNotifierProvider<PitchFormantLabNotifier, PitchFormantState>((ref) {
  return PitchFormantLabNotifier();
});

class PitchFormantLabSheet extends ConsumerWidget {
  const PitchFormantLabSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const PitchFormantLabSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labState = ref.watch(pitchFormantLabProvider);
    final notifier = ref.read(pitchFormantLabProvider.notifier);

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
                  Icon(Icons.graphic_eq_rounded, color: AppColors.ledPurple, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'PITCH & FORMANT SHIFTING LAB',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  Tooltip(
                    message: 'Reset pitch & tempo to 1.0x / 0 semitones',
                    child: SkeuoButton(
                      size: 32,
                      icon: Icons.refresh_rounded,
                      onPressed: notifier.reset,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Toggle Pitch & Formant Engine',
                    child: SkeuoButton(
                      size: 32,
                      activeColor: AppColors.ledPurple,
                      isActive: labState.isEnabled,
                      onPressed: notifier.toggleEnabled,
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        size: 16,
                        color: labState.isEnabled ? AppColors.ledPurple : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Presets Rocker
          const Text('DSP LAB PRESETS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<PitchPresetMode>(
              options: const [
                RockerOption(value: PitchPresetMode.normal, label: 'Standard'),
                RockerOption(value: PitchPresetMode.nightcore, label: '⚡ Nightcore'),
                RockerOption(value: PitchPresetMode.vaporwave, label: '🌴 Vaporwave'),
                RockerOption(value: PitchPresetMode.chipmunk, label: '🐿️ Chipmunk'),
                RockerOption(value: PitchPresetMode.deepVoice, label: '🗣️ Deep Voice'),
              ],
              selectedValue: labState.activePreset,
              activeColor: AppColors.ledPurple,
              onSelected: notifier.applyPreset,
            ),
          ),

          const SizedBox(height: 18),

          // Rotary Potentiometers: PITCH, SPEED, FORMANT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'Semitone pitch shifting (-24st to +24st)',
                child: SkeuoKnob(
                  label: 'PITCH',
                  value: labState.pitchSemitones,
                  min: -24.0,
                  max: 24.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: labState.isEnabled ? notifier.setPitch : (_) {},
                  displayValue: '${labState.pitchSemitones >= 0 ? '+' : ''}${labState.pitchSemitones.toStringAsFixed(1)}st',
                ),
              ),
              Tooltip(
                message: 'Time-stretch playback speed multiplier (0.25x to 4.0x)',
                child: SkeuoKnob(
                  label: 'TEMPO',
                  value: labState.speedMultiplier,
                  min: 0.25,
                  max: 4.0,
                  size: 64,
                  ledColor: AppColors.kappogyYellow,
                  onChanged: labState.isEnabled ? notifier.setSpeed : (_) {},
                  displayValue: '${labState.speedMultiplier.toStringAsFixed(2)}x',
                ),
              ),
              Tooltip(
                message: 'Vocal throat formant shift (-12st to +12st)',
                child: SkeuoKnob(
                  label: 'FORMANT',
                  value: labState.formantShift,
                  min: -12.0,
                  max: 12.0,
                  size: 64,
                  ledColor: AppColors.ledPurple,
                  onChanged: labState.isEnabled ? notifier.setFormant : (_) {},
                  displayValue: '${labState.formantShift >= 0 ? '+' : ''}${labState.formantShift.toStringAsFixed(1)}st',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Formant Preservation Toggle
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VOCAL TIMBRE FORMANT PRESERVATION', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Prevents chipmunk artifacting when pitch shifting', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                  ],
                ),
                Tooltip(
                  message: 'Toggle intelligent vocal formant preservation',
                  child: SkeuoButton(
                    size: 34,
                    activeColor: AppColors.ledPurple,
                    isActive: labState.isFormantPreserved,
                    onPressed: notifier.toggleFormantPreservation,
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      size: 16,
                      color: labState.isFormantPreserved ? AppColors.ledPurple : AppColors.textMuted,
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
