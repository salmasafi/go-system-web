import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_error_state.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/core/widgets/custom_textfield/custom_text_field_widget.dart';
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
  final List<File> _selectedImages = [];
  final _picker = ImagePicker();

  // Map of productId -> quantity
  final Map<String, int> _selectedProducts = {};
  // Map of productId -> productPriceId (for variations)
  final Map<String, String> _selectedProductPriceIds = {};
  bool _allWarehouses = true;
  var _selectedWarehouseIds = <String>[];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsCubit>().getProducts();
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (final f in pickedFiles) {
          if (_selectedImages.length < 10) _selectedImages.add(File(f.path));
        }
      });
      if (pickedFiles.length > 10 && mounted) {
        CustomSnackbar.showWarning(
          context,
          LocaleKeys.max_images_warning.tr(namedArgs: {'max': '10'}),
        );
      }
    }
  }

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));

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
                          final selectedPriceId = tempPriceIds[p.id];
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
                            subtitle: p.variations.isNotEmpty && isSelected
                                ? DropdownButton<String>(
                                    hint: Text('Select variation'),
                                    value: selectedPriceId,
                                    isExpanded: true,
                                    onChanged: (value) => setModal(() {
                                      if (value != null) {
                                        tempPriceIds[p.id] = value;
                                      }
                                    }),
                                    items: p.variations.map((variation) {
                                      return DropdownMenuItem<String>(
                                        value: variation.id,
                                        child: Text('${variation.name} - \$${variation.price}'),
                                      );
                                    }).toList(),
                                  )
                                : null,
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
                            });
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
    if (_selectedProducts.length < 2) {
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
              productPriceId: _selectedProductPriceIds[e.key],
              quantity: e.value,
            ))
        .toList();

    context.read<PandelCubit>().addPandel(
          name: _nameController.text.trim(),
          products: products,
          images: _selectedImages,
          startDate: _startDate!,
          endDate: _endDate!,
          price: price,
          allWarehouses: _allWarehouses,
          warehouseIds: _allWarehouses ? null : _selectedWarehouseIds,
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

  Widget _buildImagesPicker() {
    final imageSize = ResponsiveUI.screenWidth(context) * 0.28;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocaleKeys.pandel_images.tr(),
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 14),
                color: AppColors.darkGray,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_selectedImages.isNotEmpty)
              TextButton.icon(
                icon: Icon(Icons.delete,
                    color: AppColors.red, size: ResponsiveUI.iconSize(context, 18)),
                label: Text(
                  LocaleKeys.remove_all.tr(),
                  style: TextStyle(
                      color: AppColors.red, fontSize: ResponsiveUI.fontSize(context, 12)),
                ),
                onPressed: () => setState(() => _selectedImages.clear()),
              ),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: ResponsiveUI.spacing(context, 8),
              mainAxisSpacing: ResponsiveUI.spacing(context, 8),
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (_, index) => Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                    border: Border.all(color: AppColors.lightGray, width: ResponsiveUI.value(context, 1)),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                    child: Image.file(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                      width: imageSize,
                      height: imageSize,
                    ),
                  ),
                ),
                Positioned(
                  top: ResponsiveUI.padding(context, 4),
                  right: ResponsiveUI.padding(context, 4),
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: EdgeInsets.all(ResponsiveUI.padding(context, 4)),
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close,
                          size: ResponsiveUI.iconSize(context, 14), color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: ResponsiveUI.padding(context, 20)),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius:
                  BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              border: Border.all(color: AppColors.lightGray, width: ResponsiveUI.value(context, 1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate_outlined,
                    size: ResponsiveUI.iconSize(context, 45),
                    color: AppColors.primaryBlue),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                Text(
                  _selectedImages.isEmpty
                      ? LocaleKeys.tap_to_upload_images.tr()
                      : LocaleKeys.tap_to_add_more_images.tr(),
                  style: TextStyle(
                    color: AppColors.darkGray.withValues(alpha: 0.7),
                    fontSize: ResponsiveUI.fontSize(context, 13),
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  Text(
                    '(${LocaleKeys.selected_images_count.tr(namedArgs: {'count': _selectedImages.length.toString()})})',
                    style: TextStyle(
                      color: AppColors.darkGray.withValues(alpha: 0.5),
                      fontSize: ResponsiveUI.fontSize(context, 12),
                    ),
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
    return BlocConsumer<PandelCubit, PandelState>(
      listener: (context, state) {
        if (state is CreatePandelSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is CreatePandelError) {
          CustomSnackbar.showError(context, state.error);
        }
      },
      builder: (context, state) {
        if (state is CreatePandelSuccess) {
          return Scaffold(
            backgroundColor: AppColors.lightBlueBackground,
            appBar: appBarWithActions(context, title: LocaleKeys.new_pandel.tr()),
            body: CustomErrorState(message: state.message, onRetry: _validateAndSubmit),
          );
        }
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

                          // Products selector
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: ResponsiveUI.spacing(context, 16)),
                              Text(
                                LocaleKeys.products.tr(),
                                style: TextStyle(
                                  fontSize: ResponsiveUI.fontSize(context, 14),
                                  color: AppColors.darkGray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: ResponsiveUI.spacing(context, 8)),
                              if (productsState is ProductsSuccess)
                                GestureDetector(
                                  onTap: () =>
                                      _openProductSelector(productsState.products),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUI.padding(context, 12),
                                      vertical: ResponsiveUI.padding(context, 14),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                                      border: Border.all(color: AppColors.lightGray),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.inventory_2_rounded,
                                            color: AppColors.primaryBlue),
                                        SizedBox(
                                            width: ResponsiveUI.spacing(context, 8)),
                                        Expanded(
                                          child: Text(
                                            _selectedProducts.isEmpty
                                                ? LocaleKeys.select_products.tr()
                                                : "${_selectedProducts.length} ${LocaleKeys.selected.tr()}",
                                            style: TextStyle(
                                              color: _selectedProducts.isEmpty
                                                  ? AppColors.darkGray
                                                      .withValues(alpha: 0.5)
                                                  : AppColors.darkGray,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_down_rounded,
                                            color: AppColors.primaryBlue),
                                      ],
                                    ),
                                  ),
                                ),
                              if (productsState is ProductsError)
                                Text(productsState.message,
                                    style: TextStyle(color: AppColors.red)),
                              if (_selectedProducts.isNotEmpty &&
                                  productsState is ProductsSuccess)
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: ResponsiveUI.spacing(context, 8)),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: _selectedProducts.entries.map((e) {
                                      final product = productsState.products
                                          .firstWhere((p) => p.id == e.key,
                                              orElse: () =>
                                                  productsState.products.first);
                                      return Chip(
                                        label: Text('${product.name} x${e.value}'),
                                        deleteIcon:
                                            Icon(Icons.close, size: ResponsiveUI.iconSize(context, 16)),
                                        onDeleted: () => setState(
                                            () => _selectedProducts.remove(e.key)),
                                      );
                                    }).toList(),
                                  ),
                                ),
                            ],
                          ),

                          SizedBox(height: ResponsiveUI.spacing(context, 12)),
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
                          _buildTextField(
                            controller: _priceController,
                            title: LocaleKeys.price.tr(),
                            hint: LocaleKeys.enter_price.tr(),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),
                          // All Warehouses Toggle
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Apply to all warehouses',
                                  style: TextStyle(
                                    fontSize: ResponsiveUI.fontSize(context, 14),
                                    color: AppColors.darkGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Switch(
                                value: _allWarehouses,
                                onChanged: (value) => setState(() => _allWarehouses = value),
                                activeThumbColor: AppColors.primaryBlue,
                              ),
                            ],
                          ),
                          if (!_allWarehouses)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: ResponsiveUI.spacing(context, 16)),
                                Text(
                                  'Select Warehouses',
                                  style: TextStyle(
                                    fontSize: ResponsiveUI.fontSize(context, 14),
                                    color: AppColors.darkGray,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                                GestureDetector(
                                  onTap: _openWarehouseSelector,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: ResponsiveUI.padding(context, 12),
                                      vertical: ResponsiveUI.padding(context, 14),
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                                      border: Border.all(color: AppColors.lightGray),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.store_rounded, color: AppColors.primaryBlue),
                                        SizedBox(width: ResponsiveUI.spacing(context, 8)),
                                        Expanded(
                                          child: Text(
                                            _selectedWarehouseIds.isEmpty
                                                ? 'Select warehouses'
                                                : "${_selectedWarehouseIds.length} selected",
                                            style: TextStyle(
                                              color: _selectedWarehouseIds.isEmpty
                                                  ? AppColors.darkGray.withValues(alpha: 0.5)
                                                  : AppColors.darkGray,
                                            ),
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryBlue),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          _buildImagesPicker(),
                          SizedBox(height: ResponsiveUI.spacing(context, 24)),
                          SizedBox(
                            width: double.infinity,
                            height: ResponsiveUI.value(context, 48),
                            child: CustomElevatedButton(
                              onPressed: isLoading ? null : _validateAndSubmit,
                              text: isLoading
                                  ? LocaleKeys.saving_pandel.tr()
                                  : LocaleKeys.save_pandel.tr(),
                              isLoading: isLoading,
                            ),
                          ),
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        ],
                      ),
                    ),
                  ),
                  if (productsState is ProductsLoading)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryBlue),
                            Text(LocaleKeys.processing.tr()),
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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
