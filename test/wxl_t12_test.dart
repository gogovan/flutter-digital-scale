import 'dart:async';

import 'package:flutter_device_searcher/device/bluetooth/bluetooth_device.dart';
import 'package:flutter_device_searcher/device/bluetooth/bluetooth_service.dart';
import 'package:flutter_device_searcher/device_searcher/bluetooth_searcher.dart';
import 'package:flutter_device_searcher/search_result/bluetooth_result.dart';
import 'package:flutter_digital_scale/weight.dart';
import 'package:flutter_digital_scale/wxl_t12.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'wxl_t12_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<BluetoothSearcher>(),
  MockSpec<BluetoothDevice>(),
])
void main() {
  final btSearcher = MockBluetoothSearcher();
  final btDevice = MockBluetoothDevice();
  final wxlt12 = WXLT12.withMockComponents(btSearcher, (_, __) => btDevice);

  group('connect', () {
    when(
      btSearcher.search(
        timeout: anyNamed('timeout'),
        onTimeout: anyNamed('onTimeout'),
      ),
    ).thenAnswer(
      (realInvocation) => Stream.value([
        const BluetoothResult(
          id: 'EFA192CD',
          name: 'WXL-T12.4.0',
          serviceIds: ['ffe0'],
        ),
      ]),
    );
    when(btDevice.connect()).thenAnswer((realInvocation) async => true);
    when(btDevice.isConnected()).thenAnswer((realInvocation) => true);
    when(btDevice.connectStateStream()).thenAnswer((realInvocation) => Stream.value(true));
    when(btDevice.getServices()).thenAnswer(
      (realInvocation) async => [
        const BluetoothService(
          serviceId: 'ffe0',
          characteristics: [
            BluetoothCharacteristic(
              serviceId: 'ffe0',
              characteristicId: 'ffe1',
            ),
          ],
        ),
      ],
    );
    when(btDevice.readAsStream('ffe0', 'ffe1')).thenAnswer(
      (realInvocation) => Stream.fromIterable(
        [
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 54, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 54, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
          [83, 84, 44, 78, 84, 44, 43, 32, 32, 32, 52, 46, 49, 50, 107, 103],
        ],
      ),
    );

    test('connect/disconnect success', () async {
      final Completer<bool> completer = Completer();
      await wxlt12.connect(
        onConnected: () {
          expect(wxlt12.isConnected(), true);
          completer.complete(true);
        },
      );
      expect(await completer.future.timeout(const Duration(seconds: 5)), true);
      expect(await wxlt12.connectStateStream().toList(), [true]);

      await wxlt12.disconnect();
      expect(wxlt12.isConnected(), false);
    });

    test('getWeightStream', () async {
      final Completer<bool> completer = Completer();
      await wxlt12.connect(
        onConnected: () {
          expect(wxlt12.isConnected(), true);
          expectLater(
            wxlt12.getWeightStream(),
            emitsInOrder([
              const WeightStatus(
                Weight(4.12, WeightUnit.kilograms),
                stable: false,
              ),
              const WeightStatus(
                Weight(4.12, WeightUnit.kilograms),
                stable: false,
              ),
              const WeightStatus(
                Weight(4.12, WeightUnit.kilograms),
                stable: true,
              ),
              const WeightStatus(
                Weight(4.12, WeightUnit.kilograms),
                stable: true,
              ),
            ]),
          );
          completer.complete(true);
        },
      );

      expect(await completer.future.timeout(const Duration(seconds: 5)), true);
    });

    test('getStabilizedWeight', () async {
      final Completer<bool> completer = Completer();
      await wxlt12.connect(
        onConnected: () async {
          expect(wxlt12.isConnected(), true);
          expect(
            await wxlt12.getStabilizedWeight(const Duration(seconds: 5)),
            const Weight(4.12, WeightUnit.kilograms),
          );
          completer.complete(true);
        },
      );

      expect(await completer.future.timeout(const Duration(seconds: 5)), true);
    });

    test('getWeight', () async {
      final Completer<bool> completer = Completer();
      await wxlt12.connect(
        onConnected: () async {
          expect(wxlt12.isConnected(), true);
          expect(
            await wxlt12.getWeight(),
            const WeightStatus(
              Weight(4.12, WeightUnit.kilograms),
              stable: false,
            ),
          );
          completer.complete(true);
        },
      );

      expect(await completer.future.timeout(const Duration(seconds: 5)), true);
    });
  });
}
