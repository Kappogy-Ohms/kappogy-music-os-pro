import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/audio_player/domain/track_model.dart';
import '../../features/audio_player/presentation/audio_providers.dart';
import '../../features/audio_player/presentation/now_playing_screen.dart';
import '../utils/id3_tag_parser.dart';

class IntentHandlerService {
  static const MethodChannel _channel = MethodChannel('com.kappogy.musicos/native_audio');
  static final StreamController<String> _intentMediaStream = StreamController<String>.broadcast();
  static bool _isInitialized = false;

  static Stream<String> get onMediaIntent => _intentMediaStream.stream;

  /// Initialize native intent listeners for Android and iOS
  static void initialize(dynamic ref, BuildContext context) {
    if (_isInitialized) return;
    _isInitialized = true;

    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onMediaIntentReceived') {
        final uri = call.arguments as String?;
        if (uri != null && uri.isNotEmpty) {
          _intentMediaStream.add(uri);
          if (context.mounted) {
            await handleIncomingMediaUri(uri, ref, context);
          }
        }
      }
    });

    // Check cold launch initial media intent
    checkInitialIntent(ref, context);
  }

  static Future<void> checkInitialIntent(dynamic ref, BuildContext context) async {
    try {
      final initialUri = await _channel.invokeMethod<String>('getInitialMediaUri');
      if (initialUri != null && initialUri.isNotEmpty && context.mounted) {
        await handleIncomingMediaUri(initialUri, ref, context);
      }
    } catch (e) {
      debugPrint('IntentHandler checkInitialIntent error: $e');
    }
  }

  /// Process incoming file / content URI from external app intent
  static Future<Track?> handleIncomingMediaUri(String uriString, dynamic ref, [BuildContext? context]) async {
    try {
      debugPrint('Processing incoming media intent URI: $uriString');
      String filePath = uriString;

      if (filePath.startsWith('file://')) {
        filePath = Uri.parse(filePath).toFilePath();
      }

      final file = File(filePath);
      final exists = await file.exists();
      final fileName = filePath.split(Platform.pathSeparator).last.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
      
      Track incomingTrack;
      if (exists) {
        final meta = await Id3TagParser.parseFile(filePath);
        incomingTrack = Track(
          id: 'intent_${DateTime.now().millisecondsSinceEpoch}',
          uri: filePath,
          title: meta.title.isNotEmpty ? meta.title : fileName,
          artist: meta.artist.isNotEmpty ? meta.artist : 'External Source',
          album: meta.album.isNotEmpty ? meta.album : 'Incoming Stream',
          durationMs: 180000,
          dateAdded: DateTime.now().millisecondsSinceEpoch,
          folder: file.parent.path,
          fileSize: meta.fileSize > 0 ? meta.fileSize : await file.length(),
        );
      } else {
        final normalized = filePath.replaceAll('\\', '/');
        final folderName = normalized.contains('/') ? normalized.substring(0, normalized.lastIndexOf('/')) : 'External';
        incomingTrack = Track(
          id: 'intent_${DateTime.now().millisecondsSinceEpoch}',
          uri: uriString,
          title: fileName.isNotEmpty ? fileName : 'External Audio Stream',
          artist: 'External Source',
          album: 'Incoming Stream',
          durationMs: 180000,
          dateAdded: DateTime.now().millisecondsSinceEpoch,
          folder: folderName,
          fileSize: 0,
        );
      }

      // Enqueue and play immediately if provider ref is available
      try {
        final notifier = ref.read(playbackStateProvider.notifier);
        await notifier.playTrack(incomingTrack, [incomingTrack]);
      } catch (e) {
        debugPrint('Note: playbackStateProvider not attached during headless test: $e');
      }

      if (context != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        );
      }

      return incomingTrack;
    } catch (e) {
      debugPrint('Error handling incoming media intent: $e');
      return null;
    }
  }

  /// Interactive "Play With..." File Picker for user to choose any external audio file
  static Future<void> openExternalAudioPicker(BuildContext context, dynamic ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'flac', 'wav', 'm4a', 'aac', 'ogg', 'opus', 'aiff', 'alac'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final tracks = <Track>[];
        for (final f in result.files) {
          if (f.path != null) {
            final meta = await Id3TagParser.parseFile(f.path!);
            tracks.add(Track(
              id: 'external_${f.name}_${DateTime.now().millisecondsSinceEpoch}',
              uri: f.path!,
              title: meta.title.isNotEmpty ? meta.title : f.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
              artist: meta.artist.isNotEmpty ? meta.artist : 'External File',
              album: meta.album.isNotEmpty ? meta.album : 'Custom Import',
              durationMs: 180000,
              dateAdded: DateTime.now().millisecondsSinceEpoch,
              folder: File(f.path!).parent.path,
              fileSize: f.size,
            ));
          }
        }

        if (tracks.isNotEmpty) {
          final notifier = ref.read(playbackStateProvider.notifier);
          await notifier.playTrack(tracks.first, tracks);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Playing ${tracks.first.title} (${tracks.length} file${tracks.length > 1 ? 's' : ''} queued)'),
                backgroundColor: const Color(0xFF00E5FF),
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error opening external audio picker: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open audio file: $e')),
        );
      }
    }
  }

  /// Outbound Share: Share audio file to WhatsApp, Telegram, Files, Bluetooth, etc.
  static Future<void> shareAudioFile(Track track, {BuildContext? context}) async {
    try {
      final file = File(track.uri);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(track.uri, name: '${track.artist} - ${track.title}', mimeType: 'audio/*')],
          text: '🎵 Listen to "${track.title}" by ${track.artist} on Kappogy Music OS Pro (Offline Studio)',
          subject: 'Audio Track: ${track.title}',
        );
      } else {
        // Share metadata text
        await Share.share(
          '🎵 Now Playing: "${track.title}" by ${track.artist} (Album: ${track.album})\nPlaying on Kappogy Music OS Pro — 100% Offline Audiophile Music OS by Kappogy Ohms',
          subject: 'Audio Track: ${track.title}',
        );
      }
    } catch (e) {
      debugPrint('Error sharing audio file: $e');
      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share track: $e')),
        );
      }
    }
  }

  /// Outbound Share: Share exported ringtone wave file
  static Future<void> shareRingtoneFile(String ringtonePath, String title, {BuildContext? context}) async {
    try {
      final file = File(ringtonePath);
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(ringtonePath, name: '$title-ringtone.wav', mimeType: 'audio/wav')],
          text: '🔔 Studio trimmed ringtone for "$title" created with Kappogy Music OS Pro',
          subject: 'Ringtone: $title',
        );
      }
    } catch (e) {
      debugPrint('Error sharing ringtone: $e');
    }
  }
}
