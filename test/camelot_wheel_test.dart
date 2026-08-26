import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/core/widgets/harmonic_camelot_wheel.dart';

void main() {
  group('Camelot Harmonic Wheel Tests', () {
    const key8A = CamelotKeyInfo(8, 'A', 'Am');
    const key8B = CamelotKeyInfo(8, 'B', 'C');
    const key7A = CamelotKeyInfo(7, 'A', 'Dm');
    const key9A = CamelotKeyInfo(9, 'A', 'Em');
    const key10A = CamelotKeyInfo(10, 'A', 'Bm');
    const key4A = CamelotKeyInfo(4, 'A', 'Fm');

    test('exact key match returns exact', () {
      expect(key8A.getRelationTo(key8A), HarmonicRelation.exact);
    });

    test('relative major/minor returns relative', () {
      expect(key8A.getRelationTo(key8B), HarmonicRelation.relative);
      expect(key8B.getRelationTo(key8A), HarmonicRelation.relative);
    });

    test('adjacent key returns adjacent', () {
      expect(key8A.getRelationTo(key7A), HarmonicRelation.adjacent);
      expect(key8A.getRelationTo(key9A), HarmonicRelation.adjacent);
    });

    test('energy boost +2 returns energyBoost', () {
      expect(key10A.getRelationTo(key8A), HarmonicRelation.energyBoost);
    });

    test('incompatible keys return incompatible', () {
      expect(key4A.getRelationTo(key8A), HarmonicRelation.incompatible);
    });
  });
}
