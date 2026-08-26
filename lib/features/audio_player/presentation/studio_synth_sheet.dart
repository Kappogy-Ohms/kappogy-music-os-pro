import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum OscillatorWaveform {
  sine('Pure Sine', Icons.waves_rounded),
  triangle('Triangle', Icons.change_history_rounded),
  sawtooth('Sawtooth', Icons.show_chart_rounded),
  square('Square Pulse', Icons.crop_square_rounded),
  pinkNoise('Pink Noise', Icons.grain_rounded),
  whiteNoise('White Noise', Icons.blur_on_rounded);

  final String label;
  final IconData icon;
  const OscillatorWaveform(this.label, this.icon);
}

class StudioSynthSettings {
  final bool isOscillatorActive;
  final OscillatorWaveform waveform;
  final double frequencyHz; // 20.0 to 20000.0 Hz
  final double filterCutoffHz; // 100.0 to 12000.0 Hz
  final double outputGainDb; // -30.0 to 0.0 dB
  final int activeNoteIndex; // -1 if none

  const StudioSynthSettings({
    this.isOscillatorActive = false,
    this.waveform = OscillatorWaveform.sine,
    this.frequencyHz = 440.0,
    this.filterCutoffHz = 4500.0,
    this.outputGainDb = -6.0,
    this.activeNoteIndex = -1,
  });

  StudioSynthSettings copyWith({
    bool? isOscillatorActive,
    OscillatorWaveform? waveform,
    double? frequencyHz,
    double? filterCutoffHz,
    double? outputGainDb,
    int? activeNoteIndex,
  }) {
    return StudioSynthSettings(
      isOscillatorActive: isOscillatorActive ?? this.isOscillatorActive,
      waveform: waveform ?? this.waveform,
      frequencyHz: frequencyHz ?? this.frequencyHz,
      filterCutoffHz: filterCutoffHz ?? this.filterCutoffHz,
      outputGainDb: outputGainDb ?? this.outputGainDb,
      activeNoteIndex: activeNoteIndex ?? this.activeNoteIndex,
    );
  }
}

class StudioSynthNotifier extends StateNotifier<StudioSynthSettings> {
  StudioSynthNotifier() : super(const StudioSynthSettings());

  void toggleOscillator() => state = state.copyWith(isOscillatorActive: !state.isOscillatorActive);
  void setWaveform(OscillatorWaveform w) => state = state.copyWith(waveform: w);
  void setFrequency(double hz) => state = state.copyWith(frequencyHz: hz.clamp(20.0, 20000.0));
  void lockA440() => state = state.copyWith(frequencyHz: 440.0, waveform: OscillatorWaveform.sine);
  void setFilter(double hz) => state = state.copyWith(filterCutoffHz: hz.clamp(100.0, 12000.0));
  void setGain(double db) => state = state.copyWith(outputGainDb: db.clamp(-30.0, 0.0));

  void apply808Sub() {
    state = state.copyWith(
      waveform: OscillatorWaveform.sine,
      frequencyHz: 55.0,
      filterCutoffHz: 250.0,
      outputGainDb: -3.0,
    );
  }

  void applySynthLead() {
    state = state.copyWith(
      waveform: OscillatorWaveform.sawtooth,
      frequencyHz: 587.33,
      filterCutoffHz: 6500.0,
      outputGainDb: -6.0,
    );
  }

  void applyAnalogBrass() {
    state = state.copyWith(
      waveform: OscillatorWaveform.square,
      frequencyHz: 220.0,
      filterCutoffHz: 2800.0,
      outputGainDb: -8.0,
    );
  }

  void applyEPiano() {
    state = state.copyWith(
      waveform: OscillatorWaveform.triangle,
      frequencyHz: 329.63,
      filterCutoffHz: 5000.0,
      outputGainDb: -5.0,
    );
  }

  void playNote(int index, double noteFreq) {
    HapticFeedback.selectionClick();
    state = state.copyWith(
      activeNoteIndex: index,
      frequencyHz: noteFreq,
      isOscillatorActive: true,
    );
  }

  void releaseNote() {
    state = state.copyWith(activeNoteIndex: -1);
  }
}

final studioSynthProvider = StateNotifierProvider<StudioSynthNotifier, StudioSynthSettings>((ref) {
  return StudioSynthNotifier();
});

