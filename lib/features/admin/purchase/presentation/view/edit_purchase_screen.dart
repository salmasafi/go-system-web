import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';

import 'package:GoSystem/features/admin/categories/view/widgets/build_image_placeholder_widget.dart';
import 'package:GoSystem/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:GoSystem/features/admin/purchase/model/purchase_model.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class EditPurchaseBottomSheet extends StatefulWidget {
  final Purchase purchase;

  const EditPurchaseBottomSheet({super.key, required this.purchase});

  @override
  State<EditPurchaseBottomSheet> createState() => _EditPurchaseBottomSheetState();
}

class _EditPurchaseBottomSheetState extends State<EditPurchaseBottomSheet> {
  late final TextEditingController _referenceController;
  late final TextEditingController _noteController;
  late final TextEditingController _shippingCostController;
  late final TextEditingController _discountController;
  late final TextEditingController _dateController;
  File? _selectedImage;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(text: widget.purchase.reference);
    _noteController = TextEditingController(text: widget.purchase.note ?? "");
    _shippingCostController = TextEditingController(text: widget.purchase.shippingCost.toString());
    _discountController = TextEditingController(text: widget.purchase.discount.toString());
    _dateController = TextEditingController(text: widget.purchase.date.toString());
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _noteController.dispose();
    _shippingCostController.dispose();
    _discountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _submitUpdate() {
    if (_referenceController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, "Reference is required");
      return;
    }

    // context.read<PurchaseCubit>().updatePurchase(
    //   purchaseId: widget.purchase.id,
    //   reference: _referenceController.text.trim(),
    //   date: _dateController.text.trim(),
    //   shippingCost: double.tryParse(_shippingCostController.text.trim()),
    //   discount: double.tryParse(_discountController.text.trim()),
    //   note: _noteController.text.trim(),
    //   receiptImage: _selectedImage,
    // );
  }

  @override
  Widget build(BuildContext context) {
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.edit_purchase.tr(),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'Edit Purchase Screen - Under Development',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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

  Widget _buildTextField({required TextEditingController controller, required String title, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.value(context, 16)),
        Text(title, style: TextStyle(color: AppColors.darkGray, fontWeight: FontWeight.w500)),
        SizedBox(height: ResponsiveUI.value(context, 8)),
        CustomTextField(controller: controller, labelText: '', hintText: hint, hasBoxDecoration: false, hasBorder: true),
      ],
    );
  }

  Widget _buildImagePicker({
    required File? selectedLocalImage,
    required String existingImageUrl,
    required String title,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    final displayImage = selectedLocalImage != null
        ? Image.file(selectedLocalImage, fit: BoxFit.cover)
        : (existingImageUrl.isNotEmpty
            ? Image.network(existingImageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const CustomImagePlaceholder())
            : const CustomImagePlaceholder());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.value(context, 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: AppColors.darkGray, fontWeight: FontWeight.w500)),
            if (selectedLocalImage != null)
              TextButton.icon(icon: Icon(Icons.delete, color: Colors.red, size: ResponsiveUI.iconSize(context, 18)), label: Text("Remove", style: TextStyle(color: Colors.red)), onPressed: onRemove),
          ],
        ),
        SizedBox(height: ResponsiveUI.value(context, 8)),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: ResponsiveUI.value(context, 120), height: ResponsiveUI.value(context, 120),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)), border: Border.all(color: Colors.grey)),
            child: ClipRRect(borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)), child: displayImage),
          ),
        ),
      ],
    );
  }
}
