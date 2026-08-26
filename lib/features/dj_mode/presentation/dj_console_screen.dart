import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_vu_meter.dart';
import '../../audio_player/domain/track_model.dart';
import '../../library/presentation/library_providers.dart';
import 'automix_engine_sheet.dart';
import 'deck_widget.dart';
import 'dj_pro_screen.dart';
import 'dj_providers.dart';
import 'stem_mixer_sheet.dart';

class DjConsoleScreen extends ConsumerWidget {
  const DjConsoleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final djState = ref.watch(djConsoleNotifierProvider);
    final notifier = ref.read(djConsoleNotifierProvider.notifier);
    final allTracks = ref.watch(libraryNotifierProvider).value ?? [];

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
          'DUAL-DECK DJ MIXING CONSOLE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            color: AppColors.textSecondary,
            shadows: SkeuoTokens.debossedText,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: SkeuoButton(
              size: 36,
              isCircular: false,
              activeColor: AppColors.kappogyGreen,
              tooltip: '4-Track Multi-Stem Mixer',
              onPressed: () => StemMixerSheet.show(context),
              icon: Icons.tune_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: SkeuoButton(
              size: 36,
              isCircular: false,
              activeColor: AppColors.ledCyan,
              tooltip: 'DJ Automix & Continuous Radio',
              onPressed: () => AutomixEngineSheet.show(context),
              icon: Icons.auto_mode_rounded,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SkeuoButton(
              size: 36,
              isCircular: false,
              activeColor: AppColors.kappogyRed,
              tooltip: 'Switch to DJ Pro Studio',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DjProScreen()),
                );
              },
              child: const Text(
                'PRO',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.kappogyRed),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 850;

            final deckA = DeckWidget(
              deck: djState.deckA,
              accentColor: AppColors.ledCyan,
              onSelectTrack: () => _showTrackPicker(context, allTracks, (track) {
                notifier.loadTrackToDeck('DECK A', track);
              }),
              onTogglePlay: () => notifier.togglePlay('DECK A'),
              onCue: () => notifier.cue('DECK A'),
              onSync: () => notifier.syncBpm('DECK A'),
              onHotCue: (idx) => notifier.triggerHotCue('DECK A', idx),
              onPitchChanged: (pitch) => notifier.setPitch('DECK A', pitch),
              onSeek: (pos) => notifier.seek('DECK A', pos),
            );

            final deckB = DeckWidget(
              deck: djState.deckB,
              accentColor: AppColors.kappogyRed,
              onSelectTrack: () => _showTrackPicker(context, allTracks, (track) {
                notifier.loadTrackToDeck('DECK B', track);
              }),
              onTogglePlay: () => notifier.togglePlay('DECK B'),
              onCue: () => notifier.cue('DECK B'),
              onSync: () => notifier.syncBpm('DECK B'),
              onHotCue: (idx) => notifier.triggerHotCue('DECK B', idx),
              onPitchChanged: (pitch) => notifier.setPitch('DECK B', pitch),
              onSeek: (pos) => notifier.seek('DECK B', pos),
            );

            final centerMixer = SkeuoPanel(
              showCornerScrews: true,
              padding: const EdgeInsets.all(14.0),
              child: Column(
                children: [
                  // Dual VU Level Meters
                  Row(
                    children: [
                      Expanded(
                        child: SkeuoVUMeter(
                          isPlaying: djState.deckA.isPlaying,
                          level: djState.deckA.volume,
                          bands: 8,
                          height: 36,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SkeuoVUMeter(
                          isPlaying: djState.deckB.isPlaying,
                          level: djState.deckB.volume,
                          bands: 8,
                          height: 36,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Horizontal Crossfader Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DECK A',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ledCyan,
                        ),
                      ),
                      Text(
                        'CROSSFADER [${((djState.crossfaderPosition + 1) * 50).round()}%]',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMuted,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Text(
                        'DECK B',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.kappogyRed,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8.0,
                      activeTrackColor: AppColors.kappogyYellow,
                      inactiveTrackColor: AppColors.panelWell,
                      thumbColor: AppColors.textPrimary,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                    ),
                    child: Slider(
                      value: djState.crossfaderPosition,
                      min: -1.0,
                      max: 1.0,
                      onChanged: (pos) => notifier.setCrossfader(pos),
                    ),
                  ),
                ],
              ),
            );

            if (isWide) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: deckA),
                    const SizedBox(width: 14),
                    SizedBox(width: 320, child: centerMixer),
                    const SizedBox(width: 14),
                    Expanded(child: deckB),
                  ],
                ),
              );
            } else {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    deckA,
                    const SizedBox(height: 12),
                    centerMixer,
                    const SizedBox(height: 12),
                    deckB,
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  void _showTrackPicker(
    BuildContext context,
    List<Track> tracks,
    Function(Track) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.chassisBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SELECT TRACK FOR DECK',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: tracks.length,
                  itemBuilder: (ctx, idx) {
                    final track = tracks[idx];
                    return ListTile(
                      dense: true,
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.panelSunken,
                          boxShadow: SkeuoTokens.sunkenWell,
                        ),
                        child: const Center(
                          child: Text(
                            'Ω',
                            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.kappogyYellow),
                          ),
                        ),
                      ),
                      title: Text(
                        track.title,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      subtitle: Text(
                        '${track.artist} • ${track.bpm.round()} BPM',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                      trailing: Text(
                        track.musicalKey,
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.ledCyan),
                      ),
                      onTap: () {
                        onSelect(track);
                        Navigator.of(ctx).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
