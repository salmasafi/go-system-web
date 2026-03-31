import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';

import 'package:systego/features/admin/categories/view/widgets/build_image_placeholder_widget.dart';
import 'package:systego/features/admin/purchase/cubit/purchase_cubit.dart';
import 'package:systego/features/admin/purchase/model/purchase_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

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
    final maxWidth = ResponsiveUI.contentMaxWidth(context);
    
    return BlocConsumer<PurchaseCubit, PurchaseState>(
      listener: (context, state) {
        if (state is UpdatePurchaseSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is UpdatePurchaseError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdatePurchaseLoading;

        return Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 243, 249, 254),
            borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveUI.borderRadius(context, 24))),
          ),
          child: Material(
             color: Colors.transparent,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: ResponsiveUI.value(context, 40), height: ResponsiveUI.value(context, 4),
                      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 2))),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 12)),
                  Text(
                    "Edit Purchase",
                    style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 20), fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
            
                  _buildTextField(controller: _referenceController, title: "Reference", hint: "Ref No"),
                  _buildTextField(controller: _dateController, title: "Date", hint: "YYYY-MM-DD"),
                  _buildTextField(controller: _noteController, title: "Note", hint: "Note"),
                  
                  Row(
                    children: [
                      Expanded(child: _buildTextField(controller: _shippingCostController, title: "Shipping", hint: "0")),
                      SizedBox(width: ResponsiveUI.value(context, 16)),
                      Expanded(child: _buildTextField(controller: _discountController, title: "Discount", hint: "0")),
                    ],
                  ),
            
                  _buildImagePicker(
                    selectedLocalImage: _selectedImage,
                    existingImageUrl: widget.purchase.receiptImg,
                    title: "Receipt Image",
                    onPick: _pickImage,
                    onRemove: _removeImage,
                  ),
            
                  SizedBox(height: ResponsiveUI.value(context, 24)),
                  CustomElevatedButton(
                    onPressed: isLoading ? null : _submitUpdate,
                    text: isLoading ? "Updating..." : "Update Purchase",
                    isLoading: isLoading,
                  ),
                  SizedBox(height: ResponsiveUI.value(context, 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
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