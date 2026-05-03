import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/product/models/product_model.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:GoSystem/features/admin/product/cubit/get_products_cubit/product_state.dart';

class AddProductToWarehouseScreen extends StatefulWidget {
  final String warehouseId;

  const AddProductToWarehouseScreen({
    super.key,
    required this.warehouseId,
  });

  @override
  State<AddProductToWarehouseScreen> createState() => _AddProductToWarehouseScreenState();
}

class _AddProductToWarehouseScreenState extends State<AddProductToWarehouseScreen> {
  final TextEditingController _productSearchController = TextEditingController();
  final TextEditingController _initialStockController = TextEditingController();
  final TextEditingController _lowStockController = TextEditingController();
  
  Product? _selectedProduct;
  List<Product> _availableProducts = [];
  List<Product> _filteredProducts = [];
  bool _showProductDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableProducts();
    _productSearchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _productSearchController.removeListener(_onSearchChanged);
    _productSearchController.dispose();
    _initialStockController.dispose();
    _lowStockController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _productSearchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_availableProducts);
      } else {
        _filteredProducts = _availableProducts.where((product) {
          return product.name.toLowerCase().contains(query);
        }).toList();
      }
      _showProductDropdown = query.isNotEmpty || _filteredProducts.isNotEmpty;
    });
  }

  Future<void> _loadAvailableProducts() async {
    try {
      await context.read<ProductsCubit>().getProducts();
      final state = context.read<ProductsCubit>().state;
      if (state is ProductsSuccess) {
        if (mounted) {
          setState(() {
            _availableProducts = state.products;
            _filteredProducts = List.from(_availableProducts);
          });
        }
      }
    } catch (error) {
      if (mounted) {
        CustomSnackbar.showError(context, 'Failed to load products');
      }
    }
    return;
  }

  void _selectProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _productSearchController.text = product.name;
      _showProductDropdown = false;
    });
  }

  Future<void> _confirmEntry() async {
    if (_selectedProduct == null) {
      CustomSnackbar.showError(context, 'Please select a product');
      return;
    }

    final quantity = int.tryParse(_initialStockController.text);
    final lowStock = int.tryParse(_lowStockController.text);

    if (quantity == null || quantity <= 0) {
      CustomSnackbar.showError(context, 'Please enter a valid quantity');
      return;
    }

    if (lowStock == null || lowStock < 0) {
      CustomSnackbar.showError(context, 'Please enter a valid low stock level');
      return;
    }

    try {
      final cubit = context.read<WareHouseCubit>();
      final response = await cubit.addProductToWarehouse(
        productId: _selectedProduct!.id,
        warehouseId: widget.warehouseId,
        quantity: quantity,
        lowStock: lowStock,
      );

      if (!mounted) return;
      if (response) {
        CustomSnackbar.showSuccess(context, 'Product added to warehouse successfully');
        Navigator.pop(context);
      } else {
        CustomSnackbar.showError(context, 'Failed to add product to warehouse');
      }
    } catch (error) {
      if (!mounted) return;
      CustomSnackbar.showError(context, 'Failed to add product to warehouse');
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(context, title: "إضافة منتج للمستودع"),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: ResponsiveUI.spacing(context, 20)),
              _buildProductSelectionField(),
              SizedBox(height: ResponsiveUI.spacing(context, 20)),
              _buildInitialStockField(),
              SizedBox(height: ResponsiveUI.spacing(context, 20)),
              _buildLowStockField(),
              SizedBox(height: ResponsiveUI.spacing(context, 30)),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
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

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primaryBlue, AppColors.darkBlue],
            ),
            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            color: Colors.white,
            size: ResponsiveUI.iconSize(context, 28),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Inventory Entry',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 24),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              SizedBox(height: ResponsiveUI.spacing(context, 4)),
              Text(
                'Register new stock for your warehouse',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 16),
                  color: AppColors.darkGray.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductSelectionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Product *',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.successGreen,
                  width: ResponsiveUI.value(context, 2),
                ),
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              ),
              child: TextField(
                controller: _productSearchController,
                decoration: InputDecoration(
                  hintText: 'Search by name / code / scan...',
                  hintStyle: TextStyle(
                    color: AppColors.darkGray.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.successGreen,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                    vertical: ResponsiveUI.padding(context, 14),
                  ),
                ),
              ),
            ),
            if (_showProductDropdown && _filteredProducts.isNotEmpty)
              Positioned(
                top: ResponsiveUI.padding(context, 60),
                left: 0,
                right: 0,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: ResponsiveUI.value(context, 200),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return ListTile(
                        leading: Container(
                          width: ResponsiveUI.value(context, 40),
                          height: ResponsiveUI.value(context, 40),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primaryBlue.withValues(alpha: 0.2), AppColors.primaryBlue.withValues(alpha: 0.1)],
                            ),
                            borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                          ),
                          child: product.image.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                                  child: Image.network(
                                    product.image,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.inventory_2,
                                        color: AppColors.primaryBlue,
                                        size: ResponsiveUI.iconSize(context, 20),
                                      );
                                    },
                                  ),
                                )
                              : Icon(
                                  Icons.inventory_2,
                                  color: AppColors.primaryBlue,
                                  size: ResponsiveUI.iconSize(context, 20),
                                ),
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: ResponsiveUI.fontSize(context, 14),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: null,
                        onTap: () => _selectProduct(product),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildInitialStockField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Initial Stock Quantity *',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        TextField(
          controller: _initialStockController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'How many pieces are you adding?',
            hintStyle: TextStyle(
              color: AppColors.darkGray.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              borderSide: BorderSide(
                color: AppColors.darkGray.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              borderSide: BorderSide(
                color: AppColors.darkGray.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: ResponsiveUI.value(context, 2),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Low Stock Alert Level *',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 16),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        SizedBox(height: ResponsiveUI.spacing(context, 8)),
        TextField(
          controller: _lowStockController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Alert me when stock falls below...',
            hintStyle: TextStyle(
              color: AppColors.darkGray.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              borderSide: BorderSide(
                color: AppColors.darkGray.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              borderSide: BorderSide(
                color: AppColors.darkGray.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              borderSide: BorderSide(
                color: AppColors.primaryBlue,
                width: ResponsiveUI.value(context, 2),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: ResponsiveUI.padding(context, 16),
              vertical: ResponsiveUI.padding(context, 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUI.padding(context, 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              ),
              side: BorderSide(
                color: AppColors.darkGray.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 16)),
        Expanded(
          child: ElevatedButton(
            onPressed: _confirmEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveUI.padding(context, 16),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
              ),
            ),
            child: Text(
              'Confirm Entry',
              style: TextStyle(
                fontSize: ResponsiveUI.fontSize(context, 16),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

