import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../data/spectral_analyzer_service.dart';
import '../domain/track_model.dart';

class SpectralAnalyzerDialog extends StatefulWidget {
  final Track track;

  const SpectralAnalyzerDialog({super.key, required this.track});

  static void show(BuildContext context, Track track) {
    showDialog(
      context: context,
      builder: (_) => SpectralAnalyzerDialog(track: track),
    );
  }

  @override
  State<SpectralAnalyzerDialog> createState() => _SpectralAnalyzerDialogState();
}

class _SpectralAnalyzerDialogState extends State<SpectralAnalyzerDialog> {
  late SpectralAnalysisResult _result;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() async {
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() {
        _result = SpectralAnalyzerService.analyzeTrack(widget.track);
        _isScanning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 520,
        decoration: BoxDecoration(
          color: AppColors.chassisBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderSubtle, width: 1.2),
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 30, spreadRadius: 5),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header
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
                      child: const Icon(Icons.graphic_eq_rounded, color: AppColors.ledCyan, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TRUE LOSSLESS SPECTRAL ANALYZER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 0.8)),
                        Text(widget.track.title, style: const TextStyle(fontSize: 10.5, color: AppColors.kappogyYellow, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (_isScanning)
              Container(
                height: 180,
                alignment: Alignment.center,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.ledCyan, strokeWidth: 2.5),
                    SizedBox(height: 14),
                    Text('COMPUTING 20Hz–22kHz FFT SPECTROGRAM...', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 0.8)),
                  ],
                ),
              )
            else ...[
              // FFT Spectrum Spectrogram
              SkeuoPanel(
                showCornerScrews: false,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('FFT FREQUENCY CUTOFF SHELF (20Hz - 22.05kHz)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
                        Text(
                          'CUTOFF: ${_result.frequencyCutoffKhz.toStringAsFixed(1)} kHz',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: _result.isGenuine ? AppColors.kappogyGreen : AppColors.kappogyRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _result.spectrumFftBins.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final heightNorm = entry.value;
                          final freqKhz = (idx / 31.0) * 22.05;
                          final isOverCutoff = freqKhz > _result.frequencyCutoffKhz;

                          Color barColor;
                          if (isOverCutoff) {
                            barColor = AppColors.borderSubtle.withValues(alpha: 0.4);
                          } else if (freqKhz < 4.0) {
                            barColor = AppColors.kappogyRed;
                          } else if (freqKhz < 12.0) {
                            barColor = AppColors.kappogyYellow;
                          } else {
                            barColor = AppColors.kappogyGreen;
                          }

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1.0),
                              child: Container(
                                height: 120 * heightNorm,
                                decoration: BoxDecoration(
                                  color: barColor,
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                                  boxShadow: isOverCutoff
                                      ? null
                                      : [
                                          BoxShadow(
                                            color: barColor.withValues(alpha: 0.4),
                                            blurRadius: 3,
                                          ),
                                        ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Frequency scale labels
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('20Hz', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontFamily: 'monospace')),
                        Text('1kHz', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontFamily: 'monospace')),
                        Text('8kHz', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontFamily: 'monospace')),
                        Text('16kHz', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontFamily: 'monospace')),
                        Text('22.05kHz', style: TextStyle(fontSize: 8, color: AppColors.textMuted, fontFamily: 'monospace')),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Certification Badge & Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.panelWell,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _result.isGenuine ? AppColors.kappogyGreen.withValues(alpha: 0.6) : AppColors.kappogyRed.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _result.isGenuine ? Icons.verified_rounded : Icons.warning_amber_rounded,
                      color: _result.isGenuine ? AppColors.kappogyGreen : AppColors.kappogyRed,
                      size: 26,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _result.status.title,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                              color: _result.isGenuine ? AppColors.kappogyGreen : AppColors.kappogyRed,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _result.status.details,
                            style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Close / Re-Scan Action Button
              SizedBox(
                width: double.infinity,
                height: 42,
                child: SkeuoButton(
                  size: 42,
                  isCircular: false,
                  tooltip: 'Close spectral inspector',
                  activeColor: AppColors.ledCyan,
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Center(
                    child: Text('DONE / DISMISS INSPECTOR', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
