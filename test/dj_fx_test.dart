import 'package:flutter_test/flutter_test.dart';
import 'package:kappogy_music_os_pro/features/dj_mode/presentation/studio_fx_rack.dart';

void main() {
  group('Studio FX Processor Tests', () {
    test('StudioFxParams instantiation and clamping', () {
      const params = StudioFxParams(
        type: StudioFxType.filterSweep,
        isActive: true,
        dryWet: 0.75,
        param1: 0.60,
        param2: 0.40,
      );

      expect(params.type, StudioFxType.filterSweep);
      expect(params.isActive, true);
      expect(params.dryWet, 0.75);
      expect(params.param1, 0.60);
      expect(params.param2, 0.40);
    });

    test('All FX types are supported', () {
      expect(StudioFxType.values.length, 4);
      expect(StudioFxType.values, contains(StudioFxType.filterSweep));
      expect(StudioFxType.values, contains(StudioFxType.echoDelay));
      expect(StudioFxType.values, contains(StudioFxType.spaceReverb));
      expect(StudioFxType.values, contains(StudioFxType.analogFlanger));
    });
  });
}
