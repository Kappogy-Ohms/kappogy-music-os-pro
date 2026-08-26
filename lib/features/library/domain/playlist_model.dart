import '../../audio_player/domain/track_model.dart';

class Playlist {
  final String id;
  final String title;
  final String description;
  final bool isSmart;
  final String? smartRule; // e.g. "bpm > 120", "genre:Afrobeats", "rating >= 4"
  final int dateCreated;
  final List<Track> tracks;

  const Playlist({
    required this.id,
    required this.title,
    this.description = '',
    this.isSmart = false,
    this.smartRule,
    required this.dateCreated,
    this.tracks = const [],
  });

  int get trackCount => tracks.length;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_smart': isSmart ? 1 : 0,
      'smart_rule': smartRule,
      'date_created': dateCreated,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map, {List<Track> tracks = const []}) {
    return Playlist(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      isSmart: (map['is_smart'] as int? ?? 0) == 1,
      smartRule: map['smart_rule'] as String?,
      dateCreated: map['date_created'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      tracks: tracks,
    );
  }
}
