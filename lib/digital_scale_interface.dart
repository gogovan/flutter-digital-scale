/// Common interface for all Digital Scales.
abstract class DigitalScaleInterface {
  /// Search and connect to a Digital scale.
  /// If multiple supported digital scales are found, the behavior is undefined.
  Future<void> connect();

  /// Disconnect from a connected Digital scale.
  Future<void> disconnect();

  /// Get the instantaneous weight value from the digital scale.
  Future<Weight> getWeight();

  /// Get the weight value when it is 'stabilized'.
  /// When an object is placed on the scale, typically the weight value would swing a bit until stabilizing to a value.
  /// This function will return the weight as soon as the value is stabilized.
  /// If weight never stabilize within the given timeout, a TimeoutException will be thrown.
  Future<Weight> getStabilizedWeight(Duration timeout);

  /// Continuously measure the weight and return the values as a Dart Stream.
  Stream<Weight> getWeightStream();
}

enum WeightUnit {
  grams, kilograms, pounds;
}

class Weight {
  Weight(this.value, this.unit);

  double value;
  WeightUnit unit;
}