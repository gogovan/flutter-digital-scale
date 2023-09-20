import 'dart:async';

import 'package:flutter_device_searcher/device/bluetooth/bluetooth_device.dart';
import 'package:flutter_device_searcher/device/bluetooth/bluetooth_service.dart';
import 'package:flutter_device_searcher/device_searcher/bluetooth_searcher.dart';
import 'package:flutter_device_searcher/search_result/bluetooth_result.dart';
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
    when(btSearcher.search()).thenAnswer(
      (realInvocation) => Stream.value([
        const BluetoothResult(
          id: 'EFA192CD',
          name: 'WXL-T12.4.0',
          serviceIds: ['ffe0'],
        ),
      ]),
    );
    when(btDevice.connect()).thenAnswer((realInvocation) async => true);
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

    test('connect success', () async {
      final Completer<bool> completer = Completer();
      await wxlt12.connect(() {
        expect(wxlt12.isConnected(), true);
        completer.complete(true);
      });
      expect(await completer.future.timeout(const Duration(seconds: 5)), true);
    });
  });
}
