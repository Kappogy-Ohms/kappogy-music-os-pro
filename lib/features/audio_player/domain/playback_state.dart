import 'track_model.dart';

enum PlaybackStatus { stopped, playing, paused, buffering, completed, error }
enum AudioRepeatMode { off, all, one }

class AppPlaybackState {
  final Track? currentTrack;
  final PlaybackStatus status;
  final Duration position;
  final Duration duration;
  final double volume; // 0.0 to 1.0
  final double speed; // 0.5 to 2.0
  final double pitch; // 0.5 to 1.5
  final bool isShuffle;
  final AudioRepeatMode repeatMode;
  final List<Track> queue;
  final int queueIndex;
  final String? errorMessage;

  const AppPlaybackState({
    this.currentTrack,
    this.status = PlaybackStatus.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 0.85,
    this.speed = 1.0,
    this.pitch = 1.0,
    this.isShuffle = false,
    this.repeatMode = AudioRepeatMode.off,
    this.queue = const [],
    this.queueIndex = 0,
    this.errorMessage,
  });

  bool get isPlaying => status == PlaybackStatus.playing;
  bool get hasTrack => currentTrack != null;
  double get progress => duration.inMilliseconds > 0
      ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
      : 0.0;

  AppPlaybackState copyWith({
    Track? currentTrack,
    PlaybackStatus? status,
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
    double? pitch,
    bool? isShuffle,
    AudioRepeatMode? repeatMode,
    List<Track>? queue,
    int? queueIndex,
    String? errorMessage,
  }) {
    return AppPlaybackState(
      currentTrack: currentTrack ?? this.currentTrack,
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      pitch: pitch ?? this.pitch,
      isShuffle: isShuffle ?? this.isShuffle,
      repeatMode: repeatMode ?? this.repeatMode,
      queue: queue ?? this.queue,
      queueIndex: queueIndex ?? this.queueIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
