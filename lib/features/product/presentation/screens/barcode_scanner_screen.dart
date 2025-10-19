import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/animated_element.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';

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

class ScannerIconContainer extends StatelessWidget {
  const ScannerIconContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ResponsiveUI.value(context, 160),
      height: ResponsiveUI.value(context, 160),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.linkBlue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: ResponsiveUI.value(context, 120),
          height: ResponsiveUI.value(context, 120),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.linkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.qr_code_scanner,
            size: ResponsiveUI.iconSize(context, 60),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class ScanButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ScanButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: ResponsiveUI.value(context, 56),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.linkBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 16),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: ResponsiveUI.iconSize(context, 24),
                ),
                SizedBox(width: ResponsiveUI.spacing(context, 12)),
                Text(
                  'Start Scanning',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InstructionsCard extends StatelessWidget {
  const InstructionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 16),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 8),
                  ),
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppColors.primaryBlue,
                  size: ResponsiveUI.iconSize(context, 20),
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 12)),
              Text(
                'Instructions',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          InstructionItem(
            number: '1',
            text: 'Tap "Start Scanning" button',
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          InstructionItem(
            number: '2',
            text: 'Point camera at the barcode',
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          InstructionItem(
            number: '3',
            text: 'Wait for automatic detection',
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          InstructionItem(
            number: '4',
            text: 'View product details instantly',
          ),
        ],
      ),
    );
  }
}

class InstructionItem extends StatelessWidget {
  final String number;
  final String text;

  const InstructionItem({
    Key? key,
    required this.number,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: ResponsiveUI.value(context, 28),
          height: ResponsiveUI.value(context, 28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.linkBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }
}