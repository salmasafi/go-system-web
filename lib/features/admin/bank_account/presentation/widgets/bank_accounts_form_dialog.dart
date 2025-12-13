import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/widgets/custom_drop_down_menu.dart';
import 'package:systego/features/admin/bank_account/cubit/bank_account_cubit.dart';
import 'package:systego/features/admin/bank_account/model/bank_account_model.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:systego/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';

class BankAccountFormDialog extends StatefulWidget {
  final BankAccountModel? account;
  final String? existingImageUrl;
  

  const BankAccountFormDialog({super.key, this.account, this.existingImageUrl});

  @override
  State<BankAccountFormDialog> createState() => _BankAccountFormDialogState();
}

class _BankAccountFormDialogState extends State<BankAccountFormDialog>
    with SingleTickerProviderStateMixin {
  File? _selectedImage;
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.account != null;
  bool status = true;
  bool inPos = true;
  String? selectedWareHouse;

  final _picker = ImagePicker();

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

  @override
  void initState() {
    super.initState();
    // context.read<WareHouseCubit>().getWarehouses();
    _initializeControllers();
    _setupAnimation();
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<WareHouseCubit>().getWarehouses();
  });
}


  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.account!.name;
      _balanceController.text = widget.account!.balance.toString();
      _descriptionController.text = widget.account!.description;
      status = widget.account!.status;
      inPos = widget.account!.inPos;

      selectedWareHouse = widget.account!.wareHouseId;
    }
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
    _descriptionController.dispose();
    _balanceController.dispose();
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
        child: BlocConsumer<BankAccountCubit, BankAccountState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateBankAccountLoading ||
                state is UpdateBankAccountLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              decoration: _buildDialogDecoration(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BankAccountDialogHeader(
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
                                  label: LocaleKeys.bank_name_en.tr(),
                                  icon: Icons.account_balance,
                                  hint: LocaleKeys.hint_bank_name_en,
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.bank_name_en.tr(),
                                      ),
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),

                                BlocBuilder<WareHouseCubit, WarehousesState>(
                                  builder: (context, state) {
                                    // Default values
                                    List<String> warehouseIds = [];
                                    List<String> warehouseNames = [];

                                    // Loading state
                                    if (state is WarehousesLoading) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    }

                                    // Success – we have data
                                    if (state is WarehousesLoaded) {
                                      warehouseIds = state.warehouses
                                          .map((w) => w.id)
                                          .toList();
                                      warehouseNames = state.warehouses
                                          .map((w) => w.name)
                                          .toList();
                                    }

                                    // If we have no warehouses at all (even after loading)
                                    if (warehouseIds.isEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Text(
                                          "No warehouses found",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }

                                    return buildDropdownField<String>(
                                      context,
                                      value: selectedWareHouse,
                                      items: warehouseIds,
                                      label: "Warehouse",
                                      hint: "select warehouse",
                                      icon: Icons.warehouse_rounded,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedWareHouse = value;
                                        });
                                      },
                                      itemLabel: (id) {
                                        final index = warehouseIds.indexOf(id);
                                        return index != -1
                                            ? warehouseNames[index]
                                            : 'Unknown';
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "please select warehouse";
                                        }
                                        return null;
                                      },
                                    );
                                  },
                                ),
                                // SizedBox(
                                //   height: ResponsiveUI.spacing(context, 12),
                                // ),
                                // buildTextField(
                                //   context,
                                //   controller: _accountNoController,
                                //   label: LocaleKeys.account_number.tr(),
                                //   icon: Icons.numbers,
                                //   hint: LocaleKeys.hint_account_number.tr(),
                                //   validator: (v) =>
                                //       LoginValidator.validateRequired(
                                //         v,
                                //         LocaleKeys.account_number.tr(),
                                //       ),
                                //   keyboardType: TextInputType.number,
                                // ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _balanceController,
                                  label: LocaleKeys.initial_balance.tr(),
                                  icon: Icons.attach_money_rounded,
                                  hint: LocaleKeys.hint_initial_balance.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                        v,
                                        LocaleKeys.initial_balance.tr(),
                                      ),
                                  keyboardType: TextInputType.number,
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                buildTextField(
                                  context,
                                  controller: _descriptionController,
                                  label: "Description",
                                  icon: Icons.note_alt_rounded,
                                  hint: "Enter a Discription",
                                  maxLines: 3,
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      LocaleKeys.active.tr(),
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(
                                          context,
                                          14,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Switch(
                                      value: status,
                                      onChanged: (value) {
                                        setState(() {
                                          status = value;
                                        });
                                      },
                                      activeColor: AppColors.white,
                                      activeTrackColor: AppColors.primaryBlue,
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 12),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "In POS",
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(
                                          context,
                                          14,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Spacer(),
                                    Switch(
                                      value: inPos,
                                      onChanged: (value) {
                                        setState(() {
                                          inPos = value;
                                        });
                                      },
                                      activeColor: AppColors.white,
                                      activeTrackColor: AppColors.primaryBlue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  BankAccountDialogButtons(
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
          LocaleKeys.bank_icon.tr(),
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
          // else if (widget.existingImageUrl != null &&
          //     widget.existingImageUrl!.isNotEmpty)
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

                      child: imageWidget,
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

  void _handleStateChanges(BuildContext context, BankAccountState state) {
    if (state is CreateBankAccountSuccess ||
        state is UpdateBankAccountSuccess) {
      Navigator.of(context).pop();
    }

    if (state is CreateBankAccountError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateBankAccountError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  // void _handleSubmit() {
  //   if (_formKey.currentState!.validate()) {
  //     final cubit = context.read<BankAccountCubit>();

  //     final name = _nameController.text.trim();
  //     final accountNo = _accountNoController.text;
  //     final balance = double.tryParse(_initialBalanceController.text) ?? 0;
  //     final note = _noteController.text.trim();

  //     if (isEditMode) {
  //       cubit.updateBankAccount(
  //         accountId: widget.account!.id,
  //         name: name,
  //         arName: _arNameController.text.trim(),
  //         accountNumber: accountNo,
  //         initialBalance: balance,
  //         note: note,
  //         status: status,
  //         icon: _selectedImage,
  //       );
  //     } else {
  //       cubit.addBankAccount(
  //         name: name,
  //         arName: _arNameController.text.trim(),
  //         accountNumber: accountNo,
  //         initialBalance: balance,
  //         note: note,
  //         icon: _selectedImage,
  //         status: status,
  //       );
  //     }
  //   }
  // }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<BankAccountCubit>();

      final name = _nameController.text.trim();
      final balance = double.tryParse(_balanceController.text) ?? 0.0;
      final description = _descriptionController.text.trim();
      if (selectedWareHouse == null) {
        CustomSnackbar.showError(context, "Please select a warehouse");
        return;
      }

      if (isEditMode) {
        cubit.updateBankAccount(
          accountId: widget.account!.id,
          name: name,
          balance: balance,
          description: description,
          status: status,
          inPos: inPos,
          image: _selectedImage,
          wareHouseId: selectedWareHouse!,
        );
      } else {
        cubit.addBankAccount(
          name: name,
          balance: balance,
          description: description,
          status: status,
          inPos: inPos,
          image: _selectedImage,
          wareHouseId: selectedWareHouse!,
        );
      }
    }
  }
}

class BankAccountDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const BankAccountDialogHeader({
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
                  isEditMode
                      ? LocaleKeys.edit_bank_account.tr()
                      : LocaleKeys.new_bank_account.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode
                      ? LocaleKeys.update_account_details.tr()
                      : LocaleKeys.add_new_bank_account.tr(),
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

class BankAccountDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const BankAccountDialogButtons({
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
                LocaleKeys.cancel.tr(),
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
                          ? LocaleKeys.update_account.tr()
                          : LocaleKeys.create_account.tr(),
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
