import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/services/native_audio_bridge.dart';
import '../../../core/widgets/skeuo_panel.dart';
import 'audio_providers.dart';
import 'spectral_analyzer_dialog.dart';

class AudiophileDacSheet extends ConsumerStatefulWidget {
  const AudiophileDacSheet({super.key});

  @override
  ConsumerState<AudiophileDacSheet> createState() => _AudiophileDacSheetState();
}

class _AudiophileDacSheetState extends ConsumerState<AudiophileDacSheet> {
  NativeAudioDeviceInfo? _deviceInfo;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final info = await NativeAudioBridge.getDeviceInfo();
    if (mounted) {
      setState(() => _deviceInfo = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(playbackStateProvider).currentTrack;
    final isLossless = track?.codec == 'FLAC' || track?.codec == 'WAV' || track?.codec == 'ALAC';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.chassisBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: SkeuoTokens.raisedLg,
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.panelSunken,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: SkeuoTokens.sunkenWell,
                      ),
                      child: const Icon(Icons.album_rounded, color: AppColors.kappogyYellow, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'AUDIOPHILE DAC & STREAM STATS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Hi-Res Certification Badge Card
            SkeuoPanel(
              showCornerScrews: true,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.panelSunken,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isLossless ? AppColors.kappogyYellow : AppColors.ledCyan,
                        width: 1.5,
                      ),
                      boxShadow: SkeuoTokens.sunkenWell,
                    ),
                    child: Center(
                      child: Text(
                        isLossless ? 'HI-RES' : 'STD',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isLossless ? AppColors.kappogyYellow : AppColors.ledCyan,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLossless ? 'DIRECT BIT-PERFECT LOSSLESS' : 'HIGH-DEFINITION ENCODED AUDIO',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isLossless
                              ? 'Uncompressed studio master direct-to-DAC audio stream'
                              : 'Standard resolution stream with dynamic harmonic expansion',
                          style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Stream Technical Specifications Matrix
            Row(
              children: [
                _specCard('CODEC FORMAT', track?.codec ?? 'MP3', AppColors.ledCyan),
                const SizedBox(width: 8),
                _specCard('SAMPLE RATE', '${(track?.sampleRate ?? 44100) / 1000} kHz', AppColors.kappogyYellow),
                const SizedBox(width: 8),
                _specCard('BIT DEPTH', '${track?.bitDepth ?? 16}-bit', AppColors.kappogyGreen),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                _specCard('BITRATE', '${track?.bitrate ?? 320} kbps', AppColors.ledPurple),
                const SizedBox(width: 8),
                _specCard('DEVICE ROUTE', _deviceInfo?.currentRoute ?? 'Internal Speaker', AppColors.textPrimary),
              ],
            ),

            const SizedBox(height: 14),

            // Hardware Output Route Inspection
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.panelWell,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                boxShadow: SkeuoTokens.sunkenWell,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _deviceInfo?.isBluetoothConnected == true ? Icons.bluetooth_audio_rounded : Icons.headset_rounded,
                        size: 18,
                        color: AppColors.ledCyan,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _deviceInfo?.isBluetoothConnected == true ? 'Bluetooth A2DP Active' : 'Direct Audio Output',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.panelSunken,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('LOW LATENCY', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.kappogyGreen)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Spectral Analyzer Trigger Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: Tooltip(
                message: 'Inspect FFT frequency cutoff spectrum & verify genuine lossless studio master',
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.panelRaised,
                    side: const BorderSide(color: AppColors.ledCyan, width: 1.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.graphic_eq_rounded, color: AppColors.ledCyan, size: 18),
                  label: const Text(
                    'INSPECT FFT FREQUENCY CUTOFF (LOSSLESS ANALYZER)',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  onPressed: () {
                    if (track != null) {
                      SpectralAnalyzerDialog.show(context, track);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specCard(String label, String value, Color accent) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.panelRaised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle, width: 0.8),
          boxShadow: SkeuoTokens.raisedSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: accent, letterSpacing: -0.2),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
