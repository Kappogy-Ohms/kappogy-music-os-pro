import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/harmonic_camelot_wheel.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../audio_player/presentation/audio_providers.dart';
import '../../library/presentation/library_providers.dart';
import '../data/audio_feature_estimator.dart';
import 'smart_rule_builder_dialog.dart';

class IntelligenceDashboard extends ConsumerWidget {
  const IntelligenceDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(libraryNotifierProvider).value ?? [];
    final playbackNotifier = ref.read(playbackStateProvider.notifier);

    final smartPlaylists = AudioFeatureEstimator.generateSmartPlaylists(library);
    final avgBpm = library.isNotEmpty
        ? library.fold(0.0, (sum, t) => sum + t.bpm) / library.length
        : 120.0;

    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: SkeuoButton(
          size: 40,
          isCircular: false,
          icon: Icons.arrow_back_rounded,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'OFFLINE MUSIC INTELLIGENCE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            shadows: SkeuoTokens.debossedText,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Analysis Summary Panel
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ON-DEVICE AUDIO HARMONICS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.panelSunken,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '100% LOCAL AI',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.kappogyGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatCard(
                          title: 'AVG TEMPO',
                          value: '${avgBpm.round()} BPM',
                          accent: AppColors.ledCyan,
                        ),
                        _StatCard(
                          title: 'ANALYZED',
                          value: '${library.length} TRACKS',
                          accent: AppColors.kappogyYellow,
                        ),
                        const _StatCard(
                          title: 'ENERGY',
                          value: 'HIGH DYNAMIC',
                          accent: AppColors.kappogyRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Interactive 24-Key Camelot Wheel Matrix
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'CAMELOT HARMONIC MIXING MATRIX',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.panelSunken,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('HARMONIC AI', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.ledCyan)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Center(
                      child: HarmonicCamelotWheel(
                        activeKey: '8A',
                        size: 260,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GENERATED SMART PLAYLISTS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  SkeuoButton(
                    size: 32,
                    isCircular: false,
                    icon: Icons.add_rounded,
                    activeColor: AppColors.kappogyGreen,
                    tooltip: 'Build Custom Rule',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const SmartRuleBuilderDialog(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Smart Playlists Cards
              ...smartPlaylists.entries.map((entry) {
                final title = entry.key;
                final tracks = entry.value;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.panelRaised,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle, width: 1.0),
                    boxShadow: SkeuoTokens.raisedMd,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.panelSunken,
                        boxShadow: SkeuoTokens.sunkenWell,
                      ),
                      child: const Center(
                        child: Text(
                          'Ω',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow),
                        ),
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      '${tracks.length} tracks • Dynamic Smart Rule',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                    trailing: SkeuoButton(
                      size: 40,
                      icon: Icons.play_arrow_rounded,
                      activeColor: AppColors.kappogyGreen,
                      onPressed: () {
                        if (tracks.isNotEmpty) {
                          playbackNotifier.playTrack(tracks.first, tracks);
                        }
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;

  const _StatCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.panelSunken,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
        boxShadow: SkeuoTokens.sunkenWell,
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
