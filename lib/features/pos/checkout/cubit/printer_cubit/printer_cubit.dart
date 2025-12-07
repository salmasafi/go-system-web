import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image/image.dart' as img;
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/features/POS/checkout/model/reciept_data.dart';
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

      final bytes = await _generateReceiptImage(context, receipt: receipt);

      if (bytes.isEmpty) return false;

      await _sendInChunks(bytes, _char!);
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
    // FIX 1: Set Target Width to 384 (Standard for 58mm printers)
    // 576 is too big and causes the "Cut off" bug on small printers.
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
                  padding: const EdgeInsets.only(left: 100, right: 20),
                  // Ensure container matches target width exactly
                  width: 560, // targetWidth.toDouble(),
                  child: Center(child: PrintableReceipt(recieptData: receipt)),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 500));

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

    int cropHeight = lastRow + 10; // Minimal bottom padding
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
    BluetoothCharacteristic char,
  ) async {
    await char.write([27, 64], withoutResponse: true);
    await Future.delayed(const Duration(milliseconds: 200));

    const int chunkSize = 140;

    for (int i = 0; i < data.length; i += chunkSize) {
      final end = i + chunkSize > data.length ? data.length : i + chunkSize;
      await char.write(data.sublist(i, end), withoutResponse: true);
      await Future.delayed(const Duration(milliseconds: 5));
    }
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
