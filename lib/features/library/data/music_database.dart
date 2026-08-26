import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../audio_player/domain/track_model.dart';
import '../domain/playlist_model.dart';

class MusicDatabase {
  static final MusicDatabase instance = MusicDatabase._init();
  static Database? _database;

  MusicDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('kappogy_music_os.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    // Initialize FFI for Windows / Linux / macOS desktop testing
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Tracks Table
    await db.execute('''
      CREATE TABLE tracks (
        id TEXT PRIMARY KEY,
        uri TEXT NOT NULL,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        album_artist TEXT,
        genre TEXT,
        year INTEGER,
        track_number INTEGER,
        duration_ms INTEGER NOT NULL,
        codec TEXT,
        bitrate INTEGER,
        sample_rate INTEGER,
        bit_depth INTEGER,
        bpm REAL,
        musical_key TEXT,
        mood TEXT,
        energy REAL,
        artwork_uri TEXT,
        lyrics_path TEXT,
        rating INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 0,
        play_count INTEGER DEFAULT 0,
        skip_count INTEGER DEFAULT 0,
        last_played INTEGER,
        date_added INTEGER NOT NULL,
        folder TEXT,
        file_size INTEGER,
        is_demo INTEGER DEFAULT 0
      )
    ''');

    // Indexes for Instant Millisecond Search
    await db.execute('CREATE INDEX idx_tracks_title ON tracks(title);');
    await db.execute('CREATE INDEX idx_tracks_artist ON tracks(artist);');
    await db.execute('CREATE INDEX idx_tracks_album ON tracks(album);');
    await db.execute('CREATE INDEX idx_tracks_genre ON tracks(genre);');
    await db.execute('CREATE INDEX idx_tracks_bpm ON tracks(bpm);');
    await db.execute('CREATE INDEX idx_tracks_fav ON tracks(is_favorite);');

    // Playlists Table
    await db.execute('''
      CREATE TABLE playlists (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        is_smart INTEGER DEFAULT 0,
        smart_rule TEXT,
        date_created INTEGER NOT NULL
      )
    ''');

    // Playlist Tracks Table
    await db.execute('''
      CREATE TABLE playlist_tracks (
        playlist_id TEXT NOT NULL,
        track_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        PRIMARY KEY (playlist_id, track_id),
        FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (track_id) REFERENCES tracks(id) ON DELETE CASCADE
      )
    ''');

    // Listening History Table (For Offline Analytics)
    await db.execute('''
      CREATE TABLE listening_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        track_id TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        duration_played_ms INTEGER NOT NULL,
        completed INTEGER DEFAULT 0
      )
    ''');

    // EQ Presets Table
    await db.execute('''
      CREATE TABLE eq_presets (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        bands TEXT NOT NULL,
        preamp REAL DEFAULT 0.0,
        bass_boost REAL DEFAULT 0.0,
        stereo_widen REAL DEFAULT 0.0,
        is_custom INTEGER DEFAULT 1
      )
    ''');
  }

  // --- Track CRUD Operations ---

