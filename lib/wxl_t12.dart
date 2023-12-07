import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_device_searcher/device/bluetooth/bluetooth_device.dart';
import 'package:flutter_device_searcher/device/bluetooth/bluetooth_service.dart';
import 'package:flutter_device_searcher/device_searcher/bluetooth_searcher.dart';
import 'package:flutter_device_searcher/search_result/bluetooth_result.dart';
import 'package:flutter_digital_scale/digital_scale_exception.dart';
import 'package:flutter_digital_scale/digital_scale_interface.dart';
import 'package:flutter_digital_scale/weight.dart';
import 'package:rxdart/rxdart.dart';

/// Interface a Wuxianliang WXL-T12 Digital Scale.
class WXLT12 implements DigitalScaleInterface {
  WXLT12()
      : _btSearcher = BluetoothSearcher(),
        _btDeviceCreator = _createBTDevice;

  @visibleForTesting
  WXLT12.withMockComponents(this._btSearcher, this._btDeviceCreator);

  static const String _bluetoothName = 'WXL-T12.4.0';
  static const String _refServiceUuid = 'ffe0';
  static const String _refCharacteristicUuid = 'ffe1';

  final BluetoothSearcher _btSearcher;
  final BluetoothDevice Function(
    BluetoothSearcher btSearcher,
    BluetoothResult btResult,
  ) _btDeviceCreator;

  BluetoothDevice? _btDevice;
  BluetoothCharacteristic? _btCharacteristic;

  StreamSubscription<Iterable<BluetoothResult>>? _searchedDevices;

  /// Number of samples to collect until deciding that the weight is now stabilized.
  int threshold = 10;

  bool _connected = false;

  static BluetoothDevice _createBTDevice(
    BluetoothSearcher btSearcher,
    BluetoothResult btResult,
  ) =>
      BluetoothDevice(btSearcher, btResult);

  @override
  Future<void> connect({
    Duration timeout = Duration.zero,
    required void Function() onConnected,
  }) async {
    final stream = _btSearcher
        .search()
        .map(
          (event) => event.where((element) => element.name == _bluetoothName),
        )
        .where((event) => event.isNotEmpty);
    if (timeout > Duration.zero) {
      stream.timeout(timeout);
    }

    _searchedDevices = stream.listen(cancelOnError: true, (event) async {
      await _searchedDevices?.cancel();
      final btDevice = _btDeviceCreator(_btSearcher, event.first);
      if (await btDevice.connect()) {
        // 1 second delay added because otherwise getServices would fail with device already connected error. (Not sure why).
        // ignore: avoid-ignoring-return-values, not needed.
        await Future.delayed(const Duration(seconds: 1));

        final services = await btDevice.getServices();
        final service = services.where(
          (s) =>
              s.serviceId.contains(_refServiceUuid) &&
              s.characteristics.any(
                (c) => c.characteristicId.contains(_refCharacteristicUuid),
              ),
        );

        if (service.isNotEmpty) {
          final selectedService = service.first;

          _btDevice = btDevice;
          _btCharacteristic = selectedService.characteristics
              .where(
                (element) =>
                    element.characteristicId.contains(_refCharacteristicUuid),
              )
              .first;

          _connected = true;
          onConnected();
          await _searchedDevices?.cancel();
        }
      } else {
        return Future.error(
          DigitalScaleException('Failed to connect to device'),
        );
      }
    });
  }

  @override
  Future<void> disconnect() async {
    await _searchedDevices?.cancel();
    await _btDevice?.disconnect();
    _btDevice = null;
    _btCharacteristic = null;
    _connected = false;
  }

  @override
  bool isConnected() => _connected;

  @override
  Future<Weight> getStabilizedWeight(Duration timeout) async {
    final source = getWeightStream();
    return source
        .firstWhere((element) => element.stable)
        .timeout(timeout)
        .then((value) => value.weight);
  }

  @override
  Future<WeightStatus> getWeight() async {
    final source = getWeightStream();

    return source.first;
  }

  @override
  Stream<WeightStatus> getWeightStream() {
    final characteristic = _btCharacteristic;
    final device = _btDevice;
    if (device == null || characteristic == null) {
      throw StateError('Digital Scale is not connected.');
    }

    final weights = device
        .readAsStream(characteristic.serviceId, characteristic.characteristicId)
        .asBroadcastStream()
        .map((event) {
          final str = String.fromCharCodes(event);

          final value =
              double.tryParse(str.substring(6, 14).replaceAll(' ', ''));
          final unit = WeightUnit.fromString(str.substring(14, 16));

          return [value, unit];
        })
        .where((event) => event.first != null && event[1] != null)
        .map(
          // ignore: avoid-non-null-assertion, checked not null
          (event) => Weight(event.first! as double, event[1]! as WeightUnit),
        )
        .bufferCount(threshold, 1)
        .map(
          (items) => WeightStatus(
            items.last,
            stable: items.every((element) => element == items.last),
          ),
        );

    return weights;
  }
}
