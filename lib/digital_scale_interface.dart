import 'package:flutter_digital_scale/weight.dart';

/// Common interface for all Digital Scales.
abstract class DigitalScaleInterface {
  /// Search and connect to a Digital scale.
  /// If multiple supported digital scales are found, only one of them will be connected.
  Future<void> connect({
    Duration timeout = Duration.zero,
    required void Function() onConnected,
  });

  /// Disconnect from a connected Digital scale.
  Future<void> disconnect();

  bool isConnected();

  Stream<bool> connectStateStream();

  /// Get the instantaneous weight value and status from the digital scale.
  /// However, in typical usage you would likely want to use `getStabilizedWeight()` instead.
  Future<WeightStatus> getWeight();

  /// Get the weight value when it is 'stabilized'.
  /// When an object is placed on the scale, typically the weight value would swing a bit until stabilizing to a value.
  /// This function will return the weight as soon as the value is stabilized.
  /// 'threshold' is the number of equal samples to receive until it is stabilized.
  /// Weight are considered equal when the weight value no longer changes up to the precision of the scale.
  /// Zero weight shall never be returned by this method, to avoid function returning zero before any object is placed on the scale.
  /// If weight never stabilize within the given timeout, a TimeoutException will be thrown.
  Future<Weight> getStabilizedWeight(Duration timeout);

  /// Continuously measure the weight and return the values as a Dart Stream.
  Stream<WeightStatus> getWeightStream();
}
