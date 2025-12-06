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
    // INCREASED WIDTH: 576 is standard for 80mm printers (Bigger receipt)
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
              child: Container(
                color: Colors.white,
                width: targetWidth.toDouble(), // 576px Width
                child: PrintableReceipt(recieptData: receipt),
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
      // High Quality Capture (3x resolution)
      final image = await render.toImage(pixelRatio: 3.0);
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

    // Resize to the larger target width (576)
    processed = img.copyResize(processed, width: targetWidth);

    // Grayscale & Binarization (Making text black and crisp)
    processed = img.grayscale(processed);
    for (int y = 0; y < processed.height; y++) {
      for (int x = 0; x < processed.width; x++) {
        final p = processed.getPixel(x, y);
        final gray = (p.r * 0.299 + p.g * 0.587 + p.b * 0.114).round();
        final value = gray > 140 ? 255 : 0;
        processed.setPixel(x, y, img.ColorRgb8(value, value, value));
      }
    }

    // --- SMART CROP (BOTTOM ONLY) ---
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

    // Add padding at the bottom for the paper cutter
    int cropHeight = lastRow + 30;
    if (cropHeight > processed.height) cropHeight = processed.height;

    img.Image cropped = img.copyCrop(
      processed,
      x: 0,
      y: 0,
      width: processed.width,
      height: cropHeight,
    );

    final profile = await CapabilityProfile.load();
    // Use PaperSize.mm80 for bigger receipts, or stick to mm58 but print the larger image
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
