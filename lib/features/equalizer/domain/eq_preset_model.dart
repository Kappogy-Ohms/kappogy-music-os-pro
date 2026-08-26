class EqPreset {
  final String id;
  final String name;
  final List<double> bands; // 10 bands in dB (-15.0 to +15.0)
  final double preamp; // in dB (-12.0 to +12.0)
  final double bassBoost; // 0.0 to 100.0%
  final double treble; // in dB (-15.0 to +15.0)
  final double stereoWiden; // 0.0 to 100.0%
  final bool isCustom;

  const EqPreset({
    required this.id,
    required this.name,
    required this.bands,
    this.preamp = 0.0,
    this.bassBoost = 0.0,
    this.treble = 0.0,
    this.stereoWiden = 0.0,
    this.isCustom = false,
  });

  static const List<String> bandFrequencies = [
    '31Hz', '62Hz', '125Hz', '250Hz', '500Hz',
    '1kHz', '2kHz', '4kHz', '8kHz', '16kHz'
  ];

  static List<EqPreset> getDefaultPresets() {
    return const [
      EqPreset(
        id: 'flat',
        name: 'Flat / Studio Direct',
        bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      ),
      EqPreset(
        id: 'afrobeats',
        name: 'Afrobeats Punch',
        bands: [6.0, 7.5, 4.0, 1.0, 0.0, 2.0, 3.5, 4.0, 5.5, 6.0],
        bassBoost: 35.0,
        preamp: 1.5,
      ),
      EqPreset(
        id: 'bass_boost',
        name: 'Deep Bass Sub-Woofer',
        bands: [8.5, 9.0, 6.5, 3.0, 0.0, -1.0, 0.0, 1.0, 2.0, 2.5],
        bassBoost: 60.0,
      ),
      EqPreset(
        id: 'hip_hop',
        name: 'Hip-Hop / 808',
        bands: [7.0, 6.5, 3.0, 1.0, -1.0, 1.5, 3.0, 2.0, 4.0, 5.0],
        bassBoost: 40.0,
      ),
      EqPreset(
        id: 'rock',
        name: 'Rock / Dynamic',
        bands: [4.5, 3.0, -1.5, -2.0, 1.0, 3.0, 5.0, 6.0, 6.5, 7.0],
        preamp: 1.0,
      ),
      EqPreset(
        id: 'jazz',
        name: 'Jazz Club Warmth',
        bands: [3.0, 2.5, 1.0, 2.0, -1.0, -1.0, 0.0, 2.0, 3.5, 4.0],
        stereoWiden: 25.0,
      ),
      EqPreset(
        id: 'vocal',
        name: 'Vocal / Acoustic Clarity',
        bands: [-2.0, -1.5, 0.0, 2.5, 4.5, 5.0, 4.0, 3.0, 1.5, 0.0],
        treble: 2.0,
      ),
      EqPreset(
        id: 'classical',
        name: 'Concert Hall Classical',
        bands: [4.0, 3.5, 2.5, 1.5, -1.0, 0.0, 2.5, 3.5, 4.5, 5.0],
        stereoWiden: 40.0,
      ),
    ];
  }

  EqPreset copyWith({
    String? id,
    String? name,
    List<double>? bands,
    double? preamp,
    double? bassBoost,
    double? treble,
    double? stereoWiden,
    bool? isCustom,
  }) {
    return EqPreset(
      id: id ?? this.id,
      name: name ?? this.name,
      bands: bands ?? this.bands,
      preamp: preamp ?? this.preamp,
      bassBoost: bassBoost ?? this.bassBoost,
      treble: treble ?? this.treble,
      stereoWiden: stereoWiden ?? this.stereoWiden,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
