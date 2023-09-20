import 'package:flutter_digital_scale/weight.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeightUnit', () {
    test('fromString', () {
      expect(WeightUnit.fromString('kg'), WeightUnit.kilograms);
      expect(WeightUnit.fromString(' g'), WeightUnit.grams);
      expect(WeightUnit.fromString('lb'), WeightUnit.pounds);
      expect(WeightUnit.fromString('-'), null);
    });
  });

  group('weight', () {
    test('toKilograms', () {
      expect(const Weight(300, WeightUnit.kilograms).toKilograms(), 300);
      expect(const Weight(300, WeightUnit.grams).toKilograms(), 0.3);
      expect(const Weight(300, WeightUnit.pounds).toKilograms(), 136.077711);
    });

    test('equals', () {
      expect(
        const Weight(3, WeightUnit.kilograms) ==
            const Weight(3, WeightUnit.kilograms),
        true,
      );
      expect(
        const Weight(3, WeightUnit.kilograms) ==
            const Weight(4, WeightUnit.kilograms),
        false,
      );
      expect(
        const Weight(3, WeightUnit.kilograms) ==
            const Weight(3, WeightUnit.grams),
        false,
      );
      expect(
        const Weight(3, WeightUnit.kilograms) ==
            const Weight(3000, WeightUnit.grams),
        false,
      );
    });
  });

  group('weightStatus', () {
    test('equals', () {
      expect(
        const WeightStatus(Weight(3, WeightUnit.kilograms), stable: true) ==
            const WeightStatus(Weight(3, WeightUnit.kilograms), stable: true),
        true,
      );
      expect(
        const WeightStatus(Weight(3, WeightUnit.kilograms), stable: true) ==
            const WeightStatus(Weight(5, WeightUnit.kilograms), stable: true),
        false,
      );
      expect(
        const WeightStatus(Weight(3, WeightUnit.kilograms), stable: true) ==
            const WeightStatus(
              Weight(3, WeightUnit.kilograms),
              stable: false,
            ),
        false,
      );
    });
  });
}
