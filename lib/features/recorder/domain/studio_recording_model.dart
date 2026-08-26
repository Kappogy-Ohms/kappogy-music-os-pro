enum RecordingFormat {
  losslessWav('24-bit Lossless WAV (96kHz)', 'wav', 96000, 24),
  broadcastWav('24-bit Broadcast WAV (48kHz)', 'wav', 48000, 24),
  standardMp3('320kbps Studio MP3 (44.1kHz)', 'mp3', 44100, 16);

  final String label;
  final String ext;
  final int sampleRate;
  final int bitDepth;
  const RecordingFormat(this.label, this.ext, this.sampleRate, this.bitDepth);
}

class StudioRecording {
  final String id;
  final String title;
  final String filePath;
  final int durationMs;
  final int timestamp;
  final int fileSize;
  final RecordingFormat format;
  final bool isOverdub;
  final String? backingTrackTitle;

  const StudioRecording({
    required this.id,
    required this.title,
    required this.filePath,
    required this.durationMs,
    required this.timestamp,
    required this.fileSize,
    required this.format,
    this.isOverdub = false,
    this.backingTrackTitle,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'filePath': filePath,
    'durationMs': durationMs,
    'timestamp': timestamp,
    'fileSize': fileSize,
    'format': format.name,
    'isOverdub': isOverdub ? 1 : 0,
    'backingTrackTitle': backingTrackTitle,
  };

  factory StudioRecording.fromMap(Map<String, dynamic> map) => StudioRecording(
    id: map['id'] as String,
    title: map['title'] as String,
    filePath: map['filePath'] as String,
    durationMs: map['durationMs'] as int,
    timestamp: map['timestamp'] as int,
    fileSize: map['fileSize'] as int,
    format: RecordingFormat.values.firstWhere(
      (f) => f.name == map['format'],
      orElse: () => RecordingFormat.losslessWav,
    ),
    isOverdub: (map['isOverdub'] as int? ?? 0) == 1,
    backingTrackTitle: map['backingTrackTitle'] as String?,
  );
}
