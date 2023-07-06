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

class Weight {
  Weight(this.value, this.unit);

  double value;
  WeightUnit unit;

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
}
