import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(context, title: "ماسح الباركود"),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Scanner Icon
              ScannerIconContainer(),
              SizedBox(height: ResponsiveUI.spacing(context, 30)),
              
              // Camera Scanner Section
              ScanButton(
                onPressed: _startScanning,
              ),
              
              SizedBox(height: ResponsiveUI.spacing(context, 20)),
              
              // External Scanner Section
              Container(
                width: double.infinity,
                height: ResponsiveUI.value(context, 56),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                    ResponsiveUI.borderRadius(context, 16),
                  ),
                  border: Border.all(color: AppColors.primaryBlue),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _startExternalScanning,
                    borderRadius: BorderRadius.circular(
                      ResponsiveUI.borderRadius(context, 16),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.keyboard,
                            color: AppColors.primaryBlue,
                            size: ResponsiveUI.iconSize(context, 24),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Text(
                            'قارئ خارجي',
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 18),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              if (_isListeningForExternal) ...[
                SizedBox(height: ResponsiveUI.spacing(context, 20)),
                Container(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryBlue),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.keyboard_alt,
                        size: ResponsiveUI.iconSize(context, 48),
                        color: AppColors.primaryBlue,
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      Text(
                        "وضع الاستماع للقارئ الخارجي مفعل",
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 8)),
                      Text(
                        "يرجى مسح الباركود باستخدام القارئ الخارجي",
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14),
                          color: AppColors.darkGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_currentInput.isNotEmpty) ...[
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),
                        Container(
                          padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.lightGray),
                          ),
                          child: Text(
                            "الإدخال الحالي: $_currentInput",
                            style: TextStyle(
                              fontSize: ResponsiveUI.fontSize(context, 14),
                              fontFamily: 'monospace',
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // Scale down for web
    if (kIsWeb) {
      screenContent = MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: const TextScaler.linear(0.55),
        ),
        child: screenContent,
      );
    }
    return screenContent;
  }
}
