import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/app_bar_widgets.dart';
import 'package:systego/core/widgets/custom_button_widget.dart';
import 'package:systego/core/widgets/custom_loading/custom_loading_state.dart';
import 'package:systego/core/widgets/custom_textfield/custom_text_field_widget.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:systego/features/admin/product/cubit/product_filter_cubit.dart';
import 'package:systego/features/admin/product/cubit/product_filter_state.dart';
import 'package:systego/features/admin/product/models/filter_models.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _wholePriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _lowStockController = TextEditingController();
  final _minQuantityController = TextEditingController();
  final _maxToShowController = TextEditingController();
  final _unitController = TextEditingController();

  // Images
  File? _mainImage;
  List<File> _galleryImages = [];

  // Dropdowns
  List<CategoryFilter>? _selectedCategories;
  BrandFilter? _selectedBrand;

  // Checkboxes
  bool _hasExpiry = false;
  bool _hasIMEI = false;
  bool _differentPrice = false;
  bool _showQuantity = true;

  @override
  void initState() {
    super.initState();
    context.read<ProductFiltersCubit>().getFilters();

    // Set default values
    _minQuantityController.text = '1';
    _lowStockController.text = '10';
    _maxToShowController.text = '100';
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
    setState(() {
      _galleryImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProductsCubit, ProductsState>(
      listener: (context, state) {
        if (state is ProductAddSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
              ),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
          Navigator.pop(context, true);
        } else if (state is ProductsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
              ),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: appBarWithActions(context, title: "New Product"),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.horizontalPadding(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: ResponsiveUI.spacing(context, 8)),

                  // Product Name
                  _buildSectionTitle('Product Information'),
                  CustomTextField(
                    controller: _nameController,
                    labelText: 'Product Name',
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.inventory_2,
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  // Description
                  CustomTextField(
                    controller: _descriptionController,
                    labelText: 'Description',
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.description,
                    maxLines: 3,
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  // Categories Dropdown
                  _buildSectionTitle('Category & Brand'),
                  BlocBuilder<ProductFiltersCubit, ProductFiltersState>(
                    builder: (context, filtersState) {
                      if (filtersState is ProductFiltersLoading) {
                        return _buildLoadingDropdown('Loading categories...');
                      }

                      if (filtersState is ProductFiltersSuccess) {
                        if (filtersState.filters.data != null &&
                            filtersState.filters.data!.categories.isNotEmpty) {}
                        return _buildCategoriesDropdown(
                          filtersState.filters.data!.categories,
                        );
                      }

                      return _buildEmptyDropdown('No categories available');
                    },
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  // Brand Dropdown
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

                      return _buildEmptyDropdown('No brands available');
                    },
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  // Pricing Information
                  _buildSectionTitle('Pricing & Stock'),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _priceController,
                          labelText: 'Price',
                          hasBoxDecoration: false,
                          hasBorder: true,
                          prefixIcon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 12)),
                      Expanded(
                        child: CustomTextField(
                          controller: _wholePriceController,
                          labelText: 'Wholesale Price',
                          hasBoxDecoration: false,
                          hasBorder: true,
                          prefixIcon: Icons.money_off,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  // Quantity & Unit
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _quantityController,
                          labelText: 'Quantity',
                          hasBoxDecoration: false,
                          hasBorder: true,
                          prefixIcon: Icons.inventory,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 12)),
                      Expanded(
                        child: CustomTextField(
                          controller: _unitController,
                          labelText: 'Unit (piece, kg, etc.)',
                          hasBoxDecoration: false,
                          hasBorder: true,
                          prefixIcon: Icons.scale,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  // Stock Settings
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _lowStockController,
                          labelText: 'Low Stock Alert',
                          hasBoxDecoration: false,
                          hasBorder: true,
                          prefixIcon: Icons.warning,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: ResponsiveUI.spacing(context, 12)),
                      Expanded(
                        child: CustomTextField(
                          controller: _minQuantityController,
                          labelText: 'Min. Sale Quantity',
                          hasBoxDecoration: false,
                          hasBorder: true,
                          prefixIcon: Icons.shopping_cart,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 16)),

                  CustomTextField(
                    controller: _maxToShowController,
                    labelText: 'Maximum to Show',
                    hasBoxDecoration: false,
                    hasBorder: true,
                    prefixIcon: Icons.visibility,
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),

                  // Product Settings
                  _buildSectionTitle('Product Settings'),
                  CheckboxListTile(
                    value: _hasExpiry,
                    onChanged: (value) =>
                        setState(() => _hasExpiry = value ?? false),
                    title: Text(
                      'Has Expiry Date',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryBlue,
                  ),
                  CheckboxListTile(
                    value: _hasIMEI,
                    onChanged: (value) =>
                        setState(() => _hasIMEI = value ?? false),
                    title: Text(
                      'Product has IMEI/Serial Number',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryBlue,
                  ),
                  CheckboxListTile(
                    value: _differentPrice,
                    onChanged: (value) =>
                        setState(() => _differentPrice = value ?? false),
                    title: Text(
                      'Different prices for variations',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryBlue,
                  ),
                  CheckboxListTile(
                    value: _showQuantity,
                    onChanged: (value) =>
                        setState(() => _showQuantity = value ?? true),
                    title: Text(
                      'Show quantity in store',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primaryBlue,
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),

                  // Main Image
                  _buildSectionTitle('Product Images'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Main Image*',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14),
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_mainImage != null)
                        TextButton.icon(
                          icon: Icon(
                            Icons.delete,
                            color: AppColors.red,
                            size: ResponsiveUI.iconSize(context, 18),
                          ),
                          label: Text(
                            'Remove',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: ResponsiveUI.fontSize(context, 12),
                            ),
                          ),
                          onPressed: () => setState(() => _mainImage = null),
                        ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 10)),
                  GestureDetector(
                    onTap: _pickMainImage,
                    child: Container(
                      width: ResponsiveUI.value(context, 140),
                      height: ResponsiveUI.value(context, 140),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          ResponsiveUI.borderRadius(context, 12),
                        ),
                        border: Border.all(
                          color: AppColors.lightGray,
                          width: 2,
                        ),
                      ),
                      child: _mainImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(
                                ResponsiveUI.borderRadius(context, 12),
                              ),
                              child: Image.file(_mainImage!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate_outlined,
                                  size: ResponsiveUI.iconSize(context, 45),
                                  color: AppColors.primaryBlue,
                                ),
                                SizedBox(
                                  height: ResponsiveUI.spacing(context, 8),
                                ),
                                Text(
                                  'Tap to upload',
                                  style: TextStyle(
                                    color: AppColors.darkGray,
                                    fontSize: ResponsiveUI.fontSize(
                                      context,
                                      13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 24)),

                  // Gallery Images
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Gallery Images (Optional)',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 14),
                          color: AppColors.darkGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton.icon(
                        icon: Icon(
                          Icons.add_photo_alternate,
                          color: AppColors.primaryBlue,
                          size: ResponsiveUI.iconSize(context, 18),
                        ),
                        label: Text(
                          'Add Images',
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: ResponsiveUI.fontSize(context, 12),
                          ),
                        ),
                        onPressed: _pickGalleryImages,
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUI.spacing(context, 10)),
                  if (_galleryImages.isNotEmpty)
                    Wrap(
                      spacing: ResponsiveUI.spacing(context, 10),
                      runSpacing: ResponsiveUI.spacing(context, 10),
                      children: List.generate(_galleryImages.length, (index) {
                        return Stack(
                          children: [
                            Container(
                              width: ResponsiveUI.value(context, 80),
                              height: ResponsiveUI.value(context, 80),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUI.borderRadius(context, 8),
                                ),
                                border: Border.all(color: AppColors.lightGray),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  ResponsiveUI.borderRadius(context, 8),
                                ),
                                child: Image.file(
                                  _galleryImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -8,
                              right: -8,
                              child: IconButton(
                                icon: Container(
                                  padding: EdgeInsets.all(
                                    ResponsiveUI.padding(context, 4),
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: ResponsiveUI.iconSize(context, 12),
                                    color: Colors.white,
                                  ),
                                ),
                                onPressed: () => _removeGalleryImage(index),
                              ),
                            ),
                          ],
                        );
                      }),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      child: Text(
        title,
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 16),
          fontWeight: FontWeight.bold,
          color: AppColors.primaryBlue,
        ),
      ),
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

  Widget _buildEmptyDropdown(String message) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.warningOrange,
            size: ResponsiveUI.iconSize(context, 20),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 8)),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 12),
                color: Colors.orange[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesDropdown(List<CategoryFilter> categories) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.lightGray, width: 1.5),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: ResponsiveUI.borderRadius(context, 6),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownSearch<CategoryFilter>.multiSelection(
        popupProps: PopupPropsMultiSelection.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Search categories...',
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 12),
                vertical: ResponsiveUI.padding(context, 8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.darkGray),
            ),
          ),
        ),
        items: categories,
        itemAsString: (CategoryFilter item) => item.name,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 12),
              vertical: ResponsiveUI.padding(context, 10),
            ),
            border: InputBorder.none,
            hintText: 'Select categories',
            suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.darkGray),
          ),
        ),
        onChanged: (List<CategoryFilter> value) {
          setState(() => _selectedCategories = value);
        },
      ),
    );
  }

  Widget _buildBrandDropdown(List<BrandFilter> brands) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.lightGray, width: 1.5),
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: ResponsiveUI.borderRadius(context, 6),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownSearch<BrandFilter>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              hintText: 'Search brands...',
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUI.padding(context, 12),
                vertical: ResponsiveUI.padding(context, 8),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveUI.borderRadius(context, 8),
                ),
              ),
              prefixIcon: Icon(Icons.search, color: AppColors.darkGray),
            ),
          ),
        ),
        items: brands,
        itemAsString: (BrandFilter item) => item.name,
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 12),
              vertical: ResponsiveUI.padding(context, 10),
            ),
            border: InputBorder.none,
            hintText: 'Select brand',
            suffixIcon: Icon(Icons.arrow_drop_down, color: AppColors.darkGray),
          ),
        ),
        onChanged: (BrandFilter? value) {
          setState(() => _selectedBrand = value);
        },
      ),
    );
  }

  void _saveProduct() {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter product name');
      return;
    }
    if (_mainImage == null) {
      _showError('Please select main product image');
      return;
    }
    if (_selectedCategories == null || _selectedCategories!.isEmpty) {
      _showError('Please select at least one category');
      return;
    }
    if (_selectedBrand == null) {
      _showError('Please select a brand');
      return;
    }
    if (_priceController.text.trim().isEmpty) {
      _showError('Please enter product price');
      return;
    }
    if (_unitController.text.trim().isEmpty) {
      _showError('Please enter product unit');
      return;
    }

    // TODO: Implement actual save logic with ProductsCubit
    // This will require updating the cubit method to accept parameters
    context.read<ProductsCubit>().addProduct();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontSize: ResponsiveUI.fontSize(context, 14)),
        ),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            ResponsiveUI.borderRadius(context, 8),
          ),
        ),
        margin: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _wholePriceController.dispose();
    _quantityController.dispose();
    _lowStockController.dispose();
    _minQuantityController.dispose();
    _maxToShowController.dispose();
    _unitController.dispose();
    super.dispose();
  }
}
