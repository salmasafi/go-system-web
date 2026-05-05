import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/features/pos/checkout/model/reciept_data.dart';

import 'printer_mobile.dart' as mobile;

part 'printer_state.dart';

class PrinterCubit extends Cubit<PrinterState> {
  PrinterCubit() : super(PrinterInitial());

  dynamic _printer;

  Future<dynamic> findPrinter() async {
    if (kIsWeb) return null;
    return await mobile.findPrinter();
  }

  Future<bool> printReceipt(
    BuildContext context, {
    required RecieptData receipt,
  }) async {
    if (kIsWeb) {
      developer.log('Printing not supported on web');
      return false;
    }
    return await mobile.printReceipt(context, receipt: receipt);
  }

  Future<void> disconnect() async {
    if (kIsWeb) return;
    await mobile.disconnectPrinter(_printer);
  }
}
