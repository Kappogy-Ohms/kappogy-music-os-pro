import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';

enum AutomixTransitionStyle {
  beatmatch8Bar('8-Bar Beatmatch', 'Smooth rhythm blend with seamless tempo synchronisation'),
  echoFreezeOut('Echo Freeze Tail', 'Freezes outgoing deck in an expansive stereo dub echo'),
  highPassSweep('High-Pass Sweep', 'Gradually filters out sub-bass before dropping the incoming kick'),
  vinylSpinback('Vinyl Brake Stop', 'Classic analog 33-RPM motor brake spindown and drop');

  final String label;
  final String description;
  const AutomixTransitionStyle(this.label, this.description);
}

class AutomixSettings {
  final bool isEnabled;
  final AutomixTransitionStyle style;
  final double transitionSeconds; // 4.0 to 24.0 s
  final bool isHarmonicSortEnabled;
  final bool isTempoBpmMatchEnabled;
  final double liveCrossfadeProgress; // 0.0 to 1.0

  const AutomixSettings({
    this.isEnabled = true,
    this.style = AutomixTransitionStyle.beatmatch8Bar,
    this.transitionSeconds = 12.0,
    this.isHarmonicSortEnabled = true,
    this.isTempoBpmMatchEnabled = true,
    this.liveCrossfadeProgress = 0.5,
  });

  AutomixSettings copyWith({
    bool? isEnabled,
    AutomixTransitionStyle? style,
    double? transitionSeconds,
    bool? isHarmonicSortEnabled,
    bool? isTempoBpmMatchEnabled,
    double? liveCrossfadeProgress,
  }) {
    return AutomixSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      style: style ?? this.style,
      transitionSeconds: transitionSeconds ?? this.transitionSeconds,
      isHarmonicSortEnabled: isHarmonicSortEnabled ?? this.isHarmonicSortEnabled,
      isTempoBpmMatchEnabled: isTempoBpmMatchEnabled ?? this.isTempoBpmMatchEnabled,
      liveCrossfadeProgress: liveCrossfadeProgress ?? this.liveCrossfadeProgress,
    );
  }
}

class AutomixNotifier extends StateNotifier<AutomixSettings> {
  AutomixNotifier() : super(const AutomixSettings());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);
  void setStyle(AutomixTransitionStyle s) => state = state.copyWith(style: s);
  void setTransitionDuration(double sec) => state = state.copyWith(transitionSeconds: sec.clamp(4.0, 24.0));
  void toggleHarmonicSort() => state = state.copyWith(isHarmonicSortEnabled: !state.isHarmonicSortEnabled);
  void toggleBpmMatch() => state = state.copyWith(isTempoBpmMatchEnabled: !state.isTempoBpmMatchEnabled);
  void setProgress(double prog) => state = state.copyWith(liveCrossfadeProgress: prog.clamp(0.0, 1.0));
}

final automixProvider = StateNotifierProvider<AutomixNotifier, AutomixSettings>((ref) {
  return AutomixNotifier();
});

class AutomixEngineSheet extends ConsumerWidget {
  const AutomixEngineSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AutomixEngineSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(automixProvider);
    final notifier = ref.read(automixProvider.notifier);

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
                  Icon(Icons.auto_mode_rounded, color: AppColors.ledCyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'DJ AUTOMIX & HARMONIC TRANSITION ENGINE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Tooltip(
                message: 'Toggle Continuous Radio DJ Automix',
                child: SkeuoButton(
                  size: 32,
                  activeColor: AppColors.ledCyan,
                  isActive: settings.isEnabled,
                  onPressed: notifier.toggleEnabled,
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 16,
                    color: settings.isEnabled ? AppColors.ledCyan : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Transition Style Card
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
                      settings.style == AutomixTransitionStyle.beatmatch8Bar
                          ? Icons.sync_rounded
                          : settings.style == AutomixTransitionStyle.echoFreezeOut
                              ? Icons.blur_on_rounded
                              : settings.style == AutomixTransitionStyle.highPassSweep
                                  ? Icons.tune_rounded
                                  : Icons.album_rounded,
                      color: AppColors.ledCyan,
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
                        settings.style.label.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.ledCyan),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        settings.style.description,
                        style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Style Rocker Selector
          const Text('AUTOMIX TRANSITION STYLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SkeuoRockerSwitch<AutomixTransitionStyle>(
              options: const [
                RockerOption(value: AutomixTransitionStyle.beatmatch8Bar, label: '⚡ 8-Bar Beatmatch'),
                RockerOption(value: AutomixTransitionStyle.echoFreezeOut, label: '🌊 Echo Freeze'),
                RockerOption(value: AutomixTransitionStyle.highPassSweep, label: '🎚️ Filter Sweep'),
                RockerOption(value: AutomixTransitionStyle.vinylSpinback, label: '💿 Vinyl Brake'),
              ],
              selectedValue: settings.style,
              activeColor: AppColors.ledCyan,
              onSelected: notifier.setStyle,
            ),
          ),

          const SizedBox(height: 18),

          // Potentiometer & Toggles
          Row(
            children: [
              Tooltip(
                message: 'Crossfade transition duration in seconds (4s to 24s)',
                child: SkeuoKnob(
                  label: 'DURATION',
                  value: settings.transitionSeconds,
                  min: 4.0,
                  max: 24.0,
                  size: 64,
                  ledColor: AppColors.ledCyan,
                  onChanged: settings.isEnabled ? notifier.setTransitionDuration : (_) {},
                  displayValue: '${settings.transitionSeconds.toInt()}s',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  children: [
                    // Harmonic Camelot Queue Sorting
                    SkeuoPanel(
                      showCornerScrews: false,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('HARMONIC CAMELOT SORT', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                              Text('Orders queue for perfect musical keys', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted)),
                            ],
                          ),
                          SkeuoButton(
                            size: 28,
                            activeColor: AppColors.kappogyGreen,
                            isActive: settings.isHarmonicSortEnabled,
                            onPressed: notifier.toggleHarmonicSort,
                            child: Icon(
                              Icons.music_note_rounded,
                              size: 14,
                              color: settings.isHarmonicSortEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Beat BPM Tempo Sync
                    SkeuoPanel(
                      showCornerScrews: false,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BPM TEMPO SYNC', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                              Text('Matches speeds during overlap', style: TextStyle(fontSize: 8.5, color: AppColors.textMuted)),
                            ],
                          ),
                          SkeuoButton(
                            size: 28,
                            activeColor: AppColors.kappogyYellow,
                            isActive: settings.isTempoBpmMatchEnabled,
                            onPressed: notifier.toggleBpmMatch,
                            child: Icon(
                              Icons.speed_rounded,
                              size: 14,
                              color: settings.isTempoBpmMatchEnabled ? AppColors.kappogyYellow : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
