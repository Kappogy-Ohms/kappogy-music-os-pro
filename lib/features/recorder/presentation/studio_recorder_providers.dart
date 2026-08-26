import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/studio_recording_model.dart';

class StudioRecorderState {
  final bool isRecording;
  final bool isPaused;
  final int elapsedSeconds;
  final double preampGain; // 0.0 to +24.0 dB
  final bool rumbleFilter80Hz;
  final bool monitoringEnabled;
  final bool overdubEnabled;
  final RecordingFormat format;
  final double vuMeterLeft; // -40.0 to +6.0 dB
  final double vuMeterRight; // -40.0 to +6.0 dB
  final List<StudioRecording> recordings;

  const StudioRecorderState({
    this.isRecording = false,
    this.isPaused = false,
    this.elapsedSeconds = 0,
    this.preampGain = 6.0,
    this.rumbleFilter80Hz = true,
    this.monitoringEnabled = true,
    this.overdubEnabled = false,
    this.format = RecordingFormat.losslessWav,
    this.vuMeterLeft = -40.0,
    this.vuMeterRight = -40.0,
    this.recordings = const [],
  });

  StudioRecorderState copyWith({
    bool? isRecording,
    bool? isPaused,
    int? elapsedSeconds,
    double? preampGain,
    bool? rumbleFilter80Hz,
    bool? monitoringEnabled,
    bool? overdubEnabled,
    RecordingFormat? format,
    double? vuMeterLeft,
    double? vuMeterRight,
    List<StudioRecording>? recordings,
  }) {
    return StudioRecorderState(
      isRecording: isRecording ?? this.isRecording,
      isPaused: isPaused ?? this.isPaused,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      preampGain: preampGain ?? this.preampGain,
      rumbleFilter80Hz: rumbleFilter80Hz ?? this.rumbleFilter80Hz,
      monitoringEnabled: monitoringEnabled ?? this.monitoringEnabled,
      overdubEnabled: overdubEnabled ?? this.overdubEnabled,
      format: format ?? this.format,
      vuMeterLeft: vuMeterLeft ?? this.vuMeterLeft,
      vuMeterRight: vuMeterRight ?? this.vuMeterRight,
      recordings: recordings ?? this.recordings,
    );
  }
}

class StudioRecorderNotifier extends StateNotifier<StudioRecorderState> {
  Timer? _timer;
  Timer? _vuTimer;
  final Random _random = Random();

  StudioRecorderNotifier() : super(const StudioRecorderState());

  void setPreampGain(double db) {
    state = state.copyWith(preampGain: db.clamp(0.0, 24.0));
  }

  void toggleRumbleFilter() {
    state = state.copyWith(rumbleFilter80Hz: !state.rumbleFilter80Hz);
  }

  void toggleMonitoring() {
    state = state.copyWith(monitoringEnabled: !state.monitoringEnabled);
  }

  void toggleOverdub() {
    state = state.copyWith(overdubEnabled: !state.overdubEnabled);
  }

  void setFormat(RecordingFormat format) {
    state = state.copyWith(format: format);
  }

  void startRecording({String? backingTrackTitle}) {
    state = state.copyWith(
      isRecording: true,
      isPaused: false,
      elapsedSeconds: 0,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.isRecording && !state.isPaused) {
        state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
      }
    });

    _vuTimer?.cancel();
    _vuTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (state.isRecording && !state.isPaused) {
        final base = -18.0 + (state.preampGain * 0.8);
        final left = (base + (_random.nextDouble() * 12.0) - 6.0).clamp(-40.0, 4.0);
        final right = (base + (_random.nextDouble() * 12.0) - 6.0).clamp(-40.0, 4.0);
        state = state.copyWith(vuMeterLeft: left, vuMeterRight: right);
      } else {
        state = state.copyWith(vuMeterLeft: -40.0, vuMeterRight: -40.0);
      }
    });
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  StudioRecording? stopAndSaveRecording({String? title, String? backingTrackTitle}) {
    if (!state.isRecording) return null;

    final duration = state.elapsedSeconds * 1000;
    final now = DateTime.now();
    final recTitle = title?.isNotEmpty == true
        ? title!
        : (state.overdubEnabled ? 'Vocal Overdub - ${now.hour}:${now.minute.toString().padLeft(2, '0')}' : 'Studio Take ${state.recordings.length + 1}');

    final newRec = StudioRecording(
      id: 'rec_${now.millisecondsSinceEpoch}',
      title: recTitle,
      filePath: '/storage/emulated/0/Music/KappogyStudio/$recTitle.${state.format.ext}',
      durationMs: duration > 0 ? duration : 1000,
      timestamp: now.millisecondsSinceEpoch,
      fileSize: (state.elapsedSeconds * state.format.sampleRate * 2 * (state.format.bitDepth ~/ 8)),
      format: state.format,
      isOverdub: state.overdubEnabled,
      backingTrackTitle: backingTrackTitle,
    );

    final updated = List<StudioRecording>.from(state.recordings)..insert(0, newRec);

    _timer?.cancel();
    _vuTimer?.cancel();

    state = state.copyWith(
      isRecording: false,
      isPaused: false,
      elapsedSeconds: 0,
      vuMeterLeft: -40.0,
      vuMeterRight: -40.0,
      recordings: updated,
    );

    return newRec;
  }

  void cancelRecording() {
    _timer?.cancel();
    _vuTimer?.cancel();
    state = state.copyWith(
      isRecording: false,
      isPaused: false,
      elapsedSeconds: 0,
      vuMeterLeft: -40.0,
      vuMeterRight: -40.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _vuTimer?.cancel();
    super.dispose();
  }
}

final studioRecorderProvider = StateNotifierProvider<StudioRecorderNotifier, StudioRecorderState>((ref) {
  return StudioRecorderNotifier();
});
