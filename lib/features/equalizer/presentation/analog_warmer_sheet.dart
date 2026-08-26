import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum WarmthChassisProfile {
  vintageTube75('1975 Vintage Tube', 'Silky 2nd-order even harmonics with rich valve bass warmth'),
  classATriode('Class-A Triode', 'Airy vocal harmonic excitation and dynamic valve crunch'),
  studerTapeMaster('Studer 15-IPS Tape', 'Analog magnetic tape compression glue and tape roundness'),
  solidStateClean('Solid-State Linear', 'Ultra-linear studio mastering stage with transparent fidelity');

  final String label;
  final String description;
  const WarmthChassisProfile(this.label, this.description);
}

class AnalogWarmerSettings {
  final bool isEnabled;
  final WarmthChassisProfile profile;
  final double tubeWarmthPercent; // 0.0 to 100.0%
  final double tapeSaturationPercent; // 0.0 to 100.0%
  final double harmonicDriveDb; // 0.0 to 18.0 dB
  final bool isAnalogHissEnabled;

  const AnalogWarmerSettings({
    this.isEnabled = true,
    this.profile = WarmthChassisProfile.vintageTube75,
    this.tubeWarmthPercent = 40.0,
    this.tapeSaturationPercent = 35.0,
    this.harmonicDriveDb = 6.0,
    this.isAnalogHissEnabled = false,
  });

  AnalogWarmerSettings copyWith({
    bool? isEnabled,
    WarmthChassisProfile? profile,
    double? tubeWarmthPercent,
    double? tapeSaturationPercent,
    double? harmonicDriveDb,
    bool? isAnalogHissEnabled,
  }) {
    return AnalogWarmerSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      profile: profile ?? this.profile,
      tubeWarmthPercent: tubeWarmthPercent ?? this.tubeWarmthPercent,
      tapeSaturationPercent: tapeSaturationPercent ?? this.tapeSaturationPercent,
      harmonicDriveDb: harmonicDriveDb ?? this.harmonicDriveDb,
      isAnalogHissEnabled: isAnalogHissEnabled ?? this.isAnalogHissEnabled,
    );
  }
}

class AnalogWarmerNotifier extends StateNotifier<AnalogWarmerSettings> {
  AnalogWarmerNotifier() : super(const AnalogWarmerSettings());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  void setProfile(WarmthChassisProfile p) => state = state.copyWith(profile: p);
  void setTubeWarmth(double val) => state = state.copyWith(tubeWarmthPercent: val.clamp(0.0, 100.0));
  void setTapeSaturation(double val) => state = state.copyWith(tapeSaturationPercent: val.clamp(0.0, 100.0));
  void setDrive(double db) => state = state.copyWith(harmonicDriveDb: db.clamp(0.0, 18.0));
  void toggleHiss() => state = state.copyWith(isAnalogHissEnabled: !state.isAnalogHissEnabled);
}

final analogWarmerProvider = StateNotifierProvider<AnalogWarmerNotifier, AnalogWarmerSettings>((ref) {
  return AnalogWarmerNotifier();
});

class AnalogWarmerSheet extends ConsumerWidget {
  const AnalogWarmerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AnalogWarmerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(analogWarmerProvider);
    final notifier = ref.read(analogWarmerProvider.notifier);

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
                  Icon(Icons.fireplace_rounded, color: AppColors.kappogyYellow, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'VINTAGE TUBE & TAPE SATURATION WARMER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle Vacuum Tube Saturation Stage',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.kappogyYellow,
                  isActive: settings.isEnabled,
                  onPressed: notifier.toggleEnabled,
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 16,
                    color: settings.isEnabled ? AppColors.kappogyYellow : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Glowing Vacuum Tube / Tape Spool Visualizer
          SkeuoPanel(
            showCornerScrews: true,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Glowing Cathode Valve Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.panelSunken,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: settings.isEnabled ? AppColors.kappogyYellow : AppColors.borderSubtle,
                      width: 1.2,
                    ),
                    boxShadow: settings.isEnabled
                        ? [
                            BoxShadow(
                              color: AppColors.kappogyYellow.withValues(alpha: 0.35),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : SkeuoTokens.sunkenWell,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lightbulb_rounded,
                      color: settings.isEnabled ? AppColors.kappogyYellow : AppColors.textMuted,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        settings.profile.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: settings.isEnabled ? AppColors.kappogyYellow : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        settings.profile.description,
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Profile Selection Rocker
          const Text('ANALOG CHASSIS & VALVE PROFILE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<WarmthChassisProfile>(
              options: const [
                RockerOption(value: WarmthChassisProfile.vintageTube75, label: '1975 Tube'),
                RockerOption(value: WarmthChassisProfile.classATriode, label: 'Class-A Triode'),
                RockerOption(value: WarmthChassisProfile.studerTapeMaster, label: '15-IPS Tape'),
                RockerOption(value: WarmthChassisProfile.solidStateClean, label: 'Linear Solid'),
              ],
              selectedValue: settings.profile,
              activeColor: AppColors.kappogyYellow,
              onSelected: notifier.setProfile,
            ),
          ),

          const SizedBox(height: 18),

          // Rotary Potentiometers (Tube Warmth, Tape Saturation, Harmonic Drive)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Tooltip(
                message: '2nd-order even harmonic tube valve saturation',
                child: SkeuoKnob(
                  label: 'TUBE WARMTH',
                  value: settings.tubeWarmthPercent,
                  min: 0.0,
                  max: 100.0,
                  size: 64,
                  ledColor: AppColors.kappogyYellow,
                  onChanged: settings.isEnabled ? notifier.setTubeWarmth : (_) {},
                  displayValue: '${settings.tubeWarmthPercent.toInt()}%',
                ),
              ),
              Tooltip(
                message: '3rd-order magnetic tape saturation & tape compression glue',
                child: SkeuoKnob(
                  label: 'TAPE GLUE',
                  value: settings.tapeSaturationPercent,
                  min: 0.0,
                  max: 100.0,
                  size: 64,
                  ledColor: AppColors.kappogyRed,
                  onChanged: settings.isEnabled ? notifier.setTapeSaturation : (_) {},
                  displayValue: '${settings.tapeSaturationPercent.toInt()}%',
                ),
              ),
              Tooltip(
                message: 'Harmonic saturation input drive gain',
                child: SkeuoKnob(
                  label: 'DRIVE',
                  value: settings.harmonicDriveDb,
                  min: 0.0,
                  max: 18.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: settings.isEnabled ? notifier.setDrive : (_) {},
                  displayValue: '+${settings.harmonicDriveDb.toStringAsFixed(1)}dB',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Analog Tape Hiss Switch
          SkeuoPanel(
            showCornerScrews: false,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('VINTAGE MAGNETIC TAPE HISS & FLUTTER', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    SizedBox(height: 2),
                    Text('Generates subtle -72dB analog room noise floor', style: TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
                  ],
                ),
                Tooltip(
                  message: 'Toggle subtle vintage tape floor hiss simulation',
                  child: SkeuoButton(
                    size: 34,
                    activeColor: AppColors.kappogyYellow,
                    isActive: settings.isAnalogHissEnabled,
                    onPressed: notifier.toggleHiss,
                    child: Icon(
                      Icons.grain_rounded,
                      size: 16,
                      color: settings.isAnalogHissEnabled ? AppColors.kappogyYellow : AppColors.textMuted,
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
