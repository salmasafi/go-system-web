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
import 'package:GoSystem/features/admin/brands/cubit/brand_cubit.dart';
import 'package:GoSystem/features/admin/brands/cubit/brand_states.dart';
import 'package:GoSystem/features/admin/brands/model/get_brands_model.dart';
import 'package:GoSystem/features/admin/categories/cubit/categories_cubit.dart';
import 'package:GoSystem/features/admin/categories/cubit/categories_states.dart';
import 'package:GoSystem/features/admin/categories/model/get_categories_model.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:GoSystem/features/admin/units/cubit/units_cubit.dart';
import 'package:GoSystem/features/admin/units/model/unit_model.dart';
import '../../../../../core/utils/image_handler.dart';
import '../../models/product_model.dart';
import '../widgets/add_product_custom_widgets.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _nameController = TextEditingController();
  final _arNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _arDescriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _wholePriceController = TextEditingController();
  final _startQuantityController = TextEditingController();
  final _lowStockController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _maxToShowController = TextEditingController();
  final _codeController = TextEditingController();

  // Images
  File? _mainImage;
  String? _existingImageUrl;
  List<File> _galleryImages = [];
  List<String> _existingGalleryUrls = [];

  // Selections
  List<CategoryItem>? _selectedCategories;
  Brands? _selectedBrand;
  UnitModel? _selectedProductUnit;
  UnitModel? _selectedSaleUnit;
  UnitModel? _selectedPurchaseUnit;

  // Pre-population flags (each runs once when data loads)
  bool _categoriesPrePopulated = false;
  bool _brandPrePopulated = false;
  bool _unitPrePopulated = false;

  // Settings
  bool _hasExpiry = false;
  bool _hasIMEI = false;
  bool _showQuantity = false;
  bool _isFeatured = false;
  DateTime? _expiryDate;

  @override
  void initState() {
    super.initState();
    _initFields();
    context.read<CategoriesCubit>().getCategories();
    context.read<BrandsCubit>().getBrands();
    context.read<UnitsCubit>().getUnits();
  }

  void _initFields() {
    final p = widget.product;
    _nameController.text = p.name;
    _arNameController.text = p.arName;
    _descriptionController.text = p.description;
    _arDescriptionController.text = p.arDescription;
    _priceController.text = p.price.toString();
    _wholePriceController.text = p.wholePrice.toString();
    _startQuantityController.text = p.startQuantaty.toString();
    _lowStockController.text = p.lowStock.toString();
    _minQuantityController.text = p.minimumQuantitySale.toString();
    _maxToShowController.text = p.maximumToShow.toString();
    _hasExpiry = p.expAbility;
    _expiryDate = p.dateOfExpiry;
    _hasIMEI = p.productHasImei;
    _showQuantity = p.showQuantity;
    _isFeatured = p.isFeatured ?? false;
    _existingImageUrl = p.image.isNotEmpty ? p.image : null;
    _existingGalleryUrls = List<String>.from(p.galleryProduct);
  }

  Future<void> _pickMainImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _mainImage = File(picked.path));
  }

  Future<void> _pickGalleryImages() async {
    final picked = await ImagePicker().pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() => _galleryImages.addAll(picked.map((f) => File(f.path))));
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryBlue,
            onPrimary: AppColors.white,
            onSurface: AppColors.darkGray,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  void _saveProduct() {
    if (_nameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'الرجاء إدخال اسم المنتج بالإنجليزية');
      return;
    }
    if (_arNameController.text.trim().isEmpty) {
      CustomSnackbar.showError(context, 'الرجاء إدخال اسم المنتج بالعربية');
      return;
    }
    if (_selectedCategories == null || _selectedCategories!.isEmpty) {
      CustomSnackbar.showError(context, 'الرجاء اختيار قسم واحد على الأقل');
      return;
    }
    if (_selectedBrand == null) {
      CustomSnackbar.showError(context, 'الرجاء اختيار علامة تجارية');
      return;
    }

    final double price = double.tryParse(_priceController.text) ?? 0.0;
    final double wholePrice = double.tryParse(_wholePriceController.text) ?? 0.0;
    final int startQty = int.tryParse(_startQuantityController.text) ?? 0;
    final int minQtySale = int.tryParse(_minQuantityController.text) ?? 1;
    final int lowStock = int.tryParse(_lowStockController.text) ?? 10;
    final int maxToShow =
        _showQuantity ? (int.tryParse(_maxToShowController.text) ?? 100) : 0;

    // Keep existing image URL if no new file selected
    final String? mainImage = _mainImage != null
        ? ImageHelper.encodeImageToBase64(_mainImage!)
        : _existingImageUrl;

    // Merge existing URLs with newly picked files
    final List<String> gallery = [
      ..._existingGalleryUrls,
      ..._galleryImages.map((img) => ImageHelper.encodeImageToBase64(img)),
    ];

    context.read<ProductsCubit>().updateProductWithData(
          id: widget.product.id,
          name: _nameController.text.trim(),
          arName: _arNameController.text.trim(),
          description: _descriptionController.text.trim(),
          arDescription: _arDescriptionController.text.trim(),
          image: mainImage,
          code: _codeController.text.trim(),
          categoryIds: _selectedCategories!.map((c) => c.id).toList(),
          brandId: _selectedBrand!.id ?? '',
          unit: _selectedProductUnit?.id ?? widget.product.unit,
          price: price,
          expAbility: _hasExpiry,
          expiryDate: _expiryDate,
          minimumQuantitySale: minQtySale,
          lowStock: lowStock,
          wholePrice: wholePrice,
          startQuantity: startQty,
          quantity: startQty,
          taxesId: widget.product.taxesId ?? '67056d0a3b233c5c1b36a7ae',
          productHasImei: _hasIMEI,
          showQuantity: _showQuantity,
          isFeatured: _isFeatured,
          maximumToShow: maxToShow,
          galleryProduct: gallery,
        );
  }

  @override
  Widget build(BuildContext context) {
    Widget screen = BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductAddSuccess) {
          CustomSnackbar.showSuccess(context, state.message);
          Navigator.pop(context, true);
        } else if (state is ProductsError) {
          CustomSnackbar.showError(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is ProductsLoading;
        return Scaffold(
          backgroundColor: AppColors.shadowGray[50],
          appBar: appBarWithActions(context, title: 'تعديل المنتج'),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.horizontalPadding(context),
                vertical: ResponsiveUI.padding(context, 16),
              ),
              child: Column(
                children: [
                  _buildBasicInfoSection(),
                  _buildClassificationSection(),
                  _buildUnitsSection(),
                  _buildPricingSection(),
                  _buildStockSection(),
                  _buildSettingsSection(),
                  _buildImagesSection(),
                  SizedBox(
                    width: double.infinity,
                    height: ResponsiveUI.value(context, 56),
                    child: CustomElevatedButton(
                      onPressed: isLoading ? null : _saveProduct,
                      text: isLoading ? 'جاري التحديث...' : 'تحديث المنتج',
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (kIsWeb) {
      screen = MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(0.55)),
        child: screen,
      );
    }
    return screen;
  }

  // ── Section 1: Basic Info ─────────────────────────────────────────────────
  Widget _buildBasicInfoSection() {
    return ProductSectionCard(
      title: 'معلومات المنتج',
      icon: Icons.inventory_2_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: buildTextField(
                context,
                controller: _nameController,
                label: 'الاسم (EN) *',
                icon: Icons.label_outline,
                hint: 'Product name',
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Expanded(
              child: buildTextField(
                context,
                controller: _arNameController,
                label: 'الاسم (AR) *',
                icon: Icons.label_outline,
                hint: 'اسم المنتج',
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        buildTextField(
          context,
          controller: _descriptionController,
          label: 'الوصف (EN)',
          icon: Icons.description_outlined,
          hint: 'Product description...',
          maxLines: 3,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        buildTextField(
          context,
          controller: _arDescriptionController,
          label: 'الوصف (AR)',
          icon: Icons.description_outlined,
          hint: 'وصف المنتج...',
          maxLines: 3,
        ),
      ],
    );
  }

  // ── Section 2: Classification ─────────────────────────────────────────────
  Widget _buildClassificationSection() {
    return ProductSectionCard(
      title: 'التصنيف والعلامة التجارية',
      icon: Icons.category_outlined,
      children: [
        BlocConsumer<CategoriesCubit, CategoriesState>(
          listener: (context, state) {
            if (!_categoriesPrePopulated && state is GetCategoriesSuccess) {
              final productCategoryIds =
                  widget.product.categoryId.map((c) => c.id).toSet();
              final matched = state.categories
                  .where((cat) => productCategoryIds.contains(cat.id))
                  .toList();
              if (matched.isNotEmpty) {
                setState(() {
                  _selectedCategories = matched;
                  _categoriesPrePopulated = true;
                });
              } else {
                _categoriesPrePopulated = true;
              }
            }
          },
          builder: (context, state) {
            if (state is GetCategoriesLoading) {
              return _loadingWidget('جاري تحميل الأقسام...');
            }
            if (state is GetCategoriesSuccess) {
              return buildMultiSelectDropdownField<CategoryItem>(
                context,
                items: state.categories,
                hint: 'اختر الأقسام...',
                onChanged: (val) =>
                    setState(() => _selectedCategories = val),
                itemLabel: (cat) => cat.name,
                selectedItems: _selectedCategories ?? const [],
              );
            }
            return EmptyStateWidget(
              message: 'لا توجد أقسام',
              icon: Icons.category_outlined,
              color: AppColors.warningOrange,
            );
          },
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        BlocConsumer<BrandsCubit, BrandsState>(
          listener: (context, state) {
            if (!_brandPrePopulated && state is GetBrandsSuccess) {
              final brands = state.brands.whereType<Brands>().toList();
              final matched = brands.firstWhere(
                (b) => b.id == widget.product.brandId.id,
                orElse: () => Brands(),
              );
              if (matched.id != null && matched.id!.isNotEmpty) {
                setState(() {
                  _selectedBrand = matched;
                  _brandPrePopulated = true;
                });
              } else {
                _brandPrePopulated = true;
              }
            }
          },
          builder: (context, state) {
            if (state is GetBrandsLoading) {
              return _loadingWidget('جاري تحميل العلامات التجارية...');
            }
            if (state is GetBrandsSuccess) {
              final brands = state.brands.whereType<Brands>().toList();
              return buildDropdownField<Brands>(
                context,
                items: brands,
                label: 'العلامة التجارية *',
                hint: 'اختر العلامة التجارية',
                value: _selectedBrand,
                onChanged: (val) => setState(() => _selectedBrand = val),
                itemLabel: (b) => b.name ?? '',
              );
            }
            return EmptyStateWidget(
              message: 'لا توجد علامات تجارية',
              icon: Icons.branding_watermark_outlined,
              color: AppColors.warningOrange,
            );
          },
        ),
      ],
    );
  }

  // ── Section 3: Units ──────────────────────────────────────────────────────
  Widget _buildUnitsSection() {
    return ProductSectionCard(
      title: 'وحدات القياس',
      icon: Icons.straighten_outlined,
      children: [
        BlocConsumer<UnitsCubit, UnitsState>(
          listener: (context, state) {
            if (!_unitPrePopulated && state is GetUnitsSuccess) {
              final matched = state.units.firstWhere(
                (u) => u.name == widget.product.unit,
                orElse: () => UnitModel(),
              );
              if (matched.id != null && matched.id!.isNotEmpty) {
                setState(() {
                  _selectedProductUnit = matched;
                  _unitPrePopulated = true;
                });
              } else {
                _unitPrePopulated = true;
              }
            }
          },
          builder: (context, state) {
            if (state is GetUnitsLoading) {
              return _loadingWidget('جاري تحميل الوحدات...');
            }
            if (state is GetUnitsSuccess) {
              return Column(
                children: [
                  buildDropdownField<UnitModel>(
                    context,
                    items: state.units,
                    label: 'وحدة المنتج',
                    hint: 'اختر وحدة المنتج',
                    value: _selectedProductUnit,
                    onChanged: (v) =>
                        setState(() => _selectedProductUnit = v),
                    itemLabel: (u) => u.name ?? '',
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 12)),
                  Row(
                    children: [
                      Expanded(
                        child: buildDropdownField<UnitModel>(
                          context,
                          items: state.units,
                          label: 'وحدة البيع',
                          hint: 'وحدة البيع',
                          value: _selectedSaleUnit,
                          onChanged: (v) =>
                              setState(() => _selectedSaleUnit = v),
                          itemLabel: (u) => u.name ?? '',
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 12)),
                      Expanded(
                        child: buildDropdownField<UnitModel>(
                          context,
                          items: state.units,
                          label: 'وحدة الشراء',
                          hint: 'وحدة الشراء',
                          value: _selectedPurchaseUnit,
                          onChanged: (v) =>
                              setState(() => _selectedPurchaseUnit = v),
                          itemLabel: (u) => u.name ?? '',
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return EmptyStateWidget(
              message: 'لا توجد وحدات',
              icon: Icons.straighten_outlined,
              color: AppColors.warningOrange,
            );
          },
        ),
      ],
    );
  }

  // ── Section 4: Pricing ────────────────────────────────────────────────────
  Widget _buildPricingSection() {
    return ProductSectionCard(
      title: 'التسعير',
      icon: Icons.payments_outlined,
      children: [
        buildTextField(
          context,
          controller: _priceController,
          label: 'سعر البيع *',
          icon: Icons.sell_outlined,
          hint: '0.00',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 12)),
        Row(
          children: [
            Expanded(
              child: buildTextField(
                context,
                controller: _wholePriceController,
                label: 'سعر الجملة',
                icon: Icons.price_change_outlined,
                hint: '0.00',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Expanded(
              child: buildTextField(
                context,
                controller: _minQuantityController,
                label: 'حد الجملة (كمية)',
                icon: Icons.shopping_cart_outlined,
                hint: '50',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Section 5: Stock ──────────────────────────────────────────────────────
  Widget _buildStockSection() {
    return ProductSectionCard(
      title: 'المخزون',
      icon: Icons.inventory_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: buildTextField(
                context,
                controller: _startQuantityController,
                label: 'الكمية الحالية',
                icon: Icons.add_box_outlined,
                hint: '0',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: ResponsiveUI.spacing(context, 12)),
            Expanded(
              child: buildTextField(
                context,
                controller: _lowStockController,
                label: 'تنبيه نفاد المخزون',
                icon: Icons.warning_amber_outlined,
                hint: '10',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Section 6: Settings ───────────────────────────────────────────────────
  Widget _buildSettingsSection() {
    return ProductSectionCard(
      title: 'إعدادات المنتج',
      icon: Icons.tune_outlined,
      children: [
        AnimatedCheckboxTile(
          value: _isFeatured,
          title: 'منتج مميز',
          onChanged: (v) => setState(() => _isFeatured = v ?? false),
        ),
        AnimatedCheckboxTile(
          value: _hasExpiry,
          title: 'له تاريخ انتهاء صلاحية',
          onChanged: (v) => setState(() {
            _hasExpiry = v ?? false;
            if (!_hasExpiry) _expiryDate = null;
          }),
        ),
        if (_hasExpiry)
          DatePickerCard(
            selectedDate: _expiryDate,
            onTap: _selectExpiryDate,
            label: 'تاريخ انتهاء الصلاحية',
          ),
        AnimatedCheckboxTile(
          value: _hasIMEI,
          title: 'له رقم IMEI / تسلسلي',
          onChanged: (v) => setState(() => _hasIMEI = v ?? false),
        ),
        AnimatedCheckboxTile(
          value: _showQuantity,
          title: 'إظهار الكمية للعملاء',
          onChanged: (v) => setState(() => _showQuantity = v ?? false),
        ),
        if (_showQuantity) ...[
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
          buildTextField(
            context,
            controller: _maxToShowController,
            label: 'الحد الأقصى المعروض',
            icon: Icons.visibility_outlined,
            hint: '100',
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 8)),
        ],
      ],
    );
  }

  // ── Section 7: Images ─────────────────────────────────────────────────────
  Widget _buildImagesSection() {
    return ProductSectionCard(
      title: 'صور المنتج',
      icon: Icons.photo_library_outlined,
      children: [
        // Main image — supports existing URL + new file pick
        _buildMainImagePicker(),
        SizedBox(height: ResponsiveUI.spacing(context, 16)),
        // Gallery — existing URLs + new files
        _buildGalleryPicker(),
      ],
    );
  }

  Widget _buildMainImagePicker() {
    final hasNewImage = _mainImage != null;
    final hasExistingUrl =
        _existingImageUrl != null && _existingImageUrl!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.image,
                  size: ResponsiveUI.iconSize(context, 20),
                  color: AppColors.primaryBlue),
              SizedBox(width: ResponsiveUI.value(context, 8)),
              Text(
                'الصورة الرئيسية',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 15),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ]),
            if (hasNewImage || hasExistingUrl)
              TextButton.icon(
                onPressed: () => setState(() {
                  _mainImage = null;
                  _existingImageUrl = null;
                }),
                icon: Icon(Icons.delete_outline,
                    color: AppColors.red,
                    size: ResponsiveUI.iconSize(context, 18)),
                label: Text('إزالة',
                    style: TextStyle(
                        color: AppColors.red,
                        fontSize: ResponsiveUI.fontSize(context, 12))),
              ),
          ],
        ),
        SizedBox(height: ResponsiveUI.value(context, 12)),
        GestureDetector(
          onTap: _pickMainImage,
          child: Container(
            width: double.infinity,
            height: ResponsiveUI.value(context, 220),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
              border: Border.all(
                color: AppColors.primaryBlue.withValues(alpha: 0.4),
                width: ResponsiveUI.value(context, 2),
              ),
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(ResponsiveUI.borderRadius(context, 14)),
              child: hasNewImage
                  ? Stack(children: [
                      Image.file(_mainImage!,
                          width: double.infinity, fit: BoxFit.cover),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _editBadge(),
                      ),
                    ])
                  : hasExistingUrl
                      ? Stack(children: [
                          Image.network(_existingImageUrl!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imagePlaceholder()),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: _editBadge(),
                          ),
                        ])
                      : _imagePlaceholder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _editBadge() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 8)),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.edit,
          size: ResponsiveUI.iconSize(context, 18),
          color: AppColors.primaryBlue),
    );
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.add_photo_alternate,
              size: ResponsiveUI.iconSize(context, 36),
              color: AppColors.primaryBlue),
        ),
        SizedBox(height: ResponsiveUI.value(context, 10)),
        Text('اضغط لتغيير الصورة',
            style: TextStyle(
                color: AppColors.shadowGray,
                fontSize: ResponsiveUI.fontSize(context, 13))),
      ],
    );
  }

  Widget _buildGalleryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              Icon(Icons.collections,
                  size: ResponsiveUI.iconSize(context, 20),
                  color: AppColors.primaryBlue),
              SizedBox(width: ResponsiveUI.value(context, 8)),
              Text(
                'صور المعرض',
                style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 15),
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray),
              ),
            ]),
            TextButton.icon(
              onPressed: _pickGalleryImages,
              icon: Icon(Icons.add_circle,
                  color: AppColors.primaryBlue,
                  size: ResponsiveUI.iconSize(context, 20)),
              label: Text('إضافة',
                  style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontSize: ResponsiveUI.fontSize(context, 13))),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUI.value(context, 10)),
        // Existing URL thumbnails
        if (_existingGalleryUrls.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_existingGalleryUrls.length, (i) {
              return _networkThumbnail(_existingGalleryUrls[i], () {
                setState(() => _existingGalleryUrls.removeAt(i));
              });
            }),
          ),
        if (_existingGalleryUrls.isNotEmpty && _galleryImages.isNotEmpty)
          SizedBox(height: ResponsiveUI.value(context, 10)),
        // New file thumbnails
        if (_galleryImages.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(_galleryImages.length, (i) {
              return _fileThumbnail(_galleryImages[i], () {
                setState(() => _galleryImages.removeAt(i));
              });
            }),
          ),
        if (_existingGalleryUrls.isEmpty && _galleryImages.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBackground,
              borderRadius:
                  BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              border: Border.all(color: AppColors.shadowGray.withValues(alpha: 0.3)),
            ),
            child: Column(children: [
              Icon(Icons.collections_outlined,
                  size: ResponsiveUI.iconSize(context, 36),
                  color: AppColors.shadowGray.withValues(alpha: 0.5)),
              SizedBox(height: ResponsiveUI.value(context, 6)),
              Text('لا توجد صور معرض',
                  style: TextStyle(
                      color: AppColors.shadowGray,
                      fontSize: ResponsiveUI.fontSize(context, 13))),
            ]),
          ),
      ],
    );
  }

  Widget _networkThumbnail(String url, VoidCallback onRemove) {
    return _thumbnail(
      child: Image.network(url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.broken_image, color: AppColors.shadowGray)),
      onRemove: onRemove,
    );
  }

  Widget _fileThumbnail(File file, VoidCallback onRemove) {
    return _thumbnail(
      child: Image.file(file, fit: BoxFit.cover),
      onRemove: onRemove,
    );
  }

  Widget _thumbnail({required Widget child, required VoidCallback onRemove}) {
    final size = ResponsiveUI.value(context, 90.0);
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(ResponsiveUI.borderRadius(context, 10)),
            border: Border.all(color: AppColors.lightGray, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(ResponsiveUI.borderRadius(context, 9)),
            child: child,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 5)),
              decoration: BoxDecoration(
                  color: AppColors.red, shape: BoxShape.circle),
              child: Icon(Icons.close,
                  size: ResponsiveUI.iconSize(context, 14),
                  color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _loadingWidget(String message) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      child: CustomLoadingState(
        message: message,
        color: AppColors.primaryBlue,
        size: ResponsiveUI.iconSize(context, 36),
      ),
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
    _codeController.dispose();
    super.dispose();
  }
}
