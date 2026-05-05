// Mobile implementation with Bluetooth and ESC/POS support
// This file is imported when dart.library.io IS available (Mobile/Desktop)

import 'dart:async';
import 'dart:math' as math;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as developer;

Future<BluetoothDevice?> findPrinterMobile() async {
  await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));
  await for (var results in FlutterBluePlus.scanResults) {
    for (var r in results) {
      if (r.device.platformName.contains("XP-P323B") ||
          r.device.remoteId.toString().toLowerCase().contains(
            "dd:0d:30:d5:7c:6c",
          )) {
        await FlutterBluePlus.stopScan();
        return r.device;
      }
    }
  }
  await FlutterBluePlus.stopScan();
  return null;
}

Future<List<int>> generateEscPosCommands(img.Image cropped) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);

  return [
    ...generator.reset(),
    ...generator.imageRaster(
      cropped,
      highDensityHorizontal: true,
      highDensityVertical: true,
    ),
    ...generator.cut(),
  ];
}

Future<void> sendInChunksMobile(
  List<int> data,
  BluetoothCharacteristic char, {
  BluetoothDevice? device,
}) async {
  developer.log('Starting optimized print with ${data.length} bytes');

  await char.write([0x1B, 0x40], withoutResponse: false);
  await Future.delayed(const Duration(milliseconds: 40));

  await char.write([0x1B, 0x3D, 0x01], withoutResponse: false);
  await Future.delayed(const Duration(milliseconds: 10));

  final bool useWithoutResponse = char.properties.writeWithoutResponse;
  final printer = device;
  final int mtuNow = math.max(23, printer?.mtuNow ?? 23);
  final int mtuLimited = math.max(1, mtuNow - 3);
  final int chunkSize = useWithoutResponse ? math.min(256, mtuLimited) : 512;
  int totalSent = 0;

  for (int i = 0; i < data.length; i += chunkSize) {
    final end = i + chunkSize > data.length ? data.length : i + chunkSize;
    final chunk = data.sublist(i, end);

    await char.write(chunk, withoutResponse: useWithoutResponse);
    totalSent += chunk.length;
    await Future.delayed(const Duration(milliseconds: 5));
  }

  developer.log('Total bytes sent: $totalSent');

  await Future.delayed(const Duration(milliseconds: 80));
  await char.write([0x1B, 0x64, 0x03], withoutResponse: false);
  await Future.delayed(const Duration(milliseconds: 30));
  await char.write([0x0C], withoutResponse: false);
  await Future.delayed(const Duration(milliseconds: 10));
}

Future<BluetoothCharacteristic?> getWriteCharacteristicMobile(BluetoothDevice d) async {
  final services = await d.discoverServices();
  for (var s in services) {
    for (var c in s.characteristics) {
      if (c.properties.write || c.properties.writeWithoutResponse) return c;
    }
  }
  return null;
}

Future<void> disconnectMobile(BluetoothDevice? printer) async {
  await printer?.disconnect();
}
