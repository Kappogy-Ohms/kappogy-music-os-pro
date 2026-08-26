import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum LoudnessStandard {
  streaming14('Streaming (-14 LUFS)', -14.0),
  audiophileEbu18('Audiophile EBU (-18 LUFS)', -18.0),
  broadcast23('Broadcast R128 (-23 LUFS)', -23.0);

  final String label;
  final double targetLufs;
  const LoudnessStandard(this.label, this.targetLufs);
}

class LoudnessLevelerSettings {
  final bool isEnabled;
  final LoudnessStandard standard;
  final double manualTrimDb; // -12.0 to +12.0 dB
  final bool isTruePeakGuardEnabled;
  final double liveLufs; // Simulated live -30 to -6

  const LoudnessLevelerSettings({
    this.isEnabled = true,
    this.standard = LoudnessStandard.streaming14,
    this.manualTrimDb = 0.0,
    this.isTruePeakGuardEnabled = true,
    this.liveLufs = -14.2,
  });

  LoudnessLevelerSettings copyWith({
    bool? isEnabled,
    LoudnessStandard? standard,
    double? manualTrimDb,
    bool? isTruePeakGuardEnabled,
    double? liveLufs,
  }) {
    return LoudnessLevelerSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      standard: standard ?? this.standard,
      manualTrimDb: manualTrimDb ?? this.manualTrimDb,
      isTruePeakGuardEnabled: isTruePeakGuardEnabled ?? this.isTruePeakGuardEnabled,
      liveLufs: liveLufs ?? this.liveLufs,
    );
  }
}

class LoudnessLevelerNotifier extends StateNotifier<LoudnessLevelerSettings> {
  LoudnessLevelerNotifier() : super(const LoudnessLevelerSettings());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  void setStandard(LoudnessStandard std) => state = state.copyWith(standard: std);
  void setManualTrim(double db) => state = state.copyWith(manualTrimDb: db.clamp(-12.0, 12.0));
  void toggleTruePeakGuard() => state = state.copyWith(isTruePeakGuardEnabled: !state.isTruePeakGuardEnabled);
  void updateLiveLufs(double lufs) => state = state.copyWith(liveLufs: lufs);
}

final loudnessLevelerProvider = StateNotifierProvider<LoudnessLevelerNotifier, LoudnessLevelerSettings>((ref) {
  return LoudnessLevelerNotifier();
});

class LoudnessLevelerSheet extends ConsumerWidget {
  const LoudnessLevelerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const LoudnessLevelerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(loudnessLevelerProvider);
    final notifier = ref.read(loudnessLevelerProvider.notifier);

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
                  Icon(Icons.volume_up_rounded, color: AppColors.kappogyGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'EBU R128 / REPLAYGAIN LUFS LOUDNESS LEVELER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle Loudness Normalization Engine',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.kappogyGreen,
                  isActive: settings.isEnabled,
                  onPressed: notifier.toggleEnabled,
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 16,
                    color: settings.isEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Live Integrated LUFS Display Meter
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('INTEGRATED LOUDNESS GAUGE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                    Text(
                      settings.isEnabled ? '${settings.liveLufs.toStringAsFixed(1)} LUFS (TARGET: ${settings.standard.targetLufs.toInt()} LUFS)' : 'BYPASS',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: settings.isEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Visual Meter Bar
                Container(
                  height: 18,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.panelSunken,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: SkeuoTokens.sunkenWell,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final norm = ((-settings.liveLufs) / 30.0).clamp(0.0, 1.0);
                      final meterWidth = width * (1.0 - norm);

                      return Stack(
                        children: [
                          Container(
                            width: meterWidth,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.kappogyGreen, AppColors.kappogyYellow, AppColors.kappogyRed],
                                stops: [0.6, 0.85, 1.0],
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          // Target line
                          Positioned(
                            left: width * (1.0 - ((-settings.standard.targetLufs) / 30.0)),
                            top: 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Standard Target Rocker Switch
          const Text('TARGET LOUDNESS STANDARD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<LoudnessStandard>(
              options: const [
                RockerOption(value: LoudnessStandard.streaming14, label: 'Streaming (-14)'),
                RockerOption(value: LoudnessStandard.audiophileEbu18, label: 'EBU R128 (-18)'),
                RockerOption(value: LoudnessStandard.broadcast23, label: 'Broadcast (-23)'),
              ],
              selectedValue: settings.standard,
              activeColor: AppColors.kappogyGreen,
              onSelected: notifier.setStandard,
            ),
          ),

          const SizedBox(height: 16),

          // Preamp Trim & True-Peak Guard Controls
          Row(
            children: [
              Expanded(
                child: SkeuoPanel(
                  showCornerScrews: false,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text('PREAMP GAIN TRIM', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      SkeuoKnob(
                        label: 'TRIM',
                        value: settings.manualTrimDb,
                        min: -12.0,
                        max: 12.0,
                        size: 64,
                        ledColor: AppColors.kappogyYellow,
                        onChanged: settings.isEnabled ? notifier.setManualTrim : (_) {},
                        displayValue: '${settings.manualTrimDb >= 0 ? '+' : ''}${settings.manualTrimDb.toStringAsFixed(1)}dB',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SkeuoPanel(
                  showCornerScrews: false,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TRUE-PEAK GUARD', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          SkeuoButton(
                            size: 28,
                            activeColor: AppColors.kappogyGreen,
                            isActive: settings.isTruePeakGuardEnabled,
                            onPressed: notifier.toggleTruePeakGuard,
                            child: Icon(
                              Icons.security_rounded,
                              size: 14,
                              color: settings.isTruePeakGuardEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Intercepts inter-sample peaks to protect DACs from clipping distortion during loud masters.',
                        style: TextStyle(fontSize: 9, color: AppColors.textSecondary, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
