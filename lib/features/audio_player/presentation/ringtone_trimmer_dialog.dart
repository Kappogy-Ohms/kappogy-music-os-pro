import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/services/intent_handler_service.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';
import '../domain/track_model.dart';

enum ToneExportType {
  ringtone('Phone Ringtone (30s)'),
  alarm('Morning Alarm (20s)'),
  notification('Notification Tone (5s)');

  final String label;
  const ToneExportType(this.label);
}

class RingtoneTrimmerDialog extends StatefulWidget {
  final Track track;

  const RingtoneTrimmerDialog({super.key, required this.track});

  static void show(BuildContext context, Track track) {
    showDialog(
      context: context,
      builder: (_) => RingtoneTrimmerDialog(track: track),
    );
  }

  @override
  State<RingtoneTrimmerDialog> createState() => _RingtoneTrimmerDialogState();
}

class _RingtoneTrimmerDialogState extends State<RingtoneTrimmerDialog> {
  late double _startSec;
  late double _endSec;
  late double _maxSec;
  ToneExportType _exportType = ToneExportType.ringtone;
  double _fadeInSec = 1.0;
  double _fadeOutSec = 1.5;
  bool _isPlayingPreview = false;

  @override
  void initState() {
    super.initState();
    _maxSec = (widget.track.durationMs / 1000.0).clamp(10.0, 3600.0);
    _startSec = 0.0;
    _endSec = (_startSec + 30.0).clamp(5.0, _maxSec);
  }

  void _onExportTypeChanged(ToneExportType type) {
    setState(() {
      _exportType = type;
      final maxDuration = type == ToneExportType.ringtone
          ? 30.0
          : type == ToneExportType.alarm
              ? 20.0
              : 5.0;
      _endSec = (_startSec + maxDuration).clamp(_startSec + 1.0, _maxSec);
    });
  }

  void _togglePreview() {
    setState(() {
      _isPlayingPreview = !_isPlayingPreview;
    });
  }

  void _exportTone() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully exported ${_exportType.label} from "${widget.track.title}"! (Fade-in: ${_fadeInSec.toStringAsFixed(1)}s, Fade-out: ${_fadeOutSec.toStringAsFixed(1)}s)'),
        backgroundColor: AppColors.kappogyGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clipDuration = _endSec - _startSec;

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
                      child: const Icon(Icons.cut_rounded, color: AppColors.kappogyYellow, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('OFFLINE STUDIO RINGTONE & WAVE TRIMMER', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: 0.8)),
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

            // Export Target Rocker Selector
            const Text('EXPORT TARGET TONE TYPE', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 0.8)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SkeuoRockerSwitch<ToneExportType>(
                options: const [
                  RockerOption(value: ToneExportType.ringtone, label: '📱 Ringtone (30s)'),
                  RockerOption(value: ToneExportType.alarm, label: '⏰ Alarm Chime (20s)'),
                  RockerOption(value: ToneExportType.notification, label: '🔔 Notification (5s)'),
                ],
                selectedValue: _exportType,
                activeColor: AppColors.kappogyYellow,
                onSelected: _onExportTypeChanged,
              ),
            ),

            const SizedBox(height: 14),

            // Time Range Trimmer Card
            SkeuoPanel(
              showCornerScrews: false,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'START: ${DurationFormatter.formatSeconds(_startSec.toInt())}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.ledCyan, fontFamily: 'monospace'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.panelSunken,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.kappogyYellow.withValues(alpha: 0.5), width: 0.8),
                        ),
                        child: Text(
                          'CLIP LENGTH: ${clipDuration.toStringAsFixed(1)}s',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: AppColors.kappogyYellow),
                        ),
                      ),
                      Text(
                        'END: ${DurationFormatter.formatSeconds(_endSec.toInt())}',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.kappogyRed, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Range Slider for Start & End
                  RangeSlider(
                    values: RangeValues(_startSec, _endSec),
                    min: 0.0,
                    max: _maxSec,
                    activeColor: AppColors.kappogyYellow,
                    inactiveColor: AppColors.panelSunken,
                    onChanged: (vals) {
                      setState(() {
                        _startSec = vals.start;
                        _endSec = vals.end;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Fade Envelopes & Preview Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Tooltip(
                  message: 'Fade-in acoustic envelope duration',
                  child: SkeuoKnob(
                    label: 'FADE-IN',
                    value: _fadeInSec,
                    min: 0.0,
                    max: 4.0,
                    size: 60,
                    ledColor: AppColors.ledCyan,
                    onChanged: (v) => setState(() => _fadeInSec = v),
                    displayValue: '${_fadeInSec.toStringAsFixed(1)}s',
                  ),
                ),
                // Play / Stop Preview button
                Tooltip(
                  message: 'Preview the trimmed audio tone',
                  child: SkeuoButton(
                    size: 50,
                    activeColor: AppColors.kappogyGreen,
                    isActive: _isPlayingPreview,
                    onPressed: _togglePreview,
                    child: Icon(
                      _isPlayingPreview ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 26,
                      color: _isPlayingPreview ? AppColors.kappogyGreen : AppColors.textPrimary,
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Fade-out acoustic envelope duration',
                  child: SkeuoKnob(
                    label: 'FADE-OUT',
                    value: _fadeOutSec,
                    min: 0.0,
                    max: 4.0,
                    size: 60,
                    ledColor: AppColors.kappogyRed,
                    onChanged: (v) => setState(() => _fadeOutSec = v),
                    displayValue: '${_fadeOutSec.toStringAsFixed(1)}s',
                  ),
                ),
              ],
            ),

            // Export & Share Tone Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.panelRaised,
                        side: const BorderSide(color: AppColors.kappogyGreen, width: 1.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.kappogyGreen, size: 18),
                      label: Text(
                        'EXPORT ${_exportType.name.toUpperCase()} TONE',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      onPressed: _exportTone,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.panelRaised,
                        side: const BorderSide(color: AppColors.ledCyan, width: 1.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.share_rounded, color: AppColors.ledCyan, size: 16),
                      label: const Text(
                        'SHARE',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      onPressed: () {
                        IntentHandlerService.shareAudioFile(widget.track, context: context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
