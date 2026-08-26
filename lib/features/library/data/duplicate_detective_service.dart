import '../../audio_player/domain/track_model.dart';

class DuplicateGroup {
  final String normalizedKey; // artist + title
  final List<Track> tracks;

  DuplicateGroup({required this.normalizedKey, required this.tracks});

  Track get bestQualityTrack {
    return tracks.reduce((a, b) {
      if (a.bitrate != b.bitrate) {
        return a.bitrate > b.bitrate ? a : b;
      }
      return a.fileSize > b.fileSize ? a : b;
    });
  }

  List<Track> get redundantTracks {
    final best = bestQualityTrack;
    return tracks.where((t) => t.id != best.id).toList();
  }
}

class DuplicateDetectiveService {
  DuplicateDetectiveService._();
  static final DuplicateDetectiveService instance = DuplicateDetectiveService._();

  List<DuplicateGroup> findDuplicates(List<Track> allTracks) {
    final map = <String, List<Track>>{};

    for (final track in allTracks) {
      final normArtist = track.artist.trim().toLowerCase();
      final normTitle = track.title.trim().toLowerCase();
      if (normTitle.isEmpty) continue;

      final key = '$normArtist - $normTitle';
      map.putIfAbsent(key, () => []).add(track);
    }

    final duplicates = <DuplicateGroup>[];
    for (final entry in map.entries) {
      if (entry.value.length > 1) {
        duplicates.add(DuplicateGroup(
          normalizedKey: entry.key,
          tracks: entry.value,
        ));
      }
    }

    return duplicates;
  }
}
