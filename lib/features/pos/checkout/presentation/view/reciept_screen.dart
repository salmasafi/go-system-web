import 'package:flutter/material.dart';
import 'package:systego/features/POS/checkout/model/reciept_data.dart';
import 'dart:async';
import '../../cubit/printer_cubit/printer_cubit.dart';
import '../widgets/printable_reciept.dart';

class ReceiptPreviewScreen extends StatefulWidget {
  final RecieptData recieptData;
  const ReceiptPreviewScreen({super.key, required this.recieptData});

  @override
  State<ReceiptPreviewScreen> createState() => _ReceiptPreviewScreenState();
}

class _ReceiptPreviewScreenState extends State<ReceiptPreviewScreen> {
  final PrinterCubit printerCubit = PrinterCubit();
  String status = 'Searching for your printer';
  bool printing = false;

  @override
  void initState() {
    super.initState();
    _findPrinter();
  }

  void _findPrinter() async {
    final device = await printerCubit.findPrinter();
    setState(
      () => status = device != null
          ? 'Your printer is found'
          : "Your printer is not connected",
    );
  }

  Future<void> _print() async {
    if (printing) return;
    setState(() => printing = true);

    final success = await printerCubit.printReceipt(
      context,
      receipt: widget.recieptData,
    );

    setState(() {
      printing = false;
      status = success ? "Reciept is printed successfully!" : "Printing failed";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("SYSTEGO Thermal Printer")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(status, style: TextStyle(fontSize: 20)),
              SizedBox(height: 40),
              SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    width: 384,
                    color: Colors.white,
                    child: PrintableReceipt(recieptData: widget.recieptData),
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: printing ? null : _print,
                icon: Icon(Icons.print, size: 30),
                label: Text("Reciept Printing", style: TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
