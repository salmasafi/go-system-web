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
import 'package:systego/features/admin/revenue/cubit/revenue_cubit.dart';
import 'package:systego/features/admin/revenue/model/revenue_model.dart';
import 'package:systego/generated/locale_keys.g.dart';

class RevenueFormDialog extends StatefulWidget {
  final RevenueModel? revenue;


  const RevenueFormDialog({
    super.key,
    this.revenue,

  });

  @override
  State<RevenueFormDialog> createState() => _RevenueFormDialogState();
}

class _RevenueFormDialogState extends State<RevenueFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? selectedCategoryId;
  String? selectedFinancialAccountId;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool get isEditMode => widget.revenue != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
    context.read<RevenueCubit>().getSelectionData();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _nameController.text = widget.revenue!.name;
      _amountController.text = widget.revenue!.amount.toString();
      _noteController.text = widget.revenue!.note ?? '';
      selectedCategoryId = widget.revenue!.category?.id;
      selectedFinancialAccountId = widget.revenue!.financialAccount?.id;
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
    _amountController.dispose();
    _noteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<RevenueCubit, RevenueState>(
          listener: _handleStateChanges,
          builder: (context, revenueState) {
            final isSubmitting =
                revenueState is CreateRevenueLoading ||
                revenueState is UpdateRevenueLoading;

            final isDataLoading =
        revenueState is GetSelectionDataLoading;

            return Stack(
              children: [
                _buildDialogContent(context, revenueState, isSubmitting),

                /// 🔵 GLOBAL LOADING OVERLAY
                if (isDataLoading || isSubmitting)
                  buildLoadingOverlay(context, 45),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDialogContent(
    BuildContext context,
    RevenueState revenueState,
    bool isSubmitting,
  ) {
    final maxWidth = ResponsiveUI.isMobile(context)
        ? ResponsiveUI.screenWidth(context) * 0.95
        : ResponsiveUI.contentMaxWidth(context);

    final cubit = context.read<RevenueCubit>();

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxWidth,
        maxHeight: ResponsiveUI.screenHeight(context) * 0.8,
      ),
      decoration: _buildDecoration(context),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        buildTextField(
                          context,
                          controller: _nameController,
                          label: LocaleKeys.revenue_name.tr(),
                          icon: Icons.business,
                          hint: LocaleKeys.hint_revenue_name.tr(),
                          validator: (v) => LoginValidator.validateRequired(
                            v,
                            LocaleKeys.revenue_name.tr(),
                          ),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),
                        buildTextField(
                          context,
                          controller: _amountController,
                          label: LocaleKeys.amount.tr(),
                          icon: Icons.attach_money,
                          hint: LocaleKeys.please_enter_amount.tr(),
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return LocaleKeys.enter_amount.tr();
                            }
                            if (double.tryParse(v) == null) {
                              return LocaleKeys.invalid_number.tr();
                            }
                            if (double.parse(v) <= 0) {
                              return LocaleKeys.amount_must_be_positive.tr();
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),

                        if (cubit.selectionAccounts.isNotEmpty)
                          buildDropdownField<String>(
                            context,
                            value: selectedFinancialAccountId,
                            items: cubit.selectionAccounts
                                .map((e) => e.id)
                                .toList(),
                            label:
                                LocaleKeys.financial_accounts.tr(), // Consider using LocaleKeys here
                            hint: LocaleKeys.please_select_financial_account.tr(),
                            icon: Icons
                                .account_balance_wallet, // Changed icon to be more relevant
                            onChanged: (v) {
                              setState(() {
                                selectedFinancialAccountId = v;
                              });
                            },
                            itemLabel: (id) {
                              // Safe check to ensure we find the ID
                              final account = cubit.selectionAccounts
                                  .where((r) => r.id == id)
                                  .firstOrNull;
                              return account?.name ?? '';
                            },
                            validator: (v) => v == null
                                ? LocaleKeys.please_select_financial_account.tr()
                                : null,
                          ),

                      

                        SizedBox(height: ResponsiveUI.spacing(context, 12)),

                         if (cubit.selectionCategories.isNotEmpty)
                          buildDropdownField<String>(
                            context,
                            value: selectedCategoryId,
                            // Access data directly from the Cubit list
                            items: cubit.selectionCategories
                                .map((e) => e.id)
                                .toList(),
                            label:
                                LocaleKeys.categories_title.tr(), // Consider using LocaleKeys here
                            hint:  LocaleKeys.select_category.tr(),
                            icon: Icons
                                .category, // Changed icon to be more relevant
                            onChanged: (v) {
                              setState(() {
                                selectedCategoryId = v;
                              });
                            },
                            itemLabel: (id) {
                              // Safe check to ensure we find the ID
                              final category = cubit.selectionCategories
                                  .where((r) => r.id == id)
                                  .firstOrNull;
                              return category?.name ?? '';
                            },
                            validator: (v) => v == null
                                ? LocaleKeys.please_select_category.tr()
                                : null,
                          ),

                      

                        SizedBox(height: ResponsiveUI.spacing(context, 12)),

                        buildTextField(
                          context,
                          controller: _noteController,
                          label: LocaleKeys.note.tr(),
                          icon: Icons.note,
                          hint: LocaleKeys.hint_note.tr(),
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty
                              ? LocaleKeys.enter_note.tr()
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                // if (isLoading) buildLoadingOverlay(context, 45),
              ],
            ),
          ),
          RevenueDialogButtons(
            isEditMode: isEditMode,
            isLoading: isSubmitting,
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: _handleSubmit,
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(BuildContext context) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(
        ResponsiveUI.borderRadius(context, 24),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ResponsiveUI.borderRadius(context, 24)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.monetization_on, color: Colors.white, size: 28),
          SizedBox(width: ResponsiveUI.spacing(context, 15)),
          Text(
            isEditMode
                ? LocaleKeys.edit_revenue.tr()
                : LocaleKeys.new_revenue.tr(),
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.close, color: Colors.white, size: 26),
          ),
        ],
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final cubit = context.read<RevenueCubit>();

      if (isEditMode) {
        cubit.updateRevenue(
          revenueId: widget.revenue!.id,
          name: _nameController.text.trim(),
          amount: double.parse(_amountController.text),
          categoryId: selectedCategoryId!,
          note: _noteController.text.trim(),
          financialAccountId: selectedFinancialAccountId!,
        );
      } else {
        cubit.createRevenue(
          name: _nameController.text.trim(),
          amount: double.parse(_amountController.text),
          categoryId: selectedCategoryId!,
          note: _noteController.text.trim(),
          financialAccountId: selectedFinancialAccountId!,
        );
      }
    }
  }

  void _handleStateChanges(BuildContext context, RevenueState state) {
    if (state is CreateRevenueSuccess || state is UpdateRevenueSuccess) {
      Navigator.pop(context);
    } else if (state is CreateRevenueError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateRevenueError) {
      CustomSnackbar.showError(context, state.error);
    }
  }
}

class RevenueDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const RevenueDialogButtons({
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
                          ? LocaleKeys.update_revenue.tr()
                          : LocaleKeys.create_revenue.tr(),
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