  Future<void> insertOrUpdateTrack(Track track) async {
    final db = await instance.database;
    await db.insert(
      'tracks',
      track.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertTracksBulk(List<Track> tracks) async {
    final db = await instance.database;
    final batch = db.batch();
    for (final track in tracks) {
      batch.insert(
        'tracks',
        track.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Track>> getAllTracks() async {
    final db = await instance.database;
    final result = await db.query('tracks', orderBy: 'title COLLATE NOCASE ASC');
    return result.map((m) => Track.fromMap(m)).toList();
  }

  Future<List<Track>> getFavoriteTracks() async {
    final db = await instance.database;
    final result = await db.query(
      'tracks',
      where: 'is_favorite = 1',
      orderBy: 'title COLLATE NOCASE ASC',
    );
    return result.map((m) => Track.fromMap(m)).toList();
  }

  Future<List<Track>> getRecentlyPlayedTracks({int limit = 30}) async {
    final db = await instance.database;
    final result = await db.query(
      'tracks',
      where: 'last_played IS NOT NULL AND last_played > 0',
      orderBy: 'last_played DESC',
      limit: limit,
    );
    return result.map((m) => Track.fromMap(m)).toList();
  }

  Future<List<Track>> getMostPlayedTracks({int limit = 30}) async {
    final db = await instance.database;
    final result = await db.query(
      'tracks',
      where: 'play_count > 0',
      orderBy: 'play_count DESC',
      limit: limit,
    );
    return result.map((m) => Track.fromMap(m)).toList();
  }

  Future<void> setFavorite(String trackId, bool isFavorite) async {
    final db = await instance.database;
    await db.update(
      'tracks',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  Future<void> setRating(String trackId, int rating) async {
    final db = await instance.database;
    await db.update(
      'tracks',
      {'rating': rating.clamp(0, 5)},
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  Future<void> recordPlay(String trackId, int durationPlayedMs, bool completed) async {
    final db = await instance.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.rawUpdate('''
      UPDATE tracks 
      SET play_count = play_count + 1, last_played = ?
      WHERE id = ?
    ''', [now, trackId]);

    await db.insert('listening_history', {
      'track_id': trackId,
      'timestamp': now,
      'duration_played_ms': durationPlayedMs,
      'completed': completed ? 1 : 0,
    });
  }

  Future<void> recordSkip(String trackId) async {
    final db = await instance.database;
    await db.rawUpdate('''
      UPDATE tracks 
      SET skip_count = skip_count + 1
      WHERE id = ?
    ''', [trackId]);
  }

  Future<void> updateMetadata(String trackId, Map<String, dynamic> fields) async {
    final db = await instance.database;
    await db.update(
      'tracks',
      fields,
      where: 'id = ?',
      whereArgs: [trackId],
    );
  }

  // --- Search ---

  Future<List<Track>> searchTracks(String query) async {
    final db = await instance.database;
    final clean = query.trim();
    if (clean.isEmpty) return getAllTracks();

    // Natural query parsing or direct wildcard
    if (clean.startsWith('artist:')) {
      final val = clean.replaceFirst('artist:', '').trim();
      final res = await db.query('tracks', where: 'artist LIKE ?', whereArgs: ['%$val%']);
      return res.map((m) => Track.fromMap(m)).toList();
    } else if (clean.startsWith('genre:')) {
      final val = clean.replaceFirst('genre:', '').trim();
      final res = await db.query('tracks', where: 'genre LIKE ?', whereArgs: ['%$val%']);
      return res.map((m) => Track.fromMap(m)).toList();
    } else if (clean.startsWith('bpm:')) {
      final val = clean.replaceFirst('bpm:', '').trim();
      if (val.contains('-')) {
        final parts = val.split('-');
        final minBpm = double.tryParse(parts[0]) ?? 0;
        final maxBpm = double.tryParse(parts[1]) ?? 250;
        final res = await db.query('tracks', where: 'bpm >= ? AND bpm <= ?', whereArgs: [minBpm, maxBpm]);
        return res.map((m) => Track.fromMap(m)).toList();
      }
    }

    final wild = '%$clean%';
    final result = await db.query(
      'tracks',
      where: 'title LIKE ? OR artist LIKE ? OR album LIKE ? OR genre LIKE ?',
      whereArgs: [wild, wild, wild, wild],
      orderBy: 'title COLLATE NOCASE ASC',
    );
    return result.map((m) => Track.fromMap(m)).toList();
  }

  // --- Playlists ---

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await instance.database;
    final res = await db.query('playlists', orderBy: 'date_created DESC');
    final List<Playlist> list = [];

    for (final m in res) {
      final playlistId = m['id'] as String;
      final tracksRes = await db.rawQuery('''
        SELECT t.* FROM tracks t
        INNER JOIN playlist_tracks pt ON t.id = pt.track_id
        WHERE pt.playlist_id = ?
        ORDER BY pt.position ASC
      ''', [playlistId]);
      final tracks = tracksRes.map((t) => Track.fromMap(t)).toList();
      list.add(Playlist.fromMap(m, tracks: tracks));
    }
    return list;
  }

  Future<void> createPlaylist(Playlist playlist) async {
    final db = await instance.database;
    await db.insert('playlists', playlist.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    final db = await instance.database;
    final maxPosRes = await db.rawQuery(
      'SELECT MAX(position) as max_pos FROM playlist_tracks WHERE playlist_id = ?',
      [playlistId],
    );
    final nextPos = (maxPosRes.first['max_pos'] as int? ?? 0) + 1;

    await db.insert(
      'playlist_tracks',
      {
        'playlist_id': playlistId,
        'track_id': trackId,
        'position': nextPos,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // --- Export Database for 100% Offline Backup ---

  Future<Map<String, dynamic>> exportFullBackup() async {
    final db = await instance.database;
    final tracks = await db.query('tracks');
    final playlists = await db.query('playlists');
    final playlistTracks = await db.query('playlist_tracks');
    final history = await db.query('listening_history');
    final eqPresets = await db.query('eq_presets');

    return {
      'version': '1.0',
      'app': 'Kappogy Music OS Pro',
      'exported_at': DateTime.now().toIso8601String(),
      'tracks': tracks,
      'playlists': playlists,
      'playlist_tracks': playlistTracks,
      'history': history,
      'eq_presets': eqPresets,
    };
  }

  Future<void> restoreBackup(Map<String, dynamic> backup) async {
    final db = await instance.database;
    final batch = db.batch();

    if (backup['tracks'] is List) {
      for (final t in backup['tracks']) {
        batch.insert('tracks', Map<String, dynamic>.from(t), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    if (backup['playlists'] is List) {
      for (final p in backup['playlists']) {
        batch.insert('playlists', Map<String, dynamic>.from(p), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    if (backup['playlist_tracks'] is List) {
      for (final pt in backup['playlist_tracks']) {
        batch.insert('playlist_tracks', Map<String, dynamic>.from(pt), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }
    await batch.commit(noResult: true);
  }
}
