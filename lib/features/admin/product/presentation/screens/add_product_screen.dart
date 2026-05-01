// lib/features/admin/product/presentation/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_button_widget.dart';
import 'package:GoSystem/core/widgets/custom_drop_down_menu.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:GoSystem/core/widgets/custom_textfield/build_text_field.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/features/admin/product/cubit/product_filter_state.dart';
import 'package:GoSystem/features/admin/product/models/filter_models.dart';
import 'package:GoSystem/features/admin/units/cubit/units_cubit.dart';
import 'package:GoSystem/features/admin/units/model/unit_model.dart';
import '../../../../../core/utils/image_handler.dart';
import '../../cubit/filter_product_cubit/product_filter_cubit.dart';
import '../../models/product_to_add.dart';
import '../widgets/add_product_custom_widgets.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with TickerProviderStateMixin {
  // Controllers
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _arDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _wholePriceController = TextEditingController();
  final _startQuantityController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _maxToShowController = TextEditingController();
  final _productUnitController = TextEditingController();
  final _saleUnitController = TextEditingController();
  final _purchaseUnitController = TextEditingController();
  final _codeController = TextEditingController();

  // Images
  File? _mainImage;
  List<File> _galleryImages = [];

  // Dropdowns
  List<CategoryFilter>? _selectedCategories;
  BrandFilter? _selectedBrand;

  UnitModel? _selectedSaleUnit;
  UnitModel? _selectedPurchaseUnit;
  UnitModel? _selectedProductUnit;

  // Checkboxes
  bool _hasExpiry = false;
  bool _hasIMEI = false;
  bool _showQuantity = false;
  bool _isFeatured = false;

  // Expiry Date
  DateTime? _expiryDate;

  // Variations & Options (from API)
  List<VariationFilter> _variations = [];
  List<VariationFilter> _selectedVariations = [];
  Map<VariationFilter, List<FilterOption>> _selectedOptionsPerVariation = {};

  @override
  void initState() {
    super.initState();
    context.read<ProductFiltersCubit>().getFilters();
    
    _variations = context.read<ProductFiltersCubit>().variations;

    // _codeController.text = await _generateCode();

    _initializeControllers();

    // Set default values
    _minQuantityController.text = '50';
    _lowStockController.text = '10';
    _maxToShowController.text = '100';
    _startQuantityController.text = '0';
    _quantityController.text = '1';
    _wholePriceController.text = '0';
  }

  Future<void> _initializeControllers() async {
    context.read<UnitsCubit>().getUnits();
    try {
      final code = await _generateCode();
      
      if (!mounted) return;

      setState(() {
        _codeController.text = code;
      });
    } catch (e) {
      debugPrint("Error generating code: $e");
    }
  }

  Future<void> _pickMainImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _mainImage = File(pickedFile.path));
    }
  }

  Future<void> _pickGalleryImages() async {
    final pickedFiles = await ImagePicker().pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _galleryImages.addAll(pickedFiles.map((file) => File(file.path)));
      });
    }
  }

  void _removeGalleryImage(int index) {
    setState(() => _galleryImages.removeAt(index));
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: AppColors.white,
              onSurface: AppColors.darkGray,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _expiryDate = picked);
    }
  }

  Future<String> _generateCode() async {
  return await context.read<ProductsCubit>().generateCode();
}

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductAddSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is ProductsError) {
          CustomSnackbar.showError(context, state.message);
        }
        //  else if (state is ProductCodeSuccess) {
        //   _codeController.text = state.code.toString();
        // }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.lightBlueBackground,
          appBar: appBarWithActions(context, title: "Add Product"),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.horizontalPadding(context),
                vertical: ResponsiveUI.padding(context, 16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Information Section
                  ProductSectionCard(
                    title: 'Product Information',
                    icon: Icons.inventory_2,
                    children: [
                      buildTextField(
                        context,
                        controller: _nameController,
                        label: 'Product Name (EN) *',
                        icon: Icons.label,
                        hint: 'Enter product name in English',
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      buildTextField(
                        context,
                        controller: _arNameController,
                        label: 'Product Name (AR) *',
                        icon: Icons.label,
                        hint: 'أدخل اسم المنتج بالعربية',
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      buildTextField(
                        context,
                        controller: _descriptionController,
                        label: 'Description (EN) *',
                        icon: Icons.description,
                        hint: 'Enter product description',
                        maxLines: 3,
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      buildTextField(
                        context,
                        controller: _arDescriptionController,
                        label: 'Description (AR) *',
                        icon: Icons.description,
                        hint: 'أدخل وصف المنتج',
                        maxLines: 3,
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 20)),

                  // Category & Brand Section
                  ProductSectionCard(
                    title: 'Category & Brand',
                    icon: Icons.category,
                    children: [
                      BlocBuilder<ProductFiltersCubit, ProductFiltersState>(
                        builder: (context, filtersState) {
                          if (filtersState is ProductFiltersLoading) {
                            return _buildLoadingDropdown(
                              'Loading categories...',
                            );
                          }
                          if (filtersState is ProductFiltersSuccess) {
                            return _buildCategoriesDropdown(
                              filtersState.filters.data!.categories,
                            );
                          }
                          return EmptyStateWidget(
                            message: 'No categories available',
                            icon: Icons.category,
                            color: AppColors.warningOrange,
                          );
                        },
                      ),
                      //SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      BlocBuilder<ProductFiltersCubit, ProductFiltersState>(
                        builder: (context, filtersState) {
                          if (filtersState is ProductFiltersLoading) {
                            return _buildLoadingDropdown('Loading brands...');
                          }
                          if (filtersState is ProductFiltersSuccess) {
                            return _buildBrandDropdown(
                              filtersState.filters.data!.brands,
                            );
                          }
                          return EmptyStateWidget(
                            message: 'No categories available',
                            icon: Icons.category,
                            color: AppColors.warningOrange,
                          );
                        },
                      ),
                     
                    ],
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 20)),

                  // Pricing & Stock Section
                  ProductSectionCard(
                    title: 'Pricing & Stock',
                    icon: Icons.attach_money,
                    children: [
                      // Row(
                      //   children: [
                      //Expanded(child:
                      // buildTextField(
                      //   context,
                      //   controller: _saleUnitController,
                      //   label: 'Sale Unit *',
                      //   icon: Icons.scale,
                      //   hint: 'piece, kg, etc.',
                      // ),

                      // buildTextField(
                      //   context,
                      //   controller: _purchaseUnitController,
                      //   label: 'Purchase Unit *',
                      //   icon: Icons.scale,
                      //   hint: 'piece, kg, etc.',
                      // ),

                      // buildTextField(
                      //   context,
                      //   controller: _productUnitController,
                      //   label: 'Product Unit *',
                      //   icon: Icons.scale,
                      //   hint: 'piece, kg, etc.',
                      // ),

                       BlocBuilder<UnitsCubit, UnitsState>(
                        builder: (context, unitState) {
                          if (unitState is GetUnitsLoading) {
                            return _buildLoadingDropdown('Loading units...');
                          }
                          if (unitState is GetUnitsSuccess) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                
                                _buildPurchaseUnitDropdown(unitState.units),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                _buildSaleUnitDropdown(unitState.units),
                                SizedBox(height: ResponsiveUI.spacing(context, 12)),
                                _buildProductUnitDropdown(unitState.units),
                                 SizedBox(height: ResponsiveUI.spacing(context, 12)),
                              ],
                            );
                          }
                          return EmptyStateWidget(
                            message: 'No units available',
                            icon: Icons.category,
                            color: AppColors.warningOrange,
                          );
                        },
                      ),
                      //),
                      //     SizedBox(width: ResponsiveUI.spacing(context, 12)),

                      //   ],
                      // ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              context,
                              controller: _minQuantityController,
                              label: 'Min. Wholesale Qty *',
                              icon: Icons.shopping_cart,
                              hint: '1',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Expanded(
                            child: buildTextField(
                              context,
                              controller: _wholePriceController,
                              label: 'Wholesale Price',
                              icon: Icons.money_off,
                              hint: '0.00',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                      Row(
                        children: [
                          Expanded(
                            child: buildTextField(
                              context,
                              controller: _startQuantityController,
                              label: 'Start Quantity',
                              icon: Icons.inventory,
                              hint: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          SizedBox(width: ResponsiveUI.spacing(context, 12)),
                          Expanded(
                            child: buildTextField(
                              context,
                              controller: _lowStockController,
                              label: 'Low Stock Alert',
                              icon: Icons.warning,
                              hint: '10',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 12)),
                    ],
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 20)),

                  // Product Settings Section
                  ProductSectionCard(
                    title: 'Product Settings',
                    icon: Icons.settings,
                    children: [
                      AnimatedCheckboxTile(
                        value: _isFeatured,
                        title: 'Is Featured',
                        //   icon: Icons.calendar_today,
                        onChanged: (value) {
                          setState(() {
                            _isFeatured = value ?? false;
                          });
                        },
                      ),
                      AnimatedCheckboxTile(
                        value: _hasExpiry,
                        title: 'Has Expiry Date',
                        //   icon: Icons.calendar_today,
                        onChanged: (value) {
                          setState(() {
                            _hasExpiry = value ?? false;
                            if (!_hasExpiry) _expiryDate = null;
                          });
                        },
                      ),
                      if (_hasExpiry) ...[
                        //SizedBox(height: ResponsiveUI.spacing(context, 8)),
                        DatePickerCard(
                          selectedDate: _expiryDate,
                          onTap: _selectExpiryDate,
                          label: 'Expiry Date',
                        ),
                      ],
                      AnimatedCheckboxTile(
                        value: _hasIMEI,
                        title: 'Product has IMEI/Serial Number',
                        // icon: Icons.qr_code,
                        onChanged: (value) =>
                            setState(() => _hasIMEI = value ?? false),
                      ),
                      AnimatedCheckboxTile(
                        value: _showQuantity,
                        title: 'Show Quantity',
                        //  icon: Icons.visibility,
                        onChanged: (value) =>
                            setState(() => _showQuantity = value ?? true),
                      ),
                      if (_showQuantity) ...[
                        SizedBox(height: ResponsiveUI.spacing(context, 8)),
                        buildTextField(
                          context,
                          controller: _maxToShowController,
                          label: 'Maximum to Show',
                          icon: Icons.visibility,
                          hint: '100',
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      ],
                    ],
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 20)),

                  // Product Images Section
                  ProductSectionCard(
                    title: 'Product Images',
                    icon: Icons.image,
                    children: [
                      MainImagePicker(
                        image: _mainImage,
                        onPick: _pickMainImage,
                        onRemove: () => setState(() => _mainImage = null),
                      ),
                      SizedBox(height: ResponsiveUI.spacing(context, 16)),
                      GalleryImagesPicker(
                        images: _galleryImages,
                        onAdd: _pickGalleryImages,
                        onRemove: _removeGalleryImage,
                      ),
                    ],
                  ),

                  SizedBox(height: ResponsiveUI.spacing(context, 30)),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 56),
                    child: CustomElevatedButton(
                      onPressed: state is ProductsLoading ? null : _saveProduct,
                      text: state is ProductsLoading
                          ? 'Saving Product...'
                          : 'Save Product',
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 20)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingDropdown(String message) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      child: CustomLoadingState(
        message: message,
        color: AppColors.primaryBlue,
        size: ResponsiveUI.iconSize(context, 40),
      ),
    );
  }

  Widget _buildCategoriesDropdown(List<CategoryFilter> categories) {
    return buildMultiSelectDropdownField<CategoryFilter>(
      context,
      items: categories,
      hint: 'Search categories...',
      onChanged: (value) {
        setState(() {
          _selectedCategories = value;
        });
      },

      itemLabel: (category) => category.name,

      //value: null,
    );
  }

  Widget _buildBrandDropdown(List<BrandFilter> brands) {
    return buildDropdownField<BrandFilter>(
      context,
      items: brands,
      hint: 'Search brands...',
      onChanged: (value) {
        setState(() {
          _selectedBrand = value;
        });
      },
      itemLabel: (brand) => brand.name,
      value: null,
      label: '',
      //icon: Icons.keyboard_arrow_down_rounded,
    );
  }

  Widget _buildProductUnitDropdown(List<UnitModel> units) {
    return buildDropdownField<UnitModel>(
      context,
      items: units,
      hint: 'Select Product Unit',
      onChanged: (value) {
        setState(() {
          _selectedProductUnit = value;
        });
      },
      itemLabel: (brand) => brand.name,
      value: _selectedProductUnit,
      label: 'Product Unit',
    );
  }

  Widget _buildPurchaseUnitDropdown(List<UnitModel> units) {
    return buildDropdownField<UnitModel>(
      context,
      items: units,
      hint: 'Select Purchase Unit',
      onChanged: (value) {
        setState(() {
          _selectedPurchaseUnit = value;
        });
      },
      itemLabel: (brand) => brand.name,
      value: _selectedPurchaseUnit,
      label: 'Purchase Unit',
    );
  }

  Widget _buildSaleUnitDropdown(List<UnitModel> units) {
    return buildDropdownField<UnitModel>(
      context,
      items: units,
      hint: 'Select Sale Unit',
      onChanged: (value) {
        setState(() {
          _selectedSaleUnit = value;
        });
      },
      itemLabel: (brand) => brand.name,
      value: _selectedSaleUnit,
      label: 'Sale Unit',
    );
  }

  // Only the _saveProduct() method is updated — rest of your file stays the same

  void _saveProduct() async {
    // === Validation ===
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter product name (EN)');
      return;
    }
    if (_arNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'Please enter product name (AR)');
      return;
    }
    // Image is now optional - removed validation
    if (_selectedCategories == null || _selectedCategories!.isEmpty) {
      CustomSnackbar.showError(context, 'Please select at least one category');
      return;
    }
    if (_selectedBrand == null) {
      CustomSnackbar.showError(context, 'Please select a brand');
      return;
    }
    

    // Parse numeric fields safely
    final double mainPrice = double.tryParse(_priceController.text) ?? 0.0;
    final double wholePrice =
        double.tryParse(_wholePriceController.text) ?? 0.0;
    final int quantity = int.tryParse(_quantityController.text) ?? 0;
    final int startQuantity = int.tryParse(_startQuantityController.text) ?? 0;
    final int minQtySale = int.tryParse(_minQuantityController.text) ?? 1;
    final int lowStock = int.tryParse(_lowStockController.text) ?? 10;
    final int maxToShow = _showQuantity
        ? (int.tryParse(_maxToShowController.text) ?? 100)
        : 0;

    // === Encode Images (optional) ===
    final String? mainImageBase64 = _mainImage != null 
        ? ImageHelper.encodeImageToBase64(_mainImage!) 
        : null;
    final List<String> galleryBase64 = _galleryImages
        .map((img) => ImageHelper.encodeImageToBase64(img))
        .toList();

    // === Call Cubit ===
    context.read<ProductsCubit>().addProductWithData(
      name: _nameController.text.trim(),
      arName: _arNameController.text.trim(),
      description: _descriptionController.text.trim(),
      arDescription: _arDescriptionController.text.trim(),
      image: mainImageBase64,
      categoryIds: _selectedCategories!.map((c) => c.id).toList(),
      brandId: _selectedBrand!.id,
      purchaseUnit: _selectedPurchaseUnit!.id, // or .name depending on API
      saleUnit: _selectedSaleUnit!.id, // or .name depending on API
      productUnit: _selectedProductUnit!.id,
      price: mainPrice,
      expAbility: _hasExpiry,
      code: _codeController.text.trim(),
      minimumQuantitySale: minQtySale,
      lowStock: lowStock,
      wholePrice: wholePrice,
      startQuantity: startQuantity,
      quantity: quantity,
      taxesId:
          '67056d0a3b233c5c1b36a7ae', // Replace later with dynamic tax selection
      productHasImei: _hasIMEI,
      showQuantity: _showQuantity,
      isFeatured: _isFeatured,
      maximumToShow: maxToShow,
      galleryProduct: galleryBase64,
      expiryDate: _expiryDate,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _arNameController.dispose();
    _descriptionController.dispose();
    _arDescriptionController.dispose();
    _priceController.dispose();
    _wholePriceController.dispose();
    _startQuantityController.dispose();
    _lowStockController.dispose();
    _minQuantityController.dispose();
    _maxToShowController.dispose();
    _productUnitController.dispose();
    _purchaseUnitController.dispose();
    _saleUnitController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
