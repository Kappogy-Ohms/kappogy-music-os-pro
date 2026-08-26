import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_fader.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';
import '../domain/eq_preset_model.dart';
import 'analog_warmer_sheet.dart';
import 'cassette_deck_sheet.dart';
import 'crossfeed_processor_sheet.dart';
import 'eq_curve_visualizer.dart';
import 'equalizer_providers.dart';
import 'loudness_leveler_sheet.dart';
import 'parametric_peq_sheet.dart';
import 'spatial_audio_sheet.dart';

class EqualizerScreen extends ConsumerWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eqState = ref.watch(equalizerNotifierProvider);
    final notifier = ref.read(equalizerNotifierProvider.notifier);

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
          '10-BAND GRAPHIC EQUALIZER RACK',
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
            padding: const EdgeInsets.only(right: 12),
            child: SkeuoButton(
              size: 40,
              icon: Icons.power_settings_new_rounded,
              isActive: eqState.isEnabled,
              activeColor: AppColors.kappogyGreen,
              tooltip: eqState.isEnabled ? 'Bypass EQ' : 'Enable EQ',
              onPressed: () => notifier.toggleEnabled(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preset Selector Rocker Bar
              SkeuoPanel(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'STUDIO ACOUSTIC PROFILES',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SkeuoRockerSwitch<String>(
                        options: eqState.allPresets.map((p) {
                          return RockerOption<String>(
                            value: p.id,
                            label: p.name,
                          );
                        }).toList(),
                        selectedValue: eqState.currentPreset.id,
                        activeColor: AppColors.kappogyYellow,
                        onSelected: (id) {
                          final selected = eqState.allPresets.firstWhere((p) => p.id == id);
                          notifier.selectPreset(selected);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Master Processing Knobs (Preamp, Bass Boost, Treble, Stereo Widening)
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MASTER ANALOG STAGE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMuted,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Preamp Knob
                        SkeuoKnob(
                          value: eqState.currentPreset.preamp,
                          min: -12.0,
                          max: 12.0,
                          size: 76,
                          label: 'Preamp',
                          displayValue: '${eqState.currentPreset.preamp >= 0 ? "+" : ""}${eqState.currentPreset.preamp.toStringAsFixed(1)}dB',
                          ledColor: AppColors.kappogyRed,
                          onChanged: (v) => notifier.updatePreamp(v),
                        ),

                        // Bass Boost Knob
                        SkeuoKnob(
                          value: eqState.currentPreset.bassBoost,
                          min: 0.0,
                          max: 100.0,
                          size: 76,
                          label: 'Sub-Bass',
                          displayValue: '${eqState.currentPreset.bassBoost.round()}%',
                          ledColor: AppColors.kappogyYellow,
                          onChanged: (v) => notifier.updateBassBoost(v),
                        ),

                        // Treble Knob
                        SkeuoKnob(
                          value: eqState.currentPreset.treble,
                          min: -15.0,
                          max: 15.0,
                          size: 76,
                          label: 'Air Treble',
                          displayValue: '${eqState.currentPreset.treble >= 0 ? "+" : ""}${eqState.currentPreset.treble.toStringAsFixed(1)}dB',
                          ledColor: AppColors.ledCyan,
                          onChanged: (v) => notifier.updateTreble(v),
                        ),

                        // Stereo Widener Knob
                        SkeuoKnob(
                          value: eqState.currentPreset.stereoWiden,
                          min: 0.0,
                          max: 100.0,
                          size: 76,
                          label: 'Stereo',
                          displayValue: '${eqState.currentPreset.stereoWiden.round()}%',
                          ledColor: AppColors.ledPurple,
                          onChanged: (v) => notifier.updateStereoWiden(v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Real-Time Frequency Spline Curve Visualizer
              EqCurveVisualizer(
                gains: eqState.currentPreset.bands,
                height: 90,
              ),

              const SizedBox(height: 14),

              // 10-Band Graphic Channel Faders Rack
              SkeuoPanel(
                showCornerScrews: true,
                padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '10-BAND ISO FREQUENCY CHANNELS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          eqState.isEnabled ? 'ACTIVE [CALIBRATED]' : 'BYPASS',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: eqState.isEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Horizontal scrolling faders strip
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(10, (idx) {
                          final freq = EqPreset.bandFrequencies[idx];
                          final val = eqState.currentPreset.bands[idx];

                          // Tri-color mapping: Bands 0-2 (Bass: Red), Bands 3-6 (Mid: Yellow), Bands 7-9 (Treble: Green)
                          Color faderColor;
                          if (idx <= 2) {
                            faderColor = AppColors.kappogyRed;
                          } else if (idx <= 6) {
                            faderColor = AppColors.kappogyYellow;
                          } else {
                            faderColor = AppColors.kappogyGreen;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: SkeuoFader(
                              value: val,
                              min: -15.0,
                              max: 15.0,
                              label: freq,
                              height: 170,
                              width: 48,
                              ledColor: faderColor,
                              showScale: idx == 0,
                              onChanged: (newVal) => notifier.updateBand(idx, newVal),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Studio Dynamics (Limiter & Compressor)
              SkeuoPanel(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        SkeuoButton(
                          size: 38,
                          isCircular: false,
                          icon: Icons.shield_rounded,
                          isActive: eqState.limiterEnabled,
                          activeColor: AppColors.kappogyGreen,
                          onPressed: () => notifier.toggleLimiter(),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PEAK LIMITER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Prevents digital clipping',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        SkeuoButton(
                          size: 38,
                          isCircular: false,
                          icon: Icons.compress_rounded,
                          isActive: eqState.compressorEnabled,
                          activeColor: AppColors.ledCyan,
                          onPressed: () => notifier.toggleCompressor(),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'COMPRESSOR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Smooths dynamic range',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Crossfeed & Acoustic Room Launcher
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Tooltip(
                  message: 'Open Bauer Headphone Crossfeed & Virtual Room Acoustic Processor',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.panelRaised,
                      side: const BorderSide(color: AppColors.ledCyan, width: 1.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.headphones_rounded, color: AppColors.ledCyan, size: 18),
                    label: const Text(
                      'BAUER HEADPHONE CROSSFEED & ROOM PROCESSOR',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    onPressed: () => CrossfeedProcessorSheet.show(context),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: 'Open EBU R128 LUFS Loudness Leveler & ReplayGain auto-matcher',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.panelRaised,
                          side: const BorderSide(color: AppColors.kappogyGreen, width: 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.volume_up_rounded, color: AppColors.kappogyGreen, size: 16),
                        label: const Text(
                          'LUFS LEVELER',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        onPressed: () => LoudnessLevelerSheet.show(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Tooltip(
                      message: 'Open Vintage Vacuum Tube & Magnetic Tape Saturation Warmer',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.panelRaised,
                          side: const BorderSide(color: AppColors.kappogyYellow, width: 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.fireplace_rounded, color: AppColors.kappogyYellow, size: 16),
                        label: const Text(
                          'TUBE WARMER',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        onPressed: () => AnalogWarmerSheet.show(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: 'Open Binaural 3D Spatial Audio & Orbit Simulator',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.panelRaised,
                          side: const BorderSide(color: AppColors.ledPurple, width: 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.spatial_audio_off_rounded, color: AppColors.ledPurple, size: 16),
                        label: const Text(
                          '3D SPATIAL',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        onPressed: () => SpatialAudioSheet.show(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Tooltip(
                      message: 'Open Vintage Cassette Deck & Lo-Fi Tape Modulator',
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.panelRaised,
                          side: const BorderSide(color: AppColors.kappogyYellow, width: 1.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.album_rounded, color: AppColors.kappogyYellow, size: 16),
                        label: const Text(
                          'CASSETTE DECK',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        onPressed: () => CassetteDeckSheet.show(context),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // 5-Band Parametric PEQ
              SizedBox(
                width: double.infinity,
                height: 44,
                child: Tooltip(
                  message: 'Open 5-Band Continuous Parametric Equalizer (PEQ) with Bell Curves',
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.panelRaised,
                      side: const BorderSide(color: AppColors.kappogyGreen, width: 1.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.show_chart_rounded, color: AppColors.kappogyGreen, size: 18),
                    label: const Text(
                      '5-BAND CONTINUOUS PARAMETRIC EQ (PEQ)',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    onPressed: () => ParametricPeqSheet.show(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
