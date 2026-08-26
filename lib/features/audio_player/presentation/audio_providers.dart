import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/audio_player_service.dart';
import '../domain/playback_state.dart';
import '../domain/track_model.dart';
import '../../library/data/music_database.dart';

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final service = AudioPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

final playbackStateProvider =
    StateNotifierProvider<PlaybackNotifier, AppPlaybackState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  final db = MusicDatabase.instance;
  return PlaybackNotifier(service, db);
});

class PlaybackNotifier extends StateNotifier<AppPlaybackState> {
  final AudioPlayerService _service;
  final MusicDatabase _db;

  PlaybackNotifier(this._service, this._db) : super(_service.currentState) {
    _service.stateStream.listen((newState) {
      state = newState;
    });
  }

  Future<void> playTrack(Track track, List<Track> queue) async {
    final idx = queue.indexWhere((t) => t.id == track.id);
    await _service.loadQueue(queue, startIndex: idx >= 0 ? idx : 0, autoPlay: true);
    await _db.recordPlay(track.id, 0, false);
  }

  Future<void> togglePlayPause() async {
    await _service.togglePlayPause();
  }

  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  Future<void> next() async {
    await _service.next();
    if (state.currentTrack != null) {
      await _db.recordPlay(state.currentTrack!.id, 0, false);
    }
  }

  Future<void> previous() async {
    await _service.previous();
  }

  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
  }

  Future<void> setSpeed(double speed) async {
    await _service.setSpeed(speed);
  }

  Future<void> setPitch(double pitch) async {
    await _service.setPitch(pitch);
  }

  void toggleRepeat() {
    _service.toggleRepeat();
  }

  void toggleShuffle() {
    _service.toggleShuffle();
  }
}
