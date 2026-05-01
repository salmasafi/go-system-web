// lib/features/admin/product/presentation/screens/add_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_drop_down_menu.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:systego/features/admin/product/cubit/product_filter_state.dart';
import 'package:systego/features/admin/product/models/filter_models.dart';
import 'package:systego/features/admin/units/cubit/unit_cubit.dart';
import 'package:systego/features/admin/units/cubit/unit_state.dart';
import 'package:systego/features/admin/units/model/unit_model.dart';
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
  bool _differentPrice = false;
  bool _showQuantity = false;
  bool _isFeatured = false;

  // Expiry Date
  DateTime? _expiryDate;

  // Variations & Options (from API)
  List<VariationFilter> _variations = [];
  List<VariationFilter> _selectedVariations = [];
  Map<VariationFilter, List<FilterOption>> _selectedOptionsPerVariation = {};
  List<PriceVariation> _priceVariations = [];

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

  List<List<String>> _generateOptionCombinations() {
    if (_selectedVariations.isEmpty) return [];

    List<List<String>> result = [[]];

    for (var variation in _selectedVariations) {
      final selectedOpts = _selectedOptionsPerVariation[variation] ?? [];
      if (selectedOpts.isEmpty) continue; // Skip if no options selected

      List<List<String>> newResult = [];
      for (var combo in result) {
        for (var option in selectedOpts) {
          newResult.add([...combo, option.id]);
        }
      }
      result = newResult;
    }

    return result;
  }

  // void _generateVariations() {
  //   final combos = _generateOptionCombinations();
  //   setState(() {
  //     for (var variation in _priceVariations) {
  //       variation.dispose();
  //     }
  //     _priceVariations = combos.map((combo) {
  //       final code = await _generateCode();
  //       return PriceVariation(
  //         priceController: TextEditingController(),
  //         codeController: TextEditingController(text: code),
  //         quantityController: TextEditingController(text: '0'),
  //         selectedOptions: combo,
  //         galleryImages: [],
  //       );
  //     }).toList();
  //   });
  // }

  Future<void> _generateVariations() async {
  final combos = _generateOptionCombinations();

  final variationFutures = combos.map((combo) async {
    final code = await _generateCode(); // This await is now valid
    
    return PriceVariation(
      priceController: TextEditingController(),
      codeController: TextEditingController(text: code),
      quantityController: TextEditingController(text: '0'),
      selectedOptions: combo,
      galleryImages: [],
    );
  });

  final newVariations = await Future.wait(variationFutures);

  if (!mounted) return; 
  
  setState(() {
    for (var variation in _priceVariations) {
      variation.dispose();
    }
    _priceVariations = newVariations;
  });
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
                          if (unitState is UnitsLoading) {
                            return _buildLoadingDropdown('Loading units...');
                          }
                          if (unitState is UnitsSuccess) {
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
                      AnimatedCheckboxTile(
                        priceController: _priceController,
                        quantityController: _quantityController,
                        codeController: _codeController,
                        value: _differentPrice,
                        title: 'Different Prices for Variations',
                        //   icon: Icons.price_check,
                        onChanged: (value) {
                          setState(() {
                            _differentPrice = value ?? false;
                            if (!_differentPrice) {
                              for (var variation in _priceVariations) {
                                variation.dispose();
                              }
                              _priceVariations.clear();
                              _selectedVariations.clear();
                              _selectedOptionsPerVariation.clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  if (_differentPrice) ...[
                    SizedBox(height: ResponsiveUI.spacing(context, 20)),
                    _buildPriceVariationsSection(),
                  ],

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

  Widget _buildPriceVariationsSection() {
    return ProductSectionCard(
      title: 'Price Variations',
      icon: Icons.price_change,
      children: [
        Text(
          'Select Variations',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        buildMultiSelectDropdownField<VariationFilter>(
          context,
          items: _variations,
          hint: 'Select variations...',
          onChanged: (value) {
            setState(() {
              _selectedVariations = value;
              _selectedOptionsPerVariation.removeWhere(
                (key, value) => !_selectedVariations.contains(key),
              );
            });
          },
          itemLabel: (variation) => variation.name,
        ),
        if (_selectedVariations.isNotEmpty) ...[
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          ..._selectedVariations.map((var variation) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Options for ${variation.name}',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 8)),
                buildMultiSelectDropdownField<FilterOption>(
                  context,
                  items: variation.options,
                  hint: 'Select options...',
                  onChanged: (selectedOpts) {
                    setState(() {
                      _selectedOptionsPerVariation[variation] = selectedOpts;
                    });
                  },
                  itemLabel: (option) => option.name,
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 16)),
              ],
            );
          }),
          CustomElevatedButton(
            onPressed:
                _selectedVariations.every(
                  (v) => (_selectedOptionsPerVariation[v] ?? []).isNotEmpty,
                )
                ? _generateVariations
                : null,
            text: 'Generate Combinations',
          ),
        ],
        if (_priceVariations.isNotEmpty) ...[
          SizedBox(height: ResponsiveUI.spacing(context, 20)),
          Column(
            children: List.generate(_priceVariations.length, (index) {
              return Column(
                children: [
                  _buildPriceVariationForm(index),
                  if (index < _priceVariations.length - 1)
                    Divider(height: ResponsiveUI.spacing(context, 20)),
                ],
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildPriceVariationForm(int index) {
    final variation = _priceVariations[index];
    final label = variation.selectedOptions
        .map((optionId) {
          for (var v in _variations) {
            final opt = v.options.firstWhere(
              (o) => o.id == optionId,
              orElse: () => FilterOption(
                id: '',
                variationId: '',
                name: 'Unknown',
                status: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );
            if (opt.id != '') return opt.name;
          }
          return 'Unknown';
        })
        .join(' - ');

    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: variation.priceController,
            label: 'Price *',
            icon: Icons.attach_money,
            hint: '0.00',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: variation.codeController,
            label: 'Product Code *',
            icon: Icons.qr_code,
            hint: 'Enter unique code',
            readOnly: true
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: variation.quantityController,
            label: 'Quantity',
            icon: Icons.inventory,
            hint: '0',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildVariationGallery(variation),
        ],
      ),
    );
  }

  Widget _buildVariationGallery(PriceVariation variation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Variation Images',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 13),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                final pickedFiles = await ImagePicker().pickMultiImage();
                if (pickedFiles.isNotEmpty) {
                  setState(() {
                    variation.galleryImages.addAll(
                      pickedFiles.map((file) => File(file.path)),
                    );
                  });
                }
              },
              icon: Icon(Icons.add_photo_alternate, size: ResponsiveUI.iconSize(context, 16)),
              label: Text('Add', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 12))),
            ),
          ],
        ),
        if (variation.galleryImages.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(variation.galleryImages.length, (imgIndex) {
              return Stack(
                children: [
                  Container(
                    width: ResponsiveUI.value(context, 60),
                    height: ResponsiveUI.value(context, 60),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                      border: Border.all(color: AppColors.lightGray),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                      child: Image.file(
                        variation.galleryImages[imgIndex],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      icon: Container(
                        padding: EdgeInsets.all(ResponsiveUI.padding(context, 4)),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.close, size: ResponsiveUI.iconSize(context, 12), color: Colors.white),
                      ),
                      onPressed: () {
                        setState(() {
                          variation.galleryImages.removeAt(imgIndex);
                        });
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
      ],
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

    // === Build Price Variations ===
    List<Map<String, dynamic>> pricesJson = [];

    if (_differentPrice && _priceVariations.isNotEmpty) {
      List<String> codes = [];
      for (int i = 0; i < _priceVariations.length; i++) {
        final v = _priceVariations[i];

        if (v.priceController.text.trim().isEmpty) {
          CustomSnackbar.showError(
            context,
            'Enter price for variation ${i + 1}',
          );
          return;
        }

        if (v.codeController.text.trim().isEmpty) {
          CustomSnackbar.showError(
            context,
            'Enter product code for variation ${i + 1}',
          );
          return;
        } else {
          if (codes.contains(v.codeController.text.trim())) {
            CustomSnackbar.showError(
              context,
              'Don\'t enter the same codes for price variations',
            );
            return;
          } else {
            codes.add(v.codeController.text.trim());
          }
        }

        pricesJson.add({
          "price": double.tryParse(v.priceController.text.trim()) ?? 0.0,
          "code": v.codeController.text.trim(),
          "quantity": int.tryParse(v.quantityController.text) ?? 0,
          "gallery": v.galleryImages
              .map((img) => ImageHelper.encodeImageToBase64(img))
              .toList(),
          "options": v.selectedOptions,
        });
      }
      // Remove duplicates from codes list if needed (optional, but ensures no duplicates after processing)
      //codes = codes.toSet().toList();
    }
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
      price: _differentPrice ? 0.0 : mainPrice, // MUST be 0 if variations used
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
      differentPrice: _differentPrice,
      showQuantity: _showQuantity,
      isFeatured: _isFeatured,
      maximumToShow: maxToShow,
      galleryProduct: galleryBase64,
      prices: pricesJson,
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
    for (var variation in _priceVariations) {
      variation.dispose();
    }
    super.dispose();
  }
}
