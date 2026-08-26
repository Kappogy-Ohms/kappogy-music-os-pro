import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';
import '../domain/drum_machine_model.dart';
import 'drum_machine_providers.dart';

class DrumMachineSheet extends ConsumerWidget {
  const DrumMachineSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const DrumMachineSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(drumMachineProvider);
    final notifier = ref.read(drumMachineProvider.notifier);

    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: SkeuoTokens.raisedLg,
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: Column(
        children: [
          // Header Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.grid_view_rounded, color: AppColors.kappogyRed, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'STUDIO 16-STEP BEAT SEQUENCER',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SkeuoButton(
                  size: 32,
                  icon: Icons.close_rounded,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transport & Controls Console
                  SkeuoPanel(
                    padding: const EdgeInsets.all(12),
                    showCornerScrews: true,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Play / Stop Transport Button
                            SkeuoButton(
                              size: 46,
                              isCircular: true,
                              icon: state.isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
                              isActive: state.isPlaying,
                              activeColor: AppColors.kappogyGreen,
                              tooltip: state.isPlaying ? 'Stop Sequencer' : 'Start Sequencer',
                              onPressed: notifier.togglePlay,
                            ),

                            // Tap Tempo Button
                            GestureDetector(
                              onTap: notifier.tapTempo,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.panelRaised,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                                  boxShadow: SkeuoTokens.raisedSm,
                                ),
                                child: Column(
                                  children: const [
                                    Icon(Icons.touch_app_rounded, color: AppColors.ledCyan, size: 16),
                                    SizedBox(height: 2),
                                    Text(
                                      'TAP TEMPO',
                                      style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w900, color: AppColors.ledCyan),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // BPM Rotary Knob
                            SkeuoKnob(
                              label: 'TEMPO (BPM)',
                              value: state.bpm,
                              min: 40.0,
                              max: 240.0,
                              size: 58,
                              ledColor: AppColors.kappogyRed,
                              onChanged: notifier.setBpm,
                              displayValue: '${state.bpm.toInt()} BPM',
                            ),

                            // Swing Groove Knob
                            SkeuoKnob(
                              label: 'SWING %',
                              value: state.swing,
                              min: 0.0,
                              max: 75.0,
                              size: 58,
                              ledColor: AppColors.kappogyYellow,
                              onChanged: notifier.setSwing,
                              displayValue: '${state.swing.toInt()}%',
                            ),

                            // Volume Level Knob
                            SkeuoKnob(
                              label: 'LEVEL',
                              value: state.volume,
                              min: 0.0,
                              max: 1.0,
                              size: 58,
                              ledColor: AppColors.ledCyan,
                              onChanged: notifier.setVolume,
                              displayValue: '${(state.volume * 100).toInt()}%',
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Kit Selector & Pattern Tabs
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Kit Selector Dropdown
                            DropdownButtonHideUnderline(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.panelSunken,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                                ),
                                child: DropdownButton<DrumKitType>(
                                  value: state.kit,
                                  dropdownColor: AppColors.panelRaised,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                                  icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.ledCyan, size: 16),
                                  items: DrumKitType.values.map((k) {
                                    return DropdownMenuItem(value: k, child: Text(k.label));
                                  }).toList(),
                                  onChanged: (k) {
                                    if (k != null) notifier.setKit(k);
                                  },
                                ),
                              ),
                            ),

                            // Pattern Bank Selector
                            SkeuoRockerSwitch<int>(
                              options: const [
                                RockerOption(label: 'PAT A', value: 0),
                                RockerOption(label: 'PAT B', value: 1),
                                RockerOption(label: 'PAT C', value: 2),
                                RockerOption(label: 'PAT D', value: 3),
                              ],
                              selectedValue: state.patterns.indexWhere((p) => p.id == state.activePattern.id).clamp(0, 3),
                              onSelected: notifier.selectPattern,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 16-Step Step Sequencer Matrix
                  SkeuoPanel(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // Top Step Running LED Bar
                        Row(
                          children: [
                            const SizedBox(width: 80), // Offset for instrument labels
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(16, (i) {
                                  final isCurrent = state.isPlaying && state.currentStep == i;
                                  final isBeatAccent = i % 4 == 0;
                                  return Container(
                                    width: 12,
                                    height: 12,
                                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrent
                                          ? AppColors.kappogyRed
                                          : (isBeatAccent ? AppColors.textSecondary : AppColors.panelSunken),
                                      boxShadow: isCurrent
                                          ? [
                                              BoxShadow(
                                                color: AppColors.kappogyRed.withValues(alpha: 0.8),
                                                blurRadius: 6,
                                              ),
                                            ]
                                          : null,
                                      border: Border.all(
                                        color: isCurrent ? Colors.white : Colors.white10,
                                        width: 0.6,
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Instrument Step Grid Rows
                        ...DrumSound.values.map((sound) {
                          final steps = state.activePattern.steps[sound] ?? List.generate(16, (_) => false);
                          final isMuted = state.mutedSounds.contains(sound);
                          final isSolo = state.soloSound == sound;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                // Left Instrument Label & Mute/Solo
                                Container(
                                  width: 78,
                                  height: 32,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.panelRaised,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: sound.color.withValues(alpha: 0.5), width: 0.8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          sound.shortCode,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                            color: sound.color,
                                          ),
                                          maxLines: 1,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => notifier.toggleMute(sound),
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: isMuted ? AppColors.kappogyRed : AppColors.panelWell,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'M',
                                              style: TextStyle(
                                                fontSize: 7,
                                                fontWeight: FontWeight.bold,
                                                color: isMuted ? Colors.white : AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      GestureDetector(
                                        onTap: () => notifier.toggleSolo(sound),
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: isSolo ? AppColors.kappogyYellow : AppColors.panelWell,
                                            borderRadius: BorderRadius.circular(2),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'S',
                                              style: TextStyle(
                                                fontSize: 7,
                                                fontWeight: FontWeight.bold,
                                                color: isSolo ? Colors.black : AppColors.textMuted,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 4),

                                // 16 Step Buttons
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(16, (stepIdx) {
                                      final isActive = steps[stepIdx];
                                      final isCurrent = state.isPlaying && state.currentStep == stepIdx;
                                      final isBeatGroup = (stepIdx ~/ 4) % 2 == 0;

                                      return GestureDetector(
                                        onTap: () => notifier.toggleStep(sound, stepIdx),
                                        child: Container(
                                          width: 13,
                                          height: 28,
                                          margin: const EdgeInsets.symmetric(horizontal: 1.0),
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? (isCurrent ? Colors.white : sound.color)
                                                : (isBeatGroup ? AppColors.panelRaised : const Color(0xFF1E2129)),
                                            borderRadius: BorderRadius.circular(3),
                                            boxShadow: isActive
                                                ? [
                                                    BoxShadow(
                                                      color: sound.color.withValues(alpha: 0.7),
                                                      blurRadius: 4,
                                                    ),
                                                  ]
                                                : null,
                                            border: Border.all(
                                              color: isCurrent ? AppColors.kappogyRed : Colors.white12,
                                              width: isCurrent ? 1.2 : 0.6,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      // Clear Pattern Button
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.panelRaised,
                              side: const BorderSide(color: AppColors.borderSubtle, width: 1.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.textMuted, size: 16),
                            label: const Text(
                              'CLEAR',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary),
                            ),
                            onPressed: notifier.clearPattern,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Export Beat Mixdown Button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 42,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.panelRaised,
                              side: const BorderSide(color: AppColors.kappogyRed, width: 1.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.save_rounded, color: AppColors.kappogyRed, size: 16),
                            label: const Text(
                              'BOUNCE BEAT TO LIBRARY',
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Bounced 16-Step Beat Pattern to local audio library!'),
                                  backgroundColor: AppColors.kappogyRed,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
