import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/pos/checkout/model/reciept_data.dart';
import '../../presentation/widgets/printable_reciept.dart';
part 'printer_state.dart';

class PrinterCubit extends Cubit<PrinterState> {
  PrinterCubit() : super(PrinterInitial());

  BluetoothDevice? _printer;
  BluetoothCharacteristic? _char;

  Future<BluetoothDevice?> findPrinter() async {
    if (_printer != null && _printer!.isConnected) return _printer;

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

      if (!context.mounted) return false;
      final bytes = await _generateReceiptImage(context, receipt: receipt);

      if (bytes.isEmpty) return false;

      await _sendInChunks(bytes, _char!, device: device);
      return true;
    } catch (e) {
      developer.log('Print error: $e');
      return false;
    }
  }

  Future<List<int>> _generateReceiptImage(
    BuildContext context, {
    required RecieptData receipt,
  }) async {
    // FIX 1: Set Target Width to 576 (Standard for 58mm printers)
    const int targetWidth = 576;

    final GlobalKey repaintKey = GlobalKey();
    final Completer<ui.Image> completer = Completer();

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: repaintKey,
              child: Center(
                child: Container(
                  color: Colors.white,
                  width: targetWidth.toDouble(),
                  child: PrintableReceipt(recieptData: receipt),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) throw Exception('Context unmounted during rendering');

    try {
      final render =
          repaintKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      // FIX 2: Capture at 2x or 3x resolution for sharpness, then we resize down
      final image = await render.toImage(pixelRatio: 3);
      completer.complete(image);
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      return [];
    }

    final image = await completer.future;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return [];

    final pngBytes = byteData.buffer.asUint8List();
    img.Image? processed = img.decodePng(pngBytes);
    if (processed == null) return [];

    // FIX 3: Resize DOWN to 384px.
    // Capturing high (3x) and resizing down makes text very crisp.
    processed = img.copyResize(processed, width: targetWidth);

    // Grayscale & Binarization
    processed = img.grayscale(processed);
    for (int y = 0; y < processed.height; y++) {
      for (int x = 0; x < processed.width; x++) {
        final p = processed.getPixel(x, y);
        final gray = (p.r * 0.299 + p.g * 0.587 + p.b * 0.114).round();
        final value = gray > 140 ? 255 : 0;
        processed.setPixel(x, y, img.ColorRgb8(value, value, value));
      }
    }

    // Smart Crop (Bottom Only)
    int lastRow = processed.height - 1;
    const int cleanRows = 30;
    const double maxFillRatio = 0.12;
    const double maxWidthRatio = 0.35;
    final white = img.ColorRgb8(255, 255, 255);
    for (int offset = 0; offset < cleanRows; offset++) {
      final int y = processed.height - 1 - offset;
      if (y < 0) break;
      int blackCount = 0;
      int minX = processed.width;
      int maxX = -1;
      for (int x = 0; x < processed.width; x++) {
        if (processed.getPixel(x, y).r == 0) {
          blackCount++;
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
        }
      }
      if (blackCount == 0) continue;
      final double fillRatio = blackCount / processed.width;
      final double widthRatio = maxX > minX
          ? (maxX - minX) / processed.width
          : 0;
      if (fillRatio <= maxFillRatio && widthRatio <= maxWidthRatio) {
        for (int x = 0; x < processed.width; x++) {
          processed.setPixel(x, y, white);
        }
        continue;
      }
      break;
    }
    for (int y = processed.height - 1; y >= 0; y--) {
      bool hasBlack = false;
      for (int x = 0; x < processed.width; x++) {
        if (processed.getPixel(x, y).r == 0) {
          hasBlack = true;
          break;
        }
      }
      if (hasBlack) {
        lastRow = y;
        break;
      }
    }

    int cropHeight = lastRow; // Minimal bottom padding
    if (cropHeight > processed.height) cropHeight = processed.height;

    img.Image cropped = img.copyCrop(
      processed,
      x: 0,
      y: 0,
      width: processed.width,
      height: cropHeight,
    );

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

  Future<BluetoothCharacteristic?> _getWriteCharacteristic(
    BluetoothDevice d,
  ) async {
    final services = await d.discoverServices();
    for (var s in services) {
      for (var c in s.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) return c;
      }
    }
    return null;
  }

  Future<void> disconnect() async => await _printer?.disconnect();
}
