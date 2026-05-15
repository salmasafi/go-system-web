import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:GoSystem/features/admin/discount/cubit/discount_cubit.dart';
import 'package:GoSystem/features/admin/discount/model/discount_model.dart';
import 'package:GoSystem/features/admin/pandel/cubit/pandel_cubit.dart';
import 'package:GoSystem/features/admin/pandel/model/pandel_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';

class CreatePandelScreen extends StatefulWidget {
  const CreatePandelScreen({super.key});

  @override
  State<CreatePandelScreen> createState() => _CreatePandelScreenState();
}

class _CreatePandelScreenState extends State<CreatePandelScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  // Map of productId -> quantity
  final Map<String, int> _selectedProducts = {};
  // Map of productId -> productPriceId (for variations)
  final Map<String, String> _selectedProductPriceIds = {};
  // Map of productId -> product price (for discount calculation)
  final Map<String, double> _selectedProductPrices = {};
  bool _allWarehouses = true;
  var _selectedWarehouseIds = <String>[];

  DiscountModel? _selectedDiscount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsCubit>().getProducts();
      context.read<DiscountsCubit>().getDiscounts();
    });
  }

  void _applyDiscountToPrice() {
    if (_selectedDiscount == null || _selectedProductPrices.isEmpty) return;
    double total = 0;
    for (final entry in _selectedProducts.entries) {
      total += (_selectedProductPrices[entry.key] ?? 0) * entry.value;
    }
    final double finalPrice;
    if (_selectedDiscount!.type == 'percentage') {
      finalPrice = total * (1 - _selectedDiscount!.amount);
    } else {
      finalPrice = (total - _selectedDiscount!.amount).clamp(0.0, double.infinity);
    }
    _priceController.text = finalPrice.toStringAsFixed(2);
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initial = isStartDate
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now().add(const Duration(days: 30)));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: isStartDate ? DateTime.now() : (_startDate ?? DateTime.now()),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryBlue,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.darkGray,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _openProductSelector(List products) async {
    await showModalBottomSheet<Map<String, int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(ResponsiveUI.borderRadius(context, 16))),
      ),
      builder: (ctx) {
        final tempSelected = Map<String, int>.from(_selectedProducts);
        final tempPriceIds = Map<String, String>.from(_selectedProductPriceIds);
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.7,
              maxChildSize: 0.95,
              builder: (_, scroll) {
                return Column(
                  children: [
                    SizedBox(height: ResponsiveUI.value(context, 12)),
                    Container(
                      width: ResponsiveUI.value(context, 40),
                      height: ResponsiveUI.value(context, 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 2)),
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 16)),
                    Text(
                      LocaleKeys.select_products.tr(),
                      style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 16), fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: ResponsiveUI.value(context, 8)),
                    Expanded(
                      child: ListView.builder(
                        controller: scroll,
                        itemCount: products.length,
                        itemBuilder: (_, i) {
                          final p = products[i];
                          final isSelected = tempSelected.containsKey(p.id);
                          final qty = tempSelected[p.id] ?? 1;
                          return ListTile(
                            leading: Checkbox(
                              value: isSelected,
                              activeColor: AppColors.primaryBlue,
                              onChanged: (checked) => setModal(() {
                                if (checked == true) {
                                  tempSelected[p.id] = 1;
                                } else {
                                  tempSelected.remove(p.id);
                                  tempPriceIds.remove(p.id);
                                }
                              }),
                            ),
                            title: Text(p.name),
                            trailing: isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline),
                                        color: AppColors.primaryBlue,
                                        onPressed: qty > 1
                                            ? () => setModal(() => tempSelected[p.id] = qty - 1)
                                            : null,
                                      ),
                                      Text(
                                        '$qty',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600, fontSize: ResponsiveUI.fontSize(context, 16)),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline),
                                        color: AppColors.primaryBlue,
                                        onPressed: () =>
                                            setModal(() => tempSelected[p.id] = qty + 1),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedProducts
                                ..clear()
                                ..addAll(tempSelected);
                              _selectedProductPriceIds
                                ..clear()
                                ..addAll(tempPriceIds);
                              // Update prices map for discount calculation
                              for (final p in products) {
                                if (tempSelected.containsKey(p.id)) {
                                  _selectedProductPrices[p.id] = (p.price as num).toDouble();
                                }
                              }
                              _selectedProductPrices.removeWhere(
                                  (k, _) => !tempSelected.containsKey(k));
                            });
                            if (_selectedDiscount != null) _applyDiscountToPrice();
                            Navigator.pop(ctx);
                          },
                          child: Text(LocaleKeys.done.tr()),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _openWarehouseSelector() async {
    // TODO: Implement warehouse selector
    // This should show a list of warehouses and allow multi-selection
    CustomSnackbar.showInfo(context, 'Warehouse selector to be implemented');
  }

  void _validateAndSubmit() {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, LocaleKeys.warning_enter_pandel_name.tr());
      return;
    }
    if (_selectedProducts.isEmpty) {
      CustomSnackbar.showWarning(
          context, LocaleKeys.warning_select_at_least_two_products.tr());
      return;
    }
    if (_startDate == null) {
      CustomSnackbar.showWarning(context, LocaleKeys.warning_select_start_date.tr());
      return;
    }
    if (_endDate == null) {
      CustomSnackbar.showWarning(context, LocaleKeys.warning_select_end_date.tr());
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      CustomSnackbar.showWarning(context, LocaleKeys.warning_end_date_before_start.tr());
      return;
    }
    // Images are now optional - removed validation
    
    if (_priceController.text.trim().isEmpty) {
      CustomSnackbar.showWarning(context, LocaleKeys.warning_enter_price.tr());
      return;
    }
    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      CustomSnackbar.showWarning(context, LocaleKeys.warning_enter_valid_price.tr());
      return;
    }

    final products = _selectedProducts.entries
        .map((e) => PandelProduct(
              productId: e.key,
              // Note: productPriceId removed in migration 014
              quantity: e.value,
            ))
        .toList();

    context.read<PandelCubit>().addPandel(
          name: _nameController.text.trim(),
          products: products,
          images: [],
          startDate: _startDate!,
          endDate: _endDate!,
          price: price,
          allWarehouses: _allWarehouses,
          warehouseIds: _allWarehouses ? null : _selectedWarehouseIds,
          discountId: _selectedDiscount?.id,
        );
  }

  Widget _buildDiscountSelector() {
    return BlocBuilder<DiscountsCubit, DiscountsState>(
      builder: (context, state) {
        final discounts = state is GetDiscountsSuccess
            ? state.discounts.where((d) => d.status).toList()
            : <DiscountModel>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveUI.spacing(context, 16)),
            Text(
              'الخصم (اختياري)',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: ResponsiveUI.spacing(context, 8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 12),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                border: Border.all(color: AppColors.lightGray),
              ),
              child: DropdownButton<DiscountModel?>(
                isExpanded: true,
                underline: const SizedBox(),
                value: _selectedDiscount,
                hint: Text(
                  'اختر خصم...',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: AppColors.darkGray.withValues(alpha: 0.5),
                  ),
                ),
                items: [
                  DropdownMenuItem<DiscountModel?>(
                    value: null,
                    child: Text(
                      'بدون خصم',
                      style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
                    ),
                  ),
                  ...discounts.map((d) => DropdownMenuItem<DiscountModel?>(
                        value: d,
                        child: Text(
                          '${d.name}  (${d.type == 'percentage' ? '${(d.amount * 100).toStringAsFixed(0)}%' : '${d.amount.toStringAsFixed(2)} ثابت'})',
                          style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
                        ),
                      )),
                ],
                onChanged: (discount) {
                  setState(() => _selectedDiscount = discount);
                  if (discount != null) _applyDiscountToPrice();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String title,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        CustomTextField(
          controller: controller,
          labelText: '',
          hintText: hint,
          hasBoxDecoration: false,
          hasBorder: true,
          prefixIconColor: AppColors.darkGray.withValues(alpha: 0.7),
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required DateTime? selectedDate,
    required String title,
    required String hint,
    required void Function() onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Text(
          title,
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            color: AppColors.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 14),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
              border: Border.all(color: AppColors.lightGray, width: ResponsiveUI.value(context, 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}"
                      : hint,
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    color: selectedDate != null
                        ? AppColors.darkGray
                        : AppColors.darkGray.withValues(alpha: 0.5),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: ResponsiveUI.iconSize(context, 20),
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = BlocConsumer<PandelCubit, PandelState>(
      listener: (context, state) {
        if (state is CreatePandelSuccess) {
          Navigator.pop(context, true);
        } else if (state is CreatePandelError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        final isLoading = state is CreatePandelLoading;
        return Scaffold(
          backgroundColor: const Color.fromARGB(255, 243, 249, 254),
          appBar: appBarWithActions(context, title: LocaleKeys.new_pandel.tr()),
          body: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, productsState) {
              return Stack(
                children: [
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUI.padding(context, 16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            title: LocaleKeys.pandel_name.tr(),
                            hint: LocaleKeys.enter_pandel_name.tr(),
                          ),
                          _buildDiscountSelector(),
                          _buildTextField(
                            controller: _priceController,
                            title: LocaleKeys.price.tr(),
                            hint: LocaleKeys.enter_price.tr(),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                          _buildDatePicker(
                            selectedDate: _startDate,
                            title: LocaleKeys.start_date.tr(),
                            hint: LocaleKeys.select_start_date.tr(),
                            onTap: () => _selectDate(context, true),
                          ),
                          _buildDatePicker(
                            selectedDate: _endDate,
                            title: LocaleKeys.end_date.tr(),
                            hint: LocaleKeys.select_end_date.tr(),
                            onTap: () => _selectDate(context, false),
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),
                          if (productsState is ProductsSuccess) ...[
                            Text(
                              LocaleKeys.select_products.tr(),
                              style: TextStyle(
                                fontSize: ResponsiveUI.fontSize(context, 14),
                                color: AppColors.darkGray,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: ResponsiveUI.spacing(context, 8)),
                            OutlinedButton.icon(
                              onPressed: () => _openProductSelector(productsState.products),
                              icon: const Icon(Icons.add_shopping_cart),
                              label: Text(
                                _selectedProducts.isEmpty
                                    ? LocaleKeys.select_products.tr()
                                    : '${_selectedProducts.length} ${LocaleKeys.selected.tr()}',
                              ),
                            ),
                          ] else if (productsState is ProductsLoading) ...[
                            const Center(child: CircularProgressIndicator()),
                          ],
                          SizedBox(height: ResponsiveUI.spacing(context, 32)),
                          SizedBox(
                            width: double.infinity,
                            height: ResponsiveUI.value(context, 48),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _validateAndSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      ResponsiveUI.borderRadius(context, 12)),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: ResponsiveUI.iconSize(context, 20),
                                      width: ResponsiveUI.iconSize(context, 20),
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            AppColors.white),
                                      ),
                                    )
                                  : Text(
                                      LocaleKeys.save_pandel.tr(),
                                      style: TextStyle(
                                        fontSize: ResponsiveUI.fontSize(context, 16),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
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

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
