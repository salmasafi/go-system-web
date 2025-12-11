import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/widgets/custom_drop_down_menu.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';
import '../../cubit/payment_method_cubit.dart';
import '../../cubit/payment_method_state.dart';
import '../../model/payment_method_model.dart';

class PaymentMethodFormDialog extends StatefulWidget {
  final PaymentMethodModel? paymentMethod;
  final String? existingImageUrl;

  const PaymentMethodFormDialog({super.key, this.paymentMethod, this.existingImageUrl});

  @override
  State<PaymentMethodFormDialog> createState() =>
      _PaymentMethodFormDialogState();
}

class _PaymentMethodFormDialogState extends State<PaymentMethodFormDialog>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.paymentMethod != null;
   String? selectedtaxType;
   File? _selectedImage;
   final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    // Common setup for both modes
    if (isEditMode) {
      _nameController.text = widget.paymentMethod!.name;
      _arNameController.text = widget.paymentMethod!.arName;
      _typeController.text = widget.paymentMethod!.type;
      _descriptionController.text = widget.paymentMethod!.description;
      selectedtaxType =
          widget.paymentMethod!.type[0].toUpperCase() +
          widget.paymentMethod!.type.substring(1).toLowerCase();

          log("selected ${_selectedImage}");
    }
  }

  
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        final pickedFileAsFile = File(pickedFile.path);

        _selectedImage = pickedFileAsFile;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }


  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arNameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);
    final maxHeight = ResponsiveUI.screenHeight(context) * 0.85;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<PaymentMethodCubit, PaymentMethodState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreatePaymentMethodLoading ||
                state is UpdatePaymentMethodLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PaymentMethodDialogHeader(
                    isEditMode: isEditMode,
                    onClose: () => Navigator.of(context).pop(),
                  ),
                  Flexible(
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          padding: EdgeInsets.all(
                            ResponsiveUI.padding(context, 24),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                 _buildImagePicker(context),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _nameController,
                                  label: 'Payment Method Name (EN)',
                                  icon: Icons.attach_money_rounded,
                                  hint: 'Enter payment method name in English',
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        'payment method name in english',
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _arNameController,
                                  label: 'Payment Method Name (AR)',
                                  icon: Icons.attach_money_rounded,
                                  hint: 'Enter payment method name in Arabic',
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        'payment method name in arabic',
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                  buildDropdownField<String>(
                                  context,
                                  value: selectedtaxType,
                                  items: ["manual", "automatic"],
                                  label: 'Tax Type',
                                  icon: Icons.attach_money_rounded,

                                  hint: 'Select Tax Type',
                                  onChanged: (value) {
                                    setState(() {
                                      selectedtaxType = value;
                                    });
                                  },
                                  itemLabel: (type) => type,
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select a tax type';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _descriptionController,
                                  keyboardType: TextInputType.number,
                                  label: 'Description',
                                  icon: Icons.description,
                                  hint: 'Enter description',
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        'description',
                                      ),
                                  maxLines: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  PaymentMethodDialogButtons(
                    isEditMode: isEditMode,
                    isLoading: isLoading,
                    onCancel: () => Navigator.of(context).pop(),
                    onSubmit: _handleSubmit,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  BoxDecoration _buildDialogDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 24),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.2),
          blurRadius: ResponsiveUI.value(context, 30),
          offset: Offset(0, ResponsiveUI.value(context, 10)),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, PaymentMethodState state) {
    if (state is CreatePaymentMethodSuccess ||
        state is UpdatePaymentMethodSuccess) {
      Navigator.of(context).pop();
    }

    if (state is CreatePaymentMethodError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdatePaymentMethodError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  
  Widget _buildImagePicker(BuildContext context) {
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final iconSize40 = ResponsiveUI.iconSize(context, 40);
    final fontSize14 = ResponsiveUI.fontSize(context, 14);
    final height120 = ResponsiveUI.value(context, 120);
    final spacing8 = ResponsiveUI.spacing(context, 8);
    final padding8 = ResponsiveUI.padding(context, 8);
    final iconSize24 = ResponsiveUI.iconSize(context, 24);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Payment Icon",
          style: TextStyle(
            fontSize: fontSize14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: spacing8),
        if (_selectedImage != null)
          Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: double.infinity,
                height: height120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius12),
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius12 - 2),
                  child: Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: _clearImage,
                  child: Container(
                    padding: EdgeInsets.all(padding8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: iconSize24,
                    ),
                  ),
                ),
              ),
            ],
          )
        else if (widget.existingImageUrl != null &&
            widget.existingImageUrl!.isNotEmpty)
          Builder(
            builder: (context) {
              final isBase64 = widget.existingImageUrl!.startsWith('data:');

              Widget imageWidget;

              if (isBase64) {

                final parts = widget.existingImageUrl!.split(',');

                if (parts.length == 2) {
                  try {
                    final bytes = base64Decode(parts[1]);

                    imageWidget = Image.memory(
                      bytes,

                      fit: BoxFit.cover,

                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorPlaceholder(),
                    );
                  } catch (_) {
                    imageWidget = _buildErrorPlaceholder();
                  }
                } else {
                  imageWidget = _buildErrorPlaceholder();
                }
              } else {
                // Handle regular Network URL

                imageWidget = Image.network(
                  widget.existingImageUrl!,

                  fit: BoxFit.cover,

                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,

                        color: AppColors.primaryBlue,
                      ),
                    );
                  },

                  errorBuilder: (context, error, stackTrace) {
                    return _buildErrorPlaceholder();
                  },
                );
              }

              return Stack(
                alignment: Alignment.topRight,

                children: [
                  Container(
                    width: double.infinity,

                    height: height120,

                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius12),

                      border: Border.all(color: Colors.grey[300]!, width: 2),
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(borderRadius12 - 2),

                      child:
                          imageWidget,
                    ),
                  ),

                   Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.all(padding8),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: iconSize24,
                  ),
                ),
              ),
            ),

                ],
              );
            },
          )
        else
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: height120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius12),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                color: Colors.grey[50],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: iconSize40,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(height: spacing8),
                  Text(
                    LocaleKeys.tap_to_select_image.tr(),
                    style: TextStyle(
                      fontSize: fontSize14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final height120 = ResponsiveUI.value(context, 120);
    return Container(
      width: double.infinity,
      height: height120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(borderRadius12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image_outlined, size: 40, color: Colors.grey[400]),
          SizedBox(height: 8),
          Text(
            LocaleKeys.failed_to_load_image.tr(),
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      
      final cubit = context.read<PaymentMethodCubit>();
      if (isEditMode) {
        cubit.updatePaymentMethod(
          paymentMethodId: widget.paymentMethod!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          type: selectedtaxType!.toLowerCase(),
          description: _descriptionController.text.trim(),
          isActive: true,
          icon: _selectedImage,
        );
      } else {
        cubit.createPaymentMethod(
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          type: selectedtaxType!.toLowerCase(),
          description: _descriptionController.text.trim(),
          isActive: true,
          icon: _selectedImage,
        );
      }
    }
  }
}

// PaymentMethodDialogHeader and PaymentMethodDialogButtons remain unchanged
class PaymentMethodDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const PaymentMethodDialogHeader({
    super.key,
    required this.isEditMode,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final paddingHorizontal = ResponsiveUI.padding(context, 24);
    final paddingVertical = ResponsiveUI.padding(context, 20);
    final iconSize28 = ResponsiveUI.iconSize(context, 28);
    final fontSize22 = ResponsiveUI.fontSize(context, 22);
    final fontSize13 = ResponsiveUI.fontSize(context, 13);
    final spacing16 = ResponsiveUI.spacing(context, 16);
    final padding10 = ResponsiveUI.padding(context, 10);
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
    final iconSize24 = ResponsiveUI.iconSize(context, 24);
    final padding8 = ResponsiveUI.padding(context, 8);
    final borderRadius20 = ResponsiveUI.borderRadius(context, 20);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: paddingHorizontal,
        vertical: paddingVertical,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius24),
          topRight: Radius.circular(borderRadius24),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(padding10),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(borderRadius12),
            ),
            child: Icon(
              isEditMode ? Icons.edit : Icons.add,
              color: AppColors.white,
              size: iconSize28,
            ),
          ),
          SizedBox(width: spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Edit Payment Method' : 'New Payment Method',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode
                      ? 'Update Payment Method details'
                      : 'Add a new Payment Method',
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: fontSize13,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius20),
              onTap: onClose,
              child: Container(
                padding: EdgeInsets.all(padding8),
                child: Icon(
                  Icons.close,
                  color: AppColors.white,
                  size: iconSize24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const PaymentMethodDialogButtons({
    super.key,
    required this.isEditMode,
    required this.isLoading,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final padding24 = ResponsiveUI.padding(context, 24);
    final borderRadius24 = ResponsiveUI.borderRadius(context, 24);
    final borderRadius12 = ResponsiveUI.borderRadius(context, 12);
    final padding16 = ResponsiveUI.padding(context, 16);
    final value1_5 = ResponsiveUI.value(context, 1.5);
    final fontSize16 = ResponsiveUI.fontSize(context, 16);
    final padding12 = ResponsiveUI.padding(context, 12);
    final value14 = ResponsiveUI.fontSize(context, 14);
    final iconSize20 = ResponsiveUI.iconSize(context, 20);
    final spacing8 = ResponsiveUI.spacing(context, 8);
    final spacing16 = ResponsiveUI.spacing(context, 16);

    return Container(
      padding: EdgeInsets.all(padding24),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(borderRadius24),
          bottomRight: Radius.circular(borderRadius24),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : onCancel,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: padding16),
                side: BorderSide(
                  color: AppColors.shadowGray[300]!,
                  width: value1_5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: fontSize16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.shadowGray[700],
                ),
              ),
            ),
          ),
          SizedBox(width: spacing16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(
                  vertical: padding16,
                  horizontal: padding12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEditMode
                        ? Icons.check_circle_outline
                        : Icons.add_circle_outline,
                    size: iconSize20,
                  ),
                  SizedBox(width: spacing8),
                  Flexible(
                    child: Text(
                      isEditMode
                          ? 'Update Payment Method'
                          : 'Create Payment Method',
                      style: TextStyle(
                        fontSize: value14,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
