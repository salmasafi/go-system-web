// lib/features/admin/product/presentation/screens/edit_product_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
import '../../../../../core/utils/image_handler.dart';
import '../../cubit/filter_product_cubit/product_filter_cubit.dart';
import '../widgets/add_product_custom_widgets.dart';
import '../../models/product_model.dart'; // Updated import for the product model

class PriceVariation {
  TextEditingController priceController;
  TextEditingController codeController;
  TextEditingController quantityController;
  List<String> selectedOptions;
  List<File> galleryImages;
  List<String> galleryUrls;

  PriceVariation({
    required this.priceController,
    required this.codeController,
    required this.quantityController,
    required this.selectedOptions,
    List<File>? galleryImages,
    List<String>? galleryUrls,
  })  : galleryImages = galleryImages ?? [],
        galleryUrls = galleryUrls ?? [];

  void dispose() {
    priceController.dispose();
    codeController.dispose();
    quantityController.dispose();
  }
}

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen>
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
  final _unitController = TextEditingController();
  final _codeController = TextEditingController();

  // Images
  File? _mainImage;
  String? mainImageUrl;
  List<File> _galleryImages = [];
  List<String> galleryImageUrls = [];

  // Dropdowns
  List<CategoryFilter>? _selectedCategories;
  BrandFilter? _selectedBrand;

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

  bool populated = false;

  @override
  void initState() {
    super.initState();
    context.read<ProductFiltersCubit>().getFilters();

    _nameController.text = widget.product.name;
    _arNameController.text = widget.product.arName;
    _descriptionController.text = widget.product.description;
    _arDescriptionController.text = widget.product.arDescription;
    _wholePriceController.text = widget.product.wholePrice.toString();
    _startQuantityController.text = widget.product.startQuantaty.toString();
    _quantityController.text = widget.product.quantity.toString();
    _lowStockController.text = widget.product.lowStock.toString();
    _minQuantityController.text = widget.product.minimumQuantitySale.toString();
    _maxToShowController.text = widget.product.maximumToShow.toString();
    _unitController.text = widget.product.unit;
    _hasExpiry = widget.product.expAbility;
    _expiryDate = widget.product.dateOfExpiry;
    _hasIMEI = widget.product.productHasImei;
    // Note: differentPrice removed in migration 014
    _differentPrice = false; // Always false now
    _showQuantity = widget.product.showQuantity;
    _isFeatured = widget.product.isFeatured ?? false;
    mainImageUrl = widget.product.image;
    galleryImageUrls = widget.product.galleryProduct;

    // Always use single price now
    _priceController.text = widget.product.price.toString();
    _codeController.text = ''; // Assume no main code, or fetch if available
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
      if (selectedOpts.isEmpty) continue;

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

  void _generateVariations() {
    final combos = _generateOptionCombinations();
    setState(() {
      for (var variation in _priceVariations) {
        variation.dispose();
      }
      _priceVariations = combos.map((combo) {
        return PriceVariation(
          priceController: TextEditingController(),
          codeController: TextEditingController(),
          quantityController: TextEditingController(text: '0'),
          selectedOptions: combo,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenContent = BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductAddSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is ProductsError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        return BlocListener<ProductFiltersCubit, ProductFiltersState>(
          listener: (context, filtersState) {
            if (filtersState is ProductFiltersSuccess) {
              _variations = filtersState.filters.data!.variations;
              if (!populated) {
                populated = true;
              }
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.lightBlueBackground,
            appBar: appBarWithActions(context, title: "تعديل منتج"),
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
                      title: 'معلومات المنتج',
                      icon: Icons.inventory_2,
                      children: [
                        buildTextField(
                          context,
                          controller: _nameController,
                          label: 'اسم المنتج (EN) *',
                          icon: Icons.label,
                          hint: 'أدخل اسم المنتج بالإنجليزية',
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),
                        buildTextField(
                          context,
                          controller: _arNameController,
                          label: 'اسم المنتج (AR) *',
                          icon: Icons.label,
                          hint: 'أدخل اسم المنتج بالعربية',
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),
                        buildTextField(
                          context,
                          controller: _descriptionController,
                          label: 'الوصف (EN) *',
                          icon: Icons.description,
                          hint: 'أدخل وصف المنتج بالإنجليزية',
                          maxLines: 3,
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),
                        buildTextField(
                          context,
                          controller: _arDescriptionController,
                          label: 'الوصف (AR) *',
                          icon: Icons.description,
                          hint: 'أدخل وصف المنتج بالعربية',
                          maxLines: 3,
                        ),
                      ],
                    ),

                    SizedBox(height: ResponsiveUI.spacing(context, 20)),

                    // Category & Brand Section
                    ProductSectionCard(
                      title: 'الفئة والعلامة التجارية',
                      icon: Icons.category,
                      children: [
                        BlocBuilder<ProductFiltersCubit, ProductFiltersState>(
                          builder: (context, filtersState) {
                            if (filtersState is ProductFiltersLoading) {
                              return _buildLoadingDropdown(
                                'جاري تحميل الفئات...',
                              );
                            }
                            if (filtersState is ProductFiltersSuccess) {
                              return _buildCategoriesDropdown(
                                filtersState.filters.data!.categories,
                              );
                            }
                            return EmptyStateWidget(
                              message: 'لا توجد فئات متاحة',
                              icon: Icons.category,
                              color: AppColors.warningOrange,
                            );
                          },
                        ),
                        BlocBuilder<ProductFiltersCubit, ProductFiltersState>(
                          builder: (context, filtersState) {
                            if (filtersState is ProductFiltersLoading) {
                              return _buildLoadingDropdown('جاري تحميل العلامات التجارية...');
                            }
                            if (filtersState is ProductFiltersSuccess) {
                              return _buildBrandDropdown(
                                filtersState.filters.data!.brands,
                              );
                            }
                            return EmptyStateWidget(
                              message: 'لا توجد علامات تجارية متاحة',
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
                      title: 'التسعير والمخزون',
                      icon: Icons.attach_money,
                      children: [
                        buildTextField(
                          context,
                          controller: _unitController,
                          label: 'الوحدة *',
                          icon: Icons.scale,
                          hint: 'قطعة، كجم، إلخ.',
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 12)),
                        Row(
                          children: [
                            Expanded(
                              child: buildTextField(
                                context,
                                controller: _minQuantityController,
                                label: 'الحد الأدنى لكمية الجملة *',
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
                                label: 'سعر الجملة',
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
                                label: 'الكمية الابتدائية',
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
                                label: 'تنبيه المخزون المنخفض',
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
                      title: 'إعدادات المنتج',
                      icon: Icons.settings,
                      children: [
                        AnimatedCheckboxTile(
                          value: _isFeatured,
                          title: 'منتج مميز',
                          onChanged: (value) {
                            setState(() {
                              _isFeatured = value ?? false;
                            });
                          },
                        ),
                        AnimatedCheckboxTile(
                          value: _hasExpiry,
                          title: 'له تاريخ انتهاء صلاحية',
                          onChanged: (value) {
                            setState(() {
                              _hasExpiry = value ?? false;
                              if (!_hasExpiry) _expiryDate = null;
                            });
                          },
                        ),
                        if (_hasExpiry) ...[
                          DatePickerCard(
                            selectedDate: _expiryDate,
                            onTap: _selectExpiryDate,
                            label: 'تاريخ انتهاء الصلاحية',
                          ),
                        ],
                        AnimatedCheckboxTile(
                          value: _hasIMEI,
                          title: 'المنتج له رقم IMEI/تسلسلي',
                          onChanged: (value) =>
                              setState(() => _hasIMEI = value ?? false),
                        ),
                        AnimatedCheckboxTile(
                          value: _showQuantity,
                          title: 'إظهار الكمية',
                          onChanged: (value) =>
                              setState(() => _showQuantity = value ?? true),
                        ),
                        if (_showQuantity) ...[
                          SizedBox(height: ResponsiveUI.spacing(context, 8)),
                          buildTextField(
                            context,
                            controller: _maxToShowController,
                            label: 'الحد الأقصى للعرض',
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
                          title: 'أسعار مختلفة للتنويعات',
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
                      title: 'صور المنتج',
                      icon: Icons.image,
                      children: [
                        MainImagePicker(
                          image: _mainImage,
                          onPick: _pickMainImage,
                          onRemove: () => setState(() {
                            _mainImage = null;
                            mainImageUrl = null;
                          }),
                        ),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        GalleryImagesPicker(
                          images: _galleryImages,
                          onAdd: _pickGalleryImages, onRemove: (int p1) {  },
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
                            ? 'جاري تحديث المنتج...'
                            : 'تحديث المنتج',
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 20)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Scale down for web
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

  Widget _buildPriceVariationsSection() {
    return ProductSectionCard(
      title: 'تنويعات الأسعار',
      icon: Icons.price_change,
      children: [
        Text(
          'اختر التنويعات',
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
          hint: 'اختر التنويعات...',
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
                  'اختر الخيارات لـ ${variation.name}',
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
                  hint: 'اختر الخيارات...',
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
            text: 'إنشاء التركيبات',
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
            label: 'السعر *',
            icon: Icons.attach_money,
            hint: '0.00',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: variation.codeController,
            label: 'كود المنتج *',
            icon: Icons.qr_code,
            hint: 'أدخل كود فريد',
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          buildTextField(
            context,
            controller: variation.quantityController,
            label: 'الكمية',
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
    List<dynamic> allGallery = [...variation.galleryUrls, ...variation.galleryImages];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'صور التنويع',
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
              label: Text('إضافة', style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 12))),
            ),
          ],
        ),
        if (allGallery.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(allGallery.length, (imgIndex) {
              dynamic img = allGallery[imgIndex];
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
                      child: img is String
                          ? Image.network(img, fit: BoxFit.contain)
                          : Image.file(img, fit: BoxFit.contain),
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
                          if (imgIndex < variation.galleryUrls.length) {
                            variation.galleryUrls.removeAt(imgIndex);
                          } else {
                            variation.galleryImages.removeAt(
                              imgIndex - variation.galleryUrls.length,
                            );
                          }
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
      hint: 'ابحث عن الفئات...',
      onChanged: (value) {
        setState(() {
          _selectedCategories = value;
        });
      },
      itemLabel: (category) => category.name,
    );
  }

  Widget _buildBrandDropdown(List<BrandFilter> brands) {
    return buildDropdownField<BrandFilter>(
      context,
      items: brands,
      hint: 'ابحث عن العلامات التجارية...',
      onChanged: (value) {
        setState(() {
          _selectedBrand = value;
        });
      },
      itemLabel: (brand) => brand.name,
      value: null,
      label: '',
    );
  }

  void _saveProduct() async {
    // === Validation ===
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'الرجاء إدخال اسم المنتج (EN)');
      return;
    }
    if (_arNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'الرجاء إدخال اسم المنتج (AR)');
      return;
    }
    // Image is now optional - removed validation
    if (_selectedCategories == null || _selectedCategories!.isEmpty) {
      CustomSnackbar.showError(context, 'الرجاء اختيار فئة واحدة على الأقل');
      return;
    }
    if (_selectedBrand == null) {
      CustomSnackbar.showError(context, 'الرجاء اختيار علامة تجارية');
      return;
    }
    if (_unitController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'الرجاء إدخال الوحدة (مثل: قطعة)');
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
            'أدخل السعر للتنويع ${i + 1}',
          );
          return;
        }

        if (v.codeController.text.trim().isEmpty) {
          CustomSnackbar.showError(
            context,
            'أدخل كود المنتج للتنويع ${i + 1}',
          );
          return;
        } else {
          final code = v.codeController.text.trim();
          if (codes.contains(code)) {
            CustomSnackbar.showError(
              context,
              'لا تدخل نفس الأكواد لتنويعات الأسعار',
            );
            return;
          } else {
            codes.add(code);
          }
        }

        pricesJson.add({
          "price": double.tryParse(v.priceController.text.trim()) ?? 0.0,
          "code": v.codeController.text.trim(),
          "quantity": int.tryParse(v.quantityController.text) ?? 0,
          "gallery": [...v.galleryUrls, ...v.galleryImages.map((img) => ImageHelper.encodeImageToBase64(img))],
          "options": v.selectedOptions,
        });
      }
    }

    // === Encode Images ===
    // If no new image selected, keep the existing URL; otherwise encode new image
    String? mainImageBase64 = _mainImage != null 
        ? ImageHelper.encodeImageToBase64(_mainImage!) 
        : mainImageUrl; // keep existing image URL if no new image picked
    List<String> galleryBase64 = [...galleryImageUrls, ..._galleryImages.map((img) => ImageHelper.encodeImageToBase64(img))];

    // === Call Cubit ===
    context.read<ProductsCubit>().updateProductWithData(
      id: widget.product.id,
      name: _nameController.text.trim(),
      arName: _arNameController.text.trim(),
      description: _descriptionController.text.trim(),
      arDescription: _arDescriptionController.text.trim(),
      image: mainImageBase64, // Made optional
      categoryIds: _selectedCategories!.map((c) => c.id).toList(),
      brandId: _selectedBrand!.id,
      unit: _unitController.text.trim(),
      price: mainPrice, // Always use single price now
      expAbility: _hasExpiry,
      code: _codeController.text.trim(),
      minimumQuantitySale: minQtySale,
      lowStock: lowStock,
      wholePrice: wholePrice,
      startQuantity: startQuantity,
      quantity: quantity,
      taxesId: '67056d0a3b233c5c1b36a7ae',
      productHasImei: _hasIMEI,
      // Note: differentPrice and prices removed in migration 014
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
    _unitController.dispose();
    _codeController.dispose();
    for (var variation in _priceVariations) {
      variation.dispose();
    }
    super.dispose();
  }
}
