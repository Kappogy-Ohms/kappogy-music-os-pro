import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum VocalExtractionMode {
  karaokeInstrumental('Karaoke Instrumental', 'Mutes center lead vocals via phase cancellation while preserving stereo instrumentation'),
  acappellaSolo('A Cappella Solo', 'Isolates and extracts centered human vocal frequencies'),
  bypass('Original Master', 'Full unmodified stereo studio audio mix');

  final String label;
  final String description;
  const VocalExtractionMode(this.label, this.description);
}

class VocalRemoverSettings {
  final bool isEnabled;
  final VocalExtractionMode mode;
  final double vocalCutDb; // -24.0 to 0.0 dB
  final double centerFrequencyHz; // 200 to 3500 Hz
  final double sideStereoRecoveryPercent; // 0 to 100%
  final bool isBassRetained; // Keep center bass below 120Hz

  const VocalRemoverSettings({
    this.isEnabled = true,
    this.mode = VocalExtractionMode.karaokeInstrumental,
    this.vocalCutDb = -18.0,
    this.centerFrequencyHz = 1200.0,
    this.sideStereoRecoveryPercent = 75.0,
    this.isBassRetained = true,
  });

  VocalRemoverSettings copyWith({
    bool? isEnabled,
    VocalExtractionMode? mode,
    double? vocalCutDb,
    double? centerFrequencyHz,
    double? sideStereoRecoveryPercent,
    bool? isBassRetained,
  }) {
    return VocalRemoverSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      mode: mode ?? this.mode,
      vocalCutDb: vocalCutDb ?? this.vocalCutDb,
      centerFrequencyHz: centerFrequencyHz ?? this.centerFrequencyHz,
      sideStereoRecoveryPercent: sideStereoRecoveryPercent ?? this.sideStereoRecoveryPercent,
      isBassRetained: isBassRetained ?? this.isBassRetained,
    );
  }
}

class VocalRemoverNotifier extends StateNotifier<VocalRemoverSettings> {
  VocalRemoverNotifier() : super(const VocalRemoverSettings());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  void setMode(VocalExtractionMode m) => state = state.copyWith(mode: m);
  void setVocalCut(double db) => state = state.copyWith(vocalCutDb: db.clamp(-24.0, 0.0));
  void setCenterFreq(double hz) => state = state.copyWith(centerFrequencyHz: hz.clamp(200.0, 3500.0));
  void setSideRecovery(double val) => state = state.copyWith(sideStereoRecoveryPercent: val.clamp(0.0, 100.0));
  void toggleBassRetained() => state = state.copyWith(isBassRetained: !state.isBassRetained);
}

final vocalRemoverProvider = StateNotifierProvider<VocalRemoverNotifier, VocalRemoverSettings>((ref) {
  return VocalRemoverNotifier();
});

class VocalRemoverSheet extends ConsumerWidget {
  const VocalRemoverSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const VocalRemoverSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(vocalRemoverProvider);
    final notifier = ref.read(vocalRemoverProvider.notifier);

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
                  Icon(Icons.mic_off_rounded, color: AppColors.ledPurple, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'MID-SIDE VOCAL REMOVER & STEM EXTRACTOR',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle Vocal Processing Engine',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.ledPurple,
                  isActive: settings.isEnabled,
                  onPressed: notifier.toggleEnabled,
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 16,
                    color: settings.isEnabled ? AppColors.ledPurple : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Mode Description Card
          SkeuoPanel(
            showCornerScrews: true,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.panelSunken,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: SkeuoTokens.sunkenWell,
                  ),
                  child: Center(
                    child: Icon(
                      settings.mode == VocalExtractionMode.karaokeInstrumental
                          ? Icons.music_note_rounded
                          : settings.mode == VocalExtractionMode.acappellaSolo
                              ? Icons.record_voice_over_rounded
                              : Icons.album_rounded,
                      color: AppColors.ledPurple,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.mode.label.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.ledPurple),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.mode.description,
                        style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Mode Rocker Selector
          const Text('EXTRACTION MODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<VocalExtractionMode>(
              options: const [
                RockerOption(value: VocalExtractionMode.karaokeInstrumental, label: '🎤 Karaoke Cut'),
                RockerOption(value: VocalExtractionMode.acappellaSolo, label: '🗣️ A Cappella'),
                RockerOption(value: VocalExtractionMode.bypass, label: '🎵 Full Master'),
              ],
              selectedValue: settings.mode,
              activeColor: AppColors.ledPurple,
              onSelected: notifier.setMode,
            ),
          ),

          const SizedBox(height: 18),

          // Rotary Potentiometers (Vocal Cut Depth, Frequency Notch, Stereo Side Recovery)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: 'Center channel attenuation depth',
                child: SkeuoKnob(
                  label: 'VOCAL CUT',
                  value: settings.vocalCutDb,
                  min: -24.0,
                  max: 0.0,
                  size: 64,
                  ledColor: AppColors.kappogyRed,
                  onChanged: settings.isEnabled ? notifier.setVocalCut : (_) {},
                  displayValue: '${settings.vocalCutDb.toStringAsFixed(1)}dB',
                ),
              ),
              Tooltip(
                message: 'Center frequency band for human speech and singing presence',
                child: SkeuoKnob(
                  label: 'CENTER FREQ',
                  value: settings.centerFrequencyHz,
                  min: 200.0,
                  max: 3500.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: settings.isEnabled ? notifier.setCenterFreq : (_) {},
                  displayValue: '${settings.centerFrequencyHz.toInt()}Hz',
                ),
              ),
              Tooltip(
                message: 'Stereo side ambient reverb & spatial instruments recovery',
                child: SkeuoKnob(
                  label: 'SIDE GLUE',
                  value: settings.sideStereoRecoveryPercent,
                  min: 0.0,
                  max: 100.0,
                  size: 64,
                  ledColor: AppColors.kappogyGreen,
                  onChanged: settings.isEnabled ? notifier.setSideRecovery : (_) {},
                  displayValue: '${settings.sideStereoRecoveryPercent.toInt()}%',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Bass Center Retention Toggle
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BASS & KICK RETENTION (< 120Hz)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Preserves centered low-end groove during vocal cancellation', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                  ],
                ),
                Tooltip(
                  message: 'Keep center frequencies below 120Hz to maintain solid kick drum and bass line',
                  child: SkeuoButton(
                    size: 34,
                    activeColor: AppColors.ledPurple,
                    isActive: settings.isBassRetained,
                    onPressed: notifier.toggleBassRetained,
                    child: Icon(
                      Icons.speaker_group_rounded,
                      size: 16,
                      color: settings.isBassRetained ? AppColors.ledPurple : AppColors.textMuted,
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
