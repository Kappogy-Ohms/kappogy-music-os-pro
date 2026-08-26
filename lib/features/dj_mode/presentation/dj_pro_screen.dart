import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_vu_meter.dart';
import '../../library/presentation/library_providers.dart';
import 'dj_providers.dart';
import 'studio_fx_rack.dart';

class DjProScreen extends ConsumerStatefulWidget {
  const DjProScreen({super.key});

  @override
  ConsumerState<DjProScreen> createState() => _DjProScreenState();
}

class _DjProScreenState extends ConsumerState<DjProScreen> {
  bool _showFxRack = false;
  int _deckAKeyShift = 0; // -12 to +12 semitones
  int _deckBKeyShift = 0;
  bool _deckAKeyLock = true;
  bool _deckBKeyLock = true;

  // Isolator EQ states (Deck A)
  double _deckAHi = 0.0; // -24 to +6 dB
  double _deckAMid = 0.0;
  double _deckALow = 0.0;
  bool _deckAHiKill = false;
  bool _deckAMidKill = false;
  bool _deckALowKill = false;

  // Isolator EQ states (Deck B)
  double _deckBHi = 0.0;
  double _deckBMid = 0.0;
  double _deckBLow = 0.0;
  bool _deckBHiKill = false;
  bool _deckBMidKill = false;
  bool _deckBLowKill = false;

