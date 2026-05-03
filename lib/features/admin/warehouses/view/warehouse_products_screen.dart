import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:GoSystem/core/widgets/app_bar_widgets.dart';
import 'package:GoSystem/generated/locale_keys.g.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:GoSystem/core/constants/app_colors.dart';
import 'package:GoSystem/core/utils/responsive_ui.dart';
import 'package:GoSystem/core/widgets/custom_error/custom_empty_state.dart';
import 'package:GoSystem/core/widgets/custom_loading/custom_loading_state_with_shimmer.dart';
import 'package:GoSystem/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:GoSystem/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:GoSystem/features/admin/warehouses/model/ware_house_model.dart';
import 'package:GoSystem/features/admin/product/presentation/widgets/search_bar_widget.dart';
import 'package:GoSystem/features/admin/warehouses/view/add_product_to_warehouse_screen.dart';

class WarehouseProductsScreen extends StatefulWidget {
  final Warehouses warehouse;

  const WarehouseProductsScreen({
    super.key,
    required this.warehouse,
  });

  @override
  State<WarehouseProductsScreen> createState() => _WarehouseProductsScreenState();
}

class _WarehouseProductsScreenState extends State<WarehouseProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredProducts = [];
  List<dynamic> _allProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadWarehouseProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadWarehouseProducts() async {
    setState(() => _isLoading = true);
    
    try {
      final productsData = await context.read<WareHouseCubit>().getWarehouseProducts(widget.warehouse.id);
      
      if (productsData != null) {
        setState(() {
          _allProducts = productsData['products'] ?? [];
          _filteredProducts = List.from(_allProducts);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (error) {
      setState(() => _isLoading = false);
      CustomSnackbar.showError(context, 'Failed to load products');
    }
    return;
  }

  void _filterProducts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = List.from(_allProducts);
      } else {
        _filteredProducts = _allProducts.where((product) {
          final nameLower = (product['name'] ?? '').toLowerCase();
          final codeLower = (product['code'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();
          
          return nameLower.contains(searchLower) || codeLower.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scale down for web
    Widget screenContent = Scaffold(
      backgroundColor: AppColors.lightBlueBackground,
      appBar: appBarWithActions(
        context,
        title: LocaleKeys.warehouse_products.tr(),
        showBackButton: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildWarehouseInfo(),
            _buildInventoryHeader(),
            Expanded(child: _buildProductsList()),
          ],
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

  Widget _buildWarehouseInfo() {
    return Container(
      margin: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.white, AppColors.lightBlueBackground],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUI.padding(context, 12)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.darkBlue],
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                ),
                child: Icon(
                  Icons.warehouse,
                  color: Colors.white,
                  size: ResponsiveUI.iconSize(context, 24),
                ),
              ),
              SizedBox(width: ResponsiveUI.spacing(context, 16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.warehouse.name,
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                    SizedBox(height: ResponsiveUI.spacing(context, 4)),
                    Text(
                      'Warehouse Details',
                      style: TextStyle(
                        fontSize: ResponsiveUI.fontSize(context, 14),
                        color: AppColors.darkGray.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 20)),
          _buildInfoRow(Icons.location_on, 'Address', widget.warehouse.address ?? 'N/A'),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildInfoRow(Icons.phone, 'Phone', widget.warehouse.phone ?? 'N/A'),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildInfoRow(Icons.email, 'Email', widget.warehouse.email ?? 'N/A'),
          SizedBox(height: ResponsiveUI.spacing(context, 12)),
          _buildInfoRow(Icons.inventory, 'Capacity', '${widget.warehouse.stockQuantity ?? 0} Total Items'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveUI.iconSize(context, 18),
          color: AppColors.primaryBlue,
        ),
        SizedBox(width: ResponsiveUI.spacing(context, 12)),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: ResponsiveUI.fontSize(context, 14),
            fontWeight: FontWeight.w600,
            color: AppColors.darkGray,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: ResponsiveUI.fontSize(context, 14),
              color: AppColors.darkGray.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryHeader() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: ResponsiveUI.padding(context, 16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: ResponsiveUI.spacing(context, 8),
            runSpacing: ResponsiveUI.spacing(context, 8),
            children: [
              Text(
                'Inventory Management',
                style: TextStyle(
                  fontSize: ResponsiveUI.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddProductToWarehouseScreen(
                        warehouseId: widget.warehouse.id,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.add, size: ResponsiveUI.iconSize(context, 18)),
                label: const Text('Add New Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.successGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 16),
                    vertical: ResponsiveUI.padding(context, 12),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUI.spacing(context, 16)),
          SearchBarWidget(
            text: 'Search products',
            controller: _searchController,
            onChanged: _filterProducts,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList() {
    if (_isLoading) {
      return CustomLoadingShimmer(
        padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      );
    }

    if (_allProducts.isEmpty) {
      return CustomEmptyState(
        icon: Icons.inventory_outlined,
        title: 'No Products Found',
        message: 'This warehouse has no products yet.',
        onRefresh: _loadWarehouseProducts,
        actionLabel: 'Refresh',
        onAction: _loadWarehouseProducts,
      );
    }

    if (_filteredProducts.isEmpty) {
      return CustomEmptyState(
        icon: Icons.search_off,
        title: 'No Results Found',
        message: 'Try adjusting your search terms',
        onRefresh: () async {
          _searchController.clear();
          _filterProducts('');
        },
        actionLabel: 'Clear Search',
        onAction: () async {
          _searchController.clear();
          _filterProducts('');
        },
      );
    }

    return Container(
      margin: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProductsHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return _buildProductItem(product, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
          topRight: Radius.circular(ResponsiveUI.borderRadius(context, 16)),
        ),
      ),
      child: Text(
        'PRODUCT NAME',
        style: TextStyle(
          fontSize: ResponsiveUI.fontSize(context, 14),
          fontWeight: FontWeight.bold,
          color: AppColors.darkGray,
        ),
      ),
    );
  }

  Widget _buildProductItem(dynamic product, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUI.spacing(context, 12)),
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        color: AppColors.shadowGray[50],
        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 12)),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveUI.value(context, 40),
            height: ResponsiveUI.value(context, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.successGreen.withValues(alpha: 0.2), AppColors.successGreen.withValues(alpha: 0.1)],
              ),
              borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
            ),
            child: product['image'] != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 8)),
                    child: Image.network(
                      product['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.inventory_2,
                          color: AppColors.successGreen,
                          size: ResponsiveUI.iconSize(context, 20),
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.inventory_2,
                    color: AppColors.successGreen,
                    size: ResponsiveUI.iconSize(context, 20),
                  ),
          ),
          SizedBox(width: ResponsiveUI.spacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] ?? 'Unknown Product',
                  style: TextStyle(
                    fontSize: ResponsiveUI.fontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGray,
                  ),
                ),
                SizedBox(height: ResponsiveUI.spacing(context, 4)),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUI.padding(context, 8),
                        vertical: ResponsiveUI.padding(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
                      ),
                      child: Text(
                        'Qty: ${product['quantity'] ?? 0}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: ResponsiveUI.spacing(context, 8)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveUI.padding(context, 8),
                        vertical: ResponsiveUI.padding(context, 4),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.shadowGray.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(ResponsiveUI.borderRadius(context, 6)),
                      ),
                      child: Text(
                        'Price: ${product['price'] ?? 0}',
                        style: TextStyle(
                          fontSize: ResponsiveUI.fontSize(context, 12),
                          color: AppColors.linkBlue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