class StudioSynthSheet extends ConsumerWidget {
  const StudioSynthSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const StudioSynthSheet(),
    );
  }

  static const List<Map<String, dynamic>> _musicalNotes = [
    {'name': 'C4', 'freq': 261.63},
    {'name': 'D4', 'freq': 293.66},
    {'name': 'E4', 'freq': 329.63},
    {'name': 'F4', 'freq': 349.23},
    {'name': 'G4', 'freq': 392.00},
    {'name': 'A4', 'freq': 440.00},
    {'name': 'B4', 'freq': 493.88},
    {'name': 'C5', 'freq': 523.25},
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(studioSynthProvider);
    final notifier = ref.read(studioSynthProvider.notifier);

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
                  Icon(Icons.piano_rounded, color: AppColors.kappogyGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'STUDIO TONE GENERATOR & TUNER SYNTH',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle Tone Output',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.kappogyGreen,
                  isActive: settings.isOscillatorActive,
                  onPressed: notifier.toggleOscillator,
                  child: Icon(
                    Icons.volume_up_rounded,
                    size: 16,
                    color: settings.isOscillatorActive ? AppColors.kappogyGreen : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Frequency Readout & Calibration Lock
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('OSCILLATOR FREQUENCY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${settings.frequencyHz.toStringAsFixed(1)} Hz',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.ledCyan, fontFamily: 'monospace'),
                    ),
                  ],
                ),
                Tooltip(
                  message: 'Lock to A440 Concert Tuning Pitch (440.0Hz Pure Sine)',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: settings.frequencyHz == 440.0 ? AppColors.kappogyGreen : AppColors.panelRaised,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.tune_rounded, size: 14, color: AppColors.textPrimary),
                    label: const Text('LOCK A440', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    onPressed: notifier.lockA440,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Waveform Rocker Selector
          const Text('ANALOG OSCILLATOR WAVEFORM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<OscillatorWaveform>(
              options: const [
                RockerOption(value: OscillatorWaveform.sine, label: 'Sine (Pure)'),
                RockerOption(value: OscillatorWaveform.triangle, label: 'Triangle'),
                RockerOption(value: OscillatorWaveform.sawtooth, label: 'Sawtooth'),
                RockerOption(value: OscillatorWaveform.square, label: 'Square'),
                RockerOption(value: OscillatorWaveform.pinkNoise, label: 'Pink Noise'),
              ],
              selectedValue: settings.waveform,
              activeColor: AppColors.kappogyGreen,
              onSelected: notifier.setWaveform,
            ),
          ),

          const SizedBox(height: 14),

          // Instrument Sound Presets
          const Text('STUDIO INSTRUMENT SOUND PRESETS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.panelRaised,
                    side: const BorderSide(color: AppColors.kappogyRed, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    notifier.apply808Sub();
                  },
                  child: const Text('🔥 808 Sub-Bass', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.kappogyRed)),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.panelRaised,
                    side: const BorderSide(color: AppColors.ledCyan, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    notifier.applySynthLead();
                  },
                  child: const Text('⚡ Synth Lead', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.ledCyan)),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.panelRaised,
                    side: const BorderSide(color: AppColors.kappogyYellow, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    notifier.applyAnalogBrass();
                  },
                  child: const Text('🎺 Analog Brass', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow)),
                ),
                const SizedBox(width: 6),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.panelRaised,
                    side: const BorderSide(color: AppColors.ledPurple, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    notifier.applyEPiano();
                  },
                  child: const Text('🎹 E-Piano', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.ledPurple)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Playable 8-Key Touch Synth Keyboard
          const Text('PLAYABLE MUSICIAN TOUCH KEYBED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(_musicalNotes.length, (idx) {
              final note = _musicalNotes[idx];
              final isKeyActive = settings.activeNoteIndex == idx;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: GestureDetector(
                    onTapDown: (_) => notifier.playNote(idx, note['freq'] as double),
                    onTapUp: (_) => notifier.releaseNote(),
                    onTapCancel: notifier.releaseNote,
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: isKeyActive ? null : AppColors.raisedButtonGradient,
                        color: isKeyActive ? AppColors.kappogyGreen : null,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isKeyActive ? AppColors.kappogyGreen : AppColors.borderSubtle,
                          width: 1.2,
                        ),
                        boxShadow: isKeyActive
                            ? [
                                BoxShadow(
                                  color: AppColors.kappogyGreen.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                            : SkeuoTokens.raisedSm,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            note['name'] as String,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isKeyActive ? Colors.black : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 14,
                            height: 3,
                            color: isKeyActive ? Colors.black54 : AppColors.kappogyGreen,
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Potentiometers (Frequency Sweep, Low-Pass Filter, Output Gain)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'Continuous test tone frequency sweep',
                child: SkeuoKnob(
                  label: 'FREQ SWEEP',
                  value: settings.frequencyHz,
                  min: 20.0,
                  max: 20000.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: notifier.setFrequency,
                  displayValue: settings.frequencyHz > 1000 ? '${(settings.frequencyHz / 1000).toStringAsFixed(1)}k' : '${settings.frequencyHz.toInt()}Hz',
                ),
              ),
              Tooltip(
                message: 'Analog synthesizer low-pass resonance filter cutoff',
                child: SkeuoKnob(
                  label: 'LP FILTER',
                  value: settings.filterCutoffHz,
                  min: 100.0,
                  max: 12000.0,
                  size: 64,
                  ledColor: AppColors.kappogyYellow,
                  onChanged: notifier.setFilter,
                  displayValue: '${(settings.filterCutoffHz / 1000).toStringAsFixed(1)}kHz',
                ),
              ),
              Tooltip(
                message: 'Tone generator output volume gain',
                child: SkeuoKnob(
                  label: 'GAIN',
                  value: settings.outputGainDb,
                  min: -30.0,
                  max: 0.0,
                  size: 64,
                  ledColor: AppColors.kappogyGreen,
                  onChanged: notifier.setGain,
                  displayValue: '${settings.outputGainDb.toStringAsFixed(0)}dB',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
