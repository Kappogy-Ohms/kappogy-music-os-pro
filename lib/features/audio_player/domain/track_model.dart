class Track {
  final String id;
  final String uri;
  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final String genre;
  final int year;
  final int trackNumber;
  final int durationMs;
  final String codec;
  final int bitrate; // in kbps
  final int sampleRate; // in Hz
  final int bitDepth;
  final double bpm;
  final String musicalKey;
  final String mood;
  final double energy; // 0.0 to 1.0
  final String? artworkUri;
  final String? lyricsPath;
  final int rating; // 0 to 5
  final bool isFavorite;
  final int playCount;
  final int skipCount;
  final int? lastPlayed;
  final int dateAdded;
  final String folder;
  final int fileSize;
  final bool isDemo;

  const Track({
    required this.id,
    required this.uri,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtist = '',
    this.genre = 'Unknown',
    this.year = 2026,
    this.trackNumber = 1,
    required this.durationMs,
    this.codec = 'MP3',
    this.bitrate = 320,
    this.sampleRate = 44100,
    this.bitDepth = 16,
    this.bpm = 120.0,
    this.musicalKey = 'C',
    this.mood = 'Energetic',
    this.energy = 0.75,
    this.artworkUri,
    this.lyricsPath,
    this.rating = 0,
    this.isFavorite = false,
    this.playCount = 0,
    this.skipCount = 0,
    this.lastPlayed,
    required this.dateAdded,
    required this.folder,
    required this.fileSize,
    this.isDemo = false,
  });

  Duration get duration => Duration(milliseconds: durationMs);

  Track copyWith({
    String? id,
    String? uri,
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    String? genre,
    int? year,
    int? trackNumber,
    int? durationMs,
    String? codec,
    int? bitrate,
    int? sampleRate,
    int? bitDepth,
    double? bpm,
    String? musicalKey,
    String? mood,
    double? energy,
    String? artworkUri,
    String? lyricsPath,
    int? rating,
    bool? isFavorite,
    int? playCount,
    int? skipCount,
    int? lastPlayed,
    int? dateAdded,
    String? folder,
    int? fileSize,
    bool? isDemo,
  }) {
    return Track(
      id: id ?? this.id,
      uri: uri ?? this.uri,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      durationMs: durationMs ?? this.durationMs,
      codec: codec ?? this.codec,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      bitDepth: bitDepth ?? this.bitDepth,
      bpm: bpm ?? this.bpm,
      musicalKey: musicalKey ?? this.musicalKey,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      artworkUri: artworkUri ?? this.artworkUri,
      lyricsPath: lyricsPath ?? this.lyricsPath,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      skipCount: skipCount ?? this.skipCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      dateAdded: dateAdded ?? this.dateAdded,
      folder: folder ?? this.folder,
      fileSize: fileSize ?? this.fileSize,
      isDemo: isDemo ?? this.isDemo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uri': uri,
      'title': title,
      'artist': artist,
      'album': album,
      'album_artist': albumArtist,
      'genre': genre,
      'year': year,
      'track_number': trackNumber,
      'duration_ms': durationMs,
      'codec': codec,
      'bitrate': bitrate,
      'sample_rate': sampleRate,
      'bit_depth': bitDepth,
      'bpm': bpm,
      'musical_key': musicalKey,
      'mood': mood,
      'energy': energy,
      'artwork_uri': artworkUri,
      'lyrics_path': lyricsPath,
      'rating': rating,
      'is_favorite': isFavorite ? 1 : 0,
      'play_count': playCount,
      'skip_count': skipCount,
      'last_played': lastPlayed,
      'date_added': dateAdded,
      'folder': folder,
      'file_size': fileSize,
      'is_demo': isDemo ? 1 : 0,
    };
  }

  factory Track.fromMap(Map<String, dynamic> map) {
    return Track(
      id: map['id'] as String,
      uri: map['uri'] as String,
      title: map['title'] as String? ?? 'Unknown Title',
      artist: map['artist'] as String? ?? 'Unknown Artist',
      album: map['album'] as String? ?? 'Unknown Album',
      albumArtist: map['album_artist'] as String? ?? '',
      genre: map['genre'] as String? ?? 'Other',
      year: map['year'] as int? ?? 2026,
      trackNumber: map['track_number'] as int? ?? 1,
      durationMs: map['duration_ms'] as int? ?? 180000,
      codec: map['codec'] as String? ?? 'MP3',
      bitrate: map['bitrate'] as int? ?? 320,
      sampleRate: map['sample_rate'] as int? ?? 44100,
      bitDepth: map['bit_depth'] as int? ?? 16,
      bpm: (map['bpm'] as num?)?.toDouble() ?? 120.0,
      musicalKey: map['musical_key'] as String? ?? 'C',
      mood: map['mood'] as String? ?? 'Energetic',
      energy: (map['energy'] as num?)?.toDouble() ?? 0.7,
      artworkUri: map['artwork_uri'] as String?,
      lyricsPath: map['lyrics_path'] as String?,
      rating: map['rating'] as int? ?? 0,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      playCount: map['play_count'] as int? ?? 0,
      skipCount: map['skip_count'] as int? ?? 0,
      lastPlayed: map['last_played'] as int?,
      dateAdded: map['date_added'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      folder: map['folder'] as String? ?? '',
      fileSize: map['file_size'] as int? ?? 0,
      isDemo: (map['is_demo'] as int? ?? 0) == 1,
    );
  }
}
