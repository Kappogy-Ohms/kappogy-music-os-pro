import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/skeuo_tokens.dart';
import '../../../core/services/intent_handler_service.dart';
import '../../../core/utils/duration_formatter.dart';
import '../../../core/widgets/skeuo_button.dart';
import '../../../core/widgets/skeuo_knob.dart';
import '../../../core/widgets/skeuo_panel.dart';
import '../../../core/widgets/skeuo_rocker.dart';
import '../../audio_player/domain/track_model.dart';
import '../../audio_player/presentation/audio_providers.dart';
import '../domain/studio_recording_model.dart';
import 'studio_recorder_providers.dart';

class StudioRecorderSheet extends ConsumerStatefulWidget {
  const StudioRecorderSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const StudioRecorderSheet(),
    );
  }

  @override
  ConsumerState<StudioRecorderSheet> createState() => _StudioRecorderSheetState();
}

class _StudioRecorderSheetState extends ConsumerState<StudioRecorderSheet> {
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(studioRecorderProvider);
    final notifier = ref.read(studioRecorderProvider.notifier);
    final playbackState = ref.watch(playbackStateProvider);
    final currentTrack = playbackState.currentTrack;

    final minutes = (state.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (state.elapsedSeconds % 60).toString().padLeft(2, '0');

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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
                    const Icon(Icons.mic_rounded, color: AppColors.kappogyRed, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'STUDIO 24-BIT RECORDER & OVERDUB LAB',
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
                  onPressed: () {
                    if (state.isRecording) {
                      notifier.cancelRecording();
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  // Dual Analog Needle VU Meter Panel
                  SkeuoPanel(
                    padding: const EdgeInsets.all(12),
                    showCornerScrews: true,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'LIVE ANALOG PREAMP VU METERS',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: state.isRecording ? AppColors.kappogyRed.withValues(alpha: 0.2) : AppColors.panelWell,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: state.isRecording ? AppColors.kappogyRed : AppColors.borderSubtle,
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: state.isRecording ? AppColors.kappogyRed : AppColors.textMuted,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    state.isRecording ? 'LIVE MIC ON' : 'STANDBY',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: state.isRecording ? AppColors.kappogyRed : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: _buildAnalogVuGauge('L - CHANNEL', state.vuMeterLeft)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildAnalogVuGauge('R - CHANNEL', state.vuMeterRight)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Elapsed LED Time Display & Overdub Backing Track Pill
                  SkeuoPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('RECORDING TIME (SMPTE)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
                            const SizedBox(height: 2),
                            Text(
                              '$minutes:$seconds.00',
                              style: TextStyle(
                                fontFamily: 'Courier',
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: state.isRecording ? AppColors.kappogyRed : AppColors.ledCyan,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ],
                        ),
                        if (currentTrack != null)
                          Container(
                            constraints: const BoxConstraints(maxWidth: 160),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.panelWell,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.layers_rounded, size: 12, color: state.overdubEnabled ? AppColors.kappogyGreen : AppColors.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      state.overdubEnabled ? 'BACKING TRACK' : 'PLAYER IDLE',
                                      style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w900,
                                        color: state.overdubEnabled ? AppColors.kappogyGreen : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentTrack.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Format Selector
                  SkeuoPanel(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('FORMAT:', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
                        Wrap(
                          spacing: 6,
                          children: RecordingFormat.values.map((f) {
                            final isSel = state.format == f;
                            return GestureDetector(
                              onTap: state.isRecording ? null : () => notifier.setFormat(f),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSel ? AppColors.ledCyan.withValues(alpha: 0.15) : AppColors.panelWell,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isSel ? AppColors.ledCyan : AppColors.borderSubtle,
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  f.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: isSel ? AppColors.ledCyan : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Preamp Gain & Studio Switchboard Rack
                  SkeuoPanel(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Tooltip(
                          message: 'Analog microphone preamp gain (+0dB to +24dB)',
                          child: SkeuoKnob(
                            label: 'PREAMP GAIN',
                            value: state.preampGain,
                            min: 0.0,
                            max: 24.0,
                            size: 65,
                            ledColor: AppColors.kappogyRed,
                            onChanged: notifier.setPreampGain,
                            displayValue: '+${state.preampGain.toStringAsFixed(1)}dB',
                          ),
                        ),
                        Column(
                          children: [
                            const Text('80Hz RUMBLE CUT', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            SkeuoRockerSwitch<bool>(
                              options: const [
                                RockerOption(label: 'OFF', value: false),
                                RockerOption(label: 'HPF 80Hz', value: true),
                              ],
                              selectedValue: state.rumbleFilter80Hz,
                              onSelected: (v) => notifier.toggleRumbleFilter(),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('VOCAL OVERDUB', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            SkeuoRockerSwitch<bool>(
                              options: const [
                                RockerOption(label: 'OFF', value: false),
                                RockerOption(label: 'OVERDUB', value: true),
                              ],
                              selectedValue: state.overdubEnabled,
                              onSelected: (v) => notifier.toggleOverdub(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Main Transport Buttons
                  Row(
                    children: [
                      // Record / Stop Main Button
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.isRecording ? AppColors.kappogyRed : AppColors.panelRaised,
                              side: BorderSide(
                                color: state.isRecording ? AppColors.kappogyRed : AppColors.borderSubtle,
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: Icon(
                              state.isRecording ? Icons.stop_rounded : Icons.fiber_manual_record_rounded,
                              color: state.isRecording ? Colors.white : AppColors.kappogyRed,
                              size: 22,
                            ),
                            label: Text(
                              state.isRecording ? 'STOP & SAVE TAKE' : 'START RECORDING',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: state.isRecording ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            onPressed: () {
                              if (state.isRecording) {
                                final saved = notifier.stopAndSaveRecording(backingTrackTitle: currentTrack?.title);
                                if (saved != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Saved "${saved.title}" (${saved.format.label})'),
                                      backgroundColor: AppColors.kappogyGreen,
                                    ),
                                  );
                                }
                              } else {
                                notifier.startRecording(backingTrackTitle: currentTrack?.title);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Pause Button
                      if (state.isRecording)
                        Expanded(
                          flex: 1,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.panelRaised,
                                side: BorderSide(
                                  color: state.isPaused ? AppColors.kappogyYellow : AppColors.borderSubtle,
                                  width: 1.0,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: notifier.togglePause,
                              child: Icon(
                                state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                color: state.isPaused ? AppColors.kappogyYellow : AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Recorded Takes History
                  if (state.recordings.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'SAVED RECORDINGS & OVERDUB TAKES',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.textSecondary, letterSpacing: 1.0),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.recordings.length,
                      itemBuilder: (ctx, idx) {
                        final rec = state.recordings[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.panelRaised,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                rec.isOverdub ? Icons.layers_rounded : Icons.mic_rounded,
                                color: rec.isOverdub ? AppColors.kappogyGreen : AppColors.ledCyan,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      rec.title,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                      maxLines: 1,
                                    ),
                                    Text(
                                      '${DurationFormatter.format(Duration(milliseconds: rec.durationMs))} • ${rec.format.ext.toUpperCase()} • ${(rec.fileSize / 1024).toStringAsFixed(1)} KB',
                                      style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_rounded, size: 16, color: AppColors.ledCyan),
                                tooltip: 'Share Audio Recording',
                                onPressed: () {
                                  final track = Track(
                                    id: rec.id,
                                    uri: rec.filePath,
                                    title: rec.title,
                                    artist: 'Kappogy Studio Recording',
                                    album: 'Studio Takes',
                                    durationMs: rec.durationMs,
                                    dateAdded: rec.timestamp,
                                    folder: 'Recordings',
                                    fileSize: rec.fileSize,
                                  );
                                  IntentHandlerService.shareAudioFile(track, context: context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalogVuGauge(String label, double db) {
    // -40dB to +4dB range mapped to angle -0.7 to +0.7 radians
    final clamped = db.clamp(-40.0, 4.0);
    final normalized = (clamped + 40.0) / 44.0; // 0.0 to 1.0
    final angle = -0.75 + (normalized * 1.5);

    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1914), // Warm incandescent vintage meter face
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
        boxShadow: SkeuoTokens.sunkenWell,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFFC4B89B))),
              Text(
                '${clamped > 0 ? '+' : ''}${clamped.toStringAsFixed(1)} dB',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: clamped > 0 ? AppColors.kappogyRed : const Color(0xFF00E5FF),
                ),
              ),
            ],
          ),
          // Scale ticks (-20, -10, -5, 0, +3)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text('-20', style: TextStyle(fontSize: 6.5, color: Color(0xFF8A826F))),
              Text('-10', style: TextStyle(fontSize: 6.5, color: Color(0xFF8A826F))),
              Text('-3', style: TextStyle(fontSize: 6.5, color: Color(0xFF8A826F))),
              Text('0', style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37))),
              Text('+3', style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.bold, color: Color(0xFFFF5252))),
            ],
          ),
          // Animated needle
          Transform.rotate(
            angle: angle,
            child: Container(
              width: 2,
              height: 24,
              decoration: BoxDecoration(
                color: clamped > 0 ? const Color(0xFFFF5252) : const Color(0xFF111111),
                borderRadius: BorderRadius.circular(1),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 1)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
