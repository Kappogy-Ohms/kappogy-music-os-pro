import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_fader.dart';
import '../../../core/widgets/skeuo_panel.dart';

class StemChannelState {
  final String name;
  final Color color;
  final double volume; // 0.0 to 1.0
  final bool isMuted;
  final bool isSolo;
  final double pan; // -1.0 (L) to 1.0 (R)

  const StemChannelState({
    required this.name,
    required this.color,
    this.volume = 0.85,
    this.isMuted = false,
    this.isSolo = false,
    this.pan = 0.0,
  });

  StemChannelState copyWith({
    String? name,
    Color? color,
    double? volume,
    bool? isMuted,
    bool? isSolo,
    double? pan,
  }) {
    return StemChannelState(
      name: name ?? this.name,
      color: color ?? this.color,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      isSolo: isSolo ?? this.isSolo,
      pan: pan ?? this.pan,
    );
  }
}

class StemMixerState {
  final bool isEnabled;
  final StemChannelState vocals;
  final StemChannelState drums;
  final StemChannelState bass;
  final StemChannelState melody;

  const StemMixerState({
    this.isEnabled = true,
    this.vocals = const StemChannelState(name: 'VOCALS', color: AppColors.ledCyan, volume: 0.85),
    this.drums = const StemChannelState(name: 'DRUMS', color: AppColors.kappogyYellow, volume: 0.90),
    this.bass = const StemChannelState(name: 'BASS', color: AppColors.kappogyRed, volume: 0.85),
    this.melody = const StemChannelState(name: 'MELODY', color: AppColors.ledPurple, volume: 0.80),
  });

  StemMixerState copyWith({
    bool? isEnabled,
    StemChannelState? vocals,
    StemChannelState? drums,
    StemChannelState? bass,
    StemChannelState? melody,
  }) {
    return StemMixerState(
      isEnabled: isEnabled ?? this.isEnabled,
      vocals: vocals ?? this.vocals,
      drums: drums ?? this.drums,
      bass: bass ?? this.bass,
      melody: melody ?? this.melody,
    );
  }
}

class StemMixerNotifier extends StateNotifier<StemMixerState> {
  StemMixerNotifier() : super(const StemMixerState());

  void toggleEnabled() => state = state.copyWith(isEnabled: !state.isEnabled);

  void setVolume(String stem, double vol) {
    if (stem == 'VOCALS') state = state.copyWith(vocals: state.vocals.copyWith(volume: vol));
    if (stem == 'DRUMS') state = state.copyWith(drums: state.drums.copyWith(volume: vol));
    if (stem == 'BASS') state = state.copyWith(bass: state.bass.copyWith(volume: vol));
    if (stem == 'MELODY') state = state.copyWith(melody: state.melody.copyWith(volume: vol));
  }

  void toggleMute(String stem) {
    if (stem == 'VOCALS') state = state.copyWith(vocals: state.vocals.copyWith(isMuted: !state.vocals.isMuted));
    if (stem == 'DRUMS') state = state.copyWith(drums: state.drums.copyWith(isMuted: !state.drums.isMuted));
    if (stem == 'BASS') state = state.copyWith(bass: state.bass.copyWith(isMuted: !state.bass.isMuted));
    if (stem == 'MELODY') state = state.copyWith(melody: state.melody.copyWith(isMuted: !state.melody.isMuted));
  }

  void toggleSolo(String stem) {
    if (stem == 'VOCALS') state = state.copyWith(vocals: state.vocals.copyWith(isSolo: !state.vocals.isSolo));
    if (stem == 'DRUMS') state = state.copyWith(drums: state.drums.copyWith(isSolo: !state.drums.isSolo));
    if (stem == 'BASS') state = state.copyWith(bass: state.bass.copyWith(isSolo: !state.bass.isSolo));
    if (stem == 'MELODY') state = state.copyWith(melody: state.melody.copyWith(isSolo: !state.melody.isSolo));
  }

  void resetAll() {
    state = const StemMixerState();
  }
}

final stemMixerProvider = StateNotifierProvider<StemMixerNotifier, StemMixerState>((ref) {
  return StemMixerNotifier();
});

class StemMixerSheet extends ConsumerWidget {
  const StemMixerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const StemMixerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(stemMixerProvider);
    final notifier = ref.read(stemMixerProvider.notifier);

    final stems = [state.vocals, state.drums, state.bass, state.melody];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(color: Colors.black87, blurRadius: 30, spreadRadius: 5, offset: Offset(0, -10)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
                  Icon(Icons.tune_rounded, color: AppColors.ledCyan, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '4-TRACK MULTI-STEM STUDIO MIXER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Row(
                children: [
                  Tooltip(
                    message: 'Reset all stem faders and solos',
                    child: SkeuoButton(
                      size: 32,
                      icon: Icons.refresh_rounded,
                      onPressed: notifier.resetAll,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Toggle Stem Engine Bypass',
                    child: SkeuoButton(
                      size: 32,
                      activeColor: AppColors.ledCyan,
                      isActive: state.isEnabled,
                      onPressed: notifier.toggleEnabled,
                      child: Icon(
                        Icons.power_settings_new_rounded,
                        size: 16,
                        color: state.isEnabled ? AppColors.ledCyan : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 4-Channel Stem Mixer Console
          SkeuoPanel(
            showCornerScrews: true,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stems.map((stem) {
                return _buildStemStrip(context, stem, state.isEnabled, notifier);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStemStrip(BuildContext context, StemChannelState stem, bool isEnabled, StemMixerNotifier notifier) {
    return Column(
      children: [
        // Channel Label & Status LED
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.panelSunken,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: stem.color.withValues(alpha: 0.6), width: 1.0),
          ),
          child: Text(
            stem.name,
            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: stem.color),
          ),
        ),
        const SizedBox(height: 10),

        // Mute & Solo Push Buttons
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SkeuoButton(
              size: 26,
              activeColor: AppColors.kappogyRed,
              isActive: stem.isMuted,
              onPressed: isEnabled ? () => notifier.toggleMute(stem.name) : null,
              child: const Text('M', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.kappogyRed)),
            ),
            const SizedBox(width: 4),
            SkeuoButton(
              size: 26,
              activeColor: AppColors.kappogyYellow,
              isActive: stem.isSolo,
              onPressed: isEnabled ? () => notifier.toggleSolo(stem.name) : null,
              child: const Text('S', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Channel Fader
        SkeuoFader(
          label: stem.isMuted ? 'MUTE' : '${((stem.volume - 1.0) * 24.0).toInt()}dB',
          value: stem.volume,
          min: 0.0,
          max: 1.0,
          height: 120.0,
          showScale: false,
          ledColor: stem.color,
          onChanged: isEnabled && !stem.isMuted ? (v) => notifier.setVolume(stem.name, v) : (_) {},
        ),
      ],
    );
  }
}
