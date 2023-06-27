import 'package:flutter_device_searcher/device_searcher/bluetooth_searcher.dart';
import 'package:flutter_digital_scale/digital_scale_interface.dart';

/// Interface a Wuxianliang WXL-T12 Digital Scale.
class WXLT12 implements DigitalScaleInterface {
  static const String _bluetoothName = 'WXL-T12.4.0';
  static const String _serviceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String _characteristicUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';

  BluetoothSearcher btSearcher = BluetoothSearcher();

  @override
  Future<void> connect() {
    // TODO: implement connect
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() {
    // TODO: implement disconnect
    throw UnimplementedError();
  }

  @override
  Future<Weight> getStabilizedWeight(Duration timeout) {
    // TODO: implement getStabilizedWeight
    throw UnimplementedError();
  }

  @override
  Future<Weight> getWeight() {
    // TODO: implement getWeight
    throw UnimplementedError();
  }

  @override
  Stream<Weight> getWeightStream() {
    // TODO: implement getWeightStream
    throw UnimplementedError();
  }

}
