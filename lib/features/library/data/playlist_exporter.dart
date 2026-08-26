import '../domain/playlist_model.dart';
import '../../audio_player/domain/track_model.dart';

class PlaylistExporter {
  PlaylistExporter._();

  /// Generates a standard UTF-8 M3U8 string
  static String exportToM3u8({
    required Playlist playlist,
    required List<Track> tracks,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('#EXTM3U');
    buffer.writeln('#PLAYLIST:${playlist.title}');
    if (playlist.description.isNotEmpty) {
      buffer.writeln('#COMMENT:${playlist.description}');
    }

    for (final track in tracks) {
      final durationSec = track.duration.inSeconds;
      buffer.writeln('#EXTINF:$durationSec,${track.artist} - ${track.title}');
      buffer.writeln(track.uri);
    }

    return buffer.toString();
  }

  /// Parses an M3U / M3U8 string into a list of file paths
  static List<String> parseM3uPaths(String content) {
    final lines = content.split('\n');
    final paths = <String>[];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }
      paths.add(line);
    }

    return paths;
  }
}
