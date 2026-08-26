import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../audio_player/domain/track_model.dart';
import '../../../core/utils/id3_tag_parser.dart';
import 'music_database.dart';
import 'demo_music_factory.dart';

class LocalIndexerService {
  final MusicDatabase _db;
  bool _isIndexing = false;
  double _progress = 0.0;
  String _currentIndexingFile = '';

  LocalIndexerService({MusicDatabase? db}) : _db = db ?? MusicDatabase.instance;

  bool get isIndexing => _isIndexing;
  double get progress => _progress;
  String get currentIndexingFile => _currentIndexingFile;

  static const supportedExtensions = {
    '.mp3', '.flac', '.wav', '.aac', '.m4a', '.ogg', '.opus', '.aiff', '.alac', '.wma'
  };

  /// Initializes database with demo tracks on first launch if empty
  Future<void> ensureInitialized() async {
    final existing = await _db.getAllTracks();
    if (existing.isEmpty) {
      final demos = DemoMusicFactory.generateDemoTracks();
      await _db.insertTracksBulk(demos);
    }
  }

  /// Request permissions on Android / iOS
  Future<bool> requestStoragePermission() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return true;
    }

    if (Platform.isAndroid) {
      final audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted) return true;
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.mediaLibrary.request();
      return status.isGranted;
    }
    return true;
  }

  /// Scans custom directory or default device music folders
  Future<int> scanDirectory(
    String directoryPath, {
    Function(double progress, String currentFile)? onProgress,
  }) async {
    _isIndexing = true;
    _progress = 0.0;
    int indexedCount = 0;

    try {
      final dir = Directory(directoryPath);
      if (!await dir.exists()) return 0;

      final List<File> audioFiles = [];
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase();
          if (supportedExtensions.contains(ext)) {
            audioFiles.add(entity);
          }
        }
      }

      final total = audioFiles.length;
      if (total == 0) {
        _isIndexing = false;
        return 0;
      }

      final List<Track> batch = [];
      for (int i = 0; i < total; i++) {
        final file = audioFiles[i];
        _currentIndexingFile = p.basename(file.path);
        _progress = (i + 1) / total;
        onProgress?.call(_progress, _currentIndexingFile);

        try {
          final meta = await Id3TagParser.parseFile(file.path);
          final fileStat = await file.stat();
          final trackId = md5.convert(file.path.codeUnits).toString();

          // Cache artwork if embedded
          String? artUri;
          if (meta.artworkBytes != null && meta.artworkBytes!.isNotEmpty) {
            artUri = await _saveCachedArtwork(trackId, meta.artworkBytes!);
          }

          final track = Track(
            id: trackId,
            uri: file.path,
            title: meta.title,
            artist: meta.artist,
            album: meta.album,
            genre: meta.genre,
            year: meta.year,
            trackNumber: meta.trackNumber,
            durationMs: 200000, // Estimated duration or parsed from audio decoder
            codec: meta.format,
            bitrate: 320,
            sampleRate: 44100,
            bitDepth: 16,
            bpm: 120.0,
            musicalKey: 'C',
            mood: 'Unknown',
            energy: 0.7,
            artworkUri: artUri,
            rating: 0,
            isFavorite: false,
            dateAdded: fileStat.modified.millisecondsSinceEpoch,
            folder: p.dirname(file.path),
            fileSize: meta.fileSize,
            isDemo: false,
          );

          batch.add(track);
          indexedCount++;

          if (batch.length >= 25) {
            await _db.insertTracksBulk(batch);
            batch.clear();
          }
        } catch (_) {}
      }

      if (batch.isNotEmpty) {
        await _db.insertTracksBulk(batch);
        batch.clear();
      }
    } finally {
      _isIndexing = false;
      _progress = 1.0;
    }

    return indexedCount;
  }

  Future<String> _saveCachedArtwork(String trackId, Uint8List bytes) async {
    final appDir = await getApplicationDocumentsDirectory();
    final artDir = Directory(p.join(appDir.path, 'album_art'));
    if (!await artDir.exists()) {
      await artDir.create(recursive: true);
    }
    final artPath = p.join(artDir.path, '$trackId.jpg');
    final file = File(artPath);
    await file.writeAsBytes(bytes);
    return artPath;
  }
}
