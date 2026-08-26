import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/drum_machine_model.dart';

class DrumMachineState {
  final bool isPlaying;
  final int currentStep; // 0 to 15
  final double bpm; // 40.0 to 240.0
  final double swing; // 0.0 to 75.0%
  final double volume; // 0.0 to 1.0
  final DrumKitType kit;
  final DrumPattern activePattern;
  final List<DrumPattern> patterns;
  final DrumSound? soloSound;
  final Set<DrumSound> mutedSounds;

  const DrumMachineState({
    this.isPlaying = false,
    this.currentStep = 0,
    this.bpm = 120.0,
    this.swing = 0.0,
    this.volume = 0.85,
    this.kit = DrumKitType.trap808,
    required this.activePattern,
    this.patterns = const [],
    this.soloSound,
    this.mutedSounds = const {},
  });

  DrumMachineState copyWith({
    bool? isPlaying,
    int? currentStep,
    double? bpm,
    double? swing,
    double? volume,
    DrumKitType? kit,
    DrumPattern? activePattern,
    List<DrumPattern>? patterns,
    DrumSound? soloSound,
    Set<DrumSound>? mutedSounds,
    bool clearSolo = false,
  }) {
    return DrumMachineState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentStep: currentStep ?? this.currentStep,
      bpm: bpm ?? this.bpm,
      swing: swing ?? this.swing,
      volume: volume ?? this.volume,
      kit: kit ?? this.kit,
      activePattern: activePattern ?? this.activePattern,
      patterns: patterns ?? this.patterns,
      soloSound: clearSolo ? null : (soloSound ?? this.soloSound),
      mutedSounds: mutedSounds ?? this.mutedSounds,
    );
  }
}

class DrumMachineNotifier extends StateNotifier<DrumMachineState> {
  Timer? _stepTimer;
  final List<DateTime> _tapTimes = [];

  DrumMachineNotifier()
      : super(
          DrumMachineState(
            activePattern: DrumPattern.defaultFourOnFloor(),
            patterns: [
              DrumPattern.defaultFourOnFloor(),
              DrumPattern.empty('pattern_2', 'Pattern B (User Beat)'),
              DrumPattern.empty('pattern_3', 'Pattern C (Syncopation)'),
              DrumPattern.empty('pattern_4', 'Pattern D (Breakdown)'),
            ],
          ),
        );

  @override
  void dispose() {
    _stepTimer?.cancel();
    super.dispose();
  }

  void togglePlay() {
    if (state.isPlaying) {
      stop();
    } else {
      start();
    }
  }

  void start() {
    _stepTimer?.cancel();
    state = state.copyWith(isPlaying: true, currentStep: 0);
    _scheduleNextStep();
  }

  void stop() {
    _stepTimer?.cancel();
    state = state.copyWith(isPlaying: false, currentStep: 0);
  }

  void _scheduleNextStep() {
    if (!state.isPlaying) return;

    // 16th note step duration in ms = (60,000 / BPM) / 4
    final baseStepMs = (60000.0 / state.bpm) / 4.0;
    // Apply swing on odd steps (1, 3, 5, 7...)
    final isOddStep = state.currentStep % 2 == 1;
    final swingOffset = isOddStep ? (baseStepMs * (state.swing / 100.0) * 0.5) : -(baseStepMs * (state.swing / 100.0) * 0.5);
    final durationMs = (baseStepMs + swingOffset).clamp(20.0, 500.0);

    _stepTimer = Timer(Duration(milliseconds: durationMs.toInt()), () {
      if (!state.isPlaying) return;
      final nextStep = (state.currentStep + 1) % 16;
      state = state.copyWith(currentStep: nextStep);
      _scheduleNextStep();
    });
  }

  void toggleStep(DrumSound sound, int stepIndex) {
    if (stepIndex < 0 || stepIndex >= 16) return;
    final map = Map<DrumSound, List<bool>>.from(state.activePattern.steps);
    final stepsList = List<bool>.from(map[sound] ?? List.generate(16, (_) => false));
    stepsList[stepIndex] = !stepsList[stepIndex];
    map[sound] = stepsList;

    final updatedPattern = state.activePattern.copyWith(steps: map);
    final patternIndex = state.patterns.indexWhere((p) => p.id == updatedPattern.id);
    final newPatterns = List<DrumPattern>.from(state.patterns);
    if (patternIndex != -1) {
      newPatterns[patternIndex] = updatedPattern;
    }

    state = state.copyWith(
      activePattern: updatedPattern,
      patterns: newPatterns,
    );
  }

  void setBpm(double newBpm) {
    state = state.copyWith(bpm: newBpm.clamp(40.0, 240.0));
  }

  void setSwing(double newSwing) {
    state = state.copyWith(swing: newSwing.clamp(0.0, 75.0));
  }

  void setVolume(double newVol) {
    state = state.copyWith(volume: newVol.clamp(0.0, 1.0));
  }

  void setKit(DrumKitType kit) {
    state = state.copyWith(kit: kit);
  }

  void selectPattern(int index) {
    if (index < 0 || index >= state.patterns.length) return;
    state = state.copyWith(activePattern: state.patterns[index]);
  }

  void clearPattern() {
    final emptyMap = <DrumSound, List<bool>>{};
    for (final sound in DrumSound.values) {
      emptyMap[sound] = List.generate(16, (_) => false);
    }
    final cleared = state.activePattern.copyWith(steps: emptyMap);
    final patternIndex = state.patterns.indexWhere((p) => p.id == cleared.id);
    final newPatterns = List<DrumPattern>.from(state.patterns);
    if (patternIndex != -1) {
      newPatterns[patternIndex] = cleared;
    }
    state = state.copyWith(activePattern: cleared, patterns: newPatterns);
  }

  void toggleMute(DrumSound sound) {
    final newMutes = Set<DrumSound>.from(state.mutedSounds);
    if (newMutes.contains(sound)) {
      newMutes.remove(sound);
    } else {
      newMutes.add(sound);
    }
    state = state.copyWith(mutedSounds: newMutes);
  }

  void toggleSolo(DrumSound sound) {
    if (state.soloSound == sound) {
      state = state.copyWith(clearSolo: true);
    } else {
      state = state.copyWith(soloSound: sound);
    }
  }

  void tapTempo() {
    final now = DateTime.now();
    _tapTimes.add(now);
    if (_tapTimes.length > 4) {
      _tapTimes.removeAt(0);
    }

    if (_tapTimes.length >= 2) {
      double totalDiffMs = 0;
      for (int i = 1; i < _tapTimes.length; i++) {
        totalDiffMs += _tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds;
      }
      final avgDiffMs = totalDiffMs / (_tapTimes.length - 1);
      if (avgDiffMs > 0) {
        final calcBpm = (60000.0 / avgDiffMs).clamp(40.0, 240.0);
        setBpm(calcBpm);
      }
    }
  }
}

final drumMachineProvider =
    StateNotifierProvider<DrumMachineNotifier, DrumMachineState>((ref) {
  return DrumMachineNotifier();
});
