import '../../audio_player/domain/track_model.dart';

class Artist {
  final String name;
  final List<Track> tracks;
  final Set<String> albums;

  const Artist({
    required this.name,
    this.tracks = const [],
    this.albums = const {},
  });

  int get trackCount => tracks.length;
  int get albumCount => albums.length;
}
