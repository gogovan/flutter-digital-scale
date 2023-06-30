import 'dart:async';

import 'package:flutter_device_searcher/device/bluetooth/bluetooth_device.dart';
import 'package:flutter_device_searcher/device/bluetooth/bluetooth_service.dart';
import 'package:flutter_device_searcher/device_searcher/bluetooth_searcher.dart';
import 'package:flutter_device_searcher/search_result/bluetooth_result.dart';
import 'package:flutter_digital_scale/digital_scale_interface.dart';
import 'package:flutter_digital_scale/weight.dart';

/// Interface a Wuxianliang WXL-T12 Digital Scale.
class WXLT12 implements DigitalScaleInterface {
  static const String _bluetoothName = 'WXL-T12.4.0';
  static const String _serviceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
  static const String _characteristicUuid =
      '0000ffe1-0000-1000-8000-00805f9b34fb';

  final BluetoothSearcher _btSearcher = BluetoothSearcher();
  BluetoothDevice? _btDevice;
  BluetoothCharacteristic? _btCharacteristic;

  StreamSubscription<List<BluetoothResult>>? _searchedDevices;

  Stream<Weight>? _weights;
  StreamSubscription<Weight>? _weightStream;

  @override
  Future<void> connect(
    Duration timeout,
    void Function() onConnected,
  ) async {
    _searchedDevices =
        _btSearcher.search().listen(cancelOnError: true, (event) async {
      final device = event.where((element) => element.name == _bluetoothName);

      if (device.isNotEmpty) {
        await _searchedDevices?.cancel();
        final btDevice = BluetoothDevice(_btSearcher, device.first);
        if (await btDevice.connect()) {
          // 1 second delay added because otherwise getServices would fail with device already connected error. (Not sure why).
          // ignore: avoid-ignoring-return-values, not needed.
          await Future.delayed(const Duration(seconds: 1));

          final services = await btDevice.getServices();
          final service = services.where(
            (s) =>
                s.serviceId == _serviceUuid &&
                s.characteristics
                    .any((c) => c.characteristicId == _characteristicUuid),
          );

          if (service.isNotEmpty) {
            final selectedService = service.first;

            _btDevice = btDevice;
            _btCharacteristic = selectedService.characteristics
                .where(
                  (element) => element.characteristicId == _characteristicUuid,
                )
                .first;

            onConnected();
          }
        }
      }
    });
  }

  @override
  Future<void> disconnect() async {
    await _weightStream?.cancel();
    await _searchedDevices?.cancel();
  }

  @override
  Future<Weight> getStabilizedWeight(int threshold, Duration timeout) async {
    final source = _weights ??= getWeightStream();

    final stabilizedWeight = Completer<Weight>();

    var lastWeight = Weight(0, WeightUnit.kilograms);
    var streak = 0;

    final subscription = source.timeout(timeout).listen((event) {
      if ((lastWeight.toKilograms() - event.toKilograms()).abs() > 0.01 ||
          event.toKilograms() < 0.01) {
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
    final source = _weights ??= getWeightStream();

    return source.first;
  }

  @override
  Stream<Weight> getWeightStream() {
    final characteristic = _btCharacteristic;
    final device = _btDevice;
    if (device == null || characteristic == null) {
      throw StateError('Digital Scale is not connected.');
    }

    final weights = device
        .readAsStream(_serviceUuid, _characteristicUuid)
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
        );

    _weights = weights;

    return weights;
  }
}
