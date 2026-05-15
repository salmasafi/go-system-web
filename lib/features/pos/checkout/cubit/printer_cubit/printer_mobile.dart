// Mobile implementation with Bluetooth and ESC/POS support
// Only imported on mobile/desktop platforms

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as developer;
import 'package:GoSystem/features/pos/checkout/model/reciept_data.dart';

dynamic _printer;
dynamic _char;

Future<BluetoothDevice?> findPrinter() async {
  if (_printer != null && _printer.isConnected) return _printer;

  await FlutterBluePlus.startScan(timeout: const Duration(seconds: 6));
  await for (var results in FlutterBluePlus.scanResults) {
    for (var r in results) {
      if (r.device.platformName.contains("XP-P323B") ||
          r.device.remoteId.toString().toLowerCase().contains(
            "dd:0d:30:d5:7c:6c",
          )) {
        await FlutterBluePlus.stopScan();
        _printer = r.device;
        return r.device;
      }
    }
  }
  await FlutterBluePlus.stopScan();
  return null;
}

Future<bool> printReceipt(
  BuildContext context, {
  required RecieptData receipt,
}) async {
  try {
    final device = _printer ?? await findPrinter();
    if (device == null) return false;

    if (!device.isConnected) {
      await device.connect(timeout: const Duration(seconds: 10));
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _char ??= await _getWriteCharacteristic(device);
    if (_char == null) return false;

    final bytes = await _generateReceiptBytes(context, receipt: receipt);
    if (bytes.isEmpty) return false;

    await _sendInChunks(bytes, _char!, device: device);
    return true;
  } catch (e) {
    developer.log('Print error: $e');
    return false;
  }
}

Future<List<int>> _generateReceiptBytes(
  BuildContext context, {
  required RecieptData receipt,
}) async {
  // Image generation logic here (simplified)
  return [];
}

Future<void> _sendInChunks(
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
  final int mtuNow = math.max(23, device?.mtuNow ?? _printer?.mtuNow ?? 23);
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

Future<BluetoothCharacteristic?> _getWriteCharacteristic(BluetoothDevice d) async {
  final services = await d.discoverServices();
  for (var s in services) {
    for (var c in s.characteristics) {
      if (c.properties.write || c.properties.writeWithoutResponse) return c;
    }
  }
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

Future<bool> printFromBoundary(
  BuildContext context,
  GlobalKey boundaryKey,
) async {
  try {
    final device = _printer ?? await findPrinter();
    if (device == null) return false;

    if (!device.isConnected) {
      await device.connect(timeout: const Duration(seconds: 10));
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _char ??= await _getWriteCharacteristic(device);
    if (_char == null) return false;

    // Capture widget as image via RepaintBoundary
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return false;

    final uiImage = await boundary.toImage(pixelRatio: 3.0);
    final byteData =
        await uiImage.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return false;

    final pngBytes = byteData.buffer.asUint8List();
    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) return false;

    // Resize to 58mm printer width (384px at 203dpi) and convert to grayscale
    final resized = img.copyResize(decoded, width: 384);
    final grayscale = img.grayscale(resized);

    final bytes = await generateEscPosCommands(grayscale);
    if (bytes.isEmpty) return false;

    await _sendInChunks(bytes, _char!, device: device);
    return true;
  } catch (e) {
    developer.log('printFromBoundary error: $e');
    return false;
  }
}

Future<void> disconnectPrinter(dynamic printer) async {
  await printer?.disconnect();
}
