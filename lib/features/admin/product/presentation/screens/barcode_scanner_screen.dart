import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/animation/animated_element.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import '../widgets/instruction_card_and_item.dart';
import '../widgets/scan_widgets.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  String _currentInput = ''; // لتجميع إدخال القارئ الخارجي
  bool _isListeningForExternal = false; // جديد: التحكم في وضع الاستماع للخارجي

  Future<void> _startScanning() async {
    // مسح بالكاميرا الخلفية
    String? result = await SimpleBarcodeScanner.scanBarcode(
      context,
      cameraFace: CameraFace.back, // ضمان الكاميرا الخلفية
      isShowFlashIcon: true,
    );

    if (result != null) {
      log('Camera scanned: $result'); // Debug
      if (mounted) {
        Navigator.pop(context, result);
      }
    }
  }

  void _startExternalScanning() {
    setState(() {
      _isListeningForExternal = true;
      _currentInput = ''; // مسح أي إدخال سابق
    });
    log('External scanner mode activated'); // Debug
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWithActions(context, title: 'Scan Barcode'),
      body: SingleChildScrollView(
        child: Center(
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
                      _isListeningForExternal
                          ? 'Ready for external scan...\nPoint your scanner and press Enter after reading.'
                          : 'Point your camera at the product barcode\nto search for it instantly',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 15),
                        color: AppColors.darkGray.withValues(alpha: 0.6),
                        height: ResponsiveUI.value(context, 1.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 18)),

                  // زر المسح بالكاميرا
                  AnimatedElement(
                    delay: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _startScanning,
                        icon: Icon(Icons.camera_alt),
                        label: const Text('Scan with Camera'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppColors.primaryBlue,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUI.padding(context, 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  // زر المسح بالقارئ الخارجي
                  AnimatedElement(
                    delay: const Duration(milliseconds: 300),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isListeningForExternal
                            ? null
                            : _startExternalScanning, // تعطيل إذا مفعل
                        icon: Icon(Icons.usb),
                        label: Text(
                          _isListeningForExternal
                              ? 'Listening...'
                              : 'Scan with External Scanner',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isListeningForExternal
                              ? AppColors.shadowGray
                              : AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: ResponsiveUI.padding(context, 16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_isListeningForExternal) ...[
                    SizedBox(height: ResponsiveUI.spacing(context, 16)),
                    // عرض الإدخال الحالي (اختياري، للاختبار)
                    AnimatedElement(
                      delay: const Duration(milliseconds: 400),
                      child: Text(
                        'Current input: $_currentInput',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14),
                          color: AppColors.darkGray,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
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
      ),
    );
  }
}
