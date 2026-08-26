import '../../audio_player/domain/track_model.dart';

class Album {
  final String name;
  final String artist;
  final int year;
  final String? artworkUri;
  final List<Track> tracks;

  const Album({
    required this.name,
    required this.artist,
    required this.year,
    this.artworkUri,
    this.tracks = const [],
  });

  int get trackCount => tracks.length;
  int get totalDurationMs => tracks.fold(0, (sum, t) => sum + t.durationMs);
}
