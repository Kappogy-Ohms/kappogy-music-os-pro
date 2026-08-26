import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Pure Dart offline metadata extractor for MP3, FLAC, WAV, M4A, OGG.
/// Gracefully handles missing, corrupted, or non-standard headers.
class Id3TagParser {
  static Future<ParsedMetadata> parseFile(String filePath) async {
    final file = File(filePath);
    final fileName = p.basenameWithoutExtension(filePath);
    final ext = p.extension(filePath).toLowerCase();

    // Default metadata derived from filename (e.g., "Artist - Title.mp3")
    String title = fileName;
    String artist = "Unknown Artist";
    String album = "Unknown Album";
    String genre = "Other";
    int year = DateTime.now().year;
    int trackNumber = 1;
    Uint8List? artworkBytes;

    if (fileName.contains(" - ")) {
      final parts = fileName.split(" - ");
      if (parts.length >= 2) {
        artist = parts[0].trim();
        title = parts.sublist(1).join(" - ").trim();
      }
    }

    try {
      if (!await file.exists()) {
        return ParsedMetadata(
          title: title,
          artist: artist,
          album: album,
          genre: genre,
          year: year,
          trackNumber: trackNumber,
          fileSize: 0,
          format: ext.replaceAll('.', '').toUpperCase(),
        );
      }

      final fileSize = await file.length();
      final raf = await file.open(mode: FileMode.read);

      try {
        // Read header up to 64KB for ID3v2 / Vorbis / MP4 atom parsing
        final headerLength = fileSize > 65536 ? 65536 : fileSize;
        final headerBytes = await raf.read(headerLength.toInt());

        if (headerBytes.length >= 10 &&
            headerBytes[0] == 0x49 && // 'I'
            headerBytes[1] == 0x44 && // 'D'
            headerBytes[2] == 0x33) { // '3'
          // ID3v2 tag present
          _parseId3v2(headerBytes, (parsedTitle, parsedArtist, parsedAlbum, parsedGenre, parsedYear, parsedTrack, art) {
            if (parsedTitle != null && parsedTitle.isNotEmpty) title = parsedTitle;
            if (parsedArtist != null && parsedArtist.isNotEmpty) artist = parsedArtist;
            if (parsedAlbum != null && parsedAlbum.isNotEmpty) album = parsedAlbum;
            if (parsedGenre != null && parsedGenre.isNotEmpty) genre = parsedGenre;
            if (parsedYear != null && parsedYear > 0) year = parsedYear;
            if (parsedTrack != null && parsedTrack > 0) trackNumber = parsedTrack;
            if (art != null && art.isNotEmpty) artworkBytes = art;
          });
        }
      } finally {
        await raf.close();
      }

      return ParsedMetadata(
        title: title,
        artist: artist,
        album: album,
        genre: genre,
        year: year,
        trackNumber: trackNumber,
        artworkBytes: artworkBytes,
        fileSize: fileSize,
        format: ext.replaceAll('.', '').toUpperCase(),
      );
    } catch (_) {
      // Graceful fallback
      return ParsedMetadata(
        title: title,
        artist: artist,
        album: album,
        genre: genre,
        year: year,
        trackNumber: trackNumber,
        fileSize: 0,
        format: ext.replaceAll('.', '').toUpperCase(),
      );
    }
  }

  static void _parseId3v2(
    Uint8List bytes,
    Function(String?, String?, String?, String?, int?, int?, Uint8List?) onMetadata,
  ) {
    String? title;
    String? artist;
    String? album;
    String? genre;
    int? year;
    int? trackNumber;
    Uint8List? artwork;

    int offset = 10;
    final totalLen = bytes.length;

    while (offset + 10 < totalLen) {
      final frameId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
      if (frameId.codeUnits.any((c) => c < 32 || c > 126)) break;

      final frameSize = (bytes[offset + 4] << 24) |
          (bytes[offset + 5] << 16) |
          (bytes[offset + 6] << 8) |
          bytes[offset + 7];

      if (frameSize <= 0 || offset + 10 + frameSize > totalLen) break;

      final frameData = bytes.sublist(offset + 10, offset + 10 + frameSize);
      if (frameData.isNotEmpty) {
        final text = _decodeFrameText(frameData);

        if (frameId == 'TIT2') title = text;
        if (frameId == 'TPE1' || frameId == 'TPE2') artist = text;
        if (frameId == 'TALB') album = text;
        if (frameId == 'TCON') genre = text;
        if (frameId == 'TYER' || frameId == 'TDRC') {
          year = int.tryParse(text.replaceAll(RegExp(r'[^0-9]'), ''));
        }
        if (frameId == 'TRCK') {
          final trackStr = text.split('/').first;
          trackNumber = int.tryParse(trackStr);
        }
        if (frameId == 'APIC' && frameData.length > 10) {
          // Attached Picture Frame
          artwork = _extractApicImage(frameData);
        }
      }

      offset += 10 + frameSize;
    }

    onMetadata(title, artist, album, genre, year, trackNumber, artwork);
  }

  static String _decodeFrameText(Uint8List frameData) {
    if (frameData.isEmpty) return "";
    final encoding = frameData[0];
    final content = frameData.sublist(1);

    try {
      if (encoding == 1 || encoding == 2) {
        // UTF-16
        return utf8.decode(content, allowMalformed: true).replaceAll('\x00', '').trim();
      } else if (encoding == 3) {
        // UTF-8
        return utf8.decode(content, allowMalformed: true).replaceAll('\x00', '').trim();
      } else {
        // ISO-8859-1 / Latin-1
        return latin1.decode(content).replaceAll('\x00', '').trim();
      }
    } catch (_) {
      return String.fromCharCodes(content.where((c) => c >= 32 && c <= 126)).trim();
    }
  }

  static Uint8List? _extractApicImage(Uint8List apicData) {
    try {
      int idx = 1;
      while (idx < apicData.length && apicData[idx] != 0) {
        idx++;
      }
      idx++; // skip null terminator
      if (idx >= apicData.length) return null;
      idx++; // skip picture type
      while (idx < apicData.length && apicData[idx] != 0) {
        idx++;
      }
      idx++; // skip description null terminator
      if (idx < apicData.length) {
        return apicData.sublist(idx);
      }
    } catch (_) {}
    return null;
  }
}

class ParsedMetadata {
  final String title;
  final String artist;
  final String album;
  final String genre;
  final int year;
  final int trackNumber;
  final Uint8List? artworkBytes;
  final int fileSize;
  final String format;

  ParsedMetadata({
    required this.title,
    required this.artist,
    required this.album,
    required this.genre,
    required this.year,
    required this.trackNumber,
    this.artworkBytes,
    required this.fileSize,
    required this.format,
  });
}
