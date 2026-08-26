import '../../audio_player/domain/track_model.dart';

class DjDeckState {
  final String deckName; // "DECK A" or "DECK B"
  final Track? loadedTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double bpm;
  final double originalBpm;
  final double pitchPercent; // -8.0% to +8.0% (or up to ±50%)
  final double volume; // 0.0 to 1.0
  final double highEq; // -12.0 to +12.0
  final double midEq;
  final double lowEq;
  final double filter; // -1.0 (Low-pass) to 1.0 (High-pass)
  final Duration? mainCue;
  final List<Duration?> hotCues; // 4 hot cues
  final double loopBeats; // 0.25, 0.5, 1, 2, 4, 8, 16
  final bool isLooping;
  final bool isKeyLocked;

  const DjDeckState({
    required this.deckName,
    this.loadedTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bpm = 120.0,
    this.originalBpm = 120.0,
    this.pitchPercent = 0.0,
    this.volume = 1.0,
    this.highEq = 0.0,
    this.midEq = 0.0,
    this.lowEq = 0.0,
    this.filter = 0.0,
    this.mainCue,
    this.hotCues = const [null, null, null, null],
    this.loopBeats = 4.0,
    this.isLooping = false,
    this.isKeyLocked = true,
  });

  double get progress => duration.inMilliseconds > 0
      ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
      : 0.0;

  DjDeckState copyWith({
    String? deckName,
    Track? loadedTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    double? bpm,
    double? originalBpm,
    double? pitchPercent,
    double? volume,
    double? highEq,
    double? midEq,
    double? lowEq,
    double? filter,
    Duration? mainCue,
    List<Duration?>? hotCues,
    double? loopBeats,
    bool? isLooping,
    bool? isKeyLocked,
  }) {
    return DjDeckState(
      deckName: deckName ?? this.deckName,
      loadedTrack: loadedTrack ?? this.loadedTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      bpm: bpm ?? this.bpm,
      originalBpm: originalBpm ?? this.originalBpm,
      pitchPercent: pitchPercent ?? this.pitchPercent,
      volume: volume ?? this.volume,
      highEq: highEq ?? this.highEq,
      midEq: midEq ?? this.midEq,
      lowEq: lowEq ?? this.lowEq,
      filter: filter ?? this.filter,
      mainCue: mainCue ?? this.mainCue,
      hotCues: hotCues ?? this.hotCues,
      loopBeats: loopBeats ?? this.loopBeats,
      isLooping: isLooping ?? this.isLooping,
      isKeyLocked: isKeyLocked ?? this.isKeyLocked,
    );
  }
}
