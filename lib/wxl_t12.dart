import 'dart:async';

import 'package:flutter_device_searcher/device/bluetooth/bluetooth_device.dart';
import 'package:flutter_device_searcher/device/bluetooth/bluetooth_service.dart';
import 'package:flutter_device_searcher/device_searcher/bluetooth_searcher.dart';
import 'package:flutter_device_searcher/search_result/bluetooth_result.dart';
import 'package:flutter_digital_scale/digital_scale_interface.dart';

/// Interface a Wuxianliang WXL-T12 Digital Scale.
class WXLT12 implements DigitalScaleInterface {
  static const String _bluetoothName = 'WXL-T12.4.0';
  static const String _serviceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String _characteristicUuid =
      '0000ffe1-0000-1000-8000-00805f9b34fb';

  BluetoothSearcher btSearcher = BluetoothSearcher();
  BluetoothDevice? btDevice;
  BluetoothCharacteristic? btCharacteristic;

  StreamSubscription<List<BluetoothResult>>? searchedDevices;

  Stream<Weight>? weights;
  StreamSubscription<Weight>? weightStream;

  Weight? currentWeight;

  @override
  Future<void> connect(
    void Function(BluetoothDevice device, BluetoothService service) onConnected,
  ) async {
    searchedDevices = btSearcher.search().listen((event) async {
      final device = event.where((element) => element.name == _bluetoothName);

      if (device.isNotEmpty) {
        final btDevice = BluetoothDevice(btSearcher, device.first);
        final services = await btDevice.getServices();
        final service = services.where(
          (s) =>
              s.serviceId == _serviceUuid &&
              s.characteristics
                  .any((c) => c.characteristicId == _characteristicUuid),
        );

        if (service.isNotEmpty) {
          final selectedService = service.first;

          this.btDevice = btDevice;
          btCharacteristic = selectedService.characteristics
              .where(
                (element) => element.characteristicId == _characteristicUuid,
              )
              .first;

          onConnected(btDevice, selectedService);
        }
      }
    });
  }

  @override
  Future<void> disconnect() async {
    await weightStream?.cancel();
    await searchedDevices?.cancel();
  }

  @override
  Future<Weight> getStabilizedWeight(int threshold, Duration timeout) async {
    final source = weights ??= getWeightStream();

    final stabilizedWeight = Completer<Weight>();

    var lastWeight = Weight(-999, WeightUnit.kilograms);
    var streak = 0;

    final subscription = source.timeout(timeout).listen((event) {
      if ((lastWeight.toKilograms() - event.toKilograms()).abs() > 0.01) {
        lastWeight = event;
        streak = 0;
      } else {
        streak++;
        if (streak >= threshold) {
          stabilizedWeight.complete(event);
        }
      }
    });

    final finalWeight = await stabilizedWeight.future;

    await subscription.cancel();

    return finalWeight;
  }

  @override
  Future<Weight> getWeight() async {
    final source = weights ??= getWeightStream();

    return source.first;
  }

  @override
  Stream<Weight> getWeightStream() {
    final characteristic = btCharacteristic;
    final device = btDevice;
    if (device == null || characteristic == null) {
      throw StateError('Digital Scale is not connected.');
    }

    final weights = device
        .readAsStream(_serviceUuid, _characteristicUuid)
        .asBroadcastStream()
        .map((event) {
      final str = String.fromCharCodes(event);

      return Weight(1, WeightUnit.kilograms);
    });

    weightStream = weights.listen((event) {
      currentWeight = event;
    });

    this.weights = weights;

    return weights;
  }
}
