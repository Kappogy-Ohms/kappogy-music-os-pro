import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/eq_preset_model.dart';

class EqualizerState {
  final bool isEnabled;
  final EqPreset currentPreset;
  final List<EqPreset> allPresets;
  final bool limiterEnabled;
  final bool compressorEnabled;

  const EqualizerState({
    this.isEnabled = true,
    required this.currentPreset,
    this.allPresets = const [],
    this.limiterEnabled = true,
    this.compressorEnabled = false,
  });

  EqualizerState copyWith({
    bool? isEnabled,
    EqPreset? currentPreset,
    List<EqPreset>? allPresets,
    bool? limiterEnabled,
    bool? compressorEnabled,
  }) {
    return EqualizerState(
      isEnabled: isEnabled ?? this.isEnabled,
      currentPreset: currentPreset ?? this.currentPreset,
      allPresets: allPresets ?? this.allPresets,
      limiterEnabled: limiterEnabled ?? this.limiterEnabled,
      compressorEnabled: compressorEnabled ?? this.compressorEnabled,
    );
  }
}

final equalizerNotifierProvider =
    StateNotifierProvider<EqualizerNotifier, EqualizerState>((ref) {
  return EqualizerNotifier();
});

class EqualizerNotifier extends StateNotifier<EqualizerState> {
  EqualizerNotifier()
      : super(EqualizerState(
          currentPreset: EqPreset.getDefaultPresets().first,
          allPresets: EqPreset.getDefaultPresets(),
        ));

  void toggleEnabled() {
    state = state.copyWith(isEnabled: !state.isEnabled);
  }

  void selectPreset(EqPreset preset) {
    state = state.copyWith(currentPreset: preset);
  }

  void updateBand(int bandIndex, double value) {
    final bands = List<double>.from(state.currentPreset.bands);
    if (bandIndex >= 0 && bandIndex < bands.length) {
      bands[bandIndex] = value.clamp(-15.0, 15.0);
      final updated = state.currentPreset.copyWith(
        bands: bands,
        isCustom: true,
        name: 'Custom Profile',
      );
      state = state.copyWith(currentPreset: updated);
    }
  }

  void setAllBands(List<double> newBands, {String? presetName}) {
    final updated = state.currentPreset.copyWith(
      bands: List<double>.from(newBands),
      isCustom: true,
      name: presetName ?? 'AutoEQ Calibrated',
    );
    state = state.copyWith(currentPreset: updated);
  }

  void updatePreamp(double value) {
    final updated = state.currentPreset.copyWith(preamp: value.clamp(-12.0, 12.0));
    state = state.copyWith(currentPreset: updated);
  }

  void updateBassBoost(double value) {
    final updated = state.currentPreset.copyWith(bassBoost: value.clamp(0.0, 100.0));
    state = state.copyWith(currentPreset: updated);
  }

  void updateTreble(double value) {
    final updated = state.currentPreset.copyWith(treble: value.clamp(-15.0, 15.0));
    state = state.copyWith(currentPreset: updated);
  }

  void updateStereoWiden(double value) {
    final updated = state.currentPreset.copyWith(stereoWiden: value.clamp(0.0, 100.0));
    state = state.copyWith(currentPreset: updated);
  }

  void toggleLimiter() {
    state = state.copyWith(limiterEnabled: !state.limiterEnabled);
  }

  void toggleCompressor() {
    state = state.copyWith(compressorEnabled: !state.compressorEnabled);
  }
}
