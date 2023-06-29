enum WeightUnit {
  grams,
  kilograms,
  pounds;
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
