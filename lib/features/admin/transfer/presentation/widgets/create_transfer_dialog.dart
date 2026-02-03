
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:systego/core/constants/app_colors.dart';
import 'package:systego/core/utils/responsive_ui.dart';
import 'package:systego/core/widgets/custom_drop_down_menu.dart';
import 'package:systego/core/widgets/custom_loading/build_overlay_loading.dart';
import 'package:systego/core/widgets/custom_snack_bar/custom_snackbar.dart';
import 'package:systego/core/widgets/custom_textfield/build_text_field.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_cubit.dart';
import 'package:systego/features/admin/product/cubit/get_products_cubit/product_state.dart';
import 'package:systego/features/admin/transfer/cubit/transfers_cubit.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_cubit.dart';
import 'package:systego/features/admin/warehouses/cubit/warehouse_state.dart';
import 'package:systego/generated/locale_keys.g.dart';

// Add this model for product selection tracking
class SelectedProduct {
  String? productId;
  TextEditingController quantityController;
  String? error;
  
  SelectedProduct()
      : quantityController = TextEditingController();
  
  void dispose() {
    quantityController.dispose();
  }
}

class CreateTransferDialog extends StatefulWidget {
  const CreateTransferDialog({super.key});

  @override
  State<CreateTransferDialog> createState() => _CreateTransferDialogState();
}

