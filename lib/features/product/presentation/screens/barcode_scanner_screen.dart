import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import '../widgets/instruction_card_and_item.dart';
import '../widgets/scan_widgets.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String? scannedCode;

  Future<void> _startScanning() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (result != null && result != '-1') {
      setState(() {
        scannedCode = result;
      });
      // Return the scanned code to the previous screen
      if (mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        'Scan Barcode',
        () => Navigator.pop(context),
        showActions: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUI.contentMaxWidth(context),
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedElement(
                  delay: Duration.zero,
                  child: ScannerIconContainer(),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 32)),
                AnimatedElement(
                  delay: const Duration(milliseconds: 100),
                  child: Text(
                    'Scan Product Barcode',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 24),
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                AnimatedElement(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Point your camera at the product barcode\nto search for it instantly',
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 15),
                      color: AppColors.darkGray.withOpacity(0.6),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 48)),
                AnimatedElement(
                  delay: const Duration(milliseconds: 300),
                  child: ScanButton(onPressed: _startScanning),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 24)),
                AnimatedElement(
                  delay: const Duration(milliseconds: 400),
                  child: InstructionsCard(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


