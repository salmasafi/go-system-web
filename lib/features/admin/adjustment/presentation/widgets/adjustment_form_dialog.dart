import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/features/admin/reason/cubit/reason_cubit.dart';
import 'package:GoSystem/features/admin/reason/cubit/reason_state.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/responsive_ui.dart';
import '../../../../../core/widgets/custom_loading/build_overlay_loading.dart';
import '../../../../../core/widgets/custom_snack_bar/custom_snackbar.dart';
import '../../../../../core/widgets/custom_textfield/build_text_field.dart';
import '../../../../../core/widgets/custom_drop_down_menu.dart';
import '../../cubit/adjustment_state.dart';
import '../../cubit/adjustment_cubit.dart';
import '../../model/adjustment_model.dart';

class AdjustmentFormDialog extends StatefulWidget {
  final AdjustmentModel? adjustment;
  final String? existingImageUrl;
  const AdjustmentFormDialog({
    super.key,
    this.adjustment,
    this.existingImageUrl,
  });

  @override
  State<AdjustmentFormDialog> createState() => _AdjustmentFormDialogState();
}

class _AdjustmentFormDialogState extends State<AdjustmentFormDialog>
    with SingleTickerProviderStateMixin {
  final _warehouseIdController = TextEditingController();
  final _productIdController = TextEditingController();
  final _quantityController = TextEditingController();
  final _noteController = TextEditingController();
  final _imageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // Dropdown state
  // ReasonModel? selectedReason;

  List<String> availableProducts = [];

  final reasons = AdjustmentCubit.reasons;
  String? selectedWareHouse;
  String? selectedProduct;
  String? selectedReason;
  bool get isEditMode => widget.adjustment != null;
  bool _isFetchingProducts = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimation();
  }

  void _initializeControllers() {
    if (isEditMode) {
      _quantityController.text = widget.adjustment!.quantity.toString();
      _noteController.text = widget.adjustment!.note;
      selectedWareHouse = widget.adjustment!.warehouseId;
      selectedProduct = widget.adjustment!.productId;
      selectedReason = widget.adjustment!.selectReasonId;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // context.read<ProductsCubit>().getProducts();
      context.read<WareHouseCubit>().getWarehouses();
      context.read<ReasonCubit>().getReasons();
      if (isEditMode && selectedWareHouse != null) {
        _fetchWarehouseProducts(selectedWareHouse!);
      }
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
    _warehouseIdController.dispose();
    _productIdController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    _imageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // New method to fetch warehouse products
  void _fetchWarehouseProducts(String warehouseId) {
    setState(() {
      _isFetchingProducts = true;
      selectedProduct = null; // Reset product selection
      availableProducts = [];
    });

    context.read<ProductsCubit>().getWareHouseProducts(warehouseId);
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: BlocConsumer<AdjustmentCubit, AdjustmentState>(
          listener: _handleStateChanges,
          builder: (context, adjustmentState) {
            final warehouseState = context.watch<WareHouseCubit>().state;
            final productsState = context.watch<ProductsCubit>().state;
            final reasonState = context.watch<ReasonCubit>().state;

            final isDataLoading =
                warehouseState is WarehousesLoading ||
                // productsState is ProductsLoading ||
                reasonState is GetReasonsLoading;

            final isSubmitting =
                adjustmentState is CreateAdjustmentLoading ||
                adjustmentState is UpdateAdjustmentLoading;

            return Stack(
              children: [
                _buildDialogContent(
                  context,
                  warehouseState,
                  productsState,
                  reasonState,
                  isSubmitting,
                ),

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
    WarehousesState warehouseState,
    ProductsState productsState,
    ReasonState reasonState,
    bool isSubmitting,
  ) {
    // Reset products when warehouse changes
    if (productsState is ProductsSuccess && selectedWareHouse != null) {
      if (productsState.products.isEmpty) {
        _isFetchingProducts = false;
      }
      // Update available products list
      final currentProducts = productsState.products.map((e) => e.id).toList();
      if (!listEquals(availableProducts, currentProducts)) {
        availableProducts = currentProducts;
        _isFetchingProducts = false;
      }
    } else if (productsState is ProductsLoading) {
      _isFetchingProducts = true;
    } else if (productsState is ProductsError) {
      _isFetchingProducts = false;
    }
    return Container(
      constraints: BoxConstraints(
        maxWidth: ResponsiveUI.isMobile(context)
            ? ResponsiveUI.screenWidth(context) * 0.95
            : ResponsiveUI.contentMaxWidth(context),
        maxHeight: ResponsiveUI.screenHeight(context) * 0.85,
      ),
      decoration: _buildDialogDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AdjustmentDialogHeader(
            isEditMode: isEditMode,
            onClose: () => Navigator.of(context).pop(),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// -------- WAREHOUSE --------
                    if (warehouseState is WarehousesLoaded)
                      buildDropdownField<String>(
                        context,
                        value: selectedWareHouse,
                        items: warehouseState.warehouses
                            .map((e) => e.id)
                            .toList(),
                        label: "Warehouse",
                        hint: "Select warehouse",
                        icon: Icons.warehouse_rounded,
                        // onChanged: (v) => setState(() => selectedWareHouse = v),
                        onChanged: (v) {
                          setState(() {
                            selectedWareHouse = v;
                            selectedProduct =
                                null; // Reset product when warehouse changes
                            availableProducts = []; // Clear products list
                          });
                          if (v != null) {
                            _fetchWarehouseProducts(v);
                          }
                        },
                        itemLabel: (id) => warehouseState.warehouses
                            .firstWhere((w) => w.id == id)
                            .name,
                        validator: (v) =>
                            v == null ? "Please select warehouse" : null,
                      ),

                    SizedBox(height: ResponsiveUI.spacing(context, 12)),

                    // /// -------- PRODUCT --------
                    // if (productsState is ProductsSuccess)
                    //   buildDropdownField<String>(
                    //     context,
                    //     value: selectedProduct,
                    //     items: productsState.products.map((e) => e.id).toList(),
                    //     label: "Product",
                    //     hint: "Select product",
                    //     icon: Icons.inventory_2_outlined,
                    //     onChanged: (v) => setState(() => selectedProduct = v),
                    //     itemLabel: (id) =>
                    //         productsState.products
                    //             .firstWhere((p) => p.id == id)
                    //             .name,
                    //     validator: (v) =>
                    //         v == null ? "Please select product" : null,
                    //   ),

                    /// -------- PRODUCT --------
                    // Show product dropdown only if warehouse is selected
                    if (selectedWareHouse != null)
                      _buildProductDropdown(productsState),

                    SizedBox(height: ResponsiveUI.spacing(context, 12)),

                    /// -------- REASON --------
                    if (reasonState is GetReasonsSuccess)
                      buildDropdownField<String>(
                        context,
                        value: selectedReason,
                        items: reasonState.reasonData.reasons
                            .map((e) => e.id)
                            .toList(),
                        label: "Reason",
                        hint: "Select reason",
                        icon: Icons.adjust_rounded,
                        onChanged: (v) => setState(() => selectedReason = v),
                        itemLabel: (id) => reasonState.reasonData.reasons
                            .firstWhere((r) => r.id == id)
                            .reason,
                        validator: (v) =>
                            v == null ? "Please select reason" : null,
                      ),

                    SizedBox(height: ResponsiveUI.spacing(context, 12)),

                    buildTextField(
                      context,
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      label: LocaleKeys.quantity.tr(),
                      icon: Icons.numbers_rounded,
                      hint: LocaleKeys.hint_quantity.tr(),
                    ),

                    SizedBox(height: ResponsiveUI.spacing(context, 12)),

                    buildTextField(
                      context,
                      controller: _noteController,
                      label: LocaleKeys.note.tr(),
                      icon: Icons.note_rounded,
                      hint: LocaleKeys.hint_note.tr(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AdjustmentDialogButtons(
            isEditMode: isEditMode,
            isLoading: isSubmitting,
            onCancel: () => Navigator.of(context).pop(),
            onSubmit: _handleSubmit,
          ),
        ],
      ),
    );
  }

  // New method to build product dropdown
  Widget _buildProductDropdown(ProductsState productsState) {
    if (_isFetchingProducts) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product",
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 14),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
              border: Border.all(color: Colors.grey[300]!),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Icon(Icons.inventory_2_outlined, color: Colors.grey[400]),
                SizedBox(width: ResponsiveUI.spacing(context, 12)),
                Expanded(
                  child: Text(
                    "Loading products...",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                SizedBox(
                  width: ResponsiveUI.iconSize(context, 20),
                  height: ResponsiveUI.iconSize(context, 20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (productsState is ProductsError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Product",
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 14),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                ResponsiveUI.borderRadius(context, 12),
              ),
              border: Border.all(color: Colors.red[300]!),
              color: Colors.red[50],
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red[400]),
                SizedBox(width: ResponsiveUI.spacing(context, 12)),
                Expanded(
                  child: Text(
                    "Failed to load products. Please try again.",
                    style: TextStyle(color: Colors.red[600]),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.refresh,
                    size: ResponsiveUI.iconSize(context, 20),
                    color: AppColors.primaryBlue,
                  ),
                  onPressed: () {
                    if (selectedWareHouse != null) {
                      _fetchWarehouseProducts(selectedWareHouse!);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (productsState is ProductsSuccess) {
      final products = productsState.products;

      if (products.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Product",
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 8)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 16),
                vertical: ResponsiveUI.padding(context, 14),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 12),
                ),
                border: Border.all(color: Colors.orange[300]!),
                color: Colors.orange[50],
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined, color: Colors.orange[400]),
                  SizedBox(width: ResponsiveUI.spacing(context, 12)),
                  Expanded(
                    child: Text(
                      "No products available in this warehouse",
                      style: TextStyle(color: Colors.orange[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }

      return buildDropdownField<String>(
        context,
        value: selectedProduct,
        items: products.map((e) => e.id).toList(),
        label: "Product",
        hint: "Select product",
        icon: Icons.inventory_2_outlined,
        onChanged: (v) => setState(() => selectedProduct = v),
        itemLabel: (id) => products.firstWhere((p) => p.id == id).name,
        validator: (v) => v == null ? "Please select product" : null,
      );
    }

    // Default empty state
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Product",
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUI.padding(context, 16),
            vertical: ResponsiveUI.padding(context, 14),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              ResponsiveUI.borderRadius(context, 12),
            ),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.grey[50],
          ),
          child: Row(
            children: [
              Icon(Icons.inventory_2_outlined, color: Colors.grey[400]),
              SizedBox(width: ResponsiveUI.spacing(context, 12)),
              Expanded(
                child: Text(
                  "Select a warehouse first",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ],
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
          color: AppColors.black.withValues(alpha: 0.2),
          blurRadius: ResponsiveUI.value(context, 30),
          offset: Offset(0, ResponsiveUI.value(context, 10)),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, AdjustmentState state) {
    if (state is CreateAdjustmentSuccess || state is UpdateAdjustmentSuccess) {
      Navigator.of(context).pop();
    }
    if (state is CreateAdjustmentError) {
      CustomSnackbar.showError(context, state.error);
    } else if (state is UpdateAdjustmentError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate() &&
        selectedWareHouse != null &&
        selectedProduct != null &&
        selectedReason != null) {
      final cubit = context.read<AdjustmentCubit>();
      if (isEditMode) {
        cubit.updateAdjustment(
          adjustmentId: widget.adjustment!.id,
          warehouseId: selectedWareHouse!,
          productId: selectedProduct!,
          quantity: _quantityController.text.trim(),
          reasonId: selectedReason!,
          note: _noteController.text.trim(),
          image: null,
        );
      } else {
        cubit.createAdjustment(
          warehouseId: selectedWareHouse!,
          productId: selectedProduct!,
          quantity: _quantityController.text.trim(),
          reasonId: selectedReason!,
          note: _noteController.text.trim(),
          image: null,
        );
      }
    }
  }
}

class AdjustmentDialogHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;
  const AdjustmentDialogHeader({
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
            AppColors.darkBlue,
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
              color: AppColors.white.withValues(alpha: 0.2),
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
                      ? LocaleKeys.edit_adjustment.tr()
                      : LocaleKeys.new_adjustment.tr(),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: fontSize22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isEditMode
                      ? LocaleKeys.adjustment_dialog_update_details.tr()
                      : LocaleKeys.adjustment_dialog_add_new.tr(),
                  style: TextStyle(
                    color: AppColors.white.withValues(alpha: 0.9),
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

class AdjustmentDialogButtons extends StatelessWidget {
  final bool isEditMode;
  final bool isLoading;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  const AdjustmentDialogButtons({
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
                          ? LocaleKeys.update_adjustment.tr()
                          : LocaleKeys.create_adjustment.tr(),
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


