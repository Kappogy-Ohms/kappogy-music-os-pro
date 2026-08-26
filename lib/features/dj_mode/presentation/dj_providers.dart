import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio_player/domain/track_model.dart';
import '../../../core/utils/audio_math.dart';
import '../domain/dj_deck_model.dart';

class DjConsoleState {
  final DjDeckState deckA;
  final DjDeckState deckB;
  final double crossfaderPosition; // -1.0 (Deck A) to 1.0 (Deck B)
  final String crossfaderCurve; // "equal_power", "linear", "cut"
  final double masterVolume;

  const DjConsoleState({
    required this.deckA,
    required this.deckB,
    this.crossfaderPosition = 0.0,
    this.crossfaderCurve = 'equal_power',
    this.masterVolume = 1.0,
  });

  (double gainA, double gainB) get deckGains {
    final gains = AudioMath.calculateCrossfader(crossfaderPosition, curve: crossfaderCurve);
    return (gains.$1 * deckA.volume * masterVolume, gains.$2 * deckB.volume * masterVolume);
  }

  DjConsoleState copyWith({
    DjDeckState? deckA,
    DjDeckState? deckB,
    double? crossfaderPosition,
    String? crossfaderCurve,
    double? masterVolume,
  }) {
    return DjConsoleState(
      deckA: deckA ?? this.deckA,
      deckB: deckB ?? this.deckB,
      crossfaderPosition: crossfaderPosition ?? this.crossfaderPosition,
      crossfaderCurve: crossfaderCurve ?? this.crossfaderCurve,
      masterVolume: masterVolume ?? this.masterVolume,
    );
  }
}

final djConsoleNotifierProvider =
    StateNotifierProvider<DjConsoleNotifier, DjConsoleState>((ref) {
  return DjConsoleNotifier();
});

class DjConsoleNotifier extends StateNotifier<DjConsoleState> {
  Timer? _playbackTicker;

  DjConsoleNotifier()
      : super(const DjConsoleState(
          deckA: DjDeckState(deckName: 'DECK A'),
          deckB: DjDeckState(deckName: 'DECK B'),
        )) {
    _startTicker();
  }

  void _startTicker() {
    _playbackTicker = Timer.periodic(const Duration(milliseconds: 100), (t) {
      bool needUpdate = false;
      DjDeckState newDeckA = state.deckA;
      DjDeckState newDeckB = state.deckB;

      if (state.deckA.isPlaying && state.deckA.loadedTrack != null) {
        final posMs = state.deckA.position.inMilliseconds + (100 * (1 + state.deckA.pitchPercent / 100.0)).toInt();
        if (posMs <= state.deckA.duration.inMilliseconds) {
          newDeckA = state.deckA.copyWith(position: Duration(milliseconds: posMs));
          needUpdate = true;
        } else {
          newDeckA = state.deckA.copyWith(isPlaying: false, position: Duration.zero);
          needUpdate = true;
        }
      }

      if (state.deckB.isPlaying && state.deckB.loadedTrack != null) {
        final posMs = state.deckB.position.inMilliseconds + (100 * (1 + state.deckB.pitchPercent / 100.0)).toInt();
        if (posMs <= state.deckB.duration.inMilliseconds) {
          newDeckB = state.deckB.copyWith(position: Duration(milliseconds: posMs));
          needUpdate = true;
        } else {
          newDeckB = state.deckB.copyWith(isPlaying: false, position: Duration.zero);
          needUpdate = true;
        }
      }

      if (needUpdate) {
        state = state.copyWith(deckA: newDeckA, deckB: newDeckB);
      }
    });
  }

  void loadTrackToDeck(String deckName, Track track) {
    final deck = DjDeckState(
      deckName: deckName,
      loadedTrack: track,
      duration: track.duration,
      position: Duration.zero,
      bpm: track.bpm,
      originalBpm: track.bpm,
      isPlaying: false,
    );

    if (deckName == 'DECK A') {
      state = state.copyWith(deckA: deck);
    } else {
      state = state.copyWith(deckB: deck);
    }
  }