class _CreateTransferDialogState extends State<CreateTransferDialog> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedFromWarehouseId;
  String? _selectedToWarehouseId;
  
  List<SelectedProduct> _selectedProducts = [];
  List<String> _availableProductIds = [];
  Map<String, String> _productNameMap = {};
  
  bool _isFetchingProducts = false;
  bool _hasFetchedProducts = false;

  @override
  void initState() {
    super.initState();
    context.read<WareHouseCubit>().getWarehouses();
    _addProductRow(); // Add one empty row by default
  }

  void _addProductRow() {
    setState(() {
      _selectedProducts.add(SelectedProduct());
    });
  }

  void _removeProductRow(int index) {
    if (_selectedProducts.length > 1) {
      setState(() {
        _selectedProducts[index].dispose();
        _selectedProducts.removeAt(index);
      });
    } else {
      CustomSnackbar.showError(context, LocaleKeys.at_least_one_product.tr());
    }
  }

  void _fetchWarehouseProducts(String warehouseId) {
    setState(() {
      _isFetchingProducts = true;
      _hasFetchedProducts = false;
      _availableProductIds = [];
      _productNameMap = {};
      
      // Reset all product selections when warehouse changes
      for (var product in _selectedProducts) {
        product.productId = null;
        product.quantityController.clear();
      }
    });

    context.read<ProductsCubit>().getWareHouseProducts(warehouseId);
  }


  void _updateAvailableProducts(ProductsState productsState) {
  if (productsState is ProductsSuccess) {
    if (productsState.products.isEmpty) {
      // Handle empty products case
      setState(() {
        _availableProductIds = [];
        _productNameMap = {};
        _isFetchingProducts = false;
        _hasFetchedProducts = true;
      });
    } else {
      final currentProductIds = productsState.products.map((e) => e.id).toList();
      final currentProductNames = {
        for (var product in productsState.products) product.id: product.name
      };
      
      if (!listEquals(_availableProductIds, currentProductIds)) {
        setState(() {
          _availableProductIds = currentProductIds;
          _productNameMap = currentProductNames;
          _isFetchingProducts = false;
          _hasFetchedProducts = true;
        });
      }
    }
  } else if (productsState is ProductsError) {
    setState(() {
      _isFetchingProducts = false;
      _hasFetchedProducts = false;
      _availableProductIds = [];
      _productNameMap = {};
    });
  }
}

  // Get used product IDs to filter them out in dropdowns
  List<String> _getAvailableProductsForRow(int currentRowIndex) {
    final usedProductIds = _selectedProducts
        .asMap()
        .entries
        .where((entry) => 
            entry.key != currentRowIndex && 
            entry.value.productId != null)
        .map((entry) => entry.value.productId!)
        .toList();
    
    return _availableProductIds
        .where((id) => !usedProductIds.contains(id))
        .toList();
  }

  @override
  void dispose() {
    for (var product in _selectedProducts) {
      product.dispose();
    }
    super.dispose();
  }

  Widget _buildDialogContent(
    BuildContext context,
    WarehousesState warehouseState,
    ProductsState productsState,
    bool isSubmitting,
  ) {

     if (_selectedFromWarehouseId != null && 
      _selectedFromWarehouseId!.isNotEmpty &&
      !_hasFetchedProducts) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateAvailableProducts(productsState);
      }
    });
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
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveUI.spacing(context, 12)),

                    if (warehouseState is WarehousesLoaded) ...[
                      // From Warehouse Dropdown
                      buildDropdownField<String>(
                        context,
                        value: _selectedFromWarehouseId,
                        items: warehouseState.warehouses
                            .map((e) => e.id)
                            .toList(),
                        label: "From Warehouse",
                        hint: "Select warehouse",
                        icon: Icons.logout,
                        onChanged: (v) {
                          setState(() {
                            _selectedFromWarehouseId = v;
                            _selectedToWarehouseId = null;
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

                      // To Warehouse Dropdown
                      buildDropdownField<String>(
                        context,
                        value: _selectedToWarehouseId,
                        items: warehouseState.warehouses
                            .map((e) => e.id)
                            .toList()
                            .where((id) => id != _selectedFromWarehouseId)
                            .toList(),
                        label: "To Warehouse",
                        hint: "Select warehouse",
                        icon: Icons.login,
                        onChanged: (v) {
                          setState(() {
                            _selectedToWarehouseId = v;
                          });
                        },
                        itemLabel: (id) => warehouseState.warehouses
                            .firstWhere((w) => w.id == id)
                            .name,
                        validator: (v) =>
                            v == null ? "Please select warehouse" : null,
                      ),

                      SizedBox(height: ResponsiveUI.spacing(context, 12)),

                      // Products Section
                      if (_selectedFromWarehouseId != null) ...[
                        const Divider(),
                        SizedBox(height: ResponsiveUI.spacing(context, 16)),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              LocaleKeys.products.tr(),
                              style: const TextStyle(
                                fontSize: 18, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _selectedFromWarehouseId != null &&
                                      _hasFetchedProducts &&
                                      _availableProductIds.isNotEmpty
                                  ? _addProductRow
                                  : null,
                              icon: const Icon(Icons.add),
                              label: Text(LocaleKeys.add_product.tr()),
                            )
                          ],
                        ),
                        
                        if (_isFetchingProducts) ...[
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),
                          _buildProductsLoading(),
                        ] else if (_hasFetchedProducts &&
                            _availableProductIds.isEmpty) ...[
                          SizedBox(height: ResponsiveUI.spacing(context, 16)),
                          _buildNoProductsMessage(),
                        ],
                        
                        SizedBox(height: ResponsiveUI.spacing(context, 8)),
                        
                        // Product Rows
                        if (_hasFetchedProducts) ...[
                          ..._selectedProducts.asMap().entries.map((entry) {
                            return _buildProductRow(
                              entry.key, 
                              entry.value, 
                              productsState
                            );
                          }),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
          _buildFooter(context, isSubmitting),
        ],
      ),
    );
  }

  Widget _buildProductRow(
    int index, 
    SelectedProduct selectedProduct, 
    ProductsState productsState
  ) {
    final availableProductsForRow = _getAvailableProductsForRow(index);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Dropdown
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) 
                  Text(
                    LocaleKeys.product_name.tr(),
                    style: TextStyle(
                      fontSize: ResponsiveUI.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                SizedBox(height: index == 0 ? 8 : 0),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUI.padding(context, 12),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedProduct.error != null
                          ? Colors.red
                          : Colors.grey[300]!,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    value: selectedProduct.productId,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(
                      LocaleKeys.select_product.tr(),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          LocaleKeys.select_product.tr(),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      ...availableProductsForRow.map((productId) {
                        return DropdownMenuItem<String>(
                          value: productId,
                          child: Text(_productNameMap[productId] ?? productId),
                        );
                      }).toList(),
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        selectedProduct.productId = value;
                        selectedProduct.error = null;
                      });
                    },
                  ),
                ),
                if (selectedProduct.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      selectedProduct.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Quantity Input
          Expanded(
            flex: 1,
            child: buildTextField(
              context,
              controller: selectedProduct.quantityController,
              icon: Icons.safety_check,
              label: index == 0 ? LocaleKeys.quantity.tr() : "",
              hint: "0",
              keyboardType: TextInputType.number,
            ),
          ),
          // Delete Button
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 25 : 5),
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeProductRow(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsLoading() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(color: Colors.blue[100]!),
        color: Colors.blue[50],
      ),
      child: Row(
        children: [
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
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Text(
              "Loading products from warehouse...",
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: ResponsiveUI.fontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProductsMessage() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          ResponsiveUI.borderRadius(context, 12),
        ),
        border: Border.all(color: Colors.orange[100]!),
        color: Colors.orange[50],
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined, color: Colors.orange[600]),
          SizedBox(width: ResponsiveUI.spacing(context, 12)),
          Expanded(
            child: Text(
              "No products available in the selected warehouse",
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: ResponsiveUI.fontSize(context, 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.all(ResponsiveUI.padding(context, 16)),
      child: BlocConsumer<TransfersCubit, TransfersState>(
        listener: _handleStateChanges,
        builder: (context, state) {
          final warehouseState = context.watch<WareHouseCubit>().state;
          final productsState = context.watch<ProductsCubit>().state;
          final isDataLoading = warehouseState is WarehousesLoading;
          final isSubmitting = state is CreateTransferLoading;

          return Stack(
            children: [
              _buildDialogContent(
                context,
                warehouseState,
                productsState,
                isSubmitting,
              ),
              if (isDataLoading || isSubmitting)
                buildLoadingOverlay(context, 45),
            ],
          );
        },
      ),
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
          color: AppColors.black.withOpacity(0.2),
          blurRadius: ResponsiveUI.value(context, 30),
          offset: Offset(0, ResponsiveUI.value(context, 10)),
        ),
      ],
    );
  }

  void _handleStateChanges(BuildContext context, TransfersState state) {
    if (state is CreateTransferSuccess) {
      Navigator.of(context).pop();
    }
    if (state is CreateTransferError) {
      CustomSnackbar.showError(context, state.error);
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 20)),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, color: Colors.white),
          const SizedBox(width: 10),
          Text(
            LocaleKeys.create_transfer.tr(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isLoading) {
    return Padding(
      padding: EdgeInsets.all(ResponsiveUI.padding(context, 24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: isLoading ? null : () => Navigator.pop(context),
            child: Text(LocaleKeys.cancel.tr()),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text(LocaleKeys.submit.tr()),
          ),
        ],
      ),
    );
  }

  void _submit() {
    // Validate warehouses
    if (_selectedFromWarehouseId == null) {
      CustomSnackbar.showError(context, "Please select from warehouse");
      return;
    }
    
    if (_selectedToWarehouseId == null) {
      CustomSnackbar.showError(context, "Please select to warehouse");
      return;
    }
    
    // Validate products
    bool hasErrors = false;
    for (var i = 0; i < _selectedProducts.length; i++) {
      final product = _selectedProducts[i];
      
      if (product.productId == null) {
        setState(() {
          product.error = "Please select a product";
        });
        hasErrors = true;
      }
      
      final quantity = product.quantityController.text.trim();
      if (quantity.isEmpty) {
        CustomSnackbar.showError(context, "Please enter quantity for all products");
        hasErrors = true;
        break;
      }
      
      final quantityInt = int.tryParse(quantity);
      if (quantityInt == null || quantityInt <= 0) {
        CustomSnackbar.showError(context, "Quantity must be a positive number");
        hasErrors = true;
        break;
      }
    }
    
    if (hasErrors) {
      return;
    }
    
    // Prepare products payload
    final List<Map<String, dynamic>> productsPayload = _selectedProducts.map((product) {
      return {
        "productId": product.productId!,
        "quantity": int.parse(product.quantityController.text.trim()),
      };
    }).toList();

    context.read<TransfersCubit>().createTransfer(
      fromId: _selectedFromWarehouseId!,
      toId: _selectedToWarehouseId!,
      products: productsPayload,
    );
  }
}