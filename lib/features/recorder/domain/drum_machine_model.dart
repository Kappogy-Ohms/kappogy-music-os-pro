import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum DrumKitType {
  trap808('808 Trap Boom', 'Heavy sub-bass kicks & snappy rolls'),
  dance909('909 Dance Classic', 'Punchy four-on-the-floor club drums'),
  lofiVinyl('Lo-Fi Dusty Vinyl', 'Warm tape-saturated vinyl drums'),
  acousticVintage('Vintage Acoustic', 'Real studio drum kit with room resonance'),
  afrobeatsPerc('Afrobeats & Amapiano', 'Log drums, shakers, and syncopated rims');

  final String label;
  final String description;
  const DrumKitType(this.label, this.description);
}

enum DrumSound {
  kick('KICK', 'BD', AppColors.kappogyRed),
  snare('SNARE', 'SD', AppColors.kappogyYellow),
  closedHat('CH.HAT', 'CH', AppColors.ledCyan),
  openHat('OP.HAT', 'OH', AppColors.ledPurple),
  clap('CLAP', 'CP', AppColors.kappogyGreen),
  rimshot('PERC/RIM', 'RM', Color(0xFFFF9100));

  final String name;
  final String shortCode;
  final Color color;
  const DrumSound(this.name, this.shortCode, this.color);
}

class DrumPattern {
  final String id;
  final String name;
  final Map<DrumSound, List<bool>> steps; // 16 steps per sound

  const DrumPattern({
    required this.id,
    required this.name,
    required this.steps,
  });

  DrumPattern copyWith({
    String? id,
    String? name,
    Map<DrumSound, List<bool>>? steps,
  }) {
    return DrumPattern(
      id: id ?? this.id,
      name: name ?? this.name,
      steps: steps ?? this.steps,
    );
  }

  static DrumPattern empty(String id, String name) {
    final map = <DrumSound, List<bool>>{};
    for (final sound in DrumSound.values) {
      map[sound] = List.generate(16, (_) => false);
    }
    return DrumPattern(id: id, name: name, steps: map);
  }

  static DrumPattern defaultFourOnFloor() {
    final map = <DrumSound, List<bool>>{};
    // Kick on 1, 5, 9, 13
    map[DrumSound.kick] = [true, false, false, false, true, false, false, false, true, false, false, false, true, false, false, false];
    // Snare / Clap on 5, 13
    map[DrumSound.snare] = [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false];
    map[DrumSound.clap] = [false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false];
    // Closed Hat on every eighth note (1, 3, 5, 7, 9, 11, 13, 15)
    map[DrumSound.closedHat] = [true, false, true, false, true, false, true, false, true, false, true, false, true, false, true, false];
    // Open Hat on off-beats (3, 7, 11, 15)
    map[DrumSound.openHat] = [false, false, true, false, false, false, true, false, false, false, true, false, false, false, true, false];
    // Percussion
    map[DrumSound.rimshot] = [false, false, false, true, false, false, true, false, false, false, false, true, false, true, false, false];

    return DrumPattern(
      id: 'pattern_1',
      name: 'Pattern A (Classic Groove)',
      steps: map,
    );
  }
}
