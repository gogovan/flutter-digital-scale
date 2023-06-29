import 'package:flutter_device_searcher/device/bluetooth/bluetooth_device.dart';
import 'package:flutter_device_searcher/device/bluetooth/bluetooth_service.dart';

/// Common interface for all Digital Scales.
abstract class DigitalScaleInterface {
  /// Search and connect to a Digital scale.
  /// If multiple supported digital scales are found, only one of them will be connected.
  Future<void> connect(void Function(BluetoothDevice device, BluetoothService service) onConnected);

  /// Disconnect from a connected Digital scale.
  Future<void> disconnect();

  /// Get the instantaneous weight value from the digital scale.
  Future<Weight> getWeight();

  /// Get the weight value when it is 'stabilized'.
  /// When an object is placed on the scale, typically the weight value would swing a bit until stabilizing to a value.
  /// This function will return the weight as soon as the value is stabilized.
  /// If weight never stabilize within the given timeout, a TimeoutException will be thrown.
  Future<Weight> getStabilizedWeight(int threshold, Duration timeout);

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

  double toKilograms() {
    switch (unit) {
      case WeightUnit.kilograms: return value;
      // ignore: no-magic-number, unit conversions are fixed.
      case WeightUnit.grams: return value / 1000;
    // ignore: no-magic-number, unit conversions are fixed.
      case WeightUnit.pounds: return value * 0.45359237;
    }
  }
}
