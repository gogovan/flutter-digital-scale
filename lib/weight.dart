import 'package:flutter/foundation.dart';

enum WeightUnit {
  grams,
  kilograms,
  pounds;

  static WeightUnit? fromString(String s) {
    final strim = s.trim();

    if (strim == 'kg') {
      return WeightUnit.kilograms;
    } else if (strim == 'g') {
      return WeightUnit.grams;
    } else if (strim == 'lb') {
      return WeightUnit.pounds;
    } else {
      return null;
    }
  }
}

/// Represent a measured weight value with unit.
@immutable
class Weight {
  const Weight(this.value, this.unit);

  final double value;
  final WeightUnit unit;

  double toKilograms() {
    switch (unit) {
      case WeightUnit.kilograms:
        return value;
      case WeightUnit.grams:
        // ignore: no-magic-number, unit conversions are fixed.
        return value / 1000;
      case WeightUnit.pounds:
        // ignore: no-magic-number, unit conversions are fixed.
        return value * 0.45359237;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Weight &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          unit == other.unit;

  @override
  int get hashCode => value.hashCode ^ unit.hashCode;

  @override
  String toString() => 'Weight{value: $value, unit: $unit}';
}

@immutable
class WeightStatus {
  const WeightStatus(this.weight, {required this.stable});

  final Weight weight;

  /// Whether the weight is stabilized.
  final bool stable;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightStatus &&
          runtimeType == other.runtimeType &&
          weight == other.weight &&
          stable == other.stable;

  @override
  int get hashCode => weight.hashCode ^ stable.hashCode;

  @override
  String toString() => 'WeightStatus{weight: $weight, stable: $stable}';
}