  @override
  Widget build(BuildContext context) {
    final djState = ref.watch(djConsoleNotifierProvider);
    final notifier = ref.read(djConsoleNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.chassisBg,
      appBar: AppBar(
        backgroundColor: AppColors.chassisBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text(
              'DJ PRO STUDIO CONSOLE',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.kappogyRed,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('PRO', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
          ],
        ),
        actions: [
          SkeuoButton(
            size: 34,
            isCircular: false,
            icon: Icons.auto_fix_high_rounded,
            isActive: _showFxRack,
            activeColor: AppColors.ledCyan,
            tooltip: 'Toggle Studio FX Rack',
            onPressed: () => setState(() => _showFxRack = !_showFxRack),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              // Optional Expandable Studio FX Rack
              if (_showFxRack) ...[
                const StudioFxRack(),
                const SizedBox(height: 12),
              ],

              // Dual Decks in Pro Configuration
              _buildProDeck(
                deckName: 'DECK A',
                deck: djState.deckA,
                accentColor: AppColors.ledCyan,
                keyShift: _deckAKeyShift,
                keyLock: _deckAKeyLock,
                onKeyShiftChanged: (s) => setState(() => _deckAKeyShift = s),
                onKeyLockToggled: () => setState(() => _deckAKeyLock = !_deckAKeyLock),
                onSelectTrack: () => _showTrackSelectionSheet('DECK A'),
                onTogglePlay: () => notifier.togglePlay('DECK A'),
                onCue: () => notifier.cue('DECK A'),
                onSync: () => notifier.syncBpm('DECK A'),
                onHotCue: (i) => notifier.triggerHotCue('DECK A', i),
                onPitchNudge: (delta) => notifier.setPitch('DECK A', djState.deckA.pitchPercent + delta),
                hiVal: _deckAHi,
                midVal: _deckAMid,
                lowVal: _deckALow,
                hiKill: _deckAHiKill,
                midKill: _deckAMidKill,
                lowKill: _deckALowKill,
                onHiChanged: (v) => setState(() => _deckAHi = v),
                onMidChanged: (v) => setState(() => _deckAMid = v),
                onLowChanged: (v) => setState(() => _deckALow = v),
                onHiKillToggle: () => setState(() => _deckAHiKill = !_deckAHiKill),
                onMidKillToggle: () => setState(() => _deckAMidKill = !_deckAMidKill),
                onLowKillToggle: () => setState(() => _deckALowKill = !_deckALowKill),
              ),

              const SizedBox(height: 12),

              // Master Center Pro Crossfader & Dual VU Rack
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('DECK A', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.ledCyan)),
                        Text(
                          'CROSSFADER (${djState.crossfaderCurve.toUpperCase()})',
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                        ),
                        const Text('DECK B', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.kappogyRed)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Crossfader Horizontal Slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 8,
                        activeTrackColor: AppColors.kappogyYellow,
                        inactiveTrackColor: AppColors.panelSunken,
                        thumbColor: AppColors.textPrimary,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        value: djState.crossfaderPosition,
                        min: -1.0,
                        max: 1.0,
                        onChanged: (val) => notifier.setCrossfader(val),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Dual Deck Audio Level Spectrum
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SkeuoVUMeter(level: djState.deckA.isPlaying ? 0.85 : 0.05, height: 48, bands: 16),
                        SkeuoVUMeter(level: djState.deckB.isPlaying ? 0.85 : 0.05, height: 48, bands: 16),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              _buildProDeck(
                deckName: 'DECK B',
                deck: djState.deckB,
                accentColor: AppColors.kappogyRed,
                keyShift: _deckBKeyShift,
                keyLock: _deckBKeyLock,
                onKeyShiftChanged: (s) => setState(() => _deckBKeyShift = s),
                onKeyLockToggled: () => setState(() => _deckBKeyLock = !_deckBKeyLock),
                onSelectTrack: () => _showTrackSelectionSheet('DECK B'),
                onTogglePlay: () => notifier.togglePlay('DECK B'),
                onCue: () => notifier.cue('DECK B'),
                onSync: () => notifier.syncBpm('DECK B'),
                onHotCue: (i) => notifier.triggerHotCue('DECK B', i),
                onPitchNudge: (delta) => notifier.setPitch('DECK B', djState.deckB.pitchPercent + delta),
                hiVal: _deckBHi,
                midVal: _deckBMid,
                lowVal: _deckBLow,
                hiKill: _deckBHiKill,
                midKill: _deckBMidKill,
                lowKill: _deckBLowKill,
                onHiChanged: (v) => setState(() => _deckBHi = v),
                onMidChanged: (v) => setState(() => _deckBMid = v),
                onLowChanged: (v) => setState(() => _deckBLow = v),
                onHiKillToggle: () => setState(() => _deckBHiKill = !_deckBHiKill),
                onMidKillToggle: () => setState(() => _deckBMidKill = !_deckBMidKill),
                onLowKillToggle: () => setState(() => _deckBLowKill = !_deckBLowKill),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProDeck({
    required String deckName,
    required dynamic deck,
    required Color accentColor,
    required int keyShift,
    required bool keyLock,
    required ValueChanged<int> onKeyShiftChanged,
    required VoidCallback onKeyLockToggled,
    required VoidCallback onSelectTrack,
    required VoidCallback onTogglePlay,
    required VoidCallback onCue,
    required VoidCallback onSync,
    required Function(int) onHotCue,
    required Function(double) onPitchNudge,
    required double hiVal,
    required double midVal,
    required double lowVal,
    required bool hiKill,
    required bool midKill,
    required bool lowKill,
    required ValueChanged<double> onHiChanged,
    required ValueChanged<double> onMidChanged,
    required ValueChanged<double> onLowChanged,
    required VoidCallback onHiKillToggle,
    required VoidCallback onMidKillToggle,
    required VoidCallback onLowKillToggle,
  }) {
    return SkeuoPanel(
      showCornerScrews: true,
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.panelSunken,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1.2),
                    ),
                    child: Text(
                      deckName,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: accentColor, letterSpacing: 1.0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KEY: ${deck.loadedTrack != null ? deck.loadedTrack!.musicalKey : "—"} (${keyShift >= 0 ? "+$keyShift" : "$keyShift"}st)',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.kappogyYellow),
                  ),
                ],
              ),
              Row(
                children: [
                  SkeuoButton(
                    size: 30,
                    isCircular: false,
                    isActive: keyLock,
                    activeColor: AppColors.kappogyGreen,
                    onPressed: onKeyLockToggled,
                    child: const Text('KEY LOCK', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 6),
                  SkeuoButton(
                    size: 32,
                    isCircular: false,
                    icon: Icons.folder_open_rounded,
                    tooltip: 'Load Track',
                    onPressed: onSelectTrack,
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Track Title Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.panelWell,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            child: Text(
              deck.loadedTrack?.title ?? 'EMPTY DECK — TAP FOLDER TO LOAD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: deck.loadedTrack != null ? AppColors.textPrimary : AppColors.textMuted,
              ),
              maxLines: 1,
            ),
          ),

          const SizedBox(height: 10),

          // 3-Band Isolator EQ & Kill Switches Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildEqBand('HI', hiVal, hiKill, onHiChanged, onHiKillToggle),
              _buildEqBand('MID', midVal, midKill, onMidChanged, onMidKillToggle),
              _buildEqBand('LOW', lowVal, lowKill, onLowChanged, onLowKillToggle),
            ],
          ),

          const SizedBox(height: 10),

          // 8 Performance Pads Matrix (4 Cues + 4 Loops/Rolls)
          const Text('PERFORMANCE PADS (HOT CUE & AUTO LOOP)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.8,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            children: [
              _padButton('CUE 1', deck.hotCues[0] != null, AppColors.kappogyYellow, () => onHotCue(0)),
              _padButton('CUE 2', deck.hotCues[1] != null, AppColors.kappogyYellow, () => onHotCue(1)),
              _padButton('CUE 3', deck.hotCues[2] != null, AppColors.kappogyYellow, () => onHotCue(2)),
              _padButton('CUE 4', deck.hotCues[3] != null, AppColors.kappogyYellow, () => onHotCue(3)),
              _padButton('1/2 BEAT', false, AppColors.ledCyan, () {}),
              _padButton('1 BEAT', false, AppColors.ledCyan, () {}),
              _padButton('2 BEAT', false, AppColors.ledCyan, () {}),
              _padButton('4 BEAT', false, AppColors.ledCyan, () {}),
            ],
          ),

          const SizedBox(height: 10),

          // Transport & Pitch Bend Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SkeuoButton(
                    size: 36,
                    isCircular: false,
                    onPressed: () => onPitchNudge(-0.5),
                    child: const Text('- NUDGE', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 4),
                  SkeuoButton(
                    size: 36,
                    isCircular: false,
                    onPressed: () => onPitchNudge(0.5),
                    child: const Text('+ NUDGE', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),

              Row(
                children: [
                  SkeuoButton(
                    size: 42,
                    isCircular: false,
                    activeColor: AppColors.ledCyan,
                    onPressed: onSync,
                    child: const Text('SYNC', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 6),
                  SkeuoButton(
                    size: 42,
                    isCircular: false,
                    activeColor: AppColors.kappogyYellow,
                    onPressed: onCue,
                    child: const Text('CUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 6),
                  SkeuoButton(
                    size: 48,
                    icon: deck.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    isActive: deck.isPlaying,
                    activeColor: AppColors.kappogyGreen,
                    onPressed: onTogglePlay,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEqBand(String label, double val, bool isKilled, ValueChanged<double> onChanged, VoidCallback onKillToggle) {
    return Column(
      children: [
        SkeuoKnob(
          value: isKilled ? -24.0 : val,
          min: -24.0,
          max: 6.0,
          size: 60,
          label: label,
          displayValue: isKilled ? 'KILL' : '${val >= 0 ? "+" : ""}${val.round()}dB',
          ledColor: isKilled ? AppColors.kappogyRed : AppColors.ledCyan,
          onChanged: onChanged,
        ),
        const SizedBox(height: 4),
        SkeuoButton(
          size: 26,
          isCircular: false,
          isActive: isKilled,
          activeColor: AppColors.kappogyRed,
          onPressed: onKillToggle,
          child: Text('KILL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: isKilled ? AppColors.kappogyRed : AppColors.textMuted)),
        ),
      ],
    );
  }

  Widget _padButton(String label, bool isActive, Color color, VoidCallback onTap) {
    return SkeuoButton(
      size: 34,
      isCircular: false,
      isActive: isActive,
      activeColor: color,
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: isActive ? color : AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showTrackSelectionSheet(String deckTarget) {
    final libraryTracks = ref.read(libraryNotifierProvider).value ?? [];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.chassisBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => ListView.builder(
        itemCount: libraryTracks.length,
        itemBuilder: (context, idx) {
          final track = libraryTracks[idx];
          return ListTile(
            title: Text(track.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            subtitle: Text('${track.artist} • ${track.bpm} BPM', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            trailing: const Icon(Icons.add_rounded, color: AppColors.ledCyan),
            onTap: () {
              ref.read(djConsoleNotifierProvider.notifier).loadTrackToDeck(deckTarget, track);
              Navigator.of(ctx).pop();
            },
          );
        },
      ),
    );
  }
}
