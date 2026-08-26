import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio_player/domain/track_model.dart';
import '../domain/album_model.dart';
import '../domain/artist_model.dart';
import '../domain/playlist_model.dart';
import '../data/music_database.dart';
import '../data/local_indexer_service.dart';

final musicDatabaseProvider = Provider<MusicDatabase>((ref) {
  return MusicDatabase.instance;
});

final localIndexerProvider = Provider<LocalIndexerService>((ref) {
  final db = ref.watch(musicDatabaseProvider);
  return LocalIndexerService(db: db);
});

// Main Track Library State Notifier
final libraryNotifierProvider =
    StateNotifierProvider<LibraryNotifier, AsyncValue<List<Track>>>((ref) {
  final db = ref.watch(musicDatabaseProvider);
  final indexer = ref.watch(localIndexerProvider);
  return LibraryNotifier(db, indexer);
});

class LibraryNotifier extends StateNotifier<AsyncValue<List<Track>>> {
  final MusicDatabase _db;
  final LocalIndexerService _indexer;

  LibraryNotifier(this._db, this._indexer) : super(const AsyncValue.loading()) {
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    state = const AsyncValue.loading();
    try {
      await _indexer.ensureInitialized();
      final tracks = await _db.getAllTracks();
      state = AsyncValue.data(tracks);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String trackId) async {
    final current = state.value ?? [];
    final idx = current.indexWhere((t) => t.id == trackId);
    if (idx != -1) {
      final updatedTrack = current[idx].copyWith(isFavorite: !current[idx].isFavorite);
      final updatedList = List<Track>.from(current);
      updatedList[idx] = updatedTrack;
      state = AsyncValue.data(updatedList);
      await _db.setFavorite(trackId, updatedTrack.isFavorite);
    }
  }

  Future<void> setRating(String trackId, int rating) async {
    final current = state.value ?? [];
    final idx = current.indexWhere((t) => t.id == trackId);
    if (idx != -1) {
      final updatedTrack = current[idx].copyWith(rating: rating);
      final updatedList = List<Track>.from(current);
      updatedList[idx] = updatedTrack;
      state = AsyncValue.data(updatedList);
      await _db.setRating(trackId, rating);
    }
  }

  Future<void> scanDirectory(
    String path, {
    Function(double progress, String currentFile)? onProgress,
  }) async {
    await _indexer.scanDirectory(path, onProgress: onProgress);
    await loadLibrary();
  }
}

// Derived Filter Providers
final favoriteTracksProvider = Provider<List<Track>>((ref) {
  final library = ref.watch(libraryNotifierProvider).value ?? [];
  return library.where((t) => t.isFavorite).toList();
});

final albumsProvider = Provider<List<Album>>((ref) {
  final library = ref.watch(libraryNotifierProvider).value ?? [];
  final Map<String, List<Track>> map = {};

  for (final track in library) {
    final key = '${track.album}__${track.artist}';
    map.putIfAbsent(key, () => []).add(track);
  }

  return map.entries.map((e) {
    final tracks = e.value;
    final first = tracks.first;
    return Album(
      name: first.album,
      artist: first.artist,
      year: first.year,
      artworkUri: first.artworkUri,
      tracks: tracks,
    );
  }).toList();
});

final artistsProvider = Provider<List<Artist>>((ref) {
  final library = ref.watch(libraryNotifierProvider).value ?? [];
  final Map<String, List<Track>> map = {};

  for (final track in library) {
    map.putIfAbsent(track.artist, () => []).add(track);
  }

  return map.entries.map((e) {
    final tracks = e.value;
    final albums = tracks.map((t) => t.album).toSet();
    return Artist(
      name: e.key,
      tracks: tracks,
      albums: albums,
    );
  }).toList();
});

final playlistsNotifierProvider =
    StateNotifierProvider<PlaylistsNotifier, AsyncValue<List<Playlist>>>((ref) {
  final db = ref.watch(musicDatabaseProvider);
  return PlaylistsNotifier(db);
});

class PlaylistsNotifier extends StateNotifier<AsyncValue<List<Playlist>>> {
  final MusicDatabase _db;

  PlaylistsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    state = const AsyncValue.loading();
    try {
      final list = await _db.getAllPlaylists();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<Playlist> createPlaylist(String title, {String description = ''}) async {
    final pl = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      dateCreated: DateTime.now().millisecondsSinceEpoch,
    );
    await _db.createPlaylist(pl);
    await loadPlaylists();
    return pl;
  }

  Future<void> addTrack(String playlistId, String trackId) async {
    await _db.addTrackToPlaylist(playlistId, trackId);
    await loadPlaylists();
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    await _db.addTrackToPlaylist(playlistId, trackId);
    await loadPlaylists();
  }
}
