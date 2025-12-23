import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/utils/validators.dart';
import 'package:systego/core/widgets/custom_drop_down_menu.dart';
import 'package:systego/core/widgets/custom_loading/build_overlay_loading.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/features/admin/cashier/cubit/cashier_cubit.dart';
import 'package:systego/features/admin/cashier/model/cashirer_model.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:systego/generated/locale_keys.g.dart';

class CashierFormDialog extends StatefulWidget {
  final CashierModel? cashier;

  const CashierFormDialog({
    super.key, 
    this.cashier,
  });

  @override
  State<CashierFormDialog> createState() => _CashierFormDialogState();
}

class _CashierFormDialogState extends State<CashierFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  
  String? selectedWarehouse;
  bool status = true;
  bool cashierActive = true;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.cashier != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.cashier!.name;
      _arNameController.text = widget.cashier!.arName;
      selectedWarehouse =  widget.cashier!.warehouse.id;
      status = widget.cashier!.status;
      cashierActive = widget.cashier!.cashierActive;
    } 
  }

  void _setupAnimation() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WareHouseCubit>().getWarehouses();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<CashierCubit, CashierState>(
          listener: _handleStateChanges,
          builder: (context, state) {
            final isLoading =
                state is CreateCashierLoading || state is UpdateCashierLoading;

            return Container(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: ResponsiveUI.screenHeight(context) * 0.85,
              ),
              decoration: _buildDecoration(context),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(
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
                                buildTextField(
                                  context,
                                  controller: _nameController,
                                  label: LocaleKeys.name.tr(),
                                  icon: Icons.person_outline,
                                  hint: LocaleKeys.enter_cashier_name.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                          v, LocaleKeys.name.tr()),
                                ),
                                SizedBox(height: 12),
                                buildTextField(
                                  context,
                                  controller: _arNameController,
                                  label: LocaleKeys.arabic_name.tr(),
                                  icon: Icons.text_fields,
                                  hint: LocaleKeys.enter_arabic_name.tr(),
                                  validator: (v) =>
                                      LoginValidator.validateRequired(
                                          v, LocaleKeys.arabic_name.tr()),
                                ),
                                SizedBox(height: 12),
                                // buildDropdownField<Warehouse>(
                                //   context,
                                //   value: selectedWarehouse,
                                //   items: widget.warehouses,
                                //   label: LocaleKeys.warehouse.tr(),
                                //   icon: Icons.store,
                                //   hint: LocaleKeys.select_warehouse.tr(),
                                //   itemLabel: (warehouse) => warehouse.name,
                                //   onChanged: (val) {
                                //     setState(() => selectedWarehouse = val);
                                //   },
                                //   validator: (v) =>
                                //       v == null ? LocaleKeys.please_select_warehouse.tr() : null,
                                // ),

                                BlocBuilder<WareHouseCubit, WarehousesState>(
                                  builder: (context, state) {
                                    if (state is WarehousesLoaded) {
                                      final ids =
                                          state.warehouses.map((e) => e.id).toList();
                                      final names = state.warehouses
                                          .map((e) => e.name)
                                          .toList();

                                      return buildDropdownField<String>(
                                        context,
                                        value: selectedWarehouse,
                                        items: ids,
                                        label: LocaleKeys.warehouse.tr(),
                                        hint: LocaleKeys.select_warehouse.tr(),
                                        onChanged: (v) =>
                                            setState(() => selectedWarehouse = v),
                                        itemLabel: (id) {
                                          final i = ids.indexOf(id);
                                          return i != -1 ? names[i] : '';
                                        },
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                                SizedBox(height: 20),
                                _buildStatusSwitches(context),
                                SizedBox(height: 20),
                                if (isEditMode) _buildInfoSection(context),
                              ],
                            ),
                          ),
                        ),
                        if (isLoading) buildLoadingOverlay(context, 45),
                      ],
                    ),
                  ),
                  CashierDialogButtons(
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

  Widget _buildStatusSwitches(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.status.tr(),
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: 12),
        Card(
          color: AppColors.lightBlueBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
          ),
          child: Padding(
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.cashier_status.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                        color: AppColors.darkGray,
                      ),
                    ),
                    Switch(
                      value: status,
                      onChanged: (value) {
                        setState(() => status = value);
                      },
                      activeColor: AppColors.successGreen,
                    ),
                  ],
                ),
                Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.cashier_active.tr(),
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                        color: AppColors.darkGray,
                      ),
                    ),
                    Switch(
                      value: cashierActive,
                      onChanged: (value) {
                        setState(() => cashierActive = value);
                      },
                      activeColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Card(
      color: AppColors.lightBlueBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.additional_info.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  LocaleKeys.users_count.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.shadowGray,
                  ),
                ),
                Text(
                  '${widget.cashier!.users.length}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                 LocaleKeys.bank_accounts_count.tr(),
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.shadowGray,
                  ),
                ),
                Text(
                  '${widget.cashier!.bankAccounts.length}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 30,
          offset: const Offset(0, 10),
        )
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.person_outline, color: Colors.white, size: 28),
          const SizedBox(width: 15),
          Text(
            isEditMode ? LocaleKeys.edit_cashier.tr() : LocaleKeys.new_cashier.tr(),
            style: const TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.close, color: Colors.white, size: 26),
          )
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<CashierCubit>();

      if (isEditMode) {
        cubit.updateCashier(
          cashierId: widget.cashier!.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
           warehouseId: selectedWarehouse,
          status: status,
          cashierActive: cashierActive,
        );
      } else {
        cubit.createCashier(
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
           warehouseId: selectedWarehouse,
          status: status,
          cashierActive: cashierActive,
        );
      }
    }
  }

  void _handleStateChanges(BuildContext context, CashierState state) {
    if (state is CreateCashierSuccess || state is UpdateCashierSuccess) {
      Navigator.pop(context);
    } else if (state is CreateCashierError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateCashierError) {
      CustomSnackbar.showError(context, state.error);
    }
  }
}

class CashierDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const CashierDialogButtons({
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
                      isEditMode ? LocaleKeys.update_cashier.tr() : LocaleKeys.create_cashier.tr(),
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