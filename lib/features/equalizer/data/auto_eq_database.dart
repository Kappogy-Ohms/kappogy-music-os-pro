class AutoEqProfile {
  final String id;
  final String brand;
  final String model;
  final String type; // 'Over-Ear', 'IEM / In-Ear', 'Wireless / ANC'
  final List<double> graphic10BandGains; // 31Hz to 16kHz
  final List<AutoEqFilter> peqFilters;
  final String description;

  const AutoEqProfile({
    required this.id,
    required this.brand,
    required this.model,
    required this.type,
    required this.graphic10BandGains,
    required this.peqFilters,
    required this.description,
  });
}

class AutoEqFilter {
  final double freq;
  final double gain;
  final double q;
  const AutoEqFilter({required this.freq, required this.gain, required this.q});
}

class AutoEqDatabase {
  static const List<AutoEqProfile> profiles = [
    AutoEqProfile(
      id: 'sennheiser_hd600',
      brand: 'Sennheiser',
      model: 'HD 600 (Audiophile Reference)',
      type: 'Over-Ear',
      graphic10BandGains: [4.5, 3.8, 1.2, 0.0, -0.5, 0.0, 1.2, -1.8, 0.5, 1.0],
      peqFilters: [
        AutoEqFilter(freq: 45, gain: 4.5, q: 0.8),
        AutoEqFilter(freq: 220, gain: -1.2, q: 1.4),
        AutoEqFilter(freq: 3500, gain: -2.0, q: 2.2),
        AutoEqFilter(freq: 6000, gain: 1.5, q: 1.8),
        AutoEqFilter(freq: 12000, gain: 1.0, q: 1.0),
      ],
      description: 'Compensates for low-end sub-bass roll-off under 60Hz and smooths the 3.5kHz ear canal resonance for reference transparency.',
    ),
    AutoEqProfile(
      id: 'sennheiser_hd650',
      brand: 'Sennheiser',
      model: 'HD 650 / HD 6XX',
      type: 'Over-Ear',
      graphic10BandGains: [4.0, 3.0, 0.5, -0.8, -0.5, 0.2, 1.5, -0.5, 1.2, 1.8],
      peqFilters: [
        AutoEqFilter(freq: 40, gain: 4.2, q: 0.7),
        AutoEqFilter(freq: 200, gain: -1.5, q: 1.2),
        AutoEqFilter(freq: 3200, gain: -1.8, q: 2.0),
        AutoEqFilter(freq: 7500, gain: 2.0, q: 1.5),
        AutoEqFilter(freq: 14000, gain: 2.5, q: 1.2),
      ],
      description: 'Lifts deep sub-bass and opens up top-end air treble while taming the mid-bass veil.',
    ),
    AutoEqProfile(
      id: 'sony_wh1000xm5',
      brand: 'Sony',
      model: 'WH-1000XM5 (Wireless ANC)',
      type: 'Wireless / ANC',
      graphic10BandGains: [-2.0, -3.5, -3.0, -1.0, 0.5, 1.2, 2.5, 1.8, 2.2, 1.5],
      peqFilters: [
        AutoEqFilter(freq: 120, gain: -3.5, q: 0.9),
        AutoEqFilter(freq: 850, gain: 1.2, q: 1.5),
        AutoEqFilter(freq: 2800, gain: 2.8, q: 1.4),
        AutoEqFilter(freq: 5500, gain: 1.5, q: 2.0),
        AutoEqFilter(freq: 10000, gain: 2.0, q: 1.0),
      ],
      description: 'Controls boomy mid-bass bloat and elevates clarity in vocal presence (2.8kHz) and soundstage sparkle.',
    ),
    AutoEqProfile(
      id: 'apple_airpods_max',
      brand: 'Apple',
      model: 'AirPods Max (Spatial ANC)',
      type: 'Wireless / ANC',
      graphic10BandGains: [1.2, 0.5, -1.0, -0.5, 0.0, 0.8, -1.5, 2.2, 1.0, 0.0],
      peqFilters: [
        AutoEqFilter(freq: 60, gain: 1.5, q: 1.0),
        AutoEqFilter(freq: 250, gain: -1.2, q: 1.2),
        AutoEqFilter(freq: 2100, gain: 1.8, q: 1.8),
        AutoEqFilter(freq: 4200, gain: -2.2, q: 2.5),
        AutoEqFilter(freq: 8000, gain: 2.5, q: 1.5),
      ],
      description: 'Tunes AirPods Max towards the Harman 2019v2 target, smoothing the 4.2kHz dip and giving crisp vocal definition.',
    ),
    AutoEqProfile(
      id: 'moondrop_blessing2',
      brand: 'Moondrop',
      model: 'Blessing 2 / Dusk (Hybrid IEM)',
      type: 'IEM / In-Ear',
      graphic10BandGains: [2.5, 1.8, 0.5, 0.0, -0.2, 0.0, 0.5, -1.0, 0.8, 1.2],
      peqFilters: [
        AutoEqFilter(freq: 35, gain: 2.5, q: 0.8),
        AutoEqFilter(freq: 150, gain: 1.0, q: 1.2),
        AutoEqFilter(freq: 3000, gain: -1.0, q: 2.0),
        AutoEqFilter(freq: 6200, gain: -1.5, q: 3.0),
        AutoEqFilter(freq: 11000, gain: 1.8, q: 1.2),
      ],
      description: 'Sub-bass impact boost and 6kHz sibilance control for ultra-clean holographic IEM imaging.',
    ),
    AutoEqProfile(
      id: 'beyerdynamic_dt770',
      brand: 'Beyerdynamic',
      model: 'DT 770 Pro (80 Ohm Studio)',
      type: 'Over-Ear',
      graphic10BandGains: [0.0, -1.5, -1.0, 0.0, 0.5, 1.0, 1.5, -4.5, -3.0, 0.0],
      peqFilters: [
        AutoEqFilter(freq: 100, gain: -1.8, q: 1.0),
        AutoEqFilter(freq: 1200, gain: 1.2, q: 1.5),
        AutoEqFilter(freq: 5800, gain: -5.2, q: 3.5),
        AutoEqFilter(freq: 8500, gain: -4.0, q: 2.8),
        AutoEqFilter(freq: 13000, gain: 1.0, q: 1.0),
      ],
      description: 'Eliminates the infamous Beyerdynamic 6kHz-8kHz treble spike while preserving punchy bass for fatigue-free mixing.',
    ),
    AutoEqProfile(
      id: 'audio_technica_m50x',
      brand: 'Audio-Technica',
      model: 'ATH-M50x (Studio Monitor)',
      type: 'Over-Ear',
      graphic10BandGains: [-1.5, -2.5, -1.0, 0.0, 0.5, 1.0, -0.5, -2.0, 1.0, 1.5],
      peqFilters: [
        AutoEqFilter(freq: 150, gain: -2.8, q: 1.2),
        AutoEqFilter(freq: 1000, gain: 1.5, q: 1.4),
        AutoEqFilter(freq: 4000, gain: 2.0, q: 2.0),
        AutoEqFilter(freq: 9500, gain: -2.5, q: 2.5),
        AutoEqFilter(freq: 14000, gain: 2.0, q: 1.0),
      ],
      description: 'Balances upper bass thickness and corrects upper mid recession for accurate audio mastering.',
    ),
    AutoEqProfile(
      id: 'harman_target_overear',
      brand: 'Harman Acoustic Research',
      model: 'Harman Target 2019v2 (Reference Curve)',
      type: 'Reference Standard',
      graphic10BandGains: [3.5, 3.0, 1.5, 0.0, 0.0, 0.5, 1.5, 0.0, 0.5, 1.0],
      peqFilters: [
        AutoEqFilter(freq: 50, gain: 4.0, q: 0.7),
        AutoEqFilter(freq: 200, gain: 1.0, q: 1.0),
        AutoEqFilter(freq: 2800, gain: 2.0, q: 1.5),
        AutoEqFilter(freq: 7000, gain: 1.0, q: 2.0),
        AutoEqFilter(freq: 12000, gain: 1.5, q: 1.2),
      ],
      description: 'The golden acoustic target developed by Dr. Sean Olive for universally preferred musical naturalness.',
    ),
  ];
}