  void togglePlay(String deckName) {
    if (deckName == 'DECK A') {
      state = state.copyWith(deckA: state.deckA.copyWith(isPlaying: !state.deckA.isPlaying));
    } else {
      state = state.copyWith(deckB: state.deckB.copyWith(isPlaying: !state.deckB.isPlaying));
    }
  }

  void cue(String deckName) {
    if (deckName == 'DECK A') {
      if (state.deckA.isPlaying) {
        state = state.copyWith(
          deckA: state.deckA.copyWith(
            isPlaying: false,
            position: state.deckA.mainCue ?? Duration.zero,
          ),
        );
      } else {
        state = state.copyWith(
          deckA: state.deckA.copyWith(mainCue: state.deckA.position),
        );
      }
    } else {
      if (state.deckB.isPlaying) {
        state = state.copyWith(
          deckB: state.deckB.copyWith(
            isPlaying: false,
            position: state.deckB.mainCue ?? Duration.zero,
          ),
        );
      } else {
        state = state.copyWith(
          deckB: state.deckB.copyWith(mainCue: state.deckB.position),
        );
      }
    }
  }

  void triggerHotCue(String deckName, int index) {
    if (index < 0 || index >= 4) return;
    if (deckName == 'DECK A') {
      final cues = List<Duration?>.from(state.deckA.hotCues);
      if (cues[index] == null) {
        cues[index] = state.deckA.position;
        state = state.copyWith(deckA: state.deckA.copyWith(hotCues: cues));
      } else {
        state = state.copyWith(deckA: state.deckA.copyWith(position: cues[index]!));
      }
    } else {
      final cues = List<Duration?>.from(state.deckB.hotCues);
      if (cues[index] == null) {
        cues[index] = state.deckB.position;
        state = state.copyWith(deckB: state.deckB.copyWith(hotCues: cues));
      } else {
        state = state.copyWith(deckB: state.deckB.copyWith(position: cues[index]!));
      }
    }
  }

  void syncBpm(String targetDeckName) {
    if (targetDeckName == 'DECK A' && state.deckB.loadedTrack != null) {
      final targetBpm = state.deckB.bpm;
      final original = state.deckA.originalBpm;
      final pitch = ((targetBpm - original) / original) * 100.0;
      state = state.copyWith(
        deckA: state.deckA.copyWith(bpm: targetBpm, pitchPercent: pitch),
      );
    } else if (targetDeckName == 'DECK B' && state.deckA.loadedTrack != null) {
      final targetBpm = state.deckA.bpm;
      final original = state.deckB.originalBpm;
      final pitch = ((targetBpm - original) / original) * 100.0;
      state = state.copyWith(
        deckB: state.deckB.copyWith(bpm: targetBpm, pitchPercent: pitch),
      );
    }
  }

  void setPitch(String deckName, double pitchPercent) {
    if (deckName == 'DECK A') {
      final newBpm = state.deckA.originalBpm * (1 + (pitchPercent / 100.0));
      state = state.copyWith(
        deckA: state.deckA.copyWith(pitchPercent: pitchPercent, bpm: newBpm),
      );
    } else {
      final newBpm = state.deckB.originalBpm * (1 + (pitchPercent / 100.0));
      state = state.copyWith(
        deckB: state.deckB.copyWith(pitchPercent: pitchPercent, bpm: newBpm),
      );
    }
  }

  void seek(String deckName, Duration position) {
    if (deckName == 'DECK A') {
      state = state.copyWith(deckA: state.deckA.copyWith(position: position));
    } else {
      state = state.copyWith(deckB: state.deckB.copyWith(position: position));
    }
  }

  void setCrossfader(double position) {
    state = state.copyWith(crossfaderPosition: position.clamp(-1.0, 1.0));
  }

  void setVolume(String deckName, double volume) {
    if (deckName == 'DECK A') {
      state = state.copyWith(deckA: state.deckA.copyWith(volume: volume.clamp(0.0, 1.0)));
    } else {
      state = state.copyWith(deckB: state.deckB.copyWith(volume: volume.clamp(0.0, 1.0)));
    }
  }

  @override
  void dispose() {
    _playbackTicker?.cancel();
    super.dispose();
  }
}
